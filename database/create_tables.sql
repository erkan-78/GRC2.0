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




-- Automation Scripts
CREATE TABLE automation_scripts (
    scriptID INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    scriptType VARCHAR(50) NOT NULL, -- python, powershell, sql, etc.
    scriptContent NVARCHAR(MAX),
    parameters NVARCHAR(MAX), -- JSON format for parameter definitions
    inputType VARCHAR(50), -- none, csv, json, etc.
    createdBy INT,
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedBy INT,
    modifiedDate DATETIME,
    isActive BIT DEFAULT 1
);

-- Script Executions
CREATE TABLE script_executions (
    executionID INT IDENTITY(1,1) PRIMARY KEY,
    scriptID INT FOREIGN KEY REFERENCES automation_scripts(scriptID),
    auditID INT FOREIGN KEY REFERENCES audits(auditID),
    controlID INT FOREIGN KEY REFERENCES controls(controlID),
    executedBy INT,
    executionDate DATETIME DEFAULT GETDATE(),
    status VARCHAR(50), -- pending, running, completed, failed
    resultText NVARCHAR(MAX),
    resultFile VARCHAR(500),
    inputFile VARCHAR(500),
    parameters NVARCHAR(MAX), -- JSON format for parameter values
    errorMessage NVARCHAR(MAX)
); 


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


-- Alert Messages
INSERT INTO translations (languageID, translationKey, translationValue) VALUES
-- Company Application
('en-US', 'alert.company.application.success', 'Your application has been submitted successfully. We will review it and contact you soon.'),
('es-ES', 'alert.company.application.success', 'Su solicitud ha sido enviada con éxito. La revisaremos y nos pondremos en contacto con usted pronto.'),
('tr-TR', 'alert.company.application.success', 'Başvurunuz başarıyla gönderildi. İnceleyip en kısa sürede size ulaşacağız.'),

('en-US', 'alert.company.application.error', 'An error occurred while submitting your application. Please try again.'),
('es-ES', 'alert.company.application.error', 'Se produjo un error al enviar su solicitud. Por favor, inténtelo de nuevo.'),
('tr-TR', 'alert.company.application.error', 'Başvurunuz gönderilirken bir hata oluştu. Lütfen tekrar deneyin.'),

-- Company Management
('en-US', 'alert.company.update.success', 'Company updated successfully.'),
('es-ES', 'alert.company.update.success', 'Empresa actualizada con éxito.'),
('tr-TR', 'alert.company.update.success', 'Şirket başarıyla güncellendi.'),

('en-US', 'alert.company.salt.confirm', 'Are you sure you want to regenerate the salt? This will require updating all encrypted data.'),
('es-ES', 'alert.company.salt.confirm', '¿Está seguro de que desea regenerar la sal? Esto requerirá actualizar todos los datos encriptados.'),
('tr-TR', 'alert.company.salt.confirm', 'Tuzu yeniden oluşturmak istediğinizden emin misiniz? Bu, tüm şifrelenmiş verilerin güncellenmesini gerektirecektir.'),

('en-US', 'alert.company.salt.success', 'Company salt has been updated successfully.'),
('es-ES', 'alert.company.salt.success', 'La sal de la empresa se ha actualizado con éxito.'),
('tr-TR', 'alert.company.salt.success', 'Şirket tuzu başarıyla güncellendi.'),

-- Administrator Management
('en-US', 'alert.admin.update.success', 'Administrator updated successfully.'),
('es-ES', 'alert.admin.update.success', 'Administrador actualizado con éxito.'),
('tr-TR', 'alert.admin.update.success', 'Yönetici başarıyla güncellendi.'),

-- Generic Error Messages
('en-US', 'alert.error.generic', 'An error occurred. Please try again.'),
('es-ES', 'alert.error.generic', 'Se produjo un error. Por favor, inténtelo de nuevo.'),
('tr-TR', 'alert.error.generic', 'Bir hata oluştu. Lütfen tekrar deneyin.'); 



-- Regulations table
CREATE TABLE regulations (
    regulationID INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    version DECIMAL(4,1) NOT NULL DEFAULT 1.0,
    createdBy INT NOT NULL,
    createdDate DATETIME NOT NULL,
    modifiedBy INT,
    modifiedDate DATETIME,
    approvalWorkflowID INT,
    FOREIGN KEY (createdBy) REFERENCES users(userID),
    FOREIGN KEY (modifiedBy) REFERENCES users(userID),
    FOREIGN KEY (approvalWorkflowID) REFERENCES approval_workflows(workflowID)
);

