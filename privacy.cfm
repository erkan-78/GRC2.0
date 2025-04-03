<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Privacy Policy</title>
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
        .privacy-header {
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
        .privacy-content {
            line-height: 1.6;
        }
        .privacy-section {
            margin-bottom: 2rem;
        }
        .privacy-section h2 {
            color: #1a237e;
            margin-bottom: 1rem;
        }
        .privacy-section h3 {
            color: #0d47a1;
            margin: 1.5rem 0 1rem;
            font-size: 1.25rem;
        }
        .privacy-section p {
            margin-bottom: 1rem;
        }
        .privacy-section ul {
            margin-bottom: 1rem;
            padding-left: 1.5rem;
        }
        .privacy-section li {
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
        AND page = 'privacy'
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
        <div class="privacy-header">
            <div class="brand-header">
                <span class="logo-text">Light<span class="highlight">GRC</span></span>
            </div>
            <h1 data-translation-key="privacy.title">Privacy Policy</h1>
            <p class="text-muted" data-translation-key="privacy.lastUpdated">Last updated: <cfoutput>#dateFormat(now(), "mmmm d, yyyy")#</cfoutput></p>
        </div>

        <div class="privacy-content">
            <div class="privacy-section">
                <h2 data-translation-key="privacy.introduction.title">Introduction</h2>
                <p data-translation-key="privacy.introduction.content">At LightGRC, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our service.</p>
            </div>

            <div class="privacy-section">
                <h2 data-translation-key="privacy.collection.title">Information We Collect</h2>
                <h3 data-translation-key="privacy.collection.personal.title">Personal Information</h3>
                <p data-translation-key="privacy.collection.personal.intro">We collect information that you provide directly to us, including:</p>
                <ul>
                    <li data-translation-key="privacy.collection.personal.item1">Name and contact information</li>
                    <li data-translation-key="privacy.collection.personal.item2">Account credentials</li>
                    <li data-translation-key="privacy.collection.personal.item3">Company information</li>
                    <li data-translation-key="privacy.collection.personal.item4">Payment information</li>
                </ul>
                
                <h3 data-translation-key="privacy.collection.usage.title">Usage Information</h3>
                <p data-translation-key="privacy.collection.usage.intro">We automatically collect information about your use of our service, including:</p>
                <ul>
                    <li data-translation-key="privacy.collection.usage.item1">Log data and device information</li>
                    <li data-translation-key="privacy.collection.usage.item2">Usage patterns and preferences</li>
                    <li data-translation-key="privacy.collection.usage.item3">Performance metrics</li>
                    <li data-translation-key="privacy.collection.usage.item4">Error reports</li>
                </ul>
            </div>

            <div class="privacy-section">
                <h2 data-translation-key="privacy.usage.title">How We Use Your Information</h2>
                <p data-translation-key="privacy.usage.intro">We use the collected information for various purposes, including:</p>
                <ul>
                    <li data-translation-key="privacy.usage.item1">Providing and maintaining our service</li>
                    <li data-translation-key="privacy.usage.item2">Processing your transactions</li>
                    <li data-translation-key="privacy.usage.item3">Sending you important updates</li>
                    <li data-translation-key="privacy.usage.item4">Improving our service</li>
                    <li data-translation-key="privacy.usage.item5">Complying with legal obligations</li>
                </ul>
            </div>

            <div class="privacy-section">
                <h2 data-translation-key="privacy.security.title">Data Security</h2>
                <p data-translation-key="privacy.security.content">We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.</p>
            </div>

            <div class="privacy-section">
                <h2 data-translation-key="privacy.sharing.title">Data Sharing</h2>
                <p data-translation-key="privacy.sharing.intro">We may share your information with:</p>
                <ul>
                    <li data-translation-key="privacy.sharing.item1">Service providers and business partners</li>
                    <li data-translation-key="privacy.sharing.item2">Legal authorities when required</li>
                    <li data-translation-key="privacy.sharing.item3">Other users with your consent</li>
                </ul>
            </div>

            <div class="privacy-section">
                <h2 data-translation-key="privacy.rights.title">Your Rights</h2>
                <p data-translation-key="privacy.rights.intro">You have the right to:</p>
                <ul>
                    <li data-translation-key="privacy.rights.item1">Access your personal information</li>
                    <li data-translation-key="privacy.rights.item2">Correct inaccurate data</li>
                    <li data-translation-key="privacy.rights.item3">Request deletion of your data</li>
                    <li data-translation-key="privacy.rights.item4">Opt-out of marketing communications</li>
                    <li data-translation-key="privacy.rights.item5">Export your data</li>
                </ul>
            </div>

            <div class="privacy-section">
                <h2 data-translation-key="privacy.cookies.title">Cookies and Tracking</h2>
                <p data-translation-key="privacy.cookies.content">We use cookies and similar tracking technologies to track activity on our service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.</p>
            </div>

            <div class="privacy-section">
                <h2 data-translation-key="privacy.contact.title">Contact Us</h2>
                <p data-translation-key="privacy.contact.intro">If you have any questions about this Privacy Policy, please contact us at:</p>
                <p>
                    Email: privacy@lightgrc.com<br>
                    Address: 123 Business Street, Suite 100, City, State 12345
                </p>
            </div>
        </div>

        <div class="back-link">
            <a href="register.cfm?languageID=<cfoutput>#languageID#</cfoutput>" class="btn btn-primary" data-translation-key="privacy.backToRegister">Back to Registration</a>
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
            const response = await fetch(`api/language.cfc?method=getTranslations&languageID=${languageID}&page=privacy`);
            const data = await response.json();
            
            if (data.success) {
                translations = data.data;
                currentLanguage = languageID;
                applyTranslations();
                // Update the language selector
                document.getElementById('languageSelect').value = languageID;
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