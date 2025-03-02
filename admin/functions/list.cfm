<!DOCTYPE html>
<html>
<head>
    <title>Business Functions Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Business Functions</h2>
            <div>
                <a href="index.cfm?page=edit" class="btn btn-primary">Add New Function</a>
            </div>
        </div>

        <!--- Filters --->
        <div class="card mb-4">
            <div class="card-body">
                <form action="index.cfm" method="get" class="row g-3">
                    <div class="col-md-3">
                        <label for="status" class="form-label">Status:</label>
                        <select name="status" id="status" class="form-control">
                            <option value="">All Status</option>
                            <option value="enabled" <cfif url.status eq "enabled">selected</cfif>>Enabled</option>
                            <option value="disabled" <cfif url.status eq "disabled">selected</cfif>>Disabled</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="approvalStatus" class="form-label">Approval Status:</label>
                        <select name="approvalStatus" id="approvalStatus" class="form-control">
                            <option value="">All</option>
                            <option value="pending" <cfif url.approvalStatus eq "pending">selected</cfif>>Pending</option>
                            <option value="approved" <cfif url.approvalStatus eq "approved">selected</cfif>>Approved</option>
                            <option value="rejected" <cfif url.approvalStatus eq "rejected">selected</cfif>>Rejected</option>
                        </select>
                    </div>
                    <cfif !isCompanyAdmin>
                        <div class="col-md-3">
                            <label for="companyID" class="form-label">Company:</label>
                            <select name="companyID" id="companyID" class="form-control">
                                <option value="">All Companies</option>
                                <cfoutput query="getCompanies">
                                    <option value="#companyID#" <cfif url.companyID eq companyID>selected</cfif>>#companyName#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </cfif>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-primary w-100">Filter</button>
                    </div>
                </form>
            </div>
        </div>

        <!--- Functions Table --->
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Title</th>
                        <cfif !isCompanyAdmin>
                            <th>Company</th>
                        </cfif>
                        <th>Description</th>
                        <th>Status</th>
                        <th>Approval Status</th>
                        <th>Last Modified</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getFunctions">
                        <tr>
                            <td>#title#</td>
                            <cfif !isCompanyAdmin>
                                <td>#companyName#</td>
                            </cfif>
                            <td>#left(description, 100)#<cfif len(description) GT 100>...</cfif></td>
                            <td>
                                <span class="badge bg-#status eq 'enabled' ? 'success' : 'danger'#">
                                    #status#
                                </span>
                            </td>
                            <td>
                                <span class="badge bg-#approvalStatus eq 'approved' ? 'success' : (approvalStatus eq 'rejected' ? 'danger' : 'warning')#">
                                    #uCase(approvalStatus)#
                                </span>
                            </td>
                            <td>#dateTimeFormat(modified, "yyyy-mm-dd HH:nn:ss")#</td>
                            <td>
                                <div class="btn-group">
                                    <a href="index.cfm?page=edit&id=#functionID#" 
                                       class="btn btn-sm btn-primary">Edit</a>
                                    <cfif approvalStatus eq "approved">
                                        <button type="button" 
                                                class="btn btn-sm btn-#status eq 'enabled' ? 'warning' : 'success'# toggle-status"
                                                data-id="#functionID#"
                                                data-status="#status#">
                                            #status eq 'enabled' ? 'Disable' : 'Enable'#
                                        </button>
                                    </cfif>
                                    <a href="index.cfm?page=activity&id=#functionID#" 
                                       class="btn btn-sm btn-info">Activity Log</a>
                                </div>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <!--- Pagination --->
        <cfif getFunctions.recordCount GT 0>
            <div class="d-flex justify-content-between align-items-center mt-4">
                <div>
                    Showing #((currentPage-1)*pageSize)+1# to #min(currentPage*pageSize, totalRecords)# of #totalRecords# functions
                </div>
                <nav>
                    <ul class="pagination">
                        <cfloop from="1" to="#ceiling(totalRecords/pageSize)#" index="i">
                            <li class="page-item #i eq currentPage ? 'active' : ''#">
                                <a class="page-link" href="index.cfm?page=list&p=#i#&status=#url.status#&approvalStatus=#url.approvalStatus#">#i#</a>
                            </li>
                        </cfloop>
                    </ul>
                </nav>
            </div>
        </cfif>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            $('.toggle-status').click(function() {
                const functionID = $(this).data('id');
                const currentStatus = $(this).data('status');
                const newStatus = currentStatus === 'enabled' ? 'disabled' : 'enabled';
                
                if (confirm('Are you sure you want to ' + (currentStatus === 'enabled' ? 'disable' : 'enable') + ' this function?')) {
                    $.post('/api/functions/toggleStatus', {
                        functionID: functionID,
                        status: newStatus
                    }, function(response) {
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