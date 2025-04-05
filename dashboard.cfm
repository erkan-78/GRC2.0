<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
  <script src="assets/js/bootstrap.bundle.min.js"></script>
    <!--- Check if user is logged in --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
        <cflocation url="login.cfm" addtoken="false">
    </cfif>
  <cfset pageid="dashboard">
    <!--- Get available languages --->
    <cfquery name="getLanguages" datasource="#application.datasource#">
        SELECT languageID, languageName
        FROM languages
        WHERE isActive = 1
        ORDER BY languageName
    </cfquery>
    <cfif isDefined("url.languageID")>
     <cfloop query="getLanguages">
        <cfif languageID EQ url.languageID>
            <cfset session.languageID = url.languageID>
            <cfquery name="updateUserLanguage" datasource="#application.datasource#">
                UPDATE users
                SET preferredLanguage = <cfqueryparam value="#url.languageID#" cfsqltype="cf_sql_varchar">
                WHERE userid = <cfqueryparam value="#session.userID#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <script>
                alert("Language set to #url.languageID#");
            </script>
        </cfif>
    </cfloop>
        
    </cfif>
   
    <!--- Get translations for the current language --->
    <cfset languageID = session.languageID ?: "en-US">
    <cfquery name="getTranslations" datasource="#application.datasource#">
        SELECT translationKey, translationValue
        FROM translations
        WHERE languageID = <cfqueryparam value="#session.languageID#" cfsqltype="cf_sql_varchar">
        and page = 'dashboard'
    </cfquery>
    
    <cfset translations = {}>
    <cfloop query="getTranslations">
        <cfset translations[translationKey] = translationValue>
    </cfloop>

    <!--- Include the menu --->
    <cfinclude template="includes/menu.cfm">

    <style>
        body {
            background-color: #f8f9fa;
            min-height: 100vh;
            margin: 0;
            padding: 0;
        }
        .container-fluid {
            padding: 2rem;
        }
        .dashboard-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .dashboard-header img {
            max-width: 150px;
            margin-bottom: 20px;
        }
        .welcome-message {
            text-align: center;
            margin-bottom: 30px;
        }
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-card i {
            font-size: 2rem;
            margin-bottom: 10px;
            color: #1a237e;
        }
        .stat-card h3 {
            margin: 0;
            font-size: 1.5rem;
            color: #333;
        }
        .stat-card p {
            margin: 5px 0 0;
            color: #666;
        }
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }
        .action-button {
            background: #1a237e;
            color: white;
            border: none;
            border-radius: 5px;
            padding: 12px;
            text-align: center;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        .action-button:hover {
            background: #0d47a1;
            color: white;
            text-decoration: none;
        }
        @media (max-width: 991.98px) {
            .dashboard-stats {
                grid-template-columns: repeat(2, 1fr);
            }
            .quick-actions {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="container-fluid">
        <div class="dashboard-header">
            <div class="brand-header">
                <span class="logo-text">Light<span class="highlight">GRC</span></span>
            </div>
            <h2 data-translation-key="dashboard.title">Dashboard</h2>
            <p class="text-muted" data-translation-key="dashboard.subtitle">Your Governance, Risk, and Compliance Dashboard</p>
        </div>
 

        <div class="dashboard-stats">
            <div class="stat-card">
                <i class="bi bi-file-earmark-text"></i>
                <h3>12</h3>
                <p>Active Documents</p>
            </div>
            <div class="stat-card">
                <i class="bi bi-tasks"></i>
                <h3>5</h3>
                <p>Pending Tasks</p>
            </div>
            <div class="stat-card">
                <i class="bi bi-shield-check"></i>
                <h3>8</h3>
                <p>Compliance Items</p>
            </div>
            <div class="stat-card">
                <i class="bi bi-exclamation-triangle"></i>
                <h3>3</h3>
                <p>Risk Alerts</p>
            </div>
        </div>

        <div class="quick-actions">
            <a href="documents.cfm" class="action-button" data-translation-key="dashboard.actions.documents">
                <i class="bi bi-file-earmark-text"></i> Manage Documents
            </a>
            <a href="tasks.cfm" class="action-button" data-translation-key="dashboard.actions.tasks">
                <i class="bi bi-tasks"></i> View Tasks
            </a>
            <a href="compliance.cfm" class="action-button" data-translation-key="dashboard.actions.compliance">
                <i class="bi bi-shield-check"></i> Compliance Overview
            </a>
            <a href="risks.cfm" class="action-button" data-translation-key="dashboard.actions.risks">
                <i class="bi bi-exclamation-triangle"></i> Risk Management
            </a>
        </div>
    </div>

  
 
</body>
</html> 