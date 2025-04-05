<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Translations Management</title>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="../assets/css/base.css" rel="stylesheet">
    <link href="../assets/css/login.css" rel="stylesheet">
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
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        .page-header {
            text-align: center;
            margin-bottom: 2rem;
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
        .admin-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 2rem;
        }
        .admin-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .admin-card-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #1a237e;
            margin: 0;
        }
        .admin-btn {
            padding: 0.5rem 1rem;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .admin-btn-primary {
            background-color: #1a237e;
            color: white;
        }
        .admin-btn-primary:hover {
            background-color: #0d47a1;
        }
        .admin-btn-secondary {
            background-color: #e0e0e0;
            color: #333;
        }
        .admin-btn-secondary:hover {
            background-color: #bdbdbd;
        }
        .admin-btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
        }
        .admin-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        .admin-table th,
        .admin-table td {
            padding: 1rem;
            border-bottom: 1px solid #e0e0e0;
            text-align: left;
        }
        .admin-table th {
            background-color: #f5f5f5;
            font-weight: 600;
        }
        .admin-table tr:hover {
            background-color: #f8f9fa;
        }
        .admin-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        .admin-modal.show {
            display: block;
        }
        .admin-modal-dialog {
            max-width: 600px;
            margin: 2rem auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
        }
        .admin-modal-content {
            padding: 2rem;
        }
        .admin-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .admin-modal-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #1a237e;
            margin: 0;
        }
        .admin-form-group {
            margin-bottom: 1.5rem;
        }
        .admin-form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #333;
        }
        .admin-form-control {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            font-size: 1rem;
        }
        .admin-form-control:focus {
            outline: none;
            border-color: #1a237e;
        }
        .admin-modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 2rem;
        }
        .language-selector {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }
        .form-select {
            padding: 0.5rem;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            background-color: white;
        }
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            .admin-card {
                padding: 1rem;
            }
            .admin-modal-dialog {
                margin: 1rem;
            }
        }
    </style>
