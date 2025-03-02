component {
    this.name = "GRC2";
    this.applicationTimeout = createTimeSpan(0,2,0,0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0,0,20,0);
    this.datasource = "grc2";
    this.mappings = {
        "/model" = expandPath('./model'),
        "/controller" = expandPath('./controller')
    };
    
    function onApplicationStart() {
        application.started = now();
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
        writeDump(arguments.exception);
    }
} 