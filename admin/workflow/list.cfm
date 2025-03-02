<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('workflows', 'Workflows')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <cfset workflowService = new model.WorkflowService()>
    <cfset workflows = workflowService.getWorkflows(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><cfoutput>#getLabel('workflows', 'Workflows')#</cfoutput></h2>
            <button type="button" class="btn btn-primary" onclick="location.href='designer.cfm'">
                <i class="fas fa-plus"></i> <cfoutput>#getLabel('new_workflow', 'New Workflow')#</cfoutput>
            </button>
        </div>

        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th><cfoutput>#getLabel('title', 'Title')#</cfoutput></th>
                                <th><cfoutput>#getLabel('created_by', 'Created By')#</cfoutput></th>
                                <th><cfoutput>#getLabel('created_date', 'Created Date')#</cfoutput></th>
                                <th><cfoutput>#getLabel('current_version', 'Current Version')#</cfoutput></th>
                                <th><cfoutput>#getLabel('status', 'Status')#</cfoutput></th>
                                <th><cfoutput>#getLabel('actions', 'Actions')#</cfoutput></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="workflows">
                                <tr>
                                    <td>#title#</td>
                                    <td>#createdByName#</td>
                                    <td>#dateFormat(createdDate, "yyyy-mm-dd")#</td>
                                    <td>v#currentVersion#</td>
                                    <td>
                                        <span class="badge bg-#status eq 'approved' ? 'success' :
                                                    (status eq 'draft' ? 'warning' : 'danger')#">
                                            #getLabel('status_' & status, status)#
                                        </span>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-sm btn-primary" 
                                                    onclick="location.href='designer.cfm?id=#workflowID#'"
                                                    title="#getLabel('edit', 'Edit')#">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-info" 
                                                    onclick="viewVersions(#workflowID#)"
                                                    title="#getLabel('versions', 'Versions')#">
                                                <i class="fas fa-history"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-danger" 
                                                    onclick="deleteWorkflow(#workflowID#)"
                                                    title="#getLabel('delete', 'Delete')#">
                                                <i class="fas fa-trash"></i>
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

    <!-- Versions Modal -->
    <div class="modal fade" id="versionsModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><cfoutput>#getLabel('workflow_versions', 'Workflow Versions')#</cfoutput></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="table-responsive">
                        <table class="table table-striped" id="versionsTable">
                            <thead>
                                <tr>
                                    <th><cfoutput>#getLabel('version', 'Version')#</cfoutput></th>
                                    <th><cfoutput>#getLabel('status', 'Status')#</cfoutput></th>
                                    <th><cfoutput>#getLabel('created_by', 'Created By')#</cfoutput></th>
                                    <th><cfoutput>#getLabel('created_date', 'Created Date')#</cfoutput></th>
                                    <th><cfoutput>#getLabel('approved_by', 'Approved By')#</cfoutput></th>
                                    <th><cfoutput>#getLabel('approval_date', 'Approval Date')#</cfoutput></th>
                                    <th><cfoutput>#getLabel('actions', 'Actions')#</cfoutput></th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Approval Modal -->
    <div class="modal fade" id="approvalModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><cfoutput>#getLabel('approve_workflow', 'Approve Workflow')#</cfoutput></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="approvalForm">
                        <input type="hidden" name="workflowID" id="approvalWorkflowID">
                        <input type="hidden" name="version" id="approvalVersion">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('comments', 'Comments')#</cfoutput></label>
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

    <!-- Rejection Modal -->
    <div class="modal fade" id="rejectionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><cfoutput>#getLabel('reject_workflow', 'Reject Workflow')#</cfoutput></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="rejectionForm">
                        <input type="hidden" name="workflowID" id="rejectionWorkflowID">
                        <input type="hidden" name="version" id="rejectionVersion">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('reason', 'Reason')#</cfoutput></label>
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
        function viewVersions(workflowID) {
            $.get(`/api/workflow/versions?id=${workflowID}`, function(versions) {
                const tbody = $('#versionsTable tbody');
                tbody.empty();
                
                versions.forEach(version => {
                    const row = `
                        <tr>
                            <td>v${version.version}</td>
                            <td>
                                <span class="badge bg-${version.status === 'approved' ? 'success' :
                                            (version.status === 'draft' ? 'warning' : 'danger')}">
                                    ${getLabel('status_' + version.status, version.status)}
                                </span>
                            </td>
                            <td>${version.createdByName}</td>
                            <td>${new Date(version.createdDate).toLocaleDateString()}</td>
                            <td>${version.approverName || ''}</td>
                            <td>${version.approvalDate ? new Date(version.approvalDate).toLocaleDateString() : ''}</td>
                            <td>
                                <div class="btn-group">
                                    ${version.status === 'draft' ? `
                                        <button type="button" class="btn btn-sm btn-success" 
                                                onclick="approveVersion(${workflowID}, ${version.version})"
                                                title="${getLabel('approve', 'Approve')}">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-danger" 
                                                onclick="rejectVersion(${workflowID}, ${version.version})"
                                                title="${getLabel('reject', 'Reject')}">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    ` : ''}
                                </div>
                            </td>
                        </tr>
                    `;
                    tbody.append(row);
                });
                
                $('#versionsModal').modal('show');
            });
        }

        function approveVersion(workflowID, version) {
            $('#approvalWorkflowID').val(workflowID);
            $('#approvalVersion').val(version);
            $('#approvalModal').modal('show');
        }

        function rejectVersion(workflowID, version) {
            $('#rejectionWorkflowID').val(workflowID);
            $('#rejectionVersion').val(version);
            $('#rejectionModal').modal('show');
        }

        function submitApproval() {
            $.post('/api/workflow/approve', $('#approvalForm').serialize(), function(response) {
                if (response.success) {
                    location.reload();
                } else {
                    alert(response.message);
                }
            });
        }

        function submitRejection() {
            $.post('/api/workflow/reject', $('#rejectionForm').serialize(), function(response) {
                if (response.success) {
                    location.reload();
                } else {
                    alert(response.message);
                }
            });
        }

        function deleteWorkflow(workflowID) {
            if (confirm(getLabel('confirm_delete_workflow', 'Are you sure you want to delete this workflow?'))) {
                $.post('/api/workflow/delete', { workflowID: workflowID }, function(response) {
                    if (response.success) {
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                });
            }
        }
    </script>
</body>
</html> 