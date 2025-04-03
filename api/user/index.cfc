component {
    
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public boolean function emailExists(required string email) {
        var result = queryExecute(
            "SELECT COUNT(*) as count FROM users WHERE email = :email",
            {email = {value=arguments.email, cfsqltype="cf_sql_varchar"}},
            {datasource="grc"}
        );
        
        return result.count > 0;
    }
    
    public struct function createUser(
        required string companyID,
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
        var hashedPassword = hashPassword(arguments.password, salt, "SHA-256");
        
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
                statusID,
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
                companyID = {value=arguments.companyID, cfsqltype="cf_sql_varchar"},
                firstName = {value=arguments.firstName, cfsqltype="cf_sql_varchar"},
                lastName = {value=arguments.lastName, cfsqltype="cf_sql_varchar"},
                email = {value=arguments.email, cfsqltype="cf_sql_varchar"},
                password = {value=hashedPassword, cfsqltype="cf_sql_varchar"},
                salt = {value=salt, cfsqltype="cf_sql_varchar"},
                role = {value=arguments.role, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.status, cfsqltype="cf_sql_varchar"}
            },
            {datasource="grc"}
        );
        
        // Get the created user
        var user = queryExecute(
            "SELECT * FROM users WHERE email = :email",
            { email = {value=arguments.email, cfsqltype="cf_sql_varchar"}},
            {datasource="grc"}
        );
        
          return {
                    "success": true,
                    "message": "User created successfully",
                    "data": {
                        "userID": user.userID
                    }
                };
    }
    
    public void function updateUserStatus(required numeric userID, required string status) {
        queryExecute(
            "UPDATE users SET status = :status WHERE userID = :userID",
            {
                userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.status, cfsqltype="cf_sql_varchar"}
            },
            {datasource="grc"}
        );
    }
    
    public void function updateLastVerificationAttempt(required numeric userID) {
        queryExecute(
            "UPDATE users SET lastVerificationAttempt = CURRENT_TIMESTAMP WHERE userID = :userID",
            {userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}},
            {datasource="grc"}
        );
    }
    
    private string function generateSalt() {
        return hash(createUUID() & now(), "SHA-256");
    }
    
    private string function hashPassword(required string password, required string salt) {
        return hash(arguments.password & arguments.salt, "SHA-256");
    }

    
    public string function getEmailDomain(required string email) {
        // Remove any whitespace and convert to lowercase
        var cleanEmail = trim(lcase(arguments.email));
        
        // Check if email is valid
        if (!isValid("email", cleanEmail)) {
            return "";
        }
        
        // Get the part after @ symbol
        var domain = listLast(cleanEmail, "@");
        
        // Remove any trailing dots
        domain = reReplace(domain, "\.$", "");
        
        return domain;
    }
} 