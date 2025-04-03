-- Start transaction
START TRANSACTION;

-- Delete existing translations for login page to avoid duplicates
DELETE FROM translations 
WHERE translationKey LIKE 'login.%' 
AND languageID IN ('en-US', 'es-ES', 'tr-TR');

-- Insert login page translations for English
INSERT INTO translations (translationKey, languageID, translationValue) VALUES
-- Login Form Elements
('login.title', 'en-US', 'Welcome Back'),
('login.accessGRCWorkspace', 'en-US', 'Access your GRC workspace'),
('login.email', 'en-US', 'Email'),
('login.password', 'en-US', 'Password'),
('login.rememberMe', 'en-US', 'Remember me'),
('login.submit', 'en-US', 'Sign In'),
('login.forgotPassword', 'en-US', 'Forgot your password?'),
('login.error', 'en-US', 'Invalid email or password'),
('login.register', 'en-US', 'Register Your Company'),
('login.newToGRC', 'en-US', 'New to LightGRC?'),

-- Marketing Content
('login.marketing.title', 'en-US', 'Illuminate Your GRC Journey'),
('login.marketing.subtitle', 'en-US', 'LightGRC brings clarity and efficiency to governance, risk, and compliance with AI-powered insights and automation'),
('login.marketing.features.insights.title', 'en-US', 'Intelligent Insights'),
('login.marketing.features.insights.desc', 'en-US', 'AI-driven risk analysis and predictive controls'),
('login.marketing.features.compliance.title', 'en-US', 'Swift Compliance'),
('login.marketing.features.compliance.desc', 'en-US', 'Automated assessments and real-time monitoring'),
('login.marketing.features.security.title', 'en-US', 'Enhanced Security'),
('login.marketing.features.security.desc', 'en-US', 'Built-in controls and security frameworks'),
('login.marketing.features.visibility.title', 'en-US', 'Clear Visibility'),
('login.marketing.features.visibility.desc', 'en-US', 'Comprehensive dashboards and reporting'),

-- Statistics Labels
('login.marketing.stats.uptime', 'en-US', 'Uptime'),
('login.marketing.stats.clients', 'en-US', 'Enterprise Clients'),
('login.marketing.stats.support', 'en-US', 'Support'),
('login.marketing.stats.uptime.value', 'en-US', '99.9%'),
('login.marketing.stats.clients.value', 'en-US', '500+'),
('login.marketing.stats.support.value', 'en-US', '24/7'),

-- Feature Icons
('login.marketing.features.insights.icon', 'en-US', 'Lightbulb'),
('login.marketing.features.compliance.icon', 'en-US', 'Bolt'),
('login.marketing.features.security.icon', 'en-US', 'Shield'),
('login.marketing.features.visibility.icon', 'en-US', 'Chart Line');

-- Insert login page translations for Spanish
INSERT INTO translations (translationKey, languageID, translationValue) VALUES
-- Login Form Elements
('login.title', 'es-ES', 'Bienvenido de nuevo'),
('login.accessGRCWorkspace', 'es-ES', 'Accede a tu espacio de trabajo GRC'),
('login.email', 'es-ES', 'Correo electrónico'),
('login.password', 'es-ES', 'Contraseña'),
('login.rememberMe', 'es-ES', 'Recordarme'),
('login.submit', 'es-ES', 'Iniciar sesión'),
('login.forgotPassword', 'es-ES', '¿Olvidaste tu contraseña?'),
('login.error', 'es-ES', 'Correo electrónico o contraseña inválidos'),
('login.register', 'es-ES', 'Registra tu empresa'),
('login.newToGRC', 'es-ES', '¿Nuevo en LightGRC?'),

-- Marketing Content
('login.marketing.title', 'es-ES', 'Ilumina tu viaje GRC'),
('login.marketing.subtitle', 'es-ES', 'LightGRC aporta claridad y eficiencia a la gobernanza, el riesgo y el cumplimiento con información impulsada por IA y automatización'),
('login.marketing.features.insights.title', 'es-ES', 'Información inteligente'),
('login.marketing.features.insights.desc', 'es-ES', 'Análisis de riesgos y controles predictivos impulsados por IA'),
('login.marketing.features.compliance.title', 'es-ES', 'Cumplimiento rápido'),
('login.marketing.features.compliance.desc', 'es-ES', 'Evaluaciones automatizadas y monitoreo en tiempo real'),
('login.marketing.features.security.title', 'es-ES', 'Seguridad mejorada'),
('login.marketing.features.security.desc', 'es-ES', 'Controles integrados y marcos de seguridad'),
('login.marketing.features.visibility.title', 'es-ES', 'Visibilidad clara'),
('login.marketing.features.visibility.desc', 'es-ES', 'Paneles y reportes completos'),

