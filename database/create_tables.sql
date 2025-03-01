-- Create companies table
CREATE TABLE companies (
    companyID VARCHAR(36) PRIMARY KEY DEFAULT UUID(),
    name VARCHAR(100) NOT NULL,
    taxNumber VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    website VARCHAR(255),
    logo VARCHAR(255),
    salt VARCHAR(32) NOT NULL,
    statusID VARCHAR(36) NOT NULL,
    ssoEnabled BIT DEFAULT 0,
    ssoProvider VARCHAR(50),
    ssoClientID VARCHAR(255),
    ssoClientSecret VARCHAR(255),
    ssoDomain VARCHAR(255),
    ssoMetadataURL VARCHAR(255),
    applicationDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approvalDate DATETIME,
    lastModifiedDate DATETIME,
    modifiedByUserID VARCHAR(36),
    FOREIGN KEY (statusID) REFERENCES company_statuses(statusID),
    FOREIGN KEY (modifiedByUserID) REFERENCES users(userID)
);

-- Create company statuses table
CREATE TABLE company_statuses (
    statusID VARCHAR(36) PRIMARY KEY DEFAULT UUID(),
    status VARCHAR(20) NOT NULL,
    statusName VARCHAR(50) NOT NULL,
    CONSTRAINT UQ_Status UNIQUE (status)
);

-- Create languages table
CREATE TABLE languages (
    languageID VARCHAR(5) PRIMARY KEY,
    languageName VARCHAR(50) NOT NULL,
    isActive BIT DEFAULT 1
);

-- Create translations table
CREATE TABLE translations (
    translationID INT PRIMARY KEY IDENTITY(1,1),
    languageID VARCHAR(5) NOT NULL,
    translationKey VARCHAR(100) NOT NULL,
    translationValue NVARCHAR(MAX) NOT NULL,
    CONSTRAINT FK_Translations_Languages FOREIGN KEY (languageID) REFERENCES languages(languageID)
);

-- Create menu items table
CREATE TABLE menuItems (
    menuItemID VARCHAR(36) PRIMARY KEY DEFAULT UUID(),
    parentMenuItemID VARCHAR(36),
    menuOrder INT NOT NULL,
    icon VARCHAR(50),
    route VARCHAR(255),
    translationKey VARCHAR(100) NOT NULL,
    isActive BIT DEFAULT 1,
    CONSTRAINT FK_MenuItems_Parent FOREIGN KEY (parentMenuItemID) REFERENCES menuItems(menuItemID)
);

-- Create profiles table
CREATE TABLE profiles (
    profileID VARCHAR(36) PRIMARY KEY DEFAULT UUID(),
    companyID VARCHAR(36) NOT NULL,
    profileName VARCHAR(100) NOT NULL,
    isActive BIT DEFAULT 1,
    CONSTRAINT FK_Profiles_Companies FOREIGN KEY (companyID) REFERENCES companies(companyID)
);

-- Create profile menu permissions table
CREATE TABLE profileMenuPermissions (
    profileID VARCHAR(36) NOT NULL,
    menuItemID VARCHAR(36) NOT NULL,
    CONSTRAINT PK_ProfileMenuPermissions PRIMARY KEY (profileID, menuItemID),
    CONSTRAINT FK_ProfileMenuPermissions_Profiles FOREIGN KEY (profileID) REFERENCES profiles(profileID),
    CONSTRAINT FK_ProfileMenuPermissions_MenuItems FOREIGN KEY (menuItemID) REFERENCES menuItems(menuItemID)
);

-- Create users table with company relationship
CREATE TABLE users (
    userID VARCHAR(36) PRIMARY KEY DEFAULT UUID(),
    companyID VARCHAR(36) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(512) NOT NULL,  -- Increased length for SHA-512 hash + salt
    passwordSalt VARCHAR(128) NOT NULL,  -- Unique salt per user
    firstName VARCHAR(50),
    lastName VARCHAR(50),
    preferredLanguage VARCHAR(5) DEFAULT 'en-US',
    isActive BIT DEFAULT 1,
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    lastLoginDate DATETIME,
    lastPasswordChange DATETIME,
    passwordResetToken VARCHAR(100),
    passwordResetExpiry DATETIME,
    role VARCHAR(20) DEFAULT 'user',
    CONSTRAINT FK_Users_Companies FOREIGN KEY (companyID) REFERENCES companies(companyID),
    CONSTRAINT FK_Users_Languages FOREIGN KEY (preferredLanguage) REFERENCES languages(languageID),
    CONSTRAINT UQ_Email UNIQUE (email)
);

-- Create user profile assignments table
CREATE TABLE userProfiles (
    userID VARCHAR(36) NOT NULL,
    profileID VARCHAR(36) NOT NULL,
    CONSTRAINT PK_UserProfiles PRIMARY KEY (userID, profileID),
    CONSTRAINT FK_UserProfiles_Users FOREIGN KEY (userID) REFERENCES users(userID),
    CONSTRAINT FK_UserProfiles_Profiles FOREIGN KEY (profileID) REFERENCES profiles(profileID)
);

-- Create activity logs table
CREATE TABLE activity_logs (
    logID INT PRIMARY KEY AUTO_INCREMENT,
    userID VARCHAR(36),
    companyID VARCHAR(36),
    activityType VARCHAR(50) NOT NULL,
    activityDescription TEXT NOT NULL,
    ipAddress VARCHAR(45),
    userAgent VARCHAR(255),
    activityDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    additionalData TEXT,
    FOREIGN KEY (userID) REFERENCES users(userID),
    FOREIGN KEY (companyID) REFERENCES companies(companyID)
);

-- Add indexes for better query performance
CREATE INDEX idx_activity_logs_user ON activity_logs(userID);
CREATE INDEX idx_activity_logs_company ON activity_logs(companyID);
CREATE INDEX idx_activity_logs_date ON activity_logs(activityDate);
CREATE INDEX idx_activity_logs_type ON activity_logs(activityType);

-- Insert default languages
INSERT INTO languages (languageID, languageName) VALUES
('en-US', 'English'),
('es-ES', 'Spanish'),
('tr-TR', 'Turkish');

-- Update other tables to reference the new UUID format
ALTER TABLE activity_logs 
    MODIFY userID VARCHAR(36),
    ADD CONSTRAINT FK_ActivityLogs_Users FOREIGN KEY (userID) REFERENCES users(userID);

ALTER TABLE companies 
    MODIFY modifiedByUserID VARCHAR(36),
    ADD CONSTRAINT FK_Companies_Users FOREIGN KEY (modifiedByUserID) REFERENCES users(userID);

ALTER TABLE userProfiles 
    MODIFY userID VARCHAR(36),
    ADD CONSTRAINT FK_UserProfiles_Users FOREIGN KEY (userID) REFERENCES users(userID);

-- Update activity_logs table foreign key
ALTER TABLE activity_logs
    MODIFY companyID VARCHAR(36),
    ADD CONSTRAINT FK_ActivityLogs_Companies FOREIGN KEY (companyID) REFERENCES companies(companyID);

-- Remove old check constraint as it's no longer needed for UUID
ALTER TABLE companies
DROP CONSTRAINT CHK_CompanyID; 