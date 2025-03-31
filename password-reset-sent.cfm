<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Email Sent - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
<cfoutput>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!-- Message Side -->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Check Your Email</h2>
                        <p class="text-muted">We've sent you a password reset link</p>
                    </div>

                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i>
                        A password reset link has been sent to your email address. 
                        Please check your inbox and follow the instructions to reset your password.
                    </div>

                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i>
                        The reset link will expire in 30 minutes for security reasons.
                    </div>

                    <div class="auth-links">
                        <a href="login.cfm" class="btn btn-primary btn-block">Back to Login</a>
                        <a href="forgot-password.cfm" class="btn btn-outline-primary btn-block">Request New Link</a>
                    </div>
                </div>
            </div>

            <!-- Marketing Side -->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Secure Password Reset</h1>
                    <p class="lead-text">
                        We've sent you a secure link to reset your password. 
                        This link will expire in 30 minutes for your security.
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <h3>Check Your Email</h3>
                            <p>Look for an email from LightGRC</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-clock"></i>
                            </div>
                            <h3>Time Limited</h3>
                            <p>Link expires in 30 minutes</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3>Secure Process</h3>
                            <p>Two-step verification</p>
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