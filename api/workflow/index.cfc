component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function getWorkflow(required numeric workflowID) {
        var result = queryExecute(
            "SELECT w.*, u.firstName, u.lastName
            FROM workflows w
            LEFT JOIN users u ON w.createdBy = u.userID
            WHERE w.workflowID = :workflowID",
            {workflowID = {value=arguments.workflowID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveWorkflow(required struct workflowData) {
        var result = queryExecute(
            "INSERT INTO workflows (
                name,
                description,
                status,
                type,
                createdBy,
                createdDate
            ) VALUES (
                :name,
                :description,
                :status,
                :type,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                name = {value=arguments.workflowData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.workflowData.description, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.workflowData.status, cfsqltype="cf_sql_varchar"},
                type = {value=arguments.workflowData.type, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.workflowData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, workflowID: result.generatedKey};
    }
    
    public struct function getWorkflowSteps(required numeric workflowID) {
        var result = queryExecute(
            "SELECT ws.*, u.firstName, u.lastName
            FROM workflow_steps ws
            LEFT JOIN users u ON ws.assignedTo = u.userID
            WHERE ws.workflowID = :workflowID
            ORDER BY ws.stepOrder",
            {workflowID = {value=arguments.workflowID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveWorkflowStep(required struct stepData) {
        var result = queryExecute(
            "INSERT INTO workflow_steps (
                workflowID,
                name,
                description,
                assignedTo,
                stepOrder,
                createdBy,
                createdDate
            ) VALUES (
                :workflowID,
                :name,
                :description,
                :assignedTo,
                :stepOrder,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                workflowID = {value=arguments.stepData.workflowID, cfsqltype="cf_sql_integer"},
                name = {value=arguments.stepData.name, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.stepData.description, cfsqltype="cf_sql_varchar"},
                assignedTo = {value=arguments.stepData.assignedTo, cfsqltype="cf_sql_integer"},
                stepOrder = {value=arguments.stepData.stepOrder, cfsqltype="cf_sql_integer"},
                createdBy = {value=arguments.stepData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, stepID: result.generatedKey};
    }
    
    public struct function updateStepStatus(required struct statusData) {
        queryExecute(
            "UPDATE workflow_steps
            SET 
                status = :status,
                completedDate = :completedDate,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE stepID = :stepID",
            {
                stepID = {value=arguments.statusData.stepID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.statusData.status, cfsqltype="cf_sql_varchar"},
                completedDate = {value=arguments.statusData.completedDate, cfsqltype="cf_sql_timestamp"},
                updatedBy = {value=arguments.statusData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function addStepComment(required struct commentData) {
        var result = queryExecute(
            "INSERT INTO workflow_comments (
                stepID,
                comment,
                createdBy,
                createdDate
            ) VALUES (
                :stepID,
                :comment,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                stepID = {value=arguments.commentData.stepID, cfsqltype="cf_sql_integer"},
                comment = {value=arguments.commentData.comment, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.commentData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, commentID: result.generatedKey};
    }
    
    public struct function getWorkflowHistory(required numeric workflowID) {
        var result = queryExecute(
            "SELECT wh.*, u.firstName, u.lastName
            FROM workflow_history wh
            LEFT JOIN users u ON wh.userID = u.userID
            WHERE wh.workflowID = :workflowID
            ORDER BY wh.createdDate DESC",
            {workflowID = {value=arguments.workflowID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
} 