<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
<cfoutput>
    <cfprocessingdirective suppresswhitespace="true">
        <!--- Initialize services --->
        <cfset variables.securityService = new SecurityService()>
        <cfset variables.userService = new api.user.index()>
        
        <!--- Get token from URL --->
        <cfset resetToken = url.token>
        
        <!--- Verify token and get user --->
        <cfset user = variables.securityService.verifyResetToken(resetToken)>
        
        <!--- If token is invalid or expired, redirect --->
        <cfif !isStruct(user)>
            <cflocation url="forgot-password.cfm?error=invalid_token" addtoken="false">
        </cfif>
    </cfprocessingdirective>

    <div class="container-fluid h-100">
        <div class="row h-100">
            <!-- Reset Form Side -->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Set New Password</h2>
                        <p class="text-muted">Please enter your new password</p>
                    </div>

                    <form action="password-reset-process.cfm" method="post" class="login-form">
                        <input type="hidden" name="token" value="#resetToken#">
                        
                        <cfif structKeyExists(url, "error")>
                            <div class="alert alert-danger">
                                <cfswitch expression="#url.error#">
                                    <cfcase value="password_mismatch">
                                        Passwords do not match. Please try again.
                                    </cfcase>
                                    <cfcase value="password_weak">
                                        Password must be at least 8 characters long and contain numbers and letters.
                                    </cfcase>
                                    <cfdefaultcase>
                                        An error occurred. Please try again.
                                    </cfdefaultcase>
                                </cfswitch>
                            </div>
                        </cfif>
                        
                        <div class="form-group">
                            <label>New Password</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-lock"></i>
                                </span>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                            <small class="form-text text-muted">
                                Password must be at least 8 characters long and contain numbers and letters.
                            </small>
                        </div>

                        <div class="form-group">
                            <label>Confirm Password</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-lock"></i>
                                </span>
                                <input type="password" name="confirm_password" class="form-control" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary btn-block">Reset Password</button>
                        
                        <div class="auth-links">
                            <a href="login.cfm" class="back-link">Back to Login</a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Marketing Side -->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Secure Password Reset</h1>
                    <p class="lead-text">
                        Choose a strong password to protect your account. 
                        We recommend using a unique password that you haven't used elsewhere.
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3>Strong Password</h3>
                            <p>Use a mix of letters, numbers, and symbols</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-user-shield"></i>
                            </div>
                            <h3>Account Security</h3>
                            <p>Protect your sensitive information</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-lock"></i>
                            </div>
                            <h3>Secure Access</h3>
                            <p>Keep your account protected</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfoutput>

<script src="assets/js/bootstrap.bundle.min.js"></script>
</body>
</html> 