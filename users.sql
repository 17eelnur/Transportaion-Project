drop procedure addOneUser;
use senja;


DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS addOneUser(
    IN inputUsername VARCHAR(50), 
    IN inputEmail VARCHAR(255), 
    IN inputPassword VARCHAR(255)
)
BEGIN
    DECLARE exitMessage VARCHAR(255);
    DECLARE errorOccurred BOOLEAN DEFAULT FALSE;
    DECLARE emailInvalid BOOLEAN DEFAULT FALSE;
    DECLARE newUserId BIGINT;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET errorOccurred = TRUE;

        IF (SELECT COUNT(*) FROM senja.`User` WHERE username = inputUsername) > 0 THEN
            SET exitMessage = 'Error: Username already exists.';
        ELSEIF (SELECT COUNT(*) FROM senja.`User` WHERE email = inputEmail) > 0 THEN
            SET exitMessage = 'Error: Email already exists.';
        ELSE
            SET exitMessage = 'Error: An unknown error occurred.';
        END IF;

        ROLLBACK;
    END;

    IF inputEmail NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' THEN
        SET emailInvalid = TRUE;
        SET exitMessage = 'Error: Invalid email format.';
    END IF;

    IF NOT emailInvalid THEN

        START TRANSACTION;

        INSERT INTO senja.`User` (username, email, password)
        VALUES (inputUsername, inputEmail, SHA2(inputPassword, 256));
       
        SET newUserId = LAST_INSERT_ID();

        INSERT INTO senja.`Role` (userId, role)
        VALUES (newUserId, 'user');

        COMMIT;
    END IF;

    IF emailInvalid THEN
        SELECT exitMessage AS ErrorMessage;
    ELSEIF errorOccurred THEN
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SELECT 'User added successfully!' AS SuccessMessage;
    END IF;
END$$

DELIMITER ;


CREATE PROCEDURE DeleteOneUser(
	IN inputUsername VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`User` 
        WHERE username = inputUsername
    ) THEN
        SELECT CONCAT('Error: User with username "', inputUsername, '" does not exist.') AS message;
    ELSE
        DELETE FROM senja.`User` WHERE username = inputUsername;
        SELECT CONCAT('Success: User with username "', inputUsername, '" has been deleted.') AS message;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS checkUsernameExists(
    IN inputUsername VARCHAR(50)
)
BEGIN
    DECLARE usernameExists BOOLEAN;

    SELECT COUNT(*) > 0 INTO usernameExists
    FROM senja.`User`
    WHERE username = inputUsername;

    IF usernameExists THEN
        SELECT 'Error: Username already exists.' AS ErrorMessage;
    ELSE
        SELECT 'Username is available.' AS SuccessMessage;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS checkEmailExists(
    IN inputEmail VARCHAR(255)
)
BEGIN
    DECLARE emailExists BOOLEAN;

    SELECT COUNT(*) > 0 INTO emailExists
    FROM senja.`User`
    WHERE email = inputEmail;

    IF emailExists THEN
        SELECT 'Error: Email already exists.' AS ErrorMessage;
    ELSE
        SELECT 'Email is available.' AS SuccessMessage;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS validateEmailFormat(
    IN inputEmail VARCHAR(255)
)
BEGIN
    DECLARE emailValid BOOLEAN;

    IF inputEmail NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' THEN
        SET emailValid = FALSE;
        SELECT 'Error: Invalid email format.' AS ErrorMessage;
    ELSE
        SET emailValid = TRUE;
        SELECT 'Email format is valid.' AS SuccessMessage;
    END IF;
END$$

DELIMITER ;
drop procedure selectAllUsers; 
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS selectAllUsers()
BEGIN
    SELECT username, email, phone, address FROM senja.`User`;
END $$
DELIMITER ;


CREATE procedure if not exists deleteAllUsers()
BEGIN
	delete from senja.`User`
	where id>0;
end$$

DELIMITER ;
DELIMITER $$

