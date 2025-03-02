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