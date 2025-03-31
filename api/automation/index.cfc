component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function getAutomation(required numeric automationID) {
        var result = queryExecute(
            "SELECT a.*, u.firstName, u.lastName
            FROM automations a
            LEFT JOIN users u ON a.createdBy = u.userID
            WHERE a.automationID = :automationID",
            {automationID = {value=arguments.automationID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveAutomation(required struct automationData) {
        var result = queryExecute(
            "INSERT INTO automations (
                name,
                description,
                type,
                schedule,
                status,
                createdBy,
                createdDate
            ) VALUES (
                :name,
                :description,
                :type,
                :schedule,
                :status,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                name = {value=arguments.automationData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.automationData.description, cfsqltype="cf_sql_varchar"},
                type = {value=arguments.automationData.type, cfsqltype="cf_sql_varchar"},
                schedule = {value=arguments.automationData.schedule, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.automationData.status, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.automationData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, automationID: result.generatedKey};
    }
    
    public struct function getAutomationRules(required numeric automationID) {
        var result = queryExecute(
            "SELECT ar.*, u.firstName, u.lastName
            FROM automation_rules ar
            LEFT JOIN users u ON ar.createdBy = u.userID
            WHERE ar.automationID = :automationID
            ORDER BY ar.ruleOrder",
            {automationID = {value=arguments.automationID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveAutomationRule(required struct ruleData) {
        var result = queryExecute(
            "INSERT INTO automation_rules (
                automationID,
                name,
                description,
                condition,
                action,
                ruleOrder,
                createdBy,
                createdDate
            ) VALUES (
                :automationID,
                :name,
                :description,
                :condition,
                :action,
                :ruleOrder,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                automationID = {value=arguments.ruleData.automationID, cfsqltype="cf_sql_integer"},
                name = {value=arguments.ruleData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.ruleData.description, cfsqltype="cf_sql_varchar"},
                condition = {value=arguments.ruleData.condition, cfsqltype="cf_sql_varchar"},
                action = {value=arguments.ruleData.action, cfsqltype="cf_sql_varchar"},
                ruleOrder = {value=arguments.ruleData.ruleOrder, cfsqltype="cf_sql_integer"},
                createdBy = {value=arguments.ruleData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, ruleID: result.generatedKey};
    }
    
    public struct function updateAutomationStatus(required struct statusData) {
        queryExecute(
            "UPDATE automations
            SET 
                status = :status,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE automationID = :automationID",
            {
                automationID = {value=arguments.statusData.automationID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.statusData.status, cfsqltype="cf_sql_varchar"},
                updatedBy = {value=arguments.statusData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function getAutomationLogs(required numeric automationID) {
        var result = queryExecute(
            "SELECT al.*, u.firstName, u.lastName
            FROM automation_logs al
            LEFT JOIN users u ON al.userID = u.userID
            WHERE al.automationID = :automationID
            ORDER BY al.createdDate DESC",
            {automationID = {value=arguments.automationID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function logAutomationExecution(required struct logData) {
        var result = queryExecute(
            "INSERT INTO automation_logs (
                automationID,
                status,
                message,
                userID,
                createdDate
            ) VALUES (
                :automationID,
                :status,
                :message,
                :userID,
                CURRENT_TIMESTAMP
            )",
            {
                automationID = {value=arguments.logData.automationID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.logData.status, cfsqltype="cf_sql_varchar"},
                message = {value=arguments.logData.message, cfsqltype="cf_sql_varchar"},
                userID = {value=arguments.logData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, logID: result.generatedKey};
    }
} 