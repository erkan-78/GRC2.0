component {
    
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public void function sendTemplatedEmail(required struct emailData) {
        // Get email template
        var template = getEmailTemplate(arguments.emailData.template);
        
        // Replace template variables
        var subject = replaceTemplateVariables(template.subject, arguments.emailData.data);
        var content = replaceTemplateVariables(template.content, arguments.emailData.data);
        
        // Send email
        cfmail(
            to = arguments.emailData.to,
            from = application.config.siteEmail,
            subject = subject,
            type = "html"
        ) {
            writeOutput(content);
        }
    }
    
    public void function sendVerificationEmail(required string email, required string token) {
        var emailData = {
            to = arguments.email,
            template = "verification_email",
            data = {
                verificationLink = application.config.baseURL & "/verify-email.cfm?token=" & arguments.token,
                expiryHours = 24
            }
        };
        
        sendTemplatedEmail(emailData);
    }
    
    private struct function getEmailTemplate(required string templateName) {
        var result = queryExecute(
            "SELECT subject, content FROM email_templates WHERE name = :name",
            {name = {value=arguments.templateName, cfsqltype="cf_sql_varchar"}},
            {datasource=variables.datasource}
        );
        
        if (result.recordCount) {
            return {
                subject = result.subject,
                content = result.content
            };
        }
        
        throw(type="CustomError", message="Email template '#arguments.templateName#' not found");
    }
    
    private string function replaceTemplateVariables(required string template, required struct data) {
        var result = arguments.template;
        
        for (var key in arguments.data) {
            result = replace(result, "{{" & key & "}}", arguments.data[key], "all");
        }
        
        return result;
    }
} 