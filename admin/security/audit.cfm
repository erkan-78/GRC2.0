<!DOCTYPE html>
<html>
<head>
    <title>Permission Audit Log</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Permission Audit Log</h2>
            <div>
                <a href="index.cfm?page=roles" class="btn btn-secondary me-2">Manage Roles</a>
                <a href="index.cfm?page=permissions" class="btn btn-secondary">Manage Permissions</a>
            </div>
        </div>

        <!--- Filters --->
        <div class="card mb-4">
            <div class="card-body">
                <form action="index.cfm" method="get" class="row g-3">
                    <input type="hidden" name="page" value="audit">
                    
                    <div class="col-md-3">
                        <label for="dateRange" class="form-label">Date Range:</label>
                        <input type="text" class="form-control" id="dateRange" name="dateRange">
                    </div>
                    
                    <div class="col-md-3">
                        <label for="userID" class="form-label">User:</label>
                        <select name="userID" id="userID" class="form-control">
                            <option value="">All Users</option>
                            <cfoutput query="getUsers">
                                <option value="#userID#">#firstName# #lastName#</option>
                            </cfoutput>
                        </select>
                    </div>
                    
                    <div class="col-md-3">
                        <label for="permissionName" class="form-label">Permission:</label>
                        <select name="permissionName" id="permissionName" class="form-control">
                            <option value="">All Permissions</option>
                            <cfoutput query="getPermissions">
                                <option value="#permissionName#">#permissionName#</option>
                            </cfoutput>
                        </select>
                    </div>
                    
                    <div class="col-md-2">
                        <label for="granted" class="form-label">Result:</label>
                        <select name="granted" id="granted" class="form-control">
                            <option value="">All</option>
                            <option value="1">Granted</option>
                            <option value="0">Denied</option>
                        </select>
                    </div>
                    
                    <div class="col-md-1">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-primary w-100">Filter</button>
                    </div>
                </form>
            </div>
        </div>

        <!--- Audit Log Table --->
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>User</th>
                        <th>Permission</th>
                        <th>Result</th>
                        <th>IP Address</th>
                        <th>Request Path</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getAuditLog">
                        <tr>
                            <td>#dateTimeFormat(timestamp, "yyyy-mm-dd HH:nn:ss")#</td>
                            <td>#firstName# #lastName#</td>
                            <td>#permissionName#</td>
                            <td>
                                <span class="badge bg-#granted ? 'success' : 'danger'#">
                                    #granted ? 'Granted' : 'Denied'#
                                </span>
                            </td>
                            <td>#ipAddress#</td>
                            <td>#requestPath#</td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <!--- Pagination --->
        <cfif getAuditLog.recordCount GT 0>
            <div class="d-flex justify-content-between align-items-center mt-4">
                <div>
                    Showing #((page-1)*pageSize)+1# to #min(page*pageSize, getAuditLog.recordCount)# of #totalRecords# entries
                </div>
                <nav>
                    <ul class="pagination">
                        <cfloop from="1" to="#ceiling(totalRecords/pageSize)#" index="i">
                            <li class="page-item #i eq page ? 'active' : ''#">
                                <a class="page-link" href="index.cfm?page=audit&p=#i#">#i#</a>
                            </li>
                        </cfloop>
                    </ul>
                </nav>
            </div>
        </cfif>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#dateRange').daterangepicker({
                ranges: {
                    'Today': [moment(), moment()],
                    'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                    'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                    'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                    'This Month': [moment().startOf('month'), moment().endOf('month')],
                    'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
                },
                startDate: moment().subtract(29, 'days'),
                endDate: moment()
            });
        });
    </script>
</body>
</html> 