<cfif not structKeyExists(session, "userID")>
    <cflocation url="login.cfm" addToken="false">
</cfif>

<cfset userService = application.userService>
<cfset dashboardService = application.dashboardService>
<cfset languageService = application.languageService>
<cfset currentUser = userService.getCurrentUser()>
<cfset userPermissions = userService.getUserPermissions(session.userID)>
<cfset dashboardStats = dashboardService.getDashboardStatistics(session.userID)>
<cfset labels = languageService.getModuleLabels("dashboard", session.userLanguage)>

<cfoutput>
<!DOCTYPE html>
<html lang="#session.userLanguage#">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GRC Dashboard</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/fontawesome.min.css" rel="stylesheet">
    <link href="assets/css/dashboard.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <!-- Welcome Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="welcome-header p-4 bg-primary text-white rounded">
                    <h1>#labels.welcome.title#, #currentUser.firstName# #currentUser.lastName#</h1>
                    <p class="lead">
                        #languageService.formatDate(now(), session.userLanguage)# | 
                        #labels.welcome.last_login#: #languageService.formatDateTime(currentUser.lastLoginDate, session.userLanguage)#
                    </p>
                </div>
            </div>
        </div>

        <!-- Quick Stats -->
        <div class="row mb-4">
            <cfif userPermissions.hasAccess("risk_management")>
                <div class="col-md-3">
                    <div class="stat-card bg-warning text-white">
                        <div class="stat-card-body">
                            <h5>#labels.stats.high_risks#</h5>
                            <h2>#dashboardStats.highRiskCount#</h2>
                            <p>#labels.stats.requiring_attention#</p>
                        </div>
                    </div>
                </div>
            </cfif>
            
            <cfif userPermissions.hasAccess("policy_management")>
                <div class="col-md-3">
                    <div class="stat-card bg-info text-white">
                        <div class="stat-card-body">
                            <h5>#labels.stats.pending_reviews#</h5>
                            <h2>#dashboardStats.pendingPolicyReviews#</h2>
                            <p>#labels.stats.policy_documents#</p>
                        </div>
                    </div>
                </div>
            </cfif>
            
            <!-- Similar updates for other stat cards -->
        </div>

        <!-- Main Sections -->
        <div class="row">
            <!-- Risk Management -->
            <cfif userPermissions.hasAccess("risk_management")>
                <div class="col-md-6 mb-4">
                    <div class="section-card">
                        <div class="section-card-header">
                            <h3>#labels.sections.risk.title#</h3>
                            <a href="admin/risk/index.cfm" class="btn btn-primary btn-sm">
                                #labels.sections.risk.view_all#
                            </a>
                        </div>
                        <div class="section-card-body">
                            <div class="quick-actions mb-3">
                                <a href="admin/risk/new.cfm" class="btn btn-outline-primary btn-sm">
                                    #labels.sections.risk.new_assessment#
                                </a>
                                <a href="admin/risk/dashboard.cfm" class="btn btn-outline-primary btn-sm">
                                    #labels.sections.risk.risk_dashboard#
                                </a>
                            </div>
                            <div class="recent-items">
                                <h6>#labels.sections.risk.recent_updates#</h6>
                                <cfset recentRisks = dashboardService.getRecentRisks(5)>
                                <cfloop query="recentRisks">
                                    <div class="recent-item">
                                        <span class="badge badge-#recentRisks.riskLevel#">
                                            #labels.status[recentRisks.riskLevel]#
                                        </span>
                                        <span class="item-title">#recentRisks.title#</span>
                                        <span class="item-date">
                                            #languageService.formatDate(recentRisks.updateDate, session.userLanguage)#
                                        </span>
                                    </div>
                                </cfloop>
                            </div>
                        </div>
                    </div>
                </div>
            </cfif>

            <!-- Similar updates for other sections -->
        </div>
    </div>

    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/bootstrap.bundle.min.js"></script>
    <script>
        // Add language to AJAX requests
        $.ajaxSetup({
            beforeSend: function(xhr) {
                xhr.setRequestHeader('Accept-Language', '#session.userLanguage#');
            }
        });
    </script>
    <script src="assets/js/dashboard.js"></script>
</body>
</html>
</cfoutput> 