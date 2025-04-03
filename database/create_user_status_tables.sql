-- Create user status types table
CREATE TABLE user_status_types (
    statusID VARCHAR(36) PRIMARY KEY DEFAULT UUID(),
    status VARCHAR(50) NOT NULL UNIQUE,
    isActive BIT DEFAULT 1,
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    modifiedDate DATETIME,
    modifiedByUserID VARCHAR(36),
    FOREIGN KEY (modifiedByUserID) REFERENCES users(userID)
);

-- Create user status labels table for multilingual support
CREATE TABLE user_status_labels (
    labelID VARCHAR(36) PRIMARY KEY DEFAULT UUID(),
    statusID VARCHAR(36) NOT NULL,
    languageID VARCHAR(5) NOT NULL,
    label VARCHAR(100) NOT NULL,
    description TEXT,
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    modifiedDate DATETIME,
    modifiedByUserID VARCHAR(36),
    FOREIGN KEY (statusID) REFERENCES user_status_types(statusID),
    FOREIGN KEY (languageID) REFERENCES languages(languageID),
    FOREIGN KEY (modifiedByUserID) REFERENCES users(userID),
    UNIQUE KEY unique_status_language (statusID, languageID)
);

-- Insert default user status types
INSERT INTO user_status_types (status) VALUES
('ACTIVE'),
('INACTIVE'),
('PENDING'),
('SUSPENDED'),
('DELETED');

-- Insert default labels for English
INSERT INTO user_status_labels (statusID, languageID, label, description)
SELECT 
    t.statusID,
    'en-US',
    CASE t.status
        WHEN 'ACTIVE' THEN 'Active'
        WHEN 'INACTIVE' THEN 'Inactive'
        WHEN 'PENDING' THEN 'Pending'
        WHEN 'SUSPENDED' THEN 'Suspended'
        WHEN 'DELETED' THEN 'Deleted'
    END,
    CASE t.status
        WHEN 'ACTIVE' THEN 'User account is active and can access the system'
        WHEN 'INACTIVE' THEN 'User account is inactive and cannot access the system'
        WHEN 'PENDING' THEN 'User account is pending activation'
        WHEN 'SUSPENDED' THEN 'User account is temporarily suspended'
        WHEN 'DELETED' THEN 'User account has been deleted'
    END
FROM user_status_types t;

-- Insert default labels for Spanish
INSERT INTO user_status_labels (statusID, languageID, label, description)
SELECT 
    t.statusID,
    'es-ES',
    CASE t.status
        WHEN 'ACTIVE' THEN 'Activo'
        WHEN 'INACTIVE' THEN 'Inactivo'
        WHEN 'PENDING' THEN 'Pendiente'
        WHEN 'SUSPENDED' THEN 'Suspendido'
        WHEN 'DELETED' THEN 'Eliminado'
    END,
    CASE t.status
        WHEN 'ACTIVE' THEN 'La cuenta de usuario está activa y puede acceder al sistema'
        WHEN 'INACTIVE' THEN 'La cuenta de usuario está inactiva y no puede acceder al sistema'
        WHEN 'PENDING' THEN 'La cuenta de usuario está pendiente de activación'
        WHEN 'SUSPENDED' THEN 'La cuenta de usuario está temporalmente suspendida'
        WHEN 'DELETED' THEN 'La cuenta de usuario ha sido eliminada'
    END
FROM user_status_types t;

-- Insert default labels for Turkish
INSERT INTO user_status_labels (statusID, languageID, label, description)
SELECT 
    t.statusID,
    'tr-TR',
    CASE t.status
        WHEN 'ACTIVE' THEN 'Aktif'
        WHEN 'INACTIVE' THEN 'Pasif'
        WHEN 'PENDING' THEN 'Beklemede'
        WHEN 'SUSPENDED' THEN 'Askıya Alındı'
        WHEN 'DELETED' THEN 'Silindi'
    END,
    CASE t.status
        WHEN 'ACTIVE' THEN 'Kullanıcı hesabı aktif ve sisteme erişebilir'
        WHEN 'INACTIVE' THEN 'Kullanıcı hesabı pasif ve sisteme erişemez'
        WHEN 'PENDING' THEN 'Kullanıcı hesabı aktivasyon bekliyor'
        WHEN 'SUSPENDED' THEN 'Kullanıcı hesabı geçici olarak askıya alındı'
        WHEN 'DELETED' THEN 'Kullanıcı hesabı silindi'
    END
FROM user_status_types t;

-- Add indexes for better performance
CREATE INDEX idx_user_status_labels_status ON user_status_labels(statusID);
CREATE INDEX idx_user_status_labels_language ON user_status_labels(languageID);
CREATE INDEX idx_user_status_types_status ON user_status_types(status); 