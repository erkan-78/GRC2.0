<!DOCTYPE html>
<html>
<head>
    <title>Translations Management</title>
    <link href="css/admin.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <!--- Check if user is logged in and has admin role --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR session.userRole NEQ "admin">
        <cflocation url="../login.cfm" addtoken="false">
    </cfif>

    <div class="container">
        <h2 class="page-header">Translations Management</h2>

        <div class="admin-card">
            <div class="admin-card-header">
                <h5 class="admin-card-title">Translation Keys</h5>
                <button type="button" class="admin-btn admin-btn-primary admin-btn-sm" onclick="showAddTranslationModal()">
                    <i class="bi bi-plus admin-icon"></i> Add New Translation
                </button>
            </div>
            <div class="admin-card-body">
                <div class="admin-table-responsive">
                    <table class="admin-table" id="translationsTable">
                        <thead>
                            <tr>
                                <th>Key</th>
                                <cfloop query="getLanguages">
                                    <th>#languageName#</th>
                                </cfloop>
                                <th>Actions</th>
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
                    <h5 class="admin-modal-title" id="modalTitle">Add Translation</h5>
                    <button type="button" class="admin-btn admin-btn-secondary admin-btn-sm" onclick="closeModal()">×</button>
                </div>
                <div class="admin-modal-body">
                    <form id="translationForm">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="translationKey">Translation Key</label>
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
                    <button type="button" class="admin-btn admin-btn-secondary" onclick="closeModal()">Cancel</button>
                    <button type="button" class="admin-btn admin-btn-primary" onclick="saveTranslation()">Save</button>
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
        });

        function showAddTranslationModal() {
            editingKey = null;
            document.getElementById('modalTitle').textContent = 'Add Translation';
            document.getElementById('translationKey').value = '';
            document.getElementById('translationKey').readOnly = false;
            
            <cfloop query="getLanguages">
                document.getElementById('translation_#languageID#').value = '';
            </cfloop>
            
            translationModal.classList.add('show');
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
                                <button class="btn btn-sm btn-primary" onclick="editTranslation('${key}')">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button class="btn btn-sm btn-danger" onclick="deleteTranslation('${key}')">
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

        function showAddTranslationModal() {
            editingKey = null;
            document.getElementById('modalTitle').textContent = 'Add Translation';
            document.getElementById('translationKey').value = '';
            document.getElementById('translationKey').readOnly = false;
            
            <cfloop query="getLanguages">
                document.getElementById('translation_#languageID#').value = '';
            </cfloop>
            
            translationModal.show();
        }

        async function editTranslation(key) {
            try {
                const response = await fetch(`../api/admin.cfc?method=getTranslation&translationKey=${key}`);
                const data = await response.json();
                
                if (data.success) {
                    editingKey = key;
                    document.getElementById('modalTitle').textContent = 'Edit Translation';
                    document.getElementById('translationKey').value = key;
                    document.getElementById('translationKey').readOnly = true;
                    
                    <cfloop query="getLanguages">
                        document.getElementById('translation_#languageID#').value = 
                            data.data['#languageID#'] || '';
                    </cfloop>
                    
                    translationModal.show();
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
                    translationModal.hide();
                    loadTranslations();
                } else {
                    alert(data.message);
                }
            } catch (error) {
                console.error('Error saving translation:', error);
            }
        }

        async function deleteTranslation(key) {
            if (confirm('Are you sure you want to delete this translation?')) {
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
    </script>
</body>
</html> 