</head>
<body>
<cfset pageid="system.translations.manage">
    <!--- Check if user is logged in and has admin role --->
    <cfset permissionsService = new api.permissions.index()>
    <cfset hasPermission = permissionsService.hasPermission(session.userID, pageid)>
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR hasPermission.hasPermission EQ false>
        <cflocation url="../login.cfm" addtoken="false">
    </cfif>

    <!--- Get available languages --->
    <cfquery name="getLanguages" datasource="#application.datasource#">
        SELECT languageID, languageName
        FROM languages
        WHERE isActive = 1
        ORDER BY languageName
    </cfquery>

    <!--- Get translations for the current language --->
    <cfset languageID = session.languageID ?: "en-US">
    <cfquery name="getTranslations" datasource="#application.datasource#">
        SELECT translationKey, translationValue
        FROM translations
        WHERE languageID = <cfqueryparam value="#languageID#" cfsqltype="cf_sql_varchar">
        and page = 'translations'
    </cfquery>
    
    <cfset translations = {}>
    <cfloop query="getTranslations">
        <cfset translations[translationKey] = translationValue>
    </cfloop>

    <!--- Include the menu --->
    <cfinclude template="/includes/menu.cfm">
 

 
    <div class="container">
        <div class="brand-header">
            <span class="logo-text">Light<span class="highlight">GRC</span></span>
        </div>
        <h2 class="page-header" data-translation-key="translations.title">Translations Management</h2>

        <div class="admin-card">
            <div class="admin-card-header">
                <h5 class="admin-card-title" data-translation-key="translations.keys">Translation Keys</h5>
                <button type="button" class="admin-btn admin-btn-primary admin-btn-sm" onclick="showAddTranslationModal()">
                    <i class="bi bi-plus"></i> <span data-translation-key="translations.addNew">Add New Translation</span>
                </button>
            </div>
            <div class="admin-card-body">
                <div class="admin-table-responsive">
                    <table class="admin-table" id="translationsTable">
                        <thead>
                            <tr>
                                <th data-translation-key="translations.key">Key</th>
                                <cfloop query="getLanguages">
                                    <th>#languageName#</th>
                                </cfloop>
                                <th data-translation-key="translations.actions">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="translationsBody">
                            <!-- Will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add/Edit Translation Modal -->
    <div class="admin-modal" id="translationModal">
        <div class="admin-modal-dialog">
            <div class="admin-modal-content">
                <div class="admin-modal-header">
                    <h5 class="admin-modal-title" id="modalTitle" data-translation-key="translations.addNew">Add Translation</h5>
                    <button type="button" class="admin-btn admin-btn-secondary admin-btn-sm" onclick="closeModal()">×</button>
                </div>
                <div class="admin-modal-body">
                    <form id="translationForm">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="translationKey" data-translation-key="translations.key">Translation Key</label>
                            <input type="text" class="admin-form-control" id="translationKey" required>
                        </div>
                        <cfloop query="getLanguages">
                            <div class="admin-form-group">
                                <label class="admin-form-label" for="translation_#languageID#">
                                    #languageName# Translation
                                </label>
                                <input type="text" class="admin-form-control" 
                                    id="translation_#languageID#" 
                                    data-language="#languageID#" required>
                            </div>
                        </cfloop>
                    </form>
                </div>
                <div class="admin-modal-footer">
                    <button type="button" class="admin-btn admin-btn-secondary" onclick="closeModal()" data-translation-key="translations.cancel">Cancel</button>
                    <button type="button" class="admin-btn admin-btn-primary" onclick="saveTranslation()" data-translation-key="translations.save">Save</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let translationModal;
        let editingKey = null;

        document.addEventListener('DOMContentLoaded', function() {
            translationModal = document.getElementById('translationModal');
            loadTranslations();
            updateTranslations();
        });

        function showAddTranslationModal() {
            editingKey = null;
            document.getElementById('modalTitle').textContent = document.querySelector('[data-translation-key="translations.addNew"]').textContent;
            document.getElementById('translationKey').value = '';
            document.getElementById('translationKey').readOnly = false;
            
            <cfloop query="getLanguages">
                document.getElementById('translation_#languageID#').value = '';
            </cfloop>
            
            translationModal.classList.add('show');
        }

        function closeModal() {
            translationModal.classList.remove('show');
        }

        async function loadTranslations() {
            try {
                const response = await fetch('../api/admin.cfc?method=getAllTranslations');
                const data = await response.json();
                
                if (data.success) {
                    const tbody = document.getElementById('translationsBody');
                    tbody.innerHTML = '';
                    
                    Object.entries(data.data).forEach(([key, translations]) => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td>${key}</td>
                            <cfloop query="getLanguages">
                                <td>${translations['#languageID#'] || ''}</td>
                            </cfloop>
                            <td>
                                <button class="admin-btn admin-btn-primary admin-btn-sm" onclick="editTranslation('${key}')">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button class="admin-btn admin-btn-secondary admin-btn-sm" onclick="deleteTranslation('${key}')">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        `;
                        tbody.appendChild(row);
                    });
                }
            } catch (error) {
                console.error('Error loading translations:', error);
            }
        }

        async function editTranslation(key) {
            try {
                const response = await fetch(`../api/admin.cfc?method=getTranslation&translationKey=${key}`);
                const data = await response.json();
                
                if (data.success) {
                    editingKey = key;
                    document.getElementById('modalTitle').textContent = document.querySelector('[data-translation-key="translations.edit"]').textContent;
                    document.getElementById('translationKey').value = key;
                    document.getElementById('translationKey').readOnly = true;
                    
                    <cfloop query="getLanguages">
                        document.getElementById('translation_#languageID#').value = 
                            data.data['#languageID#'] || '';
                    </cfloop>
                    
                    translationModal.classList.add('show');
                }
            } catch (error) {
                console.error('Error loading translation:', error);
            }
        }

        async function saveTranslation() {
            const key = document.getElementById('translationKey').value;
            const translations = {};
            
            <cfloop query="getLanguages">
                translations['#languageID#'] = document.getElementById('translation_#languageID#').value;
            </cfloop>
            
            try {
                const response = await fetch('../api/admin.cfc?method=saveTranslation', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        translationKey: key,
                        translations: translations,
                        isNew: !editingKey
                    })
                });
                
                const data = await response.json();
                if (data.success) {
                    translationModal.classList.remove('show');
                    loadTranslations();
                } else {
                    alert(data.message);
                }
            } catch (error) {
                console.error('Error saving translation:', error);
            }
        }

        async function deleteTranslation(key) {
            if (confirm(document.querySelector('[data-translation-key="translations.confirmDelete"]').textContent)) {
                try {
                    const response = await fetch('../api/admin.cfc?method=deleteTranslation', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({
                            translationKey: key
                        })
                    });
                    
                    const data = await response.json();
                    if (data.success) {
                        loadTranslations();
                    } else {
                        alert(data.message);
                    }
                } catch (error) {
                    console.error('Error deleting translation:', error);
                }
            }
        }

        function changeLanguage(languageCode) {
            fetch('../api/language/update.cfm', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    languageCode: languageCode
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    window.location.reload();
                }
            })
            .catch(error => console.error('Error:', error));
        }

        function updateTranslations() {
            const elements = document.querySelectorAll('[data-translation-key]');
            elements.forEach(element => {
                const key = element.getAttribute('data-translation-key');
                if (translations[key]) {
                    element.textContent = translations[key];
                }
            });
        }
    </script>
</body>
</html> 