component {
    public function init() {
        return this;
    }

    public function getUserMenu(required string userID, string preferredLanguage = "") {
        var result = {
            success: true,
            message: "",
            data: []
        };

        try {
            // Get user permissions using the permissions service
            var permissionsService = new api.permissions.index();
            var permissionsResult = permissionsService.getUserPermissions(arguments.userID, arguments.preferredLanguage);

            if (permissionsResult.success) {
                var permissions = permissionsResult.data.permissions;
                var menuItems = []; 
                
                // Create menu items for each category
                for (var category in permissions) {
                    var categoryPermissions = permissions[category];
                    
                    // Skip if no permissions in this category
                    if (structCount(categoryPermissions) == 0) continue;
                    
                    // Get the first permission to extract category label
                    var firstPermission = "";
                    for (var permKey in categoryPermissions) {
                        firstPermission = categoryPermissions[permKey];
                        break;
                    }
                    
                    // Create category menu item
                    var categoryItem = {
                        id: category,
                        label: uCase(left(firstPermission.categoryLabel, 1)) & right(firstPermission.categoryLabel, len(firstPermission.categoryLabel)-1), // Capitalize first letter
                        icon: getCategoryIcon(category),
                        route: firstPermission.route,
                        translationKey: "menu.#category#",
                        children: []
                    };
                    
                    // Add child items for each permission
                    for (var permKey in categoryPermissions) {
                        var permission = categoryPermissions[permKey];
                        arrayAppend(categoryItem.children, {
                            id: permission.name,
                            label: permission.description,
                            icon: getPermissionIcon(permission.name),
                            route: permission.route,
                            translationKey: "menu.#permission.name#"
                        });
                    }
                    
                    // Only add category if it has children
                    if (arrayLen(categoryItem.children) > 0) {
                        arrayAppend(menuItems, categoryItem);
                    }
                }

                result.data = menuItems;
            } else {
                result.success = false;
                result.message = permissionsResult.message;
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }
    
    // Helper function to get appropriate icon for a category
    private function getCategoryIcon(required string category) {
        var iconMap = {
            "system": "gear",
            "company": "building",
            "documents": "file-earmark-text",
            "tasks": "check-square",
            "compliance": "shield-check",
            "risks": "exclamation-triangle",
            "users": "people",
            "settings": "gear-fill",
            "reports": "file-earmark-text",
            "security": "shield-lock",
            "backup": "archive",
            "logs": "journal-text",
            "translations": "translate"
        };
        
        return structKeyExists(iconMap, arguments.category) ? iconMap[arguments.category] : "folder";
    }
    
    // Helper function to get appropriate icon for a permission
    private function getPermissionIcon(required string permissionName) {
        var iconMap = {
            "view": "eye",
            "create": "plus-circle",
            "edit": "pencil",
            "delete": "trash",
            "manage": "gear",
            "list": "list",
            "export": "download",
            "import": "upload",
            "print": "printer",
            "approve": "check-circle",
            "reject": "x-circle",
            "assign": "person-plus",
            "unassign": "person-dash",
            "status": "activity",
            "backup": "archive",
            "restore": "arrow-counterclockwise",
            "logs": "journal-text",
            "security": "shield-lock",
            "settings": "gear-fill",
            "translations": "translate"
        };
        
        // Try to match permission name with icon map
        for (var iconName in iconMap) {
            if (findNoCase(iconName, arguments.permissionName)) {
                return iconMap[iconName];
            }
        }
        
        return "gear"; // Default icon
    }
} 