<cfscript>
    // Initialize services
    securityService = new model.SecurityService();
    emailService = new model.EmailService();
    userService = new model.UserService();
    templateService = new model.EmailTemplateService();
    
    // Require authentication for all admin pages
    securityService.requireAuthentication();
    
    // Get the requested page
    page = url.page ?: "send";
    
    // Check permissions based on the page
    switch(page) {
        case "templates":
            securityService.requirePermission("email.manage");
            getTemplates = templateService.getAllTemplates();
            include "templates.cfm";
            break;
            
        case "send":
        default:
            securityService.requirePermission("email.send");
            getUsers = userService.getAllUsers();
            getCompanies = userService.getAllCompanies();
            getTemplates = templateService.getAllTemplates();
            include "send.cfm";
            break;
    }
</cfscript> 