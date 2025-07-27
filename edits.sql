use senja;

insert into Category (type) values 
('polis'),
('cargo'),
('travel'),
('personal');

insert into permission(name, codename, contentType) values 
('can view Users', 'User', 'select'),
('can add to Users', 'User', 'insert'),
('can change Users', 'User', 'update'),
('can delete Users', 'User', 'delete');

insert into permission(name, codename, contentType) values 
('can view Roles', 'Role', 'select'),
('can add to Roles', 'Role', 'insert'),
('can change Roles', 'Role', 'update'),
('can delete Roles', 'Role', 'delete');

select * from permission;

