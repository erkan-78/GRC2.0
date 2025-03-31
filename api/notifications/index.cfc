component {
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public struct function get(required numeric id) {
        var result = queryExecute(
            "SELECT n.*, u.firstName, u.lastName
            FROM notifications n
            LEFT JOIN users u ON n.createdBy = u.userID
            WHERE n.notificationID = :id",
            {id = {value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result;
    }
    
    public struct function markRead(required numeric id) {
        queryExecute(
            "UPDATE notifications 
            SET readDate = CURRENT_TIMESTAMP
            WHERE notificationID = :id",
            {id = {value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public numeric function getUnreadCount(required numeric userID) {
        var result = queryExecute(
            "SELECT COUNT(*) as count
            FROM notifications
            WHERE userID = :userID
            AND readDate IS NULL",
            {userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return result.count;
    }
    
    public struct function savePreferences(required struct preferences) {
        queryExecute(
            "UPDATE notification_preferences
            SET 
                emailEnabled = :emailEnabled,
                pushEnabled = :pushEnabled,
                inAppEnabled = :inAppEnabled,
                updatedBy = :updatedBy,
                updatedDate = CURRENT_TIMESTAMP
            WHERE userID = :userID",
            {
                userID = {value=arguments.preferences.userID, cfsqltype="cf_sql_integer"},
                emailEnabled = {value=arguments.preferences.emailEnabled, cfsqltype="cf_sql_bit"},
                pushEnabled = {value=arguments.preferences.pushEnabled, cfsqltype="cf_sql_bit"},
                inAppEnabled = {value=arguments.preferences.inAppEnabled, cfsqltype="cf_sql_bit"},
                updatedBy = {value=arguments.preferences.userID, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
    
    public struct function create(required struct notificationData) {
        var result = queryExecute(
            "INSERT INTO notifications (
                userID,
                title,
                message,
                type,
                link,
                createdBy,
                createdDate
            ) VALUES (
                :userID,
                :title,
                :message,
                :type,
                :link,
                :createdBy,
                CURRENT_TIMESTAMP
            )",
            {
                userID = {value=arguments.notificationData.userID, cfsqltype="cf_sql_integer"},
                title = {value=arguments.notificationData.title, cfsqltype="cf_sql_varchar"},
                message = {value=arguments.notificationData.message, cfsqltype="cf_sql_varchar"},
                type = {value=arguments.notificationData.type, cfsqltype="cf_sql_varchar"},
                link = {value=arguments.notificationData.link, cfsqltype="cf_sql_varchar"},
                createdBy = {value=arguments.notificationData.createdBy, cfsqltype="cf_sql_integer"}
            },
            {datasource=variables.datasource}
        );
        
        return {success: true, notificationID: result.generatedKey};
    }
    
    public struct function delete(required numeric id) {
        queryExecute(
            "DELETE FROM notifications WHERE notificationID = :id",
            {id = {value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return {success: true};
    }
} 