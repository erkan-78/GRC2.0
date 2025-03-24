<cfset pageTitle = "Policy Management">
<cfset currentPage = "policy">

<cfset pageHeader = '
<div class="section-header d-flex justify-content-between align-items-center">
    <div>
        <h1 class="section-title">Policy Management</h1>
        <p class="text-muted">Manage organizational policies and procedures</p>
    </div>
    <div>
        <a href="new.cfm" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Policy
        </a>
    </div>
</div>
'>

<cfset body = '
<div class="content-box">
    <div class="row">
        <div class="col-md-3">
            <div class="info-card">
                <h6 class="text-muted">Active Policies</h6>
                <h2 class="text-primary">#activePolicyCount#</h2>
            </div>
        </div>
        <!-- Similar cards for other policy statistics -->
    </div>

    <div class="section-content mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="section-title">Policy Library</h3>
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
                    <th>Policy ID</th>
                    <th>Title</th>
                    <th>Type</th>
                    <th>Owner</th>
                    <th>Review Date</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="policies">
                    <tr>
                        <td>#policies.policyID#</td>
                        <td>#policies.title#</td>
                        <td>#policies.type#</td>
                        <td>#policies.ownerName#</td>
                        <td>#dateFormat(policies.reviewDate, "mmm d, yyyy")#</td>
                        <td>
                            <span class="badge badge-#policies.status#">
                                #policies.status#
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="view.cfm?id=#policies.policyID#" 
                                   class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="edit.cfm?id=#policies.policyID#" 
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