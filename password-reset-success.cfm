<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Successful - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
<cfoutput>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!-- Success Message Side -->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Password Reset Successful</h2>
                        <p class="text-muted">Your password has been updated</p>
                    </div>

                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i>
                        Your password has been successfully reset. 
                        You can now log in with your new password.
                    </div>

                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i>
                        A confirmation email has been sent to your email address.
                    </div>

                    <div class="auth-links">
                        <a href="login.cfm" class="btn btn-primary btn-block">Log In</a>
                    </div>
                </div>
            </div>

            <!-- Marketing Side -->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Password Reset Complete</h1>
                    <p class="lead-text">
                        Your account security has been restored. 
                        You can now access your account with your new password.
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <h3>Password Updated</h3>
                            <p>Your new password is now active</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <h3>Email Confirmation</h3>
                            <p>Check your email for confirmation</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3>Secure Access</h3>
                            <p>Your account is now protected</p>
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