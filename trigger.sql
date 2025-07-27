DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS CopyAllTablesToNewDatabase(IN newDatabaseName VARCHAR(255))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tableName VARCHAR(255);
    DECLARE cur CURSOR FOR 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'senja';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Create the new database if it doesn't already exist
    SET @createDatabase = CONCAT('CREATE DATABASE IF NOT EXISTS ', newDatabaseName);
    PREPARE stmt FROM @createDatabase;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Open the cursor to loop through tables
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tableName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Create the table structure in the new database
        SET @createTable = CONCAT('CREATE TABLE IF NOT EXISTS ', newDatabaseName, '.', tableName, ' LIKE senja.', tableName);
        PREPARE stmt FROM @createTable;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Copy the data into the new table
        SET @copyData = CONCAT('INSERT INTO ', newDatabaseName, '.', tableName, ' SELECT * FROM senja.', tableName);
        PREPARE stmt FROM @copyData;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

-- Step 2: Create an event to trigger the backup procedure every day
DELIMITER $$

CREATE EVENT IF NOT EXISTS CopyTablesToNewDatabaseEvent
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE newDatabaseName VARCHAR(255);
    -- Generate a unique backup database name with a timestamp
    SET newDatabaseName = CONCAT('senja_backup_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%S'));
    CALL CopyAllTablesToNewDatabase(newDatabaseName);
END$$

DELIMITER ;

-- Step 3: Create an event to clean up old logs from the ChangeLog table
DELIMITER $$

CREATE EVENT IF NOT EXISTS CleanupChangeLog
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM senja.ChangeLog
    WHERE timestamp < NOW() - INTERVAL 30 DAY;
END$$

DELIMITER ;

SHOW DATABASES;
USE senja_backup_manual;
SHOW TABLES;
SELECT * FROM User; -- Replace <table_name> with a specific table name to confirm data.
SET GLOBAL event_scheduler = ON;
SHOW EVENTS WHERE Db = 'senja';
ALTER EVENT CopyTablesToNewDatabaseEvent 
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE;
SHOW DATABASES;
SELECT * FROM senja.ChangeLog;
