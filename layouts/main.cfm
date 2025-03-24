<!DOCTYPE html>
<html lang="#session.userLanguage ?: 'en'#">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - <cfoutput>#pageTitle#</cfoutput></title>
    <link href="/assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="/assets/css/base.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <cfif structKeyExists(variables, "additionalCSS")>
        <cfoutput>#additionalCSS#</cfoutput>
    </cfif>
</head>
<body>
    <div class="page-container">
        <!-- Sidebar Navigation -->
        <nav class="main-nav">
            <div class="brand-header">
                <div class="logo-text">Light<span class="highlight">GRC</span></div>
            </div>
            
            <div class="nav-menu">
                <cfif userPermissions.hasAccess("dashboard")>
                    <a href="/dashboard" class="nav-item #(currentPage == 'dashboard') ? 'active' : ''#">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                </cfif>
                
                <cfif userPermissions.hasAccess("risk_management")>
                    <a href="/admin/risk" class="nav-item #(currentPage == 'risk') ? 'active' : ''#">
                        <i class="fas fa-shield-alt"></i> Risk Management
                    </a>
                </cfif>
                
                <cfif userPermissions.hasAccess("policy_management")>
                    <a href="/admin/policy" class="nav-item #(currentPage == 'policy') ? 'active' : ''#">
                        <i class="fas fa-file-alt"></i> Policy Management
                    </a>
                </cfif>
                
                <cfif userPermissions.hasAccess("audit_management")>
                    <a href="/admin/audit" class="nav-item #(currentPage == 'audit') ? 'active' : ''#">
                        <i class="fas fa-clipboard-check"></i> Audit Management
                    </a>
                </cfif>
                
                <cfif userPermissions.hasAccess("compliance_management")>
                    <a href="/admin/compliance" class="nav-item #(currentPage == 'compliance') ? 'active' : ''#">
                        <i class="fas fa-check-circle"></i> Compliance
                    </a>
                </cfif>
                
                <cfif userPermissions.hasAccess("automation_management")>
                    <a href="/admin/automation" class="nav-item #(currentPage == 'automation') ? 'active' : ''#">
                        <i class="fas fa-robot"></i> Automation
                    </a>
                </cfif>
            </div>
            
            <div class="nav-footer">
                <div class="user-menu">
                    <img src="#session.userAvatar#" alt="Profile" class="user-avatar">
                    <div class="user-info">
                        <div class="user-name">#session.userFirstName# #session.userLastName#</div>
                        <div class="user-role">#session.userRole#</div>
                    </div>
                    <div class="dropdown-menu">
                        <a href="/profile" class="dropdown-item">Profile</a>
                        <a href="/settings" class="dropdown-item">Settings</a>
                        <div class="dropdown-divider"></div>
                        <a href="/logout" class="dropdown-item">Logout</a>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main Content -->
        <div class="content-wrapper">
            <cfif structKeyExists(variables, "pageHeader")>
                <div class="page-header">
                    <cfoutput>#pageHeader#</cfoutput>
                </div>
            </cfif>
            
            <div class="page-content">
                <cfoutput>#body#</cfoutput>
            </div>
        </div>
    </div>

    <script src="/assets/js/bootstrap.bundle.min.js"></script>
    <script src="/assets/js/app.js"></script>
    <cfif structKeyExists(variables, "additionalJS")>
        <cfoutput>#additionalJS#</cfoutput>
    </cfif>
</body>
</html> 