use senja;

drop function CheckUserPermission;

DELIMITER $$

CREATE FUNCTION CheckUserPermission(
    inputUsername VARCHAR(50), 
    inputCodename VARCHAR(100), 
    inputContentType VARCHAR(100)
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM senja.`User` u
        INNER JOIN senja.`Role` r ON u.id = r.userId AND r.isActive = TRUE
        INNER JOIN senja.`RolePermission` rp ON r.id = rp.roleId AND rp.isActive = TRUE
        INNER JOIN senja.`Permission` p ON rp.permissionId = p.id 
            AND p.codename = inputCodename
            AND p.contentType = inputContentType
            AND p.isActive = TRUE
        WHERE u.username = inputUsername
    );
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE if not exists AddRolePermissionForUserRoles(
    IN inputUsername VARCHAR(50), 
    IN inputCodename VARCHAR(100), 
    IN inputContentType VARCHAR(100)
)
BEGIN
    DECLARE permissionIdd BIGINT;
    DECLARE userRoleCount INT;

    SELECT id INTO permissionIdd
    FROM senja.`Permission`
    WHERE codename = inputCodename
      AND contentType = inputContentType
      AND isActive = TRUE
    LIMIT 1;

    IF permissionIdd IS NULL THEN
        SELECT 'Permission not found' AS Message;
    ELSE

        SELECT COUNT(*) INTO userRoleCount
        FROM senja.`User` u
        INNER JOIN senja.`Role` r ON u.id = r.userId
        WHERE u.username = inputUsername
          AND r.isActive = TRUE;

        IF userRoleCount = 0 THEN
            SELECT 'No roles found for the user or roles are inactive' AS Message;
        ELSE

            BEGIN
                DECLARE done INT DEFAULT 0;
                DECLARE roleIdd BIGINT;
                DECLARE curRoles CURSOR FOR 
                    SELECT r.id 
                    FROM senja.`User` u
                    INNER JOIN senja.`Role` r ON u.id = r.userId
                    WHERE u.username = inputUsername
                      AND r.isActive = TRUE;
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

                OPEN curRoles;

                readLoop: LOOP
                    FETCH curRoles INTO roleIdd;
                    IF done THEN
                        LEAVE readLoop;
                    END IF;

                    IF EXISTS (
                        SELECT 1
                        FROM senja.`RolePermission`
                        WHERE roleId = roleIdd AND permissionId = permissionIdd
                    ) THEN
                        SELECT CONCAT('RolePermission already exists for this user') AS Message;
                    ELSE

                        INSERT INTO senja.`RolePermission` (roleId, permissionId, createAt, isActive)
                        VALUES (roleIdd, permissionIdd, CURRENT_TIMESTAMP, TRUE);
                        SELECT CONCAT('RolePermission added successfully') AS Message;
                    END IF;
                END LOOP;

                CLOSE curRoles;
            END;
        END IF;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE if not exists DeleteRolePermissionForUserRoles(
    IN inputUsername VARCHAR(50),
    IN inputCodename VARCHAR(100),
    IN inputContentType VARCHAR(100)
)
BEGIN
    DECLARE permissionIdd BIGINT;
    DECLARE userRoleCount INT;

    SELECT id INTO permissionIdd
    FROM senja.`Permission`
    WHERE codename = inputCodename
      AND contentType = inputContentType
      AND isActive = TRUE
    LIMIT 1;

    IF permissionIdd IS NULL THEN
        SELECT 'Permission not found' AS Message;
    ELSE
        SELECT COUNT(*) INTO userRoleCount
        FROM senja.`User` u
        INNER JOIN senja.`Role` r ON u.id = r.userId
        WHERE u.username = inputUsername
          AND r.isActive = TRUE;

        IF userRoleCount = 0 THEN
            SELECT 'No roles found for the user or roles are inactive' AS Message;
        ELSE
            BEGIN
                DECLARE done INT DEFAULT 0;
                DECLARE roleIdd BIGINT;
                DECLARE curRoles CURSOR FOR 
                    SELECT r.id 
                    FROM senja.`User` u
                    INNER JOIN senja.`Role` r ON u.id = r.userId
                    WHERE u.username = inputUsername
                      AND r.isActive = TRUE;
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

                OPEN curRoles;

                readLoop: LOOP
                    FETCH curRoles INTO roleIdd;
                    IF done THEN
                        LEAVE readLoop;
                    END IF;

                    IF EXISTS (
                        SELECT 1
                        FROM senja.`RolePermission`
                        WHERE roleId = roleIdd AND permissionId = permissionIdd
                    ) THEN
                        -- Delete the RolePermission
                        DELETE FROM senja.`RolePermission`
                        WHERE roleId = roleIdd AND permissionId = permissionIdd;

                        SELECT CONCAT('RolePermission removed successfully') AS Message;
                    ELSE
                        SELECT CONCAT('RolePermission does not exist') AS Message;
                    END IF;
                END LOOP;

                CLOSE curRoles;
            END;
        END IF;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE ShowUserPermissions(
    IN inputUsername VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`User` 
        WHERE username = inputUsername
    ) THEN
        SELECT 'User not found' AS Message;
    ELSE
        SELECT p.name AS PermissionName, 
               p.codename AS Codename, 
               p.contentType AS ContentType
        FROM senja.`User` u
        INNER JOIN senja.`Role` r ON u.id = r.userId
        INNER JOIN senja.`RolePermission` rp ON r.id = rp.roleId
        INNER JOIN senja.`Permission` p ON rp.permissionId = p.id
        WHERE u.username = inputUsername
          AND r.isActive = TRUE
          AND rp.isActive = TRUE
          AND p.isActive = TRUE
        ORDER BY p.name;
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE if not exists selectAllRolePermissions()
begin
	select * from RolePermission;
end$$

DELIMITER ;
DELIMITER $$

CREATE procedure if not exists deleteAllRolePermissions()
BEGIN
    DELETE from RolePermission where id > 0;
end$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE if not exists selectAllPermissions()
begin
	select * from Permission;
end$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS ToggleIsActiveForPermission(
    IN inputPermissionId BIGINT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM senja.`Permission`
        WHERE id = inputPermissionId
    ) THEN
        SELECT CONCAT('Error: Permission with ID "', inputPermissionId, '" does not exist.') AS message;
    ELSE
        UPDATE senja.`Permission`
        SET isActive = NOT isActive
        WHERE id = inputPermissionId;
        SELECT CONCAT('Success: isActive status for permission ID "', inputPermissionId, '" has been toggled.') AS message;
    END IF;
END$$

DELIMITER ;