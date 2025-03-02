component {
    property name="remediationService" type="RemediationService";
    property name="riskService" type="RiskService";
    property name="aiService" type="AIRiskAnalysisService";
    
    public function init() {
        variables.remediationService = new RemediationService();
        variables.riskService = new RiskService();
        variables.aiService = new AIRiskAnalysisService();
        return this;
    }

    public function analyzeRemediationImpact(required numeric planID) {
        var plan = variables.remediationService.getRemediationPlan(arguments.planID);
        var riskAssessment = variables.riskService.getControlRiskAssessment(plan.controlID);
        var completedTasks = variables.remediationService.getCompletedTasks(arguments.planID);
        
        // Analyze evidence from completed tasks
        var evidenceAnalysis = analyzeTaskEvidence(completedTasks);
        
        // Calculate new risk scores based on remediation progress
        var updatedRiskScores = calculateUpdatedRiskScores(
            riskAssessment,
            plan,
            evidenceAnalysis
        );
        
        // Save updated risk assessment
        variables.riskService.updateRiskAssessment(
            riskAssessment.assessmentID,
            updatedRiskScores
        );
        
        return {
            originalRisk: riskAssessment,
            updatedRisk: updatedRiskScores,
            evidenceAnalysis: evidenceAnalysis
        };
    }

    private function analyzeTaskEvidence(required array tasks) {
        var evidenceAnalysis = [];
        
        for (var task in arguments.tasks) {
            var taskEvidence = variables.remediationService.getTaskEvidence(task.taskID);
            
            if (arrayLen(taskEvidence)) {
                var analysis = variables.aiService.analyzeEvidence(
                    taskEvidence,
                    task.controlID
                );
                
                evidenceAnalysis.append({
                    taskID: task.taskID,
                    analysis: analysis
                });
            }
        }
        
        return evidenceAnalysis;
    }

    private function calculateUpdatedRiskScores(
        required struct riskAssessment,
        required struct plan,
        required array evidenceAnalysis
    ) {
        var completionRate = (plan.completedTasks / plan.totalTasks);
        var effectivenessScore = calculateEffectivenessScore(arguments.evidenceAnalysis);
        
        // Calculate new likelihood score
        var newLikelihood = adjustLikelihood(
            arguments.riskAssessment.likelihood,
            completionRate,
            effectivenessScore
        );
        
        // Calculate new impact score
        var newImpact = adjustImpact(
            arguments.riskAssessment.impact,
            completionRate,
            effectivenessScore
        );
        
        // Calculate new control effectiveness
        var newEffectiveness = calculateControlEffectiveness(
            completionRate,
            effectivenessScore
        );
        
        return {
            likelihood: newLikelihood,
            impact: newImpact,
            effectiveness: newEffectiveness,
            residualRisk: calculateResidualRisk(newLikelihood, newImpact, newEffectiveness)
        };
    }

    private function calculateEffectivenessScore(required array evidenceAnalysis) {
        if (!arrayLen(arguments.evidenceAnalysis)) {
            return 0;
        }
        
        var totalScore = 0;
        for (var analysis in arguments.evidenceAnalysis) {
            totalScore += analysis.analysis.effectivenessScore;
        }
        
        return totalScore / arrayLen(arguments.evidenceAnalysis);
    }

    private function adjustLikelihood(
        required numeric currentLikelihood,
        required numeric completionRate,
        required numeric effectivenessScore
    ) {
        var adjustment = (arguments.completionRate * arguments.effectivenessScore) / 2;
        var newLikelihood = arguments.currentLikelihood - adjustment;
        
        // Ensure likelihood stays within valid range (1-5)
        return min(5, max(1, newLikelihood));
    }

    private function adjustImpact(
        required numeric currentImpact,
        required numeric completionRate,
        required numeric effectivenessScore
    ) {
        var adjustment = (arguments.completionRate * arguments.effectivenessScore) / 3;
        var newImpact = arguments.currentImpact - adjustment;
        
        // Ensure impact stays within valid range (1-5)
        return min(5, max(1, newImpact));
    }

    private function calculateControlEffectiveness(
        required numeric completionRate,
        required numeric effectivenessScore
    ) {
        return (arguments.completionRate * 0.4) + (arguments.effectivenessScore * 0.6);
    }

    private function calculateResidualRisk(
        required numeric likelihood,
        required numeric impact,
        required numeric effectiveness
    ) {
        var inherentRisk = arguments.likelihood * arguments.impact;
        return inherentRisk * (1 - arguments.effectiveness);
    }

    public function generateRiskTreatmentPlan(required numeric riskID) {
        var risk = variables.riskService.getRiskDetails(arguments.riskID);
        var controls = variables.riskService.getRiskControls(arguments.riskID);
        var remediationContext = {
            risk: risk,
            controls: controls,
            currentTreatments: variables.riskService.getCurrentTreatments(arguments.riskID)
        };
        
        // Generate AI-powered treatment suggestions
        var treatmentSuggestions = variables.aiService.generateTreatmentSuggestions(
            remediationContext
        );
        
        // Create remediation plans for suggested treatments
        var plans = [];
        for (var suggestion in treatmentSuggestions) {
            var plan = variables.remediationService.createRemediationPlan({
                controlID: suggestion.controlID,
                auditID: risk.auditID,
                title: suggestion.title,
                description: suggestion.description,
                tasks: suggestion.tasks,
                priority: suggestion.priority,
                resourceRequirements: suggestion.resources,
                successMetrics: suggestion.metrics
            });
            
            plans.append(plan);
        }
        
        return {
            riskID: arguments.riskID,
            suggestions: treatmentSuggestions,
            plans: plans
        };
    }

    public function trackRiskTreatmentProgress(required numeric riskID) {
        var risk = variables.riskService.getRiskDetails(arguments.riskID);
        var treatments = variables.riskService.getCurrentTreatments(arguments.riskID);
        var remediationPlans = [];
        
        for (var treatment in treatments) {
            if (treatment.type == "remediation") {
                var plan = variables.remediationService.getRemediationPlan(treatment.planID);
                remediationPlans.append(plan);
            }
        }
        
        var progress = {
            totalPlans: arrayLen(remediationPlans),
            completedPlans: 0,
            totalTasks: 0,
            completedTasks: 0,
            overdueTasks: 0,
            riskReduction: 0
        };
        
        for (var plan in remediationPlans) {
            progress.completedPlans += (plan.status == "completed" ? 1 : 0);
            progress.totalTasks += plan.totalTasks;
            progress.completedTasks += plan.completedTasks;
            progress.overdueTasks += plan.overdueTasks;
            
            // Analyze risk impact for completed plans
            if (plan.status == "completed") {
                var impact = analyzeRemediationImpact(plan.planID);
                progress.riskReduction += (impact.originalRisk.residualRisk - impact.updatedRisk.residualRisk);
            }
        }
        
        return progress;
    }
} 