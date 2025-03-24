-- User Management and Authentication
CREATE TABLE users (
    userID INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    firstName NVARCHAR(100),
    lastName NVARCHAR(100),
    title NVARCHAR(100),
    phone NVARCHAR(50),
    isActive BIT DEFAULT 1,
    lastLoginDate DATETIME,
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedDate DATETIME,
    preferredLanguage NVARCHAR(5) DEFAULT 'en'
);

CREATE TABLE roles (
    roleID bigint AUTO_INCREMENT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    isActive BIT DEFAULT b'1',
    createdDate DATETIME DEFAULT current_timestamp(),
    modifiedDate DATETIME,
    PRIMARY KEY (`roleID`)
);

CREATE TABLE user_roles (
    userID INT,
    roleID INT,
    assignedDate DATETIME DEFAULT current_timestamp(),
    CONSTRAINT PK_user_roles PRIMARY KEY (userID, roleID),
    CONSTRAINT FK_user_roles_user FOREIGN KEY (userID) REFERENCES users(userID),
    CONSTRAINT FK_user_roles_role FOREIGN KEY (roleID) REFERENCES roles(roleID)
);

CREATE TABLE permissions (
    permissionID INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500),
    module NVARCHAR(100),
    createdDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE role_permissions (
    roleID INT,
    permissionID INT,
    CONSTRAINT PK_role_permissions PRIMARY KEY (roleID, permissionID),
    CONSTRAINT FK_role_permissions_role FOREIGN KEY (roleID) REFERENCES roles(roleID),
    CONSTRAINT FK_role_permissions_permission FOREIGN KEY (permissionID) REFERENCES permissions(permissionID)
);

-- Company and Organization
CREATE TABLE companies (
    companyID INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    industry NVARCHAR(100),
    size NVARCHAR(50),
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedDate DATETIME,
    isActive BIT DEFAULT 1
);

CREATE TABLE departments (
    departmentID INT IDENTITY(1,1) PRIMARY KEY,
    companyID INT,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(500),
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedDate DATETIME,
    CONSTRAINT FK_departments_company FOREIGN KEY (companyID) REFERENCES companies(companyID)
);

-- Language and Localization
CREATE TABLE languages (
    languageID NVARCHAR(5) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL,
    nativeName NVARCHAR(50) NOT NULL,
    isActive BIT DEFAULT 1,
    isDefault BIT DEFAULT 0,
    dateFormat NVARCHAR(50),
    timeFormat NVARCHAR(50),
    numberFormat NVARCHAR(50),
    currencyFormat NVARCHAR(50)
);

CREATE TABLE language_labels (
    labelID INT IDENTITY(1,1) PRIMARY KEY,
    moduleID NVARCHAR(50) NOT NULL,
    labelKey NVARCHAR(200) NOT NULL,
    context NVARCHAR(50) NOT NULL,
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedDate DATETIME,
    CONSTRAINT UQ_module_label UNIQUE (moduleID, labelKey)
);

CREATE TABLE label_translations (
    translationID INT IDENTITY(1,1) PRIMARY KEY,
    labelID INT,
    languageID NVARCHAR(5),
    translation NVARCHAR(MAX) NOT NULL,
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedDate DATETIME,
    CONSTRAINT FK_translations_label FOREIGN KEY (labelID) REFERENCES language_labels(labelID),
    CONSTRAINT FK_translations_language FOREIGN KEY (languageID) REFERENCES languages(languageID),
    CONSTRAINT UQ_label_language UNIQUE (labelID, languageID)
);

-- Audit Documentation and Evidence
CREATE TABLE audit_evidence (
    evidenceID INT IDENTITY(1,1) PRIMARY KEY,
    auditID INT,
    controlID INT,
    type NVARCHAR(50),
    description NVARCHAR(MAX),
    createdBy INT,
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedDate DATETIME,
    CONSTRAINT FK_evidence_audit FOREIGN KEY (auditID) REFERENCES audits(auditID),
    CONSTRAINT FK_evidence_control FOREIGN KEY (controlID) REFERENCES controls(controlID),
    CONSTRAINT FK_evidence_user FOREIGN KEY (createdBy) REFERENCES users(userID)
);

CREATE TABLE evidence_attachments (
    attachmentID INT IDENTITY(1,1) PRIMARY KEY,
    evidenceID INT,
    fileName NVARCHAR(255),
    fileType NVARCHAR(100),
    filePath NVARCHAR(500),
    fileSize INT,
    uploadedBy INT,
    uploadDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_attachments_evidence FOREIGN KEY (evidenceID) REFERENCES audit_evidence(evidenceID),
    CONSTRAINT FK_attachments_user FOREIGN KEY (uploadedBy) REFERENCES users(userID)
);

