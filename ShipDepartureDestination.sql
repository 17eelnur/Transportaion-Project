DELIMITER $$

CREATE PROCEDURE addShipDepartureDestination(
    IN inputShipId BIGINT,
    IN inputDepartureDestinationId BIGINT
)
BEGIN
    DECLARE errorMessage VARCHAR(255);

    -- Check if the provided shipId exists and is active
    IF NOT EXISTS (
        SELECT 1 
        FROM Ship 
        WHERE id = inputShipId AND isActive = TRUE
    ) THEN
        SET errorMessage = 'Error: Ship ID does not exist or is inactive.';
    END IF;

    -- Check if the provided departureDestinationId exists and is active
    IF errorMessage IS NULL AND NOT EXISTS (
        SELECT 1 
        FROM DepartureDestination 
        WHERE id = inputDepartureDestinationId AND isActive = TRUE
    ) THEN
        SET errorMessage = 'Error: Departure Destination ID does not exist or is inactive.';
    END IF;

    -- Check if the combination already exists in the table
    IF errorMessage IS NULL AND EXISTS (
        SELECT 1 
        FROM ShipDepartureDestination 
        WHERE shipId = inputShipId 
        AND departureDestinationId = inputDepartureDestinationId
        AND isActive = TRUE
    ) THEN
        SET errorMessage = 'Error: This ship and departure destination combination already exists.';
    END IF;

    -- If there is no error, insert the new record
    IF errorMessage IS NULL THEN
        INSERT INTO ShipDepartureDestination (
            shipId, 
            departureDestinationId, 
            createdAt, 
            isActive
        )
        VALUES (
            inputShipId, 
            inputDepartureDestinationId, 
            CURRENT_TIMESTAMP, 
            TRUE
        );

        SET errorMessage = 'Success: Record added successfully.';
    END IF;

    -- Output the result message
    SELECT errorMessage AS ResultMessage;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE selectShipDepartureDestination(
    IN inputId BIGINT
)
BEGIN
    IF inputId IS NULL THEN
        -- Select all active records if no ID is provided
        SELECT * 
        FROM ShipDepartureDestination 
        WHERE isActive = TRUE;
    ELSE
        -- Select a specific record by ID if it exists
        IF EXISTS (
            SELECT 1 
            FROM ShipDepartureDestination 
            WHERE id = inputId AND isActive = TRUE
        ) THEN
            SELECT * 
            FROM ShipDepartureDestination 
            WHERE id = inputId;
        ELSE
            SELECT 'Error: No record found with the specified ID or the record is inactive.' AS ErrorMessage;
        END IF;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE deleteShipDepartureDestination(
    IN inputId BIGINT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM ShipDepartureDestination 
        WHERE id = inputId AND isActive = TRUE
    ) THEN
        SELECT 'Error: No active record found with the specified ID.' AS ErrorMessage;
    ELSE
        -- Mark the record as inactive
        UPDATE ShipDepartureDestination
        SET isActive = FALSE
        WHERE id = inputId;

        SELECT 'Success: Record deactivated successfully.' AS SuccessMessage;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE updateShipDepartureDestination(
    IN inputId BIGINT,
    IN newShipId BIGINT,
    IN newDepartureDestinationId BIGINT
)
BEGIN
    DECLARE errorMessage VARCHAR(255);

    -- Check if the record exists and is active
    IF NOT EXISTS (
        SELECT 1 
        FROM ShipDepartureDestination 
        WHERE id = inputId AND isActive = TRUE
    ) THEN
        SET errorMessage = 'Error: No active record found with the specified ID.';
    END IF;

    -- Check if the newShipId exists and is active
    IF errorMessage IS NULL AND NOT EXISTS (
        SELECT 1 
        FROM Ship 
        WHERE id = newShipId AND isActive = TRUE
    ) THEN
        SET errorMessage = 'Error: New Ship ID does not exist or is inactive.';
    END IF;

    -- Check if the newDepartureDestinationId exists and is active
    IF errorMessage IS NULL AND NOT EXISTS (
        SELECT 1 
        FROM DepartureDestination 
        WHERE id = newDepartureDestinationId AND isActive = TRUE
    ) THEN
        SET errorMessage = 'Error: New Departure Destination ID does not exist or is inactive.';
    END IF;

    -- Check if the combination already exists
    IF errorMessage IS NULL AND EXISTS (
        SELECT 1 
        FROM ShipDepartureDestination 
        WHERE shipId = newShipId 
        AND departureDestinationId = newDepartureDestinationId
        AND id != inputId
        AND isActive = TRUE
    ) THEN
        SET errorMessage = 'Error: This ship and departure destination combination already exists.';
    END IF;

    -- Perform the update if no errors
    IF errorMessage IS NULL THEN
        UPDATE ShipDepartureDestination
        SET shipId = newShipId, 
            departureDestinationId = newDepartureDestinationId, 
            createdAt = CURRENT_TIMESTAMP
        WHERE id = inputId;

        SET errorMessage = 'Success: Record updated successfully.';
    END IF;

    -- Output the result message
    SELECT errorMessage AS ResultMessage;
END$$

DELIMITER ;





