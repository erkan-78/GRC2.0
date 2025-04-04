component {
    public function init() {
        return this;
    }

    /**
     * Get all categories with translations for a specific language
     * @param string languageCode The language code to get translations for (e.g., en-US)
     * @param boolean includeInactive Whether to include inactive categories
     * @return struct Result with categories data
     */
    public function getCategories(string languageCode = "en-US", boolean includeInactive = false) {
        var result = {
            success: true,
            message: "",
            data: []
        };

        try {
            var sql = "
                SELECT 
                    c.categoryID,
                    c.categoryName,
                    c.categoryKey,
                    c.icon,
                    c.route,
                    c.parentCategoryID,
                    c.displayOrder,
                    c.isActive,
                    ct.label,
                    ct.description
                FROM 
                    categories c
                LEFT JOIN 
                    category_translations ct ON c.categoryID = ct.categoryID AND ct.languageCode = :languageCode
                WHERE 
                    1=1
            ";
            
            if (!arguments.includeInactive) {
                sql &= " AND c.isActive = 1";
            }
            
            sql &= " ORDER BY c.displayOrder, c.categoryName";
            
            var queryResult = queryExecute(
                sql,
                { languageCode: { value: arguments.languageCode, cfsqltype: "CF_SQL_VARCHAR" } },
                { datasource: "grc" }
            );
            
            // Convert query to array of structs
            for (var row in queryResult) {
                arrayAppend(result.data, {
                    categoryID: row.categoryID,
                    categoryName: row.categoryName,
                    categoryKey: row.categoryKey,
                    icon: row.icon,
                    route: row.route,
                    parentCategoryID: row.parentCategoryID,
                    displayOrder: row.displayOrder,
                    isActive: row.isActive,
                    label: row.label ?: row.categoryName,
                    description: row.description
                });
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    /**
     * Get a category by ID with translation for a specific language
     * @param numeric categoryID The category ID to get
     * @param string languageCode The language code to get translation for (e.g., en-US)
     * @return struct Result with category data
     */
    public function getCategory(required numeric categoryID, string languageCode = "en-US") {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            var sql = "
                SELECT 
                    c.categoryID,
                    c.categoryName,
                    c.categoryKey,
                    c.icon,
                    c.route,
                    c.parentCategoryID,
                    c.displayOrder,
                    c.isActive,
                    ct.label,
                    ct.description
                FROM 
                    categories c
                LEFT JOIN 
                    category_translations ct ON c.categoryID = ct.categoryID AND ct.languageCode = :languageCode
                WHERE 
                    c.categoryID = :categoryID
            ";
            
            var queryResult = queryExecute(
                sql,
                { 
                    categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                    languageCode: { value: arguments.languageCode, cfsqltype: "CF_SQL_VARCHAR" }
                },
                { datasource: "grc" }
            );
            
            if (queryResult.recordCount > 0) {
                var row = queryResult;
                result.data = {
                    categoryID: row.categoryID,
                    categoryName: row.categoryName,
                    categoryKey: row.categoryKey,
                    icon: row.icon,
                    route: row.route,
                    parentCategoryID: row.parentCategoryID,
                    displayOrder: row.displayOrder,
                    isActive: row.isActive,
                    label: row.label ?: row.categoryName,
                    description: row.description
                };
            } else {
                result.success = false;
                result.message = "Category not found";
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    /**
     * Create a new category
     * @param struct categoryData The category data to create
     * @return struct Result with created category data
     */
    public function createCategory(required struct categoryData) {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            // Validate required fields
            if (!structKeyExists(arguments.categoryData, "categoryName") || !len(arguments.categoryData.categoryName)) {
                throw("Category name is required");
            }
            
            if (!structKeyExists(arguments.categoryData, "categoryKey") || !len(arguments.categoryData.categoryKey)) {
                throw("Category key is required");
            }
            
            if (!structKeyExists(arguments.categoryData, "icon") || !len(arguments.categoryData.icon)) {
                throw("Icon is required");
            }
            
            if (!structKeyExists(arguments.categoryData, "route") || !len(arguments.categoryData.route)) {
                throw("Route is required");
            }
            
            // Check if category key already exists
            var checkSql = "
                SELECT COUNT(*) as count
                FROM categories
                WHERE categoryKey = :categoryKey
            ";
            
            var checkResult = queryExecute(
                checkSql,
                { categoryKey: { value: arguments.categoryData.categoryKey, cfsqltype: "CF_SQL_VARCHAR" } },
                { datasource: "grc" }
            );
            
            if (checkResult.count > 0) {
                throw("Category key already exists");
            }
            
            // Insert category
            var insertSql = "
                INSERT INTO categories (
                    categoryName,
                    categoryKey,
                    icon,
                    route,
                    parentCategoryID,
                    displayOrder,
                    isActive,
                    createdBy
                ) VALUES (
                    :categoryName,
                    :categoryKey,
                    :icon,
                    :route,
                    :parentCategoryID,
                    :displayOrder,
                    :isActive,
                    :createdBy
                )
            ";
            
            var insertParams = {
                categoryName: { value: arguments.categoryData.categoryName, cfsqltype: "CF_SQL_VARCHAR" },
                categoryKey: { value: arguments.categoryData.categoryKey, cfsqltype: "CF_SQL_VARCHAR" },
                icon: { value: arguments.categoryData.icon, cfsqltype: "CF_SQL_VARCHAR" },
                route: { value: arguments.categoryData.route, cfsqltype: "CF_SQL_VARCHAR" },
                parentCategoryID: { value: structKeyExists(arguments.categoryData, "parentCategoryID") ? arguments.categoryData.parentCategoryID : "", cfsqltype: "CF_SQL_INTEGER", null: !structKeyExists(arguments.categoryData, "parentCategoryID") },
                displayOrder: { value: structKeyExists(arguments.categoryData, "displayOrder") ? arguments.categoryData.displayOrder : 0, cfsqltype: "CF_SQL_INTEGER" },
                isActive: { value: structKeyExists(arguments.categoryData, "isActive") ? arguments.categoryData.isActive : 1, cfsqltype: "CF_SQL_BIT" },
                createdBy: { value: structKeyExists(arguments.categoryData, "createdBy") ? arguments.categoryData.createdBy : 1, cfsqltype: "CF_SQL_INTEGER" }
            };
            
            var insertResult = queryExecute(
                insertSql,
                insertParams,
                { datasource: "grc", result: "local.insertResult" }
            );
            
            var categoryID = local.insertResult.generatedKey;
            
            // Insert default English translation if provided
            if (structKeyExists(arguments.categoryData, "label") && len(arguments.categoryData.label)) {
                var translationSql = "
                    INSERT INTO category_translations (
                        categoryID,
                        languageCode,
                        label,
                        description,
                        createdBy
                    ) VALUES (
                        :categoryID,
                        :languageCode,
                        :label,
                        :description,
                        :createdBy
                    )
                ";
                
                var translationParams = {
                    categoryID: { value: categoryID, cfsqltype: "CF_SQL_INTEGER" },
                    languageCode: { value: "en-US", cfsqltype: "CF_SQL_VARCHAR" },
                    label: { value: arguments.categoryData.label, cfsqltype: "CF_SQL_VARCHAR" },
                    description: { value: structKeyExists(arguments.categoryData, "description") ? arguments.categoryData.description : "", cfsqltype: "CF_SQL_VARCHAR" },
                    createdBy: { value: structKeyExists(arguments.categoryData, "createdBy") ? arguments.categoryData.createdBy : 1, cfsqltype: "CF_SQL_INTEGER" }
                };
                
                queryExecute(
                    translationSql,
                    translationParams,
                    { datasource: "grc" }
                );
            }
            
            // Get the created category
            result.data = getCategory(categoryID).data;
            result.message = "Category created successfully";
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    /**
     * Update an existing category
     * @param numeric categoryID The category ID to update
     * @param struct categoryData The category data to update
     * @return struct Result with updated category data
     */
    public function updateCategory(required numeric categoryID, required struct categoryData) {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            // Check if category exists
            var checkResult = getCategory(arguments.categoryID);
            if (!checkResult.success) {
                throw("Category not found");
            }
            
            // Update category
            var updateSql = "
                UPDATE categories
                SET 
                    categoryName = :categoryName,
                    categoryKey = :categoryKey,
                    icon = :icon,
                    route = :route,
                    parentCategoryID = :parentCategoryID,
                    displayOrder = :displayOrder,
                    isActive = :isActive,
                    updatedBy = :updatedBy,
                    updatedDate = CURRENT_TIMESTAMP
                WHERE 
                    categoryID = :categoryID
            ";
            
            var updateParams = {
                categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                categoryName: { value: structKeyExists(arguments.categoryData, "categoryName") ? arguments.categoryData.categoryName : checkResult.data.categoryName, cfsqltype: "CF_SQL_VARCHAR" },
                categoryKey: { value: structKeyExists(arguments.categoryData, "categoryKey") ? arguments.categoryData.categoryKey : checkResult.data.categoryKey, cfsqltype: "CF_SQL_VARCHAR" },
                icon: { value: structKeyExists(arguments.categoryData, "icon") ? arguments.categoryData.icon : checkResult.data.icon, cfsqltype: "CF_SQL_VARCHAR" },
                route: { value: structKeyExists(arguments.categoryData, "route") ? arguments.categoryData.route : checkResult.data.route, cfsqltype: "CF_SQL_VARCHAR" },
                parentCategoryID: { value: structKeyExists(arguments.categoryData, "parentCategoryID") ? arguments.categoryData.parentCategoryID : checkResult.data.parentCategoryID, cfsqltype: "CF_SQL_INTEGER", null: !structKeyExists(arguments.categoryData, "parentCategoryID") },
                displayOrder: { value: structKeyExists(arguments.categoryData, "displayOrder") ? arguments.categoryData.displayOrder : checkResult.data.displayOrder, cfsqltype: "CF_SQL_INTEGER" },
                isActive: { value: structKeyExists(arguments.categoryData, "isActive") ? arguments.categoryData.isActive : checkResult.data.isActive, cfsqltype: "CF_SQL_BIT" },
                updatedBy: { value: structKeyExists(arguments.categoryData, "updatedBy") ? arguments.categoryData.updatedBy : 1, cfsqltype: "CF_SQL_INTEGER" }
            };
            
            queryExecute(
                updateSql,
                updateParams,
                { datasource: "grc" }
            );
            
            // Update translation if provided
            if (structKeyExists(arguments.categoryData, "label") && len(arguments.categoryData.label)) {
                var checkTranslationSql = "
                    SELECT COUNT(*) as count
                    FROM category_translations
                    WHERE categoryID = :categoryID AND languageCode = :languageCode
                ";
                
                var checkTranslationResult = queryExecute(
                    checkTranslationSql,
                    { 
                        categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                        languageCode: { value: "en-US", cfsqltype: "CF_SQL_VARCHAR" }
                    },
                    { datasource: "grc" }
                );
                
                if (checkTranslationResult.count > 0) {
                    // Update existing translation
                    var updateTranslationSql = "
                        UPDATE category_translations
                        SET 
                            label = :label,
                            description = :description,
                            updatedBy = :updatedBy,
                            updatedDate = CURRENT_TIMESTAMP
                        WHERE 
                            categoryID = :categoryID AND languageCode = :languageCode
                    ";
                    
                    var updateTranslationParams = {
                        categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                        languageCode: { value: "en-US", cfsqltype: "CF_SQL_VARCHAR" },
                        label: { value: arguments.categoryData.label, cfsqltype: "CF_SQL_VARCHAR" },
                        description: { value: structKeyExists(arguments.categoryData, "description") ? arguments.categoryData.description : "", cfsqltype: "CF_SQL_VARCHAR" },
                        updatedBy: { value: structKeyExists(arguments.categoryData, "updatedBy") ? arguments.categoryData.updatedBy : 1, cfsqltype: "CF_SQL_INTEGER" }
                    };
                    
                    queryExecute(
                        updateTranslationSql,
                        updateTranslationParams,
                        { datasource: "grc" }
                    );
                } else {
                    // Insert new translation
                    var insertTranslationSql = "
                        INSERT INTO category_translations (
                            categoryID,
                            languageCode,
                            label,
                            description,
                            createdBy
                        ) VALUES (
                            :categoryID,
                            :languageCode,
                            :label,
                            :description,
                            :createdBy
                        )
                    ";
                    
                    var insertTranslationParams = {
                        categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                        languageCode: { value: "en-US", cfsqltype: "CF_SQL_VARCHAR" },
                        label: { value: arguments.categoryData.label, cfsqltype: "CF_SQL_VARCHAR" },
                        description: { value: structKeyExists(arguments.categoryData, "description") ? arguments.categoryData.description : "", cfsqltype: "CF_SQL_VARCHAR" },
                        createdBy: { value: structKeyExists(arguments.categoryData, "updatedBy") ? arguments.categoryData.updatedBy : 1, cfsqltype: "CF_SQL_INTEGER" }
                    };
                    
                    queryExecute(
                        insertTranslationSql,
                        insertTranslationParams,
                        { datasource: "grc" }
                    );
                }
            }
            
            // Get the updated category
            result.data = getCategory(arguments.categoryID).data;
            result.message = "Category updated successfully";
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    /**
     * Delete a category
     * @param numeric categoryID The category ID to delete
     * @return struct Result with success status
     */
    public function deleteCategory(required numeric categoryID) {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            // Check if category exists
            var checkResult = getCategory(arguments.categoryID);
            if (!checkResult.success) {
                throw("Category not found");
            }
            
            // Delete category (translations will be deleted automatically due to CASCADE)
            var deleteSql = "
                DELETE FROM categories
                WHERE categoryID = :categoryID
            ";
            
            queryExecute(
                deleteSql,
                { categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" } },
                { datasource: "grc" }
            );
            
            result.message = "Category deleted successfully";
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }

    /**
     * Add a translation for a category
     * @param numeric categoryID The category ID
     * @param string languageCode The language code (e.g., en-US)
     * @param string label The translated label
     * @param string description The translated description
     * @param numeric userID The user ID who is adding the translation
     * @return struct Result with success status
     */
    public function addTranslation(
        required numeric categoryID,
        required string languageCode,
        required string label,
        string description = "",
        numeric userID = 1
    ) {
        var result = {
            success: true,
            message: "",
            data: {}
        };

        try {
            // Check if category exists
            var checkResult = getCategory(arguments.categoryID);
            if (!checkResult.success) {
                throw("Category not found");
            }
            
            // Check if translation already exists
            var checkTranslationSql = "
                SELECT COUNT(*) as count
                FROM category_translations
                WHERE categoryID = :categoryID AND languageCode = :languageCode
            ";
            
            var checkTranslationResult = queryExecute(
                checkTranslationSql,
                { 
                    categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                    languageCode: { value: arguments.languageCode, cfsqltype: "CF_SQL_VARCHAR" }
                },
                { datasource: "grc" }
            );
            
            if (checkTranslationResult.count > 0) {
                // Update existing translation
                var updateTranslationSql = "
                    UPDATE category_translations
                    SET 
                        label = :label,
                        description = :description,
                        updatedBy = :updatedBy,
                        updatedDate = CURRENT_TIMESTAMP
                    WHERE 
                        categoryID = :categoryID AND languageCode = :languageCode
                ";
                
                var updateTranslationParams = {
                    categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                    languageCode: { value: arguments.languageCode, cfsqltype: "CF_SQL_VARCHAR" },
                    label: { value: arguments.label, cfsqltype: "CF_SQL_VARCHAR" },
                    description: { value: arguments.description, cfsqltype: "CF_SQL_VARCHAR" },
                    updatedBy: { value: arguments.userID, cfsqltype: "CF_SQL_INTEGER" }
                };
                
                queryExecute(
                    updateTranslationSql,
                    updateTranslationParams,
                    { datasource: "grc" }
                );
                
                result.message = "Translation updated successfully";
            } else {
                // Insert new translation
                var insertTranslationSql = "
                    INSERT INTO category_translations (
                        categoryID,
                        languageCode,
                        label,
                        description,
                        createdBy
                    ) VALUES (
                        :categoryID,
                        :languageCode,
                        :label,
                        :description,
                        :createdBy
                    )
                ";
                
                var insertTranslationParams = {
                    categoryID: { value: arguments.categoryID, cfsqltype: "CF_SQL_INTEGER" },
                    languageCode: { value: arguments.languageCode, cfsqltype: "CF_SQL_VARCHAR" },
                    label: { value: arguments.label, cfsqltype: "CF_SQL_VARCHAR" },
                    description: { value: arguments.description, cfsqltype: "CF_SQL_VARCHAR" },
                    createdBy: { value: arguments.userID, cfsqltype: "CF_SQL_INTEGER" }
                };
                
                queryExecute(
                    insertTranslationSql,
                    insertTranslationParams,
                    { datasource: "grc" }
                );
                
                result.message = "Translation added successfully";
            }
        } catch (any e) {
            result.success = false;
            result.message = e.message;
        }

        return result;
    }
} 