component {
    property name="scriptRunner" type="ScriptRunner";
    property name="documentService" type="DocumentService";
    
    public function init() {
        variables.scriptRunner = new ScriptRunner();
        variables.documentService = new DocumentService();
        return this;
    }

    public function createScript(
        required string title,
        required string description,
        required string scriptType,
        required string scriptContent,
        required array parameters,
        required string inputType,
        required numeric createdBy
    ) {
        return queryExecute("
            INSERT INTO automation_scripts (
                title,
                description,
                scriptType,
                scriptContent,
                parameters,
                inputType,
                createdBy
            ) VALUES (
                :title,
                :description,
                :scriptType,
                :scriptContent,
                :parameters,
                :inputType,
                :createdBy
            )
            SELECT SCOPE_IDENTITY() as newID
        ", {
            title: arguments.title,
            description: arguments.description,
            scriptType: arguments.scriptType,
            scriptContent: arguments.scriptContent,
            parameters: serializeJSON(arguments.parameters),
            inputType: arguments.inputType,
            createdBy: arguments.createdBy
        }, {returntype="array"})[1].newID;
    }

    public function executeScript(
        required numeric scriptID,
        required numeric auditID,
        required numeric controlID,
        required numeric executedBy,
        string inputFile = "",
        struct parameters = {}
    ) {
        var script = getScript(arguments.scriptID);
        
        // Create execution record
        var executionID = queryExecute("
            INSERT INTO script_executions (
                scriptID,
                auditID,
                controlID,
                executedBy,
                status,
                parameters,
                inputFile
            ) VALUES (
                :scriptID,
                :auditID,
                :controlID,
                :executedBy,
                'pending',
                :parameters,
                :inputFile
            )
            SELECT SCOPE_IDENTITY() as newID
        ", {
            scriptID: arguments.scriptID,
            auditID: arguments.auditID,
            controlID: arguments.controlID,
            executedBy: arguments.executedBy,
            parameters: serializeJSON(arguments.parameters),
            inputFile: arguments.inputFile
        }, {returntype="array"})[1].newID;

        // Execute script asynchronously
        runAsync(function() {
            try {
                // Update status to running
                updateExecutionStatus(executionID, "running");

                // Run the script
                var result = variables.scriptRunner.execute(
                    script.scriptType,
                    script.scriptContent,
                    arguments.parameters,
                    arguments.inputFile
                );

                // Save results
                saveExecutionResults(
                    executionID,
                    result.textOutput,
                    result.fileOutput
                );

                // Create audit evidence
                createAuditEvidence(
                    arguments.auditID,
                    arguments.controlID,
                    executionID,
                    result
                );

            } catch (any e) {
                // Update status to failed
                updateExecutionStatus(executionID, "failed", e.message);
            }
        });

        return executionID;
    }

    private function saveExecutionResults(
        required numeric executionID,
        required string textOutput,
        required string fileOutput
    ) {
        queryExecute("
            UPDATE script_executions
            SET 
                status = 'completed',
                resultText = :textOutput,
                resultFile = :fileOutput,
                modifiedDate = GETDATE()
            WHERE executionID = :executionID
        ", {
            executionID: arguments.executionID,
            textOutput: arguments.textOutput,
            fileOutput: arguments.fileOutput
        });
    }

    private function createAuditEvidence(
        required numeric auditID,
        required numeric controlID,
        required numeric executionID,
        required struct result
    ) {
        // Create evidence record with text output
        var evidenceID = application.auditService.addEvidence(
            arguments.auditID,
            arguments.controlID,
            "automation",
            result.textOutput
        );

        // Attach result file if exists
        if (len(result.fileOutput)) {
            application.documentService.attachFile(
                "evidence",
                evidenceID,
                result.fileOutput
            );
        }
    }

    public function getScripts(boolean activeOnly = true) {
        var sql = "
            SELECT 
                s.*,
                u.firstName + ' ' + u.lastName as createdByName
            FROM automation_scripts s
            JOIN users u ON s.createdBy = u.userID
        ";
        
        if (arguments.activeOnly) {
            sql &= " WHERE s.isActive = 1";
        }
        
        sql &= " ORDER BY s.title";
        
        return queryExecute(sql);
    }

    public function getExecutions(
        numeric auditID = 0,
        numeric controlID = 0
    ) {
        var sql = "
            SELECT 
                e.*,
                s.title as scriptTitle,
                u.firstName + ' ' + u.lastName as executedByName
            FROM script_executions e
            JOIN automation_scripts s ON e.scriptID = s.scriptID
            JOIN users u ON e.executedBy = u.userID
            WHERE 1=1
        ";
        
        if (arguments.auditID) {
            sql &= " AND e.auditID = :auditID";
        }
        
        if (arguments.controlID) {
            sql &= " AND e.controlID = :controlID";
        }
        
        sql &= " ORDER BY e.executionDate DESC";
        
        return queryExecute(sql, {
            auditID: arguments.auditID,
            controlID: arguments.controlID
        });
    }
} 