CREATE procedure if not exists selectOneUser (
IN inputUsername VARCHAR(50)
)
BEGIN
    SELECT * 
    FROM senja.User
    WHERE username = inputUsername;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS changePhone(
    IN inputUsername VARCHAR(50), 
    IN newPhone VARCHAR(50)
)
BEGIN
    DECLARE currentPhone VARCHAR(50);
    DECLARE phoneExists BOOLEAN DEFAULT FALSE;
    DECLARE userExists BOOLEAN DEFAULT FALSE;

    SELECT COUNT(*) > 0 INTO userExists
    FROM senja.`User`
    WHERE username = inputUsername;

    IF NOT userExists THEN
        SELECT 'Error: User not found.' AS ErrorMessage;
    ELSE
        SELECT phone INTO currentPhone
        FROM senja.`User`
        WHERE username = inputUsername;

        IF currentPhone = newPhone THEN
            SELECT 'No changes made. The new phone number is the same as the current one.' AS Message;
        ELSE
            SELECT COUNT(*) > 0 INTO phoneExists
            FROM senja.`User`
            WHERE phone = newPhone AND username != inputUsername;

            IF phoneExists THEN
                SELECT 'Error: The new phone number is already in use by another user.' AS ErrorMessage;
            ELSE
                UPDATE senja.`User`
                SET phone = newPhone
                WHERE username = inputUsername;

                SELECT 'Phone number updated successfully!' AS SuccessMessage;
            END IF;
        END IF;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS changeAddress(
    IN inputUsername VARCHAR(50), 
    IN newAddress VARCHAR(255)
)
BEGIN
    DECLARE userExists BOOLEAN DEFAULT FALSE;

    SELECT COUNT(*) > 0 INTO userExists
    FROM senja.`User`
    WHERE username = inputUsername;

    IF NOT userExists THEN
        SELECT 'Error: User not found.' AS ErrorMessage;
    ELSE
        UPDATE senja.`User`
        SET address = newAddress
        WHERE username = inputUsername;

        SELECT 'Address updated successfully!' AS SuccessMessage;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE if not exists ChangeUsername(
    IN inputUsername VARCHAR(50),
    IN newUsername VARCHAR(50)
)
begin
	
    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`User`
        WHERE username = inputUsername
    ) THEN

        SELECT CONCAT('Error: User with username "', inputUsername, '" does not exist.') AS message;

    ELSEIF EXISTS (
        SELECT 1 
        FROM senja.`User`
        WHERE username = newUsername
    ) THEN

        SELECT CONCAT('Error: Username "', newUsername, '" is already taken.') AS message;

    ELSE

        UPDATE senja.`User`
        SET username = newUsername
        WHERE username = inputUsername;

        SELECT CONCAT('Success: Username has been changed from "', inputUsername, '" to "', newUsername, '".') AS message;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS ChangeEmail(
    IN inputUsername VARCHAR(50),
    IN newEmail VARCHAR(255)
)
BEGIN

    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`User`
        WHERE username = inputUsername
    ) THEN

        SELECT CONCAT('Error: User with username "', inputUsername, '" does not exist.') AS message;

    ELSEIF EXISTS (
        SELECT 1 
        FROM senja.`User`
        WHERE email = newEmail
    ) THEN

        SELECT CONCAT('Error: Email "', newEmail, '" is already in use.') AS message;

    ELSE

        UPDATE senja.`User`
        SET email = newEmail
        WHERE username = inputUsername;

        SELECT CONCAT('Success: Email for username "', inputUsername, '" has been changed to "', newEmail, '".') AS message;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS ChangePassword(
    IN inputUsername VARCHAR(50),
    IN inputPassword VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`User`
        WHERE username = inputUsername
    ) THEN

        SELECT CONCAT('Error: User with username "', inputUsername, '" does not exist.') AS message;

    ELSE
        UPDATE senja.`User`
        SET password = SHA2(inputPassword, 256)
        WHERE username = inputUsername;

        SELECT CONCAT('Success: Password for username "', inputUsername, '" has been updated.') AS message;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS loginUser(
    IN inputUsername VARCHAR(50), 
    IN inputPassword VARCHAR(64)
)
BEGIN
    DECLARE userId BIGINT;
    DECLARE storedPassword VARCHAR(64);
    DECLARE exitMessage VARCHAR(255);

    SELECT id, password INTO userId, storedPassword
    FROM senja.`User`
    WHERE username = inputUsername
    LIMIT 1;

    IF userId IS NULL OR storedPassword != SHA2(inputPassword, 256) THEN
        SET exitMessage = 'Error: Invalid username or password.';
        SELECT exitMessage AS ErrorMessage;
    ELSE
        SET exitMessage = 'Login successful!';
        SELECT exitMessage AS SuccessMessage;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE if not exists CheckUserExists(
    IN inputUsername VARCHAR(50)
)
BEGIN
    DECLARE userCount INT;

    SELECT COUNT(*) INTO userCount
    FROM senja.`User`
    WHERE username = inputUsername;

    IF userCount = 0 THEN
        SELECT 'User does not exist' AS ErrorMessage;
    end if;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS ToggleIsActiveForUser(
    IN inputUsername VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`User`
        WHERE username = inputUsername
    ) THEN

        SELECT CONCAT('Error: User with username "', inputUsername, '" does not exist.') AS message;

    ELSE

        UPDATE senja.`User`
        SET isActive = NOT isActive
        WHERE username = inputUsername;

        SELECT CONCAT('Success: isActive status for username "', inputUsername, '" has been toggled.') AS message;
    END IF;
END$$

DELIMITER ;