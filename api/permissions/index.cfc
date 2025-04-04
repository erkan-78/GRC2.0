component {
    public function init() {
        return this;
    }

    public function getUserPermissions(required string userID, required string languageId) {
        var result = {
            success: true,
            message: "",
            data: {}
        };
        
        var permissions = {};

        try {
            // Get user's roles and permissions
            var userQuery = queryExecute("
                SELECT DISTINCT r.roleID, r.roleName, p.permissionID, p.permissionName,  p.category, p.route, pt.label as description, pt2.label as categoryLabel
                FROM grc.users u
                JOIN grc.user_roles ur ON u.userID = ur.userID
                JOIN grc.roles r ON ur.roleID = r.roleID
                JOIN grc.role_permissions rp ON r.roleID = rp.roleID
                JOIN grc.permissions p ON rp.permissionID = p.permissionID
                JOIN  grc.permission_translations pt  on pt.permissionKey = p.permissionName
                JOIN  grc.permission_translations pt2  on pt2.permissionKey = p.category 
                WHERE u.userID = :userID
                AND p.isActive = 1
                AND r.isActive = 1
				AND pt.languageID = :languageID1
				and pt2.languageID = :languageID2
            ", {
                userID: { value: arguments.userID, cfsqltype: "cf_sql_varchar" },
                languageID1: { value: arguments.languageId, cfsqltype: "cf_sql_varchar" },
                languageID2: { value: arguments.languageId, cfsqltype: "cf_sql_varchar" }
            }); 
            
        
            
            if (userQuery.recordCount > 0) {
                // Build permissions structure by category
                for (var row in userQuery) {
                    // Add role name to array if not already there
                    if (!structKeyExists(permissions, row.category)) {
                        permissions[row.category] = {};
                    }
                    permissions[row.category][row.permissionName] = {
                        roleName: row.roleName,
                        permissionID: row.permissionID,
                        name: row.permissionName,
                        description: row.description,
                        category: row.category,
                        categoryLabel: row.categoryLabel,
                        route: row.route
                    };
                }
                   
                result.data = {
                    permissions: permissions
                };
            } else {
                result.success = false;
                result.message = "User not found or has no permissions";
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function hasPermission(required string userID, required string permissionName) {
        var result = {
            success: true,
            hasPermission: false
        };

        try {
            var permissions = getUserPermissions(arguments.userID);
            
            if (permissions.success) {
                // Check if permission exists in any category
                for (var category in permissions.data.permissions) {
                    if (structKeyExists(permissions.data.permissions[category], arguments.permissionName)) {
                        result.hasPermission = true;
                        break;
                    }
                }
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function hasAnyPermission(required string userID, required array permissionNames) {
        var result = {
            success: true,
            hasPermission: false
        };

        try {
            var permissions = getUserPermissions(arguments.userID);
            
            if (permissions.success) {
                // Check if any of the permissions exist
                for (var permissionName in arguments.permissionNames) {
                    for (var category in permissions.data.permissions) {
                        if (structKeyExists(permissions.data.permissions[category], permissionName)) {
                            result.hasPermission = true;
                            break;
                        }
                    }
                    if (result.hasPermission) break;
                }
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function hasAllPermissions(required string userID, required array permissionNames) {
        var result = {
            success: true,
            hasPermission: true
        };

        try {
            var permissions = getUserPermissions(arguments.userID);
            
            if (permissions.success) {
                // Check if all permissions exist
                for (var permissionName in arguments.permissionNames) {
                    var found = false;
                    for (var category in permissions.data.permissions) {
                        if (structKeyExists(permissions.data.permissions[category], permissionName)) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        result.hasPermission = false;
                        break;
                    }
                }
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }
} 