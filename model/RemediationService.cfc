component {
    property name="aiService" type="AIRiskAnalysisService";
    
    public function init() {
        variables.aiService = new AIRiskAnalysisService();
        return this;
    }

    public function generateRemediationPlan(required numeric controlID, required numeric auditID) {
        var control = getControlDetails(arguments.controlID);
        var analysis = variables.aiService.getLatestAnalysis(arguments.controlID);
        
        if (!analysis.recordCount) {
            return {
                success: false,
                message: "No analysis found for this control"
            };
        }

        // Generate detailed remediation steps using AI
        var remediationContext = {
            control: control,
            analysis: analysis,
            gaps: analysis.gaps,
            riskLevel: analysis.riskLevel,
            recommendations: analysis.recommendations
        };

        var remediationPlan = generateAIRemediationPlan(remediationContext);
        
        // Save remediation plan
        var planID = saveRemediationPlan(
            arguments.controlID,
            arguments.auditID,
            remediationPlan
        );

        return {
            success: true,
            planID: planID,
            plan: remediationPlan
        };
    }

    private function generateAIRemediationPlan(required struct context) {
        var prompt = "Based on the following control analysis, provide a detailed remediation plan:

Control: #context.control.title#
Current Risk Level: #context.riskLevel#
Identified Gaps: #context.gaps#
Current Recommendations: #context.recommendations#

Please provide a remediation plan in the following format:
1. Immediate Actions (Next 30 Days)
2. Short-term Improvements (60-90 Days)
3. Long-term Enhancements (90+ Days)
4. Resource Requirements
5. Success Metrics
6. Implementation Steps
7. Potential Challenges
8. Cost-Benefit Analysis
9. Alternative Solutions
10. Monitoring Plan";

        try {
            var httpService = new http();
            httpService.setURL("https://api.openai.com/v1/chat/completions");
            httpService.setMethod("POST");
            httpService.addParam(type="header", name="Authorization", value="Bearer " & application.getSecretKey("openai"));
            httpService.addParam(type="header", name="Content-Type", value="application/json");
            
            var requestBody = {
                "model": "gpt-4",
                "messages": [
                    {
                        "role": "system",
                        "content": "You are a remediation planning expert specializing in audit controls and risk management. Provide detailed, actionable remediation plans."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": 0.2,
                "max_tokens": 2500
            };
            
            httpService.addParam(type="body", value=serializeJSON(requestBody));
            
            var response = httpService.send().getPrefix();
            var result = deserializeJSON(response.fileContent);
            
            return parseRemediationResponse(result.choices[1].message.content);
        } catch (any e) {
            logError("Remediation plan generation failed", e);
            return {
                success: false,
                error: "Failed to generate remediation plan: " & e.message
            };
        }
    }

    private function parseRemediationResponse(required string response) {
        return {
            immediateActions: extractSection(response, "Immediate Actions"),
            shortTermImprovements: extractSection(response, "Short-term Improvements"),
            longTermEnhancements: extractSection(response, "Long-term Enhancements"),
            resourceRequirements: extractSection(response, "Resource Requirements"),
            successMetrics: extractSection(response, "Success Metrics"),
            implementationSteps: extractSection(response, "Implementation Steps"),
            potentialChallenges: extractSection(response, "Potential Challenges"),
            costBenefitAnalysis: extractSection(response, "Cost-Benefit Analysis"),
            alternativeSolutions: extractSection(response, "Alternative Solutions"),
            monitoringPlan: extractSection(response, "Monitoring Plan")
        };
    }

    private function saveRemediationPlan(
        required numeric controlID,
        required numeric auditID,
        required struct plan
    ) {
        var planID = 0;
        
        transaction {
            planID = queryExecute("
                INSERT INTO remediation_plans (
                    controlID, auditID, createdDate,
                    immediateActions, shortTermImprovements,
                    longTermEnhancements, resourceRequirements,
                    successMetrics, implementationSteps,
                    potentialChallenges, costBenefitAnalysis,
                    alternativeSolutions, monitoringPlan,
                    status
                ) VALUES (
                    :controlID, :auditID, GETDATE(),
                    :immediateActions, :shortTermImprovements,
                    :longTermEnhancements, :resourceRequirements,
                    :successMetrics, :implementationSteps,
                    :potentialChallenges, :costBenefitAnalysis,
                    :alternativeSolutions, :monitoringPlan,
                    'pending'
                )
                SELECT SCOPE_IDENTITY() as newID
            ", {
                controlID: arguments.controlID,
                auditID: arguments.auditID,
                immediateActions: plan.immediateActions,
                shortTermImprovements: plan.shortTermImprovements,
                longTermEnhancements: plan.longTermEnhancements,
                resourceRequirements: plan.resourceRequirements,
                successMetrics: plan.successMetrics,
                implementationSteps: plan.implementationSteps,
                potentialChallenges: plan.potentialChallenges,
                costBenefitAnalysis: plan.costBenefitAnalysis,
                alternativeSolutions: plan.alternativeSolutions,
                monitoringPlan: plan.monitoringPlan
            }, {returntype="array"})[1].newID;

            // Create tasks for immediate actions
            createRemediationTasks(planID, plan.immediateActions, 30);
            createRemediationTasks(planID, plan.shortTermImprovements, 90);
            createRemediationTasks(planID, plan.longTermEnhancements, 180);

            // Log activity
            logRemediationActivity(arguments.controlID, planID, "remediation_plan_created");
        }
        
        return planID;
    }

    public function getRemediationPlan(required numeric planID) {
        var plan = queryExecute("
            SELECT p.*,
                   c.title as controlTitle,
                   a.reference as auditReference,
                   (
                       SELECT COUNT(*)
                       FROM remediation_tasks
                       WHERE planID = p.planID
                       AND status = 'completed'
                   ) as completedTasks,
                   (
                       SELECT COUNT(*)
                       FROM remediation_tasks
                       WHERE planID = p.planID
                   ) as totalTasks
            FROM remediation_plans p
            JOIN audit_controls ac ON p.controlID = ac.controlID
            JOIN controls c ON ac.controlID = c.controlID
            JOIN audits a ON p.auditID = a.auditID
            WHERE p.planID = :planID
        ", {
            planID: arguments.planID
        }, {returntype="array"});

        if (arrayLen(plan)) {
            var result = plan[1];
            result.tasks = getRemediationTasks(arguments.planID);
            return result;
        }
        
        return {};
    }

    private function createRemediationTasks(
        required numeric planID,
        required string actionText,
        required numeric daysToComplete
    ) {
        // Split action text into individual tasks
        var tasks = listToArray(arguments.actionText, ".");
        var dueDate = dateAdd("d", arguments.daysToComplete, now());
        
        for (var task in tasks) {
            if (len(trim(task)) > 10) { // Minimum length to be considered a valid task
                queryExecute("
                    INSERT INTO remediation_tasks (
                        planID, taskDescription,
                        dueDate, status,
                        createdDate
                    ) VALUES (
                        :planID, :taskDescription,
                        :dueDate, 'pending',
                        GETDATE()
                    )
                ", {
                    planID: arguments.planID,
                    taskDescription: trim(task),
                    dueDate: dueDate
                });
            }
        }
    }

    public function getRemediationTasks(required numeric planID) {
        return queryExecute("
            SELECT t.*,
                   u.firstName + ' ' + u.lastName as assignedToName
            FROM remediation_tasks t
            LEFT JOIN users u ON t.assignedTo = u.userID
            WHERE t.planID = :planID
            ORDER BY t.dueDate ASC
        ", {
            planID: arguments.planID
        });
    }

    public function updateTaskStatus(
        required numeric taskID,
        required string status,
        required string notes,
        required numeric userID
    ) {
        transaction {
            queryExecute("
                UPDATE remediation_tasks
                SET status = :status,
                    completionNotes = :notes,
                    completedBy = :userID,
                    completedDate = CASE WHEN :status = 'completed' THEN GETDATE() ELSE NULL END,
                    modifiedBy = :userID,
                    modifiedDate = GETDATE()
                WHERE taskID = :taskID
            ", {
                taskID: arguments.taskID,
                status: arguments.status,
                notes: arguments.notes,
                userID: arguments.userID
            });

            // Update plan status if all tasks are completed
            updatePlanStatus(getTaskPlanID(arguments.taskID));
        }

        return {
            success: true
        };
    }

    private function getTaskPlanID(required numeric taskID) {
        return queryExecute("
            SELECT planID
            FROM remediation_tasks
            WHERE taskID = :taskID
        ", {
            taskID: arguments.taskID
        }, {returntype="array"})[1].planID;
    }

    private function updatePlanStatus(required numeric planID) {
        var taskCounts = queryExecute("
            SELECT 
                COUNT(*) as totalTasks,
                SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completedTasks
            FROM remediation_tasks
            WHERE planID = :planID
        ", {
            planID: arguments.planID
        }, {returntype="array"})[1];

        var newStatus = "pending";
        if (taskCounts.completedTasks == taskCounts.totalTasks) {
            newStatus = "completed";
        } else if (taskCounts.completedTasks > 0) {
            newStatus = "in_progress";
        }

        queryExecute("
            UPDATE remediation_plans
            SET status = :status,
                modifiedDate = GETDATE()
            WHERE planID = :planID
        ", {
            planID: arguments.planID,
            status: newStatus
        });
    }

    private function logRemediationActivity(
        required numeric controlID,
        required numeric planID,
        required string action
    ) {
        queryExecute("
            INSERT INTO audit_activity (
                controlID, action, details,
                userID, activityDate,
                metadata
            ) VALUES (
                :controlID, :action,
                'Remediation plan created',
                1, GETDATE(),
                :metadata
            )
        ", {
            controlID: arguments.controlID,
            action: arguments.action,
            metadata: serializeJSON({planID: arguments.planID})
        });
    }

    private function extractSection(required string text, required string sectionName) {
        var pattern = sectionName & ".*?(?=\d+\.|$)";
        var result = reMatch(pattern, arguments.text);
        return arrayLen(result) ? trim(replace(result[1], sectionName, "")) : "";
    }

    private function logError(required string message, required any exception) {
        queryExecute("
            INSERT INTO error_log (
                errorMessage, errorDetails,
                errorDate, component,
                stackTrace
            ) VALUES (
                :message, :details,
                GETDATE(), 'RemediationService',
                :stackTrace
            )
        ", {
            message: arguments.message,
            details: arguments.exception.message,
            stackTrace: arguments.exception.stackTrace
        });
    }

    public function getCompanyRemediationPlans(required numeric companyID) {
        return queryExecute("
            SELECT p.*,
                   c.title as controlTitle,
                   a.reference as auditReference,
                   (
                       SELECT COUNT(*)
                       FROM remediation_tasks
                       WHERE planID = p.planID
                       AND status = 'completed'
                   ) as completedTasks,
                   (
                       SELECT COUNT(*)
                       FROM remediation_tasks
                       WHERE planID = p.planID
                   ) as totalTasks
            FROM remediation_plans p
            JOIN audit_controls ac ON p.controlID = ac.controlID
            JOIN controls c ON ac.controlID = c.controlID
            JOIN audits a ON p.auditID = a.auditID
            WHERE a.companyID = :companyID
            ORDER BY p.createdDate DESC
        ", {
            companyID = arguments.companyID
        });
    }

    public function getCompanyRemediationStats(required numeric companyID) {
        var stats = queryExecute("
            SELECT 
                COUNT(DISTINCT p.planID) as totalPlans,
                SUM(CASE WHEN p.status != 'completed' THEN 1 ELSE 0 END) as activePlans,
                (
                    SELECT COUNT(*)
                    FROM remediation_tasks t
                    JOIN remediation_plans p2 ON t.planID = p2.planID
                    JOIN audits a2 ON p2.auditID = a2.auditID
                    WHERE a2.companyID = :companyID
                    AND t.status = 'completed'
                ) as completedTasks,
                (
                    SELECT COUNT(*)
                    FROM remediation_tasks t
                    JOIN remediation_plans p2 ON t.planID = p2.planID
                    JOIN audits a2 ON p2.auditID = a2.auditID
                    WHERE a2.companyID = :companyID
                    AND t.dueDate < GETDATE()
                    AND t.status != 'completed'
                ) as overdueTasks
            FROM remediation_plans p
            JOIN audits a ON p.auditID = a.auditID
            WHERE a.companyID = :companyID
        ", {
            companyID = arguments.companyID
        }, {returntype="array"})[1];

        stats.completionRate = stats.totalPlans > 0 ? 
            (stats.completedTasks / (stats.completedTasks + stats.overdueTasks)) * 100 : 0;

        return stats;
    }

    public function getTaskDetails(required numeric taskID) {
        var task = queryExecute("
            SELECT t.*,
                   u.firstName + ' ' + u.lastName as assignedToName
            FROM remediation_tasks t
            LEFT JOIN users u ON t.assignedTo = u.userID
            WHERE t.taskID = :taskID
        ", {
            taskID = arguments.taskID
        }, {returntype="array"})[1];

        task.comments = getTaskComments(arguments.taskID);
        task.evidence = getTaskEvidence(arguments.taskID);

        return task;
    }

    public function addTaskComment(
        required numeric taskID,
        required string commentText,
        required numeric userID
    ) {
        transaction {
            queryExecute("
                INSERT INTO task_comments (
                    taskID, userID, commentText,
                    commentDate
                ) VALUES (
                    :taskID, :userID, :commentText,
                    GETDATE()
                )
            ", {
                taskID = arguments.taskID,
                userID = arguments.userID,
                commentText = arguments.commentText
            });

            // Log activity
            logTaskActivity(arguments.taskID, "comment_added", "Comment added", arguments.userID);
        }

        return {
            success = true
        };
    }

    public function uploadTaskEvidence(
        required numeric taskID,
        required string description,
        required struct file,
        required numeric userID
    ) {
        var evidenceID = 0;
        
        transaction {
            // Get company ID for encryption
            var companyID = queryExecute("
                SELECT a.companyID
                FROM remediation_tasks t
                JOIN remediation_plans p ON t.planID = p.planID
                JOIN audits a ON p.auditID = a.auditID
                WHERE t.taskID = :taskID
            ", {
                taskID = arguments.taskID
            }, {returntype="array"})[1].companyID;

            // Create evidence record
            evidenceID = queryExecute("
                INSERT INTO task_evidence (
                    taskID, description, uploadedBy,
                    uploadDate
                ) VALUES (
                    :taskID, :description, :uploadedBy,
                    GETDATE()
                )
                SELECT SCOPE_IDENTITY() as newID
            ", {
                taskID = arguments.taskID,
                description = arguments.description,
                uploadedBy = arguments.userID
            }, {returntype="array"})[1].newID;

            // Process and encrypt file
            var fileExtension = listLast(arguments.file.serverFile, ".");
            var encryptedFileName = createUUID() & "." & fileExtension;
            
            // Encrypt file using company-specific key
            encryptFile(
                arguments.file.serverDirectory & "/" & arguments.file.serverFile,
                application.evidencePath & "/" & encryptedFileName,
                companyID
            );
            
            // Delete temporary file
            fileDelete(arguments.file.serverDirectory & "/" & arguments.file.serverFile);
            
            // Save file metadata
            queryExecute("
                INSERT INTO task_evidence_files (
                    evidenceID, originalFileName,
                    encryptedFileName, fileSize,
                    mimeType, uploadDate
                ) VALUES (
                    :evidenceID, :originalFileName,
                    :encryptedFileName, :fileSize,
                    :mimeType, GETDATE()
                )
            ", {
                evidenceID = evidenceID,
                originalFileName = arguments.file.clientFile,
                encryptedFileName = encryptedFileName,
                fileSize = arguments.file.fileSize,
                mimeType = arguments.file.contentType
            });

            // Log activity
            logTaskActivity(arguments.taskID, "evidence_uploaded", 
                          "Evidence uploaded: #arguments.description#", 
                          arguments.userID);
        }

        return {
            success = true,
            evidenceID = evidenceID
        };
    }

    private function encryptFile(
        required string sourceFile,
        required string destinationFile,
        required numeric companyID
    ) {
        var fileContent = fileReadBinary(arguments.sourceFile);
        var iv = generateIV();
        var encryptionKey = getCompanyEncryptionKey(arguments.companyID);
        
        var encrypted = encrypt(fileContent, encryptionKey, variables.encryptionAlgorithm, iv);
        var finalContent = binaryConcat(iv, encrypted);
        
        fileWrite(arguments.destinationFile, finalContent);
    }

    private function getCompanyEncryptionKey(required numeric companyID) {
        // Get or generate company-specific encryption key
        var keyRecord = queryExecute("
            SELECT encryptionKey
            FROM company_encryption_keys
            WHERE companyID = :companyID
        ", {
            companyID = arguments.companyID
        }, {returntype="array"});

        if (!arrayLen(keyRecord)) {
            var newKey = generateSecretKey("AES", 256);
            
            queryExecute("
                INSERT INTO company_encryption_keys (
                    companyID, encryptionKey,
                    createdDate
                ) VALUES (
                    :companyID, :encryptionKey,
                    GETDATE()
                )
            ", {
                companyID = arguments.companyID,
                encryptionKey = newKey
            });

            return newKey;
        }

        return keyRecord[1].encryptionKey;
    }

    private function getTaskComments(required numeric taskID) {
        return queryExecute("
            SELECT c.*,
                   u.firstName + ' ' + u.lastName as userFullName
            FROM task_comments c
            JOIN users u ON c.userID = u.userID
            WHERE c.taskID = :taskID
            ORDER BY c.commentDate DESC
        ", {
            taskID = arguments.taskID
        });
    }

    private function getTaskEvidence(required numeric taskID) {
        return queryExecute("
            SELECT e.*,
                   ef.originalFileName,
                   ef.fileSize,
                   ef.mimeType,
                   u.firstName + ' ' + u.lastName as uploadedByName
            FROM task_evidence e
            JOIN task_evidence_files ef ON e.evidenceID = ef.evidenceID
            JOIN users u ON e.uploadedBy = u.userID
            WHERE e.taskID = :taskID
            ORDER BY e.uploadDate DESC
        ", {
            taskID = arguments.taskID
        });
    }

    private function logTaskActivity(
        required numeric taskID,
        required string action,
        required string details,
        required numeric userID
    ) {
        queryExecute("
            INSERT INTO task_activity (
                taskID, action, details,
                userID, activityDate
            ) VALUES (
                :taskID, :action, :details,
                :userID, GETDATE()
            )
        ", {
            taskID = arguments.taskID,
            action = arguments.action,
            details = arguments.details,
            userID = arguments.userID
        });
    }
} 