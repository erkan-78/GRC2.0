-- Create roles table
CREATE TABLE roles (
    roleID INT AUTO_INCREMENT PRIMARY KEY,
    roleName VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    isActive TINYINT(1) DEFAULT 1,
    isSystem TINYINT(1) DEFAULT 0,
    companyID INT NULL,
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_role_name (roleName, companyID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create role translations table
CREATE TABLE role_translations (
    roleID INT NOT NULL,
    languageID INT NOT NULL,
    description VARCHAR(255),
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (roleID, languageID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create permissions table
CREATE TABLE permissions (
    permissionID INT AUTO_INCREMENT PRIMARY KEY,
    permissionName VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    category VARCHAR(50) NOT NULL,
    isActive TINYINT(1) DEFAULT 1,
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create permission translations table
CREATE TABLE permission_translations (
    permissionID INT NOT NULL,
    languageID INT NOT NULL,
    description VARCHAR(255),
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (permissionID, languageID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create role_permissions table (junction table)
CREATE TABLE role_permissions (
    roleID INT NOT NULL,
    permissionID INT NOT NULL,
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (roleID, permissionID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create user_roles table (junction table for multiple roles per user)
CREATE TABLE user_roles (
    userID INT NOT NULL,
    roleID INT NOT NULL,
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (userID, roleID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert system roles (these are the base system roles)
INSERT INTO roles (roleName, description, isSystem) VALUES
('site.admin', 'System Administrator with access to system management tools', 1),
('company.admin', 'Company Administrator with access to company-specific information', 1),
('user', 'Regular user with basic access', 1);

-- Insert system management permissions
INSERT INTO permissions (permissionName, description, category) VALUES
-- System Management Permissions
('system.status.update', 'Update system status', 'system'),
('system.translations.manage', 'Manage system translations', 'system'),
('system.settings.manage', 'Manage system settings', 'system'),
('system.logs.view', 'View system logs', 'system'),
('system.backup.manage', 'Manage system backups', 'system'),
('system.security.manage', 'Manage system security settings', 'system'),
('system.roles.manage', 'Manage system and company roles', 'system'),

-- Company Management Permissions
('company.view', 'View company information', 'company'),
('company.edit', 'Edit company information', 'company'),
('company.users.manage', 'Manage company users', 'company'),
('company.settings.manage', 'Manage company settings', 'company'),
('company.reports.view', 'View company reports', 'company'),
('company.documents.manage', 'Manage company documents', 'company'),
('company.tasks.manage', 'Manage company tasks', 'company'),
('company.compliance.manage', 'Manage company compliance', 'company'),
('company.risks.manage', 'Manage company risks', 'company'),
('company.roles.manage', 'Manage company roles', 'company');

-- Assign permissions to site.admin role
INSERT INTO role_permissions (roleID, permissionID)
SELECT r.roleID, p.permissionID
FROM roles r
CROSS JOIN permissions p
WHERE r.roleName = 'site.admin'
AND p.category = 'system';

-- Assign permissions to company.admin role
INSERT INTO role_permissions (roleID, permissionID)
SELECT r.roleID, p.permissionID
FROM roles r
CROSS JOIN permissions p
WHERE r.roleName = 'company.admin'
AND p.category = 'company'; 