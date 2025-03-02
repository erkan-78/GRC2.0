<!DOCTYPE html>
<html>
<head>
    <title>Manage Roles</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Role Management</h2>
            <div>
                <a href="index.cfm?page=permissions" class="btn btn-secondary me-2">Manage Permissions</a>
                <a href="index.cfm?page=audit" class="btn btn-info me-2">View Audit Log</a>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#roleModal">
                    Add New Role
                </button>
            </div>
        </div>

        <!--- Roles List --->
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Role Name</th>
                        <th>Description</th>
                        <th>Users</th>
                        <th>Permissions</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getRoles">
                        <tr>
                            <td>#roleName#</td>
                            <td>#description#</td>
                            <td>#userCount#</td>
                            <td>#permissionCount#</td>
                            <td>
                                <button class="btn btn-sm btn-primary edit-role" 
                                        data-id="#roleID#"
                                        data-name="#roleName#"
                                        data-description="#description#">
                                    Edit
                                </button>
                                <button class="btn btn-sm btn-info manage-permissions" 
                                        data-id="#roleID#"
                                        data-name="#roleName#">
                                    Permissions
                                </button>
                                <button class="btn btn-sm btn-danger delete-role" 
                                        data-id="#roleID#">
                                    Delete
                                </button>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
    </div>

    <!--- Role Modal --->
    <div class="modal fade" id="roleModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="/api/security/saveRole" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title">Role</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="roleID" id="roleID">
                        <div class="mb-3">
                            <label for="roleName" class="form-label">Role Name:</label>
                            <input type="text" class="form-control" id="roleName" name="roleName" required>
                        </div>
                        <div class="mb-3">
                            <label for="description" class="form-label">Description:</label>
                            <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Save Role</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!--- Permissions Modal --->
    <div class="modal fade" id="permissionsModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="/api/security/saveRolePermissions" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title">Role Permissions</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="roleID" id="permRoleID">
                        <div class="mb-3">
                            <label for="permissions" class="form-label">Select Permissions:</label>
                            <select name="permissions" id="permissions" class="form-control select2" multiple>
                                <cfoutput query="getAllPermissions">
                                    <option value="#permissionID#">#permissionName# - #description#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Save Permissions</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        $(document).ready(function() {
            $('.select2').select2();

            $('.edit-role').click(function() {
                $('#roleID').val($(this).data('id'));
                $('#roleName').val($(this).data('name'));
                $('#description').val($(this).data('description'));
                $('#roleModal').modal('show');
            });

            $('.manage-permissions').click(function() {
                const roleID = $(this).data('id');
                $('#permRoleID').val(roleID);
                
                // Load current permissions
                $.get('/api/security/getRolePermissions', { roleID: roleID }, function(data) {
                    $('#permissions').val(data.permissions).trigger('change');
                    $('#permissionsModal').modal('show');
                });
            });

            $('.delete-role').click(function() {
                if (confirm('Are you sure you want to delete this role?')) {
                    const roleID = $(this).data('id');
                    $.post('/api/security/deleteRole', { roleID: roleID }, function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert(response.message);
                        }
                    });
                }
            });
        });
    </script>
</body>
</html> 