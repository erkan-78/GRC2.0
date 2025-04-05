<cfset permissionsService = new api.permissions.index()>
<cfset hasPermission = permissionsService.hasPermission(session.userID, pageid)>
sss

<cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR hasPermission.hasPermission EQ false>
    <cfoutput>
        #session.userID#<br>
        #session.languageID#<br>
        #serializeJSON(hasPermission)#  <br>
        $session.isLoggedIn##
    </cfoutput><cfabort>
    <cflocation url="../login.cfm" addtoken="false">
</cfif>

<!--- Get available languages --->
<cfquery name="getLanguages" datasource="#application.datasource#">
    SELECT languageID, languageName
    FROM languages
    WHERE isActive = 1
    ORDER BY languageName
</cfquery>

<!--- Get translations for the current language --->
<cfset languageID = session.languageID ?: "en-US">
<cfquery name="getTranslations" datasource="#application.datasource#">
    SELECT translationKey, translationValue
    FROM translations
    WHERE languageID = <cfqueryparam value="#languageID#" cfsqltype="cf_sql_varchar">
    and page = 'translations'
</cfquery>

<cfset translations = {}>
<cfloop query="getTranslations">
    <cfset translations[translationKey] = translationValue>
</cfloop>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Translations Management</title>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="../assets/css/base.css" rel="stylesheet">
    <link href="../assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            min-height: 100vh;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        .page-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .brand-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .logo-text {
            font-size: 2rem;
            font-weight: 700;
            color: #1a237e;
        }
        .logo-text .highlight {
            color: #0d47a1;
        }
        .admin-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 2rem;
        }
        .admin-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .admin-card-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #1a237e;
            margin: 0;
        }
        .admin-btn {
            padding: 0.5rem 1rem;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .admin-btn-primary {
            background-color: #1a237e;
            color: white;
        }
        .admin-btn-primary:hover {
            background-color: #0d47a1;
        }
        .admin-btn-secondary {
            background-color: #e0e0e0;
            color: #333;
        }
        .admin-btn-secondary:hover {
            background-color: #bdbdbd;
        }
        .admin-btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
        }
        .admin-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        .admin-table th,
        .admin-table td {
            padding: 1rem;
            border-bottom: 1px solid #e0e0e0;
            text-align: left;
        }
        .admin-table th {
            background-color: #f5f5f5;
            font-weight: 600;
        }
        .admin-table tr:hover {
            background-color: #f8f9fa;
        }
        .admin-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        .admin-modal.show {
            display: block;
        }
        .admin-modal-dialog {
            max-width: 600px;
            margin: 2rem auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
        }
        .admin-modal-content {
            padding: 2rem;
        }
        .admin-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .admin-modal-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #1a237e;
            margin: 0;
        }
        .admin-form-group {
            margin-bottom: 1.5rem;
        }
        .admin-form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #333;
        }
        .admin-form-control {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            font-size: 1rem;
        }
        .admin-form-control:focus {
            outline: none;
            border-color: #1a237e;
        }
        .admin-modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 2rem;
        }
        .language-selector {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }
        .form-select {
            padding: 0.5rem;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            background-color: white;
        }
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            .admin-card {
                padding: 1rem;
            }
            .admin-modal-dialog {
                margin: 1rem;
            }
        }
    </style>
</head>
<body>
    <!--- Include the menu --->
    <cfinclude template="/includes/menu.cfm">
 