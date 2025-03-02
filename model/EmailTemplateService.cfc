component {
    
    public query function getAllTemplates() {
        var sql = "
            SELECT templateID, templateName, subject, content, lastModified
            FROM email_templates
            ORDER BY templateName
        ";
        return queryExecute(sql);
    }

    public struct function getTemplateByID(required numeric templateID) {
        var sql = "
            SELECT templateID, templateName, subject, content
            FROM email_templates
            WHERE templateID = :templateID
        ";
        var params = {
            templateID = { value = arguments.templateID, cfsqltype = "cf_sql_integer" }
        };
        var result = queryExecute(sql, params);
        
        if (result.recordCount) {
            return {
                templateID = result.templateID,
                templateName = result.templateName,
                subject = result.subject,
                content = result.content
            };
        }
        throw(type="CustomError", message="Template not found");
    }

    public void function saveTemplate(required struct templateData) {
        var params = {
            templateName = { value = arguments.templateData.templateName, cfsqltype = "cf_sql_varchar" },
            subject = { value = arguments.templateData.subject, cfsqltype = "cf_sql_varchar" },
            content = { value = arguments.templateData.content, cfsqltype = "cf_sql_longvarchar" },
            lastModified = { value = now(), cfsqltype = "cf_sql_timestamp" }
        };

        if (arguments.templateData.templateID > 0) {
            // Update existing template
            var sql = "
                UPDATE email_templates
                SET templateName = :templateName,
                    subject = :subject,
                    content = :content,
                    lastModified = :lastModified
                WHERE templateID = :templateID
            ";
            params.templateID = { value = arguments.templateData.templateID, cfsqltype = "cf_sql_integer" };
        } else {
            // Insert new template
            var sql = "
                INSERT INTO email_templates (templateName, subject, content, lastModified)
                VALUES (:templateName, :subject, :content, :lastModified)
            ";
        }

        queryExecute(sql, params);
    }

    public void function deleteTemplate(required numeric templateID) {
        var sql = "
            DELETE FROM email_templates
            WHERE templateID = :templateID
        ";
        var params = {
            templateID = { value = arguments.templateID, cfsqltype = "cf_sql_integer" }
        };
        queryExecute(sql, params);
    }

    public string function processTemplate(required string content, required struct variables) {
        var processedContent = arguments.content;
        
        // Replace template variables with actual values
        for (var key in arguments.variables) {
            processedContent = replace(processedContent, "{#key#}", arguments.variables[key], "all");
        }
        
        return processedContent;
    }
} 