<!DOCTYPE html>
<html>
<head>
    <title>Company Application</title>
    <link href="admin/css/admin.css" rel="stylesheet">
    <style>
        .application-container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        
        .application-title {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .required-field::after {
            content: "*";
            color: #dc3545;
            margin-left: 4px;
        }

        .logo-preview {
            width: 200px;
            height: 100px;
            border: 2px dashed #ddd;
            margin-top: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8f9fa;
        }

        .logo-preview img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
    </style>
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
</head>
<body>
    <cfset languageID = session.preferredLanguage ?: "en-US">
    
    <!--- Get translations for alerts --->
    <cfquery name="getAlertTranslations" datasource="#application.datasource#">
        SELECT translationKey, translationValue
        FROM translations
        WHERE languageID = <cfqueryparam value="#languageID#" cfsqltype="cf_sql_varchar">
        AND translationKey LIKE 'alert.%'
    </cfquery>
    
    <cfset alerts = {}>
    <cfloop query="getAlertTranslations">
        <cfset alerts[translationKey] = translationValue>
    </cfloop>

    <div class="application-container">
        <h1 class="application-title">Company Application Form</h1>
        
        <div class="admin-card">
            <div class="admin-card-header">
                <h5 class="admin-card-title">Company Information</h5>
            </div>
            <div class="admin-card-body">
                <form id="companyApplicationForm" onsubmit="submitApplication(event)" enctype="multipart/form-data">
                    <div class="admin-form-group">
                        <label class="admin-form-label required-field" for="name">Company Name</label>
                        <input type="text" class="admin-form-control" id="name" name="name" required>
                    </div>
                    
                    <div class="admin-form-group">
                        <label class="admin-form-label required-field" for="taxNumber">Tax Number</label>
                        <input type="text" class="admin-form-control" id="taxNumber" name="taxNumber" required>
                    </div>
                    
                    <div class="admin-form-group">
                        <label class="admin-form-label required-field" for="email">Company Email</label>
                        <input type="email" class="admin-form-control" id="email" name="email" required>
                    </div>
                    
                    <div class="admin-form-group">
                        <label class="admin-form-label required-field" for="phone">Phone Number</label>
                        <input type="tel" class="admin-form-control" id="phone" name="phone" required>
                    </div>
                    
                    <div class="admin-form-group">
                        <label class="admin-form-label required-field" for="address">Address</label>
                        <textarea class="admin-form-control" id="address" name="address" rows="3" required></textarea>
                    </div>
                    
                    <div class="admin-form-group">
                        <label class="admin-form-label" for="website">Website</label>
                        <input type="url" class="admin-form-control" id="website" name="website" placeholder="https://">
                    </div>

                    <div class="admin-form-group">
                        <label class="admin-form-label" for="logo">Company Logo</label>
                        <input type="file" class="admin-form-control" id="logo" name="logo" accept="image/*" onchange="previewLogo(event)">
                        <div class="logo-preview" id="logoPreview">
                            <span>Logo Preview</span>
                        </div>
                        <small class="admin-form-text text-muted">Recommended size: 200x100 pixels. Max file size: 2MB.</small>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="companyID" class="form-label">Company ID</label>
                            <input type="text" class="form-control" id="companyID" name="companyID" required>
                        </div>
                    </div>
                    
                    <div class="g-recaptcha" data-sitekey="YOUR_SITE_KEY"></div>
                    
                    <div class="admin-modal-footer">
                        <button type="submit" class="admin-btn admin-btn-primary">Submit Application</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Initialize alerts object with translations
        const alerts = <cfoutput>#serializeJSON(alerts)#</cfoutput>;

        function previewLogo(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const preview = document.getElementById('logoPreview');
                    preview.innerHTML = `<img src="${e.target.result}" alt="Logo Preview">`;
                }
                reader.readAsDataURL(file);
            }
        }

        async function submitApplication(event) {
            event.preventDefault();
            
            const formData = new FormData();
            formData.append('name', document.getElementById('name').value);
            formData.append('taxNumber', document.getElementById('taxNumber').value);
            formData.append('email', document.getElementById('email').value);
            formData.append('phone', document.getElementById('phone').value);
            formData.append('address', document.getElementById('address').value);
            formData.append('website', document.getElementById('website').value);
            
            const logoFile = document.getElementById('logo').files[0];
            if (logoFile) {
                formData.append('logo', logoFile);
            }
            
            try {
                const response = await fetch('api/company.cfc?method=submitApplication', {
                    method: 'POST',
                    body: formData
                });
                
                const data = await response.json();
                if (data.success) {
                    alert(alerts['alert.company.application.success']);
                    window.location.href = 'login.cfm';
                } else {
                    alert(data.message || alerts['alert.company.application.error']);
                }
            } catch (error) {
                console.error('Error submitting application:', error);
                alert(alerts['alert.company.application.error']);
            }
        }
    </script>
</body>
</html> 