<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('policy_approval', 'Policy Approval')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <cfset policyService = new model.PolicyService()>
    <cfset pendingPolicies = policyService.getPendingApprovals(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><cfoutput>#getLabel('policy_approval_dashboard', 'Policy Approval Dashboard')#</cfoutput></h2>
        </div>

        <!--- Approval Statistics --->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('pending_approvals', 'Pending Approvals')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#pendingPolicies.recordCount#</cfoutput></h2>
                            <i class="fas fa-clock fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('approved_this_month', 'Approved This Month')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#getApprovedCount()#</cfoutput></h2>
                            <i class="fas fa-check-circle fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-danger text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('rejected_this_month', 'Rejected This Month')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#getRejectedCount()#</cfoutput></h2>
                            <i class="fas fa-times-circle fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-info text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('avg_approval_time', 'Avg. Approval Time')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#getAverageApprovalTime()#</cfoutput></h2>
                            <i class="fas fa-hourglass-half fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Pending Approvals Table --->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><cfoutput>#getLabel('pending_approvals', 'Pending Approvals')#</cfoutput></h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th><cfoutput>#getLabel('title', 'Title')#</cfoutput></th>
                                <th><cfoutput>#getLabel('type', 'Type')#</cfoutput></th>
                                <th><cfoutput>#getLabel('category', 'Category')#</cfoutput></th>
                                <th><cfoutput>#getLabel('owner', 'Owner')#</cfoutput></th>
                                <th><cfoutput>#getLabel('submitted_date', 'Submitted Date')#</cfoutput></th>
                                <th><cfoutput>#getLabel('version', 'Version')#</cfoutput></th>
                                <th><cfoutput>#getLabel('actions', 'Actions')#</cfoutput></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="pendingPolicies">
                                <tr>
                                    <td>#title#</td>
                                    <td>#getLabel('type_' & type, type)#</td>
                                    <td>#categoryName#</td>
                                    <td>#ownerName#</td>
                                    <td>#dateFormat(submissionDate, "yyyy-mm-dd")#</td>
                                    <td>v#version#</td>
                                    <td>
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-sm btn-primary" 
                                                    onclick="viewPolicy(#policyID#, #version#)"
                                                    title="#getLabel('view_policy', 'View Policy')#">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-success" 
                                                    onclick="approvePolicy(#policyID#, #version#)"
                                                    title="#getLabel('approve', 'Approve')#">
                                                <i class="fas fa-check"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-danger" 
                                                    onclick="rejectPolicy(#policyID#, #version#)"
                                                    title="#getLabel('reject', 'Reject')#">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!--- Approval Modal --->
    <div class="modal fade" id="approvalModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><cfoutput>#getLabel('approve_policy', 'Approve Policy')#</cfoutput></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="approvalForm">
                        <input type="hidden" name="policyID" id="approvalPolicyID">
                        <input type="hidden" name="version" id="approvalVersion">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('approval_comments', 'Approval Comments')#</cfoutput></label>
                            <textarea class="form-control" name="comments" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <cfoutput>#getLabel('cancel', 'Cancel')#</cfoutput>
                    </button>
                    <button type="button" class="btn btn-success" onclick="submitApproval()">
                        <cfoutput>#getLabel('approve', 'Approve')#</cfoutput>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!--- Rejection Modal --->
    <div class="modal fade" id="rejectionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><cfoutput>#getLabel('reject_policy', 'Reject Policy')#</cfoutput></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="rejectionForm">
                        <input type="hidden" name="policyID" id="rejectionPolicyID">
                        <input type="hidden" name="version" id="rejectionVersion">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('rejection_reason', 'Rejection Reason')#</cfoutput></label>
                            <textarea class="form-control" name="reason" rows="3" required></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <cfoutput>#getLabel('cancel', 'Cancel')#</cfoutput>
                    </button>
                    <button type="button" class="btn btn-danger" onclick="submitRejection()">
                        <cfoutput>#getLabel('reject', 'Reject')#</cfoutput>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function viewPolicy(policyID, version) {
            window.location.href = `view.cfm?id=${policyID}&version=${version}`;
        }

        function approvePolicy(policyID, version) {
            $('#approvalPolicyID').val(policyID);
            $('#approvalVersion').val(version);
            $('#approvalModal').modal('show');
        }

        function rejectPolicy(policyID, version) {
            $('#rejectionPolicyID').val(policyID);
            $('#rejectionVersion').val(version);
            $('#rejectionModal').modal('show');
        }

        function submitApproval() {
            $.post('/api/policy/approve', $('#approvalForm').serialize(), function(response) {
                if (response.success) {
                    location.reload();
                } else {
                    alert(response.message);
                }
            });
        }

        function submitRejection() {
            $.post('/api/policy/reject', $('#rejectionForm').serialize(), function(response) {
                if (response.success) {
                    location.reload();
                } else {
                    alert(response.message);
                }
            });
        }
    </script>
</body>
</html> 