component {
    
    public boolean function isAuthenticated() {
        return structKeyExists(session, "userID") && session.userID > 0;
    }
    
    public void function requireAuthentication() {
        if (!isAuthenticated()) {
            if (cgi.content_type contains "application/json" || listFirst(cgi.script_name, "/") == "api") {
                // API request - return JSON error
                getPageContext().getResponse().setContentType("application/json");
                getPageContext().getResponse().setStatus(401);
                writeOutput(serializeJSON({
                    "success" = false,
                    "message" = "Authentication required",
                    "redirect" = "/login.cfm"
                }));
                abort;
            } else {
                // Regular page request - redirect to login
                location(url="/login.cfm?returnUrl=" & urlEncodedFormat(cgi.script_name & "?" & cgi.query_string), addToken=false);
            }
        }
    }
    
    public boolean function hasPermission(required string permission) {
        if (!isAuthenticated()) {
            logPermissionCheck(arguments.permission, false);
            return false;
        }

        // Check if user is superadmin (has all permissions)
        if (isSuperAdmin()) {
            logPermissionCheck(arguments.permission, true);
            return true;
        }

        // Get user's roles and permissions from cache or database
        var userPermissions = getUserPermissions(session.userID);
        
        // Check if user has the specific permission
        var hasPermission = userPermissions.containsPermission(arguments.permission);
        
        // Log the permission check
        logPermissionCheck(arguments.permission, hasPermission);
        
        return hasPermission;
    }

    private void function logPermissionCheck(required string permission, required boolean granted) {
        var sql = "
            INSERT INTO permission_audit_log (
                userID,
                permissionName,
                granted,
                ipAddress,
                userAgent,
                requestPath
            ) VALUES (
                :userID,
                :permissionName,
                :granted,
                :ipAddress,
                :userAgent,
                :requestPath
            )
        ";
        
        var params = {
            userID = { value = session.userID ?: 0, cfsqltype = "cf_sql_integer" },
            permissionName = { value = arguments.permission, cfsqltype = "cf_sql_varchar" },
            granted = { value = arguments.granted, cfsqltype = "cf_sql_bit" },
            ipAddress = { value = cgi.remote_addr, cfsqltype = "cf_sql_varchar" },
            userAgent = { value = left(cgi.http_user_agent, 255), cfsqltype = "cf_sql_varchar" },
            requestPath = { value = left(cgi.script_name & "?" & cgi.query_string, 255), cfsqltype = "cf_sql_varchar" }
        };
        
        queryExecute(sql, params);
    }

    public boolean function isSuperAdmin() {
        if (!isAuthenticated()) {
            return false;
        }

        // Check if user has superadmin role
        var sql = "
            SELECT COUNT(*) as isSuperAdmin
            FROM user_roles ur
            INNER JOIN roles r ON ur.roleID = r.roleID
            WHERE ur.userID = :userID
            AND r.roleName = 'superadmin'
        ";
        var params = {
            userID = { value = session.userID, cfsqltype = "cf_sql_integer" }
        };
        var result = queryExecute(sql, params);
        
        return result.isSuperAdmin > 0;
    }

    private struct function getUserPermissions(required numeric userID) {
        // Try to get permissions from cache first
        if (structKeyExists(application.cache.permissions, arguments.userID)) {
            // Check if cache is still valid (e.g., not older than 5 minutes)
            if (dateDiff("n", application.cache.permissions[arguments.userID].timestamp, now()) < 5) {
                return application.cache.permissions[arguments.userID].data;
            }
        }

        // If not in cache or cache expired, get from database
        var sql = "
            SELECT DISTINCT p.permissionName
            FROM user_roles ur
            INNER JOIN role_permissions rp ON ur.roleID = rp.roleID
            INNER JOIN permissions p ON rp.permissionID = p.permissionID
            WHERE ur.userID = :userID
        ";
        var params = {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" }
        };
        var result = queryExecute(sql, params);

        // Convert query to struct for easier checking
        var permissions = {
            containsPermission = function(required string permissionName) {
                return queryExecute("
                    SELECT COUNT(*) as hasPermission
                    FROM user_roles ur
                    INNER JOIN role_permissions rp ON ur.roleID = rp.roleID
                    INNER JOIN permissions p ON rp.permissionID = p.permissionID
                    WHERE ur.userID = :userID
                    AND p.permissionName = :permissionName
                ", {
                    userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" },
                    permissionName = { value = arguments.permissionName, cfsqltype = "cf_sql_varchar" }
                }).hasPermission > 0;
            }
        };

        // Cache the permissions
        application.cache.permissions[arguments.userID] = {
            timestamp = now(),
            data = permissions
        };

        return permissions;
    }
    
    public void function requirePermission(required string permission) {
        if (!hasPermission(arguments.permission)) {
            if (cgi.content_type contains "application/json" || listFirst(cgi.script_name, "/") == "api") {
                // API request - return JSON error
                getPageContext().getResponse().setContentType("application/json");
                getPageContext().getResponse().setStatus(403);
                writeOutput(serializeJSON({
                    "success" = false,
                    "message" = "Permission denied"
                }));
                abort;
            } else {
                // Regular page request - show error
                location(url="/error.cfm?type=permission", addToken=false);
            }
        }
    }

    public void function clearPermissionCache(numeric userID = 0) {
        if (arguments.userID > 0) {
            // Clear specific user's cache
            structDelete(application.cache.permissions, arguments.userID);
        } else {
            // Clear all permission cache
            application.cache.permissions = {};
        }
    }

    public struct function saveRole(required struct roleData) {
        var params = {
            roleName = { value = arguments.roleData.roleName, cfsqltype = "cf_sql_varchar" },
            description = { value = arguments.roleData.description, cfsqltype = "cf_sql_varchar" }
        };

        if (arguments.roleData.roleID > 0) {
            // Update existing role
            var sql = "
                UPDATE roles
                SET roleName = :roleName,
                    description = :description
                WHERE roleID = :roleID
            ";
            params.roleID = { value = arguments.roleData.roleID, cfsqltype = "cf_sql_integer" };
        } else {
            // Insert new role
            var sql = "
                INSERT INTO roles (roleName, description)
                VALUES (:roleName, :description)
            ";
        }

        queryExecute(sql, params);
        return { "success" = true, "message" = "Role saved successfully" };
    }

    public void function deleteRole(required numeric roleID) {
        // Check if role is in use
        var checkSql = "
            SELECT COUNT(*) as userCount
            FROM user_roles
            WHERE roleID = :roleID
        ";
        var checkParams = {
            roleID = { value = arguments.roleID, cfsqltype = "cf_sql_integer" }
        };
        var checkResult = queryExecute(checkSql, checkParams);

        if (checkResult.userCount > 0) {
            throw(type="CustomError", message="Cannot delete role: It is assigned to #checkResult.userCount# user(s)");
        }

        // Delete role permissions first
        queryExecute("
            DELETE FROM role_permissions
            WHERE roleID = :roleID
        ", checkParams);

        // Delete role
        queryExecute("
            DELETE FROM roles
            WHERE roleID = :roleID
        ", checkParams);
    }

    public array function getRolePermissions(required numeric roleID) {
        var sql = "
            SELECT p.permissionID
            FROM role_permissions rp
            INNER JOIN permissions p ON rp.permissionID = p.permissionID
            WHERE rp.roleID = :roleID
        ";
        var params = {
            roleID = { value = arguments.roleID, cfsqltype = "cf_sql_integer" }
        };
        var result = queryExecute(sql, params);
        
        return valueList(result.permissionID);
    }

    public void function saveRolePermissions(required numeric roleID, required array permissions) {
        // First, delete existing permissions
        var params = {
            roleID = { value = arguments.roleID, cfsqltype = "cf_sql_integer" }
        };
        queryExecute("
            DELETE FROM role_permissions
            WHERE roleID = :roleID
        ", params);

        // Then insert new permissions
        if (arrayLen(arguments.permissions)) {
            var sql = "
                INSERT INTO role_permissions (roleID, permissionID)
                VALUES (:roleID, :permissionID)
            ";
            for (var permissionID in arguments.permissions) {
                queryExecute(sql, {
                    roleID = params.roleID,
                    permissionID = { value = permissionID, cfsqltype = "cf_sql_integer" }
                });
            }
        }

        // Clear permission cache for all users with this role
        clearPermissionCacheForRole(arguments.roleID);
    }

    public array function getUserRoles(required numeric userID) {
        var sql = "
            SELECT r.roleID
            FROM user_roles ur
            INNER JOIN roles r ON ur.roleID = r.roleID
            WHERE ur.userID = :userID
        ";
        var params = {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" }
        };
        var result = queryExecute(sql, params);
        
        return valueList(result.roleID);
    }

    public void function saveUserRoles(required numeric userID, required array roles) {
        // First, delete existing roles
        var params = {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" }
        };
        queryExecute("
            DELETE FROM user_roles
            WHERE userID = :userID
        ", params);

        // Then insert new roles
        if (arrayLen(arguments.roles)) {
            var sql = "
                INSERT INTO user_roles (userID, roleID)
                VALUES (:userID, :roleID)
            ";
            for (var roleID in arguments.roles) {
                queryExecute(sql, {
                    userID = params.userID,
                    roleID = { value = roleID, cfsqltype = "cf_sql_integer" }
                });
            }
        }

        // Clear permission cache for this user
        clearPermissionCache(arguments.userID);
    }

    private void function clearPermissionCacheForRole(required numeric roleID) {
        var sql = "
            SELECT DISTINCT ur.userID
            FROM user_roles ur
            WHERE ur.roleID = :roleID
        ";
        var params = {
            roleID = { value = arguments.roleID, cfsqltype = "cf_sql_integer" }
        };
        var users = queryExecute(sql, params);
        
        for (var user in users) {
            clearPermissionCache(user.userID);
        }
    }
} 