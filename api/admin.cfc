component {
    // Set response type to JSON
    remote any function init() {
        getPageContext().getResponse().setContentType("application/json");
    }

    // Translation Management
    remote struct function getAllTranslations() httpmethod="GET" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            var qTranslations = queryExecute(
                "SELECT translationKey, languageID, translationValue 
                FROM translations 
                ORDER BY translationKey, languageID",
                {},
                {datasource=application.datasource}
            );
            
            var translations = {};
            for (var row in qTranslations) {
                if (NOT structKeyExists(translations, row.translationKey)) {
                    translations[row.translationKey] = {};
                }
                translations[row.translationKey][row.languageID] = row.translationValue;
            }
            
            return {
                "success": true,
                "data": translations
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching translations",
                "error": e.message
            };
        }
    }

    remote struct function getTranslation(required string translationKey) httpmethod="GET" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            var qTranslation = queryExecute(
                "SELECT languageID, translationValue 
                FROM translations 
                WHERE translationKey = :translationKey",
                {translationKey = {value=arguments.translationKey, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );
            
            var translations = {};
            for (var row in qTranslation) {
                translations[row.languageID] = row.translationValue;
            }
            
            return {
                "success": true,
                "data": translations
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching translation",
                "error": e.message
            };
        }
    }

    remote struct function saveTranslation(
        required string translationKey,
        required struct translations,
        required boolean isNew
    ) httpmethod="POST" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            transaction {
                if (arguments.isNew) {
                    // Delete any existing translations for this key
                    queryExecute(
                        "DELETE FROM translations WHERE translationKey = :translationKey",
                        {translationKey = {value=arguments.translationKey, cfsqltype="cf_sql_varchar"}},
                        {datasource=application.datasource}
                    );
                }
                
                // Insert new translations
                for (var languageID in arguments.translations) {
                    queryExecute(
                        "INSERT INTO translations (translationKey, languageID, translationValue) 
                        VALUES (:translationKey, :languageID, :translationValue)",
                        {
                            translationKey = {value=arguments.translationKey, cfsqltype="cf_sql_varchar"},
                            languageID = {value=languageID, cfsqltype="cf_sql_varchar"},
                            translationValue = {value=arguments.translations[languageID], cfsqltype="cf_sql_varchar"}
                        },
                        {datasource=application.datasource}
                    );
                }
            }
            
            return {
                "success": true,
                "message": "Translation saved successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while saving translation",
                "error": e.message
            };
        }
    }

    remote struct function deleteTranslation(required string translationKey) httpmethod="POST" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            queryExecute(
                "DELETE FROM translations WHERE translationKey = :translationKey",
                {translationKey = {value=arguments.translationKey, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "message": "Translation deleted successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while deleting translation",
                "error": e.message
            };
        }
    }

    // Menu Items Management
    remote struct function getAllMenuItems() httpmethod="GET" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            var qMenuItems = queryExecute(
                "SELECT m.menuItemID, m.parentMenuItemID, m.menuOrder, m.icon, m.route, 
                    m.translationKey, m.isActive, t.translationValue as label,
                    p.translationValue as parentLabel
                FROM menuItems m
                LEFT JOIN translations t ON m.translationKey = t.translationKey
                LEFT JOIN menuItems parent ON m.parentMenuItemID = parent.menuItemID
                LEFT JOIN translations p ON parent.translationKey = p.translationKey
                WHERE t.languageID = :languageID
                AND (p.languageID = :languageID OR p.languageID IS NULL)
                ORDER BY m.parentMenuItemID, m.menuOrder",
                {languageID = {value=session.preferredLanguage, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "data": queryToArray(qMenuItems)
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching menu items",
                "error": e.message
            };
        }
    }

    remote struct function getMenuItem(required numeric menuItemID) httpmethod="GET" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            var qMenuItem = queryExecute(
                "SELECT menuItemID, parentMenuItemID, menuOrder, icon, route, translationKey, isActive
                FROM menuItems 
                WHERE menuItemID = :menuItemID",
                {menuItemID = {value=arguments.menuItemID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qMenuItem.recordCount) {
                return {
                    "success": true,
                    "data": queryToArray(qMenuItem)[1]
                };
            } else {
                return {
                    "success": false,
                    "message": "Menu item not found"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching menu item",
                "error": e.message
            };
        }
    }

    remote struct function saveMenuItem(
        required struct menuItem,
        required boolean isNew
    ) httpmethod="POST" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            if (arguments.isNew) {
                queryExecute(
                    "INSERT INTO menuItems (
                        parentMenuItemID, menuOrder, icon, route, translationKey, isActive
                    ) VALUES (
                        :parentMenuItemID, :menuOrder, :icon, :route, :translationKey, :isActive
                    )",
                    {
                        parentMenuItemID = {value=arguments.menuItem.parentMenuItemID, cfsqltype="cf_sql_integer", null=!len(arguments.menuItem.parentMenuItemID)},
                        menuOrder = {value=arguments.menuItem.menuOrder, cfsqltype="cf_sql_integer"},
                        icon = {value=arguments.menuItem.icon, cfsqltype="cf_sql_varchar", null=!len(arguments.menuItem.icon)},
                        route = {value=arguments.menuItem.route, cfsqltype="cf_sql_varchar"},
                        translationKey = {value=arguments.menuItem.translationKey, cfsqltype="cf_sql_varchar"},
                        isActive = {value=arguments.menuItem.isActive, cfsqltype="cf_sql_bit"}
                    },
                    {datasource=application.datasource}
                );
            } else {
                queryExecute(
                    "UPDATE menuItems SET 
                        parentMenuItemID = :parentMenuItemID,
                        menuOrder = :menuOrder,
                        icon = :icon,
                        route = :route,
                        translationKey = :translationKey,
                        isActive = :isActive
                    WHERE menuItemID = :menuItemID",
                    {
                        menuItemID = {value=arguments.menuItem.menuItemID, cfsqltype="cf_sql_integer"},
                        parentMenuItemID = {value=arguments.menuItem.parentMenuItemID, cfsqltype="cf_sql_integer", null=!len(arguments.menuItem.parentMenuItemID)},
                        menuOrder = {value=arguments.menuItem.menuOrder, cfsqltype="cf_sql_integer"},
                        icon = {value=arguments.menuItem.icon, cfsqltype="cf_sql_varchar", null=!len(arguments.menuItem.icon)},
                        route = {value=arguments.menuItem.route, cfsqltype="cf_sql_varchar"},
                        translationKey = {value=arguments.menuItem.translationKey, cfsqltype="cf_sql_varchar"},
                        isActive = {value=arguments.menuItem.isActive, cfsqltype="cf_sql_bit"}
                    },
                    {datasource=application.datasource}
                );
            }
            
            return {
                "success": true,
                "message": "Menu item saved successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while saving menu item",
                "error": e.message
            };
        }
    }

    remote struct function deleteMenuItem(required numeric menuItemID) httpmethod="POST" {
        init();
        
        try {
            if (NOT isAdmin()) {
                return unauthorized();
            }
            
            // Check if menu item has children
            var qChildren = queryExecute(
                "SELECT menuItemID FROM menuItems WHERE parentMenuItemID = :menuItemID",
                {menuItemID = {value=arguments.menuItemID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qChildren.recordCount) {
                return {
                    "success": false,
                    "message": "Cannot delete menu item with children. Please delete or reassign children first."
                };
            }
            
            // Delete menu item
            queryExecute(
                "DELETE FROM menuItems WHERE menuItemID = :menuItemID",
                {menuItemID = {value=arguments.menuItemID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "message": "Menu item deleted successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while deleting menu item",
                "error": e.message
            };
        }
    }

    // Helper Functions
    private boolean function isAdmin() {
        return structKeyExists(session, "isLoggedIn") 
            AND session.isLoggedIn 
            AND session.userRole EQ "admin";
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