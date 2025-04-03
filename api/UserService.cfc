component {
    
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public boolean function emailExists(required string email) {
        var result = queryExecute(
            "SELECT COUNT(*) as count FROM users WHERE email = :email",
            {email = {value=arguments.email, cfsqltype="cf_sql_varchar"}},
            {datasource=variables.datasource}
        );
        
        return result.count > 0;
    }
    
    public struct function createUser(
        required numeric companyID,
        required string firstName,
        required string lastName,
        required string email,
        required string password,
        required string role,
        required string status
    ) {
        // Generate salt for password
        var salt = generateSalt();
        
        // Hash password
        var hashedPassword = hashPassword(arguments.password, salt);
        
        // Insert user
        var result = queryExecute(
            "INSERT INTO users (
                companyID,
                firstName,
                lastName,
                email,
                password,
                passwordSalt,
                role,
                status,
                createdDate
            ) VALUES (
                :companyID,
                :firstName,
                :lastName,
                :email,
                :password,
                :salt,
                :role,
                :status,
                CURRENT_TIMESTAMP
            )",
            {
                companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                firstName = {value=arguments.firstName, cfsqltype="cf_sql_varchar"},
                lastName = {value=arguments.lastName, cfsqltype="cf_sql_varchar"},
                email = {value=arguments.email, cfsqltype="cf_sql_varchar"},
                password = {value=hashedPassword, cfsqltype="cf_sql_varchar"},
                salt = {value=salt, cfsqltype="cf_sql_varchar"},
                role = {value=arguments.role, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.status, cfsqltype="cf_sql_varchar"}
            },
            {datasource=variables.datasource}
        );
        
        // Get the created user
        var user = queryExecute(
            "SELECT * FROM users WHERE userID = :userID",
            {userID = {value=result.generatedKey, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return user;
    }
    
    public void function updateUserStatus(required numeric userID, required string status) {
        queryExecute(
            "UPDATE users SET status = :status WHERE userID = :userID",
            {
                userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.status, cfsqltype="cf_sql_varchar"}
            },
            {datasource=variables.datasource}
        );
    }
    
    public void function updateLastVerificationAttempt(required numeric userID) {
        queryExecute(
            "UPDATE users SET lastVerificationAttempt = CURRENT_TIMESTAMP WHERE userID = :userID",
            {userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
    }
    
    private string function generateSalt() {
        return hash(createUUID() & now(), "SHA-256");
    }
    
    private string function hashPassword(required string password, required string salt) {
        return hash(arguments.password & arguments.salt, "SHA-256");
    }
} 