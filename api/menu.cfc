component {
    // Set response type to JSON
    remote any function init() {
        getPageContext().getResponse().setContentType("application/json");
    }

    remote struct function getUserMenu(required numeric userID) httpmethod="GET" {
        init();
        
        try {
            if (NOT session.isLoggedIn OR session.userID NEQ arguments.userID) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }
            
            // Get user's profiles
            var qUserProfiles = queryExecute(
                "SELECT DISTINCT p.profileID 
                FROM profiles p 
                INNER JOIN userProfiles up ON p.profileID = up.profileID 
                WHERE up.userID = :userID AND p.isActive = 1",
                {userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (NOT qUserProfiles.recordCount) {
                return {
                    "success": true,
                    "data": []
                };
            }
            
            // Build profile IDs list
            var profileIDs = valueList(qUserProfiles.profileID);
            
            // Get menu items for user's profiles
            var qMenuItems = queryExecute(
                "SELECT DISTINCT 
                    m.menuItemID,
                    m.parentMenuItemID,
                    m.menuOrder,
                    m.icon,
                    m.route,
                    m.translationKey,
                    t.translationValue as menuLabel
                FROM menuItems m
                INNER JOIN profileMenuPermissions pmp ON m.menuItemID = pmp.menuItemID
                INNER JOIN translations t ON m.translationKey = t.translationKey
                WHERE pmp.profileID IN (#profileIDs#)
                AND m.isActive = 1
                AND t.languageID = :languageID
                ORDER BY m.parentMenuItemID, m.menuOrder",
                {languageID = {value=session.preferredLanguage, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );
            
            // Build menu tree
            var menuTree = buildMenuTree(queryToArray(qMenuItems));
            
            return {
                "success": true,
                "data": menuTree
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching user menu",
                "error": e.message
            };
        }
    }

    private array function buildMenuTree(required array menuItems, parentID = 0) {
        var tree = [];
        
        for (var item in arguments.menuItems) {
            if ((isNull(item.parentMenuItemID) AND arguments.parentID == 0) OR 
                (NOT isNull(item.parentMenuItemID) AND item.parentMenuItemID == arguments.parentID)) {
                var menuItem = {
                    "id": item.menuItemID,
                    "label": item.menuLabel,
                    "icon": item.icon,
                    "route": item.route,
                    "translationKey": item.translationKey
                };
                
                // Check for children
                var children = buildMenuTree(arguments.menuItems, item.menuItemID);
                if (arrayLen(children)) {
                    menuItem["children"] = children;
                }
                
                arrayAppend(tree, menuItem);
            }
        }
        
        return tree;
    }

    private array function queryToArray(required query qry) {
        var array = [];
        for (var row in arguments.qry) {
            arrayAppend(array, row);
        }
        return array;
    }
} 