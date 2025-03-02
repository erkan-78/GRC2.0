component {
    property name="documentService" type="DocumentService";
    property name="versionService" type="VersionService";
    property name="approvalService" type="ApprovalService";
    
    public function init() {
        variables.documentService = new DocumentService();
        variables.versionService = new VersionService();
        variables.approvalService = new ApprovalService();
        return this;
    }

    public function createRegulation(
        required string title,
        required string description,
        required numeric createdBy,
        string documentPath = "",
        array subitems = []
    ) {
        var regulationID = queryExecute("
            INSERT INTO regulations (
                title,
                description,
                status,
                createdBy,
                createdDate,
                version
            ) VALUES (
                :title,
                :description,
                'draft',
                :createdBy,
                GETDATE(),
                1.0
            )
            SELECT SCOPE_IDENTITY() as newID
        ", {
            title: arguments.title,
            description: arguments.description,
            createdBy: arguments.createdBy
        }, {returntype="array"})[1].newID;

        // Handle document upload if provided
        if (len(arguments.documentPath)) {
            variables.documentService.uploadRegulationDocument(
                regulationID,
                arguments.documentPath
            );
        }

        // Create subitems if provided
        if (arrayLen(arguments.subitems)) {
            createSubitems(regulationID, arguments.subitems);
        }

        return regulationID;
    }

    public function createSubitems(
        required numeric regulationID,
        required array subitems,
        numeric parentID = 0,
        numeric level = 1
    ) {
        for (var item in arguments.subitems) {
            var subitemID = queryExecute("
                INSERT INTO regulation_subitems (
                    regulationID,
                    parentID,
                    title,
                    description,
                    level,
                    orderIndex
                ) VALUES (
                    :regulationID,
                    :parentID,
                    :title,
                    :description,
                    :level,
                    :orderIndex
                )
                SELECT SCOPE_IDENTITY() as newID
            ", {
                regulationID: arguments.regulationID,
                parentID: arguments.parentID,
                title: item.title,
                description: item.description,
                level: arguments.level,
                orderIndex: item.orderIndex ?: 0
            }, {returntype="array"})[1].newID;

            // Recursively create child items if they exist and level is less than 3
            if (structKeyExists(item, "children") && arrayLen(item.children) && arguments.level < 3) {
                createSubitems(
                    arguments.regulationID,
                    item.children,
                    subitemID,
                    arguments.level + 1
                );
            }
        }
    }

    public function updateRegulation(
        required numeric regulationID,
        required struct updates,
        required numeric updatedBy
    ) {
        // Create new version
        var currentVersion = getRegulationVersion(arguments.regulationID);
        var newVersion = currentVersion + 0.1;

        // Update regulation
        queryExecute("
            UPDATE regulations
            SET 
                title = :title,
                description = :description,
                modifiedBy = :updatedBy,
                modifiedDate = GETDATE(),
                version = :newVersion,
                status = 'draft'
            WHERE regulationID = :regulationID
        ", {
            regulationID: arguments.regulationID,
            title: updates.title,
            description: updates.description,
            updatedBy: arguments.updatedBy,
            newVersion: newVersion
        });

        // Create version history
        variables.versionService.createRegulationVersion(
            arguments.regulationID,
            newVersion,
            arguments.updatedBy
        );

        return newVersion;
    }

    public function linkRegulations(
        required numeric sourceSubitemID,
        required numeric targetSubitemID,
        required string linkType
    ) {
        queryExecute("
            INSERT INTO regulation_links (
                sourceSubitemID,
                targetSubitemID,
                linkType,
                createdDate
            ) VALUES (
                :sourceSubitemID,
                :targetSubitemID,
                :linkType,
                GETDATE()
            )
        ", {
            sourceSubitemID: arguments.sourceSubitemID,
            targetSubitemID: arguments.targetSubitemID,
            linkType: arguments.linkType
        });
    }

    public function submitForApproval(
        required numeric regulationID,
        required numeric submittedBy
    ) {
        // Create approval workflow
        var workflowID = variables.approvalService.createApprovalWorkflow(
            "regulation",
            arguments.regulationID,
            arguments.submittedBy
        );

        // Update regulation status
        queryExecute("
            UPDATE regulations
            SET 
                status = 'pending_approval',
                approvalWorkflowID = :workflowID
            WHERE regulationID = :regulationID
        ", {
            regulationID: arguments.regulationID,
            workflowID: workflowID
        });

        return workflowID;
    }

    public function getRegulationVersion(required numeric regulationID) {
        return queryExecute("
            SELECT version
            FROM regulations
            WHERE regulationID = :regulationID
        ", {
            regulationID: arguments.regulationID
        }, {returntype="array"})[1].version;
    }

    public function getRegulationHierarchy(required numeric regulationID) {
        return queryExecute("
            WITH RecursiveCTE AS (
                SELECT 
                    subitemID,
                    regulationID,
                    parentID,
                    title,
                    description,
                    level,
                    orderIndex,
                    CAST(title AS VARCHAR(1000)) as path
                FROM regulation_subitems
                WHERE regulationID = :regulationID AND parentID = 0

                UNION ALL

                SELECT 
                    s.subitemID,
                    s.regulationID,
                    s.parentID,
                    s.title,
                    s.description,
                    s.level,
                    s.orderIndex,
                    CAST(r.path + ' > ' + s.title AS VARCHAR(1000))
                FROM regulation_subitems s
                INNER JOIN RecursiveCTE r ON s.parentID = r.subitemID
            )
            SELECT *
            FROM RecursiveCTE
            ORDER BY path
        ", {
            regulationID: arguments.regulationID
        });
    }

    public function linkControlToRegulation(
        required numeric controlID,
        required numeric subitemID
    ) {
        queryExecute("
            INSERT INTO control_regulation_links (
                controlID,
                subitemID,
                createdDate
            ) VALUES (
                :controlID,
                :subitemID,
                GETDATE()
            )
        ", {
            controlID: arguments.controlID,
            subitemID: arguments.subitemID
        });
    }

    public function getLinkedControls(required numeric subitemID) {
        return queryExecute("
            SELECT 
                c.controlID,
                c.title as controlTitle,
                c.description as controlDescription,
                crl.createdDate as linkDate
            FROM controls c
            JOIN control_regulation_links crl ON c.controlID = crl.controlID
            WHERE crl.subitemID = :subitemID
            ORDER BY c.title
        ", {
            subitemID: arguments.subitemID
        });
    }

    public function getLinkedPolicies(required numeric subitemID) {
        return queryExecute("
            SELECT 
                p.policyID,
                p.title as policyTitle,
                p.version as policyVersion,
                prl.createdDate as linkDate
            FROM policies p
            JOIN policy_regulation_links prl ON p.policyID = prl.policyID
            WHERE prl.subitemID = :subitemID
            ORDER BY p.title
        ", {
            subitemID: arguments.subitemID
        });
    }
} 