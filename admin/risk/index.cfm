<cfset pageTitle = "Risk Management">
<cfset currentPage = "risk">

<cfset pageHeader = '
<div class="section-header d-flex justify-content-between align-items-center">
    <div>
        <h1 class="section-title">Risk Management</h1>
        <p class="text-muted">Manage and monitor organizational risks</p>
    </div>
    <div>
        <a href="new.cfm" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Risk Assessment
        </a>
    </div>
</div>
'>

<cfset body = '
<div class="content-box">
    <div class="row">
        <div class="col-md-3">
            <div class="info-card">
                <h6 class="text-muted">High Risks</h6>
                <h2 class="text-danger">#highRiskCount#</h2>
                <div class="card-trend">
                    <span class="trend-indicator up">+2.5%</span>
                    <span class="trend-period">vs last month</span>
                </div>
            </div>
        </div>
        <!-- Similar cards for Medium, Low, and Total Risks -->
    </div>

    <div class="section-content mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="section-title">Risk Register</h3>
            <div class="actions">
                <button class="btn btn-outline-primary">
                    <i class="fas fa-filter"></i> Filter
                </button>
                <button class="btn btn-outline-primary">
                    <i class="fas fa-download"></i> Export
                </button>
            </div>
        </div>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Risk ID</th>
                    <th>Title</th>
                    <th>Level</th>
                    <th>Category</th>
                    <th>Owner</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="risks">
                    <tr>
                        <td>#risks.riskID#</td>
                        <td>#risks.title#</td>
                        <td>
                            <span class="badge badge-#risks.level#">
                                #risks.level#
                            </span>
                        </td>
                        <td>#risks.category#</td>
                        <td>#risks.ownerName#</td>
                        <td>
                            <span class="badge badge-#risks.status#">
                                #risks.status#
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="view.cfm?id=#risks.riskID#" 
                                   class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="edit.cfm?id=#risks.riskID#" 
                                   class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-edit"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                </cfoutput>
            </tbody>
        </table>
    </div>
</div>
'>

<cfinclude template="/layouts/main.cfm"> 