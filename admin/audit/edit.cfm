<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('edit_audit', 'Edit Audit')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
</head>
<body>
    <cfset auditService = new model.AuditService()>
    <cfset workflowService = new model.WorkflowService()>
    <cfset controlService = new model.ControlService()>
    
    <cfif structKeyExists(url, "id")>
        <cfset audit = auditService.getAudit(url.id)>
    </cfif>

    <div class="container-fluid mt-4">
        <div class="row mb-4">
            <div class="col">
                <div class="d-flex justify-content-between align-items-center">
                    <h2>
                        <cfoutput>
                            <cfif structKeyExists(url, "id")>
                                #getLabel('edit_audit', 'Edit Audit')#: #audit.reference#
                            <cfelse>
                                #getLabel('new_audit', 'New Audit')#
                            </cfif>
                        </cfoutput>
                    </h2>
                    <div>
                        <button type="button" class="btn btn-secondary" onclick="location.href='list.cfm'">
                            <i class="fas fa-arrow-left"></i> <cfoutput>#getLabel('back_to_list', 'Back to List')#</cfoutput>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <form id="auditForm" onsubmit="return saveAudit(event)">
            <cfif structKeyExists(url, "id")>
                <input type="hidden" name="auditID" value="#audit.auditID#">
            </cfif>

            <div class="row">
                <!-- Main Audit Details -->
                <div class="col-md-8">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('audit_details', 'Audit Details')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('audit_reference', 'Audit Reference')#</cfoutput></label>
                                    <input type="text" class="form-control" name="reference" required
                                           value="<cfoutput>#structKeyExists(url, 'id') ? audit.reference : ''#</cfoutput>">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('audit_title', 'Audit Title')#</cfoutput></label>
                                    <input type="text" class="form-control" name="title" required
                                           value="<cfoutput>#structKeyExists(url, 'id') ? audit.title : ''#</cfoutput>">
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('audit_scope', 'Scope')#</cfoutput></label>
                                <textarea class="form-control" name="scope" rows="4" required><cfoutput>#structKeyExists(url, 'id') ? audit.scope : ''#</cfoutput></textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('audit_start_date', 'Start Date')#</cfoutput></label>
                                    <input type="date" class="form-control" name="startDate" required
                                           value="<cfoutput>#structKeyExists(url, 'id') ? dateFormat(audit.startDate, 'yyyy-mm-dd') : ''#</cfoutput>">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('audit_end_date', 'End Date')#</cfoutput></label>
                                    <input type="date" class="form-control" name="endDate" required
                                           value="<cfoutput>#structKeyExists(url, 'id') ? dateFormat(audit.endDate, 'yyyy-mm-dd') : ''#</cfoutput>">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Audit Team -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('audit_team', 'Audit Team')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('audit_manager', 'Audit Manager')#</cfoutput></label>
                                    <select class="form-select select2" name="managerID" required>
                                        <cfoutput query="auditService.getCompanyUsers(session.companyID)">
                                            <option value="#userID#" #structKeyExists(url, 'id') && audit.managerID eq userID ? 'selected' : ''#>
                                                #firstName# #lastName#
                                            </option>
                                        </cfoutput>
                                    </select>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('team_lead', 'Team Lead')#</cfoutput></label>
                                    <select class="form-select select2" name="teamLeadID" required>
                                        <cfoutput query="auditService.getCompanyUsers(session.companyID)">
                                            <option value="#userID#" #structKeyExists(url, 'id') && audit.teamLeadID eq userID ? 'selected' : ''#>
                                                #firstName# #lastName#
                                            </option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('team_members', 'Team Members')#</cfoutput></label>
                                <select class="form-select select2" name="teamMembers[]" multiple required>
                                    <cfoutput query="auditService.getCompanyUsers(session.companyID)">
                                        <option value="#userID#" #structKeyExists(url, 'id') && listFind(audit.teamMembers, userID) ? 'selected' : ''#>
                                            #firstName# #lastName#
                                        </option>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('report_receivers', 'Report Receivers')#</cfoutput></label>
                                <select class="form-select select2" name="reportReceivers[]" multiple>
                                    <cfoutput query="auditService.getCompanyUsers(session.companyID)">
                                        <option value="#userID#" #structKeyExists(url, 'id') && listFind(audit.reportReceivers, userID) ? 'selected' : ''#>
                                            #firstName# #lastName#
                                        </option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Workflows and Controls -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('workflows_and_controls', 'Workflows and Controls')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('select_workflows', 'Select Workflows')#</cfoutput></label>
                                <select class="form-select select2" name="workflows[]" multiple onchange="loadWorkflowControls()">
                                    <cfoutput query="workflowService.getWorkflows(session.companyID)">
                                        <option value="#workflowID#" #structKeyExists(url, 'id') && listFind(audit.workflows, workflowID) ? 'selected' : ''#>
                                            #title#
                                        </option>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('selected_controls', 'Selected Controls')#</cfoutput></label>
                                <div id="controlsList" class="list-group">
                                    <cfif structKeyExists(url, "id")>
                                        <cfoutput query="auditService.getAuditControls(url.id)">
                                            <div class="list-group-item">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <h6 class="mb-1">#title#</h6>
                                                        <small>#description#</small>
                                                    </div>
                                                    <button type="button" class="btn btn-sm btn-danger" onclick="removeControl(#controlID#)">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </cfoutput>
                                    </cfif>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('additional_objectives', 'Additional Objectives')#</cfoutput></label>
                                <div id="objectivesList">
                                    <cfif structKeyExists(url, "id")>
                                        <cfoutput query="auditService.getAuditObjectives(url.id)">
                                            <div class="input-group mb-2">
                                                <input type="text" class="form-control" name="objectives[]" value="#objective#">
                                                <button type="button" class="btn btn-danger" onclick="removeObjective(this)">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </div>
                                        </cfoutput>
                                    </cfif>
                                </div>
                                <button type="button" class="btn btn-outline-primary" onclick="addObjective()">
                                    <i class="fas fa-plus"></i> <cfoutput>#getLabel('add_objective', 'Add Objective')#</cfoutput>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Sidebar -->
                <div class="col-md-4">
                    <!-- Status -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('audit_status', 'Audit Status')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('status', 'Status')#</cfoutput></label>
                                <select class="form-select" name="status" required>
                                    <option value="planning" <cfif structKeyExists(url, "id") && audit.status eq "planning">selected</cfif>>
                                        <cfoutput>#getLabel('status_planning', 'Planning')#</cfoutput>
                                    </option>
                                    <option value="in_progress" <cfif structKeyExists(url, "id") && audit.status eq "in_progress">selected</cfif>>
                                        <cfoutput>#getLabel('status_in_progress', 'In Progress')#</cfoutput>
                                    </option>
                                    <option value="review" <cfif structKeyExists(url, "id") && audit.status eq "review">selected</cfif>>
                                        <cfoutput>#getLabel('status_review', 'Review')#</cfoutput>
                                    </option>
                                    <option value="completed" <cfif structKeyExists(url, "id") && audit.status eq "completed">selected</cfif>>
                                        <cfoutput>#getLabel('status_completed', 'Completed')#</cfoutput>
                                    </option>
                                </select>
                            </div>

                            <div class="text-end">
                                <button type="submit" class="btn btn-primary" name="action" value="save">
                                    <i class="fas fa-save"></i> <cfoutput>#getLabel('save_audit', 'Save Audit')#</cfoutput>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Progress -->
                    <cfif structKeyExists(url, "id")>
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0"><cfoutput>#getLabel('audit_progress', 'Audit Progress')#</cfoutput></h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('controls_reviewed', 'Controls Reviewed')#</cfoutput></label>
                                    <div class="progress">
                                        <div class="progress-bar" role="progressbar" style="width: <cfoutput>#audit.progress#</cfoutput>%">
                                            <cfoutput>#audit.progress#%</cfoutput>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <small class="text-muted">
                                        <cfoutput>
                                            #getLabel('total_controls', 'Total Controls')#: #audit.totalControls#<br>
                                            #getLabel('reviewed_controls', 'Reviewed Controls')#: #audit.reviewedControls#<br>
                                            #getLabel('pending_controls', 'Pending Controls')#: #audit.totalControls - audit.reviewedControls#
                                        </cfoutput>
                                    </small>
                                </div>
                            </div>
                        </div>
                    </cfif>
                </div>
            </div>
        </form>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        $(document).ready(function() {
            $('.select2').select2();
        });

        function saveAudit(event) {
            event.preventDefault();
            const form = event.target;
            const formData = new FormData(form);
            
            $.ajax({
                url: '/api/audit/save',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    if (response.success) {
                        location.href = 'list.cfm';
                    } else {
                        alert(response.message);
                    }
                }
            });

            return false;
        }

        function loadWorkflowControls() {
            const selectedWorkflows = $('select[name="workflows[]"]').val();
            
            $.post('/api/workflow/getControls', { workflows: selectedWorkflows }, function(response) {
                if (response.success) {
                    updateControlsList(response.controls);
                }
            });
        }

        function updateControlsList(controls) {
            const controlsList = $('#controlsList');
            controlsList.empty();

            controls.forEach(control => {
                controlsList.append(`
                    <div class="list-group-item">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="mb-1">${control.title}</h6>
                                <small>${control.description}</small>
                            </div>
                            <button type="button" class="btn btn-sm btn-danger" onclick="removeControl(${control.controlID})">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        <input type="hidden" name="controls[]" value="${control.controlID}">
                    </div>
                `);
            });
        }

        function removeControl(controlID) {
            $(`input[value="${controlID}"]`).closest('.list-group-item').remove();
        }

        function addObjective() {
            $('#objectivesList').append(`
                <div class="input-group mb-2">
                    <input type="text" class="form-control" name="objectives[]">
                    <button type="button" class="btn btn-danger" onclick="removeObjective(this)">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `);
        }

        function removeObjective(button) {
            $(button).closest('.input-group').remove();
        }
    </script>
</body>
</html> 