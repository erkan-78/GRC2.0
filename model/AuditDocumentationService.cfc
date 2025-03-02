component {
    property name="documentService" type="DocumentService";
    property name="auditService" type="AuditService";
    
    public function init() {
        variables.documentService = new DocumentService();
        variables.auditService = new AuditService();
        return this;
    }

    public function addControlDocumentation(
        required numeric controlID,
        required numeric auditID,
        required numeric userID,
        required string documentType,
        required string content,
        array attachments = []
    ) {
        // Verify user is part of audit team
        if (!isTeamMember(arguments.auditID, arguments.userID)) {
            throw(
                type="AccessDenied",
                message="User is not a member of the audit team"
            );
        }

        // Create documentation entry
        var documentationID = queryExecute("
            INSERT INTO audit_control_documentation (
                controlID,
                auditID,
                userID,
                documentType,
                content,
                createdDate,
                status
            ) VALUES (
                :controlID,
                :auditID,
                :userID,
                :documentType,
                :content,
                GETDATE(),
                'active'
            )
            SELECT SCOPE_IDENTITY() as newID
        ", {
            controlID: arguments.controlID,
            auditID: arguments.auditID,
            userID: arguments.userID,
            documentType: arguments.documentType,
            content: arguments.content
        }, {returntype="array"})[1].newID;

        // Handle attachments
        if (arrayLen(arguments.attachments)) {
            for (var attachment in arguments.attachments) {
                variables.documentService.addDocumentationAttachment(
                    documentationID,
                    attachment
                );
            }
        }

        return documentationID;
    }

    public function updateControlDocumentation(
        required numeric documentationID,
        required numeric userID,
        required struct updates
    ) {
        // Verify user is the owner or has proper permissions
        if (!canEditDocumentation(arguments.documentationID, arguments.userID)) {
            throw(
                type="AccessDenied",
                message="User does not have permission to edit this documentation"
            );
        }

        queryExecute("
            UPDATE audit_control_documentation
            SET 
                content = :content,
                modifiedBy = :userID,
                modifiedDate = GETDATE()
            WHERE documentationID = :documentationID
        ", {
            documentationID: arguments.documentationID,
            content: updates.content,
            userID: arguments.userID
        });

        // Handle attachment updates if provided
        if (structKeyExists(updates, "attachments")) {
            variables.documentService.updateDocumentationAttachments(
                arguments.documentationID,
                updates.attachments
            );
        }
    }

    public function getControlDocumentation(
        required numeric controlID,
        required numeric auditID
    ) {
        return queryExecute("
            SELECT 
                d.documentationID,
                d.documentType,
                d.content,
                d.createdDate,
                d.modifiedDate,
                u.firstName + ' ' + u.lastName as createdBy,
                d.status,
                (
                    SELECT COUNT(*)
                    FROM documentation_attachments
                    WHERE documentationID = d.documentationID
                ) as attachmentCount
            FROM audit_control_documentation d
            JOIN users u ON d.userID = u.userID
            WHERE d.controlID = :controlID
            AND d.auditID = :auditID
            ORDER BY d.createdDate DESC
        ", {
            controlID: arguments.controlID,
            auditID: arguments.auditID
        });
    }

    public function getDocumentationAttachments(required numeric documentationID) {
        return queryExecute("
            SELECT 
                attachmentID,
                fileName,
                fileSize,
                fileType,
                uploadDate,
                uploadedBy
            FROM documentation_attachments
            WHERE documentationID = :documentationID
            ORDER BY uploadDate DESC
        ", {
            documentationID: arguments.documentationID
        });
    }

    private function isTeamMember(
        required numeric auditID,
        required numeric userID
    ) {
        var teamMember = queryExecute("
            SELECT 1
            FROM audit_team_members
            WHERE auditID = :auditID
            AND userID = :userID
        ", {
            auditID: arguments.auditID,
            userID: arguments.userID
        }, {returntype="array"});

        return arrayLen(teamMember) > 0;
    }

    private function canEditDocumentation(
        required numeric documentationID,
        required numeric userID
    ) {
        var doc = queryExecute("
            SELECT 
                d.userID as ownerID,
                atm.role as teamRole
            FROM audit_control_documentation d
            JOIN audit_team_members atm ON d.auditID = atm.auditID
            WHERE d.documentationID = :documentationID
            AND atm.userID = :userID
        ", {
            documentationID: arguments.documentationID,
            userID: arguments.userID
        }, {returntype="array"});

        if (!arrayLen(doc)) {
            return false;
        }

        // Allow if user is owner or has admin/lead role
        return doc[1].ownerID == arguments.userID || 
               listFindNoCase("admin,lead", doc[1].teamRole);
    }
} 