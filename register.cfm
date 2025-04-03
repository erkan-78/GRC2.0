<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Register Your Company</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            height: 100vh;
            margin: 0;
            padding: 0;
            overflow: hidden;
        }
        .container-fluid {
            height: 100vh;
            padding: 0;
            display: flex;
        }
        .row {
            height: 100%;
            margin: 0;
            width: 100%;
            display: flex;
        }
        .login-side {
            background: white;
            height: 100%;
            width: 33%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            position: relative;
        }
        .marketing-side {
            background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%);
            height: 100%;
            width: 67%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            color: white;
            overflow-y: auto;
        }
        .login-container {
            max-width: 400px;
            width: 100%;
            padding: 20px;
        }
        .login-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            padding: 30px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header img {
            max-width: 150px;
            margin-bottom: 20px;
        }
        .form-floating {
            margin-bottom: 15px;
        }
        .btn-primary {
            width: 100%;
            padding: 12px;
            margin-top: 20px;
        }
        .language-selector {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }
        .alert {
            display: none;
            margin-bottom: 20px;
        }
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 3rem;
        }
        .feature-item {
            text-align: center;
            padding: 1.5rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            transition: transform 0.3s ease;
        }
        .feature-item:hover {
            transform: translateY(-5px);
        }
        .feature-icon {
            font-size: 2rem;
            margin-bottom: 1rem;
            color: #64b5f6;
        }
        .brand-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .logo-text {
            font-size: 2rem;
            font-weight: 700;
            color: #1a237e;
        }
        .logo-text .highlight {
            color: #0d47a1;
        }
        .mega-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: white;
        }
        .lead-text {
            font-size: 1.25rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .next-steps {
            background: rgba(255, 255, 255, 0.1);
            padding: 2rem;
            border-radius: 10px;
            margin-top: 2rem;
        }
        .next-steps h3 {
            margin-bottom: 1.5rem;
            color: #64b5f6;
        }
        .next-steps ol {
            padding-left: 1.5rem;
        }
        .next-steps li {
            margin-bottom: 1rem;
            opacity: 0.9;
        }
        @media (max-width: 991.98px) {
            .marketing-side {
                display: none;
            }
            .login-side {
                width: 100%;
                padding: 1rem;
            }
        }
        .form-control.is-invalid {
            border-color: #dc3545;
            padding-right: calc(1.5em + 0.75rem);
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linecap='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }
        .invalid-feedback {
            display: none;
            width: 100%;
            margin-top: 0.25rem;
            font-size: 0.875em;
            color: #dc3545;
        }
        .form-control.is-invalid ~ .invalid-feedback {
            display: block;
        }
        .password-requirements {
            font-size: 0.875rem;
            color: #6c757d;
            margin-top: 0.25rem;
        }
        .success-message {
            display: none;
            text-align: center;
            padding: 2rem;
        }
        .success-message.show {
            display: block;
        }
        .form-container {
            display: block;
        }
        .form-container.hide {
            display: none;
        }
    </style>
</head>
<body>
    <!--- Get available languages --->
    <cfquery name="getLanguages" datasource="#application.datasource#">
        SELECT languageID, languageName
        FROM languages
        WHERE isActive = 1
        ORDER BY languageName
    </cfquery>

    <!--- Get language from URL or session, default to English --->
    <cfset languageID = url.languageID ?: session.preferredLanguage ?: "en-US">
    
    <!--- Get translations for the current language --->
    <cfquery name="getTranslations" datasource="#application.datasource#">
        SELECT translationKey, translationValue
        FROM translations
        WHERE languageID = <cfqueryparam value="#languageID#" cfsqltype="cf_sql_varchar">
        AND page = 'register'
    </cfquery>
    
    <cfset translations = {}>
    <cfloop query="getTranslations">
        <cfset translations[translationKey] = translationValue>
    </cfloop>

    <div class="language-selector">
        <select id="languageSelect" class="form-select form-select-sm" onchange="changeLanguage(this.value)">
            <cfoutput query="getLanguages">
                <option value="#languageID#" <cfif languageID EQ url.languageID>selected</cfif>>#languageName#</option>
            </cfoutput>
        </select>
    </div>

    <div class="container-fluid h-100">
        <div class="row h-100">
            <!--- Registration Form Side --->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2 data-translation-key="register.title">Create Your Account</h2>
                        <p class="text-muted" data-translation-key="register.subtitle">Join our GRC platform</p>
                    </div>
                    
                    <!--- Success Message --->
                    <div class="success-message" id="successMessage">
                        <div class="verification-icon success">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="verification-message">
                            <h3 data-translation-key="register.success.title">Registration Successful!</h3>
                            <p id="successText" data-translation-key="register.success.message"></p>
                        </div>
                        <div class="action-buttons">
                            <a href="login.cfm" class="btn btn-primary" data-translation-key="register.success.loginButton">Log In</a>
                        </div>
                    </div>
                    
                    <!--- Registration Form --->
                    <div class="form-container" id="registrationForm">
                        <form id="registerForm" onsubmit="return handleSubmit(event)" class="login-form">
                            <input type="hidden" name="languageID" value="<cfoutput>#languageID#</cfoutput>">
                            <div class="mb-3">
                                <label for="companyName" data-translation-key="register.companyName">Company Name</label>
                                <input type="text" class="form-control" id="companyName" name="companyName" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="firstName" data-translation-key="register.firstName">First Name</label>
                                <input type="text" class="form-control" id="firstName" name="firstName" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="lastName" data-translation-key="register.lastName">Last Name</label>
                                <input type="text" class="form-control" id="lastName" name="lastName" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="email" data-translation-key="register.email">Email</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="password" data-translation-key="register.password">Password</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                                <div class="password-requirements">
                                    <span data-translation-key="register.passwordRequirements">Password must be at least 8 characters long and contain:</span>
                                    <ul>
                                        <li data-translation-key="register.passwordRequirement1">At least one uppercase letter</li>
                                        <li data-translation-key="register.passwordRequirement2">At least one lowercase letter</li>
                                        <li data-translation-key="register.passwordRequirement3">At least one number</li>
                                        <li data-translation-key="register.passwordRequirement4">At least one special character</li>
                                    </ul>
                                </div>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="confirmPassword" data-translation-key="register.confirmPassword">Confirm Password</label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirm_password" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="terms" name="terms" required>
                                <label class="form-check-label" for="terms">
                                    <span data-translation-key="register.terms.prefix">I agree to the</span>
                                    <a href="terms.cfm?languageID=<cfoutput>#languageID#</cfoutput>" class="text-primary" data-translation-key="register.terms.link">Terms of Service</a>
                                    <span data-translation-key="register.terms.and">and</span>
                                    <a href="privacy.cfm?languageID=<cfoutput>#languageID#</cfoutput>" class="text-primary" data-translation-key="register.privacy.link">Privacy Policy</a>
                                </label>
                           
                                <div class="invalid-feedback" data-translation-key="register.error.termsRequired"></div>
                            </div>
                            
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary" id="submitButton" data-translation-key="register.submit">
                                    Create Account
                                </button>
                            </div>
                        </form>
                        
                        <div class="text-center mt-4">
                            <p data-translation-key="register.haveAccount">Already have an account? <a href="login.cfm?languageID=<cfoutput>#languageID#</cfoutput>" data-translation-key="register.loginLink">Log in</a></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!--- Marketing Side --->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title" data-translation-key="register.marketing.title">Welcome to LightGRC</h1>
                    <p class="lead-text" data-translation-key="register.marketing.subtitle">
                        Your journey to better governance, risk management, and compliance starts here
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3 data-translation-key="register.marketing.feature1.title">Secure Setup</h3>
                            <p data-translation-key="register.marketing.feature1.description">Enterprise-grade security from day one</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-rocket"></i>
                            </div>
                            <h3 data-translation-key="register.marketing.feature2.title">Quick Start</h3>
                            <p data-translation-key="register.marketing.feature2.description">Get up and running in minutes</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-headset"></i>
                            </div>
                            <h3 data-translation-key="register.marketing.feature3.title">24/7 Support</h3>
                            <p data-translation-key="register.marketing.feature3.description">Expert assistance when you need it</p>
                        </div>
                    </div>
                    
                    <div class="next-steps">
                        <h3 data-translation-key="register.marketing.nextSteps.title">Next Steps</h3>
                        <ol>
                            <li data-translation-key="register.marketing.nextSteps.step1">Create your account</li>
                            <li data-translation-key="register.marketing.nextSteps.step2">Verify your email</li>
                            <li data-translation-key="register.marketing.nextSteps.step3">Complete your company profile</li>
                            <li data-translation-key="register.marketing.nextSteps.step4">Start using LightGRC</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>

<script src="assets/js/bootstrap.bundle.min.js"></script>
<script>
let translations = <cfoutput>#serializeJSON(translations)#</cfoutput>;
let currentLanguage = '<cfoutput>#languageID#</cfoutput>';

// Update all links with the current language
function updateLinks() {
    document.querySelectorAll('a[href*="languageID="]').forEach(link => {
        const baseUrl = link.href.split('?')[0];
        link.href = `${baseUrl}?languageID=${currentLanguage}`;
    });
}

// Apply translations to the page
function applyTranslations() {
    document.querySelectorAll('[data-translation-key]').forEach(element => {
        const key = element.getAttribute('data-translation-key');
        if (translations[key]) {
            if (element.tagName === 'INPUT' && element.type === 'submit') {
                element.value = translations[key];
            } else {
                element.textContent = translations[key];
            }
        }
    });
    updateLinks();
}

// Load translations for a specific language
async function loadTranslations(languageID) {
    try {
        const response = await fetch(`api/language.cfc?method=getTranslations&languageID=${languageID}&page=register`);
        const data = await response.json();
        
        if (data.success) {
            translations = data.data;
            currentLanguage = languageID;
            applyTranslations();
            // Update the hidden input with the new language
            document.querySelector('input[name="languageID"]').value = languageID;
            // Update all links with the new language
            updateLinks();
        }
    } catch (error) {
        console.error('Error loading translations:', error);
    }
}

// Handle language change
async function changeLanguage(languageID) {
    await loadTranslations(languageID);
}

function handleSubmit(event) {
    event.preventDefault();
    
    // Reset form state
    resetForm();
    
    // Get form data
    const formData = {
        companyName: document.getElementById('companyName').value,
        firstName: document.getElementById('firstName').value,
        lastName: document.getElementById('lastName').value,
        email: document.getElementById('email').value,
        password: document.getElementById('password').value,
        languageID: currentLanguage
    };
    
    // Validate passwords match
    if (formData.password !== document.getElementById('confirmPassword').value) {
        showError('confirmPassword', translations['register.error.passwordsMatch']);
        return false;
    }
    
    // Validate terms acceptance
    if (!document.getElementById('terms').checked) {
        showError('terms', translations['register.error.termsRequired']);
        return false;
    }
    
    // Disable submit button and show loading state
    const submitButton = document.getElementById('submitButton');
    submitButton.disabled = true;
    submitButton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> ' + translations['register.submit'];
    
    // Make API call
    fetch('/api/register.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Show success message
            document.getElementById('successText').textContent = data.message;
            document.getElementById('successMessage').classList.add('show');
            document.getElementById('registrationForm').classList.add('hide');
        } else {
            // Show errors
            data.errors.forEach(error => {
                // Try to match error to specific field
                if (error.toLowerCase().includes('company name')) {
                    showError('companyName', error);
                } else if (error.toLowerCase().includes('first name')) {
                    showError('firstName', error);
                } else if (error.toLowerCase().includes('last name')) {
                    showError('lastName', error);
                } else if (error.toLowerCase().includes('email')) {
                    showError('email', error);
                } else if (error.toLowerCase().includes('password')) {
                    showError('password', error);
                } else {
                    // Show general error at the top
                    const alert = document.createElement('div');
                    alert.className = 'alert alert-danger mt-3';
                    alert.innerHTML = error;
                    document.getElementById('registerForm').insertBefore(alert, document.getElementById('registerForm').firstChild);
                    setTimeout(() => alert.remove(), 5000);
                }
            });
            
            // Reset button
            submitButton.disabled = false;
            submitButton.innerHTML = translations['register.submit'];
        }
    })
    .catch(error => {
        // Show error message
        const alert = document.createElement('div');
        alert.className = 'alert alert-danger mt-3';
        alert.innerHTML = translations['register.error.general'];
        document.getElementById('registerForm').insertBefore(alert, document.getElementById('registerForm').firstChild);
        
        // Reset button
        submitButton.disabled = false;
        submitButton.innerHTML = translations['register.submit'];
        
        // Remove alert after 5 seconds
        setTimeout(() => alert.remove(), 5000);
    });
    
    return false;
}

function showError(fieldId, message) {
    const field = document.getElementById(fieldId);
    const feedback = field.nextElementSibling;
    
    field.classList.add('is-invalid');
    feedback.textContent = message;
}

function resetForm() {
    // Remove all error states
    document.querySelectorAll('.is-invalid').forEach(field => {
        field.classList.remove('is-invalid');
    });
    
    // Remove all alerts
    document.querySelectorAll('.alert').forEach(alert => {
        alert.remove();
    });
}

// Initialize
applyTranslations();
</script>
</body>
</html> 