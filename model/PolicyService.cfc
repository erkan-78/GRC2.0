component {
    
    public void function init() {
        variables.securityService = new SecurityService();
        variables.notificationService = new NotificationService();
        variables.fileService = new FileService();
        variables.encryptionService = new EncryptionService();
    }
    
    // Policy Management
    public array function getPolicies(
        required numeric companyID,
        string status = "",
        string type = "",
        numeric categoryID = 0
    ) {
        var sql = "
            SELECT p.*,
                   pc.name as categoryName,
                   u.firstName & ' ' & u.lastName as ownerName,
                   COUNT(DISTINCT pr.requirementID) as requirementCount,
                   COUNT(DISTINCT pa.attachmentID) as attachmentCount,
                   (SELECT MAX(version) FROM policy_versions WHERE policyID = p.policyID) as currentVersion
            FROM policies p
            INNER JOIN policy_categories pc ON p.categoryID = pc.categoryID
            INNER JOIN users u ON p.ownerID = u.userID
            LEFT JOIN policy_requirements pr ON p.policyID = pr.policyID
            LEFT JOIN policy_attachments pa ON p.policyID = pa.policyID
            WHERE p.companyID = :companyID
        ";
        
        var params = {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        };
        
        if (len(arguments.status)) {
            sql &= " AND p.status = :status";
            params.status = { value: arguments.status, cfsqltype: "cf_sql_varchar" };
        }
        
        if (len(arguments.type)) {
            sql &= " AND p.type = :type";
            params.type = { value: arguments.type, cfsqltype: "cf_sql_varchar" };
        }
        
        if (arguments.categoryID > 0) {
            sql &= " AND p.categoryID = :categoryID";
            params.categoryID = { value: arguments.categoryID, cfsqltype: "cf_sql_integer" };
        }
        
        sql &= " GROUP BY p.policyID ORDER BY p.title";
        
        return queryExecute(sql, params);
    }
    
    public struct function getPolicy(required numeric policyID, numeric version = 0) {
        var sql = "
            SELECT p.*, pv.*,
                   pc.name as categoryName,
                   u.firstName & ' ' & u.lastName as ownerName,
                   a.firstName & ' ' & a.lastName as approverName
            FROM policies p
            INNER JOIN policy_versions pv ON p.policyID = pv.policyID
            INNER JOIN policy_categories pc ON p.categoryID = pc.categoryID
            INNER JOIN users u ON p.ownerID = u.userID
            LEFT JOIN users a ON pv.approvedBy = a.userID
            WHERE p.policyID = :policyID
            AND (:version = 0 OR pv.version = :version)
            ORDER BY pv.version DESC
            LIMIT 1
        ";
        
        var policy = queryExecute(sql, {
            policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" },
            version = { value: arguments.version, cfsqltype: "cf_sql_integer" }
        });
        
        if (policy.recordCount) {
            // Get requirements
            var requirements = getRequirements(arguments.policyID);
            
            // Get attachments
            var attachments = getAttachments(arguments.policyID);
            
            // Get review history
            var reviews = getReviewHistory(arguments.policyID);
            
            return {
                policyID: policy.policyID,
                title: policy.title,
                description: policy.description,
                type: policy.type,
                status: policy.status,
                categoryID: policy.categoryID,
                categoryName: policy.categoryName,
                ownerID: policy.ownerID,
                ownerName: policy.ownerName,
                version: policy.version,
                content: policy.content,
                approvedBy: policy.approvedBy,
                approverName: policy.approverName,
                approvalDate: policy.approvalDate,
                reviewFrequency: policy.reviewFrequency,
                nextReviewDate: policy.nextReviewDate,
                requirements: requirements,
                attachments: attachments,
                reviews: reviews
            };
        }
        
        return {};
    }
    
    public numeric function savePolicy(required struct policy) {
        transaction {
            try {
                if (policy.policyID > 0) {
                    // Update existing policy
                    queryExecute("
                        UPDATE policies
                        SET title = :title,
                            description = :description,
                            type = :type,
                            categoryID = :categoryID,
                            ownerID = :ownerID,
                            reviewFrequency = :reviewFrequency,
                            modified = NOW()
                        WHERE policyID = :policyID
                        AND companyID = :companyID
                    ", {
                        policyID = { value: policy.policyID, cfsqltype: "cf_sql_integer" },
                        companyID = { value: policy.companyID, cfsqltype: "cf_sql_integer" },
                        title = { value: policy.title, cfsqltype: "cf_sql_varchar" },
                        description = { value: policy.description, cfsqltype: "cf_sql_varchar" },
                        type = { value: policy.type, cfsqltype: "cf_sql_varchar" },
                        categoryID = { value: policy.categoryID, cfsqltype: "cf_sql_integer" },
                        ownerID = { value: policy.ownerID, cfsqltype: "cf_sql_integer" },
                        reviewFrequency = { value: policy.reviewFrequency, cfsqltype: "cf_sql_integer" }
                    });
                    
                    var policyID = policy.policyID;
                } else {
                    // Insert new policy
                    var result = queryExecute("
                        INSERT INTO policies (
                            companyID, title, description, type,
                            categoryID, ownerID, status, reviewFrequency,
                            created
                        ) VALUES (
                            :companyID, :title, :description, :type,
                            :categoryID, :ownerID, 'draft', :reviewFrequency,
                            NOW()
                        )
                        RETURNING policyID
                    ", {
                        companyID = { value: policy.companyID, cfsqltype: "cf_sql_integer" },
                        title = { value: policy.title, cfsqltype: "cf_sql_varchar" },
                        description = { value: policy.description, cfsqltype: "cf_sql_varchar" },
                        type = { value: policy.type, cfsqltype: "cf_sql_varchar" },
                        categoryID = { value: policy.categoryID, cfsqltype: "cf_sql_integer" },
                        ownerID = { value: policy.ownerID, cfsqltype: "cf_sql_integer" },
                        reviewFrequency = { value: policy.reviewFrequency, cfsqltype: "cf_sql_integer" }
                    });
                    
                    var policyID = result.policyID;
                }
                
                // Create new version
                var versionResult = queryExecute("
                    INSERT INTO policy_versions (
                        policyID, version, content, status,
                        created_by, created
                    ) VALUES (
                        :policyID,
                        COALESCE((SELECT MAX(version) + 1 FROM policy_versions WHERE policyID = :policyID), 1),
                        :content,
                        'draft',
                        :userID,
                        NOW()
                    )
                    RETURNING version
                ", {
                    policyID = { value: policyID, cfsqltype: "cf_sql_integer" },
                    content = { value: policy.content, cfsqltype: "cf_sql_longvarchar" },
                    userID = { value: session.userID, cfsqltype: "cf_sql_integer" }
                });
                
                // Save requirements
                if (structKeyExists(policy, "requirements")) {
                    saveRequirements(policyID, policy.requirements);
                }
                
                // Save attachments
                if (structKeyExists(policy, "attachments")) {
                    saveAttachments(policyID, policy.attachments, policy.companyID);
                }
                
                // Notify approvers
                notificationService.sendSystemNotification(
                    type: "policy_approval",
                    data: {
                        title: "New Policy Version Pending Approval",
                        message: "A new version of policy '#policy.title#' requires approval.",
                        policyID: policyID,
                        version: versionResult.version
                    },
                    userGroup: "policy.approve"
                );
                
                return policyID;
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    private void function saveRequirements(required numeric policyID, required array requirements) {
        // Delete existing requirements
        queryExecute("
            DELETE FROM policy_requirements
            WHERE policyID = :policyID
        ", {
            policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" }
        });
        
        // Add new requirements
        for (var req in arguments.requirements) {
            queryExecute("
                INSERT INTO policy_requirements (
                    policyID, requirement, type, mandatory
                ) VALUES (
                    :policyID, :requirement, :type, :mandatory
                )
            ", {
                policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" },
                requirement = { value: req.requirement, cfsqltype: "cf_sql_varchar" },
                type = { value: req.type, cfsqltype: "cf_sql_varchar" },
                mandatory = { value: req.mandatory, cfsqltype: "cf_sql_bit" }
            });
        }
    }
    
    private void function saveAttachments(
        required numeric policyID,
        required array attachments,
        required numeric companyID
    ) {
        for (var attachment in arguments.attachments) {
            // Encrypt file content
            var encryptedContent = encryptionService.encryptFile(
                fileContent: attachment.content,
                companyID: arguments.companyID
            );
            
            // Save file using FileService
            var fileResult = fileService.saveFile(
                fileName: attachment.fileName,
                fileType: attachment.fileType,
                content: encryptedContent,
                companyID: arguments.companyID
            );
            
            // Link file to policy
            queryExecute("
                INSERT INTO policy_attachments (
                    policyID, fileID, type, version,
                    uploaded_by, uploaded
                ) VALUES (
                    :policyID, :fileID, :type, :version,
                    :userID, NOW()
                )
            ", {
                policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" },
                fileID = { value: fileResult.fileID, cfsqltype: "cf_sql_integer" },
                type = { value: attachment.type, cfsqltype: "cf_sql_varchar" },
                version = { value: attachment.version, cfsqltype: "cf_sql_integer" },
                userID = { value: session.userID, cfsqltype: "cf_sql_integer" }
            });
        }
    }
    
    public void function approvePolicy(
        required numeric policyID,
        required numeric version,
        string comments = ""
    ) {
        transaction {
            try {
                // Update policy version status
                queryExecute("
                    UPDATE policy_versions
                    SET status = 'approved',
                        approvedBy = :userID,
                        approvalDate = NOW(),
                        comments = :comments
                    WHERE policyID = :policyID
                    AND version = :version
                ", {
                    policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" },
                    version = { value: arguments.version, cfsqltype: "cf_sql_integer" },
                    userID = { value: session.userID, cfsqltype: "cf_sql_integer" },
                    comments = { value: arguments.comments, cfsqltype: "cf_sql_varchar" }
                });
                
                // Update policy status
                var policy = getPolicy(arguments.policyID);
                queryExecute("
                    UPDATE policies
                    SET status = 'active',
                        nextReviewDate = DATEADD(month, reviewFrequency, NOW())
                    WHERE policyID = :policyID
                ", {
                    policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" }
                });
                
                // Notify owner
                notificationService.sendSystemNotification(
                    type: "policy_approved",
                    data: {
                        title: "Policy Approved",
                        message: "Your policy '#policy.title#' has been approved.",
                        policyID: arguments.policyID,
                        version: arguments.version,
                        comments: arguments.comments
                    },
                    userID: policy.ownerID
                );
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    public void function rejectPolicy(
        required numeric policyID,
        required numeric version,
        required string reason
    ) {
        transaction {
            try {
                // Update policy version status
                queryExecute("
                    UPDATE policy_versions
                    SET status = 'rejected',
                        approvedBy = :userID,
                        approvalDate = NOW(),
                        comments = :reason
                    WHERE policyID = :policyID
                    AND version = :version
                ", {
                    policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" },
                    version = { value: arguments.version, cfsqltype: "cf_sql_integer" },
                    userID = { value: session.userID, cfsqltype: "cf_sql_integer" },
                    reason = { value: arguments.reason, cfsqltype: "cf_sql_varchar" }
                });
                
                // Update policy status if no active version exists
                var activeVersions = queryExecute("
                    SELECT COUNT(*) as activeCount
                    FROM policy_versions
                    WHERE policyID = :policyID
                    AND status = 'approved'
                ", {
                    policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" }
                });
                
                if (activeVersions.activeCount == 0) {
                    queryExecute("
                        UPDATE policies
                        SET status = 'draft'
                        WHERE policyID = :policyID
                    ", {
                        policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" }
                    });
                }
                
                // Notify owner
                var policy = getPolicy(arguments.policyID);
                notificationService.sendSystemNotification(
                    type: "policy_rejected",
                    data: {
                        title: "Policy Rejected",
                        message: "Your policy '#policy.title#' has been rejected.",
                        policyID: arguments.policyID,
                        version: arguments.version,
                        reason: arguments.reason
                    },
                    userID: policy.ownerID
                );
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    public array function getPendingReviews(required numeric companyID) {
        return queryExecute("
            SELECT p.*, pc.name as categoryName,
                   u.firstName & ' ' & u.lastName as ownerName
            FROM policies p
            INNER JOIN policy_categories pc ON p.categoryID = pc.categoryID
            INNER JOIN users u ON p.ownerID = u.userID
            WHERE p.companyID = :companyID
            AND p.status = 'active'
            AND p.nextReviewDate <= DATEADD(month, 1, NOW())
            ORDER BY p.nextReviewDate
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public array function getReviewHistory(required numeric policyID) {
        return queryExecute("
            SELECT r.*,
                   u.firstName & ' ' & u.lastName as reviewerName
            FROM policy_reviews r
            INNER JOIN users u ON r.reviewerID = u.userID
            WHERE r.policyID = :policyID
            ORDER BY r.reviewDate DESC
        ", {
            policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public void function submitReview(
        required numeric policyID,
        required string status,
        string comments = ""
    ) {
        transaction {
            try {
                // Record review
                queryExecute("
                    INSERT INTO policy_reviews (
                        policyID, reviewerID, status,
                        comments, reviewDate
                    ) VALUES (
                        :policyID, :userID, :status,
                        :comments, NOW()
                    )
                ", {
                    policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" },
                    userID = { value: session.userID, cfsqltype: "cf_sql_integer" },
                    status = { value: arguments.status, cfsqltype: "cf_sql_varchar" },
                    comments = { value: arguments.comments, cfsqltype: "cf_sql_varchar" }
                });
                
                // Update next review date
                var policy = getPolicy(arguments.policyID);
                queryExecute("
                    UPDATE policies
                    SET nextReviewDate = DATEADD(month, reviewFrequency, NOW())
                    WHERE policyID = :policyID
                ", {
                    policyID = { value: arguments.policyID, cfsqltype: "cf_sql_integer" }
                });
                
                // If review indicates changes needed, notify owner
                if (arguments.status == 'changes_needed') {
                    notificationService.sendSystemNotification(
                        type: "policy_review_changes",
                        data: {
                            title: "Policy Review - Changes Needed",
                            message: "The review of policy '#policy.title#' indicates changes are needed.",
                            policyID: arguments.policyID,
                            comments: arguments.comments
                        },
                        userID: policy.ownerID
                    );
                }
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
} 