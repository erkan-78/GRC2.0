<!DOCTYPE html>
<html>
<head>
    <title>Function Approval Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Function Approval Dashboard</h2>
            <div>
                <a href="index.cfm" class="btn btn-secondary">Back to List</a>
            </div>
        </div>

        <div class="row">
            <!--- Statistics Cards --->
            <div class="col-md-3 mb-4">
                <div class="card bg-warning text-white h-100">
                    <div class="card-body">
                        <h5 class="card-title">Pending Approvals</h5>
                        <h2 class="mb-0"><cfoutput>#stats.pendingCount#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card bg-success text-white h-100">
                    <div class="card-body">
                        <h5 class="card-title">Approved This Month</h5>
                        <h2 class="mb-0"><cfoutput>#stats.approvedThisMonth#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card bg-danger text-white h-100">
                    <div class="card-body">
                        <h5 class="card-title">Rejected This Month</h5>
                        <h2 class="mb-0"><cfoutput>#stats.rejectedThisMonth#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3 mb-4">
                <div class="card bg-info text-white h-100">
                    <div class="card-body">
                        <h5 class="card-title">Average Approval Time</h5>
                        <h2 class="mb-0"><cfoutput>#stats.avgApprovalTime# hrs</cfoutput></h2>
                    </div>
                </div>
            </div>
        </div>

        <!--- Pending Approvals --->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Pending Approvals</h5>
            </div>
            <div class="card-body">
                <form action="/api/functions/bulkApprove" method="post" id="bulkApprovalForm">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>
                                        <input type="checkbox" id="selectAll" class="form-check-input">
                                    </th>
                                    <th>Title</th>
                                    <th>Company</th>
                                    <th>Requested By</th>
                                    <th>Waiting Since</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput query="getPendingFunctions">
                                    <tr>
                                        <td>
                                            <input type="checkbox" name="functionIDs" value="#functionID#" class="form-check-input function-select">
                                        </td>
                                        <td>#title#</td>
                                        <td>#companyName#</td>
                                        <td>#requestedByName#</td>
                                        <td>#dateDiff("h", created, now())# hours ago</td>
                                        <td>
                                            <div class="btn-group">
                                                <a href="index.cfm?page=edit&id=#functionID#" 
                                                   class="btn btn-sm btn-primary">Review</a>
                                                <button type="button" 
                                                        class="btn btn-sm btn-success quick-approve"
                                                        data-id="#functionID#">
                                                    Approve
                                                </button>
                                                <button type="button" 
                                                        class="btn btn-sm btn-danger reject-function"
                                                        data-id="#functionID#"
                                                        data-title="#title#">
                                                    Reject
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </cfoutput>
                            </tbody>
                        </table>
                    </div>

                    <div class="mt-3">
                        <button type="submit" class="btn btn-success" id="bulkApproveBtn" disabled>
                            Approve Selected
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!--- Recent Activity --->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Recent Activity</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Date/Time</th>
                                <th>Function</th>
                                <th>Company</th>
                                <th>Action</th>
                                <th>By User</th>
                                <th>Comments</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="getRecentActivity">
                                <tr>
                                    <td>#dateTimeFormat(created, "yyyy-mm-dd HH:nn:ss")#</td>
                                    <td>#functionTitle#</td>
                                    <td>#companyName#</td>
                                    <td>
                                        <span class="badge bg-#action eq 'approved' ? 'success' : 
                                                    (action eq 'rejected' ? 'danger' : 'warning')#">
                                            #uCase(action)#
                                        </span>
                                    </td>
                                    <td>#actionByName#</td>
                                    <td>#comments#</td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!--- Rejection Modal --->
    <div class="modal fade" id="rejectionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Reject Function</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="rejectFunctionID">
                    <div class="mb-3">
                        <label for="rejectionReason" class="form-label">Rejection Reason:</label>
                        <textarea class="form-control" id="rejectionReason" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmReject">Reject</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            // Handle select all checkbox
            $('#selectAll').change(function() {
                $('.function-select').prop('checked', $(this).is(':checked'));
                updateBulkApproveButton();
            });

            // Handle individual checkboxes
            $('.function-select').change(function() {
                updateBulkApproveButton();
            });

            // Update bulk approve button state
            function updateBulkApproveButton() {
                $('#bulkApproveBtn').prop('disabled', !$('.function-select:checked').length);
            }

            // Quick approve
            $('.quick-approve').click(function() {
                const functionID = $(this).data('id');
                approveFunction(functionID);
            });

            // Reject function
            $('.reject-function').click(function() {
                const functionID = $(this).data('id');
                const title = $(this).data('title');
                $('#rejectFunctionID').val(functionID);
                $('.modal-title').text('Reject Function: ' + title);
                $('#rejectionModal').modal('show');
            });

            // Confirm rejection
            $('#confirmReject').click(function() {
                const functionID = $('#rejectFunctionID').val();
                const reason = $('#rejectionReason').val();
                
                if (!reason.trim()) {
                    alert('Please provide a rejection reason');
                    return;
                }
                
                rejectFunction(functionID, reason);
            });

            // Handle bulk approval
            $('#bulkApprovalForm').submit(function(e) {
                e.preventDefault();
                
                const functionIDs = $('.function-select:checked').map(function() {
                    return $(this).val();
                }).get();
                
                if (confirm('Are you sure you want to approve ' + functionIDs.length + ' functions?')) {
                    $.post('/api/functions/bulkApprove', {
                        functionIDs: functionIDs.join(',')
                    }, function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert(response.message);
                        }
                    });
                }
            });

            function approveFunction(functionID) {
                $.post('/api/functions/save', {
                    functionID: functionID,
                    approvalStatus: 'approved'
                }, function(response) {
                    if (response.success) {
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                });
            }

            function rejectFunction(functionID, reason) {
                $.post('/api/functions/save', {
                    functionID: functionID,
                    approvalStatus: 'rejected',
                    rejectionReason: reason
                }, function(response) {
                    if (response.success) {
                        $('#rejectionModal').modal('hide');
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                });
            }
        });
    </script>
</body>
</html> 