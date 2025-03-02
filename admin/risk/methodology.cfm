<!DOCTYPE html>
<html>
<head>
    <title>Risk Methodology Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-colorpicker@3.4.0/dist/css/bootstrap-colorpicker.min.css" rel="stylesheet">
</head>
<body>
    <cfset riskService = new model.RiskService()>
    <cfset methodology = riskService.getRiskMethodology(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Risk Methodology Management</h2>
            <div>
                <cfif structKeyExists(methodology, "version")>
                    <span class="badge bg-info me-2">Version #methodology.version#</span>
                    <span class="badge bg-#methodology.status eq 'approved' ? 'success' : 'warning'#">
                        #uCase(methodology.status)#
                    </span>
                </cfif>
            </div>
        </div>

        <form id="methodologyForm" method="post" action="/api/risk/saveMethodology">
            <input type="hidden" name="companyID" value="#session.companyID#">
            
            <!--- Probability Categories --->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Probability Categories</h5>
                </div>
                <div class="card-body">
                    <div id="probabilityCategories">
                        <cfif structKeyExists(methodology, "probabilities")>
                            <cfoutput query="methodology.probabilities">
                                <div class="row mb-3 probability-category">
                                    <div class="col-md-2">
                                        <label class="form-label">Level</label>
                                        <input type="number" class="form-control" name="prob_level[]" 
                                               value="#level#" min="1" required>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Name</label>
                                        <input type="text" class="form-control" name="prob_name[]" 
                                               value="#name#" required>
                                    </div>
                                    <div class="col-md-5">
                                        <label class="form-label">Description</label>
                                        <input type="text" class="form-control" name="prob_description[]" 
                                               value="#description#">
                                    </div>
                                    <div class="col-md-1">
                                        <label class="form-label">Color</label>
                                        <input type="text" class="form-control color-picker" name="prob_color[]" 
                                               value="#color#">
                                    </div>
                                    <div class="col-md-1 d-flex align-items-end">
                                        <button type="button" class="btn btn-danger remove-category">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </cfoutput>
                        </cfif>
                    </div>
                    <button type="button" class="btn btn-secondary" id="addProbability">
                        Add Probability Category
                    </button>
                </div>
            </div>

            <!--- Impact Categories --->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Impact Categories</h5>
                </div>
                <div class="card-body">
                    <div id="impactCategories">
                        <cfif structKeyExists(methodology, "impacts")>
                            <cfoutput query="methodology.impacts">
                                <div class="row mb-3 impact-category">
                                    <div class="col-md-2">
                                        <label class="form-label">Level</label>
                                        <input type="number" class="form-control" name="impact_level[]" 
                                               value="#level#" min="1" required>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Name</label>
                                        <input type="text" class="form-control" name="impact_name[]" 
                                               value="#name#" required>
                                    </div>
                                    <div class="col-md-5">
                                        <label class="form-label">Description</label>
                                        <input type="text" class="form-control" name="impact_description[]" 
                                               value="#description#">
                                    </div>
                                    <div class="col-md-1">
                                        <label class="form-label">Color</label>
                                        <input type="text" class="form-control color-picker" name="impact_color[]" 
                                               value="#color#">
                                    </div>
                                    <div class="col-md-1 d-flex align-items-end">
                                        <button type="button" class="btn btn-danger remove-category">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </cfoutput>
                        </cfif>
                    </div>
                    <button type="button" class="btn btn-secondary" id="addImpact">
                        Add Impact Category
                    </button>
                </div>
            </div>

            <!--- Risk Categories --->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Risk Categories</h5>
                </div>
                <div class="card-body">
                    <div id="riskCategories">
                        <cfif structKeyExists(methodology, "categories")>
                            <cfoutput query="methodology.categories">
                                <div class="row mb-3 risk-category">
                                    <div class="col-md-4">
                                        <label class="form-label">Name</label>
                                        <input type="text" class="form-control" name="cat_name[]" 
                                               value="#name#" required>
                                    </div>
                                    <div class="col-md-7">
                                        <label class="form-label">Description</label>
                                        <input type="text" class="form-control" name="cat_description[]" 
                                               value="#description#">
                                    </div>
                                    <div class="col-md-1 d-flex align-items-end">
                                        <button type="button" class="btn btn-danger remove-category">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </cfoutput>
                        </cfif>
                    </div>
                    <button type="button" class="btn btn-secondary" id="addRiskCategory">
                        Add Risk Category
                    </button>
                </div>
            </div>

            <div class="text-end">
                <button type="submit" class="btn btn-primary">Save Methodology</button>
            </div>
        </form>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap-colorpicker@3.4.0/dist/js/bootstrap-colorpicker.min.js"></script>
    <script src="https://kit.fontawesome.com/your-fontawesome-kit.js"></script>
    <script>
        $(document).ready(function() {
            // Initialize colorpickers
            $('.color-picker').colorpicker();
            
            // Add Probability Category
            $('#addProbability').click(function() {
                var template = `
                    <div class="row mb-3 probability-category">
                        <div class="col-md-2">
                            <label class="form-label">Level</label>
                            <input type="number" class="form-control" name="prob_level[]" min="1" required>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Name</label>
                            <input type="text" class="form-control" name="prob_name[]" required>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label">Description</label>
                            <input type="text" class="form-control" name="prob_description[]">
                        </div>
                        <div class="col-md-1">
                            <label class="form-label">Color</label>
                            <input type="text" class="form-control color-picker" name="prob_color[]">
                        </div>
                        <div class="col-md-1 d-flex align-items-end">
                            <button type="button" class="btn btn-danger remove-category">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
                $('#probabilityCategories').append(template);
                $('.color-picker').colorpicker();
            });
            
            // Add Impact Category
            $('#addImpact').click(function() {
                var template = `
                    <div class="row mb-3 impact-category">
                        <div class="col-md-2">
                            <label class="form-label">Level</label>
                            <input type="number" class="form-control" name="impact_level[]" min="1" required>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Name</label>
                            <input type="text" class="form-control" name="impact_name[]" required>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label">Description</label>
                            <input type="text" class="form-control" name="impact_description[]">
                        </div>
                        <div class="col-md-1">
                            <label class="form-label">Color</label>
                            <input type="text" class="form-control color-picker" name="impact_color[]">
                        </div>
                        <div class="col-md-1 d-flex align-items-end">
                            <button type="button" class="btn btn-danger remove-category">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
                $('#impactCategories').append(template);
                $('.color-picker').colorpicker();
            });
            
            // Add Risk Category
            $('#addRiskCategory').click(function() {
                var template = `
                    <div class="row mb-3 risk-category">
                        <div class="col-md-4">
                            <label class="form-label">Name</label>
                            <input type="text" class="form-control" name="cat_name[]" required>
                        </div>
                        <div class="col-md-7">
                            <label class="form-label">Description</label>
                            <input type="text" class="form-control" name="cat_description[]">
                        </div>
                        <div class="col-md-1 d-flex align-items-end">
                            <button type="button" class="btn btn-danger remove-category">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
                $('#riskCategories').append(template);
            });
            
            // Remove category
            $(document).on('click', '.remove-category', function() {
                $(this).closest('.row').remove();
            });
            
            // Form submission
            $('#methodologyForm').submit(function(e) {
                e.preventDefault();
                
                $.post($(this).attr('action'), $(this).serialize(), function(response) {
                    if (response.success) {
                        alert('Methodology saved successfully and sent for approval');
                        location.reload();
                    } else {
                        alert('Error saving methodology: ' + response.message);
                    }
                });
            });
        });
    </script>
</body>
</html> 