component {
    logger = createObject("component", "logger");

    // Set response type to JSON
    remote any function init() {
        getPageContext().getResponse().setContentType("application/json");
        return this;
    }

    remote struct function validateCompany(required numeric companyID) httpmethod="GET" {
        init();
        
        try {
            if (len(arguments.companyID) GT 9) {
                return {
                    "success": false,
                    "message": "Company ID must be maximum 9 digits"
                };
            }

            var qCompany = queryExecute(
                "SELECT companyID, companyName, isActive 
                FROM companies 
                WHERE companyID = :companyID",
                {companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qCompany.recordCount) {
                if (qCompany.isActive) {
                    return {
                        "success": true,
                        "data": {
                            "companyID": qCompany.companyID,
                            "companyName": qCompany.companyName
                        }
                    };
                } else {
                    return {
                        "success": false,
                        "message": "This company is not active"
                    };
                }
            } else {
                return {
                    "success": false,
                    "message": "Company not found"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while validating company",
                "error": e.message
            };
        }
    }

    remote struct function createCompany(
        required numeric companyID,
        required string companyName
    ) httpmethod="POST" {
        init();
        
        try {
            if (len(arguments.companyID) GT 9) {
                return {
                    "success": false,
                    "message": "Company ID must be maximum 9 digits"
                };
            }

            // Check if company already exists
            var qCheckCompany = queryExecute(
                "SELECT companyID FROM companies WHERE companyID = :companyID",
                {companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qCheckCompany.recordCount) {
                return {
                    "success": false,
                    "message": "Company ID already exists"
                };
            }
            
            // Insert new company
            queryExecute(
                "INSERT INTO companies (companyID, companyName) VALUES (:companyID, :companyName)",
                {
                    companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                    companyName = {value=arguments.companyName, cfsqltype="cf_sql_varchar"}
                },
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "message": "Company created successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while creating company",
                "error": e.message
            };
        }
    }

    // Submit company application
    remote struct function submitApplication(required struct formData) returnformat="json" {
        try {
            // Handle file upload
            var uploadResult = "";
            if (structKeyExists(form, "logo")) {
                uploadResult = fileUpload(
                    expandPath("../uploads/logos"),
                    "logo",
                    "image/jpeg,image/png,image/gif",
                    "makeunique"
                );
            }

            // Generate salt
            var salt = generateSalt();

            // Insert company
            var companyID = queryExecute(
                "INSERT INTO companies (
                    name,
                    taxNumber,
                    email,
                    phone,
                    address,
                    website,
                    logo,
                    salt,
                    statusID
                ) VALUES (
                    :name,
                    :taxNumber,
                    :email,
                    :phone,
                    :address,
                    :website,
                    :logo,
                    :salt,
                    (SELECT statusID FROM company_statuses WHERE statusName = 'PENDING')
                )",
                {
                    name: { value: formData.name, cfsqltype: "cf_sql_varchar" },
                    taxNumber: { value: formData.taxNumber, cfsqltype: "cf_sql_varchar" },
                    email: { value: formData.email, cfsqltype: "cf_sql_varchar" },
                    phone: { value: formData.phone, cfsqltype: "cf_sql_varchar" },
                    address: { value: formData.address, cfsqltype: "cf_sql_longvarchar" },
                    website: { value: formData.website, nullValue: "", cfsqltype: "cf_sql_varchar" },
                    logo: { value: uploadResult.serverFile ?: "", nullValue: "", cfsqltype: "cf_sql_varchar" },
                    salt: { value: salt, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource, result: "result" }
            );

            // Log the activity
            logger.logActivity(
                activityType = "CREATE",
                activityDescription = "New company application submitted: #formData.name#",
                additionalData = {
                    companyID = result.generatedKey,
                    companyName = formData.name,
                    taxNumber = formData.taxNumber
                }
            );

            return { 
                "success": true, 
                "message": "Application submitted successfully" 
            };
        } catch (any e) {
            // Clean up uploaded file if there was an error
            if (len(uploadResult.serverFile)) {
                fileDelete(expandPath("../uploads/logos/#uploadResult.serverFile#"));
            }
            
            return { 
                "success": false, 
                "message": "Error submitting application: " & e.message 
            };
        }
    }

    // Get all companies (super admin only)
    remote struct function getAllCompanies() httpmethod="GET" {
        init();
        
        try {
            if (NOT isSuperAdmin()) {
                return unauthorized();
            }
            
            var qCompanies = queryExecute(
                "SELECT c.*, cs.statusName, cs.description as statusDescription,
                    u.firstName as modifiedByFirstName, u.lastName as modifiedByLastName
                FROM companies c
                JOIN companyStatus cs ON c.statusID = cs.statusID
                LEFT JOIN users u ON c.lastModifiedBy = u.userID
                ORDER BY c.applicationDate DESC",
                {},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "data": queryToArray(qCompanies)
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching companies",
                "error": e.message
            };
        }
    }

    // Get company details (super admin only)
    remote struct function getCompany(required numeric companyID) httpmethod="GET" {
        init();
        
        try {
            if (NOT isSuperAdmin()) {
                return unauthorized();
            }
            
            var qCompany = queryExecute(
                "SELECT c.*, cs.statusName, cs.description as statusDescription,
                    u.firstName as modifiedByFirstName, u.lastName as modifiedByLastName
                FROM companies c
                JOIN companyStatus cs ON c.statusID = cs.statusID
                LEFT JOIN users u ON c.lastModifiedBy = u.userID
                WHERE c.companyID = :companyID",
                {companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qCompany.recordCount) {
                return {
                    "success": true,
                    "data": queryToArray(qCompany)[1]
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
                "message": "An error occurred while fetching company details",
                "error": e.message
            };
        }
    }

    // Update company (super admin only)
    remote struct function updateCompany(required numeric companyID, required struct companyData) returnformat="json" {
        if (NOT isAuthorized()) {
            return { "success": false, "message": "Unauthorized access" };
        }

        try {
            // Handle file upload if new logo is provided
            if (structKeyExists(form, "logo")) {
                var uploadResult = fileUpload(
                    expandPath("../uploads/logos"),
                    "logo",
                    "image/jpeg,image/png,image/gif",
                    "makeunique"
                );
                companyData.logo = uploadResult.serverFile;
            }

            // Update company
            queryExecute(
                "UPDATE companies SET
                    name = :name,
                    email = :email,
                    phone = :phone,
                    address = :address,
                    website = :website,
                    #structKeyExists(companyData, 'logo') ? 'logo = :logo,' : ''#
                    statusID = :statusID,
                    lastModifiedDate = CURRENT_TIMESTAMP,
                    modifiedByUserID = :modifiedByUserID
                WHERE companyID = :companyID",
                {
                    companyID: { value: companyID, cfsqltype: "cf_sql_integer" },
                    name: { value: companyData.name, cfsqltype: "cf_sql_varchar" },
                    email: { value: companyData.email, cfsqltype: "cf_sql_varchar" },
                    phone: { value: companyData.phone, cfsqltype: "cf_sql_varchar" },
                    address: { value: companyData.address, cfsqltype: "cf_sql_longvarchar" },
                    website: { value: companyData.website, nullValue: "", cfsqltype: "cf_sql_varchar" },
                    statusID: { value: companyData.statusID, cfsqltype: "cf_sql_integer" },
                    modifiedByUserID: { value: session.userID, cfsqltype: "cf_sql_integer" }
                } & (structKeyExists(companyData, 'logo') ? {
                    logo: { value: companyData.logo, cfsqltype: "cf_sql_varchar" }
                } : {}),
                { datasource: application.datasource }
            );

            // Log the activity
            logger.logActivity(
                activityType = "UPDATE",
                activityDescription = "Company updated: #companyData.name#",
                additionalData = {
                    companyID = companyID,
                    companyName = companyData.name,
                    updatedFields = structKeyList(companyData)
                }
            );

            return { 
                "success": true, 
                "message": "Company updated successfully" 
            };
        } catch (any e) {
            return { 
                "success": false, 
                "message": "Error updating company: " & e.message 
            };
        }
    }

    // Update company salt (super admin only)
    remote struct function updateCompanySalt(required numeric companyID) returnformat="json" {
        if (NOT isAuthorized()) {
            return { "success": false, "message": "Unauthorized access" };
        }

        try {
            var newSalt = generateSalt();
            
            queryExecute(
                "UPDATE companies SET
                    salt = :salt,
                    lastModifiedDate = CURRENT_TIMESTAMP,
                    modifiedByUserID = :modifiedByUserID
                WHERE companyID = :companyID",
                {
                    companyID: { value: companyID, cfsqltype: "cf_sql_integer" },
                    salt: { value: newSalt, cfsqltype: "cf_sql_varchar" },
                    modifiedByUserID: { value: session.userID, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );

            // Log the activity
            logger.logActivity(
                activityType = "UPDATE",
                activityDescription = "Company salt regenerated",
                additionalData = {
                    companyID = companyID
                }
            );

            return { 
                "success": true, 
                "message": "Company salt updated successfully" 
            };
        } catch (any e) {
            return { 
                "success": false, 
                "message": "Error updating company salt: " & e.message 
            };
        }
    }

    // Manage company administrators
    remote struct function getCompanyAdministrators(required numeric companyID) httpmethod="GET" {
        init();
        
        try {
            if (NOT isSuperAdmin()) {
                return unauthorized();
            }
            
            var qAdmins = queryExecute(
                "SELECT ca.*, u.firstName, u.lastName, u.email,
                    assigned.firstName as assignedByFirstName,
                    assigned.lastName as assignedByLastName,
                    GROUP_CONCAT(ap.permissionName) as permissions
                FROM companyAdministrators ca
                JOIN users u ON ca.userID = u.userID
                JOIN users assigned ON ca.assignedBy = assigned.userID
                LEFT JOIN companyAdminPermissions cap ON ca.companyID = cap.companyID AND ca.userID = cap.userID
                LEFT JOIN administratorPermissions ap ON cap.permissionID = ap.permissionID
                WHERE ca.companyID = :companyID
                GROUP BY ca.companyID, ca.userID",
                {companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "data": queryToArray(qAdmins)
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching company administrators",
                "error": e.message
            };
        }
    }

    // Add/Update company administrator
    remote struct function updateCompanyAdministrator(
        required numeric companyID,
        required numeric userID,
        required array permissions,
        required boolean isActive
    ) httpmethod="POST" {
        init();
        
        try {
            if (NOT isSuperAdmin()) {
                return unauthorized();
            }
            
            transaction {
                // Check if admin exists
                var qAdmin = queryExecute(
                    "SELECT userID FROM companyAdministrators 
                    WHERE companyID = :companyID AND userID = :userID",
                    {
                        companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                        userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}
                    },
                    {datasource=application.datasource}
                );
                
                if (qAdmin.recordCount) {
                    // Update existing admin
                    queryExecute(
                        "UPDATE companyAdministrators SET
                            isActive = :isActive
                        WHERE companyID = :companyID AND userID = :userID",
                        {
                            companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                            userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                            isActive = {value=arguments.isActive, cfsqltype="cf_sql_bit"}
                        },
                        {datasource=application.datasource}
                    );
                } else {
                    // Add new admin
                    queryExecute(
                        "INSERT INTO companyAdministrators (
                            companyID, userID, isActive, assignedDate, assignedBy
                        ) VALUES (
                            :companyID, :userID, :isActive, NOW(), :assignedBy
                        )",
                        {
                            companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                            userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                            isActive = {value=arguments.isActive, cfsqltype="cf_sql_bit"},
                            assignedBy = {value=session.userID, cfsqltype="cf_sql_integer"}
                        },
                        {datasource=application.datasource}
                    );
                }
                
                // Delete existing permissions
                queryExecute(
                    "DELETE FROM companyAdminPermissions 
                    WHERE companyID = :companyID AND userID = :userID",
                    {
                        companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                        userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}
                    },
                    {datasource=application.datasource}
                );
                
                // Add new permissions
                for (var permission in arguments.permissions) {
                    queryExecute(
                        "INSERT INTO companyAdminPermissions (
                            companyID, userID, permissionID, grantedDate, grantedBy
                        ) VALUES (
                            :companyID, :userID, 
                            (SELECT permissionID FROM administratorPermissions WHERE permissionName = :permission),
                            NOW(), :grantedBy
                        )",
                        {
                            companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                            userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                            permission = {value=permission, cfsqltype="cf_sql_varchar"},
                            grantedBy = {value=session.userID, cfsqltype="cf_sql_integer"}
                        },
                        {datasource=application.datasource}
                    );
                }
            }
            
            return {
                "success": true,
                "message": "Company administrator updated successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while updating company administrator",
                "error": e.message
            };
        }
    }

    // Helper Functions
    private string function generateSalt() {
        return createUUID();
    }

    private boolean function isSuperAdmin() {
        return structKeyExists(session, "isLoggedIn") 
            AND session.isLoggedIn 
            AND structKeyExists(session, "isSuperAdmin")
            AND session.isSuperAdmin;
    }

    private boolean function isAuthorized() {
        return structKeyExists(session, "isLoggedIn") AND 
               session.isLoggedIn AND 
               (session.isSuperAdmin OR session.isAdmin);
    }

    private struct function unauthorized() {
        return {
            "success": false,
            "message": "Unauthorized access"
        };
    }

    private array function queryToArray(required query qry) {
        var array = [];
        for (var row in arguments.qry) {
            arrayAppend(array, row);
        }
        return array;
    }
} 