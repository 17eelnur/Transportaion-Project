use senja;

-- USER
call addOneUser('Ali', 'ali@gmail.com', 1234);
call DeleteOneUser('Ali2');
call checkUsernameExists('Ali');
call checkEmailExists('ali32@gmail.com');
call validateEmailFormat('ali2@gmail.com');
call selectAllUsers();
call deleteAllUsers();
call selectOneUser('Ali12');
call changePhone('Ali', '994556215689');
call changeAddress('Ali', 'Baku');
call ChangeUsername('Ali', 'Elnur');
call ChangeEmail('Elnur', 'elnur@gmail.com');
call ChangePassword('Elnur', '1234');
call loginUser('Elnur', '1234');
call CheckUserExists('Elnur');
call ToggleIsActiveForUser('Elnur');

-- ROLE
call AddUserRole('AlfaElnur', 'superadmin');
call SelectAllRoles();
call DeleteAllRoles();
call DeleteUserRole('Ali', 'superadmin');
call GetUserRoles('Ali');
call ToggleIsActiveForRole(18);

-- ROLEPERMISSION
select CheckUserPermission('Ali', 'Role', 'insert') as 'Permission';
call AddRolePermissionForUserRoles('Ali', 'Role', 'insert');
call DeleteRolePermissionForUserRoles('AlfaElnur', 'User', 'select');
call ShowUserPermissions('AlfaElnur');
call deleteAllRolePermissions();
call selectAllPermissions();
call ToggleIsActiveForPermission(1);

-- SHIP
call addShip('Niger', 'Black', 'Africa');
call deleteShip('Niger');
call updateShip( 4, 'Niger' , 'Black' , 'Africa');
CALL selectShip(NULL);
CALL selectShip(4);
-- CHARACTERISTICS


CALL addCharacteristic(50.5,9295.0,17554.0,5.5, 2.3,'Diuble',200.0);
call deleteCharacteristic(1)
CALL updateCharacteristic(2, 60.5, 1200.0, 1800.0,6.0,2.5,'Hybrid',250.0 );
call selectCharacteristic(Null);



select * from ship ;
select * from Characteristics;



