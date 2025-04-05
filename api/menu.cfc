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
            
            // Get menu sections with translations
            var qMenuSections = queryExecute(
                "SELECT 
                    ms.sectionID,
                    ms.sectionName,
                    ms.displayOrder,
                    ms.icon,
                    mst.label as sectionLabel,
                    mst.description as sectionDescription
                FROM menu_sections ms
                INNER JOIN menu_section_translations mst ON ms.sectionID = mst.sectionID
                WHERE ms.isActive = 1
                AND mst.languageID = :languageID
                ORDER BY ms.displayOrder",
                {languageID = {value=session.preferredLanguage, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );
            
            // Get menu items for user's profiles
            var qMenuItems = queryExecute(
                "SELECT DISTINCT 
                    p.permissionID,
                    p.permissionName,
                    p.category,
                    p.route,
                    p.sectionID,
                    pt.label as menuLabel,
                    pt.description as menuDescription
                FROM permissions p
                INNER JOIN profilePermissions pp ON p.permissionID = pp.permissionID
                INNER JOIN permission_translations pt ON p.permissionName = pt.permissionKey
                WHERE pp.profileID IN (#profileIDs#)
                AND p.isActive = 1
                AND pt.languageID = :languageID
                ORDER BY p.sectionID, p.category",
                {languageID = {value=session.preferredLanguage, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );
            
            // Build menu structure with sections
            var menuStructure = buildMenuStructure(queryToArray(qMenuSections), queryToArray(qMenuItems));
            
            return {
                "success": true,
                "data": menuStructure
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching user menu",
                "error": e.message
            };
        }
    }
    
    remote struct function getMenuSections() httpmethod="GET" {
        init();
        
        try {
            // Get all menu sections with translations
            var qMenuSections = queryExecute(
                "SELECT 
                    ms.sectionID,
                    ms.sectionName,
                    ms.displayOrder,
                    ms.icon,
                    ms.isActive,
                    mst.label as sectionLabel,
                    mst.description as sectionDescription,
                    mst.languageID
                FROM menu_sections ms
                LEFT JOIN menu_section_translations mst ON ms.sectionID = mst.sectionID
                ORDER BY ms.displayOrder",
                {},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "data": queryToArray(qMenuSections)
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching menu sections",
                "error": e.message
            };
        }
    }
    
    remote struct function saveMenuSection(required struct sectionData) httpmethod="POST" {
        init();
        
        try {
            var sectionID = arguments.sectionData.sectionID ?: 0;
            var sectionName = arguments.sectionData.sectionName;
            var displayOrder = arguments.sectionData.displayOrder ?: 0;
            var icon = arguments.sectionData.icon ?: "";
            var isActive = arguments.sectionData.isActive ?: 1;
            var translations = arguments.sectionData.translations ?: [];
            
            // Begin transaction
            transaction {
                if (sectionID == 0) {
                    // Insert new section
                    var result = queryExecute(
                        "INSERT INTO menu_sections (
                            sectionName, 
                            displayOrder, 
                            icon, 
                            isActive
                        ) VALUES (
                            :sectionName, 
                            :displayOrder, 
                            :icon, 
                            :isActive
                        )",
                        {
                            sectionName = {value=sectionName, cfsqltype="cf_sql_varchar"},
                            displayOrder = {value=displayOrder, cfsqltype="cf_sql_integer"},
                            icon = {value=icon, cfsqltype="cf_sql_varchar"},
                            isActive = {value=isActive, cfsqltype="cf_sql_bit"}
                        },
                        {datasource=application.datasource, result="insertResult"}
                    );
                    
                    sectionID = insertResult.generatedKey;
                } else {
                    // Update existing section
                    queryExecute(
                        "UPDATE menu_sections SET 
                            sectionName = :sectionName, 
                            displayOrder = :displayOrder, 
                            icon = :icon, 
                            isActive = :isActive
                        WHERE sectionID = :sectionID",
                        {
                            sectionID = {value=sectionID, cfsqltype="cf_sql_integer"},
                            sectionName = {value=sectionName, cfsqltype="cf_sql_varchar"},
                            displayOrder = {value=displayOrder, cfsqltype="cf_sql_integer"},
                            icon = {value=icon, cfsqltype="cf_sql_varchar"},
                            isActive = {value=isActive, cfsqltype="cf_sql_bit"}
                        },
                        {datasource=application.datasource}
                    );
                    
                    // Delete existing translations
                    queryExecute(
                        "DELETE FROM menu_section_translations WHERE sectionID = :sectionID",
                        {sectionID = {value=sectionID, cfsqltype="cf_sql_integer"}},
                        {datasource=application.datasource}
                    );
                }
                
                // Insert translations
                for (var translation in translations) {
                    queryExecute(
                        "INSERT INTO menu_section_translations (
                            sectionID, 
                            languageID, 
                            label, 
                            description
                        ) VALUES (
                            :sectionID, 
                            :languageID, 
                            :label, 
                            :description
                        )",
                        {
                            sectionID = {value=sectionID, cfsqltype="cf_sql_integer"},
                            languageID = {value=translation.languageID, cfsqltype="cf_sql_varchar"},
                            label = {value=translation.label, cfsqltype="cf_sql_varchar"},
                            description = {value=translation.description ?: "", cfsqltype="cf_sql_varchar"}
                        },
                        {datasource=application.datasource}
                    );
                }
            }
            
            return {
                "success": true,
                "message": "Menu section saved successfully",
                "data": {
                    "sectionID": sectionID
                }
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while saving menu section",
                "error": e.message
            };
        }
    }
    
    remote struct function deleteMenuSection(required numeric sectionID) httpmethod="POST" {
        init();
        
        try {
            // Check if section has menu items
            var qCheckItems = queryExecute(
                "SELECT COUNT(*) as itemCount FROM permissions WHERE sectionID = :sectionID",
                {sectionID = {value=arguments.sectionID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qCheckItems.itemCount > 0) {
                return {
                    "success": false,
                    "message": "Cannot delete section with existing menu items"
                };
            }
            
            // Delete section (translations will be deleted via CASCADE)
            queryExecute(
                "DELETE FROM menu_sections WHERE sectionID = :sectionID",
                {sectionID = {value=arguments.sectionID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "message": "Menu section deleted successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while deleting menu section",
                "error": e.message
            };
        }
    }

    private array function buildMenuStructure(required array sections, required array menuItems) {
        var menuStructure = [];
        
        // Group menu items by section
        var itemsBySection = {};
        for (var item in arguments.menuItems) {
            var sectionID = item.sectionID ?: 0;
            if (!structKeyExists(itemsBySection, sectionID)) {
                itemsBySection[sectionID] = [];
            }
            arrayAppend(itemsBySection[sectionID], item);
        }
        
        // Build menu structure with sections
        for (var section in arguments.sections) {
            var sectionID = section.sectionID;
            var sectionItems = structKeyExists(itemsBySection, sectionID) ? itemsBySection[sectionID] : [];
            
            var menuSection = {
                "id": sectionID,
                "name": section.sectionName,
                "label": section.sectionLabel,
                "description": section.sectionDescription,
                "icon": section.icon,
                "items": []
            };
            
            // Add menu items to section
            for (var item in sectionItems) {
                arrayAppend(menuSection.items, {
                    "id": item.permissionID,
                    "name": item.permissionName,
                    "label": item.menuLabel,
                    "description": item.menuDescription,
                    "route": item.route,
                    "category": item.category
                });
            }
            
            arrayAppend(menuStructure, menuSection);
        }
        
        return menuStructure;
    }

    private array function queryToArray(required query qry) {
        var array = [];
        for (var row in arguments.qry) {
            arrayAppend(array, row);
        }
        return array;
    }
} 