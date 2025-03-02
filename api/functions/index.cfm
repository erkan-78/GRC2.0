<cfscript>
    // Initialize services
    securityService = new model.SecurityService();
    functionService = new model.BusinessFunctionService();
    notificationService = new model.NotificationService();
    
    // Require authentication
    securityService.requireAuthentication();
    
    // Get the requested action
    action = url.action ?: "default";
    
    // Set response type to JSON
    getPageContext().getResponse().setContentType("application/json");
    
    try {
        // Check if user is company admin
        isCompanyAdmin = securityService.hasPermission("company.admin");
        
        switch(action) {
            case "save":
                // Validate permissions
                if (isCompanyAdmin) {
                    if (form.companyID != session.companyID) {
                        throw(type="CustomError", message="Permission denied");
                    }
                } else {
                    securityService.requirePermission("functions.manage");
                }
                
                // Get original function data if exists
                var originalFunction = {};
                if (form.functionID > 0) {
                    originalFunction = functionService.getFunction(form.functionID);
                }
                
                // Prepare function data
                functionData = {
                    "functionID" = form.functionID ?: 0,
                    "companyID" = form.companyID ?: 0,
                    "title" = form.title ?: "",
                    "description" = form.description ?: "",
                    "status" = form.status ?: "enabled"
                };
                
                // Handle approval status if user has permission
                if (securityService.hasPermission("functions.approve")) {
                    functionData["approvalStatus"] = form.approvalStatus ?: "pending";
                    functionData["rejectionReason"] = form.rejectionReason ?: "";
                    functionData["approvedBy"] = session.userID;
                    functionData["approvedDate"] = now();
                } else {
                    // Reset to pending if non-approver makes changes
                    functionData["approvalStatus"] = "pending";
                    functionData["rejectionReason"] = "";
                    functionData["approvedBy"] = "";
                    functionData["approvedDate"] = "";
                }
                
                // Save function
                result = functionService.saveFunction(functionData);
                
                // Send notifications if approval status changed
                if (structKeyExists(originalFunction, "approvalStatus") && 
                    originalFunction.approvalStatus != functionData.approvalStatus) {
                    
                    notificationService.sendFunctionStatusNotification(
                        functionData = result,
                        action = functionData.approvalStatus,
                        comments = functionData.rejectionReason
                    );
                }
                break;
                
            case "bulkApprove":
                // Require approval permission
                securityService.requirePermission("functions.approve");
                
                // Get function IDs
                var functionIDs = listToArray(form.functionIDs ?: "");
                
                if (!arrayLen(functionIDs)) {
                    throw(type="CustomError", message="No functions selected");
                }
                
                // Process each function
                var processedCount = 0;
                for (var functionID in functionIDs) {
                    // Get function details
                    var function = functionService.getFunction(functionID);
                    
                    // Check company permission
                    if (isCompanyAdmin && function.companyID != session.companyID) {
                        continue;
                    }
                    
                    // Update function
                    var functionData = {
                        "functionID" = functionID,
                        "approvalStatus" = "approved",
                        "approvedBy" = session.userID,
                        "approvedDate" = now()
                    };
                    
                    var updatedFunction = functionService.saveFunction(functionData);
                    
                    // Send notification
                    notificationService.sendFunctionStatusNotification(
                        functionData = updatedFunction,
                        action = "approved"
                    );
                    
                    processedCount++;
                }
                
                result = {
                    "success" = true,
                    "message" = "Successfully approved #processedCount# functions"
                };
                break;
                
            case "toggleStatus":
                functionID = form.functionID ?: 0;
                newStatus = form.status ?: "";
                
                // Get function details
                function = functionService.getFunction(functionID);
                
                // Check permissions
                if (isCompanyAdmin) {
                    if (function.companyID != session.companyID) {
                        throw(type="CustomError", message="Permission denied");
                    }
                } else {
                    securityService.requirePermission("functions.manage");
                }
                
                // Only allow status changes for approved functions
                if (function.approvalStatus != "approved") {
                    throw(type="CustomError", message="Cannot change status of unapproved function");
                }
                
                // Toggle status
                functionService.updateFunctionStatus(functionID, newStatus);
                
                // Send notification
                notificationService.sendFunctionStatusNotification(
                    functionData = function,
                    action = "status_changed",
                    comments = "Status changed to: " & newStatus
                );
                
                result = {"success" = true, "message" = "Status updated successfully"};
                break;
                
            default:
                result = {"success" = false, "message" = "Invalid action"};
        }
    } catch (any e) {
        result = {
            "success" = false,
            "message" = e.message
        };
    }
    
    // Output the result as JSON
    writeOutput(serializeJSON(result));
</cfscript> 