component {
    
    public void function init() {
        variables.emailService = new EmailService();
        
        // Notification Type Constants
        variables.NOTIFICATION_TYPES = {
            // System Notifications
            "system_maintenance": {
                typeName: "System Maintenance",
                typeColor: "info",
                template: "system_maintenance"
            },
            "system_alert": {
                typeName: "System Alert",
                typeColor: "danger",
                template: "system_alert"
            },
            
            // User Account Notifications
            "account_security": {
                typeName: "Account Security",
                typeColor: "warning",
                template: "account_security"
            },
            "password_expiry": {
                typeName: "Password Expiry",
                typeColor: "warning",
                template: "password_expiry"
            },
            
            // Business Function Notifications
            "function_status": {
                typeName: "Function Status",
                typeColor: "primary",
                template: "function_status"
            },
            "function_approval": {
                typeName: "Function Approval",
                typeColor: "success",
                template: "function_approval"
            },
            "function_comment": {
                typeName: "Function Comment",
                typeColor: "info",
                template: "function_comment"
            },
            
            // Order and Payment Notifications
            "order_status": {
                typeName: "Order Status",
                typeColor: "primary",
                template: "order_status"
            },
            "payment_status": {
                typeName: "Payment Status",
                typeColor: "success",
                template: "payment_status"
            },
            "refund_status": {
                typeName: "Refund Status",
                typeColor: "warning",
                template: "refund_status"
            },
            
            // Company Notifications
            "company_update": {
                typeName: "Company Update",
                typeColor: "primary",
                template: "company_update"
            },
            "company_status": {
                typeName: "Company Status",
                typeColor: "warning",
                template: "company_status"
            },
            
            // Task Notifications
            "task_assigned": {
                typeName: "Task Assigned",
                typeColor: "info",
                template: "task_assigned"
            },
            "task_due": {
                typeName: "Task Due",
                typeColor: "warning",
                template: "task_due"
            },
            "task_completed": {
                typeName: "Task Completed",
                typeColor: "success",
                template: "task_completed"
            }
        };
    }
    
    public array function getNotifications(
        required numeric userID,
        string type = "",
        string status = "",
        string startDate = "",
        string endDate = "",
        numeric page = 1,
        numeric pageSize = 20
    ) {
        var sql = "
            SELECT n.*, nt.typeName, nt.typeColor
            FROM notifications n
            INNER JOIN notification_types nt ON n.typeID = nt.typeID
            WHERE n.userID = :userID
        ";
        
        var params = {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" }
        };
        
        if (len(arguments.type)) {
            sql &= " AND n.typeID = :typeID";
            params.typeID = { value = arguments.type, cfsqltype = "cf_sql_integer" };
        }
        
        if (len(arguments.status)) {
            sql &= " AND n.status = :status";
            params.status = { value = arguments.status, cfsqltype = "cf_sql_varchar" };
        }
        
        if (len(arguments.startDate)) {
            sql &= " AND n.created >= :startDate";
            params.startDate = { value = arguments.startDate, cfsqltype = "cf_sql_timestamp" };
        }
        
        if (len(arguments.endDate)) {
            sql &= " AND n.created <= :endDate";
            params.endDate = { value = arguments.endDate, cfsqltype = "cf_sql_timestamp" };
        }
        
        sql &= " ORDER BY n.created DESC";
        
        // Add pagination
        var offset = (arguments.page - 1) * arguments.pageSize;
        sql &= " LIMIT :limit OFFSET :offset";
        params.limit = { value = arguments.pageSize, cfsqltype = "cf_sql_integer" };
        params.offset = { value = offset, cfsqltype = "cf_sql_integer" };
        
        return queryExecute(sql, params);
    }
    
    public numeric function getNotificationCount(
        required numeric userID,
        string type = "",
        string status = "",
        string startDate = "",
        string endDate = ""
    ) {
        var sql = "
            SELECT COUNT(*) as total
            FROM notifications n
            WHERE n.userID = :userID
        ";
        
        var params = {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" }
        };
        
        if (len(arguments.type)) {
            sql &= " AND n.typeID = :typeID";
            params.typeID = { value = arguments.type, cfsqltype = "cf_sql_integer" };
        }
        
        if (len(arguments.status)) {
            sql &= " AND n.status = :status";
            params.status = { value = arguments.status, cfsqltype = "cf_sql_varchar" };
        }
        
        if (len(arguments.startDate)) {
            sql &= " AND n.created >= :startDate";
            params.startDate = { value = arguments.startDate, cfsqltype = "cf_sql_timestamp" };
        }
        
        if (len(arguments.endDate)) {
            sql &= " AND n.created <= :endDate";
            params.endDate = { value = arguments.endDate, cfsqltype = "cf_sql_timestamp" };
        }
        
        var result = queryExecute(sql, params);
        return result.total;
    }
    
    public array function getNotificationTypes() {
        return queryExecute("
            SELECT typeID, typeName, typeColor
            FROM notification_types
            ORDER BY typeName
        ");
    }
    
    public struct function getUserPreferences(required numeric userID) {
        var sql = "
            SELECT emailTypes, inAppTypes, reminderFrequency, digestTime
            FROM user_notification_preferences
            WHERE userID = :userID
        ";
        
        var result = queryExecute(sql, {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" }
        });
        
        if (result.recordCount) {
            return {
                emailTypes = result.emailTypes,
                inAppTypes = result.inAppTypes,
                reminderFrequency = result.reminderFrequency,
                digestTime = result.digestTime
            };
        }
        
        // Return defaults if no preferences found
        return {
            emailTypes = "",
            inAppTypes = "",
            reminderFrequency = "never",
            digestTime = "09:00"
        };
    }
    
    public void function saveUserPreferences(
        required numeric userID,
        required string emailTypes,
        required string inAppTypes,
        required string reminderFrequency,
        required string digestTime
    ) {
        var sql = "
            INSERT INTO user_notification_preferences (
                userID, emailTypes, inAppTypes, reminderFrequency, digestTime
            )
            VALUES (
                :userID, :emailTypes, :inAppTypes, :reminderFrequency, :digestTime
            )
            ON DUPLICATE KEY UPDATE
                emailTypes = VALUES(emailTypes),
                inAppTypes = VALUES(inAppTypes),
                reminderFrequency = VALUES(reminderFrequency),
                digestTime = VALUES(digestTime)
        ";
        
        queryExecute(sql, {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" },
            emailTypes = { value = arguments.emailTypes, cfsqltype = "cf_sql_varchar" },
            inAppTypes = { value = arguments.inAppTypes, cfsqltype = "cf_sql_varchar" },
            reminderFrequency = { value = arguments.reminderFrequency, cfsqltype = "cf_sql_varchar" },
            digestTime = { value = arguments.digestTime, cfsqltype = "cf_sql_varchar" }
        });
    }
    
    public void function markNotificationRead(required numeric notificationID) {
        queryExecute("
            UPDATE notifications
            SET status = 'read'
            WHERE notificationID = :notificationID
        ", {
            notificationID = { value = arguments.notificationID, cfsqltype = "cf_sql_integer" }
        });
    }
    
    public void function sendFunctionStatusNotification(
        required struct functionData,
        required string action,
        string comments = ""
    ) {
        // Get users to notify
        var recipients = getUsersToNotify(arguments.functionData.companyID);
        
        // Prepare email content
        var subject = "Function #uCase(action)#: #functionData.title#";
        var emailContent = "";
        
        savecontent variable="emailContent" {
            writeOutput('
                <h2>Business Function Status Update</h2>
                <p>The following business function has been #lCase(action)#:</p>
                
                <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                    <tr>
                        <th style="text-align: left; padding: 8px; background: ##f8f9fa;">Function Title:</th>
                        <td style="padding: 8px;">#functionData.title#</td>
                    </tr>
                    <tr>
                        <th style="text-align: left; padding: 8px; background: ##f8f9fa;">Company:</th>
                        <td style="padding: 8px;">#functionData.companyName#</td>
                    </tr>
                    <tr>
                        <th style="text-align: left; padding: 8px; background: ##f8f9fa;">Status:</th>
                        <td style="padding: 8px;">#functionData.status#</td>
                    </tr>
                    <tr>
                        <th style="text-align: left; padding: 8px; background: ##f8f9fa;">Approval Status:</th>
                        <td style="padding: 8px;">#functionData.approvalStatus#</td>
                    </tr>
            ');
            
            if (len(arguments.comments)) {
                writeOutput('
                    <tr>
                        <th style="text-align: left; padding: 8px; background: ##f8f9fa;">Comments:</th>
                        <td style="padding: 8px;">#arguments.comments#</td>
                    </tr>
                ');
            }
            
            writeOutput('
                </table>
                
                <p>
                    <a href="#application.config.baseURL#/admin/functions/edit.cfm?id=#functionData.functionID#" 
                       style="display: inline-block; padding: 10px 20px; background: ##007bff; color: ##fff; text-decoration: none; border-radius: 5px;">
                        View Function Details
                    </a>
                </p>
            ');
        }
        
        // Send notifications based on user preferences
        for (var recipient in recipients) {
            // Check if user wants email notifications for this type
            var preferences = getUserPreferences(recipient.userID);
            
            if (listFind(preferences.emailTypes, getNotificationTypeID("function_status"))) {
                variables.emailService.sendEmail(
                    to = recipient.email,
                    subject = subject,
                    body = emailContent,
                    type = "html"
                );
            }
            
            // Create in-app notification if enabled
            if (listFind(preferences.inAppTypes, getNotificationTypeID("function_status"))) {
                createNotification(
                    userID = recipient.userID,
                    typeID = getNotificationTypeID("function_status"),
                    subject = subject,
                    content = emailContent,
                    referenceID = functionData.functionID,
                    referenceType = "function"
                );
            }
        }
    }
    
    private array function getUsersToNotify(required numeric companyID) {
        // Get company admins and function approvers
        var sql = "
            SELECT DISTINCT u.userID, u.firstName, u.lastName, u.email
            FROM users u
            INNER JOIN user_roles ur ON u.userID = ur.userID
            INNER JOIN roles r ON ur.roleID = r.roleID
            WHERE (u.companyID = :companyID AND r.roleName = 'company.admin')
               OR r.roleName IN ('functions.approve', 'superadmin')
        ";
        
        return queryExecute(sql, {
            companyID = { value = arguments.companyID, cfsqltype = "cf_sql_integer" }
        });
    }
    
    private numeric function getNotificationTypeID(required string typeName) {
        var result = queryExecute("
            SELECT typeID
            FROM notification_types
            WHERE typeName = :typeName
        ", {
            typeName = { value = arguments.typeName, cfsqltype = "cf_sql_varchar" }
        });
        
        return result.typeID;
    }
    
    private void function createNotification(
        required numeric userID,
        required numeric typeID,
        required string subject,
        required string content,
        numeric referenceID = 0,
        string referenceType = ""
    ) {
        queryExecute("
            INSERT INTO notifications (
                userID, typeID, subject, content, 
                referenceID, referenceType, status, created
            )
            VALUES (
                :userID, :typeID, :subject, :content,
                :referenceID, :referenceType, 'unread', NOW()
            )
        ", {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" },
            typeID = { value = arguments.typeID, cfsqltype = "cf_sql_integer" },
            subject = { value = arguments.subject, cfsqltype = "cf_sql_varchar" },
            content = { value = arguments.content, cfsqltype = "cf_sql_longvarchar" },
            referenceID = { value = arguments.referenceID, cfsqltype = "cf_sql_integer" },
            referenceType = { value = arguments.referenceType, cfsqltype = "cf_sql_varchar" }
        });
    }
    
    public void function processScheduledReminders() {
        // Get users with daily reminders at current time
        var currentTime = timeFormat(now(), "HH:mm");
        var sql = "
            SELECT u.userID, u.email, unp.reminderFrequency
            FROM users u
            INNER JOIN user_notification_preferences unp ON u.userID = unp.userID
            WHERE unp.reminderFrequency != 'never'
            AND unp.digestTime = :currentTime
            AND (
                unp.reminderFrequency = 'daily'
                OR (
                    unp.reminderFrequency = 'weekly'
                    AND DAYOFWEEK(NOW()) = 2  -- Monday
                )
            )
        ";
        
        var users = queryExecute(sql, {
            currentTime = { value = currentTime, cfsqltype = "cf_sql_varchar" }
        });
        
        for (var user in users) {
            // Get pending items for user
            var pendingItems = getPendingItemsForUser(user.userID);
            
            if (arrayLen(pendingItems)) {
                // Send digest email
                sendDigestEmail(
                    userID = user.userID,
                    email = user.email,
                    items = pendingItems,
                    frequency = user.reminderFrequency
                );
            }
        }
    }
    
    private array function getPendingItemsForUser(required numeric userID) {
        // This would get all pending items across different workflows
        // Customize based on your specific needs
        return queryExecute("
            SELECT 'function' as itemType,
                   f.functionID as itemID,
                   f.title as itemTitle,
                   f.approvalStatus,
                   f.created,
                   c.companyName
            FROM business_functions f
            INNER JOIN companies c ON f.companyID = c.companyID
            WHERE f.approvalStatus = 'pending'
            AND (
                EXISTS (
                    SELECT 1 FROM user_roles ur
                    INNER JOIN roles r ON ur.roleID = r.roleID
                    WHERE ur.userID = :userID
                    AND r.roleName = 'functions.approve'
                )
                OR (
                    EXISTS (
                        SELECT 1 FROM user_roles ur
                        INNER JOIN roles r ON ur.roleID = r.roleID
                        WHERE ur.userID = :userID
                        AND r.roleName = 'company.admin'
                        AND f.companyID = (
                            SELECT companyID FROM users WHERE userID = :userID
                        )
                    )
                )
            )
        ", {
            userID = { value = arguments.userID, cfsqltype = "cf_sql_integer" }
        });
    }
    
    private void function sendDigestEmail(
        required numeric userID,
        required string email,
        required array items,
        required string frequency
    ) {
        var subject = "Your #frequency# Pending Items Digest";
        var emailContent = "";
        
        savecontent variable="emailContent" {
            writeOutput('
                <h2>Pending Items Digest</h2>
                <p>Here are your pending items that require attention:</p>
                
                <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                    <tr style="background: ##f8f9fa;">
                        <th style="text-align: left; padding: 8px;">Type</th>
                        <th style="text-align: left; padding: 8px;">Item</th>
                        <th style="text-align: left; padding: 8px;">Company</th>
                        <th style="text-align: left; padding: 8px;">Waiting Since</th>
                    </tr>
            ');
            
            for (var item in items) {
                writeOutput('
                    <tr>
                        <td style="padding: 8px;">#item.itemType#</td>
                        <td style="padding: 8px;">
                            <a href="#application.config.baseURL#/admin/#item.itemType#s/edit.cfm?id=#item.itemID#">
                                #item.itemTitle#
                            </a>
                        </td>
                        <td style="padding: 8px;">#item.companyName#</td>
                        <td style="padding: 8px;">#dateDiff("h", item.created, now())# hours</td>
                    </tr>
                ');
            }
            
            writeOutput('
                </table>
                
                <p>
                    <a href="#application.config.baseURL#/admin/dashboard" 
                       style="display: inline-block; padding: 10px 20px; background: ##007bff; color: ##fff; text-decoration: none; border-radius: 5px;">
                        View Dashboard
                    </a>
                </p>
            ');
        }
        
        variables.emailService.sendEmail(
            to = arguments.email,
            subject = subject,
            body = emailContent,
            type = "html"
        );
    }
    
    // Add new function to get notification template
    private string function getNotificationTemplate(
        required string templateName,
        required struct data
    ) {
        var template = "";
        
        switch(arguments.templateName) {
            case "system_maintenance":
                savecontent variable="template" {
                    writeOutput('
                        <h2>System Maintenance Notice</h2>
                        <div class="alert alert-info">
                            <p>#data.message#</p>
                            <hr>
                            <p><strong>Maintenance Window:</strong> #data.startTime# - #data.endTime#</p>
                            <p><strong>Impact:</strong> #data.impact#</p>
                        </div>
                    ');
                }
                break;
                
            case "account_security":
                savecontent variable="template" {
                    writeOutput('
                        <h2>Account Security Alert</h2>
                        <div class="alert alert-warning">
                            <p>#data.message#</p>
                            <hr>
                            <p><strong>Time:</strong> #dateTimeFormat(data.timestamp, "yyyy-mm-dd HH:nn:ss")#</p>
                            <p><strong>IP Address:</strong> #data.ipAddress#</p>
                            <p><strong>Location:</strong> #data.location#</p>
                        </div>
                        <p>
                            If this wasn''t you, please 
                            <a href="#application.config.baseURL#/account/security" class="btn btn-warning">
                                Review Account Security
                            </a>
                        </p>
                    ');
                }
                break;
                
            case "task_assigned":
                savecontent variable="template" {
                    writeOutput('
                        <h2>New Task Assignment</h2>
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title">#data.taskTitle#</h5>
                                <p class="card-text">#data.description#</p>
                                <ul class="list-unstyled">
                                    <li><strong>Assigned By:</strong> #data.assignedBy#</li>
                                    <li><strong>Due Date:</strong> #dateFormat(data.dueDate, "yyyy-mm-dd")#</li>
                                    <li><strong>Priority:</strong> 
                                        <span class="badge bg-#data.priority eq ''high'' ? ''danger'' : 
                                                            (data.priority eq ''medium'' ? ''warning'' : ''info'')#">
                                            #uCase(data.priority)#
                                        </span>
                                    </li>
                                </ul>
                                <a href="#application.config.baseURL#/tasks/view.cfm?id=#data.taskID#" 
                                   class="btn btn-primary">View Task</a>
                            </div>
                        </div>
                    ');
                }
                break;
                
            case "order_status":
                savecontent variable="template" {
                    writeOutput('
                        <h2>Order Status Update</h2>
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title">Order ##: #data.orderNumber#</h5>
                                <p class="card-text">
                                    Your order status has been updated to: 
                                    <span class="badge bg-#data.statusColor#">#data.status#</span>
                                </p>
                                <hr>
                                <h6>Order Details:</h6>
                                <ul class="list-unstyled">
                                    <li><strong>Date:</strong> #dateTimeFormat(data.orderDate, "yyyy-mm-dd HH:nn")#</li>
                                    <li><strong>Total:</strong> #dollarFormat(data.total)#</li>
                                    <li><strong>Items:</strong> #data.itemCount#</li>
                                </ul>
                                <a href="#application.config.baseURL#/orders/view.cfm?id=#data.orderID#" 
                                   class="btn btn-primary">View Order</a>
                            </div>
                        </div>
                    ');
                }
                break;
                
            // Add more templates as needed...
                
            default:
                savecontent variable="template" {
                    writeOutput('
                        <h2>#data.title#</h2>
                        <div class="card">
                            <div class="card-body">
                                <p class="card-text">#data.message#</p>
                            </div>
                        </div>
                    ');
                }
        }
        
        return template;
    }

    // Add new function to send system notification
    public void function sendSystemNotification(
        required string type,
        required struct data,
        string userGroup = "",
        numeric companyID = 0
    ) {
        if (!structKeyExists(variables.NOTIFICATION_TYPES, arguments.type)) {
            throw(type="CustomError", message="Invalid notification type");
        }
        
        var notificationType = variables.NOTIFICATION_TYPES[arguments.type];
        var content = getNotificationTemplate(notificationType.template, arguments.data);
        
        // Get users to notify based on group and company
        var users = getUsersByGroup(arguments.userGroup, arguments.companyID);
        
        for (var user in users) {
            var preferences = getUserPreferences(user.userID);
            var typeID = getNotificationTypeID(arguments.type);
            
            // Send email if enabled
            if (listFind(preferences.emailTypes, typeID)) {
                variables.emailService.sendEmail(
                    to = user.email,
                    subject = data.title,
                    body = content,
                    type = "html"
                );
            }
            
            // Create in-app notification if enabled
            if (listFind(preferences.inAppTypes, typeID)) {
                createNotification(
                    userID = user.userID,
                    typeID = typeID,
                    subject = data.title,
                    content = content,
                    referenceID = data.referenceID ?: 0,
                    referenceType = data.referenceType ?: ""
                );
            }
        }
    }

    // Add new function to get users by group
    private array function getUsersByGroup(string userGroup = "", numeric companyID = 0) {
        var sql = "
            SELECT DISTINCT u.userID, u.email
            FROM users u
            INNER JOIN user_roles ur ON u.userID = ur.userID
            INNER JOIN roles r ON ur.roleID = r.roleID
            WHERE 1=1
        ";
        
        var params = {};
        
        if (len(arguments.userGroup)) {
            sql &= " AND r.roleName = :roleName";
            params.roleName = { value = arguments.userGroup, cfsqltype = "cf_sql_varchar" };
        }
        
        if (arguments.companyID > 0) {
            sql &= " AND u.companyID = :companyID";
            params.companyID = { value = arguments.companyID, cfsqltype = "cf_sql_integer" };
        }
        
        return queryExecute(sql, params);
    }
} 