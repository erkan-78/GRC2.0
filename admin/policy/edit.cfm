<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('edit_policy', 'Edit Policy')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.css" rel="stylesheet">
</head>
<body>
    <cfset policyService = new model.PolicyService()>
    <cfif structKeyExists(url, "id")>
        <cfset policy = policyService.getPolicy(url.id)>
    <cfelse>
        <cfset policy = {}>
    </cfif>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>
                <cfoutput>
                    #structKeyExists(policy, "policyID") ? 
                        getLabel('edit_policy', 'Edit Policy') : 
                        getLabel('new_policy', 'New Policy')#
                </cfoutput>
            </h2>
        </div>

        <form id="policyForm" enctype="multipart/form-data">
            <cfif structKeyExists(policy, "policyID")>
                <input type="hidden" name="policyID" value="#policy.policyID#">
            </cfif>

            <div class="row">
                <!--- Main Policy Details --->
                <div class="col-md-8">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('policy_details', 'Policy Details')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('title', 'Title')#</cfoutput></label>
                                <input type="text" class="form-control" name="title" 
                                       value="<cfoutput>#structKeyExists(policy, 'title') ? policy.title : ''#</cfoutput>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('description', 'Description')#</cfoutput></label>
                                <textarea class="form-control" name="description" rows="3"><cfoutput>#structKeyExists(policy, 'description') ? policy.description : ''#</cfoutput></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('content', 'Content')#</cfoutput></label>
                                <textarea id="content" name="content" class="form-control"><cfoutput>#structKeyExists(policy, 'content') ? policy.content : ''#</cfoutput></textarea>
                            </div>
                        </div>
                    </div>

                    <!--- Requirements --->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><cfoutput>#getLabel('requirements', 'Requirements')#</cfoutput></h5>
                            <button type="button" class="btn btn-sm btn-primary" onclick="addRequirement()">
                                <i class="fas fa-plus"></i>
                            </button>
                        </div>
                        <div class="card-body">
                            <div id="requirementsList">
                                <cfif structKeyExists(policy, "requirements")>
                                    <cfoutput query="policy.requirements">
                                        <div class="requirement-item mb-3">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <input type="text" class="form-control" name="requirement[]" 
                                                           value="#requirement#" placeholder="#getLabel('requirement', 'Requirement')#">
                                                </div>
                                                <div class="col-md-3">
                                                    <select class="form-select" name="requirement_type[]">
                                                        <option value="mandatory" #type eq 'mandatory' ? 'selected' : ''#>
                                                            #getLabel('mandatory', 'Mandatory')#
                                                        </option>
                                                        <option value="optional" #type eq 'optional' ? 'selected' : ''#>
                                                            #getLabel('optional', 'Optional')#
                                                        </option>
                                                    </select>
                                                </div>
                                                <div class="col-md-3">
                                                    <button type="button" class="btn btn-danger btn-sm" onclick="removeRequirement(this)">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </cfoutput>
                                </cfif>
                            </div>
                        </div>
                    </div>
                </div>

                <!--- Sidebar --->
                <div class="col-md-4">
                    <!--- Policy Settings --->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('settings', 'Settings')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('type', 'Type')#</cfoutput></label>
                                <select name="type" class="form-select" required>
                                    <cfoutput>
                                        <option value="policy" #structKeyExists(policy, 'type') && policy.type eq 'policy' ? 'selected' : ''#>
                                            #getLabel('type_policy', 'Policy')#
                                        </option>
                                        <option value="procedure" #structKeyExists(policy, 'type') && policy.type eq 'procedure' ? 'selected' : ''#>
                                            #getLabel('type_procedure', 'Procedure')#
                                        </option>
                                        <option value="standard" #structKeyExists(policy, 'type') && policy.type eq 'standard' ? 'selected' : ''#>
                                            #getLabel('type_standard', 'Standard')#
                                        </option>
                                    </cfoutput>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('category', 'Category')#</cfoutput></label>
                                <select name="categoryID" class="form-select" required>
                                    <cfoutput query="getCategories">
                                        <option value="#categoryID#" #structKeyExists(policy, 'categoryID') && policy.categoryID eq categoryID ? 'selected' : ''#>
                                            #name#
                                        </option>
                                    </cfoutput>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('owner', 'Owner')#</cfoutput></label>
                                <select name="ownerID" class="form-select" required>
                                    <cfoutput query="getUsers">
                                        <option value="#userID#" #structKeyExists(policy, 'ownerID') && policy.ownerID eq userID ? 'selected' : ''#>
                                            #firstName# #lastName#
                                        </option>
                                    </cfoutput>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('review_frequency', 'Review Frequency')#</cfoutput></label>
                                <div class="input-group">
                                    <input type="number" class="form-control" name="reviewFrequency" 
                                           value="<cfoutput>#structKeyExists(policy, 'reviewFrequency') ? policy.reviewFrequency : 12#</cfoutput>" 
                                           min="1" max="60" required>
                                    <span class="input-group-text"><cfoutput>#getLabel('months', 'Months')#</cfoutput></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!--- Attachments --->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('attachments', 'Attachments')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('upload_files', 'Upload Files')#</cfoutput></label>
                                <input type="file" class="form-control" name="attachments" multiple 
                                       accept=".pdf,.doc,.docx">
                            </div>
                            <cfif structKeyExists(policy, "attachments") && arrayLen(policy.attachments)>
                                <div class="list-group">
                                    <cfoutput query="policy.attachments">
                                        <div class="list-group-item d-flex justify-content-between align-items-center">
                                            <span>#originalName#</span>
                                            <button type="button" class="btn btn-danger btn-sm" 
                                                    onclick="deleteAttachment(#fileID#)">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </cfoutput>
                                </div>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Form Actions --->
            <div class="card mb-4">
                <div class="card-body">
                    <div class="d-flex justify-content-between">
                        <button type="button" class="btn btn-secondary" onclick="location.href='list.cfm'">
                            <cfoutput>#getLabel('cancel', 'Cancel')#</cfoutput>
                        </button>
                        <div>
                            <button type="submit" class="btn btn-primary" name="action" value="draft">
                                <cfoutput>#getLabel('save_draft', 'Save Draft')#</cfoutput>
                            </button>
                            <button type="submit" class="btn btn-success" name="action" value="submit">
                                <cfoutput>#getLabel('submit_for_approval', 'Submit for Approval')#</cfoutput>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#content').summernote({
                height: 300,
                toolbar: [
                    ['style', ['style']],
                    ['font', ['bold', 'italic', 'underline', 'clear']],
                    ['para', ['ul', 'ol', 'paragraph']],
                    ['table', ['table']],
                    ['insert', ['link']],
                    ['view', ['fullscreen', 'codeview']]
                ]
            });
        });

        function addRequirement() {
            const template = `
                <div class="requirement-item mb-3">
                    <div class="row">
                        <div class="col-md-6">
                            <input type="text" class="form-control" name="requirement[]" 
                                   placeholder="<cfoutput>#getLabel('requirement', 'Requirement')#</cfoutput>">
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" name="requirement_type[]">
                                <option value="mandatory"><cfoutput>#getLabel('mandatory', 'Mandatory')#</cfoutput></option>
                                <option value="optional"><cfoutput>#getLabel('optional', 'Optional')#</cfoutput></option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeRequirement(this)">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                </div>
            `;
            $('#requirementsList').append(template);
        }

        function removeRequirement(button) {
            $(button).closest('.requirement-item').remove();
        }

        function deleteAttachment(fileID) {
            if (confirm('<cfoutput>#getLabel('confirm_delete_attachment', 'Are you sure you want to delete this attachment?')#</cfoutput>')) {
                $.post('/api/policy/deleteAttachment', { fileID: fileID }, function(response) {
                    if (response.success) {
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                });
            }
        }

        $('#policyForm').submit(function(e) {
            e.preventDefault();
            var formData = new FormData(this);
            
            $.ajax({
                url: '/api/policy/save',
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
        });
    </script>
</body>
</html> 