component {
    remote function sendEmail(required string to, required string subject, required string body, string companyID = "") returnformat="json" {
        try {
            var emailConfig = getEmailConfig(companyID);
            var mail = createObject("component", "mail");
            mail.setTo(to);
            mail.setSubject(subject);
            mail.setBody(body);
            mail.setFrom(emailConfig.from);
            mail.setUsername(emailConfig.username);
            mail.setPassword(emailConfig.password);
            mail.setHost(emailConfig.host);
            mail.setPort(emailConfig.port);
            mail.setSSL(emailConfig.ssl);

            mail.send();
            return {
                "success": true,
                "message": "Email sent successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error sending email: " & e.message
            };
        }
    }

    private function getEmailConfig(required string companyID) {
        // Fetch email configuration from the database
        if (companyID) {
            var qEmailConfig = queryExecute(
                "SELECT email, username, password, host, port, ssl FROM company_email WHERE companyID = :companyID",
                {companyID = {value=companyID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (qEmailConfig.recordCount) {
                return {
                    "from": qEmailConfig.email,
                    "username": qEmailConfig.username,
                    "password": qEmailConfig.password,
                    "host": qEmailConfig.host,
                    "port": qEmailConfig.port,
                    "ssl": qEmailConfig.ssl
                };
            }
        }

        // Fallback to site-level email configuration
        return {
            "from": application.siteEmail,
            "username": application.siteEmailUsername,
            "password": application.siteEmailPassword,
            "host": application.siteEmailHost,
            "port": application.siteEmailPort,
            "ssl": application.siteEmailSSL
        };
    }
}