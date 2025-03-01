component {
    // Set response type to JSON
    remote any function init() {
        getPageContext().getResponse().setContentType("application/json");
    }

    remote struct function getUserProfile(required numeric userID) httpmethod="GET" {
        init();
        
        try {
            if (NOT session.isLoggedIn OR session.userID NEQ arguments.userID) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }
            
            var qUser = queryExecute(
                "SELECT username, email, firstName, lastName, createdDate, lastLoginDate, role 
                FROM users WHERE userID = :userID",
                {userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qUser.recordCount) {
                return {
                    "success": true,
                    "data": {
                        "username": qUser.username,
                        "email": qUser.email,
                        "firstName": qUser.firstName,
                        "lastName": qUser.lastName,
                        "createdDate": dateFormat(qUser.createdDate, "yyyy-mm-dd"),
                        "lastLoginDate": dateFormat(qUser.lastLoginDate, "yyyy-mm-dd") & " " & timeFormat(qUser.lastLoginDate, "HH:mm:ss"),
                        "role": qUser.role
                    }
                };
            } else {
                return {
                    "success": false,
                    "message": "User not found"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching user profile",
                "error": e.message
            };
        }
    }

    remote struct function updateProfile(
        required numeric userID,
        required string email,
        required string firstName,
        required string lastName
    ) httpmethod="PUT" {
        init();
        
        try {
            if (NOT session.isLoggedIn OR session.userID NEQ arguments.userID) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }
            
            queryExecute(
                "UPDATE users SET 
                email = :email,
                firstName = :firstName,
                lastName = :lastName
                WHERE userID = :userID",
                {
                    userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                    email = {value=arguments.email, cfsqltype="cf_sql_varchar"},
                    firstName = {value=arguments.firstName, cfsqltype="cf_sql_varchar"},
                    lastName = {value=arguments.lastName, cfsqltype="cf_sql_varchar"}
                },
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "message": "Profile updated successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while updating profile",
                "error": e.message
            };
        }
    }

    remote struct function changePassword(
        required numeric userID,
        required string currentPassword,
        required string newPassword
    ) httpmethod="PUT" {
        init();
        
        try {
            if (NOT session.isLoggedIn OR session.userID NEQ arguments.userID) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }
            
            var qUser = queryExecute(
                "SELECT password FROM users WHERE userID = :userID",
                {userID = {value=arguments.userID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );
            
            if (qUser.recordCount AND hash(arguments.currentPassword) EQ qUser.password) {
                queryExecute(
                    "UPDATE users SET password = :password WHERE userID = :userID",
                    {
                        userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                        password = {value=hash(arguments.newPassword), cfsqltype="cf_sql_varchar"}
                    },
                    {datasource=application.datasource}
                );
                
                return {
                    "success": true,
                    "message": "Password changed successfully"
                };
            } else {
                return {
                    "success": false,
                    "message": "Current password is incorrect"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while changing password",
                "error": e.message
            };
        }
    }
} 