component {
    // Dependencies
    variables.securityService = new SecurityService();
    variables.userService = new api.user.index();
    variables.emailService = new EmailService();
    
    /**
     * Resends verification email with rate limiting
     * @email string The email address to resend verification to
     * @return struct Response containing success status, message, and errors
     */
    public struct function resendVerification(required string email) {
        var response = {
            success: false,
            message: "",
            errors: [],
            timeLimit: application.config.verificationResendLimit
        };
        
        // Validate email
        if (!len(trim(arguments.email))) {
            arrayAppend(response.errors, "Email is required");
            return response;
        }
        
        if (!isValid("email", arguments.email)) {
            arrayAppend(response.errors, "Invalid email format");
            return response;
        }
        
        // Get user by email
        var user = variables.userService.getUserByEmail(arguments.email);
        
        if (isNull(user)) {
            arrayAppend(response.errors, "Email not found");
            return response;
        }
        
        // Check if user is already verified
        if (user.status eq "active") {
            arrayAppend(response.errors, "Account is already verified");
            return response;
        }
        
        // Check last verification attempt time
        var lastAttempt = user.lastVerificationAttempt;
        var timeLimit = application.config.verificationResendLimit;
        
        if (!isNull(lastAttempt) && dateDiff("n", lastAttempt, now()) lt timeLimit) {
            var remainingMinutes = timeLimit - dateDiff("n", lastAttempt, now());
            arrayAppend(response.errors, "Please wait #remainingMinutes# minutes before requesting another verification email");
            return response;
        }
        
        // Generate new verification token
        var token = variables.securityService.generateVerificationToken(user.userID);
        
        // Update last verification attempt
        variables.userService.updateLastVerificationAttempt(user.userID);
        
        // Send verification email
        try {
            variables.emailService.sendVerificationEmail(user.email, token);
            response.success = true;
            response.message = "Verification email sent successfully";
        } catch (any e) {
            // Log the error
            log file="email_verification" type="error" text="Error sending verification email: #e.message#";
            arrayAppend(response.errors, "Failed to send verification email");
        }
        
        return response;
    }
    
    /**
     * Verifies a user's email token
     * @token string The verification token
     * @return struct Response containing success status and user information
     */
    public struct function verifyEmailToken(required string token) {
        var response = {
            success: false,
            message: "",
            user: null
        };
        
        // Validate token
        if (!len(trim(arguments.token))) {
            response.message = "Invalid verification link";
            return response;
        }
        
        // Verify token and get user
        var user = variables.securityService.verifyToken(arguments.token);
        
        if (isNull(user)) {
            response.message = "Invalid or expired verification link";
            return response;
        }
        
        // Update user status
        variables.userService.updateUserStatus(user.userID, "active");
        
        // Update company status
        variables.companyService.updateCompanyStatus(user.companyID, "active");
        
        response.success = true;
        response.message = "Email verified successfully";
        response.user = user;
        
        return response;
    }
} 