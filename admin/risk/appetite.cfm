<!DOCTYPE html>
<html>
<head>
    <title>Risk Appetite & Tolerance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <cfset riskService = new model.RiskService()>
    <cfset methodology = riskService.getRiskMethodology(session.companyID)>
    <cfset appetiteSettings = riskService.getRiskAppetiteSettings(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Risk Appetite & Tolerance Settings</h2>
        </div>

        <div class="card">
            <div class="card-body">
                <form id="appetiteForm">
                    <cfoutput query="methodology.categories">
                        <div class="row mb-4">
                            <div class="col-md-3">
                                <h5>#name#</h5>
                                <p class="text-muted small">#description#</p>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Risk Appetite Level</label>
                                <select name="appetite_#categoryID#" class="form-select" required>
                                    <option value="averse" <cfif appetiteSettings[categoryID].appetite_level eq "averse">selected</cfif>>Risk Averse</option>
                                    <option value="minimal" <cfif appetiteSettings[categoryID].appetite_level eq "minimal">selected</cfif>>Minimal</option>
                                    <option value="cautious" <cfif appetiteSettings[categoryID].appetite_level eq "cautious">selected</cfif>>Cautious</option>
                                    <option value="flexible" <cfif appetiteSettings[categoryID].appetite_level eq "flexible">selected</cfif>>Flexible</option>
                                    <option value="aggressive" <cfif appetiteSettings[categoryID].appetite_level eq "aggressive">selected</cfif>>Aggressive</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Tolerance Threshold (Risk Level)</label>
                                <input type="number" class="form-control" name="tolerance_#categoryID#" 
                                       value="#appetiteSettings[categoryID].tolerance_threshold#" min="1" max="25" required>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description_#categoryID#" rows="2">#appetiteSettings[categoryID].description#</textarea>
                            </div>
                        </div>
                    </cfoutput>
                    
                    <div class="text-end">
                        <button type="submit" class="btn btn-primary">Save Settings</button>
                    </div>
                </form>
            </div>
        </div>

        <!--- Risk Appetite Matrix --->
        <div class="card mt-4">
            <div class="card-header">
                <h5 class="mb-0">Risk Appetite Matrix</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Risk Category</th>
                                <th>Current Risk Level</th>
                                <th>Tolerance Threshold</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="methodology.categories">
                                <cfset currentLevel = riskService.getCurrentRiskLevelForCategory(
                                    session.companyID,
                                    categoryID
                                )>
                                <cfset threshold = appetiteSettings[categoryID].tolerance_threshold>
                                <tr>
                                    <td>#name#</td>
                                    <td>#currentLevel#</td>
                                    <td>#threshold#</td>
                                    <td>
                                        <span class="badge bg-#currentLevel gt threshold ? 'danger' : 'success'#">
                                            #currentLevel gt threshold ? 'Exceeds Tolerance' : 'Within Tolerance'#
                                        </span>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#appetiteForm').submit(function(e) {
                e.preventDefault();
                
                $.post('/api/risk/saveAppetiteSettings', $(this).serialize(), function(response) {
                    if (response.success) {
                        location.reload();
                    } else {
                        alert('Error saving settings: ' + response.message);
                    }
                });
            });
        });
    </script>
</body>
</html> 