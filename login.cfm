<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Intelligent Governance, Risk & Compliance</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
   
</head>
<body>
    <!--- Get available languages --->
    <cfquery name="getLanguages" datasource="#application.datasource#">
        SELECT languageID, languageName
        FROM languages
        WHERE isActive = 1
        ORDER BY languageName
    </cfquery>

    <!--- Get translations for the current language --->
    <cfset languageID = session.preferredLanguage ?: "en-US">
    <cfquery name="getTranslations" datasource="#application.datasource#">
        SELECT translationKey, translationValue
        FROM translations
        WHERE languageID = <cfqueryparam value="#languageID#" cfsqltype="cf_sql_varchar">
        and page = 'login'
    </cfquery>
    
    <cfset translations = {}>
    <cfloop query="getTranslations">
        <cfset translations[translationKey] = translationValue>
    </cfloop>

    <div class="language-selector">
        <select id="languageSelect" class="form-select form-select-sm" onchange="changeLanguage(this.value)">
            <cfoutput query="getLanguages">
                <option value="#languageID#" <cfif languageID EQ "en-US">selected</cfif>>#languageName#</option>
            </cfoutput>
        </select>
    </div>
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
        .trust-section {
            margin-top: 3rem;
            padding-bottom: 2rem;
        }
        .trust-badges {
            display: flex;
            justify-content: space-around;
            margin-bottom: 2rem;
        }
        .badge-item {
            text-align: center;
        }
        .badge-item .number {
            font-size: 2rem;
            font-weight: 700;
            display: block;
            color: #64b5f6;
        }
        .badge-item .label {
            font-size: 0.875rem;
            opacity: 0.8;
        }
        .certification-badges {
            display: flex;
            justify-content: center;
            gap: 2rem;
        }
        .cert-badge {
            opacity: 0.8;
            transition: opacity 0.3s ease;
        }
        .cert-badge:hover {
            opacity: 1;
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
    </style>

    <div class="container-fluid h-100">
        <div class="row h-100">
            <!-- Login Side -->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2 data-translation-key="login.title">Welcome Back</h2>
                        <p class="text-muted" data-translation-key="login.accessGRCWorkspace">Access your GRC workspace</p>
                    </div>

                    <div class="alert alert-danger" id="errorAlert" role="alert" data-translation-key="login.error">
                        Invalid email or password
                    </div>

                    <form id="loginForm" onsubmit="return handleLogin(event)" class="login-form">
                        <input type="hidden" name="languageID" value="<cfoutput>#languageID#</cfoutput>">
                        <div class="form-group">
                            <label for="email" data-translation-key="login.email">Email</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-envelope"></i>
                                </span>
                                <input type="email" name="email" class="form-control" id="email" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="password" data-translation-key="login.password">Password</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-lock"></i>
                                </span>
                                <input type="password" name="password" class="form-control" id="password" required>
                            </div>
                        </div>

                        <div class="form-check mb-3">
                            <input type="checkbox" class="form-check-input" id="rememberMe" name="rememberMe">
                            <label class="form-check-label" for="rememberMe" data-translation-key="login.rememberMe">Remember me</label>
                        </div>

                        <button type="submit" class="btn btn-primary btn-block" data-translation-key="login.submit">Sign In</button>
                        
                        <div class="auth-links">
                            <a href="forgot-password.cfm" class="forgot-link" data-translation-key="login.forgotPassword" data-href="forgot-password.cfm">Forgot your password?</a>
                            <div class="register-link">
                                <span data-translation-key="login.newToGRC">New to LightGRC?</span> 
                                <a href="register.cfm" class="btn btn-outline-primary" data-translation-key="login.register" data-href="register.cfm">Register Your Company</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Marketing Side -->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title" data-translation-key="login.marketing.title">Illuminate Your GRC Journey</h1>
                    <p class="lead-text" data-translation-key="login.marketing.subtitle">
                        LightGRC brings clarity and efficiency to governance, risk, and compliance with 
                        AI-powered insights and automation
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-lightbulb"></i>
                            </div>
                            <h3 data-translation-key="login.marketing.features.insights.title">Intelligent Insights</h3>
                            <p data-translation-key="login.marketing.features.insights.desc">AI-driven risk analysis and predictive controls</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-bolt"></i>
                            </div>
                            <h3 data-translation-key="login.marketing.features.compliance.title">Swift Compliance</h3>
                            <p data-translation-key="login.marketing.features.compliance.desc">Automated assessments and real-time monitoring</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3 data-translation-key="login.marketing.features.security.title">Enhanced Security</h3>
                            <p data-translation-key="login.marketing.features.security.desc">Built-in controls and security frameworks</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-chart-line"></i>
                            </div>
                            <h3 data-translation-key="login.marketing.features.visibility.title">Clear Visibility</h3>
                                <p data-translation-key="login.marketing.features.visibility.description">Comprehensive dashboards and reporting</p>
                        </div>
                    </div>

                    <div class="trust-section">
                        <div class="trust-badges">
                            <div class="badge-item">
                                <span class="number"  data-translation-key="login.marketing.stats.uptime.value">99.9%</span>
                                <span class="label" data-translation-key="login.marketing.stats.uptime">Uptime</span>
                            </div>
                            <div class="badge-item">
                                <span class="number" data-translation-key="login.marketing.stats.clients.value">500+</span>
                                <span class="label" data-translation-key="login.marketing.stats.clients">Enterprise Clients</span>
                            </div>
                            <div class="badge-item">
                                <span class="number" data-translation-key="login.marketing.stats.support.value">24/7</span>
                                <span class="label" data-translation-key="login.marketing.stats.support">Support</span>
                            </div> 
                        </div>
                        <div class="certification-badges">
                            <img src="assets/images/iso-27001.png" width="100" height="100" alt="ISO 27001" class="cert-badge">
                            <img src="assets/images/soc2.png" width="100" height="100" alt="SOC 2" class="cert-badge">
                            <img src="assets/images/gdpr.png" width="100" height="100" alt="GDPR" class="cert-badge">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="assets/js/bootstrap.bundle.min.js"></script>
    <script>
        let translations = <cfoutput>#serializeJSON(translations)#</cfoutput>;
        let currentLanguage = '<cfoutput>#languageID#</cfoutput>';

        // Update links with current language
        function updateLinks() {
            document.querySelectorAll('a[data-href]').forEach(link => {
                const baseUrl = link.getAttribute('data-href');
                link.href = `${baseUrl}?languageID=${currentLanguage}`;
            });
        }

        // Apply translations to the page
        function applyTranslations() {
            document.querySelectorAll('[data-translation-key]').forEach(element => {
                const key = element.getAttribute('data-translation-key');
                if (translations[key]) {
                    if (element.tagName === 'INPUT' && element.type === 'placeholder') {
                        element.placeholder = translations[key];
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
                const response = await fetch(`api/language.cfc?method=getTranslations&languageID=${languageID}&page=login`);
                const data = await response.json();
                
                if (data.success) {
                    translations = data.data;
                    currentLanguage = languageID;
                    applyTranslations();
                    // Update the hidden input with new language
                    document.querySelector('input[name="languageID"]').value = languageID;
                }
            } catch (error) {
                console.error('Error loading translations:', error);
            }
        }

        // Handle language change
        async function changeLanguage(languageID) {
            await loadTranslations(languageID);
        }

        // Handle login form submission
        async function handleLogin(event) {
            event.preventDefault();
            
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const rememberMe = document.getElementById('rememberMe').checked;
            const languageID = currentLanguage;
            
            try {
                const response = await fetch('login_process.cfm', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        email: email,
                        password: password,
                        rememberMe: rememberMe,
                        languageID: languageID
                    })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    window.location.href = 'dashboard.cfm';
                } else {
                    document.getElementById('errorAlert').style.display = 'block';
                }
            } catch (error) {
                console.error('Error during login:', error);
                document.getElementById('errorAlert').style.display = 'block';
            }
            
            return false;
        }

        // Initialize
        applyTranslations();
    </script>
</body>
</html> 