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