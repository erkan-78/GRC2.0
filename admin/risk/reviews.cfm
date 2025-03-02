<!DOCTYPE html>
<html>
<head>
    <title>Risk Reviews</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <cfset riskService = new model.RiskService()>
    <cfset pendingReviews = riskService.getPendingReviews(session.companyID)>
    <cfset reviewHistory = riskService.getReviewHistory(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Risk Reviews</h2>
        </div>

        <!--- Pending Reviews --->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Pending Reviews</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Risk Title</th>
                                <th>Category</th>
                                <th>Risk Level</th>
                                <th>Submitted By</th>
                                <th>Submission Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="pendingReviews">
                                <tr>
                                    <td>#title#</td>
                                    <td>#categoryName#</td>
                                    <td>
                                        <span class="badge bg-#riskLevel <= 4 ? 'success' :
                                                    (riskLevel <= 8 ? 'warning' :
                                                    (riskLevel <= 12 ? 'orange' : 'danger'))#">
                                            #riskLevel#
                                        </span>
                                    </td>
                                    <td>#submittedByName#</td>
                                    <td>#dateTimeFormat(submissionDate, "yyyy-mm-dd HH:nn")#</td>
                                    <td>
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-sm btn-primary review-risk"
                                                    data-id="#riskID#">
                                                Review
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

        <!--- Review History --->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Review History</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Risk Title</th>
                                <th>Category</th>
                                <th>Review Status</th>
                                <th>Reviewed By</th>
                                <th>Review Date</th>
                                <th>Comments</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="reviewHistory">
                                <tr>
                                    <td>#title#</td>
                                    <td>#categoryName#</td>
                                    <td>
                                        <span class="badge bg-#status eq 'approved' ? 'success' :
                                                    (status eq 'rejected' ? 'danger' : 
                                                    (status eq 'needs_revision' ? 'warning' : 'info'))#">
                                            #uCase(status)#
                                        </span>
                                    </td>
                                    <td>#reviewerName#</td>
                                    <td>#dateTimeFormat(review_date, "yyyy-mm-dd HH:nn")#</td>
                                    <td>#comments#</td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!--- Review Modal --->
    <div class="modal fade" id="reviewModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Risk Review</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="reviewForm">
                        <input type="hidden" name="riskID" id="riskID">
                        
                        <div id="riskDetails" class="mb-4">
                            <!--- Risk details will be loaded here --->
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label class="form-label">Review Decision</label>
                                <select name="status" id="status" class="form-select" required>
                                    <option value="approved">Approve</option>
                                    <option value="rejected">Reject</option>
                                    <option value="needs_revision">Needs Revision</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label class="form-label">Comments</label>
                                <textarea class="form-control" name="comments" id="comments" rows="3" required></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="submitReview">Submit Review</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            // Review risk
            $('.review-risk').click(function() {
                const riskID = $(this).data('id');
                $('#riskID').val(riskID);
                
                // Load risk details
                $.get('/api/risk/getRiskDetails', { id: riskID }, function(response) {
                    if (response.success) {
                        $('#riskDetails').html(response.html);
                        $('#reviewModal').modal('show');
                    }
                });
            });
            
            // Submit review
            $('#submitReview').click(function() {
                $.post('/api/risk/submitReview', $('#reviewForm').serialize(), function(response) {
                    if (response.success) {
                        $('#reviewModal').modal('hide');
                        location.reload();
                    } else {
                        alert('Error submitting review: ' + response.message);
                    }
                });
            });
        });
    </script>
</body>
</html> 