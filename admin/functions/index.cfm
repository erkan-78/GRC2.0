<cfscript>
    securityService = new model.SecurityService();
    functionService = new model.BusinessFunctionService();
    notificationService = new model.NotificationService();
    
    // Require authentication
    securityService.requireAuthentication();
    
    // Get the requested page
    page = url.page ?: "list";
    
    // Check if user is company admin
    isCompanyAdmin = securityService.hasPermission("company.admin");
    
    // Get user's company ID (for company admins)
    if (isCompanyAdmin) {
        companyID = session.companyID;
    }
    
    // Include the appropriate page
    switch(page) {
        case "dashboard":
            // Require approval permission
            securityService.requirePermission("functions.approve");
            
            // Get dashboard statistics
            stats = functionService.getDashboardStats(
                companyID: isCompanyAdmin ? companyID : 0
            );
            
            // Get pending functions
            getPendingFunctions = functionService.getPendingFunctions(
                companyID: isCompanyAdmin ? companyID : 0
            );
            
            // Get recent activity
            getRecentActivity = functionService.getRecentActivity(
                companyID: isCompanyAdmin ? companyID : 0,
                limit: 20
            );
            
            include "dashboard.cfm";
            break;
            
        case "list":
            // Get pagination parameters
            pageSize = 20;
            currentPage = val(url.p ?: 1);
            
            // Get functions
            if (isCompanyAdmin) {
                // Company admin sees only their company's functions
                getFunctions = functionService.getFunctions(
                    page: currentPage,
                    pageSize: pageSize,
                    companyID: companyID,
                    status: url.status ?: "",
                    approvalStatus: url.approvalStatus ?: ""
                );
                totalRecords = functionService.getFunctionCount(
                    companyID: companyID,
                    status: url.status ?: "",
                    approvalStatus: url.approvalStatus ?: ""
                );
            } else {
                // Super admin sees all functions
                securityService.requirePermission("functions.manage");
                getFunctions = functionService.getFunctions(
                    page: currentPage,
                    pageSize: pageSize,
                    status: url.status ?: "",
                    approvalStatus: url.approvalStatus ?: ""
                );
                totalRecords = functionService.getFunctionCount(
                    status: url.status ?: "",
                    approvalStatus: url.approvalStatus ?: ""
                );
            }
            
            include "list.cfm";
            break;
            
        case "edit":
            functionID = val(url.id ?: 0);
            if (functionID > 0) {
                // Check permission for existing function
                function = functionService.getFunction(functionID);
                if (isCompanyAdmin && function.companyID != companyID) {
                    location(url="/error.cfm?type=permission", addToken=false);
                }
                
                // Get approval history
                getApprovalHistory = functionService.getFunctionApprovals(functionID);
            }
            include "edit.cfm";
            break;
            
        case "activity":
            functionID = val(url.id ?: 0);
            if (functionID > 0) {
                // Check permission for viewing activity
                function = functionService.getFunction(functionID);
                if (isCompanyAdmin && function.companyID != companyID) {
                    location(url="/error.cfm?type=permission", addToken=false);
                }
                
                // Get activity log
                getActivityLog = functionService.getFunctionActivity(
                    functionID: functionID,
                    page: val(url.p ?: 1),
                    pageSize: 50
                );
            }
            include "activity.cfm";
            break;
    }
</cfscript> 