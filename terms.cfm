<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Terms of Service</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            min-height: 100vh;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 2rem;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .language-selector {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }
        .terms-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .brand-header {
            text-align: center;
            margin-bottom: 1rem;
        }
        .logo-text {
            font-size: 2rem;
            font-weight: 700;
            color: #1a237e;
        }
        .logo-text .highlight {
            color: #0d47a1;
        }
        .terms-content {
            line-height: 1.6;
        }
        .terms-section {
            margin-bottom: 2rem;
        }
        .terms-section h2 {
            color: #1a237e;
            margin-bottom: 1rem;
        }
        .terms-section p {
            margin-bottom: 1rem;
        }
        .terms-section ul {
            margin-bottom: 1rem;
            padding-left: 1.5rem;
        }
        .terms-section li {
            margin-bottom: 0.5rem;
        }
        .back-link {
            text-align: center;
            margin-top: 2rem;
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
        AND page = 'terms'
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

    <div class="container">
        <div class="terms-header">
            <div class="brand-header">
                <span class="logo-text">Light<span class="highlight">GRC</span></span>
            </div>
            <h1 data-translation-key="terms.title">Terms of Service</h1>
            <p class="text-muted" data-translation-key="terms.lastUpdated">Last updated: <cfoutput>#dateFormat(now(), "mmmm d, yyyy")#</cfoutput></p>
        </div>

        <div class="terms-content">
            <div class="terms-section">
                <h2 data-translation-key="terms.introduction.title">Introduction</h2>
                <p data-translation-key="terms.introduction.content">Welcome to LightGRC. By accessing or using our services, you agree to be bound by these Terms of Service.</p>
            </div>

            <div class="terms-section">
                <h2 data-translation-key="terms.definitions.title">Definitions</h2>
                <ul>
                    <li data-translation-key="terms.definitions.service">"Service" refers to the LightGRC platform and all its features</li>
                    <li data-translation-key="terms.definitions.user">"User" refers to any individual or entity using our Service</li>
                    <li data-translation-key="terms.definitions.content">"Content" refers to all information and data uploaded to our Service</li>
                </ul>
            </div>

            <div class="terms-section">
                <h2 data-translation-key="terms.usage.title">Usage Terms</h2>
                <p data-translation-key="terms.usage.content">You must be at least 18 years old to use our Service. You are responsible for maintaining the security of your account.</p>
            </div>

            <div class="terms-section">
                <h2 data-translation-key="terms.privacy.title">Privacy and Data Protection</h2>
                <p data-translation-key="terms.privacy.content">We take your privacy seriously. Please review our Privacy Policy for details on how we collect, use, and protect your data.</p>
            </div>

            <div class="terms-section">
                <h2 data-translation-key="terms.termination.title">Account Termination</h2>
                <p data-translation-key="terms.termination.content">We reserve the right to terminate or suspend your account for violations of these terms or for any other reason.</p>
            </div>

            <div class="terms-section">
                <h2 data-translation-key="terms.changes.title">Changes to Terms</h2>
                <p data-translation-key="terms.changes.content">We may modify these terms at any time. Continued use of the Service after changes constitutes acceptance of the new terms.</p>
            </div>
        </div>

        <div class="back-link">
            <a href="register.cfm?languageID=<cfoutput>#languageID#</cfoutput>" class="btn btn-primary" data-translation-key="terms.backToRegister">Back to Registration</a>
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
            const response = await fetch(`api/language.cfc?method=getTranslations&languageID=${languageID}&page=terms`);
            const data = await response.json();
            
            if (data.success) {
                translations = data.data;
                currentLanguage = languageID;
                applyTranslations();
                // Update the hidden input with the new language
                document.querySelector('input[name="languageID"]').value = languageID;
                // Update all links with the new language
                updateLinks();
                // Update the register.cfm link with the new language
                const registerLink = document.querySelector('a[href*="register.cfm"]');
                if (registerLink) {
                    registerLink.href = `register.cfm?languageID=${languageID}`;
                }
            }
        } catch (error) {
            console.error('Error loading translations:', error);
        }
    }

    // Handle language change
    async function changeLanguage(languageID) {
        await loadTranslations(languageID);
    }

    // Initialize
    applyTranslations();
    </script>
</body>
</html> 