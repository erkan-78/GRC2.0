-- Start transaction
START TRANSACTION;

-- Delete existing translations for registration page
DELETE FROM translations 
WHERE translationKey LIKE 'register.%' 
AND languageID IN ('en-US', 'es-ES', 'tr-TR');

-- Insert English translations
INSERT INTO translations (languageID, translationKey, translationValue) VALUES
-- Page title and subtitle
('en-US', 'register.title', 'Create Your Account'),
('en-US', 'register.subtitle', 'Join our GRC platform'),

-- Form labels
('en-US', 'register.companyName', 'Company Name'),
('en-US', 'register.firstName', 'First Name'),
('en-US', 'register.lastName', 'Last Name'),
('en-US', 'register.email', 'Email'),
('en-US', 'register.password', 'Password'),
('en-US', 'register.confirmPassword', 'Confirm Password'),
('en-US', 'register.terms', 'I agree to the Terms of Service and Privacy Policy'),
('en-US', 'register.submit', 'Create Account'),

-- Password requirements
('en-US', 'register.passwordRequirements', 'Password must be at least 8 characters long and contain:'),
('en-US', 'register.passwordRequirement1', 'At least one uppercase letter'),
('en-US', 'register.passwordRequirement2', 'At least one lowercase letter'),
('en-US', 'register.passwordRequirement3', 'At least one number'),
('en-US', 'register.passwordRequirement4', 'At least one special character'),

-- Marketing content
('en-US', 'register.marketing.title', 'Welcome to LightGRC'),
('en-US', 'register.marketing.subtitle', 'Your journey to better governance, risk management, and compliance starts here'),
('en-US', 'register.marketing.feature1.title', 'Secure Setup'),
('en-US', 'register.marketing.feature1.description', 'Enterprise-grade security from day one'),
('en-US', 'register.marketing.feature2.title', 'Quick Start'),
('en-US', 'register.marketing.feature2.description', 'Get up and running in minutes'),
('en-US', 'register.marketing.feature3.title', '24/7 Support'),
('en-US', 'register.marketing.feature3.description', 'Expert assistance when you need it'),
('en-US', 'register.marketing.nextSteps.title', 'Next Steps'),
('en-US', 'register.marketing.nextSteps.step1', 'Create your account'),
('en-US', 'register.marketing.nextSteps.step2', 'Verify your email'),
('en-US', 'register.marketing.nextSteps.step3', 'Complete your company profile'),
('en-US', 'register.marketing.nextSteps.step4', 'Start using LightGRC'),

-- Success message
('en-US', 'register.success.title', 'Registration Successful!'),
('en-US', 'register.success.message', 'Thank you for registering. Please check your email to verify your account.'),
('en-US', 'register.success.loginButton', 'Log In'),

-- Error messages
('en-US', 'register.error.passwordsMatch', 'Passwords do not match'),
('en-US', 'register.error.termsRequired', 'You must agree to the terms and conditions'),
('en-US', 'register.error.general', 'An error occurred. Please try again.');

-- Insert Spanish translations
INSERT INTO translations (languageID, translationKey, translationValue) VALUES
-- Page title and subtitle
('es-ES', 'register.title', 'Crear Cuenta'),
('es-ES', 'register.subtitle', 'Únete a nuestra plataforma GRC'),

-- Form labels
('es-ES', 'register.companyName', 'Nombre de la Empresa'),
('es-ES', 'register.firstName', 'Nombre'),
('es-ES', 'register.lastName', 'Apellido'),
('es-ES', 'register.email', 'Correo Electrónico'),
('es-ES', 'register.password', 'Contraseña'),
('es-ES', 'register.confirmPassword', 'Confirmar Contraseña'),
('es-ES', 'register.terms', 'Acepto los Términos de Servicio y la Política de Privacidad'),
('es-ES', 'register.submit', 'Crear Cuenta'),

-- Password requirements
('es-ES', 'register.passwordRequirements', 'La contraseña debe tener al menos 8 caracteres y contener:'),
('es-ES', 'register.passwordRequirement1', 'Al menos una letra mayúscula'),
('es-ES', 'register.passwordRequirement2', 'Al menos una letra minúscula'),
('es-ES', 'register.passwordRequirement3', 'Al menos un número'),
('es-ES', 'register.passwordRequirement4', 'Al menos un carácter especial'),

