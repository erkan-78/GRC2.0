<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('edit_control', 'Edit Control')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <cfset controlService = new model.ControlService()>
    <cfif structKeyExists(url, "id")>
        <cfset control = controlService.getControl(url.id)>
    </cfif>

    <div class="container-fluid mt-4">
        <div class="row mb-4">
            <div class="col">
                <div class="d-flex justify-content-between align-items-center">
                    <h2>
                        <cfoutput>
                            <cfif structKeyExists(url, "id")>
                                #getLabel('edit_control', 'Edit Control')#: #control.title#
                            <cfelse>
                                #getLabel('new_control', 'New Control')#
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

        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('control_details', 'Control Details')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <form id="controlForm" onsubmit="return saveControl(event)">
                            <cfif structKeyExists(url, "id")>
                                <input type="hidden" name="controlID" value="#control.controlID#">
                            </cfif>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('control_title', 'Control Title')#</cfoutput></label>
                                <input type="text" class="form-control" name="title" required
                                       value="<cfoutput>#structKeyExists(url, 'id') ? control.title : ''#</cfoutput>">
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('control_description', 'Description')#</cfoutput></label>
                                <textarea class="form-control" name="description" rows="4" required><cfoutput>#structKeyExists(url, 'id') ? control.description : ''#</cfoutput></textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('control_type', 'Control Type')#</cfoutput></label>
                                <select class="form-select" name="type" required>
                                    <option value="preventive" <cfif structKeyExists(url, "id") && control.type eq "preventive">selected</cfif>>
                                        <cfoutput>#getLabel('control_type_preventive', 'Preventive')#</cfoutput>
                                    </option>
                                    <option value="detective" <cfif structKeyExists(url, "id") && control.type eq "detective">selected</cfif>>
                                        <cfoutput>#getLabel('control_type_detective', 'Detective')#</cfoutput>
                                    </option>
                                    <option value="corrective" <cfif structKeyExists(url, "id") && control.type eq "corrective">selected</cfif>>
                                        <cfoutput>#getLabel('control_type_corrective', 'Corrective')#</cfoutput>
                                    </option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('control_frequency', 'Control Frequency')#</cfoutput></label>
                                <select class="form-select" name="frequency" required>
                                    <option value="continuous" <cfif structKeyExists(url, "id") && control.frequency eq "continuous">selected</cfif>>
                                        <cfoutput>#getLabel('frequency_continuous', 'Continuous')#</cfoutput>
                                    </option>
                                    <option value="daily" <cfif structKeyExists(url, "id") && control.frequency eq "daily">selected</cfif>>
                                        <cfoutput>#getLabel('frequency_daily', 'Daily')#</cfoutput>
                                    </option>
                                    <option value="weekly" <cfif structKeyExists(url, "id") && control.frequency eq "weekly">selected</cfif>>
                                        <cfoutput>#getLabel('frequency_weekly', 'Weekly')#</cfoutput>
                                    </option>
                                    <option value="monthly" <cfif structKeyExists(url, "id") && control.frequency eq "monthly">selected</cfif>>
                                        <cfoutput>#getLabel('frequency_monthly', 'Monthly')#</cfoutput>
                                    </option>
                                    <option value="quarterly" <cfif structKeyExists(url, "id") && control.frequency eq "quarterly">selected</cfif>>
                                        <cfoutput>#getLabel('frequency_quarterly', 'Quarterly')#</cfoutput>
                                    </option>
                                    <option value="annually" <cfif structKeyExists(url, "id") && control.frequency eq "annually">selected</cfif>>
                                        <cfoutput>#getLabel('frequency_annually', 'Annually')#</cfoutput>
                                    </option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('control_owner', 'Control Owner')#</cfoutput></label>
                                <select class="form-select" name="ownerID" required>
                                    <cfoutput query="controlService.getCompanyUsers(session.companyID)">
                                        <option value="#userID#" #structKeyExists(url, 'id') && control.ownerID eq userID ? 'selected' : ''#>
                                            #firstName# #lastName#
                                        </option>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('test_procedures', 'Test Procedures')#</cfoutput></label>
                                <textarea class="form-control" name="testProcedures" rows="4"><cfoutput>#structKeyExists(url, 'id') ? control.testProcedures : ''#</cfoutput></textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('evidence_requirements', 'Evidence Requirements')#</cfoutput></label>
                                <textarea class="form-control" name="evidenceRequirements" rows="4"><cfoutput>#structKeyExists(url, 'id') ? control.evidenceRequirements : ''#</cfoutput></textarea>
                            </div>

                            <div class="text-end">
                                <button type="submit" class="btn btn-primary" name="action" value="draft">
                                    <i class="fas fa-save"></i> <cfoutput>#getLabel('save_draft', 'Save Draft')#</cfoutput>
                                </button>
                                <button type="submit" class="btn btn-success" name="action" value="submit">
                                    <i class="fas fa-paper-plane"></i> <cfoutput>#getLabel('submit_for_approval', 'Submit for Approval')#</cfoutput>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <!-- Version History -->
                <cfif structKeyExists(url, "id")>
                    <div class="card mb-3">
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
                                            <th><cfoutput>#getLabel('modified_by', 'Modified By')#</cfoutput></th>
                                            <th><cfoutput>#getLabel('modified_date', 'Modified Date')#</cfoutput></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfoutput query="control.versions">
                                            <tr>
                                                <td>v#version#</td>
                                                <td>
                                                    <span class="badge bg-#status eq 'approved' ? 'success' :
                                                                (status eq 'draft' ? 'warning' : 'danger')#">
                                                        #getLabel('status_' & status, status)#
                                                    </span>
                                                </td>
                                                <td>#modifiedByName#</td>
                                                <td>#dateFormat(modifiedDate, "yyyy-mm-dd")#</td>
                                            </tr>
                                        </cfoutput>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </cfif>

                <!-- Linked Workflows -->
                <cfif structKeyExists(url, "id")>
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('linked_workflows', 'Linked Workflows')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="list-group">
                                <cfoutput query="controlService.getLinkedWorkflows(url.id)">
                                    <a href="../workflow/designer.cfm?id=#workflowID#" class="list-group-item list-group-item-action">
                                        #title#
                                    </a>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </cfif>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function saveControl(event) {
            event.preventDefault();
            const form = event.target;
            const formData = new FormData(form);
            
            $.ajax({
                url: '/api/control/save',
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
    </script>
</body>
</html> 