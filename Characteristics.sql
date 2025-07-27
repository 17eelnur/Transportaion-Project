use senja;

DELIMITER $$

CREATE PROCEDURE addCharacteristic(
    IN inputSpeed FLOAT,
    IN inputWeight FLOAT,
    IN inputMaxWeight FLOAT,
    IN inputLength FLOAT,
    IN inputHeight FLOAT,
    IN inputMotorType VARCHAR(100),
    IN inputMotorPower FLOAT
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

    -- Check for duplicates based on a unique combination of speed, weight, and motor type
    IF (SELECT COUNT(*)
        FROM Characteristics
        WHERE speed = inputSpeed AND weight = inputWeight AND motorType = inputMotorType) > 0 THEN
        SET duplicateFound = TRUE;
        SET exitMessage = 'Error: A characteristic with the same speed, weight, and motor type already exists.';
    END IF;

    IF NOT duplicateFound THEN
        START TRANSACTION;

        INSERT INTO Characteristics (speed, weight, max_weight, length, height, motorType, motorPower)
        VALUES (inputSpeed, inputWeight, inputMaxWeight, inputLength, inputHeight, inputMotorType, inputMotorPower);

        COMMIT;
        SET exitMessage = 'Characteristic added successfully!';
    END IF;

    IF errorOccurred OR duplicateFound THEN
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SELECT exitMessage AS SuccessMessage;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE deleteCharacteristic(
    IN inputId BIGINT
)
BEGIN
    DECLARE exitMessage VARCHAR(255);
    DECLARE errorOccurred BOOLEAN DEFAULT FALSE;
    DECLARE recordExists BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET errorOccurred = TRUE;
        SET exitMessage = 'Error: An unknown error occurred.';
        ROLLBACK;
    END;

    -- Check if the record exists
    IF (SELECT COUNT(*) FROM Characteristics WHERE id = inputId) > 0 THEN
        SET recordExists = TRUE;
    ELSE
        SET exitMessage = 'Error: No record found with the specified ID.';
    END IF;

    IF recordExists THEN
        START TRANSACTION;

        DELETE FROM Characteristics WHERE id = inputId;

        COMMIT;
        SET exitMessage = 'Record deleted successfully!';
    END IF;

    -- Return appropriate message
    IF errorOccurred THEN
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SELECT exitMessage AS SuccessMessage;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE updateCharacteristic(
    IN inputId BIGINT,
    IN inputSpeed FLOAT,
    IN inputWeight FLOAT,
    IN inputMaxWeight FLOAT,
    IN inputLength FLOAT,
    IN inputHeight FLOAT,
    IN inputMotorType VARCHAR(100),
    IN inputMotorPower FLOAT
)
BEGIN
    DECLARE exitMessage VARCHAR(255);
    DECLARE errorOccurred BOOLEAN DEFAULT FALSE;
    DECLARE recordExists BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET errorOccurred = TRUE;
        SET exitMessage = 'Error: An unknown error occurred.';
        ROLLBACK;
    END;

    -- Check if the record exists
    IF (SELECT COUNT(*) FROM Characteristics WHERE id = inputId) > 0 THEN
        SET recordExists = TRUE;
    ELSE
        SET exitMessage = 'Error: No record found with the specified ID.';
    END IF;

    IF recordExists THEN
        START TRANSACTION;

        UPDATE Characteristics
        SET 
            speed = inputSpeed,
            weight = inputWeight,
            max_weight = inputMaxWeight,
            length = inputLength,
            height = inputHeight,
            motorType = inputMotorType,
            motorPower = inputMotorPower
        WHERE id = inputId;

        COMMIT;
        SET exitMessage = 'Record updated successfully!';
    END IF;

    -- Return appropriate message
    IF errorOccurred THEN
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SELECT exitMessage AS SuccessMessage;
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE selectCharacteristic(
    IN inputId BIGINT
)
BEGIN
    IF inputId IS NULL THEN
        -- Fetch all records
        SELECT * FROM Characteristics;
    ELSE
        -- Fetch record by ID
        IF EXISTS (SELECT 1 FROM Characteristics WHERE id = inputId) THEN
            SELECT * FROM Characteristics WHERE id = inputId;
        ELSE
            SELECT 'Error: No record found with the specified ID.' AS ErrorMessage;
        END IF;
    END IF;
END$$

DELIMITER ;


