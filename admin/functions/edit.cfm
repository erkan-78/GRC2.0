<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#functionID GT 0 ? "Edit" : "Add"#</cfoutput> Business Function</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><cfoutput>#functionID GT 0 ? "Edit" : "Add"#</cfoutput> Business Function</h2>
            <div>
                <a href="index.cfm" class="btn btn-secondary">Back to List</a>
            </div>
        </div>

        <cfif structKeyExists(variables, "function") && function.approvalStatus neq "approved">
            <div class="alert alert-warning mb-4">
                <h5>Approval Status: <cfoutput>#uCase(function.approvalStatus)#</cfoutput></h5>
                <cfif function.approvalStatus eq "rejected" && len(function.rejectionReason)>
                    <p class="mb-0">Rejection Reason: <cfoutput>#function.rejectionReason#</cfoutput></p>
                </cfif>
            </div>
        </cfif>

        <div class="card">
            <div class="card-body">
                <form action="/api/functions/save" method="post" id="functionForm">
                    <input type="hidden" name="functionID" value="<cfoutput>#functionID#</cfoutput>">
                    
                    <cfif !isCompanyAdmin>
                        <div class="mb-3">
                            <label for="companyID" class="form-label">Company:</label>
                            <select name="companyID" id="companyID" class="form-control" required>
                                <option value="">Select Company</option>
                                <cfoutput query="getCompanies">
                                    <option value="#companyID#" 
                                            <cfif structKeyExists(variables, "function") && function.companyID eq companyID>selected</cfif>>
                                        #companyName#
                                    </option>
                                </cfoutput>
                            </select>
                        </div>
                    <cfelse>
                        <input type="hidden" name="companyID" value="<cfoutput>#session.companyID#</cfoutput>">
                    </cfif>

                    <div class="mb-3">
                        <label for="title" class="form-label">Title:</label>
                        <input type="text" 
                               class="form-control" 
                               id="title" 
                               name="title" 
                               value="<cfoutput>#structKeyExists(variables, "function") ? function.title : ""#</cfoutput>" 
                               required>
                    </div>

                    <div class="mb-3">
                        <label for="description" class="form-label">Description:</label>
                        <textarea class="form-control" 
                                  id="description" 
                                  name="description" 
                                  rows="5"><cfoutput>#structKeyExists(variables, "function") ? function.description : ""#</cfoutput></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="status" class="form-label">Status:</label>
                        <select name="status" id="status" class="form-control" required>
                            <option value="enabled" <cfif structKeyExists(variables, "function") && function.status eq "enabled">selected</cfif>>Enabled</option>
                            <option value="disabled" <cfif structKeyExists(variables, "function") && function.status eq "disabled">selected</cfif>>Disabled</option>
                        </select>
                    </div>

                    <cfif securityService.hasPermission("functions.approve") && structKeyExists(variables, "function")>
                        <div class="mb-3">
                            <label for="approvalStatus" class="form-label">Approval Status:</label>
                            <select name="approvalStatus" id="approvalStatus" class="form-control">
                                <option value="pending" <cfif function.approvalStatus eq "pending">selected</cfif>>Pending</option>
                                <option value="approved" <cfif function.approvalStatus eq "approved">selected</cfif>>Approved</option>
                                <option value="rejected" <cfif function.approvalStatus eq "rejected">selected</cfif>>Rejected</option>
                            </select>
                        </div>

                        <div id="rejectionReasonDiv" class="mb-3" style="display: none;">
                            <label for="rejectionReason" class="form-label">Rejection Reason:</label>
                            <textarea class="form-control" 
                                      id="rejectionReason" 
                                      name="rejectionReason" 
                                      rows="3"><cfoutput>#function.rejectionReason ?: ""#</cfoutput></textarea>
                        </div>
                    </cfif>

                    <div class="text-end">
                        <button type="submit" class="btn btn-primary">Save Function</button>
                    </div>
                </form>
            </div>
        </div>

        <cfif structKeyExists(variables, "function")>
            <div class="card mt-4">
                <div class="card-header">
                    <h5 class="mb-0">Approval History</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Requested By</th>
                                    <th>Approved/Rejected By</th>
                                    <th>Comments</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput query="getApprovalHistory">
                                    <tr>
                                        <td>#dateTimeFormat(created, "yyyy-mm-dd HH:nn:ss")#</td>
                                        <td>
                                            <span class="badge bg-#status eq 'approved' ? 'success' : (status eq 'rejected' ? 'danger' : 'warning')#">
                                                #uCase(status)#
                                            </span>
                                        </td>
                                        <td>#requestedByName#</td>
                                        <td>#approvedByName#</td>
                                        <td>#comments#</td>
                                    </tr>
                                </cfoutput>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </cfif>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#approvalStatus').change(function() {
                if ($(this).val() === 'rejected') {
                    $('#rejectionReasonDiv').show();
                    $('#rejectionReason').prop('required', true);
                } else {
                    $('#rejectionReasonDiv').hide();
                    $('#rejectionReason').prop('required', false);
                }
            });

            // Trigger initial state
            $('#approvalStatus').trigger('change');

            $('#functionForm').on('submit', function(e) {
                e.preventDefault();
                
                $.post($(this).attr('action'), $(this).serialize(), function(response) {
                    if (response.success) {
                        window.location.href = 'index.cfm';
                    } else {
                        alert(response.message);
                    }
                });
            });
        });
    </script>
</body>
</html> 