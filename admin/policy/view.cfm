<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('view_policy', 'View Policy')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .policy-content {
            background: #fff;
            padding: 2rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            min-height: 500px;
        }
        .version-badge {
            font-size: 0.9rem;
            padding: 0.5rem 1rem;
        }
        .requirement-list {
            list-style: none;
            padding-left: 0;
        }
        .requirement-list li {
            padding: 0.5rem 0;
            border-bottom: 1px solid #eee;
        }
        .requirement-badge {
            font-size: 0.8rem;
        }
    </style>
</head>
<body>
    <cfset policyService = new model.PolicyService()>
    <cfset policy = policyService.getPolicy(url.id, url.version ?: 0)>
    
    <div class="container-fluid mt-4">
        <!--- Header --->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2><cfoutput>#policy.title#</cfoutput></h2>
                <div class="text-muted">
                    <cfoutput>
                        <span class="badge bg-secondary version-badge">v#policy.version#</span>
                        <span class="ms-2">#getLabel('type_' & policy.type, policy.type)#</span>
                        <span class="ms-2">&bull;</span>
                        <span class="ms-2">#policy.categoryName#</span>
                    </cfoutput>
                </div>
            </div>
            <div>
                <button type="button" class="btn btn-secondary" onclick="location.href='list.cfm'">
                    <i class="fas fa-arrow-left"></i> <cfoutput>#getLabel('back_to_list', 'Back to List')#</cfoutput>
                </button>
                <cfif policy.status eq "active">
                    <div class="btn-group ms-2">
                        <button type="button" class="btn btn-primary" onclick="downloadPDF()">
                            <i class="fas fa-file-pdf"></i> PDF
                        </button>
                        <button type="button" class="btn btn-primary" onclick="downloadWord()">
                            <i class="fas fa-file-word"></i> Word
                        </button>
                    </div>
                </cfif>
            </div>
        </div>

        <div class="row">
            <!--- Main Content --->
            <div class="col-md-8">
                <!--- Policy Content --->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('content', 'Content')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="policy-content">
                            <cfoutput>#policy.content#</cfoutput>
                        </div>
                    </div>
                </div>

                <!--- Version History --->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('version_history', 'Version History')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th><cfoutput>#getLabel('version', 'Version')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('status', 'Status')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('created_by', 'Created By')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('created_date', 'Created Date')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('approved_by', 'Approved By')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('approval_date', 'Approval Date')#</cfoutput></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfoutput query="policy.versions">
                                        <tr>
                                            <td>
                                                <a href="view.cfm?id=#url.id#&version=#version#" 
                                                   class="text-decoration-none">v#version#</a>
                                            </td>
                                            <td>
                                                <span class="badge bg-#status eq 'approved' ? 'success' :
                                                            (status eq 'rejected' ? 'danger' : 'warning')#">
                                                    #getLabel('status_' & status, status)#
                                                </span>
                                            </td>
                                            <td>#createdByName#</td>
                                            <td>#dateFormat(created, "yyyy-mm-dd")#</td>
                                            <td>#approverName#</td>
                                            <td>#dateFormat(approvalDate, "yyyy-mm-dd")#</td>
                                        </tr>
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Sidebar --->
            <div class="col-md-4">
                <!--- Policy Details --->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('policy_details', 'Policy Details')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <dl class="row mb-0">
                            <dt class="col-sm-4"><cfoutput>#getLabel('owner', 'Owner')#</cfoutput></dt>
                            <dd class="col-sm-8"><cfoutput>#policy.ownerName#</cfoutput></dd>

                            <dt class="col-sm-4"><cfoutput>#getLabel('status', 'Status')#</cfoutput></dt>
                            <dd class="col-sm-8">
                                <cfoutput>
                                    <span class="badge bg-#policy.status eq 'active' ? 'success' :
                                                (policy.status eq 'pending' ? 'warning' : 'secondary')#">
                                        #getLabel('status_' & policy.status, policy.status)#
                                    </span>
                                </cfoutput>
                            </dd>

                            <dt class="col-sm-4"><cfoutput>#getLabel('next_review', 'Next Review')#</cfoutput></dt>
                            <dd class="col-sm-8">
                                <cfoutput>
                                    <cfif isDate(policy.nextReviewDate)>
                                        <span class="badge bg-#dateCompare(policy.nextReviewDate, dateAdd('m', 1, now())) eq 1 ? 'success' : 'danger'#">
                                            #dateFormat(policy.nextReviewDate, "yyyy-mm-dd")#
                                        </span>
                                    <cfelse>
                                        <span class="badge bg-secondary">#getLabel('not_set', 'Not Set')#</span>
                                    </cfif>
                                </cfoutput>
                            </dd>
                        </dl>
                    </div>
                </div>

                <!--- Requirements --->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('requirements', 'Requirements')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <ul class="requirement-list">
                            <cfoutput query="policy.requirements">
                                <li>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span>#requirement#</span>
                                        <span class="badge bg-#type eq 'mandatory' ? 'danger' : 'info'# requirement-badge">
                                            #getLabel('type_' & type, type)#
                                        </span>
                                    </div>
                                </li>
                            </cfoutput>
                        </ul>
                    </div>
                </div>

                <!--- Attachments --->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('attachments', 'Attachments')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="list-group">
                            <cfoutput query="policy.attachments">
                                <a href="##" onclick="downloadAttachment(#fileID#)" 
                                   class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                    <span>#originalName#</span>
                                    <span class="badge bg-primary rounded-pill">#fileType#</span>
                                </a>
                            </cfoutput>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function downloadPDF() {
            window.location.href = '/api/policy/download?id=<cfoutput>#url.id#</cfoutput>&format=pdf';
        }

        function downloadWord() {
            window.location.href = '/api/policy/download?id=<cfoutput>#url.id#</cfoutput>&format=docx';
        }

        function downloadAttachment(fileID) {
            window.location.href = '/api/policy/downloadAttachment?fileID=' + fileID;
        }
    </script>
</body>
</html> 