component {
    property name="emailService" type="EmailService";
    property name="remediationService" type="RemediationService";
    
    public function init() {
        variables.emailService = new EmailService();
        variables.remediationService = new RemediationService();
        return this;
    }

    public function sendTaskAssignmentNotification(
        required numeric taskID,
        required numeric assigneeID,
        required numeric assignerID
    ) {
        var task = variables.remediationService.getTaskDetails(arguments.taskID);
        var assignee = getUserDetails(arguments.assigneeID);
        var assigner = getUserDetails(arguments.assignerID);
        
        var emailData = {
            to: assignee.email,
            subject: "New Remediation Task Assignment",
            template: "task_assignment",
            data: {
                assigneeName: assignee.firstName,
                taskDescription: task.description,
                dueDate: dateFormat(task.dueDate, "mmmm d, yyyy"),
                priority: task.priority,
                assignerName: "#assigner.firstName# #assigner.lastName#",
                planTitle: task.planTitle,
                taskURL: application.baseURL & "/admin/remediation/plan.cfm?id=" & task.planID & "&task=" & task.taskID
            }
        };
        
        return variables.emailService.sendTemplatedEmail(emailData);
    }

    public function sendTaskDueReminder(required numeric taskID) {
        var task = variables.remediationService.getTaskDetails(arguments.taskID);
        var assignee = getUserDetails(task.assignedTo);
        
        var emailData = {
            to: assignee.email,
            subject: "Remediation Task Due Soon",
            template: "task_reminder",
            data: {
                assigneeName: assignee.firstName,
                taskDescription: task.description,
                dueDate: dateFormat(task.dueDate, "mmmm d, yyyy"),
                daysLeft: dateDiff("d", now(), task.dueDate),
                priority: task.priority,
                planTitle: task.planTitle,
                taskURL: application.baseURL & "/admin/remediation/plan.cfm?id=" & task.planID & "&task=" & task.taskID
            }
        };
        
        return variables.emailService.sendTemplatedEmail(emailData);
    }

    public function sendTaskOverdueNotification(required numeric taskID) {
        var task = variables.remediationService.getTaskDetails(arguments.taskID);
        var assignee = getUserDetails(task.assignedTo);
        var manager = getPlanManager(task.planID);
        
        // Notify assignee
        var assigneeEmail = {
            to: assignee.email,
            subject: "Remediation Task Overdue",
            template: "task_overdue_assignee",
            data: {
                assigneeName: assignee.firstName,
                taskDescription: task.description,
                dueDate: dateFormat(task.dueDate, "mmmm d, yyyy"),
                daysOverdue: dateDiff("d", task.dueDate, now()),
                priority: task.priority,
                planTitle: task.planTitle,
                taskURL: application.baseURL & "/admin/remediation/plan.cfm?id=" & task.planID & "&task=" & task.taskID
            }
        };
        
        // Notify manager
        var managerEmail = {
            to: manager.email,
            subject: "Remediation Task Overdue Alert",
            template: "task_overdue_manager",
            data: {
                managerName: manager.firstName,
                assigneeName: "#assignee.firstName# #assignee.lastName#",
                taskDescription: task.description,
                dueDate: dateFormat(task.dueDate, "mmmm d, yyyy"),
                daysOverdue: dateDiff("d", task.dueDate, now()),
                priority: task.priority,
                planTitle: task.planTitle,
                taskURL: application.baseURL & "/admin/remediation/plan.cfm?id=" & task.planID & "&task=" & task.taskID
            }
        };
        
        variables.emailService.sendTemplatedEmail(assigneeEmail);
        return variables.emailService.sendTemplatedEmail(managerEmail);
    }

    public function sendTaskStatusUpdateNotification(
        required numeric taskID,
        required string oldStatus,
        required string newStatus,
        required numeric updatedByID
    ) {
        var task = variables.remediationService.getTaskDetails(arguments.taskID);
        var updatedBy = getUserDetails(arguments.updatedByID);
        var recipients = getTaskStakeholders(arguments.taskID);
        
        for (var recipient in recipients) {
            var emailData = {
                to: recipient.email,
                subject: "Remediation Task Status Update",
                template: "task_status_update",
                data: {
                    recipientName: recipient.firstName,
                    taskDescription: task.description,
                    oldStatus: arguments.oldStatus,
                    newStatus: arguments.newStatus,
                    updatedByName: "#updatedBy.firstName# #updatedBy.lastName#",
                    planTitle: task.planTitle,
                    taskURL: application.baseURL & "/admin/remediation/plan.cfm?id=" & task.planID & "&task=" & task.taskID
                }
            };
            
            variables.emailService.sendTemplatedEmail(emailData);
        }
        
        return true;
    }

    public function sendCommentNotification(
        required numeric taskID,
        required numeric commentID,
        required numeric commenterID
    ) {
        var task = variables.remediationService.getTaskDetails(arguments.taskID);
        var comment = getCommentDetails(arguments.commentID);
        var commenter = getUserDetails(arguments.commenterID);
        var recipients = getTaskStakeholders(arguments.taskID);
        
        // Remove commenter from recipients
        recipients = recipients.filter(function(item) {
            return item.userID != arguments.commenterID;
        });
        
        for (var recipient in recipients) {
            var emailData = {
                to: recipient.email,
                subject: "New Comment on Remediation Task",
                template: "task_comment",
                data: {
                    recipientName: recipient.firstName,
                    taskDescription: task.description,
                    commenterName: "#commenter.firstName# #commenter.lastName#",
                    commentText: comment.commentText,
                    planTitle: task.planTitle,
                    taskURL: application.baseURL & "/admin/remediation/plan.cfm?id=" & task.planID & "&task=" & task.taskID
                }
            };
            
            variables.emailService.sendTemplatedEmail(emailData);
        }
        
        return true;
    }

    private function getUserDetails(required numeric userID) {
        return queryExecute("
            SELECT userID, firstName, lastName, email
            FROM users
            WHERE userID = :userID
        ", {
            userID = arguments.userID
        }, {returntype="array"})[1];
    }

    private function getPlanManager(required numeric planID) {
        return queryExecute("
            SELECT u.userID, u.firstName, u.lastName, u.email
            FROM remediation_plans p
            JOIN audits a ON p.auditID = a.auditID
            JOIN users u ON a.managerID = u.userID
            WHERE p.planID = :planID
        ", {
            planID = arguments.planID
        }, {returntype="array"})[1];
    }

    private function getTaskStakeholders(required numeric taskID) {
        return queryExecute("
            SELECT DISTINCT u.userID, u.firstName, u.lastName, u.email
            FROM remediation_tasks t
            JOIN remediation_plans p ON t.planID = p.planID
            JOIN audits a ON p.auditID = a.auditID
            JOIN users u ON u.userID IN (
                t.assignedTo,
                a.managerID,
                a.teamLeadID
            )
            WHERE t.taskID = :taskID
        ", {
            taskID = arguments.taskID
        });
    }

    private function getCommentDetails(required numeric commentID) {
        return queryExecute("
            SELECT *
            FROM task_comments
            WHERE commentID = :commentID
        ", {
            commentID = arguments.commentID
        }, {returntype="array"})[1];
    }
} 