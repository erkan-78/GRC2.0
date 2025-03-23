component {
    property name="languageService" type="LanguageService";

    public function init() {
        variables.languageService = new LanguageService();
        return this;
    }

    public struct function getDashboardStatistics(
        required numeric userID,
        string language = session.userLanguage
    ) {
        // ... existing code ...
        
        // Format numbers according to language preferences
        return {
            highRiskCount: languageService.formatNumber(highRiskCount, arguments.language),
            pendingPolicyReviews: languageService.formatNumber(pendingPolicyReviews, arguments.language),
            activeAudits: languageService.formatNumber(activeAudits, arguments.language),
            controlGaps: languageService.formatNumber(controlGaps, arguments.language)
        };
    }

    // ... other methods with similar language support ...
} 