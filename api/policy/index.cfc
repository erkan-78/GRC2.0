component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function getVersionHistory(required numeric policyID) {
        var result = queryExecute(
            "SELECT v.*, u.firstName, u.lastName
            FROM policy_versions v
            LEFT JOIN users u ON v.createdBy = u.userID
            WHERE v.policyID = :policyID
            ORDER BY v.version DESC",
            {policyID = {value=arguments.policyID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function getPolicies(required struct filters) {
        var sql = "SELECT p.*, c.name as companyName, u.firstName, u.lastName
                  FROM policies p
                  LEFT JOIN companies c ON p.companyID = c.companyID
                  LEFT JOIN users u ON p.createdBy = u.userID
                  WHERE 1=1";
        
        var params = {};
        
        if (structKeyExists(arguments.filters, "status")) {
            sql &= " AND p.status = :status";
            params.status = {value=arguments.filters.status, cfsqltype="cf_sql_varchar"};
        }
        
        if (structKeyExists(arguments.filters, "companyID")) {
            sql &= " AND p.companyID = :companyID";
            params.companyID = {value=arguments.filters.companyID, cfsqltype="cf_sql_integer"};
        }
        
        sql &= " ORDER BY p.createdDate DESC";
        
        var result = queryExecute(sql, params, {datasource=variables.datasource});
        
        return result;
    }
    
    public struct function submitReview(required numeric policyID, required numeric userID, required string comments) {
        queryExecute(
            "INSERT INTO policy_reviews (
                policyID,
                userID,
                comments,
                createdDate
            ) VALUES (
                :policyID,
                :userID,
                :comments,
                CURRENT_TIMESTAMP
            )",
            {
                policyID = {value=arguments.policyID, cfsqltype="cf_sql_integer"},
                userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                comments = {value=arguments.comments, cfsqltype="cf_sql_varchar"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function save(required struct policyData) {
        var result = queryExecute(
            "INSERT INTO policies (
                companyID,
                title,
                description,
                content,
                status,
                createdBy,
                createdDate
            ) VALUES (
                :companyID,
                :title,
                :description,
                :content,
                :status,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                companyID = {value=arguments.policyData.companyID, cfsqltype="cf_sql_integer"},
                title = {value=arguments.policyData.title, cfsqltype="cf_sql_varchar"},
                description = {value=arguments.policyData.description, cfsqltype="cf_sql_varchar"},
                content = {value=arguments.policyData.content, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.policyData.status, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.policyData.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, policyID: result.generatedKey};
    }
    
    public struct function deleteAttachment(required numeric fileID) {
        queryExecute(
            "DELETE FROM policy_attachments WHERE fileID = :fileID",
            {fileID = {value=arguments.fileID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function download(required numeric id, required string format) {
        var policy = queryExecute(
            "SELECT * FROM policies WHERE policyID = :id",
            {id = {value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        if (!policy.recordCount) {
            return {success: false, message: "Policy not found"};
        }
        
        // Generate file based on format
        var fileName = "policy_#policy.policyID#.#arguments.format#";
        var filePath = expandPath("./downloads/#fileName#");
        
        // Implementation for file generation would go here
        // This is just a placeholder
        
        return {
            success: true,
            fileName: fileName,
            filePath: filePath
        };
    }
    
    public struct function downloadAttachment(required numeric fileID) {
        var attachment = queryExecute(
            "SELECT * FROM policy_attachments WHERE fileID = :fileID",
            {fileID = {value=arguments.fileID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        if (!attachment.recordCount) {
            return {success: false, message: "Attachment not found"};
        }
        
        return {
            success: true,
            fileName: attachment.fileName,
            filePath: attachment.filePath
        };
    }
} 