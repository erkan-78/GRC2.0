<cfscript>
    // Verify state parameter to prevent CSRF
    if (NOT structKeyExists(url, "state") OR NOT structKeyExists(session, "ssoState") OR url.state NEQ session.ssoState) {
        location(url="login.cfm?error=invalid_state", addToken=false);
    }

    // Get the authorization code
    if (NOT structKeyExists(url, "code")) {
        location(url="login.cfm?error=no_code", addToken=false);
    }

    try {
        // Get company information from stored email
        var domain = listLast(session.ssoEmail, "@");
        var qCompany = queryExecute(
            "SELECT companyID, ssoProvider, ssoClientID, ssoClientSecret, ssoDomain 
            FROM companies 
            WHERE ssoEnabled = 1 
            AND ssoDomain = :domain 
            AND statusID = (SELECT statusID FROM company_statuses WHERE status = 'APPROVED')",
            {domain = {value=domain, cfsqltype="cf_sql_varchar"}},
            {datasource=application.datasource}
        );

        if (NOT qCompany.recordCount) {
            location(url="login.cfm?error=company_not_found", addToken=false);
        }

        // Exchange code for tokens based on provider
        var tokenEndpoint = "";
        switch (qCompany.ssoProvider) {
            case "AZURE":
                tokenEndpoint = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
                break;
            case "GOOGLE":
                tokenEndpoint = "https://oauth2.googleapis.com/token";
                break;
            default:
                location(url="login.cfm?error=unsupported_provider", addToken=false);
        }

        // Make token request
        var tokenRequest = new http();
        tokenRequest.setMethod("POST");
        tokenRequest.setUrl(tokenEndpoint);
        tokenRequest.addParam(type="header", name="Content-Type", value="application/x-www-form-urlencoded");
        tokenRequest.addParam(type="body", value="client_id=#qCompany.ssoClientID#");
        tokenRequest.addParam(type="body", value="client_secret=#qCompany.ssoClientSecret#");
        tokenRequest.addParam(type="body", value="code=#url.code#");
        tokenRequest.addParam(type="body", value="redirect_uri=#application.baseURL#sso-callback.cfm");
        tokenRequest.addParam(type="body", value="grant_type=authorization_code");
        
        var tokenResponse = tokenRequest.send().getPrefix();
        var tokenData = deserializeJSON(tokenResponse.fileContent);

        if (NOT structKeyExists(tokenData, "access_token")) {
            location(url="login.cfm?error=token_error", addToken=false);
        }

        // Get user info
        var userInfoEndpoint = "";
        switch (qCompany.ssoProvider) {
            case "AZURE":
                userInfoEndpoint = "https://graph.microsoft.com/oidc/userinfo";
                break;
            case "GOOGLE":
                userInfoEndpoint = "https://www.googleapis.com/oauth2/v3/userinfo";
                break;
        }

        var userInfoRequest = new http();
        userInfoRequest.setMethod("GET");
        userInfoRequest.setUrl(userInfoEndpoint);
        userInfoRequest.addParam(type="header", name="Authorization", value="Bearer #tokenData.access_token#");
        
        var userInfoResponse = userInfoRequest.send().getPrefix();
        var userData = deserializeJSON(userInfoResponse.fileContent);

        // Verify email matches
        if (userData.email NEQ session.ssoEmail) {
            location(url="login.cfm?error=email_mismatch", addToken=false);
        }

        // Get or create user
        var qUser = queryExecute(
            "SELECT userID, firstName, lastName, role, preferredLanguage 
            FROM users 
            WHERE email = :email 
            AND companyID = :companyID 
            AND isActive = 1",
            {
                email = {value=userData.email, cfsqltype="cf_sql_varchar"},
                companyID = {value=qCompany.companyID, cfsqltype="cf_sql_integer"}
            },
            {datasource=application.datasource}
        );

        if (NOT qUser.recordCount) {
            // Create new user
            queryExecute(
                "INSERT INTO users (
                    companyID,
                    email,
                    firstName,
                    lastName,
                    role,
                    isActive,
                    createdDate
                ) VALUES (
                    :companyID,
                    :email,
                    :firstName,
                    :lastName,
                    'user',
                    1,
                    CURRENT_TIMESTAMP
                )",
                {
                    companyID = {value=qCompany.companyID, cfsqltype="cf_sql_integer"},
                    email = {value=userData.email, cfsqltype="cf_sql_varchar"},
                    firstName = {value=userData.given_name, cfsqltype="cf_sql_varchar"},
                    lastName = {value=userData.family_name, cfsqltype="cf_sql_varchar"}
                },
                {datasource=application.datasource}
            );

            qUser = queryExecute(
                "SELECT userID, firstName, lastName, role, preferredLanguage 
                FROM users 
                WHERE email = :email 
                AND companyID = :companyID",
                {
                    email = {value=userData.email, cfsqltype="cf_sql_varchar"},
                    companyID = {value=qCompany.companyID, cfsqltype="cf_sql_integer"}
                },
                {datasource=application.datasource}
            );
        }

        // Update last login date
        queryExecute(
            "UPDATE users SET lastLoginDate = CURRENT_TIMESTAMP WHERE userID = :userID",
            {userID = {value=qUser.userID, cfsqltype="cf_sql_integer"}},
            {datasource=application.datasource}
        );

        // Set session variables
        session.isLoggedIn = true;
        session.userID = qUser.userID;
        session.companyID = qCompany.companyID;
        session.email = userData.email;
        session.firstName = qUser.firstName;
        session.lastName = qUser.lastName;
        session.role = qUser.role;
        session.preferredLanguage = qUser.preferredLanguage;
        session.isSuperAdmin = (qUser.role EQ "superadmin");
        session.isAdmin = (qUser.role EQ "admin" OR qUser.role EQ "superadmin");

        // Log the activity
        var logger = createObject("component", "api.logger");
        logger.logActivity(
            activityType = "SSO_LOGIN",
            activityDescription = "User logged in via SSO",
            additionalData = {
                email = userData.email,
                provider = qCompany.ssoProvider
            }
        );

        // Clear SSO session variables
        structDelete(session, "ssoState");
        structDelete(session, "ssoEmail");

        // Redirect to dashboard
        location(url="dashboard.cfm", addToken=false);
    } catch (any e) {
        location(url="login.cfm?error=system_error", addToken=false);
    }
</cfscript> 