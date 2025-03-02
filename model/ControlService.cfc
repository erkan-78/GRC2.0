component {
    public function init() {
        return this;
    }

    public function getControl(required numeric controlID) {
        var control = queryExecute("
            SELECT c.*, u.firstName + ' ' + u.lastName as ownerName
            FROM controls c
            JOIN users u ON c.ownerID = u.userID
            WHERE c.controlID = :controlID
            AND c.companyID = :companyID
        ", {
            controlID = arguments.controlID,
            companyID = session.companyID
        }, {returntype="array"});

        if (arrayLen(control)) {
            var result = control[1];
            result.versions = getControlVersions(arguments.controlID);
            return result;
        }
        return {};
    }

    public function getControlVersions(required numeric controlID) {
        return queryExecute("
            SELECT v.*, u.firstName + ' ' + u.lastName as modifiedByName
            FROM control_versions v
            JOIN users u ON v.modifiedBy = u.userID
            WHERE v.controlID = :controlID
            ORDER BY v.version DESC
        ", {controlID = arguments.controlID});
    }

    public function getControls(required numeric companyID) {
        return queryExecute("
            SELECT c.*, u.firstName + ' ' + u.lastName as ownerName,
                   cv.version as currentVersion, cv.status
            FROM controls c
            JOIN users u ON c.ownerID = u.userID
            LEFT JOIN control_versions cv ON c.controlID = cv.controlID
            WHERE c.companyID = :companyID
            AND cv.version = (
                SELECT MAX(version)
                FROM control_versions
                WHERE controlID = c.controlID
            )
            ORDER BY c.title
        ", {companyID = arguments.companyID});
    }

    public function saveControl(required struct control) {
        var controlID = 0;
        transaction {
            // Save control
            if (structKeyExists(control, "controlID")) {
                queryExecute("
                    UPDATE controls
                    SET title = :title,
                        description = :description,
                        type = :type,
                        frequency = :frequency,
                        ownerID = :ownerID,
                        testProcedures = :testProcedures,
                        evidenceRequirements = :evidenceRequirements,
                        modifiedBy = :userID,
                        modifiedDate = GETDATE()
                    WHERE controlID = :controlID
                    AND companyID = :companyID
                ", {
                    controlID = control.controlID,
                    title = control.title,
                    description = control.description,
                    type = control.type,
                    frequency = control.frequency,
                    ownerID = control.ownerID,
                    testProcedures = control.testProcedures,
                    evidenceRequirements = control.evidenceRequirements,
                    userID = session.userID,
                    companyID = session.companyID
                });
                controlID = control.controlID;
            } else {
                controlID = queryExecute("
                    INSERT INTO controls (
                        title, description, type, frequency, ownerID,
                        testProcedures, evidenceRequirements,
                        companyID, createdBy, createdDate
                    ) VALUES (
                        :title, :description, :type, :frequency, :ownerID,
                        :testProcedures, :evidenceRequirements,
                        :companyID, :userID, GETDATE()
                    )
                    SELECT SCOPE_IDENTITY() as newID
                ", {
                    title = control.title,
                    description = control.description,
                    type = control.type,
                    frequency = control.frequency,
                    ownerID = control.ownerID,
                    testProcedures = control.testProcedures,
                    evidenceRequirements = control.evidenceRequirements,
                    companyID = session.companyID,
                    userID = session.userID
                }, {returntype="array"})[1].newID;
            }

            // Create new version
            var version = createControlVersion(controlID, control.action);
        }
        return controlID;
    }

    private function createControlVersion(required numeric controlID, required string action) {
        var currentVersion = queryExecute("
            SELECT ISNULL(MAX(version), 0) + 1 as newVersion
            FROM control_versions
            WHERE controlID = :controlID
        ", {controlID = arguments.controlID}, {returntype="array"})[1].newVersion;

        queryExecute("
            INSERT INTO control_versions (
                controlID, version, status, modifiedBy, modifiedDate
            ) VALUES (
                :controlID, :version, :status, :userID, GETDATE()
            )
        ", {
            controlID = arguments.controlID,
            version = currentVersion,
            status = arguments.action eq 'submit' ? 'pending' : 'draft',
            userID = session.userID
        });

        return currentVersion;
    }

    public function approveControl(required numeric controlID, required numeric version, string comments = "") {
        queryExecute("
            UPDATE control_versions
            SET status = 'approved',
                approvedBy = :userID,
                approvalDate = GETDATE(),
                comments = :comments
            WHERE controlID = :controlID
            AND version = :version
        ", {
            controlID = arguments.controlID,
            version = arguments.version,
            userID = session.userID,
            comments = arguments.comments
        });

        // Log activity
        logActivity(arguments.controlID, "approved", "Version " & arguments.version & " approved");
    }

    public function rejectControl(required numeric controlID, required numeric version, required string reason) {
        queryExecute("
            UPDATE control_versions
            SET status = 'rejected',
                approvedBy = :userID,
                approvalDate = GETDATE(),
                comments = :reason
            WHERE controlID = :controlID
            AND version = :version
        ", {
            controlID = arguments.controlID,
            version = arguments.version,
            userID = session.userID,
            reason = arguments.reason
        });

        // Log activity
        logActivity(arguments.controlID, "rejected", "Version " & arguments.version & " rejected: " & arguments.reason);
    }

    public function getLinkedWorkflows(required numeric controlID) {
        return queryExecute("
            SELECT DISTINCT w.*
            FROM workflows w
            JOIN workflow_nodes n ON w.workflowID = n.workflowID
            JOIN workflow_node_controls nc ON n.nodeID = nc.nodeID
            WHERE nc.controlID = :controlID
            AND w.companyID = :companyID
        ", {
            controlID = arguments.controlID,
            companyID = session.companyID
        });
    }

    public function getCompanyUsers(required numeric companyID) {
        return queryExecute("
            SELECT userID, firstName, lastName
            FROM users
            WHERE companyID = :companyID
            ORDER BY lastName, firstName
        ", {companyID = arguments.companyID});
    }

    private function logActivity(required numeric controlID, required string action, required string details) {
        queryExecute("
            INSERT INTO control_activity_log (
                controlID, userID, action, details, activityDate, ipAddress
            ) VALUES (
                :controlID, :userID, :action, :details, GETDATE(), :ipAddress
            )
        ", {
            controlID = arguments.controlID,
            userID = session.userID,
            action = arguments.action,
            details = arguments.details,
            ipAddress = cgi.remote_addr
        });
    }
} 