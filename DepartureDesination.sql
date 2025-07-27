DELIMITER $$

CREATE PROCEDURE selectDepartureDestination(
    IN inputId BIGINT
)
BEGIN
    IF inputId IS NULL THEN
        -- Select all records if no ID is provided
        SELECT * FROM DepartureDestination WHERE isActive = TRUE;
    ELSE
        -- Select a specific record by ID if it exists
        IF EXISTS (SELECT 1 FROM DepartureDestination WHERE id = inputId AND isActive = TRUE) THEN
            SELECT * FROM DepartureDestination WHERE id = inputId;
        ELSE
            SELECT 'Error: No record found with the specified ID or the record is inactive.' AS ErrorMessage;
        END IF;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE addDepartureDestination(
    IN inputFrom VARCHAR(255),
    IN inputTo VARCHAR(255),
    IN inputDepartureTime DATETIME,
    IN inputArrivalTime DATETIME,
    IN inputIsActive BOOL
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Insert new record into DepartureDestination
    INSERT INTO DepartureDestination (`from`, `to`, departureTime, arrivalTime, isActive)
    VALUES (inputFrom, inputTo, inputDepartureTime, inputArrivalTime, inputIsActive);

    SET message = 'Success: New DepartureDestination record has been added.';

    -- Return success message
    SELECT message AS Message;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE deleteDepartureDestination(
    IN inputId BIGINT
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Check if the record exists and is active
    IF EXISTS (SELECT 1 FROM DepartureDestination WHERE id = inputId AND isActive = TRUE) THEN
        -- Mark the record as inactive rather than deleting it (soft delete)
        UPDATE DepartureDestination SET isActive = FALSE WHERE id = inputId;

        SET message = 'Success: DepartureDestination record has been marked as inactive.';
    ELSE
        SET message = 'Error: No record found with the specified ID or the record is already inactive.';
    END IF;

    -- Return the final message
    SELECT message AS Message;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE updateDepartureDestination(
    IN inputId BIGINT,
    IN newFrom VARCHAR(255),
    IN newTo VARCHAR(255),
    IN newDepartureTime DATETIME,
    IN newArrivalTime DATETIME,
    IN newIsActive BOOL
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Check if the record exists and is active
    IF EXISTS (SELECT 1 FROM DepartureDestination WHERE id = inputId AND isActive = TRUE) THEN
        -- Update the record with new values
        UPDATE DepartureDestination
        SET `from` = newFrom, `to` = newTo, departureTime = newDepartureTime, arrivalTime = newArrivalTime, isActive = newIsActive
        WHERE id = inputId;

        SET message = 'Success: DepartureDestination record has been updated.';
    ELSE
        SET message = 'Error: No record found with the specified ID or the record is inactive.';
    END IF;

    -- Return the final message
    SELECT message AS Message;
END$$

DELIMITER ;



