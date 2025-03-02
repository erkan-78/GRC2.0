<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('executive_risk_dashboard', 'Executive Risk Dashboard')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <cfset riskService = new model.RiskService()>
    <cfset labelService = new model.LabelService()>
    <cfset analytics = riskService.getRiskAnalytics(session.companyID)>
    <cfset trends = riskService.getRiskTrends(session.companyID)>
    <cfset kpis = riskService.getRiskKPIs(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><cfoutput>#getLabel('executive_risk_overview', 'Risk Overview')#</cfoutput></h2>
            <div>
                <button type="button" class="btn btn-primary" onclick="exportDashboard()">
                    <cfoutput>#getLabel('export_dashboard', 'Export Dashboard')#</cfoutput>
                </button>
            </div>
        </div>

        <!--- Executive Summary Cards --->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('total_risks', 'Total Risks')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#analytics.totalRisks#</cfoutput></h2>
                            <i class="fas fa-shield-alt fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-danger text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('critical_risks', 'Critical Risks')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#analytics.highRisks#</cfoutput></h2>
                            <i class="fas fa-exclamation-triangle fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('above_tolerance', 'Above Tolerance')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#analytics.aboveTolerance#</cfoutput></h2>
                            <i class="fas fa-arrow-up fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('treated_risks', 'Treated Risks')#</cfoutput></h6>
                        <div class="d-flex justify-content-between align-items-center">
                            <h2 class="mb-0"><cfoutput>#analytics.treatedRisks#</cfoutput></h2>
                            <i class="fas fa-check-circle fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <!--- Risk Heat Map --->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('risk_heat_map', 'Risk Heat Map')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <canvas id="riskHeatMap"></canvas>
                    </div>
                </div>
            </div>

            <!--- Risk Trend Chart --->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('risk_trends', 'Risk Trends')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <canvas id="riskTrendChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <!--- Top Risks Table --->
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('top_risks', 'Top Risks')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th><cfoutput>#getLabel('risk_title', 'Risk Title')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('category', 'Category')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('risk_level', 'Risk Level')#</cfoutput></th>
                                        <th><cfoutput>#getLabel('treatment_status', 'Treatment Status')#</cfoutput></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfset topRisks = riskService.getRisks(session.companyID)>
                                    <cfoutput query="topRisks" maxrows="5">
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
                                            <td>
                                                <span class="badge bg-#treatmentStatus eq 'completed' ? 'success' :
                                                            (treatmentStatus eq 'in_progress' ? 'warning' : 'secondary')#">
                                                    #getLabel('treatment_status_' & treatmentStatus, treatmentStatus)#
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

            <!--- Risk KPIs --->
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('risk_kpis', 'Risk KPIs')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <cfoutput query="kpis">
                            <div class="mb-3">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span>#getLabel('kpi_' & name, name)#</span>
                                    <span class="badge bg-#actual_value >= target_value ? 'success' : 'danger'#">
                                        #actual_value#/#target_value#
                                    </span>
                                </div>
                                <div class="progress">
                                    <div class="progress-bar bg-#actual_value >= target_value ? 'success' : 'danger'#"
                                         role="progressbar"
                                         style="width: #min(100, (actual_value/target_value) * 100)#%">
                                    </div>
                                </div>
                            </div>
                        </cfoutput>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Risk Heat Map
            const heatMapData = <cfoutput>#serializeJSON(riskService.getRisksByLevel(session.companyID))#</cfoutput>;
            const heatMapCtx = document.getElementById('riskHeatMap').getContext('2d');
            new Chart(heatMapCtx, {
                type: 'bubble',
                data: {
                    datasets: [{
                        data: heatMapData.map(risk => ({
                            x: risk.probability,
                            y: risk.impact,
                            r: risk.count * 5
                        })),
                        backgroundColor: 'rgba(255, 99, 132, 0.5)'
                    }]
                },
                options: {
                    scales: {
                        x: {
                            title: {
                                display: true,
                                text: <cfoutput>'#getLabel("probability", "Probability")#'</cfoutput>
                            },
                            min: 1,
                            max: 5
                        },
                        y: {
                            title: {
                                display: true,
                                text: <cfoutput>'#getLabel("impact", "Impact")#'</cfoutput>
                            },
                            min: 1,
                            max: 5
                        }
                    }
                }
            });

            // Risk Trend Chart
            const trendCtx = document.getElementById('riskTrendChart').getContext('2d');
            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: <cfoutput>#serializeJSON(trends.labels)#</cfoutput>,
                    datasets: [{
                        label: <cfoutput>'#getLabel("high_risks", "High Risks")#'</cfoutput>,
                        data: <cfoutput>#serializeJSON(trends.highRisks)#</cfoutput>,
                        borderColor: '#dc3545'
                    }, {
                        label: <cfoutput>'#getLabel("medium_risks", "Medium Risks")#'</cfoutput>,
                        data: <cfoutput>#serializeJSON(trends.mediumRisks)#</cfoutput>,
                        borderColor: '#ffc107'
                    }, {
                        label: <cfoutput>'#getLabel("low_risks", "Low Risks")#'</cfoutput>,
                        data: <cfoutput>#serializeJSON(trends.lowRisks)#</cfoutput>,
                        borderColor: '#28a745'
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        });

        function exportDashboard() {
            window.location.href = '/api/risk/exportDashboard?format=pdf';
        }
    </script>
</body>
</html> 