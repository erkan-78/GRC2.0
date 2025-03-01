component {
    logger = createObject("component", "logger");

    public function init() {
        return this;
    }

    remote function updateSSOConfig(required struct formData) returnformat="json" {
        try {
            // Verify super admin access
            if (NOT structKeyExists(session, "isSuperAdmin") OR NOT session.isSuperAdmin) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }

            // Validate required fields
            if (NOT structKeyExists(formData, "companyID")) {
                return {
                    "success": false,
                    "message": "Company ID is required"
                };
            }

            // Update SSO configuration
            queryExecute(
                "UPDATE companies SET 
                    ssoEnabled = :ssoEnabled,
                    ssoProvider = :ssoProvider,
                    ssoClientID = :ssoClientID,
                    ssoClientSecret = :ssoClientSecret,
                    ssoDomain = :ssoDomain,
                    ssoMetadataURL = :ssoMetadataURL,
                    lastModifiedDate = CURRENT_TIMESTAMP,
                    modifiedByUserID = :modifiedByUserID
                WHERE companyID = :companyID",
                {
                    companyID = {value=formData.companyID, cfsqltype="cf_sql_integer"},
                    ssoEnabled = {value=formData.ssoEnabled, cfsqltype="cf_sql_bit"},
                    ssoProvider = {value=formData.ssoProvider, cfsqltype="cf_sql_varchar", null=(NOT structKeyExists(formData, "ssoProvider"))},
                    ssoClientID = {value=formData.ssoClientID, cfsqltype="cf_sql_varchar", null=(NOT structKeyExists(formData, "ssoClientID"))},
                    ssoClientSecret = {value=formData.ssoClientSecret, cfsqltype="cf_sql_varchar", null=(NOT structKeyExists(formData, "ssoClientSecret"))},
                    ssoDomain = {value=formData.ssoDomain, cfsqltype="cf_sql_varchar", null=(NOT structKeyExists(formData, "ssoDomain"))},
                    ssoMetadataURL = {value=formData.ssoMetadataURL, cfsqltype="cf_sql_varchar", null=(NOT structKeyExists(formData, "ssoMetadataURL"))},
                    modifiedByUserID = {value=session.userID, cfsqltype="cf_sql_integer"}
                },
                {datasource=application.datasource}
            );

            // Log the activity
            logger.logActivity(
                activityType = "SSO_CONFIG_UPDATE",
                activityDescription = "SSO configuration updated",
                additionalData = {
                    companyID = formData.companyID,
                    ssoEnabled = formData.ssoEnabled,
                    ssoProvider = structKeyExists(formData, "ssoProvider") ? formData.ssoProvider : ""
                }
            );

            return {
                "success": true,
                "message": "SSO configuration updated successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error updating SSO configuration: " & e.message
            };
        }
    }

    remote function getSSOConfig(required numeric companyID) returnformat="json" {
        try {
            // Verify super admin access
            if (NOT structKeyExists(session, "isSuperAdmin") OR NOT session.isSuperAdmin) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }

            var qConfig = queryExecute(
                "SELECT 
                    ssoEnabled,
                    ssoProvider,
                    ssoClientID,
                    ssoClientSecret,
                    ssoDomain,
                    ssoMetadataURL
                FROM companies 
                WHERE companyID = :companyID",
                {companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );

            if (qConfig.recordCount) {
                return {
                    "success": true,
                    "data": {
                        "ssoEnabled": qConfig.ssoEnabled,
                        "ssoProvider": qConfig.ssoProvider,
                        "ssoClientID": qConfig.ssoClientID,
                        "ssoClientSecret": qConfig.ssoClientSecret,
                        "ssoDomain": qConfig.ssoDomain,
                        "ssoMetadataURL": qConfig.ssoMetadataURL
                    }
                };
            } else {
                return {
                    "success": false,
                    "message": "Company not found"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "Error retrieving SSO configuration: " & e.message
            };
        }
    }

    remote function initiateSSOLogin(required string email) returnformat="json" {
        try {
            // Get company domain from email
            var domain = listLast(arguments.email, "@");
            
            // Find company by domain
            var qCompany = queryExecute(
                "SELECT companyID, ssoProvider, ssoClientID, ssoMetadataURL, ssoDomain 
                FROM companies 
                WHERE ssoEnabled = 1 
                AND ssoDomain = :domain 
                AND statusID = (SELECT statusID FROM company_statuses WHERE status = 'APPROVED')",
                {domain = {value=domain, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (qCompany.recordCount) {
                // Generate state token for security
                var stateToken = createUUID();
                session.ssoState = stateToken;
                session.ssoEmail = arguments.email;

                var redirectURL = "";
                switch (qCompany.ssoProvider) {
                    case "AZURE":
                        redirectURL = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize"
                            & "?client_id=" & qCompany.ssoClientID
                            & "&response_type=code"
                            & "&redirect_uri=" & urlEncodedFormat(application.baseURL & "sso-callback.cfm")
                            & "&scope=openid profile email"
                            & "&state=" & stateToken;
                        break;
                    case "GOOGLE":
                        redirectURL = "https://accounts.google.com/o/oauth2/v2/auth"
                            & "?client_id=" & qCompany.ssoClientID
                            & "&response_type=code"
                            & "&redirect_uri=" & urlEncodedFormat(application.baseURL & "sso-callback.cfm")
                            & "&scope=openid profile email"
                            & "&state=" & stateToken;
                        break;
                    case "SAML":
                        // For SAML, we'll need to generate and process SAML request
                        redirectURL = qCompany.ssoMetadataURL;
                        break;
                    default:
                        return {
                            "success": false,
                            "message": "Unsupported SSO provider"
                        };
                }

                return {
                    "success": true,
                    "data": {
                        "redirectURL": redirectURL
                    }
                };
            } else {
                return {
                    "success": false,
                    "message": "SSO not configured for this domain"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "Error initiating SSO login: " & e.message
            };
        }
    }
} 