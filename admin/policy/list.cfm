<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('policy_management', 'Policy Management')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <cfset policyService = new model.PolicyService()>
    <cfset labelService = new model.LabelService()>
    <cfset policies = policyService.getPolicies(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><cfoutput>#getLabel('policy_list', 'Policies')#</cfoutput></h2>
            <div>
                <button type="button" class="btn btn-primary" onclick="location.href='edit.cfm'">
                    <i class="fas fa-plus"></i> <cfoutput>#getLabel('new_policy', 'New Policy')#</cfoutput>
                </button>
            </div>
        </div>

        <!--- Filters --->
        <div class="card mb-4">
            <div class="card-body">
                <form id="filterForm" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label"><cfoutput>#getLabel('status', 'Status')#</cfoutput></label>
                        <select name="status" class="form-select">
                            <option value=""><cfoutput>#getLabel('all_statuses', 'All Statuses')#</cfoutput></option>
                            <option value="draft"><cfoutput>#getLabel('status_draft', 'Draft')#</cfoutput></option>
                            <option value="pending"><cfoutput>#getLabel('status_pending', 'Pending Approval')#</cfoutput></option>
                            <option value="active"><cfoutput>#getLabel('status_active', 'Active')#</cfoutput></option>
                            <option value="archived"><cfoutput>#getLabel('status_archived', 'Archived')#</cfoutput></option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label"><cfoutput>#getLabel('type', 'Type')#</cfoutput></label>
                        <select name="type" class="form-select">
                            <option value=""><cfoutput>#getLabel('all_types', 'All Types')#</cfoutput></option>
                            <option value="policy"><cfoutput>#getLabel('type_policy', 'Policy')#</cfoutput></option>
                            <option value="procedure"><cfoutput>#getLabel('type_procedure', 'Procedure')#</cfoutput></option>
                            <option value="standard"><cfoutput>#getLabel('type_standard', 'Standard')#</cfoutput></option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label"><cfoutput>#getLabel('category', 'Category')#</cfoutput></label>
                        <select name="categoryID" class="form-select">
                            <option value="0"><cfoutput>#getLabel('all_categories', 'All Categories')#</cfoutput></option>
                            <cfoutput query="getCategories">
                                <option value="#categoryID#">#name#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary">
                            <cfoutput>#getLabel('apply_filters', 'Apply Filters')#</cfoutput>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!--- Policies Table --->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th><cfoutput>#getLabel('title', 'Title')#</cfoutput></th>
                                <th><cfoutput>#getLabel('type', 'Type')#</cfoutput></th>
                                <th><cfoutput>#getLabel('category', 'Category')#</cfoutput></th>
                                <th><cfoutput>#getLabel('owner', 'Owner')#</cfoutput></th>
                                <th><cfoutput>#getLabel('status', 'Status')#</cfoutput></th>
                                <th><cfoutput>#getLabel('version', 'Version')#</cfoutput></th>
                                <th><cfoutput>#getLabel('next_review', 'Next Review')#</cfoutput></th>
                                <th><cfoutput>#getLabel('actions', 'Actions')#</cfoutput></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="policies">
                                <tr>
                                    <td>#title#</td>
                                    <td>#getLabel('type_' & type, type)#</td>
                                    <td>#categoryName#</td>
                                    <td>#ownerName#</td>
                                    <td>
                                        <span class="badge bg-#status eq 'active' ? 'success' :
                                                    (status eq 'pending' ? 'warning' :
                                                    (status eq 'draft' ? 'secondary' : 'danger'))#">
                                            #getLabel('status_' & status, status)#
                                        </span>
                                    </td>
                                    <td>v#currentVersion#</td>
                                    <td>
                                        <cfif isDate(nextReviewDate)>
                                            <span class="badge bg-#dateCompare(nextReviewDate, dateAdd('m', 1, now())) eq 1 ? 'success' : 'danger'#">
                                                #dateFormat(nextReviewDate, "yyyy-mm-dd")#
                                            </span>
                                        <cfelse>
                                            <span class="badge bg-secondary">#getLabel('not_set', 'Not Set')#</span>
                                        </cfif>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-sm btn-primary" 
                                                    onclick="location.href='view.cfm?id=#policyID#'"
                                                    title="#getLabel('view_policy', 'View Policy')#">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-secondary" 
                                                    onclick="location.href='edit.cfm?id=#policyID#'"
                                                    title="#getLabel('edit_policy', 'Edit Policy')#">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-info" 
                                                    onclick="viewHistory(#policyID#)"
                                                    title="#getLabel('view_history', 'View History')#">
                                                <i class="fas fa-history"></i>
                                            </button>
                                            <cfif status eq 'active'>
                                                <button type="button" class="btn btn-sm btn-warning" 
                                                        onclick="initiateReview(#policyID#)"
                                                        title="#getLabel('initiate_review', 'Initiate Review')#">
                                                    <i class="fas fa-clipboard-check"></i>
                                                </button>
                                            </cfif>
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

    <!--- History Modal --->
    <div class="modal fade" id="historyModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><cfoutput>#getLabel('version_history', 'Version History')#</cfoutput></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="historyContent"></div>
                </div>
            </div>
        </div>
    </div>

    <!--- Review Modal --->
    <div class="modal fade" id="reviewModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><cfoutput>#getLabel('initiate_review', 'Initiate Review')#</cfoutput></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="reviewForm">
                        <input type="hidden" name="policyID" id="reviewPolicyID">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('review_comments', 'Review Comments')#</cfoutput></label>
                            <textarea class="form-control" name="comments" rows="3" required></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <cfoutput>#getLabel('cancel', 'Cancel')#</cfoutput>
                    </button>
                    <button type="button" class="btn btn-primary" onclick="submitReview()">
                        <cfoutput>#getLabel('submit_review', 'Submit Review')#</cfoutput>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function viewHistory(policyID) {
            $.get('/api/policy/getVersionHistory', { policyID: policyID }, function(response) {
                if (response.success) {
                    $('#historyContent').html(response.html);
                    $('#historyModal').modal('show');
                }
            });
        }

        function initiateReview(policyID) {
            $('#reviewPolicyID').val(policyID);
            $('#reviewModal').modal('show');
        }

        function submitReview() {
            $.post('/api/policy/submitReview', $('#reviewForm').serialize(), function(response) {
                if (response.success) {
                    location.reload();
                } else {
                    alert(response.message);
                }
            });
        }

        $('#filterForm').submit(function(e) {
            e.preventDefault();
            $.get('/api/policy/getPolicies', $(this).serialize(), function(response) {
                if (response.success) {
                    location.reload();
                }
            });
        });
    </script>
</body>
</html> 