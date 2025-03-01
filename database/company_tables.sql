-- Company Status Types
CREATE TABLE companyStatus (
    statusID INT PRIMARY KEY AUTO_INCREMENT,
    statusName VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

INSERT INTO companyStatus (statusName, description) VALUES
('PENDING', 'Company application is pending approval'),
('APPROVED', 'Company is approved and active'),
('SUSPENDED', 'Company access is temporarily suspended'),
('REJECTED', 'Company application was rejected');

-- Companies Table
CREATE TABLE companies (
    companyID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    taxNumber VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    website VARCHAR(255),
    statusID INT NOT NULL,
    salt VARCHAR(64) NOT NULL,
    applicationDate DATETIME NOT NULL,
    approvalDate DATETIME,
    lastModifiedDate DATETIME,
    lastModifiedBy INT,
    FOREIGN KEY (statusID) REFERENCES companyStatus(statusID),
    FOREIGN KEY (lastModifiedBy) REFERENCES users(userID)
);

-- Company Administrators Table
CREATE TABLE companyAdministrators (
    companyID INT,
    userID INT,
    isActive BOOLEAN DEFAULT true,
    assignedDate DATETIME NOT NULL,
    assignedBy INT NOT NULL,
    FOREIGN KEY (companyID) REFERENCES companies(companyID),
    FOREIGN KEY (userID) REFERENCES users(userID),
    FOREIGN KEY (assignedBy) REFERENCES users(userID),
    PRIMARY KEY (companyID, userID)
);

-- Administrator Permissions Table
CREATE TABLE administratorPermissions (
    permissionID INT PRIMARY KEY AUTO_INCREMENT,
    permissionName VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

INSERT INTO administratorPermissions (permissionName, description) VALUES
('USER_MANAGEMENT', 'Can manage company users'),
('TRANSLATION_MANAGEMENT', 'Can manage company translations'),
('MENU_MANAGEMENT', 'Can manage company menu items'),
('FILE_MANAGEMENT', 'Can manage company files');

-- Company Administrator Permissions Table
CREATE TABLE companyAdminPermissions (
    companyID INT,
    userID INT,
    permissionID INT,
    grantedDate DATETIME NOT NULL,
    grantedBy INT NOT NULL,
    FOREIGN KEY (companyID, userID) REFERENCES companyAdministrators(companyID, userID),
    FOREIGN KEY (permissionID) REFERENCES administratorPermissions(permissionID),
    FOREIGN KEY (grantedBy) REFERENCES users(userID),
    PRIMARY KEY (companyID, userID, permissionID)
);

-- Add companyID to users table
ALTER TABLE users ADD COLUMN companyID INT;
ALTER TABLE users ADD FOREIGN KEY (companyID) REFERENCES companies(companyID);

-- Add isSuperAdmin to users table
ALTER TABLE users ADD COLUMN isSuperAdmin BOOLEAN DEFAULT false; 