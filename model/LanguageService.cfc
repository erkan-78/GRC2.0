component {
    // ... existing code ...

    public string function formatDate(required date dateValue, string language = session.userLanguage) {
        var format = getDateFormat(arguments.language);
        return dateFormat(arguments.dateValue, format);
    }

    public string function formatDateTime(required date dateValue, string language = session.userLanguage) {
        var dateFormat = getDateFormat(arguments.language);
        var timeFormat = getTimeFormat(arguments.language);
        return dateFormat(arguments.dateValue, dateFormat) & " " & 
               timeFormat(arguments.dateValue, timeFormat);
    }

    private string function getDateFormat(required string language) {
        var formats = {
            "en": "mmmm d, yyyy",
            "es": "d 'de' mmmm 'de' yyyy",
            "tr": "d mmmm yyyy"
        };
        return formats[arguments.language] ?: formats["en"];
    }

    private string function getTimeFormat(required string language) {
        var formats = {
            "en": "HH:mm",
            "es": "HH:mm",
            "tr": "HH:mm"
        };
        return formats[arguments.language] ?: formats["en"];
    }

    public string function getStatusLabel(
        required string status,
        required string module,
        string language = session.userLanguage
    ) {
        return getLabel(arguments.module, "status." & arguments.status, arguments.language);
    }
} 