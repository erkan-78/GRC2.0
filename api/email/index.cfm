<cfscript>
    // Initialize services
    securityService = new model.SecurityService();
    emailService = new model.EmailService();
    userService = new model.UserService();
    templateService = new model.EmailTemplateService();
    
    // Require authentication for all API endpoints
    securityService.requireAuthentication();
    
    // Get the requested action from the URL
    action = url.action ?: "default";
    
    // Set the response type to JSON
    getPageContext().getResponse().setContentType("application/json");
    
    // Handle different actions
    switch(action) {
        case "getTemplate":
            // Require permission to view templates
            securityService.requirePermission("email.view");
            
            templateID = url.templateID ?: 0;
            result = templateService.getTemplateByID(templateID);
            break;
            
        case "saveTemplate":
            // Require permission to manage templates
            securityService.requirePermission("email.manage");
            
            templateData = {
                "templateID" = form.templateID ?: 0,
                "templateName" = form.templateName ?: "",
                "subject" = form.subject ?: "",
                "content" = form.content ?: ""
            };
            try {
                templateService.saveTemplate(templateData);
                result = {"success" = true, "message" = "Template saved successfully"};
            } catch(any e) {
                result = {"success" = false, "message" = e.message};
            }
            break;
            
        case "deleteTemplate":
            // Require permission to manage templates
            securityService.requirePermission("email.manage");
            
            templateID = form.templateID ?: 0;
            try {
                templateService.deleteTemplate(templateID);
                result = {"success" = true, "message" = "Template deleted successfully"};
            } catch(any e) {
                result = {"success" = false, "message" = e.message};
            }
            break;
            
        case "send":
            // Require permission to send emails
            securityService.requirePermission("email.send");
            
            try {
                // Get form parameters
                selectionType = form.selectionType ?: "";
                templateID = form.templateID ?: 0;
                subject = form.subject ?: "";
                content = form.emailContent ?: "";
                
                // Get template if selected
                if (templateID > 0) {
                    template = templateService.getTemplateByID(templateID);
                    subject = template.subject;
                    content = template.content;
                }
                
                // Get recipients
                recipients = [];
                if (selectionType == "users" && structKeyExists(form, "selectedUsers")) {
                    recipients = userService.getUsersByIds(form.selectedUsers);
                } else if (selectionType == "company" && structKeyExists(form, "selectedCompany")) {
                    recipients = userService.getUsersByCompanyId(form.selectedCompany);
                }
                
                // Send emails
                if (arrayLen(recipients)) {
                    emailService.sendBulkEmail(recipients, subject, content);
                    result = {"success" = true, "message" = "Emails sent successfully to " & arrayLen(recipients) & " recipients"};
                } else {
                    result = {"success" = false, "message" = "No recipients selected"};
                }
            } catch(any e) {
                result = {"success" = false, "message" = "Error sending emails: " & e.message};
            }
            break;
            
        default:
            result = {"success" = false, "message" = "Invalid action"};
    }
    
    // Output the result as JSON
    writeOutput(serializeJSON(result));
</cfscript> 