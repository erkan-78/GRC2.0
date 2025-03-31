<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
<cfoutput>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!-- Reset Form Side -->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Reset Password</h2>
                        <p class="text-muted">Enter your email to receive reset instructions</p>
                    </div>

                    <form action="password-reset-request.cfm" method="post" class="login-form">
                        <cfif structKeyExists(url, "success")>
                            <div class="alert alert-success">
                                If an account exists with this email, you will receive password reset instructions.
                            </div>
                        </cfif>
                        
                        <div class="form-group">
                            <label>Email</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-envelope"></i>
                                </span>
                                <input type="email" name="email" class="form-control" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary btn-block">Send Reset Instructions</button>
                        
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
                        We take your security seriously. Our password reset process ensures your account remains protected.
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3>Secure Process</h3>
                            <p>Two-step verification for password reset</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-clock"></i>
                            </div>
                            <h3>Time-Limited</h3>
                            <p>Reset links expire after 30 minutes</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <h3>Email Verification</h3>
                            <p>Secure email-based verification</p>
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