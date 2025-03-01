component {
    logger = createObject("component", "logger");

    // Set response type to JSON
    remote any function init() {
        getPageContext().getResponse().setContentType("application/json");
        return this;
    }

    private function generateSalt() {
        var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@##$%^&*()";
        var salt = "";
        for (var i = 1; i <= 64; i++) {
            salt &= mid(chars, randRange(1, len(chars)), 1);
        }
        return salt;
    }

    private function hashPassword(required string password, required string userSalt, required string companySalt) {
        // First round: Hash with user's personal salt
        var firstHash = hash(arguments.password & arguments.userSalt, "SHA-512");
        // Second round: Hash with company salt for additional security
        return hash(firstHash & arguments.companySalt, "SHA-512");
    }

    remote function login(required struct formData) returnformat="json" {
        try {
            // Validate required fields
            if (NOT structKeyExists(formData, "email") OR 
                NOT structKeyExists(formData, "password")) {
                return {
                    "success": false,
                    "message": "Email and password are required"
                };
            }

            // Get user by email
            var qUser = queryExecute(
                "SELECT u.*, c.salt as companySalt
                FROM users u
                JOIN companies c ON u.companyID = c.companyID
                WHERE u.email = :email AND u.isActive = 1",
                {email = {value=formData.email, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (NOT qUser.recordCount) {
                return {
                    "success": false,
                    "message": "Invalid email or password"
                };
            }

            // Verify password using both user's personal salt and company salt
            var hashedPassword = hashPassword(formData.password, qUser.passwordSalt, qUser.companySalt);
            if (hashedPassword NEQ qUser.password) {
                return {
                    "success": false,
                    "message": "Invalid email or password"
                };
            }

            // Update last login date
            queryExecute(
                "UPDATE users SET lastLoginDate = CURRENT_TIMESTAMP WHERE userID = :userID",
                {userID = {value=qUser.userID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            // Set session variables
            session.isLoggedIn = true;
            session.userID = qUser.userID;
            session.companyID = qUser.companyID;
            session.email = qUser.email;
            session.firstName = qUser.firstName;
            session.lastName = qUser.lastName;
            session.role = qUser.role;
            session.preferredLanguage = qUser.preferredLanguage;
            session.isSuperAdmin = (qUser.role EQ "superadmin");
            session.isAdmin = (qUser.role EQ "admin" OR qUser.role EQ "superadmin");

            // Log the activity
            logger.logActivity(
                activityType = "LOGIN",
                activityDescription = "User logged in",
                additionalData = {
                    email = qUser.email
                }
            );

            return {
                "success": true,
                "message": "Login successful"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error during login: " & e.message
            };
        }
    }

    remote function register(required struct formData) returnformat="json" {
        try {
            // Validate required fields
            if (NOT structKeyExists(formData, "email") OR 
                NOT structKeyExists(formData, "password") OR 
                NOT structKeyExists(formData, "firstName") OR 
                NOT structKeyExists(formData, "lastName") OR 
                NOT structKeyExists(formData, "companyID")) {
                return {
                    "success": false,
                    "message": "All fields are required"
                };
            }

            // Validate company
            var qCompany = queryExecute(
                "SELECT companyID, salt FROM companies WHERE companyID = :companyID",
                {companyID = {value=formData.companyID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (NOT qCompany.recordCount) {
                return {
                    "success": false,
                    "message": "Invalid company ID"
                };
            }

            // Check if email already exists
            var qCheckEmail = queryExecute(
                "SELECT userID FROM users WHERE email = :email",
                {email = {value=formData.email, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (qCheckEmail.recordCount) {
                return {
                    "success": false,
                    "message": "Email address already registered"
                };
            }

            // Generate unique salt for the user
            var userSalt = generateSalt();
            
            // Hash password with both user's personal salt and company salt
            var hashedPassword = hashPassword(formData.password, userSalt, qCompany.salt);

            // Insert new user with UUID
            queryExecute(
                "INSERT INTO users (
                    companyID,
                    email,
                    password,
                    passwordSalt,
                    firstName,
                    lastName,
                    role,
                    isActive,
                    createdDate,
                    lastPasswordChange
                ) VALUES (
                    :companyID,
                    :email,
                    :password,
                    :passwordSalt,
                    :firstName,
                    :lastName,
                    'user',
                    1,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP
                )",
                {
                    companyID = {value=formData.companyID, cfsqltype="cf_sql_varchar"},
                    email = {value=formData.email, cfsqltype="cf_sql_varchar"},
                    password = {value=hashedPassword, cfsqltype="cf_sql_varchar"},
                    passwordSalt = {value=userSalt, cfsqltype="cf_sql_varchar"},
                    firstName = {value=formData.firstName, cfsqltype="cf_sql_varchar"},
                    lastName = {value=formData.lastName, cfsqltype="cf_sql_varchar"}
                },
                {datasource=application.datasource}
            );

            // Log the activity
            logger.logActivity(
                activityType = "REGISTER",
                activityDescription = "New user registered",
                additionalData = {
                    email = formData.email,
                    companyID = formData.companyID
                }
            );

            return {
                "success": true,
                "message": "Registration successful"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error during registration: " & e.message
            };
        }
    }

    remote function changePassword(required struct formData) returnformat="json" {
        try {
            if (NOT structKeyExists(session, "userID")) {
                return {
                    "success": false,
                    "message": "User not logged in"
                };
            }

            // Validate required fields
            if (NOT structKeyExists(formData, "currentPassword") OR 
                NOT structKeyExists(formData, "newPassword")) {
                return {
                    "success": false,
                    "message": "Current and new passwords are required"
                };
            }

            // Get user and company information
            var qUser = queryExecute(
                "SELECT u.*, c.salt as companySalt
                FROM users u
                JOIN companies c ON u.companyID = c.companyID
                WHERE u.userID = :userID",
                {userID = {value=session.userID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            // Verify current password
            var currentHashedPassword = hashPassword(formData.currentPassword, qUser.passwordSalt, qUser.companySalt);
            if (currentHashedPassword NEQ qUser.password) {
                return {
                    "success": false,
                    "message": "Current password is incorrect"
                };
            }

            // Generate new salt and hash new password
            var newSalt = generateSalt();
            var newHashedPassword = hashPassword(formData.newPassword, newSalt, qUser.companySalt);

            // Update password
            queryExecute(
                "UPDATE users SET 
                    password = :password,
                    passwordSalt = :passwordSalt,
                    lastPasswordChange = CURRENT_TIMESTAMP
                WHERE userID = :userID",
                {
                    password = {value=newHashedPassword, cfsqltype="cf_sql_varchar"},
                    passwordSalt = {value=newSalt, cfsqltype="cf_sql_varchar"},
                    userID = {value=session.userID, cfsqltype="cf_sql_varchar"}
                },
                {datasource=application.datasource}
            );

            // Log the activity
            logger.logActivity(
                activityType = "PASSWORD_CHANGE",
                activityDescription = "User changed password",
                additionalData = {
                    email = session.email
                }
            );

            return {
                "success": true,
                "message": "Password changed successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error changing password: " & e.message
            };
        }
    }

    remote function logout() returnformat="json" {
        try {
            if (structKeyExists(session, "userID")) {
                logger.logActivity(
                    activityType = "LOGOUT",
                    activityDescription = "User logged out",
                    additionalData = {
                        email = session.email
                    }
                );
            }

            structClear(session);
            
            return {
                "success": true,
                "message": "Logout successful"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error during logout: " & e.message
            };
        }
    }
} 