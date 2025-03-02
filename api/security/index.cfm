<cfscript>
    // Initialize services
    securityService = new model.SecurityService();
    
    // Require authentication for all API endpoints
    securityService.requireAuthentication();
    securityService.requirePermission("security.manage");
    
    // Get the requested action from the URL
    action = url.action ?: "default";
    
    // Set the response type to JSON
    getPageContext().getResponse().setContentType("application/json");
    
    try {
        switch(action) {
            case "saveRole":
                roleData = {
                    "roleID" = form.roleID ?: 0,
                    "roleName" = form.roleName ?: "",
                    "description" = form.description ?: ""
                };
                result = securityService.saveRole(roleData);
                break;
                
            case "deleteRole":
                roleID = form.roleID ?: 0;
                if (roleID == 0) {
                    throw(type="CustomError", message="Invalid role ID");
                }
                securityService.deleteRole(roleID);
                result = {"success" = true, "message" = "Role deleted successfully"};
                break;
                
            case "getRolePermissions":
                roleID = url.roleID ?: 0;
                if (roleID == 0) {
                    throw(type="CustomError", message="Invalid role ID");
                }
                result = {
                    "success" = true,
                    "permissions" = securityService.getRolePermissions(roleID)
                };
                break;
                
            case "saveRolePermissions":
                roleID = form.roleID ?: 0;
                permissions = form.permissions ?: "";
                if (roleID == 0) {
                    throw(type="CustomError", message="Invalid role ID");
                }
                securityService.saveRolePermissions(roleID, listToArray(permissions));
                result = {"success" = true, "message" = "Permissions updated successfully"};
                break;

            case "saveUserRoles":
                userID = form.userID ?: 0;
                roles = form.roles ?: "";
                if (userID == 0) {
                    throw(type="CustomError", message="Invalid user ID");
                }
                securityService.saveUserRoles(userID, listToArray(roles));
                result = {"success" = true, "message" = "User roles updated successfully"};
                break;

            case "getUserRoles":
                userID = url.userID ?: 0;
                if (userID == 0) {
                    throw(type="CustomError", message="Invalid user ID");
                }
                result = {
                    "success" = true,
                    "roles" = securityService.getUserRoles(userID)
                };
                break;

            default:
                result = {"success" = false, "message" = "Invalid action"};
        }
    } catch (any e) {
        result = {
            "success" = false,
            "message" = e.message
        };
    }
    
    // Output the result as JSON
    writeOutput(serializeJSON(result));
</cfscript> 