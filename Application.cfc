component {
    this.name = "GRC2";
    this.applicationTimeout = createTimeSpan(0,2,0,0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0,0,20,0);
    this.mappings = {
        "/model" = expandPath('./model'),
        "/controller" = expandPath('./controller')
    };
    
    // Lucee datasource configuration
    this.datasource = "grc";
    this.datasources["grc"] = {
        class: 'com.mysql.cj.jdbc.Driver'
        , bundleName: 'com.mysql.cj'
        , bundleVersion: '8.0.30'
        , connectionString: 'jdbc:mysql://GRC-DB:3306/grc?characterEncoding=UTF-8&serverTimezone=Etc/UTC&maxReconnects=15'
        , username: 'grc_user'
        , password: "complexPassword!!44"
        
        // optional settings
        , connectionLimit: -1 // default:-1
        , liveTimeout: 15 // default: -1; unit: minutes
        , alwaysSetTimeout: true // default: false
        , validate: false // default: false
    };
    
    function onApplicationStart() {
        application.started = now();
        
        // Create datasource if it doesn't exist
 
            queryExecute("INSERT INTO grc.Systemcheck
(Log_date, actionpage)
VALUES(now(3), 'Application.cfc');", {}, {datasource="grc"});
         application.datasource = "grc";
        
        
        restInitApplication(expandPath('./'), '/api', false, 'tr+52opru9AjLVLp9!sw');
        return true;
    }
    
    function onSessionStart() {
        session.started = now();
    }
    
    function onRequestStart(required string targetPage) {
        if(structKeyExists(url,"reload")) {
            onApplicationStart();
        }
        return true;
    }
    
    function onError(any exception, string eventName) {
        // Get the current template path 
        <!--- <cfabort> 
        var currentTemplate = cgi.script_name;
        
        // Log error details to database
        try {
            queryExecute("
                INSERT INTO grc.ErrorLog 
                (error_date, error_type, error_message, error_detail, error_file, error_line, error_template)
                VALUES 
                (now(3), ?, ?, ?, ?, ?, ?)
            ", 
            [
                arguments.exception.type,
                arguments.exception.message,
                arguments.exception.detail,
                arguments.exception.file,
                arguments.exception.line,
                currentTemplate
            ], 
            {datasource="grc"});
        } catch (any e) {
            // If database logging fails, write to file
            writeLog(
                file = "error",
                type = "error",
                text = "Error in #currentTemplate#: #arguments.exception.message#"
            );
        }
        
        // Display error page
        include "/error.cfm";--->
    }
} 