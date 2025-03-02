<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .header { text-align: center; margin-bottom: 20px; }
        .section { margin-bottom: 30px; }
        .metrics { display: flex; justify-content: space-between; margin-bottom: 20px; }
        .metric { text-align: center; padding: 10px; border: 1px solid #ddd; width: 23%; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th, td { padding: 8px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #f5f5f5; }
        .chart-container { margin-bottom: 20px; text-align: center; }
    </style>
</head>
<body>
    <cfset labelService = new model.LabelService()>
    
    <div class="header">
        <h1><cfoutput>#getLabel('executive_risk_dashboard', 'Executive Risk Dashboard')#</cfoutput></h1>
        <p><cfoutput>#dateFormat(now(), "yyyy-mm-dd")# #timeFormat(now(), "HH:mm")#</cfoutput></p>
    </div>

    <div class="section">
        <h2><cfoutput>#getLabel('risk_metrics', 'Risk Metrics')#</cfoutput></h2>
        <div class="metrics">
            <div class="metric">
                <h3><cfoutput>#getLabel('total_risks', 'Total Risks')#</cfoutput></h3>
                <p><cfoutput>#analytics.totalRisks#</cfoutput></p>
            </div>
            <div class="metric">
                <h3><cfoutput>#getLabel('critical_risks', 'Critical Risks')#</cfoutput></h3>
                <p><cfoutput>#analytics.highRisks#</cfoutput></p>
            </div>
            <div class="metric">
                <h3><cfoutput>#getLabel('above_tolerance', 'Above Tolerance')#</cfoutput></h3>
                <p><cfoutput>#analytics.aboveTolerance#</cfoutput></p>
            </div>
            <div class="metric">
                <h3><cfoutput>#getLabel('treated_risks', 'Treated Risks')#</cfoutput></h3>
                <p><cfoutput>#analytics.treatedRisks#</cfoutput></p>
            </div>
        </div>
    </div>

    <div class="section">
        <h2><cfoutput>#getLabel('top_risks', 'Top Risks')#</cfoutput></h2>
        <table>
            <thead>
                <tr>
                    <th><cfoutput>#getLabel('risk_title', 'Risk Title')#</cfoutput></th>
                    <th><cfoutput>#getLabel('category', 'Category')#</cfoutput></th>
                    <th><cfoutput>#getLabel('risk_level', 'Risk Level')#</cfoutput></th>
                    <th><cfoutput>#getLabel('treatment_status', 'Treatment Status')#</cfoutput></th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="topRisks" maxrows="5">
                    <tr>
                        <td>#title#</td>
                        <td>#categoryName#</td>
                        <td>#riskLevel#</td>
                        <td>#getLabel('treatment_status_' & treatmentStatus, treatmentStatus)#</td>
                    </tr>
                </cfoutput>
            </tbody>
        </table>
    </div>

    <div class="section">
        <h2><cfoutput>#getLabel('risk_kpis', 'Risk KPIs')#</cfoutput></h2>
        <table>
            <thead>
                <tr>
                    <th><cfoutput>#getLabel('kpi_name', 'KPI Name')#</cfoutput></th>
                    <th><cfoutput>#getLabel('target', 'Target')#</cfoutput></th>
                    <th><cfoutput>#getLabel('actual', 'Actual')#</cfoutput></th>
                    <th><cfoutput>#getLabel('status', 'Status')#</cfoutput></th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="kpis">
                    <tr>
                        <td>#getLabel('kpi_' & name, name)#</td>
                        <td>#target_value#</td>
                        <td>#actual_value#</td>
                        <td>#actual_value >= target_value ? getLabel('on_target', 'On Target') : getLabel('below_target', 'Below Target')#</td>
                    </tr>
                </cfoutput>
            </tbody>
        </table>
    </div>
</body>
</html> 