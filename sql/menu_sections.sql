-- Create menu_sections table
CREATE TABLE menu_sections (
    sectionName VARCHAR(100) PRIMARY KEY,
    displayOrder INT DEFAULT 0,
    icon VARCHAR(50) DEFAULT 'bi-speedometer2',
    isActive TINYINT(1) DEFAULT 1,
    createdBy VARCHAR(50),
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedBy VARCHAR(50),
    updatedDate DATETIME ON UPDATE CURRENT_TIMESTAMP
);

-- Create menu_section_translations table
CREATE TABLE menu_section_translations (
    translationID INT AUTO_INCREMENT PRIMARY KEY,
    sectionName VARCHAR(100),
    languageID VARCHAR(10),
    label VARCHAR(100),
    description VARCHAR(255),
    isActive TINYINT(1) DEFAULT 1,
    createdBy VARCHAR(50),
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedBy VARCHAR(50),
    updatedDate DATETIME ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sectionName) REFERENCES menu_sections(sectionName),
    FOREIGN KEY (languageID) REFERENCES languages(languageID),
    UNIQUE KEY unique_section_language (sectionName, languageID)
);

-- Insert default menu sections
INSERT INTO menu_sections (sectionName, displayOrder, icon, isActive) VALUES
('dashboard', 1, 'bi-speedometer2', 1),
('risk', 2, 'bi-shield-check', 1),
('compliance', 3, 'bi-check-circle', 1),
('incidents', 4, 'bi-exclamation-triangle', 1),
('audit', 5, 'bi-clipboard-check', 1),
('reports', 6, 'bi-file-earmark-text', 1),
('settings', 7, 'bi-gear', 1),
('system', 8, 'bi-person-gear', 1);

-- Insert English translations for menu sections
INSERT INTO menu_section_translations (sectionName, languageID, label, description) VALUES
('dashboard', 'en-US', 'Dashboard', 'Main dashboard with overview and statistics'),
('risk', 'en-US', 'Risk Management', 'Identify, assess, and manage risks'),
('compliance', 'en-US', 'Compliance', 'Track and manage compliance requirements'),
('incidents', 'en-US', 'Incidents', 'Report and manage incidents'),
('audit', 'en-US', 'Audit', 'Plan and conduct audits'),
('reports', 'en-US', 'Reports', 'Generate and view reports'),
('settings', 'en-US', 'Settings', 'Configure application settings'),
('system', 'en-US', 'Administration', 'Manage users, roles, and system settings');

-- Insert Turkish translations for menu sections
INSERT INTO menu_section_translations (sectionName, languageID, label, description) VALUES
('dashboard', 'tr-TR', 'Gösterge Paneli', 'Genel bakış ve istatistikler'),
('risk', 'tr-TR', 'Risk Yönetimi', 'Riskleri tanımlayın, değerlendirin ve yönetin'),
('compliance', 'tr-TR', 'Uyumluluk', 'Uyumluluk gereksinimlerini takip edin ve yönetin'),
('incidents', 'tr-TR', 'Olaylar', 'Olayları raporlayın ve yönetin'),
('audit', 'tr-TR', 'Denetim', 'Denetimleri planlayın ve gerçekleştirin'),
('reports', 'tr-TR', 'Raporlar', 'Raporlar oluşturun ve görüntüleyin'),
('settings', 'tr-TR', 'Ayarlar', 'Uygulama ayarlarını yapılandırın'),
('system', 'tr-TR', 'Yönetim', 'Kullanıcıları, rolleri ve sistem ayarlarını yönetin');

-- Insert Spanish translations for menu sections
INSERT INTO menu_section_translations (sectionName, languageID, label, description) VALUES
('dashboard', 'es-ES', 'Panel de Control', 'Panel principal con resumen y estadísticas'),
('risk', 'es-ES', 'Gestión de Riesgos', 'Identificar, evaluar y gestionar riesgos'),
('compliance', 'es-ES', 'Cumplimiento', 'Seguimiento y gestión de requisitos de cumplimiento'),
('incidents', 'es-ES', 'Incidentes', 'Reportar y gestionar incidentes'),
('audit', 'es-ES', 'Auditoría', 'Planificar y realizar auditorías'),
('reports', 'es-ES', 'Informes', 'Generar y ver informes'),
('settings', 'es-ES', 'Configuración', 'Configurar ajustes de la aplicación'),
('system', 'es-ES', 'Administración', 'Gestionar usuarios, roles y ajustes del sistema'); 