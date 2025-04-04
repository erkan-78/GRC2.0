component {
    public function init() {
        return this;
    }

    public function createRole(required struct roleData) {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            // Validate required fields
            if (!structKeyExists(arguments.roleData, "roleName") || !len(arguments.roleData.roleName)) {
                result.success = false;
                result.message = "Role name is required";
                return result;
            }

            // Check if role name already exists for this company
            var existingRole = queryExecute("
                SELECT roleID 
                FROM roles 
                WHERE roleName = :roleName 
                AND (companyID = :companyID OR (companyID IS NULL AND :companyID IS NULL))
            ", {
                roleName: { value: arguments.roleData.roleName, cfsqltype: "cf_sql_varchar" },
                companyID: { value: arguments.roleData.companyID, cfsqltype: "cf_sql_varchar", null: true }
            });

            if (existingRole.recordCount) {
                result.success = false;
                result.message = "Role name already exists";
                return result;
            }

            // Validate company exists if specified
            if (structKeyExists(arguments.roleData, "companyID") && arguments.roleData.companyID) {
                var companyExists = queryExecute("
                    SELECT companyID 
                    FROM companies 
                    WHERE companyID = :companyID
                ", {
                    companyID: { value: arguments.roleData.companyID, cfsqltype: "cf_sql_varchar" }
                });

                if (!companyExists.recordCount) {
                    result.success = false;
                    result.message = "Invalid company ID";
                    return result;
                }
            }

            // Insert new role
            var newRole = queryExecute("
                INSERT INTO roles (roleName, description, isActive, isSystem, companyID)
                VALUES (:roleName, :description, :isActive, :isSystem, :companyID)
            ", {
                roleName: { value: arguments.roleData.roleName, cfsqltype: "cf_sql_varchar" },
                description: { value: arguments.roleData.description, cfsqltype: "cf_sql_varchar", null: true },
                isActive: { value: arguments.roleData.isActive ?: 1, cfsqltype: "cf_sql_tinyint" },
                isSystem: { value: arguments.roleData.isSystem ?: 0, cfsqltype: "cf_sql_tinyint" },
                companyID: { value: arguments.roleData.companyID, cfsqltype: "cf_sql_varchar", null: true }
            });

            result.data.roleID = newRole.generatedKey;

            // Insert role translations if provided
            if (structKeyExists(arguments.roleData, "translations")) {
                for (var translation in arguments.roleData.translations) {
                    // Validate language exists
                    var languageExists = queryExecute("
                        SELECT languageID 
                        FROM languages 
                        WHERE languageID = :languageID
                    ", {
                        languageID: { value: translation.languageID, cfsqltype: "cf_sql_varchar" }
                    });

                    if (languageExists.recordCount) {
                        queryExecute("
                            INSERT INTO role_translations (roleID, languageID, description)
                            VALUES (:roleID, :languageID, :description)
                        ", {
                            roleID: { value: result.data.roleID, cfsqltype: "cf_sql_integer" },
                            languageID: { value: translation.languageID, cfsqltype: "cf_sql_varchar" },
                            description: { value: translation.description, cfsqltype: "cf_sql_varchar" }
                        });
                    }
                }
            }

            // Assign permissions if provided
            if (structKeyExists(arguments.roleData, "permissions")) {
                for (var permissionID in arguments.roleData.permissions) {
                    // Validate permission exists
                    var permissionExists = queryExecute("
                        SELECT permissionID 
                        FROM permissions 
                        WHERE permissionID = :permissionID
                    ", {
                        permissionID: { value: permissionID, cfsqltype: "cf_sql_integer" }
                    });

                    if (permissionExists.recordCount) {
                        queryExecute("
                            INSERT INTO role_permissions (roleID, permissionID)
                            VALUES (:roleID, :permissionID)
                        ", {
                            roleID: { value: result.data.roleID, cfsqltype: "cf_sql_integer" },
                            permissionID: { value: permissionID, cfsqltype: "cf_sql_integer" }
                        });
                    }
                }
            }

            result.message = "Role created successfully";
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function updateRole(required numeric roleID, required struct roleData) {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            // Check if role exists and is not a system role
            var existingRole = queryExecute("
                SELECT roleID, isSystem 
                FROM roles 
                WHERE roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" }
            });

            if (!existingRole.recordCount) {
                result.success = false;
                result.message = "Role not found";
                return result;
            }

            if (existingRole.isSystem) {
                result.success = false;
                result.message = "Cannot modify system roles";
                return result;
            }

            // Validate company exists if specified
            if (structKeyExists(arguments.roleData, "companyID") && arguments.roleData.companyID) {
                var companyExists = queryExecute("
                    SELECT companyID 
                    FROM companies 
                    WHERE companyID = :companyID
                ", {
                    companyID: { value: arguments.roleData.companyID, cfsqltype: "cf_sql_varchar" }
                });

                if (!companyExists.recordCount) {
                    result.success = false;
                    result.message = "Invalid company ID";
                    return result;
                }
            }

            // Update role
            queryExecute("
                UPDATE roles 
                SET roleName = :roleName,
                    description = :description,
                    isActive = :isActive,
                    companyID = :companyID
                WHERE roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" },
                roleName: { value: arguments.roleData.roleName, cfsqltype: "cf_sql_varchar" },
                description: { value: arguments.roleData.description, cfsqltype: "cf_sql_varchar", null: true },
                isActive: { value: arguments.roleData.isActive ?: 1, cfsqltype: "cf_sql_tinyint" },
                companyID: { value: arguments.roleData.companyID, cfsqltype: "cf_sql_varchar", null: true }
            });

            // Update translations if provided
            if (structKeyExists(arguments.roleData, "translations")) {
                // Delete existing translations
                queryExecute("
                    DELETE FROM role_translations 
                    WHERE roleID = :roleID
                ", {
                    roleID: { value: arguments.roleID, cfsqltype: "cf_sql_varchar" }
                });

                // Insert new translations
                for (var translation in arguments.roleData.translations) {
                    // Validate language exists
                    var languageExists = queryExecute("
                        SELECT languageID 
                        FROM languages 
                        WHERE languageID = :languageID
                    ", {
                        languageID: { value: translation.languageID, cfsqltype: "cf_sql_varchar" }
                    });

                    if (languageExists.recordCount) {
                        queryExecute("
                            INSERT INTO role_translations (roleID, languageID, description)
                            VALUES (:roleID, :languageID, :description)
                        ", {
                            roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" },
                            languageID: { value: translation.languageID, cfsqltype: "cf_sql_varchar" },
                            description: { value: translation.description, cfsqltype: "cf_sql_varchar" }
                        });
                    }
                }
            }

            // Update permissions if provided
            if (structKeyExists(arguments.roleData, "permissions")) {
                // Delete existing permissions
                queryExecute("
                    DELETE FROM role_permissions 
                    WHERE roleID = :roleID
                ", {
                    roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" }
                });

                // Insert new permissions
                for (var permissionID in arguments.roleData.permissions) {
                    // Validate permission exists
                    var permissionExists = queryExecute("
                        SELECT permissionID 
                        FROM permissions 
                        WHERE permissionID = :permissionID
                    ", {
                        permissionID: { value: permissionID, cfsqltype: "cf_sql_integer" }
                    });

                    if (permissionExists.recordCount) {
                        queryExecute("
                            INSERT INTO role_permissions (roleID, permissionID)
                            VALUES (:roleID, :permissionID)
                        ", {
                            roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" },
                            permissionID: { value: permissionID, cfsqltype: "cf_sql_integer" }
                        });
                    }
                }
            }

            result.message = "Role updated successfully";
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function deleteRole(required numeric roleID) {
        var result = {
            success: true,
            message: ""
        };

        try {
            // Check if role exists and is not a system role
            var existingRole = queryExecute("
                SELECT roleID, isSystem 
                FROM roles 
                WHERE roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" }
            });

            if (!existingRole.recordCount) {
                result.success = false;
                result.message = "Role not found";
                return result;
            }

            if (existingRole.isSystem) {
                result.success = false;
                result.message = "Cannot delete system roles";
                return result;
            }

            // Delete related records first
            queryExecute("
                DELETE FROM role_translations 
                WHERE roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" }
            });

            queryExecute("
                DELETE FROM role_permissions 
                WHERE roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" }
            });

            queryExecute("
                DELETE FROM user_roles 
                WHERE roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" }
            });

            // Delete role
            queryExecute("
                DELETE FROM roles 
                WHERE roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" }
            });

            result.message = "Role deleted successfully";
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function getRole(required numeric roleID, numeric languageID = 0) {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            // Get role details
            var roleQuery = queryExecute("
                SELECT r.*, rt.description as translatedDescription
                FROM roles r
                LEFT JOIN role_translations rt ON r.roleID = rt.roleID AND rt.languageID = :languageID
                WHERE r.roleID = :roleID
            ", {
                roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" },
                languageID: { value: arguments.languageID, cfsqltype: "cf_sql_varchar" }
            });

            if (roleQuery.recordCount) {
                result.data = {
                    roleID: roleQuery.roleID,
                    roleName: roleQuery.roleName,
                    description: roleQuery.translatedDescription ?: roleQuery.description,
                    isActive: roleQuery.isActive,
                    isSystem: roleQuery.isSystem,
                    companyID: roleQuery.companyID,
                    createdDate: roleQuery.createdDate,
                    updatedDate: roleQuery.updatedDate
                };

                // Get role permissions
                var permissionsQuery = queryExecute("
                    SELECT p.*, pt.description as translatedDescription
                    FROM permissions p
                    JOIN role_permissions rp ON p.permissionID = rp.permissionID
                    LEFT JOIN permission_translations pt ON p.permissionID = pt.permissionID AND pt.languageID = :languageID
                    WHERE rp.roleID = :roleID
                    ORDER BY p.category, p.permissionName
                ", {
                    roleID: { value: arguments.roleID, cfsqltype: "cf_sql_integer" },
                    languageID: { value: arguments.languageID, cfsqltype: "cf_sql_varchar" }
                });

                result.data.permissions = [];
                for (var permission in permissionsQuery) {
                    arrayAppend(result.data.permissions, {
                        permissionID: permission.permissionID,
                        permissionName: permission.permissionName,
                        description: permission.translatedDescription ?: permission.description,
                        category: permission.category
                    });
                }
            } else {
                result.success = false;
                result.message = "Role not found";
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function getRoles(numeric companyID = 0, numeric languageID = 0) {
        var result = {
            success: true,
            message: "",
            data: []
        };

        try {
            // Get roles with translations
            var rolesQuery = queryExecute("
                SELECT r.*, rt.description as translatedDescription
                FROM roles r
                LEFT JOIN role_translations rt ON r.roleID = rt.roleID AND rt.languageID = :languageID
                WHERE (:companyID = 0 OR r.companyID = :companyID OR r.companyID IS NULL)
                ORDER BY r.isSystem DESC, r.roleName
            ", {
                companyID: { value: arguments.companyID, cfsqltype: "cf_sql_varchar" },
                languageID: { value: arguments.languageID, cfsqltype: "cf_sql_varchar" }
            });

            for (var role in rolesQuery) {
                var roleData = {
                    roleID: role.roleID,
                    roleName: role.roleName,
                    description: role.translatedDescription ?: role.description,
                    isActive: role.isActive,
                    isSystem: role.isSystem,
                    companyID: role.companyID,
                    createdDate: role.createdDate,
                    updatedDate: role.updatedDate
                };

                // Get role permissions
                var permissionsQuery = queryExecute("
                    SELECT p.*, pt.description as translatedDescription
                    FROM permissions p
                    JOIN role_permissions rp ON p.permissionID = rp.permissionID
                    LEFT JOIN permission_translations pt ON p.permissionID = pt.permissionID AND pt.languageID = :languageID
                    WHERE rp.roleID = :roleID
                    ORDER BY p.category, p.permissionName
                ", {
                    roleID: { value: role.roleID, cfsqltype: "cf_sql_integer" },
                    languageID: { value: arguments.languageID, cfsqltype: "cf_sql_varchar" }
                });

                roleData.permissions = [];
                for (var permission in permissionsQuery) {
                    arrayAppend(roleData.permissions, {
                        permissionID: permission.permissionID,
                        permissionName: permission.permissionName,
                        description: permission.translatedDescription ?: permission.description,
                        category: permission.category
                    });
                }

                arrayAppend(result.data, roleData);
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function assignUserRoles(required string userID, required array roleIDs) {
        var result = {
            success: true,
            message: ""
        };

        try {
            // Validate user exists
            var userExists = queryExecute("
                SELECT userID 
                FROM users 
                WHERE userID = :userID
            ", {
                userID: { value: arguments.userID, cfsqltype: "cf_sql_varchar" }
            });

            if (!userExists.recordCount) {
                result.success = false;
                result.message = "User not found";
                return result;
            }

            // Delete existing user roles
            queryExecute("
                DELETE FROM user_roles 
                WHERE userID = :userID
            ", {
                userID: { value: arguments.userID, cfsqltype: "cf_sql_varchar" }
            });

            // Insert new user roles
            for (var roleID in arguments.roleIDs) {
                // Validate role exists
                var roleExists = queryExecute("
                    SELECT roleID 
                    FROM roles 
                    WHERE roleID = :roleID
                ", {
                    roleID: { value: roleID, cfsqltype: "cf_sql_varchar" }
                });

                if (roleExists.recordCount) {
                    queryExecute("
                        INSERT INTO user_roles (userID, roleID)
                        VALUES (:userID, :roleID)
                    ", {
                        userID: { value: arguments.userID, cfsqltype: "cf_sql_varchar" },
                        roleID: { value: roleID, cfsqltype: "cf_sql_integer" }
                    });
                }
            }

            result.message = "User roles updated successfully";
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    public function getUserRoles(required numeric userID, numeric languageID = 0) {
        var result = {
            success: true,
            message: "",
            data: []
        };

        try {
            // Get user roles with translations
            var rolesQuery = queryExecute("
                SELECT r.*, rt.description as translatedDescription
                FROM roles r
                JOIN user_roles ur ON r.roleID = ur.roleID
                LEFT JOIN role_translations rt ON r.roleID = rt.roleID AND rt.languageID = :languageID
                WHERE ur.userID = :userID
                ORDER BY r.isSystem DESC, r.roleName
            ", {
                userID: { value: arguments.userID, cfsqltype: "cf_sql_varchar" },
                languageID: { value: arguments.languageID, cfsqltype: "cf_sql_integer" }
            });

            for (var role in rolesQuery) {
                var roleData = {
                    roleID: role.roleID,
                    roleName: role.roleName,
                    description: role.translatedDescription ?: role.description,
                    isActive: role.isActive,
                    isSystem: role.isSystem,
                    companyID: role.companyID,
                    createdDate: role.createdDate,
                    updatedDate: role.updatedDate
                };

                // Get role permissions
                var permissionsQuery = queryExecute("
                    SELECT p.*, pt.description as translatedDescription
                    FROM permissions p
                    JOIN role_permissions rp ON p.permissionID = rp.permissionID
                    LEFT JOIN permission_translations pt ON p.permissionID = pt.permissionID AND pt.languageID = :languageID
                    WHERE rp.roleID = :roleID
                    ORDER BY p.category, p.permissionName
                ", {
                    roleID: { value: role.roleID, cfsqltype: "cf_sql_integer" },
                    languageID: { value: arguments.languageID, cfsqltype: "cf_sql_varchar" }
                });

                roleData.permissions = [];
                for (var permission in permissionsQuery) {
                    arrayAppend(roleData.permissions, {
                        permissionID: permission.permissionID,
                        permissionName: permission.permissionName,
                        description: permission.translatedDescription ?: permission.description,
                        category: permission.category
                    });
                }

                arrayAppend(result.data, roleData);
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }
} 