-- Statistics Labels
('login.marketing.stats.uptime', 'es-ES', 'Tiempo de actividad'),
('login.marketing.stats.clients', 'es-ES', 'Clientes empresariales'),
('login.marketing.stats.support', 'es-ES', 'Soporte'),
('login.marketing.stats.uptime.value', 'es-ES', '99,9%'),
('login.marketing.stats.clients.value', 'es-ES', '500+'),
('login.marketing.stats.support.value', 'es-ES', '24/7'),

-- Feature Icons
('login.marketing.features.insights.icon', 'es-ES', 'Bombilla'),
('login.marketing.features.compliance.icon', 'es-ES', 'Rayo'),
('login.marketing.features.security.icon', 'es-ES', 'Escudo'),
('login.marketing.features.visibility.icon', 'es-ES', 'Gráfico');

-- Insert login page translations for Turkish
INSERT INTO translations (translationKey, languageID, translationValue) VALUES
-- Login Form Elements
('login.title', 'tr-TR', 'Tekrar Hoşgeldiniz'),
('login.accessGRCWorkspace', 'tr-TR', 'GRC çalışma alanınıza erişin'),
('login.email', 'tr-TR', 'E-posta'),
('login.password', 'tr-TR', 'Şifre'),
('login.rememberMe', 'tr-TR', 'Beni hatırla'),
('login.submit', 'tr-TR', 'Giriş Yap'),
('login.forgotPassword', 'tr-TR', 'Şifrenizi mi unuttunuz?'),
('login.error', 'tr-TR', 'Geçersiz e-posta veya şifre'),
('login.register', 'tr-TR', 'Şirketinizi Kaydedin'),
('login.newToGRC', 'tr-TR', 'LightGRC''ye yeni misiniz?'),

-- Marketing Content
('login.marketing.title', 'tr-TR', 'GRC Yolculuğunuzu Aydınlatın'),
('login.marketing.subtitle', 'tr-TR', 'LightGRC, yapay zeka destekli içgörüler ve otomasyon ile yönetişim, risk ve uyumluluğa netlik ve verimlilik getirir'),
('login.marketing.features.insights.title', 'tr-TR', 'Akıllı İçgörüler'),
('login.marketing.features.insights.desc', 'tr-TR', 'Yapay zeka destekli risk analizi ve öngörülü kontroller'),
('login.marketing.features.compliance.title', 'tr-TR', 'Hızlı Uyumluluk'),
('login.marketing.features.compliance.desc', 'tr-TR', 'Otomatik değerlendirmeler ve gerçek zamanlı izleme'),
('login.marketing.features.security.title', 'tr-TR', 'Gelişmiş Güvenlik'),
('login.marketing.features.security.desc', 'tr-TR', 'Yerleşik kontroller ve güvenlik çerçeveleri'),
('login.marketing.features.visibility.title', 'tr-TR', 'Net Görünürlük'),
('login.marketing.features.visibility.desc', 'tr-TR', 'Kapsamlı paneller ve raporlama'),

-- Statistics Labels
('login.marketing.stats.uptime', 'tr-TR', 'Çalışma Süresi'),
('login.marketing.stats.clients', 'tr-TR', 'Kurumsal Müşteri'),
('login.marketing.stats.support', 'tr-TR', 'Destek'),
('login.marketing.stats.uptime.value', 'tr-TR', '%99,9'),
('login.marketing.stats.clients.value', 'tr-TR', '500+'),
('login.marketing.stats.support.value', 'tr-TR', '7/24'),

-- Feature Icons
('login.marketing.features.insights.icon', 'tr-TR', 'Ampul'),
('login.marketing.features.compliance.icon', 'tr-TR', 'Şimşek'),
('login.marketing.features.security.icon', 'tr-TR', 'Kalkan'),
('login.marketing.features.visibility.icon', 'tr-TR', 'Grafik');

-- Verify the number of inserted records
SELECT 
    languageID,
    COUNT(*) as translation_count
FROM translations 
WHERE translationKey LIKE 'login.%' 
AND languageID IN ('en-US', 'es-ES', 'tr-TR')
GROUP BY languageID;

-- Commit transaction if everything is successful
COMMIT; 