-- Marketing content
('es-ES', 'register.marketing.title', 'Bienvenido a LightGRC'),
('es-ES', 'register.marketing.subtitle', 'Tu viaje hacia una mejor gobernanza, gestión de riesgos y cumplimiento comienza aquí'),
('es-ES', 'register.marketing.feature1.title', 'Configuración Segura'),
('es-ES', 'register.marketing.feature1.description', 'Seguridad de nivel empresarial desde el primer día'),
('es-ES', 'register.marketing.feature2.title', 'Inicio Rápido'),
('es-ES', 'register.marketing.feature2.description', 'Comienza a usar en minutos'),
('es-ES', 'register.marketing.feature3.title', 'Soporte 24/7'),
('es-ES', 'register.marketing.feature3.description', 'Asistencia experta cuando la necesites'),
('es-ES', 'register.marketing.nextSteps.title', 'Próximos Pasos'),
('es-ES', 'register.marketing.nextSteps.step1', 'Crea tu cuenta'),
('es-ES', 'register.marketing.nextSteps.step2', 'Verifica tu correo electrónico'),
('es-ES', 'register.marketing.nextSteps.step3', 'Completa el perfil de tu empresa'),
('es-ES', 'register.marketing.nextSteps.step4', 'Comienza a usar LightGRC'),

-- Success message
('es-ES', 'register.success.title', '¡Registro Exitoso!'),
('es-ES', 'register.success.message', 'Gracias por registrarte. Por favor, revisa tu correo electrónico para verificar tu cuenta.'),
('es-ES', 'register.success.loginButton', 'Iniciar Sesión'),

-- Error messages
('es-ES', 'register.error.passwordsMatch', 'Las contraseñas no coinciden'),
('es-ES', 'register.error.termsRequired', 'Debes aceptar los términos y condiciones'),
('es-ES', 'register.error.general', 'Ocurrió un error. Por favor, inténtalo de nuevo.');

-- Insert Turkish translations
INSERT INTO translations (languageID, translationKey, translationValue) VALUES
-- Page title and subtitle
('tr-TR', 'register.title', 'Hesap Oluştur'),
('tr-TR', 'register.subtitle', 'GRC platformumuza katılın'),

-- Form labels
('tr-TR', 'register.companyName', 'Şirket Adı'),
('tr-TR', 'register.firstName', 'Ad'),
('tr-TR', 'register.lastName', 'Soyad'),
('tr-TR', 'register.email', 'E-posta'),
('tr-TR', 'register.password', 'Şifre'),
('tr-TR', 'register.confirmPassword', 'Şifreyi Onayla'),
('tr-TR', 'register.terms', 'Hizmet Şartları ve Gizlilik Politikasını kabul ediyorum'),
('tr-TR', 'register.submit', 'Hesap Oluştur'),

-- Password requirements
('tr-TR', 'register.passwordRequirements', 'Şifre en az 8 karakter uzunluğunda olmalı ve şunları içermelidir:'),
('tr-TR', 'register.passwordRequirement1', 'En az bir büyük harf'),
('tr-TR', 'register.passwordRequirement2', 'En az bir küçük harf'),
('tr-TR', 'register.passwordRequirement3', 'En az bir rakam'),
('tr-TR', 'register.passwordRequirement4', 'En az bir özel karakter'),

-- Marketing content
('tr-TR', 'register.marketing.title', 'LightGRC''ye Hoş Geldiniz'),
('tr-TR', 'register.marketing.subtitle', 'Daha iyi yönetişim, risk yönetimi ve uyumluluk yolculuğunuz burada başlıyor'),
('tr-TR', 'register.marketing.feature1.title', 'Güvenli Kurulum'),
('tr-TR', 'register.marketing.feature1.description', 'İlk günden kurumsal düzeyde güvenlik'),
('tr-TR', 'register.marketing.feature2.title', 'Hızlı Başlangıç'),
('tr-TR', 'register.marketing.feature2.description', 'Dakikalar içinde kullanmaya başlayın'),
('tr-TR', 'register.marketing.feature3.title', '7/24 Destek'),
('tr-TR', 'register.marketing.feature3.description', 'İhtiyaç duyduğunuzda uzman desteği'),
('tr-TR', 'register.marketing.nextSteps.title', 'Sonraki Adımlar'),
('tr-TR', 'register.marketing.nextSteps.step1', 'Hesabınızı oluşturun'),
('tr-TR', 'register.marketing.nextSteps.step2', 'E-postanızı doğrulayın'),
('tr-TR', 'register.marketing.nextSteps.step3', 'Şirket profilinizi tamamlayın'),
('tr-TR', 'register.marketing.nextSteps.step4', 'LightGRC''yi kullanmaya başlayın'),

-- Success message
('tr-TR', 'register.success.title', 'Kayıt Başarılı!'),
('tr-TR', 'register.success.message', 'Kayıt olduğunuz için teşekkürler. Lütfen hesabınızı doğrulamak için e-postanızı kontrol edin.'),
('tr-TR', 'register.success.loginButton', 'Giriş Yap'),

-- Error messages
('tr-TR', 'register.error.passwordsMatch', 'Şifreler eşleşmiyor'),
('tr-TR', 'register.error.termsRequired', 'Şartları ve koşulları kabul etmelisiniz'),
('tr-TR', 'register.error.general', 'Bir hata oluştu. Lütfen tekrar deneyin.');

-- Verify the inserted records
SELECT languageID, COUNT(*) as translation_count 
FROM translations 
WHERE translationKey LIKE 'register.%' 
GROUP BY languageID;

-- Commit transaction
COMMIT; 