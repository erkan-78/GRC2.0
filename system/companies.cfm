<!DOCTYPE html>
<html>
<head>
    <title>Company Management</title>
    <link href="css/admin.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <!--- Check if user is logged in and is super admin --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR NOT session.isSuperAdmin>
        <cflocation url="../login.cfm" addtoken="false">
    </cfif>

    <!--- Get translations for alerts --->
    <cfquery name="getAlertTranslations" datasource="#application.datasource#">
        SELECT translationKey, translationValue
        FROM translations
        WHERE languageID = <cfqueryparam value="#session.preferredLanguage#" cfsqltype="cf_sql_varchar">
        AND translationKey LIKE 'alert.%'
    </cfquery>
    
    <cfset alerts = {}>
    <cfloop query="getAlertTranslations">
        <cfset alerts[translationKey] = translationValue>
    </cfloop>

    <div class="container">
        <h2 class="page-header">Company Management</h2>

        <div class="admin-card">
            <div class="admin-card-header">
                <h5 class="admin-card-title">Companies</h5>
            </div>
            <div class="admin-card-body">
                <div class="admin-table-responsive">
                    <table class="admin-table" id="companiesTable">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Tax Number</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th>Application Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="companiesBody">
                            <!-- Will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Company Details Modal -->
    <div class="modal fade" id="companyModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Company Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="companyForm">
                        <input type="hidden" id="companyID" name="companyID">
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="name" class="form-label">Company Name</label>
                                <input type="text" class="form-control" id="name" name="name" required>
                            </div>
                            <div class="col-md-6">
                                <label for="taxNumber" class="form-label">Tax Number</label>
                                <input type="text" class="form-control" id="taxNumber" name="taxNumber" required>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                            </div>
                            <div class="col-md-6">
                                <label for="phone" class="form-label">Phone</label>
                                <input type="tel" class="form-control" id="phone" name="phone" required>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="address" class="form-label">Address</label>
                                <textarea class="form-control" id="address" name="address" rows="3" required></textarea>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="website" class="form-label">Website</label>
                                <input type="url" class="form-control" id="website" name="website">
                            </div>
                            <div class="col-md-6">
                                <label for="status" class="form-label">Status</label>
                                <select class="form-select" id="status" name="status" required>
                                    <cfloop query="getCompanyStatuses">
                                        <option value="#statusID#">#statusName#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="applicationDate" class="form-label">Application Date</label>
                                <div class="form-control-static" id="applicationDate"></div>
                            </div>
                            <div class="col-md-6">
                                <label for="approvalDate" class="form-label">Approval Date</label>
                                <div class="form-control-static" id="approvalDate"></div>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="lastModified" class="form-label">Last Modified</label>
                                <div class="form-control-static" id="lastModified"></div>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-12">
                                <hr>
                                <h5>SSO Configuration</h5>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check mb-3">
                                    <input type="checkbox" class="form-check-input" id="ssoEnabled" name="ssoEnabled">
                                    <label class="form-check-label" for="ssoEnabled">Enable SSO</label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label for="ssoProvider" class="form-label">SSO Provider</label>
                                <select class="form-select" id="ssoProvider" name="ssoProvider">
                                    <option value="">Select Provider</option>
                                    <option value="AZURE">Microsoft Azure AD</option>
                                    <option value="GOOGLE">Google Workspace</option>
                                    <option value="SAML">Generic SAML</option>
                                </select>
                            </div>
                        </div>

                        <div id="ssoFields" style="display: none;">
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="ssoDomain" class="form-label">Company Domain</label>
                                    <input type="text" class="form-control" id="ssoDomain" name="ssoDomain" 
                                           placeholder="example.com">
                                </div>
                                <div class="col-md-6">
                                    <label for="ssoClientID" class="form-label">Client ID</label>
                                    <input type="text" class="form-control" id="ssoClientID" name="ssoClientID">
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="ssoClientSecret" class="form-label">Client Secret</label>
                                    <input type="password" class="form-control" id="ssoClientSecret" name="ssoClientSecret">
                                </div>
                                <div class="col-md-6">
                                    <label for="ssoMetadataURL" class="form-label">Metadata URL</label>
                                    <input type="url" class="form-control" id="ssoMetadataURL" name="ssoMetadataURL"
                                           placeholder="https://">
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="saveCompany()">Save Changes</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Company Administrators Modal -->
    <div class="admin-modal" id="adminModal">
        <div class="admin-modal-dialog">
            <div class="admin-modal-content">
                <div class="admin-modal-header">
                    <h5 class="admin-modal-title">Company Administrators</h5>
                    <button type="button" class="admin-btn admin-btn-secondary admin-btn-sm" onclick="closeModal('adminModal')">×</button>
                </div>
                <div class="admin-modal-body">
                    <div class="admin-form-group">
                        <button type="button" class="admin-btn admin-btn-primary" onclick="showAddAdminModal()">
                            <i class="bi bi-plus admin-icon"></i> Add Administrator
                        </button>
                    </div>
                    <div class="admin-table-responsive">
                        <table class="admin-table" id="adminsTable">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Status</th>
                                    <th>Permissions</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="adminsBody">
                                <!-- Will be populated by JavaScript -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add/Edit Administrator Modal -->
    <div class="admin-modal" id="editAdminModal">
        <div class="admin-modal-dialog">
            <div class="admin-modal-content">
                <div class="admin-modal-header">
                    <h5 class="admin-modal-title">Administrator Details</h5>
                    <button type="button" class="admin-btn admin-btn-secondary admin-btn-sm" onclick="closeModal('editAdminModal')">×</button>
                </div>
                <div class="admin-modal-body">
                    <form id="adminForm">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="adminUser">User</label>
                            <select class="admin-form-control" id="adminUser" required>
                                <!-- Will be populated by JavaScript -->
                            </select>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label">Permissions</label>
                            <div class="admin-form-check">
                                <input type="checkbox" class="admin-form-check-input" id="perm_USER_MANAGEMENT">
                                <label class="admin-form-label" for="perm_USER_MANAGEMENT">User Management</label>
                            </div>
                            <div class="admin-form-check">
                                <input type="checkbox" class="admin-form-check-input" id="perm_TRANSLATION_MANAGEMENT">
                                <label class="admin-form-label" for="perm_TRANSLATION_MANAGEMENT">Translation Management</label>
                            </div>
                            <div class="admin-form-check">
                                <input type="checkbox" class="admin-form-check-input" id="perm_MENU_MANAGEMENT">
                                <label class="admin-form-label" for="perm_MENU_MANAGEMENT">Menu Management</label>
                            </div>
                            <div class="admin-form-check">
                                <input type="checkbox" class="admin-form-check-input" id="perm_FILE_MANAGEMENT">
                                <label class="admin-form-label" for="perm_FILE_MANAGEMENT">File Management</label>
                            </div>
                        </div>
                        <div class="admin-form-check">
                            <input type="checkbox" class="admin-form-check-input" id="adminIsActive" checked>
                            <label class="admin-form-label" for="adminIsActive">Active</label>
                        </div>
                    </form>
                </div>
                <div class="admin-modal-footer">
                    <button type="button" class="admin-btn admin-btn-secondary" onclick="closeModal('editAdminModal')">Cancel</button>
                    <button type="button" class="admin-btn admin-btn-primary" onclick="saveAdministrator()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Initialize alerts object with translations
        const alerts = <cfoutput>#serializeJSON(alerts)#</cfoutput>;
        let currentCompanyID = null;
        let editingAdminID = null;

        document.addEventListener('DOMContentLoaded', function() {
            loadCompanies();
        });

        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('show');
        }

        function viewCompanyDetails(companyID) {
            fetch(`../api/company.cfc?method=getCompanyDetails&companyID=${encodeURIComponent(companyID)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const company = data.data;
                        document.getElementById('companyID').value = company.companyID;
                        document.getElementById('name').value = company.name;
                        document.getElementById('taxNumber').value = company.taxNumber;
                        document.getElementById('email').value = company.email;
                        document.getElementById('phone').value = company.phone;
                        document.getElementById('address').value = company.address;
                        document.getElementById('website').value = company.website || '';
                        document.getElementById('status').value = company.statusID;
                        document.getElementById('applicationDate').textContent = formatDate(company.applicationDate);
                        document.getElementById('approvalDate').textContent = company.approvalDate ? formatDate(company.approvalDate) : 'Not approved';
                        document.getElementById('lastModified').textContent = company.lastModifiedDate ? 
                            `${formatDate(company.lastModifiedDate)} by ${company.modifiedByFirstName} ${company.modifiedByLastName}` : 
                            'Never modified';
                        
                        // Get SSO configuration
                        fetch(`../api/sso.cfc?method=getSSOConfig&companyID=${encodeURIComponent(companyID)}`)
                            .then(response => response.json())
                            .then(ssoData => {
                                if (ssoData.success) {
                                    const ssoConfig = ssoData.data;
                                    document.getElementById('ssoEnabled').checked = ssoConfig.ssoEnabled;
                                    document.getElementById('ssoProvider').value = ssoConfig.ssoProvider || '';
                                    document.getElementById('ssoDomain').value = ssoConfig.ssoDomain || '';
                                    document.getElementById('ssoClientID').value = ssoConfig.ssoClientID || '';
                                    document.getElementById('ssoClientSecret').value = ssoConfig.ssoClientSecret || '';
                                    document.getElementById('ssoMetadataURL').value = ssoConfig.ssoMetadataURL || '';
                                    toggleSSOFields();
                                }
                            });

                        const modal = new bootstrap.Modal(document.getElementById('companyModal'));
                        modal.show();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while fetching company details');
                });
        }

        function toggleSSOFields() {
            const ssoEnabled = document.getElementById('ssoEnabled').checked;
            const ssoFields = document.getElementById('ssoFields');
            const ssoProvider = document.getElementById('ssoProvider');
            
            ssoFields.style.display = ssoEnabled ? 'block' : 'none';
            ssoProvider.required = ssoEnabled;
            
            const fields = ['ssoDomain', 'ssoClientID', 'ssoClientSecret'];
            fields.forEach(field => {
                document.getElementById(field).required = ssoEnabled;
            });
        }

        function saveCompany() {
            const formData = {
                companyID: document.getElementById('companyID').value,
                name: document.getElementById('name').value,
                taxNumber: document.getElementById('taxNumber').value,
                email: document.getElementById('email').value,
                phone: document.getElementById('phone').value,
                address: document.getElementById('address').value,
                website: document.getElementById('website').value,
                statusID: document.getElementById('status').value,
                ssoEnabled: document.getElementById('ssoEnabled').checked,
                ssoProvider: document.getElementById('ssoProvider').value,
                ssoDomain: document.getElementById('ssoDomain').value,
                ssoClientID: document.getElementById('ssoClientID').value,
                ssoClientSecret: document.getElementById('ssoClientSecret').value,
                ssoMetadataURL: document.getElementById('ssoMetadataURL').value
            };

            // Save company details
            fetch('../api/company.cfc?method=updateCompany', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update SSO configuration
                    return fetch('../api/sso.cfc?method=updateSSOConfig', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(formData)
                    });
                }
                throw new Error(data.message);
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const modal = bootstrap.Modal.getInstance(document.getElementById('companyModal'));
                    modal.hide();
                    loadCompanies();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while saving company details');
            });
        }

        // Add event listener for SSO toggle
        document.getElementById('ssoEnabled').addEventListener('change', toggleSSOFields);
        document.getElementById('ssoProvider').addEventListener('change', function() {
            const metadataField = document.getElementById('ssoMetadataURL');
            metadataField.required = this.value === 'SAML';
        });

        function viewAdministrators(companyID) {
            currentCompanyID = companyID;
            fetch(`../api/company.cfc?method=getCompanyAdministrators&companyID=${encodeURIComponent(companyID)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const tbody = document.getElementById('adminsBody');
                        tbody.innerHTML = '';
                        
                        data.data.forEach(admin => {
                            const row = document.createElement('tr');
                            row.innerHTML = `
                                <td>${admin.firstName} ${admin.lastName}</td>
                                <td>${admin.email}</td>
                                <td>
                                    <span class="admin-badge ${admin.isActive ? 'admin-badge-success' : 'admin-badge-danger'}">
                                        ${admin.isActive ? 'Active' : 'Inactive'}
                                    </span>
                                </td>
                                <td>${formatPermissions(admin.permissions)}</td>
                                <td>
                                    <button class="admin-btn admin-btn-primary admin-btn-sm" onclick="editAdministrator('${admin.userID}')">
                                        <i class="bi bi-pencil admin-icon"></i>
                                    </button>
                                </td>
                            `;
                            tbody.appendChild(row);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error loading administrators:', error);
                });
        }

        function showAddAdminModal() {
            editingAdminID = null;
            document.getElementById('adminUser').value = '';
            document.getElementById('adminIsActive').checked = true;
            document.querySelectorAll('[id^="perm_"]').forEach(checkbox => checkbox.checked = false);
            document.getElementById('editAdminModal').classList.add('show');
        }

        async function editAdministrator(userID) {
            editingAdminID = userID;
            // Load administrator details and populate form
            document.getElementById('editAdminModal').classList.add('show');
        }

        async function saveAdministrator() {
            const permissions = [];
            document.querySelectorAll('[id^="perm_"]').forEach(checkbox => {
                if (checkbox.checked) {
                    permissions.push(checkbox.id.replace('perm_', ''));
                }
            });
            
            try {
                const response = await fetch('../api/company.cfc?method=updateCompanyAdministrator', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        companyID: currentCompanyID,
                        userID: editingAdminID || document.getElementById('adminUser').value,
                        permissions: permissions,
                        isActive: document.getElementById('adminIsActive').checked
                    })
                });
                
                const data = await response.json();
                if (data.success) {
                    closeModal('editAdminModal');
                    loadAdministrators();
                    alert(alerts['alert.admin.update.success']);
                } else {
                    alert(data.message || alerts['alert.error.generic']);
                }
            } catch (error) {
                console.error('Error saving administrator:', error);
                alert(alerts['alert.error.generic']);
            }
        }

        function getStatusBadgeClass(status) {
            switch (status) {
                case 'APPROVED': return 'admin-badge-success';
                case 'PENDING': return 'admin-badge-warning';
                case 'SUSPENDED': return 'admin-badge-danger';
                case 'REJECTED': return 'admin-badge-danger';
                default: return '';
            }
        }

        function formatDate(dateString) {
            return new Date(dateString).toLocaleString();
        }

        function formatPermissions(permissions) {
            if (!permissions) return 'None';
            return permissions.split(',').map(p => p.replace('_', ' ')).join(', ');
        }

        function loadCompanies() {
            fetch('../api/company.cfc?method=getAllCompanies')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const tbody = document.getElementById('companiesBody');
                        tbody.innerHTML = '';
                        
                        data.data.forEach(company => {
                            const row = document.createElement('tr');
                            row.innerHTML = `
                                <td>${company.name}</td>
                                <td>${company.taxNumber}</td>
                                <td>${company.email}</td>
                                <td>
                                    <span class="admin-badge ${getStatusBadgeClass(company.statusName)}">
                                        ${company.statusName}
                                    </span>
                                </td>
                                <td>${formatDate(company.applicationDate)}</td>
                                <td>
                                    <button class="admin-btn admin-btn-primary admin-btn-sm" onclick="viewCompanyDetails('${company.companyID}')">
                                        <i class="bi bi-pencil admin-icon"></i>
                                    </button>
                                    <button class="admin-btn admin-btn-secondary admin-btn-sm" onclick="viewAdministrators('${company.companyID}')">
                                        <i class="bi bi-people admin-icon"></i>
                                    </button>
                                </td>
                            `;
                            tbody.appendChild(row);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error loading companies:', error);
                });
        }
    </script>
</body>
</html> 