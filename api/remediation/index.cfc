component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function getTask(required numeric taskID) {
        var result = queryExecute(
            "SELECT t.*, u.firstName, u.lastName
            FROM remediation_tasks t
            LEFT JOIN users u ON t.assignedTo = u.userID
            WHERE t.taskID = :taskID",
            {taskID = {value=arguments.taskID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function saveTask(required struct taskData) {
        var result = queryExecute(
            "INSERT INTO remediation_tasks (
                title,
                description,
                status,
                priority,
                dueDate,
                assignedTo,
                createdBy,
                createdDate
            ) VALUES (
                :title,
                :description,
                :status,
                :priority,
                :dueDate,
                :assignedTo,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                title = {value=arguments.taskData.title, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.taskData.description, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.taskData.status, cfsqltype="cf_sql_varchar"},
                priority = {value=arguments.taskData.priority, cfsqltype="cf_sql_varchar"},
                dueDate = {value=arguments.taskData.dueDate, cfsqltype="cf_sql_timestamp"},
                assignedTo = {value=arguments.taskData.assignedTo, cfsqltype="cf_sql_integer"},
                createdBy = {value=arguments.taskData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, taskID: result.generatedKey};
    }
    
    public struct function getTaskDetails(required numeric taskID) {
        var result = queryExecute(
            "SELECT t.*, u.firstName, u.lastName, c.name as categoryName
            FROM remediation_tasks t
            LEFT JOIN users u ON t.assignedTo = u.userID
            LEFT JOIN remediation_categories c ON t.categoryID = c.categoryID
            WHERE t.taskID = :taskID",
            {taskID = {value=arguments.taskID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function addComment(required struct commentData) {
        var result = queryExecute(
            "INSERT INTO remediation_comments (
                taskID,
                comment,
                createdBy,
                createdDate
            ) VALUES (
                :taskID,
                :comment,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                taskID = {value=arguments.commentData.taskID, cfsqltype="cf_sql_integer"},
                comment = {value=arguments.commentData.comment, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.commentData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, commentID: result.generatedKey};
    }
    
    public struct function uploadEvidence(required struct evidenceData) {
        var result = queryExecute(
            "INSERT INTO remediation_evidence (
                taskID,
                fileName,
                filePath,
                fileType,
                fileSize,
                uploadedBy,
                uploadedDate
            ) VALUES (
                :taskID,
                :fileName,
                :filePath,
                :fileType,
                :fileSize,
                :uploadedBy,
                CURRENT_TIMESTAMP
            )",
            {
                taskID = {value=arguments.evidenceData.taskID, cfsqltype="cf_sql_integer"},
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
    
    public struct function downloadEvidence(required numeric evidenceID) {
        var result = queryExecute(
            "SELECT * FROM remediation_evidence WHERE evidenceID = :evidenceID",
            {evidenceID = {value=arguments.evidenceID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        if (!result.recordCount) {
            return {success: false, message: "Evidence not found"};
        }
        
        return {
            success: true,
            fileName: result.fileName,
            filePath: result.filePath
        };
    }
    
    public struct function updateTaskStatus(required struct statusData) {
        queryExecute(
            "UPDATE remediation_tasks
            SET 
                status = :status,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE taskID = :taskID",
            {
                taskID = {value=arguments.statusData.taskID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.statusData.status, cfsqltype="cf_sql_varchar"},
                updatedBy = {value=arguments.statusData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
} 