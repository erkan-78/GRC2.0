<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        .password-requirements {
            font-size: 0.875rem;
            color: #6c757d;
            margin-top: 0.5rem;
        }
        .password-requirements ul {
            margin-bottom: 0;
            padding-left: 1.5rem;
        }
        .password-requirements li {
            margin-bottom: 0.25rem;
        }
        .password-requirements li.valid {
            color: #28a745;
        }
        .password-requirements li.invalid {
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!--- Password Change Side --->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Change Password</h2>
                    </div>
                    
                    <!--- Initialize services --->
                    <cfset variables.securityService = new SecurityService()>
                    <cfset variables.userService = new UserService()>
                    
                    <!--- Process password change --->
                    <cfif structKeyExists(form, "submit")>
                        <cftry>
                            <!--- Validate current password --->
                            <cfset user = variables.userService.getUserByID(session.userID)>
                            <cfif !variables.securityService.verifyPassword(form.currentPassword, user.password, user.passwordSalt)>
                                <cfset errorMessage = "Current password is incorrect">
                            <!--- Validate new password --->
                            <cfelseif !variables.securityService.isPasswordStrong(form.newPassword)>
                                <cfset errorMessage = "New password does not meet security requirements">
                            <!--- Check password match --->
                            <cfelseif form.newPassword neq form.confirmPassword>
                                <cfset errorMessage = "New passwords do not match">
                            <!--- Update password --->
                            <cfelse>
                                <cfset variables.userService.updatePassword(session.userID, form.newPassword)>
                                <cflocation url="dashboard.cfm?success=password_changed" addtoken="false">
                            </cfif>
                            
                            <cfcatch type="any">
                                <!--- Log the error --->
                                <cflog file="password_change" type="error" text="Password change error: #cfcatch.message#">
                                <cfset errorMessage = "An error occurred. Please try again.">
                            </cfcatch>
                        </cftry>
                    </cfif>
                    
                    <!--- Show error message if any --->
                    <cfif isDefined("errorMessage")>
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle"></i>
                            #htmlEditFormat(errorMessage)#
                        </div>
                    </cfif>
                    
                    <!--- Password Change Form --->
                    <form method="post" action="change-password.cfm" onsubmit="return validateForm()">
                        <div class="form-group">
                            <label for="currentPassword">Current Password</label>
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="newPassword">New Password</label>
                            <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                            <div class="password-requirements">
                                <p class="mb-1">Password must contain:</p>
                                <ul>
                                    <li id="length">At least 8 characters</li>
                                    <li id="uppercase">One uppercase letter</li>
                                    <li id="lowercase">One lowercase letter</li>
                                    <li id="number">One number</li>
                                    <li id="special">One special character</li>
                                </ul>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                        </div>
                        
                        <div class="form-group">
                            <button type="submit" name="submit" class="btn btn-primary w-100">
                                Change Password
                            </button>
                        </div>
                        
                        <div class="text-center">
                            <a href="dashboard.cfm" class="btn btn-link">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
            
            <!--- Marketing Side --->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Secure Your Account</h1>
                    <p class="lead-text">
                        Keep your account safe with a strong password
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3>Strong Security</h3>
                            <p>Enterprise-grade password protection</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-lock"></i>
                            </div>
                            <h3>Password Requirements</h3>
                            <p>Follow best practices for account security</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-user-shield"></i>
                            </div>
                            <h3>Account Protection</h3>
                            <p>Keep your data safe and secure</p>
                        </div>
                    </div>
                    
                    <div class="next-steps">
                        <h3>Security Tips</h3>
                        <ul>
                            <li>Use a unique password for each account</li>
                            <li>Never share your password with anyone</li>
                            <li>Change your password regularly</li>
                            <li>Enable two-factor authentication if available</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

<script src="assets/js/bootstrap.bundle.min.js"></script>
<script>
function validateForm() {
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    // Check password match
    if (newPassword !== confirmPassword) {
        alert('New passwords do not match');
        return false;
    }
    
    // Check password strength
    const requirements = {
        length: newPassword.length >= 8,
        uppercase: /[A-Z]/.test(newPassword),
        lowercase: /[a-z]/.test(newPassword),
        number: /[0-9]/.test(newPassword),
        special: /[^A-Za-z0-9]/.test(newPassword)
    };
    
    // Update requirement indicators
    for (const [requirement, isValid] of Object.entries(requirements)) {
        const element = document.getElementById(requirement);
        if (isValid) {
            element.classList.add('valid');
            element.classList.remove('invalid');
        } else {
            element.classList.add('invalid');
            element.classList.remove('valid');
        }
    }
    
    // Check if all requirements are met
    if (!Object.values(requirements).every(Boolean)) {
        alert('Please ensure all password requirements are met');
        return false;
    }
    
    return true;
}

// Real-time password validation
document.getElementById('newPassword').addEventListener('input', function() {
    const password = this.value;
    
    // Update requirement indicators
    document.getElementById('length').classList.toggle('valid', password.length >= 8);
    document.getElementById('uppercase').classList.toggle('valid', /[A-Z]/.test(password));
    document.getElementById('lowercase').classList.toggle('valid', /[a-z]/.test(password));
    document.getElementById('number').classList.toggle('valid', /[0-9]/.test(password));
    document.getElementById('special').classList.toggle('valid', /[^A-Za-z0-9]/.test(password));
});
</script>
</body>
</html> 