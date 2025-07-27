use senja;

drop procedure AddUserRole;

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS AddUserRole(
    IN inputUsername VARCHAR(50),
    IN newRole ENUM('superadmin', 'admin', 'user')
)
BEGIN
    DECLARE userIdd BIGINT;
    DECLARE roleIdd BIGINT;
    DECLARE roleExists BOOLEAN;

    SELECT id INTO userIdd
    FROM senja.`User`
    WHERE username = inputUsername;

    IF userIdd IS NOT NULL THEN

        SELECT COUNT(*)
        INTO roleExists
        FROM senja.`Role`
        WHERE userId = userIdd AND role = newRole;

        IF roleExists = 0 THEN

            INSERT INTO senja.`Role` (userId, role, createAt, isActive)
            VALUES (userIdd, newRole, NOW(), TRUE);

            SELECT id INTO roleIdd
            FROM senja.`Role`
            WHERE userId = userIdd AND role = newRole;

            IF newRole = 'superadmin' THEN
                INSERT IGNORE INTO senja.`RolePermission` (roleId, permissionId, createAt, isActive)
                SELECT roleIdd, id, NOW(), TRUE
                FROM senja.`Permission`
                WHERE isActive = TRUE;

                SELECT CONCAT('Role "', newRole, '" has been added to user "', inputUsername, 
                              '" and all permissions have been granted.') AS Message;
            ELSE
                SELECT CONCAT('Role "', newRole, '" has been added to user "', inputUsername, '".') AS Message;
            END IF;
        ELSE
            SELECT CONCAT('The user "', inputUsername, '" already has the role "', newRole, '".') AS Message;
        END IF;
    ELSE
        SELECT 'User not found' AS Message;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE procedure if not exists DeleteAllRoles()
BEGIN
    DELETE FROM Role where id > 0;
END$$

DELIMITER ;
DELIMITER $$

CREATE procedure if not exists SelectAllRoles()
BEGIN
    select * FROM Role;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE DeleteUserRole(
    IN inputUsername VARCHAR(50),
    IN roleToRemove ENUM('superadmin', 'admin', 'user')
)
BEGIN
    DECLARE userIdd BIGINT;
    DECLARE roleExists BOOLEAN;

    SELECT id INTO userIdd
    FROM senja.`User`
    WHERE username = inputUsername;

    IF userIdd IS NOT NULL THEN
        SELECT COUNT(*)
        INTO roleExists
        FROM senja.`Role`
        WHERE userId = userIdd AND role = roleToRemove;

        IF roleExists > 0 THEN
            DELETE FROM senja.`Role`
            WHERE userId = userIdd AND role = roleToRemove;

            SELECT CONCAT('Role "', roleToRemove, '" has been removed from user "', inputUsername, '".') AS Message;
        ELSE
            SELECT CONCAT('The user "', inputUsername, '" does not have the role "', roleToRemove, '".') AS Message;
        END IF;
    ELSE
        SELECT 'User not found' AS Message;
    END IF;
end$$

DELIMITER ;
DELIMITER $$

CREATE procedure if not exists GetUserRoles(
    IN inputUsername VARCHAR(50)
)
BEGIN
    DECLARE userIdd BIGINT;

    SELECT id INTO userIdd
    FROM senja.`User`
    WHERE username = inputUsername;

    IF userIdd IS NOT NULL THEN
        SELECT role
        FROM senja.`Role`
        WHERE userId = userIdd AND isActive = TRUE;
    ELSE
        SELECT 'User not found' AS Message;
    END IF;
end$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS ToggleIsActiveForRole(
    IN inputRoleId BIGINT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`Role`
        WHERE id = inputRoleId 
    ) THEN
        SELECT CONCAT('Error: Role with ID "', inputRoleId, '" does not exist.') AS message;
    ELSE
        UPDATE senja.`Role`
        SET isActive = NOT isActive
        WHERE id = inputRoleId;
        SELECT CONCAT('Success: isActive status for role ID "', inputRoleId, '" has been toggled.') AS message;
    END IF;
END$$

DELIMITER ;