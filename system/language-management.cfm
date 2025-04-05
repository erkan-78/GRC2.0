<!DOCTYPE html>
<html>
<head>
    <title>Language Management</title>
    <link href="css/admin.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <!--- Check if user is logged in and is super admin --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR NOT session.isSuperAdmin>
        <cflocation url="../login.cfm" addtoken="false">
    </cfif>

    <div class="container">
        <h2 class="page-header">Language Management</h2>

        <div class="admin-card">
            <div class="admin-card-header">
                <h5 class="admin-card-title">Manage Languages</h5>
            </div>
            <div class="admin-card-body">
                <form id="languageForm">
                    <input type="hidden" id="languageID" name="languageID">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="languageCode" class="form-label">Language Code</label>
                            <input type="text" class="form-control" id="languageCode" name="languageCode" required>
                        </div>
                        <div class="col-md-6">
                            <label for="languageName" class="form-label">Language Name</label>
                            <input type="text" class="form-control" id="languageName" name="languageName" required>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="isActive" class="form-label">Active</label>
                            <select class="form-select" id="isActive" name="isActive" required>
                                <option value="1">Yes</option>
                                <option value="0">No</option>
                            </select>
                        </div>
                    </div>
                    <button type="button" class="btn btn-primary" onclick="saveLanguage()">Save Language</button>
                </form>

                <div class="admin-table-responsive mt-4">
                    <table class="admin-table" id="languagesTable">
                        <thead>
                            <tr>
                                <th>Language Code</th>
                                <th>Language Name</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="languagesBody">
                            <!-- Will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadLanguages();
        });

        function loadLanguages() {
            fetch('../api/language.cfc?method=getAllLanguages')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const tbody = document.getElementById('languagesBody');
                        tbody.innerHTML = '';
                        data.data.forEach(language => {
                            const row = document.createElement('tr');
                            row.innerHTML = `
                                <td>${language.languageID}</td>
                                <td>${language.languageName}</td>
                                <td>${language.isActive ? 'Active' : 'Inactive'}</td>
                                <td>
                                    <button class="btn btn-secondary" onclick="editLanguage('${language.languageID}')">Edit</button>
                                    <button class="btn btn-danger" onclick="toggleLanguage('${language.languageID}', ${language.isActive})">${language.isActive ? 'Disable' : 'Enable'}</button>
                                </td>
                            `;
                            tbody.appendChild(row);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error loading languages:', error);
                });
        }

        function saveLanguage() {
            const formData = {
                languageID: document.getElementById('languageID').value,
                languageCode: document.getElementById('languageCode').value,
                languageName: document.getElementById('languageName').value,
                isActive: document.getElementById('isActive').value
            };

            fetch('../api/language.cfc?method=saveLanguage', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    loadLanguages();
                    document.getElementById('languageForm').reset();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error saving language:', error);
            });
        }

        function editLanguage(languageID) {
            fetch(`../api/language.cfc?method=getLanguage&languageID=${languageID}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const language = data.data;
                        document.getElementById('languageID').value = language.languageID;
                        document.getElementById('languageCode').value = language.languageID;
                        document.getElementById('languageName').value = language.languageName;
                        document.getElementById('isActive').value = language.isActive ? '1' : '0';
                    } else {
                        alert(data.message);
                    }
                })
                .catch(error => {
                    console.error('Error loading language:', error);
                });
        }

        function toggleLanguage(languageID, isActive) {
            fetch('../api/language.cfc?method=toggleLanguage', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ languageID: languageID, isActive: !isActive })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    loadLanguages();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error toggling language:', error);
            });
        }
    </script>
</body>
</html>