create database if not exists Senja;

use Senja;

CREATE table if not exists `User` (
	id BIGINT auto_increment NOT NULL,
	username varchar(50) NOT NULL,
	email varchar(255) NOT NULL,
	password varchar(64) NOT NULL,
	phone varchar(50) NULL,
	address varchar(255) NULL,
	lastJoined DATETIME NULL,
	dateJoined DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
	isActive BOOL DEFAULT FALSE NULL,
	CONSTRAINT User_pk PRIMARY KEY (id),
	CONSTRAINT User_unique UNIQUE KEY (username),
	CONSTRAINT User_unique_1 UNIQUE KEY (email),
	CONSTRAINT User_unique_2 UNIQUE KEY (phone)
);


CREATE table if not exists `Role` (
    id BIGINT auto_increment NOT NULL,
    userId BIGINT NOT NULL,
    role ENUM('superadmin', 'admin', 'user') DEFAULT 'user',
    createAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT Role_pk PRIMARY KEY (id),
    CONSTRAINT Role_fk FOREIGN KEY (userId) REFERENCES `User`(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS `Permission` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    name VARCHAR(255) NOT NULL,
    codename VARCHAR(100) NOT NULL,
    contentType VARCHAR(100) NOT NULL,
    createAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT Permission_pk PRIMARY KEY (id),
    CONSTRAINT Permission_unique_codename_contentType UNIQUE (codename, contentType)
);


CREATE TABLE if not exists `RolePermission` (
    id BIGINT auto_increment NOT NULL,
    roleId BIGINT NOT NULL,
    permissionId BIGINT NOT NULL,
    createAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT Role_Permission_pk PRIMARY KEY (id),
    CONSTRAINT Role_Permission_fk_role FOREIGN KEY (roleId) REFERENCES `Role`(id) ON DELETE CASCADE,
    CONSTRAINT Role_Permission_fk_permission FOREIGN KEY (permissionId) REFERENCES `Permission`(id) ON DELETE CASCADE,
    CONSTRAINT Role_Permission_unique UNIQUE KEY (roleId, permissionId)
);


CREATE TABLE IF NOT EXISTS `Ship` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(100) NULL,
    country VARCHAR(100) NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT Product_pk PRIMARY KEY (id),
    CONSTRAINT Product_unique_name_country UNIQUE (name, country)
);


CREATE TABLE IF NOT EXISTS `Characteristics` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    speed FLOAT NOT NULL,
    weight FLOAT NOT NULL,
    max_weight FLOAT NOT NULL,
    length FLOAT NOT NULL,
    height FLOAT NOT NULL,
    motorType VARCHAR(100) NOT NULL,
    motorPower FLOAT NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT Characteristics_pk PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS `ShipCharacteristics` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    shipId BIGINT NOT NULL,
    characteristicsId BIGINT NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT ShipCharacteristics_pk PRIMARY KEY (id),
    CONSTRAINT ShipCharacteristics_fk_ship FOREIGN KEY (shipId) REFERENCES `Ship` (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ShipCharacteristics_fk_characteristics FOREIGN KEY (characteristicsId) REFERENCES `Characteristics` (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `Category` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    type VARCHAR(100) NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT Category_pk PRIMARY KEY (id),
    CONSTRAINT Category_unique_type UNIQUE (type)
);


CREATE TABLE IF NOT EXISTS `ShipCategory` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    shipId BIGINT NOT NULL,
    categoryId BIGINT NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT ShipCategory_pk PRIMARY KEY (id),
    CONSTRAINT ShipCategory_fk_ship FOREIGN KEY (shipId) REFERENCES `Ship` (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ShipCategory_fk_category FOREIGN KEY (categoryId) REFERENCES `Category` (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `DepartureDestination` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    `from` VARCHAR(255) NOT NULL,
    `to` VARCHAR(255) NOT NULL,
    departureTime DATETIME NOT NULL,
    arrivalTime DATETIME NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT DepartureDestination_pk PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS `ShipDepartureDestination` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    shipId BIGINT NOT NULL,
    departureDestinationId BIGINT NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NULL,
    isActive BOOL DEFAULT TRUE NULL,
    CONSTRAINT ShipDepartureDestination_pk PRIMARY KEY (id),
    CONSTRAINT ShipDepartureDestination_fk_ship FOREIGN KEY (shipId) REFERENCES `Ship` (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ShipDepartureDestination_fk_departureDestination FOREIGN KEY (departureDestinationId) REFERENCES `DepartureDestination` (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `ChangeLog` (
    id BIGINT AUTO_INCREMENT NOT NULL,
    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    table_name VARCHAR(255) NULL,
    record_id BIGINT NULL,
    old_data TEXT NULL,
    new_data TEXT NULL,
    user_id BIGINT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    isActive BOOL DEFAULT TRUE,
    CONSTRAINT ChangeLog_pk PRIMARY KEY (id),
    CONSTRAINT ChangeLog_fk_user FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE SET NULL
);







