component {
    
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public boolean function isPasswordStrong(required string password) {
        // Password must be at least 8 characters long
        if (len(arguments.password) < 8) {
            return false;
        }
        
        // Password must contain at least one uppercase letter
        if (!reFind("[A-Z]", arguments.password)) {
            return false;
        }
        
        // Password must contain at least one lowercase letter
        if (!reFind("[a-z]", arguments.password)) {
            return false;
        }
        
        // Password must contain at least one number
        if (!reFind("[0-9]", arguments.password)) {
            return false;
        }
        
        // Password must contain at least one special character
        if (!reFind("[^A-Za-z0-9]", arguments.password)) {
            return false;
        }
        
        return true;
    }
    
    public string function generateVerificationToken(required numeric userID) {
        // Generate a random token
        var token = hash(createUUID() & now(), "SHA-256");
        
        // Store token in database with expiration
        queryExecute(
            "INSERT INTO verification_tokens (
                userID,
                token,
                expiresAt,
                createdDate
            ) VALUES (
                :userID,
                :token,
                DATEADD(hour, 24, CURRENT_TIMESTAMP),
                CURRENT_TIMESTAMP
            )",
            {
                userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                token = {value=token, cfsqltype="cf_sql_varchar"}
            },
            {datasource=variables.datasource}
        );
        
        return token;
    }
    
    public struct function verifyToken(required string token) {
        // Get token and check expiration
        var result = queryExecute(
            "SELECT vt.*, u.*
            FROM verification_tokens vt
            INNER JOIN users u ON vt.userID = u.userID
            WHERE vt.token = :token
            AND vt.expiresAt > CURRENT_TIMESTAMP
            AND vt.used = 0",
            {token = {value=arguments.token, cfsqltype="cf_sql_varchar"}},
            {datasource=variables.datasource}
        );
        
        if (result.recordCount) {
            // Mark token as used
            queryExecute(
                "UPDATE verification_tokens SET used = 1 WHERE token = :token",
                {token = {value=arguments.token, cfsqltype="cf_sql_varchar"}},
                {datasource=variables.datasource}
            );
            
            return result;
        }
        
        return nullValue();
    }
} 