<!DOCTYPE html>
<html>
<head>
    <title>Asset Inventory Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
</head>
<body>
    <cfset riskService = new model.RiskService()>
    <cfset securityService = new model.SecurityService()>
    
    <!--- Get company users for owner/custodian selection --->
    <cfset companyUsers = securityService.getCompanyUsers(session.companyID)>
    
    <!--- Get assets with filters --->
    <cfset assets = riskService.getAssets(
        companyID: session.companyID,
        status: url.status ?: "",
        type: url.type ?: "",
        classification: url.classification ?: "",
        ownerID: val(url.ownerID ?: 0)
    )>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Asset Inventory</h2>
            <div>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#assetModal">
                    Add Asset
                </button>
            </div>
        </div>

        <!--- Filters --->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" class="row g-3">
                    <div class="col-md-2">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select">
                            <option value="">All Status</option>
                            <option value="active" <cfif url.status eq "active">selected</cfif>>Active</option>
                            <option value="inactive" <cfif url.status eq "inactive">selected</cfif>>Inactive</option>
                            <option value="retired" <cfif url.status eq "retired">selected</cfif>>Retired</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label">Type</label>
                        <select name="type" class="form-select">
                            <option value="">All Types</option>
                            <option value="hardware" <cfif url.type eq "hardware">selected</cfif>>Hardware</option>
                            <option value="software" <cfif url.type eq "software">selected</cfif>>Software</option>
                            <option value="data" <cfif url.type eq "data">selected</cfif>>Data</option>
                            <option value="service" <cfif url.type eq "service">selected</cfif>>Service</option>
                            <option value="facility" <cfif url.type eq "facility">selected</cfif>>Facility</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label">Classification</label>
                        <select name="classification" class="form-select">
                            <option value="">All Classifications</option>
                            <option value="public" <cfif url.classification eq "public">selected</cfif>>Public</option>
                            <option value="internal" <cfif url.classification eq "internal">selected</cfif>>Internal</option>
                            <option value="confidential" <cfif url.classification eq "confidential">selected</cfif>>Confidential</option>
                            <option value="restricted" <cfif url.classification eq "restricted">selected</cfif>>Restricted</option>
                        </select>
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label">Owner</label>
                        <select name="ownerID" class="form-select select2">
                            <option value="">All Owners</option>
                            <cfoutput query="companyUsers">
                                <option value="#userID#" <cfif url.ownerID eq userID>selected</cfif>>
                                    #firstName# #lastName#
                                </option>
                            </cfoutput>
                        </select>
                    </div>
                    
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary me-2">Apply Filters</button>
                        <a href="assets.cfm" class="btn btn-secondary">Reset</a>
                    </div>
                </form>
            </div>
        </div>

        <!--- Assets Table --->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Type</th>
                                <th>Classification</th>
                                <th>Value</th>
                                <th>Status</th>
                                <th>Owner</th>
                                <th>Custodian</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="assets">
                                <tr>
                                    <td>#name#</td>
                                    <td>#type#</td>
                                    <td>
                                        <span class="badge bg-#classification eq 'restricted' ? 'danger' :
                                                    (classification eq 'confidential' ? 'warning' :
                                                    (classification eq 'internal' ? 'info' : 'success'))#">
                                            #classification#
                                        </span>
                                    </td>
                                    <td>#dollarFormat(value)#</td>
                                    <td>
                                        <span class="badge bg-#status eq 'active' ? 'success' :
                                                    (status eq 'inactive' ? 'warning' : 'secondary')#">
                                            #status#
                                        </span>
                                    </td>
                                    <td>#ownerName#</td>
                                    <td>#custodianName#</td>
                                    <td>
                                        <button type="button" 
                                                class="btn btn-sm btn-primary edit-asset"
                                                data-id="#assetID#">
                                            Edit
                                        </button>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!--- Asset Modal --->
    <div class="modal fade" id="assetModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Asset Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="assetForm">
                        <input type="hidden" name="assetID" id="assetID" value="0">
                        <input type="hidden" name="companyID" value="#session.companyID#">
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Name</label>
                                <input type="text" class="form-control" name="name" id="name" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Type</label>
                                <select name="type" id="type" class="form-select" required>
                                    <option value="hardware">Hardware</option>
                                    <option value="software">Software</option>
                                    <option value="data">Data</option>
                                    <option value="service">Service</option>
                                    <option value="facility">Facility</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" id="description" rows="3"></textarea>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label">Status</label>
                                <select name="status" id="status" class="form-select" required>
                                    <option value="active">Active</option>
                                    <option value="inactive">Inactive</option>
                                    <option value="retired">Retired</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Value</label>
                                <input type="number" class="form-control" name="value" id="value" 
                                       step="0.01" min="0" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Classification</label>
                                <select name="classification" id="classification" class="form-select" required>
                                    <option value="public">Public</option>
                                    <option value="internal">Internal</option>
                                    <option value="confidential">Confidential</option>
                                    <option value="restricted">Restricted</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Owner</label>
                                <select name="ownerID" id="ownerID" class="form-select select2" required>
                                    <cfoutput query="companyUsers">
                                        <option value="#userID#">#firstName# #lastName#</option>
                                    </cfoutput>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Custodian</label>
                                <select name="custodianID" id="custodianID" class="form-select select2" required>
                                    <cfoutput query="companyUsers">
                                        <option value="#userID#">#firstName# #lastName#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="saveAsset">Save Asset</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        $(document).ready(function() {
            // Initialize Select2
            $('.select2').select2();
            
            // Edit asset
            $('.edit-asset').click(function() {
                const assetID = $(this).data('id');
                
                $.get('/api/risk/getAsset', { id: assetID }, function(response) {
                    if (response.success) {
                        const asset = response.asset;
                        $('#assetID').val(asset.assetID);
                        $('#name').val(asset.name);
                        $('#description').val(asset.description);
                        $('#type').val(asset.type);
                        $('#status').val(asset.status);
                        $('#value').val(asset.value);
                        $('#classification').val(asset.classification);
                        $('#ownerID').val(asset.ownerID).trigger('change');
                        $('#custodianID').val(asset.custodianID).trigger('change');
                        
                        $('#assetModal').modal('show');
                    }
                });
            });
            
            // Save asset
            $('#saveAsset').click(function() {
                $.post('/api/risk/saveAsset', $('#assetForm').serialize(), function(response) {
                    if (response.success) {
                        $('#assetModal').modal('hide');
                        location.reload();
                    } else {
                        alert('Error saving asset: ' + response.message);
                    }
                });
            });
            
            // Clear form when modal is closed
            $('#assetModal').on('hidden.bs.modal', function() {
                $('#assetForm')[0].reset();
                $('#assetID').val(0);
                $('.select2').val(null).trigger('change');
            });
        });
    </script>
</body>
</html> 