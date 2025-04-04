-- Create permissions table if it doesn't exist
CREATE TABLE IF NOT EXISTS permissions (
    permissionID INT AUTO_INCREMENT PRIMARY KEY,
    permissionKey VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    route VARCHAR(100) NULL,
    isActive TINYINT(1) NOT NULL DEFAULT 1,
    createdBy INT NOT NULL,
    createdDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedBy INT NULL,
    updatedDate DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_permission_key (permissionKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create permissions translations table if it doesn't exist
CREATE TABLE IF NOT EXISTS permission_translations (
    translationID INT AUTO_INCREMENT PRIMARY KEY,
    permissionKey VARCHAR(100) NOT NULL,
    languageCode VARCHAR(5) NOT NULL,
    label VARCHAR(100) NOT NULL,
    description TEXT NULL,
    createdBy INT NOT NULL,
    createdDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedBy INT NULL,
    updatedDate DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (permissionKey) REFERENCES permissions(permissionKey) ON DELETE CASCADE,
    UNIQUE KEY uk_permission_language (permissionKey, languageCode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert permissions
INSERT INTO permissions (permissionKey, category, route, createdBy) VALUES
('system.status.update', 'system', 'system/status.cfm', 1),
('system.translations.manage', 'system', 'system/translations.cfm', 1),
('system.settings.manage', 'system', 'system/settings.cfm', 1),
('system.logs.view', 'system', 'system/logs.cfm', 1),
('system.backup.manage', 'system', 'system/backup.cfm', 1),
('system.security.manage', 'system', 'system/security.cfm', 1),
('system.roles.manage', 'system', 'system/roles.cfm', 1),
('company.view', 'company', 'company/info.cfm', 1),
('company.edit', 'company', 'company/info.cfm', 1),
('company.users.manage', 'company', 'company/users.cfm', 1),
('company.settings.manage', 'company', 'company/settings.cfm', 1),
('company.reports.view', 'company', 'company/reports.cfm', 1),
('company.documents.manage', 'company', 'documents/index.cfm', 1),
('company.tasks.manage', 'company', 'tasks/index.cfm', 1),
('company.compliance.manage', 'company', 'compliance/index.cfm', 1),
('company.risks.manage', 'company', 'risks/index.cfm', 1),
('company.roles.manage', 'company', 'company/roles.cfm', 1);

-- Insert English translations for permissions
INSERT INTO permission_translations (permissionKey, languageCode, label, description, createdBy) VALUES
('system.status.update', 'en-US', 'Update System Status', 'Update system status information', 1),
('system.translations.manage', 'en-US', 'Manage System Translations', 'Manage system language translations', 1),
('system.settings.manage', 'en-US', 'Manage System Settings', 'Manage system configuration settings', 1),
('system.logs.view', 'en-US', 'View System Logs', 'View system logs and audit trails', 1),
('system.backup.manage', 'en-US', 'Manage System Backups', 'Manage system backup and restore operations', 1),
('system.security.manage', 'en-US', 'Manage System Security', 'Manage system security settings and configurations', 1),
('system.roles.manage', 'en-US', 'Manage System and Company Roles', 'Manage roles for both system and company', 1),
('company.view', 'en-US', 'View Company Information', 'View company details and information', 1),
('company.edit', 'en-US', 'Edit Company Information', 'Edit company details and information', 1),
('company.users.manage', 'en-US', 'Manage Company Users', 'Manage company user accounts and permissions', 1),
('company.settings.manage', 'en-US', 'Manage Company Settings', 'Manage company configuration settings', 1),
('company.reports.view', 'en-US', 'View Company Reports', 'View company reports and analytics', 1),
('company.documents.manage', 'en-US', 'Manage Company Documents', 'Manage company document library', 1),
('company.tasks.manage', 'en-US', 'Manage Company Tasks', 'Manage company tasks and assignments', 1),
('company.compliance.manage', 'en-US', 'Manage Company Compliance', 'Manage company compliance requirements', 1),
('company.risks.manage', 'en-US', 'Manage Company Risks', 'Manage company risk assessment and mitigation', 1),
('company.roles.manage', 'en-US', 'Manage Company Roles', 'Manage company-specific roles and permissions', 1);

-- Insert Turkish translations for permissions
INSERT INTO permission_translations (permissionKey, languageCode, label, description, createdBy) VALUES
('system.status.update', 'tr-TR', 'Sistem Durumunu Güncelle', 'Sistem durum bilgilerini güncelle', 1),
('system.translations.manage', 'tr-TR', 'Sistem Çevirilerini Yönet', 'Sistem dil çevirilerini yönet', 1),
('system.settings.manage', 'tr-TR', 'Sistem Ayarlarını Yönet', 'Sistem yapılandırma ayarlarını yönet', 1),
('system.logs.view', 'tr-TR', 'Sistem Günlüklerini Görüntüle', 'Sistem günlüklerini ve denetim izlerini görüntüle', 1),
('system.backup.manage', 'tr-TR', 'Sistem Yedeklemelerini Yönet', 'Sistem yedekleme ve geri yükleme işlemlerini yönet', 1),
('system.security.manage', 'tr-TR', 'Sistem Güvenliğini Yönet', 'Sistem güvenlik ayarlarını ve yapılandırmalarını yönet', 1),
('system.roles.manage', 'tr-TR', 'Sistem ve Şirket Rollerini Yönet', 'Sistem ve şirket için rolleri yönet', 1),
('company.view', 'tr-TR', 'Şirket Bilgilerini Görüntüle', 'Şirket detaylarını ve bilgilerini görüntüle', 1),
('company.edit', 'tr-TR', 'Şirket Bilgilerini Düzenle', 'Şirket detaylarını ve bilgilerini düzenle', 1),
('company.users.manage', 'tr-TR', 'Şirket Kullanıcılarını Yönet', 'Şirket kullanıcı hesaplarını ve izinlerini yönet', 1),
('company.settings.manage', 'tr-TR', 'Şirket Ayarlarını Yönet', 'Şirket yapılandırma ayarlarını yönet', 1),
('company.reports.view', 'tr-TR', 'Şirket Raporlarını Görüntüle', 'Şirket raporlarını ve analizlerini görüntüle', 1),
('company.documents.manage', 'tr-TR', 'Şirket Belgelerini Yönet', 'Şirket belge kütüphanesini yönet', 1),
('company.tasks.manage', 'tr-TR', 'Şirket Görevlerini Yönet', 'Şirket görevlerini ve atamalarını yönet', 1),
('company.compliance.manage', 'tr-TR', 'Şirket Uyumluluğunu Yönet', 'Şirket uyumluluk gereksinimlerini yönet', 1),
('company.risks.manage', 'tr-TR', 'Şirket Risklerini Yönet', 'Şirket risk değerlendirmesini ve azaltma stratejilerini yönet', 1),
('company.roles.manage', 'tr-TR', 'Şirket Rollerini Yönet', 'Şirkete özgü rolleri ve izinleri yönet', 1);

-- Insert Spanish translations for permissions
INSERT INTO permission_translations (permissionKey, languageCode, label, description, createdBy) VALUES
('system.status.update', 'es-ES', 'Actualizar Estado del Sistema', 'Actualizar información del estado del Sistema', 1),
('system.translations.manage', 'es-ES', 'Gestionar Traducciones del Sistema', 'Gestionar traducciones de idiomas del Sistema', 1),
('system.settings.manage', 'es-ES', 'Gestionar Configuración del Sistema', 'Gestionar configuración del Sistema', 1),
('system.logs.view', 'es-ES', 'Ver Registros del Sistema', 'Ver registros y pistas de auditoría del Sistema', 1),
('system.backup.manage', 'es-ES', 'Gestionar Copias de Seguridad', 'Gestionar operaciones de copia de seguridad y restauración del Sistema', 1),
('system.security.manage', 'es-ES', 'Gestionar Seguridad del Sistema', 'Gestionar configuración y seguridad del Sistema', 1),
('system.roles.manage', 'es-ES', 'Gestionar Roles del Sistema y Empresa', 'Gestionar roles para el Sistema y la Empresa', 1),
('company.view', 'es-ES', 'Ver Información de la Empresa', 'Ver detalles e información de la Empresa', 1),
('company.edit', 'es-ES', 'Editar Información de la Empresa', 'Editar detalles e información de la Empresa', 1),
('company.users.manage', 'es-ES', 'Gestionar Usuarios de la Empresa', 'Gestionar cuentas y permisos de usuarios de la Empresa', 1),
('company.settings.manage', 'es-ES', 'Gestionar Configuración de la Empresa', 'Gestionar configuración de la Empresa', 1),
('company.reports.view', 'es-ES', 'Ver Informes de la Empresa', 'Ver informes y análisis de la Empresa', 1),
('company.documents.manage', 'es-ES', 'Gestionar Documentos de la Empresa', 'Gestionar biblioteca de documentos de la Empresa', 1),
('company.tasks.manage', 'es-ES', 'Gestionar Tareas de la Empresa', 'Gestionar tareas y asignaciones de la Empresa', 1),
('company.compliance.manage', 'es-ES', 'Gestionar Cumplimiento de la Empresa', 'Gestionar requisitos de cumplimiento de la Empresa', 1),
('company.risks.manage', 'es-ES', 'Gestionar Riesgos de la Empresa', 'Gestionar evaluación y mitigación de riesgos de la Empresa', 1),
('company.roles.manage', 'es-ES', 'Gestionar Roles de la Empresa', 'Gestionar roles y permisos específicos de la Empresa', 1); 