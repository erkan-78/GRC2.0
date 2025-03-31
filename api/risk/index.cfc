component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function getRisksByLevel(required numeric companyID) {
        var result = queryExecute(
            "SELECT r.*, c.name as categoryName
            FROM risks r
            LEFT JOIN risk_categories c ON r.categoryID = c.categoryID
            WHERE r.companyID = :companyID
            ORDER BY r.riskLevel DESC",
            {companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function getRisk(required numeric id) {
        var result = queryExecute(
            "SELECT r.*, c.name as categoryName, u.firstName, u.lastName
            FROM risks r
            LEFT JOIN risk_categories c ON r.categoryID = c.categoryID
            LEFT JOIN users u ON r.assignedTo = u.userID
            WHERE r.riskID = :id",
            {id = {value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function getTreatment(required numeric id) {
        var result = queryExecute(
            "SELECT t.*, u.firstName, u.lastName
            FROM risk_treatments t
            LEFT JOIN users u ON t.createdBy = u.userID
            WHERE t.riskID = :id
            ORDER BY t.createdDate DESC",
            {id = {value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveRisk(required struct riskData) {
        var result = queryExecute(
            "INSERT INTO risks (
                companyID,
                categoryID,
                title,
                description,
                riskLevel,
                impact,
                probability,
                assignedTo,
                createdBy,
                createdDate
            ) VALUES (
                :companyID,
                :categoryID,
                :title,
                :description,
                :riskLevel,
                :impact,
                :probability,
                :assignedTo,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                companyID = {value=arguments.riskData.companyID, cfsqltype="cf_sql_integer"},
                categoryID = {value=arguments.riskData.categoryID, cfsqltype="cf_sql_integer"},
                title = {value=arguments.riskData.title, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.riskData.description, cfsqltype="cf_sql_varchar"},
                riskLevel = {value=arguments.riskData.riskLevel, cfsqltype="cf_sql_integer"},
                impact = {value=arguments.riskData.impact, cfsqltype="cf_sql_integer"},
                probability = {value=arguments.riskData.probability, cfsqltype="cf_sql_integer"},
                assignedTo = {value=arguments.riskData.assignedTo, cfsqltype="cf_sql_integer"},
                createdBy = {value=arguments.riskData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, riskID: result.generatedKey};
    }
    
    public struct function saveTreatment(required struct treatmentData) {
        var result = queryExecute(
            "INSERT INTO risk_treatments (
                riskID,
                title,
                description,
                status,
                createdBy,
                createdDate
            ) VALUES (
                :riskID,
                :title,
                :description,
                :status,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                riskID = {value=arguments.treatmentData.riskID, cfsqltype="cf_sql_integer"},
                title = {value=arguments.treatmentData.title, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.treatmentData.description, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.treatmentData.status, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.treatmentData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, treatmentID: result.generatedKey};
    }
    
    public struct function saveAppetiteSettings(required struct settings) {
        queryExecute(
            "UPDATE risk_appetite_settings
            SET 
                lowThreshold = :lowThreshold,
                mediumThreshold = :mediumThreshold,
                highThreshold = :highThreshold,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE companyID = :companyID",
            {
                companyID = {value=arguments.settings.companyID, cfsqltype="cf_sql_integer"},
                lowThreshold = {value=arguments.settings.lowThreshold, cfsqltype="cf_sql_integer"},
                mediumThreshold = {value=arguments.settings.mediumThreshold, cfsqltype="cf_sql_integer"},
                highThreshold = {value=arguments.settings.highThreshold, cfsqltype="cf_sql_integer"},
                updatedBy = {value=arguments.settings.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function saveMethodology(required struct methodology) {
        queryExecute(
            "UPDATE risk_methodology
            SET 
                description = :description,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE companyID = :companyID",
            {
                companyID = {value=arguments.methodology.companyID, cfsqltype="cf_sql_integer"},
                description = {value=arguments.methodology.description, cfsqltype="cf_sql_varchar"},
                updatedBy = {value=arguments.methodology.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function exportDashboard(required string format) {
        // Implementation for dashboard export
        var fileName = "risk_dashboard_#dateFormat(now(), "yyyymmdd")#.#arguments.format#";
        var filePath = expandPath("./downloads/#fileName#");
        
        // Export logic would go here
        
        return {
            success: true,
            fileName: fileName,
            filePath: filePath
        };
    }
    
    public struct function exportReport(required string format) {
        // Implementation for report export
        var fileName = "risk_report_#dateFormat(now(), "yyyymmdd")#.#arguments.format#";
        var filePath = expandPath("./downloads/#fileName#");
        
        // Export logic would go here
        
        return {
            success: true,
            fileName: fileName,
            filePath: filePath
        };
    }
} 