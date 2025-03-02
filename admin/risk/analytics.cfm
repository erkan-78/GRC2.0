<!DOCTYPE html>
<html>
<head>
    <title>Risk Analytics & Reporting</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <cfset riskService = new model.RiskService()>
    <cfset analytics = riskService.getRiskAnalytics(session.companyID)>
    <cfset trends = riskService.getRiskTrends(session.companyID)>
    <cfset kpis = riskService.getRiskKPIs(session.companyID)>
    
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Risk Analytics & Reporting</h2>
            <div>
                <button type="button" class="btn btn-primary" onclick="exportReport()">Export Report</button>
            </div>
        </div>

        <!--- Risk Overview Cards --->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body">
                        <h5 class="card-title">Total Risks</h5>
                        <h2 class="mb-0"><cfoutput>#analytics.totalRisks#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-danger text-white">
                    <div class="card-body">
                        <h5 class="card-title">High Risks</h5>
                        <h2 class="mb-0"><cfoutput>#analytics.highRisks#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <h5 class="card-title">Risks Above Tolerance</h5>
                        <h2 class="mb-0"><cfoutput>#analytics.aboveTolerance#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h5 class="card-title">Treated Risks</h5>
                        <h2 class="mb-0"><cfoutput>#analytics.treatedRisks#</cfoutput></h2>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <!--- Risk Distribution Chart --->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Risk Distribution by Category</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="riskDistributionChart"></canvas>
                    </div>
                </div>
            </div>

            <!--- Risk Trend Chart --->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Risk Level Trends</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="riskTrendChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!--- Risk KPIs --->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Risk KPIs</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>KPI</th>
                                <th>Target</th>
                                <th>Actual</th>
                                <th>Status</th>
                                <th>Trend</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="kpis">
                                <tr>
                                    <td>
                                        <strong>#name#</strong>
                                        <div class="small text-muted">#description#</div>
                                    </td>
                                    <td>#target_value#</td>
                                    <td>#actual_value#</td>
                                    <td>
                                        <span class="badge bg-#actual_value >= target_value ? 'success' : 'danger'#">
                                            #actual_value >= target_value ? 'On Target' : 'Below Target'#
                                        </span>
                                    </td>
                                    <td>
                                        <i class="fas fa-#trend eq 'up' ? 'arrow-up text-success' :
                                                    (trend eq 'down' ? 'arrow-down text-danger' : 
                                                    'arrow-right text-warning')#"></i>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!--- Risk Treatment Progress --->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Treatment Progress</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <canvas id="treatmentProgressChart"></canvas>
                    </div>
                    <div class="col-md-6">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Treatment Strategy</th>
                                        <th>Count</th>
                                        <th>Progress</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfoutput>
                                        <cfloop array="#analytics.treatmentProgress#" index="progress">
                                            <tr>
                                                <td>#progress.strategy#</td>
                                                <td>#progress.count#</td>
                                                <td>
                                                    <div class="progress">
                                                        <div class="progress-bar" role="progressbar" 
                                                             style="width: #progress.percentage#%"
                                                             aria-valuenow="#progress.percentage#" 
                                                             aria-valuemin="0" 
                                                             aria-valuemax="100">
                                                            #progress.percentage#%
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Initialize charts
        document.addEventListener('DOMContentLoaded', function() {
            // Risk Distribution Chart
            new Chart(document.getElementById('riskDistributionChart'), {
                type: 'pie',
                data: {
                    labels: <cfoutput>#serializeJSON(analytics.categoryLabels)#</cfoutput>,
                    datasets: [{
                        data: <cfoutput>#serializeJSON(analytics.categoryData)#</cfoutput>,
                        backgroundColor: [
                            '#007bff', '#28a745', '#ffc107', '#dc3545', '#17a2b8',
                            '#6610f2', '#fd7e14', '#20c997', '#e83e8c', '#6f42c1'
                        ]
                    }]
                }
            });

            // Risk Trend Chart
            new Chart(document.getElementById('riskTrendChart'), {
                type: 'line',
                data: {
                    labels: <cfoutput>#serializeJSON(trends.labels)#</cfoutput>,
                    datasets: [{
                        label: 'High Risks',
                        data: <cfoutput>#serializeJSON(trends.highRisks)#</cfoutput>,
                        borderColor: '#dc3545'
                    }, {
                        label: 'Medium Risks',
                        data: <cfoutput>#serializeJSON(trends.mediumRisks)#</cfoutput>,
                        borderColor: '#ffc107'
                    }, {
                        label: 'Low Risks',
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

            // Treatment Progress Chart
            new Chart(document.getElementById('treatmentProgressChart'), {
                type: 'doughnut',
                data: {
                    labels: <cfoutput>#serializeJSON(analytics.treatmentLabels)#</cfoutput>,
                    datasets: [{
                        data: <cfoutput>#serializeJSON(analytics.treatmentData)#</cfoutput>,
                        backgroundColor: [
                            '#28a745', '#17a2b8', '#ffc107', '#dc3545'
                        ]
                    }]
                }
            });
        });

        // Export report function
        function exportReport() {
            window.location.href = '/api/risk/exportReport?format=pdf';
        }
    </script>
</body>
</html> 