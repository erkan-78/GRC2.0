component {
    this.name = "UserManagementApp";
    this.applicationTimeout = createTimeSpan(0,2,0,0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0,0,30,0);
    
    // Database settings
    this.datasource = "userManagementDB";
    
    function onApplicationStart() {
        application.started = now();
        return true;
    }
    
    function onSessionStart() {
        session.started = now();
        session.isLoggedIn = false;
        session.userID = "";
        session.userName = "";
    }
    
    function onRequestStart(targetPage) {
        if(structKeyExists(url, "reset")) {
            onApplicationStart();
        }
    }
    
    function onError(exception, eventName) {
        writeOutput('<h1>An error occurred</h1>');
        writeOutput('<p>Please contact the administrator.</p>');
        writeOutput('<p>Error details: ' & exception.message & '</p>');
    }
} 