-- Regulation subitems table
CREATE TABLE regulation_subitems (
    subitemID INT IDENTITY(1,1) PRIMARY KEY,
    regulationID INT NOT NULL,
    parentID INT DEFAULT 0,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    level INT NOT NULL,
    orderIndex INT NOT NULL DEFAULT 0,
    FOREIGN KEY (regulationID) REFERENCES regulations(regulationID),
    FOREIGN KEY (parentID) REFERENCES regulation_subitems(subitemID)
);

-- Regulation documents table
CREATE TABLE regulation_documents (
    documentID INT IDENTITY(1,1) PRIMARY KEY,
    regulationID INT NOT NULL,
    fileName NVARCHAR(255) NOT NULL,
    filePath NVARCHAR(500) NOT NULL,
    fileSize BIGINT NOT NULL,
    fileType VARCHAR(100) NOT NULL,
    version DECIMAL(4,1) NOT NULL,
    uploadedBy INT NOT NULL,
    uploadDate DATETIME NOT NULL,
    FOREIGN KEY (regulationID) REFERENCES regulations(regulationID),
    FOREIGN KEY (uploadedBy) REFERENCES users(userID)
);

-- Regulation version history
CREATE TABLE regulation_versions (
    versionID INT IDENTITY(1,1) PRIMARY KEY,
    regulationID INT NOT NULL,
    version DECIMAL(4,1) NOT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    createdBy INT NOT NULL,
    createdDate DATETIME NOT NULL,
    FOREIGN KEY (regulationID) REFERENCES regulations(regulationID),
    FOREIGN KEY (createdBy) REFERENCES users(userID)
);

-- Regulation links table
CREATE TABLE regulation_links (
    linkID INT IDENTITY(1,1) PRIMARY KEY,
    sourceSubitemID INT NOT NULL,
    targetSubitemID INT NOT NULL,
    linkType VARCHAR(50) NOT NULL,
    createdDate DATETIME NOT NULL,
    FOREIGN KEY (sourceSubitemID) REFERENCES regulation_subitems(subitemID),
    FOREIGN KEY (targetSubitemID) REFERENCES regulation_subitems(subitemID)
);

-- Control regulation links table
CREATE TABLE control_regulation_links (
    linkID INT IDENTITY(1,1) PRIMARY KEY,
    controlID INT NOT NULL,
    subitemID INT NOT NULL,
    createdDate DATETIME NOT NULL,
    FOREIGN KEY (controlID) REFERENCES controls(controlID),
    FOREIGN KEY (subitemID) REFERENCES regulation_subitems(subitemID)
);

-- Policy regulation links table
CREATE TABLE policy_regulation_links (
    linkID INT IDENTITY(1,1) PRIMARY KEY,
    policyID INT NOT NULL,
    subitemID INT NOT NULL,
    createdDate DATETIME NOT NULL,
    FOREIGN KEY (policyID) REFERENCES policies(policyID),
    FOREIGN KEY (subitemID) REFERENCES regulation_subitems(subitemID)
);

-- Audit control documentation table
CREATE TABLE audit_control_documentation (
    documentationID INT IDENTITY(1,1) PRIMARY KEY,
    controlID INT NOT NULL,
    auditID INT NOT NULL,
    userID INT NOT NULL,
    documentType VARCHAR(50) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    createdDate DATETIME NOT NULL,
    modifiedBy INT,
    modifiedDate DATETIME,
    FOREIGN KEY (controlID) REFERENCES controls(controlID),
    FOREIGN KEY (auditID) REFERENCES audits(auditID),
    FOREIGN KEY (userID) REFERENCES users(userID),
    FOREIGN KEY (modifiedBy) REFERENCES users(userID)
);

-- Documentation attachments table
CREATE TABLE documentation_attachments (
    attachmentID INT IDENTITY(1,1) PRIMARY KEY,
    documentationID INT NOT NULL,
    fileName NVARCHAR(255) NOT NULL,
    filePath NVARCHAR(500) NOT NULL,
    fileSize BIGINT NOT NULL,
    fileType VARCHAR(100) NOT NULL,
    uploadedBy INT NOT NULL,
    uploadDate DATETIME NOT NULL,
    FOREIGN KEY (documentationID) REFERENCES audit_control_documentation(documentationID),
    FOREIGN KEY (uploadedBy) REFERENCES users(userID)
);

-- Create indexes for better performance
CREATE INDEX IX_regulations_status ON regulations(status);
CREATE INDEX IX_regulation_subitems_parent ON regulation_subitems(parentID);
CREATE INDEX IX_regulation_subitems_level ON regulation_subitems(level);
CREATE INDEX IX_audit_control_documentation_control ON audit_control_documentation(controlID);
CREATE INDEX IX_audit_control_documentation_audit ON audit_control_documentation(auditID);
CREATE INDEX IX_documentation_attachments_doc ON documentation_attachments(documentationID); 