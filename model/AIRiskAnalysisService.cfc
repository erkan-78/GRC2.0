component {
    property name="openAIKey" type="string";
    property name="evidenceService" type="AuditEvidenceService";
    
    public function init() {
        variables.openAIKey = application.getSecretKey("openai");
        variables.evidenceService = new AuditEvidenceService();
        return this;
    }

    public function analyzeControlEvidence(required numeric controlID, required numeric auditID) {
        var control = getControlData(arguments.controlID);
        var evidence = variables.evidenceService.getEvidence(arguments.controlID);
        
        // Prepare context for AI analysis
        var analysisContext = {
            "control": {
                "title": control.title,
                "description": control.description,
                "testProcedures": control.testProcedures,
                "evidenceRequirements": control.evidenceRequirements
            },
            "evidence": []
        };

        // Process evidence files for text extraction
        for (var item in evidence) {
            var evidenceFiles = getEvidenceFiles(item.evidenceID);
            var extractedText = extractTextFromFiles(evidenceFiles);
            analysisContext.evidence.append({
                "description": item.description,
                "content": extractedText
            });
        }

        // Perform AI analysis
        var analysisResults = performAIAnalysis(analysisContext);
        
        // Save analysis results
        saveAnalysisResults(arguments.controlID, arguments.auditID, analysisResults);
        
        return analysisResults;
    }

    private function getControlData(required numeric controlID) {
        var auditService = new AuditService();
        return auditService.getControlDetails(arguments.controlID);
    }

    private function getEvidenceFiles(required numeric evidenceID) {
        return queryExecute("
            SELECT *
            FROM audit_evidence_files
            WHERE evidenceID = :evidenceID
        ", {
            evidenceID = arguments.evidenceID
        });
    }

    private function extractTextFromFiles(required query files) {
        var textContent = [];
        
        for (var file in files) {
            var tempFile = variables.evidenceService.downloadEvidence(file.evidenceID, 1).tempFile;
            
            try {
                // Use Apache Tika for text extraction
                var tika = createObject("java", "org.apache.tika.Tika").init();
                var content = tika.parseToString(createObject("java", "java.io.File").init(tempFile));
                textContent.append(content);
            } catch (any e) {
                // Log extraction error
                logError("Text extraction failed for file: " & file.originalFileName, e);
            } finally {
                // Clean up temp file
                if (fileExists(tempFile)) {
                    fileDelete(tempFile);
                }
            }
        }
        
        return arrayToList(textContent, " ");
    }

    private function performAIAnalysis(required struct context) {
        var prompt = buildAnalysisPrompt(arguments.context);
        
        try {
            var httpService = new http();
            httpService.setURL("https://api.openai.com/v1/chat/completions");
            httpService.setMethod("POST");
            httpService.addParam(type="header", name="Authorization", value="Bearer " & variables.openAIKey);
            httpService.addParam(type="header", name="Content-Type", value="application/json");
            
            var requestBody = {
                "model": "gpt-4",
                "messages": [
                    {
                        "role": "system",
                        "content": "You are a risk analysis expert specializing in audit control evaluation. Analyze the provided control and evidence data to identify risks, gaps, and provide recommendations."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": 0.3,
                "max_tokens": 2000
            };
            
            httpService.addParam(type="body", value=serializeJSON(requestBody));
            
            var response = httpService.send().getPrefix();
            var result = deserializeJSON(response.fileContent);
            
            return parseAIResponse(result.choices[1].message.content);
        } catch (any e) {
            logError("AI analysis failed", e);
            return {
                success: false,
                error: "AI analysis failed: " & e.message
            };
        }
    }

    private function buildAnalysisPrompt(required struct context) {
        var prompt = "Analyze the following control and its evidence for risk assessment:

Control Information:
Title: #context.control.title#
Description: #context.control.description#
Test Procedures: #context.control.testProcedures#
Evidence Requirements: #context.control.evidenceRequirements#

Evidence Provided:
";
        
        for (var item in context.evidence) {
            prompt &= "
Description: #item.description#
Content: #left(item.content, 1000)#
";
        }

        prompt &= "

Please provide analysis in the following format:
1. Control Coverage Assessment
2. Evidence Completeness
3. Identified Gaps
4. Risk Level Assessment
5. Recommendations
6. Additional Controls Needed";

        return prompt;
    }

    private function parseAIResponse(required string response) {
        // Parse the structured response into sections
        var sections = {
            "coverage": extractSection(response, "Control Coverage Assessment"),
            "completeness": extractSection(response, "Evidence Completeness"),
            "gaps": extractSection(response, "Identified Gaps"),
            "riskLevel": extractSection(response, "Risk Level Assessment"),
            "recommendations": extractSection(response, "Recommendations"),
            "additionalControls": extractSection(response, "Additional Controls Needed")
        };

        // Extract risk score (if present in risk level assessment)
        var riskScore = extractRiskScore(sections.riskLevel);

        return {
            success: true,
            analysis: sections,
            riskScore: riskScore,
            rawResponse: response
        };
    }

    private function extractSection(required string text, required string sectionName) {
        var pattern = sectionName & ":\s*(.+?)(?=\d+\.|$)";
        var result = reMatch(pattern, arguments.text);
        return arrayLen(result) ? trim(result[1]) : "";
    }

    private function extractRiskScore(required string riskLevelText) {
        var scorePattern = "\b([1-5]|[0-9]*\.?[0-9]+)/5\b";
        var matches = reMatch(scorePattern, arguments.riskLevelText);
        return arrayLen(matches) ? val(matches[1]) : 0;
    }

    private function saveAnalysisResults(
        required numeric controlID,
        required numeric auditID,
        required struct analysis
    ) {
        if (!analysis.success) {
            return;
        }

        transaction {
            var analysisID = queryExecute("
                INSERT INTO audit_control_analysis (
                    controlID, auditID, analysisDate,
                    coverage, completeness, gaps,
                    riskLevel, recommendations, additionalControls,
                    riskScore, rawResponse
                ) VALUES (
                    :controlID, :auditID, GETDATE(),
                    :coverage, :completeness, :gaps,
                    :riskLevel, :recommendations, :additionalControls,
                    :riskScore, :rawResponse
                )
                SELECT SCOPE_IDENTITY() as newID
            ", {
                controlID: arguments.controlID,
                auditID: arguments.auditID,
                coverage: analysis.analysis.coverage,
                completeness: analysis.analysis.completeness,
                gaps: analysis.analysis.gaps,
                riskLevel: analysis.analysis.riskLevel,
                recommendations: analysis.analysis.recommendations,
                additionalControls: analysis.analysis.additionalControls,
                riskScore: analysis.riskScore,
                rawResponse: analysis.rawResponse
            }, {returntype="array"})[1].newID;

            // Log the analysis
            logAnalysisActivity(arguments.controlID, analysisID);
        }
    }

    private function logAnalysisActivity(required numeric controlID, required numeric analysisID) {
        queryExecute("
            INSERT INTO audit_activity (
                controlID, action, details,
                userID, activityDate,
                metadata
            ) VALUES (
                :controlID, 'ai_analysis',
                'AI Risk Analysis performed',
                1, GETDATE(),
                :metadata
            )
        ", {
            controlID: arguments.controlID,
            metadata: serializeJSON({analysisID: arguments.analysisID})
        });
    }

    private function logError(required string message, required any exception) {
        queryExecute("
            INSERT INTO error_log (
                errorMessage, errorDetails,
                errorDate, component,
                stackTrace
            ) VALUES (
                :message, :details,
                GETDATE(), 'AIRiskAnalysisService',
                :stackTrace
            )
        ", {
            message: arguments.message,
            details: arguments.exception.message,
            stackTrace: arguments.exception.stackTrace
        });
    }
} 