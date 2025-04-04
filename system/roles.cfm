<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Role Management</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <cfinclude template="../includes/menu.cfm">

    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Role Management</h5>
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#roleModal">
                            <i class="bi bi-plus-circle"></i> Create Role
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Role Name</th>
                                        <th>Description</th>
                                        <th>Type</th>
                                        <th>Company</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfset rolesService = new api.roles.index()>
                                    <cfset rolesResult = rolesService.getRoles()>
                                    
                                    <cfif rolesResult.success>
                                        <cfloop array="#rolesResult.data#" index="role">
                                            <tr>
                                                <td>#role.roleName#</td>
                                                <td>#role.description#</td>
                                                <td>
                                                    <cfif role.isSystem>
                                                        <span class="badge bg-primary">System</span>
                                                    <cfelse>
                                                        <span class="badge bg-secondary">Custom</span>
                                                    </cfif>
                                                </td>
                                                <td>
                                                    <cfif role.companyID>
                                                        <cfset companyService = new api.company.index()>
                                                        <cfset companyResult = companyService.getCompany(role.companyID)>
                                                        <cfif companyResult.success>
                                                            #companyResult.data.companyName#
                                                        </cfif>
                                                    <cfelse>
                                                        <span class="text-muted">Global</span>
                                                    </cfif>
                                                </td>
                                                <td>
                                                    <cfif role.isActive>
                                                        <span class="badge bg-success">Active</span>
                                                    <cfelse>
                                                        <span class="badge bg-danger">Inactive</span>
                                                    </cfif>
                                                </td>
                                                <td>
                                                    <div class="btn-group">
                                                        <button type="button" class="btn btn-sm btn-outline-primary" 
                                                                onclick="editRole(#role.roleID#)"
                                                                <cfif role.isSystem>disabled</cfif>>
                                                            <i class="bi bi-pencil"></i>
                                                        </button>
                                                        <button type="button" class="btn btn-sm btn-outline-danger"
                                                                onclick="deleteRole(#role.roleID#)"
                                                                <cfif role.isSystem>disabled</cfif>>
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </cfif>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Role Modal -->
    <div class="modal fade" id="roleModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Role Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="roleForm">
                        <input type="hidden" id="roleID" name="roleID">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Role Name</label>
                                <input type="text" class="form-control" id="roleName" name="roleName" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Company</label>
                                <select class="form-select" id="companyID" name="companyID">
                                    <option value="">Global Role</option>
                                    <cfset companyService = new api.company.index()>
                                    <cfset companiesResult = companyService.getCompanies()>
                                    <cfif companiesResult.success>
                                        <cfloop array="#companiesResult.data#" index="company">
                                            <option value="#company.companyID#">#company.companyName#</option>
                                        </cfloop>
                                    </cfif>
                                </select>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Translations</label>
                            <div id="translationsContainer">
                                <cfset languageService = new api.language.index()>
                                <cfset languagesResult = languageService.getLanguages()>
                                <cfif languagesResult.success>
                                    <cfloop array="#languagesResult.data#" index="language">
                                        <div class="mb-2">
                                            <label class="form-label">#language.languageName#</label>
                                            <input type="text" class="form-control" 
                                                   name="translations[#language.languageID#]" 
                                                   placeholder="Description in #language.languageName#">
                                        </div>
                                    </cfloop>
                                </cfif>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Permissions</label>
                            <div class="row">
                                <cfset permissionsService = new api.permissions.index()>
                                <cfset permissionsResult = permissionsService.getPermissions()>
                                <cfif permissionsResult.success>
                                    <cfloop array="#permissionsResult.data#" index="permission">
                                        <div class="col-md-6 mb-2">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" 
                                                       name="permissions[]" 
                                                       value="#permission.permissionID#"
                                                       id="permission_#permission.permissionID#">
                                                <label class="form-check-label" for="permission_#permission.permissionID#">
                                                    #permission.description#
                                                </label>
                                            </div>
                                        </div>
                                    </cfloop>
                                </cfif>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveRole()">Save Role</button>
                </div>
            </div>
        </div>
    </div>

    <script src="assets/js/bootstrap.bundle.min.js"></script>
    <script>
        let roleModal;
        let rolesService = new api.roles.index();

        document.addEventListener('DOMContentLoaded', function() {
            roleModal = new bootstrap.Modal(document.getElementById('roleModal'));
        });

        function editRole(roleID) {
            rolesService.getRole(roleID).then(function(result) {
                if (result.success) {
                    const role = result.data;
                    document.getElementById('roleID').value = role.roleID;
                    document.getElementById('roleName').value = role.roleName;
                    document.getElementById('companyID').value = role.companyID || '';
                    document.getElementById('description').value = role.description;

                    // Set translations
                    if (role.translations) {
                        Object.keys(role.translations).forEach(function(languageID) {
                            const input = document.querySelector(`input[name="translations[${languageID}]"]`);
                            if (input) {
                                input.value = role.translations[languageID].description;
                            }
                        });
                    }

                    // Set permissions
                    document.querySelectorAll('input[name="permissions[]"]').forEach(function(checkbox) {
                        checkbox.checked = role.permissions.some(p => p.permissionID == checkbox.value);
                    });

                    roleModal.show();
                }
            });
        }

        function saveRole() {
            const form = document.getElementById('roleForm');
            const formData = new FormData(form);
            const roleData = {
                roleName: formData.get('roleName'),
                description: formData.get('description'),
                companyID: formData.get('companyID') || null,
                isActive: true,
                translations: [],
                permissions: []
            };

            // Collect translations
            document.querySelectorAll('input[name^="translations["]').forEach(function(input) {
                const languageID = input.name.match(/\[(\d+)\]/)[1];
                if (input.value) {
                    roleData.translations.push({
                        languageID: parseInt(languageID),
                        description: input.value
                    });
                }
            });

            // Collect permissions
            document.querySelectorAll('input[name="permissions[]"]:checked').forEach(function(checkbox) {
                roleData.permissions.push(parseInt(checkbox.value));
            });

            const roleID = formData.get('roleID');
            const promise = roleID ? 
                rolesService.updateRole(parseInt(roleID), roleData) : 
                rolesService.createRole(roleData);

            promise.then(function(result) {
                if (result.success) {
                    roleModal.hide();
                    location.reload();
                } else {
                    alert(result.message);
                }
            });
        }

        function deleteRole(roleID) {
            if (confirm('Are you sure you want to delete this role?')) {
                rolesService.deleteRole(roleID).then(function(result) {
                    if (result.success) {
                        location.reload();
                    } else {
                        alert(result.message);
                    }
                });
            }
        }
    </script>
</body>
</html> 