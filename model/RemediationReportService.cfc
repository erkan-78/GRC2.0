component {
    property name="remediationService" type="RemediationService";
    
    public function init() {
        variables.remediationService = new RemediationService();
        return this;
    }

    public function generateProgressReport(
        required numeric companyID,
        required date startDate,
        required date endDate,
        string format = "json"
    ) {
        var reportData = {
            summary: getProgressSummary(arguments.companyID, arguments.startDate, arguments.endDate),
            trends: getProgressTrends(arguments.companyID, arguments.startDate, arguments.endDate),
            planDetails: getPlanDetails(arguments.companyID, arguments.startDate, arguments.endDate),
            riskImpact: getRiskImpactAnalysis(arguments.companyID, arguments.startDate, arguments.endDate)
        };

        switch (arguments.format) {
            case "pdf":
                return generatePDFReport(reportData);
            case "excel":
                return generateExcelReport(reportData);
            default:
                return reportData;
        }
    }

    private function getProgressSummary(
        required numeric companyID,
        required date startDate,
        required date endDate
    ) {
        return queryExecute("
            SELECT 
                COUNT(DISTINCT p.planID) as totalPlans,
                SUM(CASE WHEN p.status = 'completed' THEN 1 ELSE 0 END) as completedPlans,
                SUM(CASE WHEN p.status = 'in_progress' THEN 1 ELSE 0 END) as inProgressPlans,
                (
                    SELECT COUNT(*)
                    FROM remediation_tasks t
                    JOIN remediation_plans p2 ON t.planID = p2.planID
                    JOIN audits a2 ON p2.auditID = a2.auditID
                    WHERE a2.companyID = :companyID
                    AND t.createdDate BETWEEN :startDate AND :endDate
                ) as totalTasks,
                (
                    SELECT COUNT(*)
                    FROM remediation_tasks t
                    JOIN remediation_plans p2 ON t.planID = p2.planID
                    JOIN audits a2 ON p2.auditID = a2.auditID
                    WHERE a2.companyID = :companyID
                    AND t.status = 'completed'
                    AND t.completedDate BETWEEN :startDate AND :endDate
                ) as completedTasks,
                (
                    SELECT COUNT(*)
                    FROM remediation_tasks t
                    JOIN remediation_plans p2 ON t.planID = p2.planID
                    JOIN audits a2 ON p2.auditID = a2.auditID
                    WHERE a2.companyID = :companyID
                    AND t.dueDate < GETDATE()
                    AND t.status != 'completed'
                ) as overdueTasks,
                AVG(DATEDIFF(day, t.createdDate, t.completedDate)) as avgCompletionTime
            FROM remediation_plans p
            JOIN audits a ON p.auditID = a.auditID
            LEFT JOIN remediation_tasks t ON p.planID = t.planID
            WHERE a.companyID = :companyID
            AND p.createdDate BETWEEN :startDate AND :endDate
        ", {
            companyID = arguments.companyID,
            startDate = arguments.startDate,
            endDate = arguments.endDate
        }, {returntype="array"})[1];
    }

    private function getProgressTrends(
        required numeric companyID,
        required date startDate,
        required date endDate
    ) {
        var trends = {
            weekly: [],
            monthly: []
        };

        // Weekly trends
        trends.weekly = queryExecute("
            SELECT 
                DATEADD(week, DATEDIFF(week, 0, t.completedDate), 0) as weekStart,
                COUNT(*) as completedTasks,
                COUNT(DISTINCT p.planID) as affectedPlans
            FROM remediation_tasks t
            JOIN remediation_plans p ON t.planID = p.planID
            JOIN audits a ON p.auditID = a.auditID
            WHERE a.companyID = :companyID
            AND t.completedDate BETWEEN :startDate AND :endDate
            GROUP BY DATEADD(week, DATEDIFF(week, 0, t.completedDate), 0)
            ORDER BY weekStart
        ", {
            companyID = arguments.companyID,
            startDate = arguments.startDate,
            endDate = arguments.endDate
        });

        // Monthly trends
        trends.monthly = queryExecute("
            SELECT 
                DATEADD(month, DATEDIFF(month, 0, t.completedDate), 0) as monthStart,
                COUNT(*) as completedTasks,
                COUNT(DISTINCT p.planID) as affectedPlans,
                AVG(DATEDIFF(day, t.createdDate, t.completedDate)) as avgCompletionTime
            FROM remediation_tasks t
            JOIN remediation_plans p ON t.planID = p.planID
            JOIN audits a ON p.auditID = a.auditID
            WHERE a.companyID = :companyID
            AND t.completedDate BETWEEN :startDate AND :endDate
            GROUP BY DATEADD(month, DATEDIFF(month, 0, t.completedDate), 0)
            ORDER BY monthStart
        ", {
            companyID = arguments.companyID,
            startDate = arguments.startDate,
            endDate = arguments.endDate
        });

        return trends;
    }

    private function getPlanDetails(
        required numeric companyID,
        required date startDate,
        required date endDate
    ) {
        return queryExecute("
            SELECT 
                p.planID,
                p.status,
                c.title as controlTitle,
                a.reference as auditReference,
                p.createdDate,
                p.modifiedDate,
                (
                    SELECT COUNT(*)
                    FROM remediation_tasks
                    WHERE planID = p.planID
                ) as totalTasks,
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
                    AND dueDate < GETDATE()
                    AND status != 'completed'
                ) as overdueTasks
            FROM remediation_plans p
            JOIN audit_controls ac ON p.controlID = ac.controlID
            JOIN controls c ON ac.controlID = c.controlID
            JOIN audits a ON p.auditID = a.auditID
            WHERE a.companyID = :companyID
            AND p.createdDate BETWEEN :startDate AND :endDate
            ORDER BY p.createdDate DESC
        ", {
            companyID = arguments.companyID,
            startDate = arguments.startDate,
            endDate = arguments.endDate
        });
    }

    private function getRiskImpactAnalysis(
        required numeric companyID,
        required date startDate,
        required date endDate
    ) {
        return queryExecute("
            SELECT 
                r.riskLevel,
                COUNT(DISTINCT p.planID) as totalPlans,
                COUNT(DISTINCT CASE WHEN p.status = 'completed' THEN p.planID END) as completedPlans,
                AVG(CASE WHEN p.status = 'completed' 
                    THEN DATEDIFF(day, p.createdDate, p.modifiedDate) 
                    END) as avgCompletionDays,
                COUNT(DISTINCT t.taskID) as totalTasks,
                COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.taskID END) as completedTasks
            FROM remediation_plans p
            JOIN audit_controls ac ON p.controlID = ac.controlID
            JOIN risk_assessments r ON ac.controlID = r.controlID
            LEFT JOIN remediation_tasks t ON p.planID = t.planID
            JOIN audits a ON p.auditID = a.auditID
            WHERE a.companyID = :companyID
            AND p.createdDate BETWEEN :startDate AND :endDate
            GROUP BY r.riskLevel
            ORDER BY 
                CASE r.riskLevel 
                    WHEN 'critical' THEN 1
                    WHEN 'high' THEN 2
                    WHEN 'medium' THEN 3
                    WHEN 'low' THEN 4
                    ELSE 5
                END
        ", {
            companyID = arguments.companyID,
            startDate = arguments.startDate,
            endDate = arguments.endDate
        });
    }

    private function generatePDFReport(required struct reportData) {
        var pdfService = new PDFService();
        return pdfService.generateRemediationReport(arguments.reportData);
    }

    private function generateExcelReport(required struct reportData) {
        var excelService = new ExcelService();
        return excelService.generateRemediationReport(arguments.reportData);
    }
} 