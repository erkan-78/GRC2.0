component {
    
    public void function init() {
        variables.emailService = new model.EmailService();
        variables.userService = new model.UserService();
        variables.templateService = new model.EmailTemplateService();
    }

    public any function default() {
        var rc = {
            "getUsers" = variables.userService.getAllUsers(),
            "getCompanies" = variables.userService.getAllCompanies(),
            "getTemplates" = variables.templateService.getAllTemplates()
        };
        return rc;
    }

    public any function templates() {
        return {
            "getTemplates" = variables.templateService.getAllTemplates()
        };
    }

    public any function getTemplate() {
        var templateID = url.templateID ?: 0;
        var template = variables.templateService.getTemplateByID(templateID);
        return template;
    }

    public any function saveTemplate() {
        var result = {
            "success" = false,
            "message" = ""
        };

        try {
            var templateData = {
                "templateID" = form.templateID ?: 0,
                "templateName" = form.templateName ?: "",
                "subject" = form.subject ?: "",
                "content" = form.content ?: ""
            };

            variables.templateService.saveTemplate(templateData);
            result.success = true;
            result.message = "Template saved successfully.";
        } catch (any e) {
            result.message = "Error saving template: " & e.message;
        }

        return result;
    }

    public any function deleteTemplate() {
        var result = {
            "success" = false,
            "message" = ""
        };

        try {
            var templateID = url.templateID ?: 0;
            variables.templateService.deleteTemplate(templateID);
            result.success = true;
            result.message = "Template deleted successfully.";
        } catch (any e) {
            result.message = "Error deleting template: " & e.message;
        }

        return result;
    }

    public any function send() {
        var result = {
            "success" = false,
            "message" = ""
        };

        try {
            // Get form parameters
            var selectionType = form.selectionType ?: "";
            var templateID = form.templateID ?: 0;
            var subject = form.subject ?: "";
            var content = form.emailContent ?: "";
            
            // Get template if selected
            if (templateID > 0) {
                var template = variables.templateService.getTemplateByID(templateID);
                subject = template.subject;
                content = template.content;
            }
            
            // Get recipients based on selection type
            var recipients = [];
            if (selectionType == "users" && structKeyExists(form, "selectedUsers")) {
                recipients = variables.userService.getUsersByIds(form.selectedUsers);
            } else if (selectionType == "company" && structKeyExists(form, "selectedCompany")) {
                recipients = variables.userService.getUsersByCompanyId(form.selectedCompany);
            }

            // Send emails
            if (arrayLen(recipients)) {
                variables.emailService.sendBulkEmail(recipients, subject, content);
                result.success = true;
                result.message = "Emails sent successfully to " & arrayLen(recipients) & " recipients.";
            } else {
                result.message = "No recipients selected.";
            }
        } catch (any e) {
            result.message = "Error sending emails: " & e.message;
        }

        return result;
    }
} 