<cfscript>
    // Initialize services
    securityService = new model.SecurityService();
    notificationService = new model.NotificationService();
    
    // Require authentication
    securityService.requireAuthentication();
    
    // Get the requested page
    page = url.page ?: "list";
    
    switch(page) {
        case "list":
            // Get pagination parameters
            pageSize = 20;
            currentPage = val(url.p ?: 1);
            
            // Get notifications
            getNotifications = notificationService.getNotifications(
                userID: session.userID,
                type: url.type ?: "",
                status: url.status ?: "",
                startDate: url.startDate ?: "",
                endDate: url.endDate ?: "",
                page: currentPage,
                pageSize: pageSize
            );
            
            totalRecords = notificationService.getNotificationCount(
                userID: session.userID,
                type: url.type ?: "",
                status: url.status ?: "",
                startDate: url.startDate ?: "",
                endDate: url.endDate ?: ""
            );
            
            // Get notification types for filter
            getNotificationTypes = notificationService.getNotificationTypes();
            
            include "list.cfm";
            break;
            
        case "preferences":
            // Get user notification preferences
            preferences = notificationService.getUserPreferences(session.userID);
            
            // Get available notification types
            getNotificationTypes = notificationService.getNotificationTypes();
            
            include "preferences.cfm";
            break;
    }
</cfscript> 