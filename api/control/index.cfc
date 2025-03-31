component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function getControl(required numeric controlID) {
        var result = queryExecute(
            "SELECT c.*, u.firstName, u.lastName
            FROM controls c
            LEFT JOIN users u ON c.createdBy = u.userID
            WHERE c.controlID = :controlID",
            {controlID = {value=arguments.controlID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveControl(required struct controlData) {
        var result = queryExecute(
            "INSERT INTO controls (
                name,
                description,
                type,
                category,
                status,
                createdBy,
                createdDate
            ) VALUES (
                :name,
                :description,
                :type,
                :category,
                :status,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                name = {value=arguments.controlData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.controlData.description, cfsqltype="cf_sql_varchar"},
                type = {value=arguments.controlData.type, cfsqltype="cf_sql_varchar"},
                category = {value=arguments.controlData.category, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.controlData.status, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.controlData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, controlID: result.generatedKey};
    }
    
    public struct function getControlTests(required numeric controlID) {
        var result = queryExecute(
            "SELECT ct.*, u.firstName, u.lastName
            FROM control_tests ct
            LEFT JOIN users u ON ct.createdBy = u.userID
            WHERE ct.controlID = :controlID
            ORDER BY ct.testDate DESC",
            {controlID = {value=arguments.controlID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveControlTest(required struct testData) {
        var result = queryExecute(
            "INSERT INTO control_tests (
                controlID,
                name,
                description,
                testDate,
                result,
                notes,
                createdBy,
                createdDate
            ) VALUES (
                :controlID,
                :name,
                :description,
                :testDate,
                :result,
                :notes,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                controlID = {value=arguments.testData.controlID, cfsqltype="cf_sql_integer"},
                name = {value=arguments.testData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.testData.description, cfsqltype="cf_sql_varchar"},
                testDate = {value=arguments.testData.testDate, cfsqltype="cf_sql_timestamp"},
                result = {value=arguments.testData.result, cfsqltype="cf_sql_varchar"},
                notes = {value=arguments.testData.notes, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.testData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, testID: result.generatedKey};
    }
    
    public struct function updateControlStatus(required struct statusData) {
        queryExecute(
            "UPDATE controls
            SET 
                status = :status,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE controlID = :controlID",
            {
                controlID = {value=arguments.statusData.controlID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.statusData.status, cfsqltype="cf_sql_varchar"},
                updatedBy = {value=arguments.statusData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function getControlEvidence(required numeric controlID) {
        var result = queryExecute(
            "SELECT ce.*, u.firstName, u.lastName
            FROM control_evidence ce
            LEFT JOIN users u ON ce.uploadedBy = u.userID
            WHERE ce.controlID = :controlID
            ORDER BY ce.uploadedDate DESC",
            {controlID = {value=arguments.controlID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveControlEvidence(required struct evidenceData) {
        var result = queryExecute(
            "INSERT INTO control_evidence (
                controlID,
                fileName,
                filePath,
                fileType,
                fileSize,
                uploadedBy,
                uploadedDate
            ) VALUES (
                :controlID,
                :fileName,
                :filePath,
                :fileType,
                :fileSize,
                :uploadedBy,
                CURRENT_TIMESTAMP
            )",
            {
                controlID = {value=arguments.evidenceData.controlID, cfsqltype="cf_sql_integer"},
                fileName = {value=arguments.evidenceData.fileName, cfsqltype="cf_sql_varchar"},
                filePath = {value=arguments.evidenceData.filePath, cfsqltype="cf_sql_varchar"},
                fileType = {value=arguments.evidenceData.fileType, cfsqltype="cf_sql_varchar"},
                fileSize = {value=arguments.evidenceData.fileSize, cfsqltype="cf_sql_integer"},
                uploadedBy = {value=arguments.evidenceData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, evidenceID: result.generatedKey};
    }
} 