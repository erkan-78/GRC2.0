-- Create translations table if it doesn't exist
CREATE TABLE IF NOT EXISTS translations (
    translationID INT AUTO_INCREMENT PRIMARY KEY,
    languageid VARCHAR(5) NOT NULL,
    translationkey VARCHAR(100) NOT NULL,
    translationvalue TEXT NOT NULL,
    page VARCHAR(50) NOT NULL,
    UNIQUE KEY uk_translation_language (translationkey, languageid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert English translations for dashboard
INSERT INTO translations (languageid, translationkey, translationvalue, page) VALUES
-- Dashboard page title and header
('en-US', 'dashboard.title', 'Dashboard', 'dashboard'),
('en-US', 'dashboard.welcome', 'Welcome to LightGRC', 'dashboard'),
('en-US', 'dashboard.subtitle', 'Your Governance, Risk, and Compliance Dashboard', 'dashboard'),

-- Dashboard sections
('en-US', 'dashboard.overview', 'Overview', 'dashboard'),
('en-US', 'dashboard.tasks', 'Tasks', 'dashboard'),
('en-US', 'dashboard.documents', 'Documents', 'dashboard'),
('en-US', 'dashboard.compliance', 'Compliance', 'dashboard'),
('en-US', 'dashboard.risks', 'Risks', 'dashboard'),

-- Dashboard cards
('en-US', 'dashboard.pending_tasks', 'Pending Tasks', 'dashboard'),
('en-US', 'dashboard.overdue_tasks', 'Overdue Tasks', 'dashboard'),
('en-US', 'dashboard.completed_tasks', 'Completed Tasks', 'dashboard'),
('en-US', 'dashboard.total_tasks', 'Total Tasks', 'dashboard'),
('en-US', 'dashboard.recent_documents', 'Recent Documents', 'dashboard'),
('en-US', 'dashboard.compliance_status', 'Compliance Status', 'dashboard'),
('en-US', 'dashboard.risk_summary', 'Risk Summary', 'dashboard'),

-- Dashboard buttons and actions
('en-US', 'dashboard.view_all', 'View All', 'dashboard'),
('en-US', 'dashboard.add_new', 'Add New', 'dashboard'),
('en-US', 'dashboard.refresh', 'Refresh', 'dashboard'),
('en-US', 'dashboard.export', 'Export', 'dashboard'),
('en-US', 'dashboard.filter', 'Filter', 'dashboard'),

-- Dashboard table headers
('en-US', 'dashboard.task_name', 'Task Name', 'dashboard'),
('en-US', 'dashboard.due_date', 'Due Date', 'dashboard'),
('en-US', 'dashboard.status', 'Status', 'dashboard'),
('en-US', 'dashboard.assignee', 'Assignee', 'dashboard'),
('en-US', 'dashboard.priority', 'Priority', 'dashboard'),
('en-US', 'dashboard.actions', 'Actions', 'dashboard'),

-- Dashboard status labels
('en-US', 'dashboard.status_pending', 'Pending', 'dashboard'),
('en-US', 'dashboard.status_in_progress', 'In Progress', 'dashboard'),
('en-US', 'dashboard.status_completed', 'Completed', 'dashboard'),
('en-US', 'dashboard.status_overdue', 'Overdue', 'dashboard'),

-- Dashboard priority labels
('en-US', 'dashboard.priority_low', 'Low', 'dashboard'),
('en-US', 'dashboard.priority_medium', 'Medium', 'dashboard'),
('en-US', 'dashboard.priority_high', 'High', 'dashboard'),
('en-US', 'dashboard.priority_critical', 'Critical', 'dashboard'),

-- Dashboard messages
('en-US', 'dashboard.no_tasks', 'No tasks found', 'dashboard'),
('en-US', 'dashboard.no_documents', 'No documents found', 'dashboard'),
('en-US', 'dashboard.loading', 'Loading...', 'dashboard'),
('en-US', 'dashboard.error_loading', 'Error loading data', 'dashboard');

-- Insert Turkish translations for dashboard
INSERT INTO translations (languageid, translationkey, translationvalue, page) VALUES
-- Dashboard page title and header
('tr-TR', 'dashboard.title', 'Gösterge Paneli', 'dashboard'),
('tr-TR', 'dashboard.welcome', 'LightGRC''ye Hoş Geldiniz', 'dashboard'),
('tr-TR', 'dashboard.subtitle', 'Yönetişim, Risk ve Uyum Gösterge Paneliniz', 'dashboard'),

-- Dashboard sections
('tr-TR', 'dashboard.overview', 'Genel Bakış', 'dashboard'),
('tr-TR', 'dashboard.tasks', 'Görevler', 'dashboard'),
('tr-TR', 'dashboard.documents', 'Belgeler', 'dashboard'),
('tr-TR', 'dashboard.compliance', 'Uyum', 'dashboard'),
('tr-TR', 'dashboard.risks', 'Riskler', 'dashboard'),

-- Dashboard cards
('tr-TR', 'dashboard.pending_tasks', 'Bekleyen Görevler', 'dashboard'),
('tr-TR', 'dashboard.overdue_tasks', 'Gecikmiş Görevler', 'dashboard'),
('tr-TR', 'dashboard.completed_tasks', 'Tamamlanan Görevler', 'dashboard'),
('tr-TR', 'dashboard.total_tasks', 'Toplam Görevler', 'dashboard'),
('tr-TR', 'dashboard.recent_documents', 'Son Belgeler', 'dashboard'),
('tr-TR', 'dashboard.compliance_status', 'Uyum Durumu', 'dashboard'),
('tr-TR', 'dashboard.risk_summary', 'Risk Özeti', 'dashboard'),

-- Dashboard buttons and actions
('tr-TR', 'dashboard.view_all', 'Tümünü Görüntüle', 'dashboard'),
('tr-TR', 'dashboard.add_new', 'Yeni Ekle', 'dashboard'),
('tr-TR', 'dashboard.refresh', 'Yenile', 'dashboard'),
('tr-TR', 'dashboard.export', 'Dışa Aktar', 'dashboard'),
('tr-TR', 'dashboard.filter', 'Filtrele', 'dashboard'),

-- Dashboard table headers
('tr-TR', 'dashboard.task_name', 'Görev Adı', 'dashboard'),
('tr-TR', 'dashboard.due_date', 'Son Tarih', 'dashboard'),
('tr-TR', 'dashboard.status', 'Durum', 'dashboard'),
('tr-TR', 'dashboard.assignee', 'Atanan Kişi', 'dashboard'),
('tr-TR', 'dashboard.priority', 'Öncelik', 'dashboard'),
('tr-TR', 'dashboard.actions', 'İşlemler', 'dashboard'),

-- Dashboard status labels
('tr-TR', 'dashboard.status_pending', 'Beklemede', 'dashboard'),
('tr-TR', 'dashboard.status_in_progress', 'Devam Ediyor', 'dashboard'),
('tr-TR', 'dashboard.status_completed', 'Tamamlandı', 'dashboard'),
('tr-TR', 'dashboard.status_overdue', 'Gecikmiş', 'dashboard'),

-- Dashboard priority labels
('tr-TR', 'dashboard.priority_low', 'Düşük', 'dashboard'),
('tr-TR', 'dashboard.priority_medium', 'Orta', 'dashboard'),
('tr-TR', 'dashboard.priority_high', 'Yüksek', 'dashboard'),
('tr-TR', 'dashboard.priority_critical', 'Kritik', 'dashboard'),

-- Dashboard messages
('tr-TR', 'dashboard.no_tasks', 'Görev bulunamadı', 'dashboard'),
('tr-TR', 'dashboard.no_documents', 'Belge bulunamadı', 'dashboard'),
('tr-TR', 'dashboard.loading', 'Yükleniyor...', 'dashboard'),
('tr-TR', 'dashboard.error_loading', 'Veri yüklenirken hata oluştu', 'dashboard');

-- Insert Spanish translations for dashboard
INSERT INTO translations (languageid, translationkey, translationvalue, page) VALUES
-- Dashboard page title and header
('es-ES', 'dashboard.title', 'Panel de Control', 'dashboard'),
('es-ES', 'dashboard.welcome', 'Bienvenido a LightGRC', 'dashboard'),
('es-ES', 'dashboard.subtitle', 'Su Panel de Control de Gobernanza, Riesgos y Cumplimiento', 'dashboard'),

-- Dashboard sections
('es-ES', 'dashboard.overview', 'Resumen', 'dashboard'),
('es-ES', 'dashboard.tasks', 'Tareas', 'dashboard'),
('es-ES', 'dashboard.documents', 'Documentos', 'dashboard'),
('es-ES', 'dashboard.compliance', 'Cumplimiento', 'dashboard'),
('es-ES', 'dashboard.risks', 'Riesgos', 'dashboard'),

-- Dashboard cards
('es-ES', 'dashboard.pending_tasks', 'Tareas Pendientes', 'dashboard'),
('es-ES', 'dashboard.overdue_tasks', 'Tareas Vencidas', 'dashboard'),
('es-ES', 'dashboard.completed_tasks', 'Tareas Completadas', 'dashboard'),
('es-ES', 'dashboard.total_tasks', 'Total de Tareas', 'dashboard'),
('es-ES', 'dashboard.recent_documents', 'Documentos Recientes', 'dashboard'),
('es-ES', 'dashboard.compliance_status', 'Estado de Cumplimiento', 'dashboard'),
('es-ES', 'dashboard.risk_summary', 'Resumen de Riesgos', 'dashboard'),

-- Dashboard buttons and actions
('es-ES', 'dashboard.view_all', 'Ver Todo', 'dashboard'),
('es-ES', 'dashboard.add_new', 'Añadir Nuevo', 'dashboard'),
('es-ES', 'dashboard.refresh', 'Actualizar', 'dashboard'),
('es-ES', 'dashboard.export', 'Exportar', 'dashboard'),
('es-ES', 'dashboard.filter', 'Filtrar', 'dashboard'),

-- Dashboard table headers
('es-ES', 'dashboard.task_name', 'Nombre de la Tarea', 'dashboard'),
('es-ES', 'dashboard.due_date', 'Fecha de Vencimiento', 'dashboard'),
('es-ES', 'dashboard.status', 'Estado', 'dashboard'),
('es-ES', 'dashboard.assignee', 'Asignado a', 'dashboard'),
('es-ES', 'dashboard.priority', 'Prioridad', 'dashboard'),
('es-ES', 'dashboard.actions', 'Acciones', 'dashboard'),

-- Dashboard status labels
('es-ES', 'dashboard.status_pending', 'Pendiente', 'dashboard'),
('es-ES', 'dashboard.status_in_progress', 'En Progreso', 'dashboard'),
('es-ES', 'dashboard.status_completed', 'Completado', 'dashboard'),
('es-ES', 'dashboard.status_overdue', 'Vencido', 'dashboard'),

-- Dashboard priority labels
('es-ES', 'dashboard.priority_low', 'Baja', 'dashboard'),
('es-ES', 'dashboard.priority_medium', 'Media', 'dashboard'),
('es-ES', 'dashboard.priority_high', 'Alta', 'dashboard'),
('es-ES', 'dashboard.priority_critical', 'Crítica', 'dashboard'),

-- Dashboard messages
('es-ES', 'dashboard.no_tasks', 'No se encontraron tareas', 'dashboard'),
('es-ES', 'dashboard.no_documents', 'No se encontraron documentos', 'dashboard'),
('es-ES', 'dashboard.loading', 'Cargando...', 'dashboard'),
('es-ES', 'dashboard.error_loading', 'Error al cargar datos', 'dashboard'); 