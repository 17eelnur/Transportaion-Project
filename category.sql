DELIMITER $$

CREATE PROCEDURE selectCategory(
    IN inputId BIGINT
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Check if inputId is NULL
    IF inputId IS NULL THEN
        -- Fetch all records
        SELECT * 
        FROM Category;
    ELSE
        -- Check if the record exists in the Category table
        IF EXISTS (SELECT 1 FROM Category WHERE id = inputId) THEN
            -- Fetch the specific record
            SELECT * 
            FROM Category 
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

CREATE PROCEDURE addCategory(
    IN inputType VARCHAR(100),
    IN inputIsActive BOOL
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Check if the inputType already exists
    IF EXISTS (SELECT 1 FROM Category WHERE type = inputType) THEN
        SET message = 'Error: The specified category type already exists.';
    ELSE
        -- Insert the new category
        INSERT INTO Category (type, isActive)
        VALUES (inputType, inputIsActive);

        -- Set success message
        SET message = 'Success: New category has been added.';
    END IF;

    -- Return the final message
    SELECT message AS Message;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE deleteCategory(
    IN inputId BIGINT
)
BEGIN
    DECLARE message VARCHAR(255);

    -- Check if the record exists in the Category table
    IF NOT EXISTS (SELECT 1 FROM Category WHERE id = inputId) THEN
        SET message = 'Error: No record found with the specified ID.';
    ELSE
        -- Delete the record
        DELETE FROM Category WHERE id = inputId;

        -- Set success message
        SET message = 'Success: Category record has been deleted.';
    END IF;

    -- Return the final message
    SELECT message AS Message;
END$$

DELIMITER ;



