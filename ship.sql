use senja;

DELIMITER $$

CREATE PROCEDURE addShip(
    IN inputName VARCHAR(255), 
    IN inputColor VARCHAR(100), 
    IN inputCountry VARCHAR(100)
)
BEGIN
    DECLARE exitMessage VARCHAR(255);
    DECLARE errorOccurred BOOLEAN DEFAULT FALSE;
    DECLARE duplicateFound BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET errorOccurred = TRUE;
        SET exitMessage = 'Error: An unknown error occurred.';
        ROLLBACK;
    END;

    IF (SELECT COUNT(*) 
        FROM Ship 
        WHERE name = inputName AND country = inputCountry) > 0 THEN
        SET duplicateFound = TRUE;
        SET exitMessage = 'Error: Ship with the same name and country already exists.';
    END IF;

    IF NOT duplicateFound THEN
        START TRANSACTION;

        INSERT INTO Ship (name, color, country)
        VALUES (inputName, inputColor, inputCountry);

        COMMIT;
        SET exitMessage = 'Ship added successfully!';
    END IF;

    IF errorOccurred OR duplicateFound THEN
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SELECT exitMessage AS SuccessMessage;
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE deleteShip(
    IN inputName VARCHAR(255)
)
BEGIN
    DECLARE exitMessage VARCHAR(255);
    DECLARE errorOccurred BOOLEAN DEFAULT FALSE;
    DECLARE recordNotFound BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET errorOccurred = TRUE;
        SET exitMessage = 'Error: An unknown error occurred.';
        ROLLBACK;
    END;

    IF (SELECT COUNT(*) FROM Ship WHERE name = inputName) = 0 THEN
        SET recordNotFound = TRUE;
        SET exitMessage = 'Error: Ship with the given name does not exist.';
    END IF;

    IF NOT recordNotFound THEN
        START TRANSACTION;

        DELETE FROM Ship WHERE name = inputName;

        COMMIT;
        SET exitMessage = 'Ship deleted successfully!';
    END IF;

    IF errorOccurred OR recordNotFound THEN
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SELECT exitMessage AS SuccessMessage;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE updateShip(
    IN inputId BIGINT,
    IN newName VARCHAR(255),
    IN newColor VARCHAR(100),
    IN newCountry VARCHAR(100)
)
BEGIN
    DECLARE exitMessage VARCHAR(255);
    DECLARE errorOccurred BOOLEAN DEFAULT FALSE;
    DECLARE recordNotFound BOOLEAN DEFAULT FALSE;
    DECLARE duplicateFound BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET errorOccurred = TRUE;
        SET exitMessage = 'Error: An unknown error occurred.';
        ROLLBACK;
    END;

  
    IF (SELECT COUNT(*) FROM Ship WHERE id = inputId) = 0 THEN
        SET recordNotFound = TRUE;
        SET exitMessage = 'Error: Ship with the given ID does not exist.';
    END IF;

   
    IF NOT recordNotFound THEN
        IF (SELECT COUNT(*) 
            FROM Ship 
            WHERE name = newName AND country = newCountry AND id != inputId) > 0 THEN
            SET duplicateFound = TRUE;
            SET exitMessage = 'Error: Ship with the same name and country already exists.';
        END IF;
    END IF;

 
    IF NOT recordNotFound AND NOT duplicateFound THEN
        START TRANSACTION;

        UPDATE Ship
        SET name = newName, color = newColor, country = newCountry
        WHERE id = inputId;

        COMMIT;
        SET exitMessage = 'Ship updated successfully!';
    END IF;

  
    IF errorOccurred OR recordNotFound OR duplicateFound THEN
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SELECT exitMessage AS SuccessMessage;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE selectShip(
    IN inputId BIGINT
)
BEGIN
    DECLARE exitMessage VARCHAR(255);
    DECLARE recordNotFound BOOLEAN DEFAULT FALSE;

    -- If inputId is NULL, fetch all records
    IF inputId IS NULL THEN
        SELECT id, name, color, country, createdAt, isActive
        FROM Ship;
    ELSE
        -- Check if the record exists
        IF (SELECT COUNT(*) FROM Ship WHERE id = inputId) = 0 THEN
            SET recordNotFound = TRUE;
            SET exitMessage = 'Error: Ship with the given ID does not exist.';
        END IF;

        -- Fetch the specific record if it exists
        IF NOT recordNotFound THEN
            SELECT id, name, color, country, createdAt, isActive
            FROM Ship
            WHERE id = inputId;
        ELSE
            -- Output error message if the record is not found
            SELECT exitMessage AS ErrorMessage;
        END IF;
    END IF;
END$$

DELIMITER ;



