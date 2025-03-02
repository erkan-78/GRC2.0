<!DOCTYPE html>
<html>
<head>
    <title>Function Activity Log</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Activity Log: <cfoutput>#function.title#</cfoutput></h2>
            <div>
                <a href="index.cfm" class="btn btn-secondary">Back to List</a>
            </div>
        </div>

        <!--- Function Details --->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <h5>Function Details</h5>
                        <table class="table table-sm">
                            <tr>
                                <th>Title:</th>
                                <td><cfoutput>#function.title#</cfoutput></td>
                            </tr>
                            <tr>
                                <th>Company:</th>
                                <td><cfoutput>#function.companyName#</cfoutput></td>
                            </tr>
                            <tr>
                                <th>Status:</th>
                                <td>
                                    <cfoutput>
                                        <span class="badge bg-#function.status eq 'enabled' ? 'success' : 'danger'#">
                                            #function.status#
                                        </span>
                                    </cfoutput>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h5>Description</h5>
                        <p><cfoutput>#function.description#</cfoutput></p>
                    </div>
                </div>
            </div>
        </div>

        <!--- Activity Log Table --->
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Date/Time</th>
                        <th>User</th>
                        <th>Action</th>
                        <th>Details</th>
                        <th>IP Address</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getActivityLog">
                        <tr>
                            <td>#dateTimeFormat(created, "yyyy-mm-dd HH:nn:ss")#</td>
                            <td>#firstName# #lastName#</td>
                            <td>
                                <span class="badge bg-#action eq 'created' ? 'success' : 
                                                (action eq 'updated' ? 'primary' : 
                                                (action eq 'enabled' ? 'info' : 'warning'))#">
                                    #action#
                                </span>
                            </td>
                            <td>#details#</td>
                            <td>#ipAddress#</td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <!--- Pagination --->
        <cfif getActivityLog.recordCount GT 0>
            <div class="d-flex justify-content-between align-items-center mt-4">
                <div>
                    Showing #((currentPage-1)*pageSize)+1# to #min(currentPage*pageSize, totalRecords)# of #totalRecords# activities
                </div>
                <nav>
                    <ul class="pagination">
                        <cfloop from="1" to="#ceiling(totalRecords/pageSize)#" index="i">
                            <li class="page-item #i eq currentPage ? 'active' : ''#">
                                <a class="page-link" href="index.cfm?page=activity&id=#functionID#&p=#i#">#i#</a>
                            </li>
                        </cfloop>
                    </ul>
                </nav>
            </div>
        </cfif>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 