-- Automation Scripts and Execution
CREATE TABLE automation_scripts (
    scriptID INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    scriptType NVARCHAR(50) NOT NULL,
    scriptContent NVARCHAR(MAX),
    parameters NVARCHAR(MAX),
    inputType NVARCHAR(50),
    createdBy INT,
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedBy INT,
    modifiedDate DATETIME,
    isActive BIT DEFAULT 1,
    CONSTRAINT FK_scripts_creator FOREIGN KEY (createdBy) REFERENCES users(userID),
    CONSTRAINT FK_scripts_modifier FOREIGN KEY (modifiedBy) REFERENCES users(userID)
);

CREATE TABLE script_executions (
    executionID INT IDENTITY(1,1) PRIMARY KEY,
    scriptID INT,
    auditID INT,
    controlID INT,
    executedBy INT,
    executionDate DATETIME DEFAULT GETDATE(),
    status NVARCHAR(50),
    resultText NVARCHAR(MAX),
    resultFile NVARCHAR(500),
    inputFile NVARCHAR(500),
    parameters NVARCHAR(MAX),
    errorMessage NVARCHAR(MAX),
    CONSTRAINT FK_executions_script FOREIGN KEY (scriptID) REFERENCES automation_scripts(scriptID),
    CONSTRAINT FK_executions_audit FOREIGN KEY (auditID) REFERENCES audits(auditID),
    CONSTRAINT FK_executions_control FOREIGN KEY (controlID) REFERENCES controls(controlID),
    CONSTRAINT FK_executions_user FOREIGN KEY (executedBy) REFERENCES users(userID)
);

-- Regulations and Requirements
CREATE TABLE regulations (
    regulationID INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    version NVARCHAR(50),
    status NVARCHAR(50),
    createdBy INT,
    createdDate DATETIME DEFAULT GETDATE(),
    modifiedBy INT,
    modifiedDate DATETIME,
    CONSTRAINT FK_regulations_creator FOREIGN KEY (createdBy) REFERENCES users(userID),
    CONSTRAINT FK_regulations_modifier FOREIGN KEY (modifiedBy) REFERENCES users(userID)
);

CREATE TABLE regulation_items (
    itemID INT IDENTITY(1,1) PRIMARY KEY,
    regulationID INT,
    parentItemID INT,
    level INT,
    title NVARCHAR(500),
    description NVARCHAR(MAX),
    orderNumber INT,
    CONSTRAINT FK_items_regulation FOREIGN KEY (regulationID) REFERENCES regulations(regulationID),
    CONSTRAINT FK_items_parent FOREIGN KEY (parentItemID) REFERENCES regulation_items(itemID)
);

CREATE TABLE regulation_documents (
    documentID INT IDENTITY(1,1) PRIMARY KEY,
    regulationID INT,
    fileName NVARCHAR(255),
    fileType NVARCHAR(100),
    filePath NVARCHAR(500),
    version NVARCHAR(50),
    uploadedBy INT,
    uploadDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_documents_regulation FOREIGN KEY (regulationID) REFERENCES regulations(regulationID),
    CONSTRAINT FK_documents_user FOREIGN KEY (uploadedBy) REFERENCES users(userID)
);

-- Create Indexes
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_status ON users(isActive);
CREATE INDEX idx_role_name ON roles(name);
CREATE INDEX idx_permission_code ON permissions(code);
CREATE INDEX idx_company_name ON companies(name);
CREATE INDEX idx_department_company ON departments(companyID);
CREATE INDEX idx_label_module ON language_labels(moduleID);
CREATE INDEX idx_evidence_audit ON audit_evidence(auditID);
CREATE INDEX idx_evidence_control ON audit_evidence(controlID);
CREATE INDEX idx_script_type ON automation_scripts(scriptType);
CREATE INDEX idx_execution_status ON script_executions(status);
CREATE INDEX idx_regulation_status ON regulations(status);
CREATE INDEX idx_regulation_item_parent ON regulation_items(parentItemID);
CREATE INDEX idx_regulation_item_level ON regulation_items(level);

-- Add Foreign Key Indexes
CREATE INDEX idx_user_roles_user ON user_roles(userID);
CREATE INDEX idx_user_roles_role ON user_roles(roleID);
CREATE INDEX idx_role_permissions_role ON role_permissions(roleID);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permissionID);
CREATE INDEX idx_label_translations_label ON label_translations(labelID);
CREATE INDEX idx_label_translations_language ON label_translations(languageID);
CREATE INDEX idx_evidence_attachments_evidence ON evidence_attachments(evidenceID);
CREATE INDEX idx_script_executions_script ON script_executions(scriptID);
CREATE INDEX idx_regulation_documents_regulation ON regulation_documents(regulationID); 