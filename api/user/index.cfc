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
    
    public struct function getUserByEmail(required string email) {
        var result = queryExecute(
            "SELECT 
                userID,
                companyID,
                email,
                firstName,
                lastName,
                role,
                passwordSalt as salt,
                password,
                statusID
            FROM users 
            WHERE email = :email",
            {email = {value=arguments.email, cfsqltype="cf_sql_varchar"}},
            {datasource="grc"}
        );
        
        if (result.recordCount) {
            return {
                "success": true,
                "data": {
                    "userID": result.userID,
                    "companyID": result.companyID,
                    "email": result.email,
                    "firstName": result.firstName,
                    "lastName": result.lastName,
                    "role": result.role,
                    "salt": result.salt,
                    "password": result.password,
                    "statusID": result.statusID
                }
            };
        }
        
        return {
            "success": false,
            "message": "User not found"
        };
    }
    
    public struct function verifyPassword(required string email, required string password) {
        // Get user data
        var user = getUserByEmail(arguments.email);
        
        if (!user.success) {
            return {
                "success": false,
                "message": "User not found"
            };
        }
        
        // Hash the provided password with the stored salt
        var hashedPassword = hashPassword(arguments.password, user.data.salt);
        
        // Compare with stored password
        if (hashedPassword eq user.data.password) {
            // Update last login timestamp and preferred language
       
            
            return {
                "success": true,
                "message": "Password verified successfully",
                "data": {
                    "userID": user.data.userID,
                    "companyID": user.data.companyID,
                    "email": user.data.email,
                    "firstName": user.data.firstName,
                    "lastName": user.data.lastName,
                    "role": user.data.role
                }
            };
        }
        
        return {
            "success": false,
            "message": "Invalid password"
        };
    }
    
    public void function updateLastLogin(required string userID) {
        queryExecute(
            "UPDATE users SET lastLoginDate = CURRENT_TIMESTAMP WHERE userID = :userID",
            {userID = {value=arguments.userID, cfsqltype="cf_sql_varchar"}},
            {datasource="grc"}
        );
    }
    
    public void function updatePreferredLanguage(required string userID, required string languageID) {
        queryExecute(
            "UPDATE users SET preferredLanguage = :languageID WHERE userID = :userID",
            {
                userID = {value=arguments.userID, cfsqltype="cf_sql_varchar"},
                languageID = {value=arguments.languageID, cfsqltype="cf_sql_varchar"}
            },
            {datasource="grc"}
        );
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