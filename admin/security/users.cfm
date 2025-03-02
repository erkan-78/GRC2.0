<!DOCTYPE html>
<html>
<head>
    <title>User Role Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>User Role Management</h2>
            <div>
                <a href="index.cfm?page=roles" class="btn btn-secondary me-2">Manage Roles</a>
                <a href="index.cfm?page=permissions" class="btn btn-secondary me-2">Manage Permissions</a>
                <a href="index.cfm?page=audit" class="btn btn-info">View Audit Log</a>
            </div>
        </div>

        <!--- Users List --->
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Email</th>
                        <th>Current Roles</th>
                        <th>Last Login</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getUsers">
                        <tr>
                            <td>#firstName# #lastName#</td>
                            <td>#email#</td>
                            <td>#rolesList#</td>
                            <td>#dateTimeFormat(lastLogin, "yyyy-mm-dd HH:nn:ss")#</td>
                            <td>
                                <button class="btn btn-sm btn-primary manage-roles" 
                                        data-id="#userID#"
                                        data-name="#firstName# #lastName#">
                                    Manage Roles
                                </button>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <!--- Pagination --->
        <cfif getUsers.recordCount GT 0>
            <div class="d-flex justify-content-between align-items-center mt-4">
                <div>
                    Showing #((page-1)*pageSize)+1# to #min(page*pageSize, getUsers.recordCount)# of #totalRecords# users
                </div>
                <nav>
                    <ul class="pagination">
                        <cfloop from="1" to="#ceiling(totalRecords/pageSize)#" index="i">
                            <li class="page-item #i eq page ? 'active' : ''#">
                                <a class="page-link" href="index.cfm?page=users&p=#i#">#i#</a>
                            </li>
                        </cfloop>
                    </ul>
                </nav>
            </div>
        </cfif>
    </div>

    <!--- User Roles Modal --->
    <div class="modal fade" id="userRolesModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="/api/security/saveUserRoles" method="post" id="userRolesForm">
                    <div class="modal-header">
                        <h5 class="modal-title">User Roles</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="userID" id="userID">
                        <div class="mb-3">
                            <h4 id="userName" class="text-primary"></h4>
                        </div>
                        <div class="mb-3">
                            <label for="roles" class="form-label">Assigned Roles:</label>
                            <select name="roles" id="roles" class="form-control select2" multiple>
                                <cfoutput query="getAllRoles">
                                    <option value="#roleID#">#roleName# - #description#</option>
                                </cfoutput>
                            </select>
                        </div>
                        <div class="mb-3">
                            <div class="alert alert-info">
                                <h6>Role Information:</h6>
                                <div id="roleInfo">Select roles to see their permissions</div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Save Roles</button>
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
            $('.select2').select2({
                width: '100%'
            });

            $('.manage-roles').click(function() {
                const userID = $(this).data('id');
                const userName = $(this).data('name');
                
                $('#userID').val(userID);
                $('#userName').text(userName);
                
                // Load current roles
                $.get('/api/security/getUserRoles', { userID: userID }, function(data) {
                    if (data.success) {
                        $('#roles').val(data.roles).trigger('change');
                        $('#userRolesModal').modal('show');
                    } else {
                        alert(data.message);
                    }
                });
            });

            // Show role information when selection changes
            $('#roles').on('change', function() {
                const selectedRoles = $(this).find('option:selected');
                let roleInfo = '<ul class="mb-0">';
                
                selectedRoles.each(function() {
                    roleInfo += '<li><strong>' + $(this).text() + '</strong></li>';
                });
                
                roleInfo += '</ul>';
                $('#roleInfo').html(roleInfo);
            });

            // Handle form submission
            $('#userRolesForm').on('submit', function(e) {
                e.preventDefault();
                
                $.post($(this).attr('action'), $(this).serialize(), function(response) {
                    if (response.success) {
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                });
            });
        });
    </script>
</body>
</html> 