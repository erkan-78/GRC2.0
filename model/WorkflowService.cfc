component {
    public function init() {
        return this;
    }

    public function getWorkflow(required numeric workflowID) {
        var workflow = queryExecute("
            SELECT w.*, u.firstName + ' ' + u.lastName as createdByName
            FROM workflows w
            JOIN users u ON w.createdBy = u.userID
            WHERE w.workflowID = :workflowID
        ", {workflowID = arguments.workflowID}, {returntype="array"});

        if (arrayLen(workflow)) {
            var result = workflow[1];
            result.nodes = getWorkflowNodes(arguments.workflowID);
            result.connections = getWorkflowConnections(arguments.workflowID);
            return result;
        }
        return {};
    }

    public function getWorkflowNodes(required numeric workflowID) {
        return queryExecute("
            SELECT n.*, 
                   (SELECT controlID FROM workflow_node_controls 
                    WHERE nodeID = n.nodeID FOR JSON PATH) as controls
            FROM workflow_nodes n
            WHERE n.workflowID = :workflowID
        ", {workflowID = arguments.workflowID}, {returntype="array"});
    }

    public function getWorkflowConnections(required numeric workflowID) {
        return queryExecute("
            SELECT sourceID, targetID
            FROM workflow_connections
            WHERE workflowID = :workflowID
        ", {workflowID = arguments.workflowID}, {returntype="array"});
    }

    public function getWorkflowVersions(required numeric workflowID) {
        return queryExecute("
            SELECT v.*, u.firstName + ' ' + u.lastName as createdByName,
                   a.firstName + ' ' + a.lastName as approverName
            FROM workflow_versions v
            JOIN users u ON v.createdBy = u.userID
            LEFT JOIN users a ON v.approvedBy = a.userID
            WHERE v.workflowID = :workflowID
            ORDER BY v.version DESC
        ", {workflowID = arguments.workflowID}, {returntype="array"});
    }

    public function saveWorkflow(required struct workflow) {
        var workflowID = 0;
        transaction {
            // Save workflow
            if (structKeyExists(workflow, "workflowID")) {
                queryExecute("
                    UPDATE workflows
                    SET title = :title,
                        description = :description,
                        modifiedBy = :userID,
                        modifiedDate = GETDATE()
                    WHERE workflowID = :workflowID
                ", {
                    workflowID = workflow.workflowID,
                    title = workflow.title,
                    description = workflow.description,
                    userID = session.userID
                });
                workflowID = workflow.workflowID;
            } else {
                workflowID = queryExecute("
                    INSERT INTO workflows (
                        title, description, companyID, createdBy, createdDate
                    ) VALUES (
                        :title, :description, :companyID, :userID, GETDATE()
                    )
                    SELECT SCOPE_IDENTITY() as newID
                ", {
                    title = workflow.title,
                    description = workflow.description,
                    companyID = session.companyID,
                    userID = session.userID
                }, {returntype="array"})[1].newID;
            }

            // Create new version
            var version = createWorkflowVersion(workflowID);

            // Save nodes
            queryExecute("
                DELETE FROM workflow_nodes WHERE workflowID = :workflowID
            ", {workflowID = workflowID});

            for (var node in workflow.nodes) {
                var nodeID = queryExecute("
                    INSERT INTO workflow_nodes (
                        workflowID, nodeID, type, title, positionX, positionY, version
                    ) VALUES (
                        :workflowID, :nodeID, :type, :title, :positionX, :positionY, :version
                    )
                    SELECT SCOPE_IDENTITY() as newID
                ", {
                    workflowID = workflowID,
                    nodeID = node.id,
                    type = node.type,
                    title = node.title,
                    positionX = node.position.left,
                    positionY = node.position.top,
                    version = version
                }, {returntype="array"})[1].newID;

                // Save node controls
                for (var controlID in node.controls) {
                    queryExecute("
                        INSERT INTO workflow_node_controls (
                            nodeID, controlID
                        ) VALUES (
                            :nodeID, :controlID
                        )
                    ", {
                        nodeID = nodeID,
                        controlID = controlID
                    });
                }
            }

            // Save connections
            queryExecute("
                DELETE FROM workflow_connections WHERE workflowID = :workflowID
            ", {workflowID = workflowID});

            for (var conn in workflow.connections) {
                queryExecute("
                    INSERT INTO workflow_connections (
                        workflowID, sourceID, targetID, version
                    ) VALUES (
                        :workflowID, :sourceID, :targetID, :version
                    )
                ", {
                    workflowID = workflowID,
                    sourceID = conn.sourceID,
                    targetID = conn.targetID,
                    version = version
                });
            }
        }
        return workflowID;
    }

    private function createWorkflowVersion(required numeric workflowID) {
        var currentVersion = queryExecute("
            SELECT ISNULL(MAX(version), 0) + 1 as newVersion
            FROM workflow_versions
            WHERE workflowID = :workflowID
        ", {workflowID = arguments.workflowID}, {returntype="array"})[1].newVersion;

        queryExecute("
            INSERT INTO workflow_versions (
                workflowID, version, status, createdBy, createdDate
            ) VALUES (
                :workflowID, :version, 'draft', :userID, GETDATE()
            )
        ", {
            workflowID = arguments.workflowID,
            version = currentVersion,
            userID = session.userID
        });

        return currentVersion;
    }

    public function approveWorkflow(required numeric workflowID, required numeric version, string comments = "") {
        queryExecute("
            UPDATE workflow_versions
            SET status = 'approved',
                approvedBy = :userID,
                approvalDate = GETDATE(),
                comments = :comments
            WHERE workflowID = :workflowID
            AND version = :version
        ", {
            workflowID = arguments.workflowID,
            version = arguments.version,
            userID = session.userID,
            comments = arguments.comments
        });

        // Log activity
        logActivity(arguments.workflowID, "approved", "Version " & arguments.version & " approved");
    }

    public function rejectWorkflow(required numeric workflowID, required numeric version, required string reason) {
        queryExecute("
            UPDATE workflow_versions
            SET status = 'rejected',
                approvedBy = :userID,
                approvalDate = GETDATE(),
                comments = :reason
            WHERE workflowID = :workflowID
            AND version = :version
        ", {
            workflowID = arguments.workflowID,
            version = arguments.version,
            userID = session.userID,
            reason = arguments.reason
        });

        // Log activity
        logActivity(arguments.workflowID, "rejected", "Version " & arguments.version & " rejected: " & arguments.reason);
    }

    public function getControls(required numeric companyID) {
        return queryExecute("
            SELECT controlID, title, description
            FROM controls
            WHERE companyID = :companyID
            ORDER BY title
        ", {companyID = arguments.companyID});
    }

    private function logActivity(required numeric workflowID, required string action, required string details) {
        queryExecute("
            INSERT INTO workflow_activity_log (
                workflowID, userID, action, details, activityDate, ipAddress
            ) VALUES (
                :workflowID, :userID, :action, :details, GETDATE(), :ipAddress
            )
        ", {
            workflowID = arguments.workflowID,
            userID = session.userID,
            action = arguments.action,
            details = arguments.details,
            ipAddress = cgi.remote_addr
        });
    }
} 