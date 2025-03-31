component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function getRegulation(required numeric regulationID) {
        var result = queryExecute(
            "SELECT r.*, u.firstName, u.lastName
            FROM regulations r
            LEFT JOIN users u ON r.createdBy = u.userID
            WHERE r.regulationID = :regulationID",
            {regulationID = {value=arguments.regulationID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveRegulation(required struct regulationData) {
        var result = queryExecute(
            "INSERT INTO regulations (
                name,
                description,
                type,
                jurisdiction,
                status,
                createdBy,
                createdDate
            ) VALUES (
                :name,
                :description,
                :type,
                :jurisdiction,
                :status,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                name = {value=arguments.regulationData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.regulationData.description, cfsqltype="cf_sql_varchar"},
                type = {value=arguments.regulationData.type, cfsqltype="cf_sql_varchar"},
                jurisdiction = {value=arguments.regulationData.jurisdiction, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.regulationData.status, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.regulationData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, regulationID: result.generatedKey};
    }
    
    public struct function getRegulationRequirements(required numeric regulationID) {
        var result = queryExecute(
            "SELECT rr.*, u.firstName, u.lastName
            FROM regulation_requirements rr
            LEFT JOIN users u ON rr.createdBy = u.userID
            WHERE rr.regulationID = :regulationID
            ORDER BY rr.requirementOrder",
            {regulationID = {value=arguments.regulationID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveRegulationRequirement(required struct requirementData) {
        var result = queryExecute(
            "INSERT INTO regulation_requirements (
                regulationID,
                name,
                description,
                requirementOrder,
                createdBy,
                createdDate
            ) VALUES (
                :regulationID,
                :name,
                :description,
                :requirementOrder,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                regulationID = {value=arguments.requirementData.regulationID, cfsqltype="cf_sql_integer"},
                name = {value=arguments.requirementData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.requirementData.description, cfsqltype="cf_sql_varchar"},
                requirementOrder = {value=arguments.requirementData.requirementOrder, cfsqltype="cf_sql_integer"},
                createdBy = {value=arguments.requirementData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, requirementID: result.generatedKey};
    }
    
    public struct function updateRegulationStatus(required struct statusData) {
        queryExecute(
            "UPDATE regulations
            SET 
                status = :status,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE regulationID = :regulationID",
            {
                regulationID = {value=arguments.statusData.regulationID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.statusData.status, cfsqltype="cf_sql_varchar"},
                updatedBy = {value=arguments.statusData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function getRegulationCompliance(required numeric regulationID) {
        var result = queryExecute(
            "SELECT rc.*, u.firstName, u.lastName
            FROM regulation_compliance rc
            LEFT JOIN users u ON rc.userID = u.userID
            WHERE rc.regulationID = :regulationID
            ORDER BY rc.createdDate DESC",
            {regulationID = {value=arguments.regulationID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveComplianceAssessment(required struct assessmentData) {
        var result = queryExecute(
            "INSERT INTO regulation_compliance (
                regulationID,
                requirementID,
                status,
                notes,
                userID,
                createdDate
            ) VALUES (
                :regulationID,
                :requirementID,
                :status,
                :notes,
                :userID,
                CURRENT_TIMESTAMP
            )",
            {
                regulationID = {value=arguments.assessmentData.regulationID, cfsqltype="cf_sql_integer"},
                requirementID = {value=arguments.assessmentData.requirementID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.assessmentData.status, cfsqltype="cf_sql_varchar"},
                notes = {value=arguments.assessmentData.notes, cfsqltype="cf_sql_varchar"},
                userID = {value=arguments.assessmentData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, complianceID: result.generatedKey};
    }
} 