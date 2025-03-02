<cfscript>
    securityService = new model.SecurityService();
    
    // Require authentication and admin permission
    securityService.requireAuthentication();
    securityService.requirePermission("security.manage");
    
    // Get the requested page
    page = url.page ?: "roles";
    
    // Include the appropriate page
    switch(page) {
        case "roles":
            include "roles.cfm";
            break;
        case "permissions":
            include "permissions.cfm";
            break;
        case "users":
            // Get pagination parameters
            pageSize = 20;
            currentPage = val(url.p ?: 1);
            
            // Get users with their roles
            getUsers = queryExecute("
                SELECT 
                    u.userID,
                    u.firstName,
                    u.lastName,
                    u.email,
                    u.lastLogin,
                    GROUP_CONCAT(r.roleName) as rolesList,
                    COUNT(DISTINCT r.roleID) as roleCount
                FROM users u
                LEFT JOIN user_roles ur ON u.userID = ur.userID
                LEFT JOIN roles r ON ur.roleID = r.roleID
                GROUP BY u.userID, u.firstName, u.lastName, u.email, u.lastLogin
                ORDER BY u.lastName, u.firstName
                LIMIT :offset, :limit
            ", {
                offset: { value: (currentPage-1) * pageSize, cfsqltype: "cf_sql_integer" },
                limit: { value: pageSize, cfsqltype: "cf_sql_integer" }
            });
            
            // Get total count for pagination
            totalRecords = queryExecute("
                SELECT COUNT(DISTINCT u.userID) as total
                FROM users u
            ").total;
            
            // Get all roles for the modal
            getAllRoles = queryExecute("
                SELECT roleID, roleName, description
                FROM roles
                ORDER BY roleName
            ");
            
            include "users.cfm";
            break;
        case "audit":
            include "audit.cfm";
            break;
        default:
            include "roles.cfm";
    }
</cfscript> 