component {
    public function init() {
        return this;
    }

    public function getAudit(required numeric auditID) {
        var audit = queryExecute("
            SELECT a.*,
                   m.firstName + ' ' + m.lastName as managerName,
                   l.firstName + ' ' + l.lastName as teamLeadName,
                   (SELECT COUNT(*) FROM audit_controls WHERE auditID = a.auditID) as totalControls,
                   (SELECT COUNT(*) FROM audit_controls WHERE auditID = a.auditID AND status = 'approved') as reviewedControls
            FROM audits a
            JOIN users m ON a.managerID = m.userID
            JOIN users l ON a.teamLeadID = l.userID
            WHERE a.auditID = :auditID
            AND a.companyID = :companyID
        ", {
            auditID = arguments.auditID,
            companyID = session.companyID
        }, {returntype="array"});

        if (arrayLen(audit)) {
            var result = audit[1];
            result.teamMembers = getAuditTeamMembers(arguments.auditID);
            result.reportReceivers = getReportReceivers(arguments.auditID);
            result.workflows = getAuditWorkflows(arguments.auditID);
            result.progress = result.totalControls > 0 ? (result.reviewedControls / result.totalControls * 100) : 0;
            return result;
        }
        return {};
    }

    public function getAudits(required numeric companyID) {
        return queryExecute("
            SELECT a.*,
                   m.firstName + ' ' + m.lastName as managerName,
                   l.firstName + ' ' + l.lastName as teamLeadName,
                   (SELECT COUNT(*) FROM audit_controls WHERE auditID = a.auditID) as totalControls,
                   (SELECT COUNT(*) FROM audit_controls WHERE auditID = a.auditID AND status = 'approved') as reviewedControls
            FROM audits a
            JOIN users m ON a.managerID = m.userID
            JOIN users l ON a.teamLeadID = l.userID
            WHERE a.companyID = :companyID
            ORDER BY a.startDate DESC
        ", {companyID = arguments.companyID});
    }

    public function saveAudit(required struct audit) {
        // Validate unique reference within company
        if (!structKeyExists(audit, "auditID") && !isUniqueReference(audit.reference, session.companyID)) {
            return {
                success = false,
                message = "Audit reference must be unique within the company"
            };
        }

        var auditID = 0;
        transaction {
            // Save audit
            if (structKeyExists(audit, "auditID")) {
                queryExecute("
                    UPDATE audits
                    SET reference = :reference,
                        title = :title,
                        scope = :scope,
                        startDate = :startDate,
                        endDate = :endDate,
                        managerID = :managerID,
                        teamLeadID = :teamLeadID,
                        status = :status,
                        modifiedBy = :userID,
                        modifiedDate = GETDATE()
                    WHERE auditID = :auditID
                    AND companyID = :companyID
                ", {
                    auditID = audit.auditID,
                    reference = audit.reference,
                    title = audit.title,
                    scope = audit.scope,
                    startDate = audit.startDate,
                    endDate = audit.endDate,
                    managerID = audit.managerID,
                    teamLeadID = audit.teamLeadID,
                    status = audit.status,
                    userID = session.userID,
                    companyID = session.companyID
                });
                auditID = audit.auditID;
            } else {
                auditID = queryExecute("
                    INSERT INTO audits (
                        reference, title, scope, startDate, endDate,
                        managerID, teamLeadID, status,
                        companyID, createdBy, createdDate
                    ) VALUES (
                        :reference, :title, :scope, :startDate, :endDate,
                        :managerID, :teamLeadID, :status,
                        :companyID, :userID, GETDATE()
                    )
                    SELECT SCOPE_IDENTITY() as newID
                ", {
                    reference = audit.reference,
                    title = audit.title,
                    scope = audit.scope,
                    startDate = audit.startDate,
                    endDate = audit.endDate,
                    managerID = audit.managerID,
                    teamLeadID = audit.teamLeadID,
                    status = audit.status,
                    companyID = session.companyID,
                    userID = session.userID
                }, {returntype="array"})[1].newID;
            }

            // Save team members
            saveTeamMembers(auditID, audit.teamMembers);

            // Save report receivers
            saveReportReceivers(auditID, audit.reportReceivers);

            // Save workflows and controls
            saveAuditWorkflows(auditID, audit.workflows);
            saveAuditControls(auditID, audit.controls);

            // Save objectives
            saveAuditObjectives(auditID, audit.objectives);
        }

        return {
            success = true,
            auditID = auditID
        };
    }

    private function isUniqueReference(required string reference, required numeric companyID) {
        var count = queryExecute("
            SELECT COUNT(*) as cnt
            FROM audits
            WHERE reference = :reference
            AND companyID = :companyID
        ", {
            reference = arguments.reference,
            companyID = arguments.companyID
        }, {returntype="array"})[1].cnt;

        return count == 0;
    }

    private function saveTeamMembers(required numeric auditID, required array members) {
        queryExecute("
            DELETE FROM audit_team_members
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        for (var memberID in arguments.members) {
            queryExecute("
                INSERT INTO audit_team_members (auditID, userID)
                VALUES (:auditID, :userID)
            ", {
                auditID = arguments.auditID,
                userID = memberID
            });
        }
    }

    private function saveReportReceivers(required numeric auditID, required array receivers) {
        queryExecute("
            DELETE FROM audit_report_receivers
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        for (var receiverID in arguments.receivers) {
            queryExecute("
                INSERT INTO audit_report_receivers (auditID, userID)
                VALUES (:auditID, :userID)
            ", {
                auditID = arguments.auditID,
                userID = receiverID
            });
        }
    }

    private function saveAuditWorkflows(required numeric auditID, required array workflows) {
        queryExecute("
            DELETE FROM audit_workflows
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        for (var workflowID in arguments.workflows) {
            queryExecute("
                INSERT INTO audit_workflows (auditID, workflowID)
                VALUES (:auditID, :workflowID)
            ", {
                auditID = arguments.auditID,
                workflowID = workflowID
            });
        }
    }

    private function saveAuditControls(required numeric auditID, required array controls) {
        queryExecute("
            DELETE FROM audit_controls
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        for (var controlID in arguments.controls) {
            queryExecute("
                INSERT INTO audit_controls (
                    auditID, controlID, status, assignedTo
                ) VALUES (
                    :auditID, :controlID, 'not_reviewed', NULL
                )
            ", {
                auditID = arguments.auditID,
                controlID = controlID
            });
        }
    }

    private function saveAuditObjectives(required numeric auditID, required array objectives) {
        queryExecute("
            DELETE FROM audit_objectives
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        for (var objective in arguments.objectives) {
            if (len(trim(objective))) {
                queryExecute("
                    INSERT INTO audit_objectives (auditID, objective)
                    VALUES (:auditID, :objective)
                ", {
                    auditID = arguments.auditID,
                    objective = objective
                });
            }
        }
    }

    public function getAuditTeamMembers(required numeric auditID) {
        var members = queryExecute("
            SELECT userID
            FROM audit_team_members
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        return valueList(members.userID);
    }

    public function getReportReceivers(required numeric auditID) {
        var receivers = queryExecute("
            SELECT userID
            FROM audit_report_receivers
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        return valueList(receivers.userID);
    }

    public function getAuditWorkflows(required numeric auditID) {
        var workflows = queryExecute("
            SELECT workflowID
            FROM audit_workflows
            WHERE auditID = :auditID
        ", {auditID = arguments.auditID});

        return valueList(workflows.workflowID);
    }

    public function getAuditControls(required numeric auditID) {
        return queryExecute("
            SELECT c.*, ac.status, ac.assignedTo,
                   u.firstName + ' ' + u.lastName as assigneeName
            FROM audit_controls ac
            JOIN controls c ON ac.controlID = c.controlID
            LEFT JOIN users u ON ac.assignedTo = u.userID
            WHERE ac.auditID = :auditID
            ORDER BY c.title
        ", {auditID = arguments.auditID});
    }

    public function getAuditObjectives(required numeric auditID) {
        return queryExecute("
            SELECT objective
            FROM audit_objectives
            WHERE auditID = :auditID
            ORDER BY objectiveID
        ", {auditID = arguments.auditID});
    }

    public function getCompanyUsers(required numeric companyID) {
        return queryExecute("
            SELECT userID, firstName, lastName
            FROM users
            WHERE companyID = :companyID
            ORDER BY lastName, firstName
        ", {companyID = arguments.companyID});
    }

    public function getControlDetails(required numeric controlID) {
        var control = queryExecute("
            SELECT c.*, ac.status, ac.assignedTo,
                   u.firstName + ' ' + u.lastName as assigneeName,
                   w.title as workflowTitle
            FROM audit_controls ac
            JOIN controls c ON ac.controlID = c.controlID
            JOIN workflows w ON c.workflowID = w.workflowID
            LEFT JOIN users u ON ac.assignedTo = u.userID
            WHERE ac.controlID = :controlID
        ", {
            controlID = arguments.controlID
        }, {returntype="array"});

        if (arrayLen(control)) {
            return control[1];
        }
        return {};
    }

    public function assignControl(required numeric controlID, required numeric assignedTo, required numeric userID) {
        // Verify user has permission to assign
        if (!canManageControl(arguments.controlID, arguments.userID)) {
            return {
                success = false,
                message = "Insufficient permissions"
            };
        }

        transaction {
            queryExecute("
                UPDATE audit_controls
                SET assignedTo = :assignedTo,
                    modifiedBy = :userID,
                    modifiedDate = GETDATE()
                WHERE controlID = :controlID
            ", {
                controlID = arguments.controlID,
                assignedTo = arguments.assignedTo,
                userID = arguments.userID
            });

            // Log activity
            var assignee = queryExecute("
                SELECT firstName + ' ' + lastName as fullName
                FROM users
                WHERE userID = :userID
            ", {userID = arguments.assignedTo}, {returntype="array"})[1].fullName;

            logControlActivity(
                arguments.controlID,
                "control_assigned",
                "Control assigned to #assignee#",
                arguments.userID
            );
        }

        return {
            success = true
        };
    }

    public function updateControlStatus(
        required numeric controlID,
        required string action,
        required string notes,
        required numeric userID
    ) {
        // Verify user has permission
        if (!canManageControl(arguments.controlID, arguments.userID)) {
            return {
                success = false,
                message = "Insufficient permissions"
            };
        }

        var newStatus = "";
        var actionLabel = "";

        switch (arguments.action) {
            case "start_review":
                newStatus = "being_reviewed";
                actionLabel = "Review started";
                break;
            case "submit_approval":
                newStatus = "waiting_approval";
                actionLabel = "Submitted for approval";
                break;
            case "approve":
                newStatus = "approved";
                actionLabel = "Control approved";
                break;
            default:
                return {
                    success = false,
                    message = "Invalid action"
                };
        }

        transaction {
            queryExecute("
                UPDATE audit_controls
                SET status = :status,
                    modifiedBy = :userID,
                    modifiedDate = GETDATE()
                WHERE controlID = :controlID
            ", {
                controlID = arguments.controlID,
                status = newStatus,
                userID = arguments.userID
            });

            // Log activity
            logControlActivity(
                arguments.controlID,
                "status_changed",
                "#actionLabel#: #arguments.notes#",
                arguments.userID
            );

            // Send notifications
            sendStatusChangeNotification(arguments.controlID, newStatus, arguments.userID);
        }

        return {
            success = true
        };
    }

    public function getControlActivities(required numeric controlID) {
        return queryExecute("
            SELECT a.*,
                   u.firstName + ' ' + u.lastName as userFullName
            FROM audit_activity a
            JOIN users u ON a.userID = u.userID
            WHERE a.controlID = :controlID
            ORDER BY a.activityDate DESC
        ", {
            controlID = arguments.controlID
        });
    }

    private function canManageControl(required numeric controlID, required numeric userID) {
        var count = queryExecute("
            SELECT COUNT(*) as cnt
            FROM audit_controls ac
            JOIN audits a ON ac.auditID = a.auditID
            LEFT JOIN audit_team_members atm ON a.auditID = atm.auditID
            WHERE ac.controlID = :controlID
            AND (
                a.managerID = :userID
                OR a.teamLeadID = :userID
                OR atm.userID = :userID
                OR EXISTS (
                    SELECT 1
                    FROM user_roles ur
                    WHERE ur.userID = :userID
                    AND ur.roleID IN (1, 2) -- Super Admin, Auditor roles
                )
            )
        ", {
            controlID = arguments.controlID,
            userID = arguments.userID
        }, {returntype="array"})[1].cnt;

        return count > 0;
    }

    private function logControlActivity(
        required numeric controlID,
        required string action,
        required string details,
        required numeric userID
    ) {
        queryExecute("
            INSERT INTO audit_activity (
                controlID, action, details,
                userID, activityDate
            ) VALUES (
                :controlID, :action, :details,
                :userID, GETDATE()
            )
        ", {
            controlID = arguments.controlID,
            action = arguments.action,
            details = arguments.details,
            userID = arguments.userID
        });
    }

    private function sendStatusChangeNotification(
        required numeric controlID,
        required string newStatus,
        required numeric userID
    ) {
        var notificationService = new NotificationService();
        var control = getControlDetails(arguments.controlID);
        var audit = getAudit(control.auditID);
        
        var recipients = [];
        
        switch (arguments.newStatus) {
            case "being_reviewed":
                if (control.assignedTo != "") {
                    recipients.append(control.assignedTo);
                }
                break;
            case "waiting_approval":
                recipients.append(audit.managerID);
                recipients.append(audit.teamLeadID);
                break;
            case "approved":
                if (control.assignedTo != "") {
                    recipients.append(control.assignedTo);
                }
                recipients.append(audit.managerID);
                break;
        }
        
        // Remove duplicates and current user
        recipients = arrayToList(recipients);
        recipients = listDeleteAt(recipients, listFind(recipients, arguments.userID));
        recipients = listToArray(recipients);
        
        if (arrayLen(recipients)) {
            notificationService.sendControlStatusNotification(
                recipients,
                control.title,
                arguments.newStatus,
                audit.reference
            );
        }
    }
} 