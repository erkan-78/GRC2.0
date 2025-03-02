<!DOCTYPE html>
<html>
<head>
    <title>Risk Assessment</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
    <style>
        .risk-matrix {
            width: 100%;
            border-collapse: separate;
            border-spacing: 2px;
        }
        .risk-matrix th {
            text-align: center;
            padding: 10px;
            background-color: #f8f9fa;
        }
        .risk-matrix td {
            width: 80px;
            height: 80px;
            text-align: center;
            cursor: pointer;
            position: relative;
        }
        .risk-matrix td .risk-count {
            position: absolute;
            top: 5px;
            right: 5px;
            font-size: 12px;
            font-weight: bold;
        }
        .risk-matrix td:hover {
            opacity: 0.8;
        }
        .treatment-status {
            width: 15px;
            height: 15px;
            display: inline-block;
            border-radius: 50%;
            margin-right: 5px;
        }
    </style>
</head>
<body>
    <cfset riskService = new model.RiskService()>
    <cfset methodology = riskService.getRiskMethodology(session.companyID)>
    <cfset assets = riskService.getAssets(session.companyID)>
    <cfset risks = riskService.getRisks(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Risk Assessment</h2>
            <div>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#riskModal">
                    Add Risk
                </button>
            </div>
        </div>

        <!--- Risk Matrix --->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Risk Matrix</h5>
            </div>
            <div class="card-body">
                <table class="risk-matrix">
                    <thead>
                        <tr>
                            <th></th>
                            <cfoutput query="methodology.impacts">
                                <th>#name#</th>
                            </cfoutput>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="methodology.probabilities">
                            <tr>
                                <th>#name#</th>
                                <cfloop query="methodology.impacts">
                                    <cfset riskLevel = level * methodology.probabilities.level>
                                    <cfset cellColor = riskLevel <= 4 ? '##28a745' :
                                                     (riskLevel <= 8 ? '##ffc107' :
                                                     (riskLevel <= 12 ? '##fd7e14' : '##dc3545'))>
                                    <cfset cellRisks = riskService.getRisksByLevel(
                                        session.companyID,
                                        methodology.probabilities.level,
                                        methodology.impacts.level
                                    )>
                                    <td style="background-color: #cellColor#" 
                                        data-prob="#methodology.probabilities.level#"
                                        data-impact="#methodology.impacts.level#">
                                        <div class="risk-count">#cellRisks.recordCount#</div>
                                        #riskLevel#
                                    </td>
                                </cfloop>
                            </tr>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        </div>

        <!--- Risk List --->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Risk Register</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Category</th>
                                <th>Affected Assets</th>
                                <th>Probability</th>
                                <th>Impact</th>
                                <th>Risk Level</th>
                                <th>Treatment Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="risks">
                                <tr>
                                    <td>#title#</td>
                                    <td>#categoryName#</td>
                                    <td>
                                        <cfloop list="#assetList#" index="asset">
                                            <span class="badge bg-secondary">#asset#</span>
                                        </cfloop>
                                    </td>
                                    <td>#probabilityName#</td>
                                    <td>#impactName#</td>
                                    <td>
                                        <span class="badge bg-#riskLevel <= 4 ? 'success' :
                                                    (riskLevel <= 8 ? 'warning' :
                                                    (riskLevel <= 12 ? 'orange' : 'danger'))#">
                                            #riskLevel#
                                        </span>
                                    </td>
                                    <td>
                                        <span class="treatment-status" 
                                              style="background-color: #treatmentStatus eq 'planned' ? '##ffc107' :
                                                    (treatmentStatus eq 'in_progress' ? '##17a2b8' :
                                                    (treatmentStatus eq 'completed' ? '##28a745' : '##dc3545'))#">
                                        </span>
                                        #treatmentStatus#
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-sm btn-primary edit-risk"
                                                    data-id="#riskID#">
                                                Edit
                                            </button>
                                            <button type="button" class="btn btn-sm btn-info view-treatment"
                                                    data-id="#riskID#">
                                                Treatment
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

    <!--- Risk Modal --->
    <div class="modal fade" id="riskModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Risk Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="riskForm">
                        <input type="hidden" name="riskID" id="riskID" value="0">
                        <input type="hidden" name="companyID" value="#session.companyID#">
                        
                        <div class="row mb-3">
                            <div class="col-md-8">
                                <label class="form-label">Title</label>
                                <input type="text" class="form-control" name="title" id="title" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Category</label>
                                <select name="categoryID" id="categoryID" class="form-select" required>
                                    <cfoutput query="methodology.categories">
                                        <option value="#categoryID#">#name#</option>
                                    </cfoutput>
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
                            <div class="col-md-12">
                                <label class="form-label">Affected Assets</label>
                                <select name="assetIDs" id="assetIDs" class="form-select select2" multiple required>
                                    <cfoutput query="assets">
                                        <option value="#assetID#">#name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Probability</label>
                                <select name="probabilityID" id="probabilityID" class="form-select" required>
                                    <cfoutput query="methodology.probabilities">
                                        <option value="#categoryID#">#name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Impact</label>
                                <select name="impactID" id="impactID" class="form-select" required>
                                    <cfoutput query="methodology.impacts">
                                        <option value="#categoryID#">#name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="saveRisk">Save Risk</button>
                </div>
            </div>
        </div>
    </div>

    <!--- Treatment Modal --->
    <div class="modal fade" id="treatmentModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Risk Treatment Plan</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="treatmentForm">
                        <input type="hidden" name="riskID" id="treatment_riskID">
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Treatment Strategy</label>
                                <select name="strategy" id="strategy" class="form-select" required>
                                    <option value="mitigate">Mitigate</option>
                                    <option value="transfer">Transfer</option>
                                    <option value="avoid">Avoid</option>
                                    <option value="accept">Accept</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Status</label>
                                <select name="status" id="treatment_status" class="form-select" required>
                                    <option value="not_started">Not Started</option>
                                    <option value="planned">Planned</option>
                                    <option value="in_progress">In Progress</option>
                                    <option value="completed">Completed</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label class="form-label">Treatment Plan</label>
                                <textarea class="form-control" name="plan" id="plan" rows="3" required></textarea>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Due Date</label>
                                <input type="date" class="form-control" name="dueDate" id="dueDate" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Assigned To</label>
                                <select name="assignedTo" id="assignedTo" class="form-select select2" required>
                                    <cfoutput query="companyUsers">
                                        <option value="#userID#">#firstName# #lastName#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label class="form-label">Controls</label>
                                <div id="controlsList">
                                    <div class="control-item mb-2">
                                        <div class="input-group">
                                            <input type="text" class="form-control" name="controls[]" 
                                                   placeholder="Enter control measure">
                                            <button type="button" class="btn btn-danger remove-control">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-secondary btn-sm" id="addControl">
                                    Add Control
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="saveTreatment">Save Treatment Plan</button>
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
            
            // Risk Matrix cell click
            $('.risk-matrix td').click(function() {
                const prob = $(this).data('prob');
                const impact = $(this).data('impact');
                
                $.get('/api/risk/getRisksByLevel', {
                    companyID: <cfoutput>#session.companyID#</cfoutput>,
                    probability: prob,
                    impact: impact
                }, function(response) {
                    if (response.success) {
                        // Show risks in a modal or panel
                    }
                });
            });
            
            // Edit risk
            $('.edit-risk').click(function() {
                const riskID = $(this).data('id');
                
                $.get('/api/risk/getRisk', { id: riskID }, function(response) {
                    if (response.success) {
                        const risk = response.risk;
                        $('#riskID').val(risk.riskID);
                        $('#title').val(risk.title);
                        $('#description').val(risk.description);
                        $('#categoryID').val(risk.categoryID);
                        $('#assetIDs').val(risk.assetIDs.split(',')).trigger('change');
                        $('#probabilityID').val(risk.probabilityID);
                        $('#impactID').val(risk.impactID);
                        
                        $('#riskModal').modal('show');
                    }
                });
            });
            
            // View treatment
            $('.view-treatment').click(function() {
                const riskID = $(this).data('id');
                
                $.get('/api/risk/getTreatment', { id: riskID }, function(response) {
                    if (response.success) {
                        const treatment = response.treatment;
                        $('#treatment_riskID').val(riskID);
                        $('#strategy').val(treatment.strategy);
                        $('#treatment_status').val(treatment.status);
                        $('#plan').val(treatment.plan);
                        $('#dueDate').val(treatment.dueDate);
                        $('#assignedTo').val(treatment.assignedTo).trigger('change');
                        
                        // Load controls
                        $('#controlsList').empty();
                        treatment.controls.forEach(function(control) {
                            addControlItem(control);
                        });
                        
                        $('#treatmentModal').modal('show');
                    }
                });
            });
            
            // Add control
            $('#addControl').click(function() {
                addControlItem('');
            });
            
            // Remove control
            $(document).on('click', '.remove-control', function() {
                $(this).closest('.control-item').remove();
            });
            
            function addControlItem(value) {
                const template = `
                    <div class="control-item mb-2">
                        <div class="input-group">
                            <input type="text" class="form-control" name="controls[]" 
                                   value="${value}" placeholder="Enter control measure">
                            <button type="button" class="btn btn-danger remove-control">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                `;
                $('#controlsList').append(template);
            }
            
            // Save risk
            $('#saveRisk').click(function() {
                $.post('/api/risk/saveRisk', $('#riskForm').serialize(), function(response) {
                    if (response.success) {
                        $('#riskModal').modal('hide');
                        location.reload();
                    } else {
                        alert('Error saving risk: ' + response.message);
                    }
                });
            });
            
            // Save treatment
            $('#saveTreatment').click(function() {
                $.post('/api/risk/saveTreatment', $('#treatmentForm').serialize(), function(response) {
                    if (response.success) {
                        $('#treatmentModal').modal('hide');
                        location.reload();
                    } else {
                        alert('Error saving treatment plan: ' + response.message);
                    }
                });
            });
        });
    </script>
</body>
</html> 