component {
    // Dependencies
    variables.userService = new UserService();
    variables.companyService = new CompanyService();
    variables.emailService = new EmailService();
    variables.securityService = new SecurityService();
    
    /**
     * Registers a new company and user
     * @companyName string Company name
     * @firstName string User's first name
     * @lastName string User's last name
     * @email string User's email address
     * @password string User's password
     * @return struct Response containing success status, message, and errors
     */
    public struct function register(required string companyName, required string firstName, 
                                  required string lastName, required string email, required string password) {
        var response = {
            success: false,
            message: "",
            errors: []
        };
        
        // Validate required fields
        if (!len(trim(arguments.companyName))) {
            arrayAppend(response.errors, "Company name is required");
        }
        if (!len(trim(arguments.firstName))) {
            arrayAppend(response.errors, "First name is required");
        }
        if (!len(trim(arguments.lastName))) {
            arrayAppend(response.errors, "Last name is required");
        }
        if (!len(trim(arguments.email))) {
            arrayAppend(response.errors, "Email is required");
        }
        if (!len(trim(arguments.password))) {
            arrayAppend(response.errors, "Password is required");
        }
        
        // If there are validation errors, return early
        if (arrayLen(response.errors)) {
            return response;
        }
        
        // Validate email format
        if (!isValid("email", arguments.email)) {
            arrayAppend(response.errors, "Invalid email format");
            return response;
        }
        
        // Validate password strength
        if (!variables.securityService.isPasswordStrong(arguments.password)) {
            arrayAppend(response.errors, "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character");
            return response;
        }
        
        // Check if email already exists
        if (variables.userService.emailExists(arguments.email)) {
            arrayAppend(response.errors, "Email address is already registered");
            return response;
        }
        
        // Check if company name already exists
        if (variables.companyService.companyNameExists(arguments.companyName)) {
            arrayAppend(response.errors, "Company name is already registered");
            return response;
        }
        
        // Create company
        try {
            var company = variables.companyService.createCompany({
                name: arguments.companyName,
                status: "pending"
            });
            
            // Create user
            var user = variables.userService.createUser({
                companyID: company.companyID,
                firstName: arguments.firstName,
                lastName: arguments.lastName,
                email: arguments.email,
                password: arguments.password,
                status: "pending"
            });
            
            // Generate verification token
            var token = variables.securityService.generateVerificationToken(user.userID);
            
            // Send welcome email with verification link
            variables.emailService.sendWelcomeEmail(user.email, token);
            
            response.success = true;
            response.message = "Registration successful. Please check your email to verify your account.";
            
        } catch (any e) {
            // Log the error
            log file="registration" type="error" text="Registration error: #e.message#";
            arrayAppend(response.errors, "An error occurred during registration. Please try again.");
        }
        
        return response;
    }
} 