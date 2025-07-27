DELIMITER $$

CREATE PROCEDURE selectShipCategory(
    IN inputId BIGINT
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Check if inputId is NULL
    IF inputId IS NULL THEN
        -- Fetch all records from ShipCategory table
        SELECT * 
        FROM ShipCategory;
    ELSE
        -- Check if the record exists in the ShipCategory table
        IF EXISTS (SELECT 1 FROM ShipCategory WHERE id = inputId) THEN
            -- Fetch the specific record
            SELECT * 
            FROM ShipCategory 
            WHERE id = inputId;
        ELSE
            -- Set an error message if no record is found
            SET message = 'Error: No record found with the specified ID.';
            SELECT message AS ErrorMessage;
        END IF;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE addShipCategory(
    IN inputShipId BIGINT,
    IN inputCategoryId BIGINT,
    IN inputIsActive BOOL
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Check if the shipId exists in the Ship table
    IF NOT EXISTS (SELECT 1 FROM Ship WHERE id = inputShipId) THEN
        SET message = 'Error: The specified Ship ID does not exist.';
    -- Check if the categoryId exists in the Category table
    ELSEIF NOT EXISTS (SELECT 1 FROM Category WHERE id = inputCategoryId) THEN
        SET message = 'Error: The specified Category ID does not exist.';
    -- Check if the combination of shipId and categoryId already exists in ShipCategory
    ELSEIF EXISTS (
        SELECT 1 
        FROM ShipCategory 
        WHERE shipId = inputShipId AND categoryId = inputCategoryId
    ) THEN
        SET message = 'Error: The specified combination of Ship ID and Category ID already exists.';
    ELSE
        -- Insert the new record into ShipCategory
        INSERT INTO ShipCategory (shipId, categoryId, isActive)
        VALUES (inputShipId, inputCategoryId, inputIsActive);

        -- Set success message
        SET message = 'Success: New ShipCategory record has been added.';
    END IF;

    -- Return the final message
    SELECT message AS Message;
END$$

DELIMITER ;

