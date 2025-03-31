<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration Success - LightGRC</title>
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
                        <h2>Registration Successful!</h2>
                        <p class="text-muted">Thank you for joining LightGRC</p>
                    </div>

                    <div class="success-message">
                        <div class="success-icon">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <h3>Check Your Email</h3>
                        <p>
                            We've sent a verification link to your email address. 
                            Please check your inbox and click the link to verify your account.
                        </p>
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle"></i>
                            The verification link will expire in 24 hours.
                        </div>
                        <div class="mt-4">
                            <p>Didn't receive the email?</p>
                            <button type="button" class="btn btn-outline-primary" onclick="resendVerification()">
                                Resend Verification Email
                            </button>
                        </div>
                        <div class="mt-4">
                            <a href="login.cfm" class="btn btn-link">Return to Login</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Marketing Side -->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Welcome to LightGRC</h1>
                    <p class="lead-text">
                        You're one step away from transforming your GRC processes with 
                        intelligent automation and powerful insights
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3>Secure Setup</h3>
                            <p>Enterprise-grade security from day one</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-rocket"></i>
                            </div>
                            <h3>Quick Start</h3>
                            <p>Get up and running in minutes</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-headset"></i>
                            </div>
                            <h3>24/7 Support</h3>
                            <p>Expert assistance when you need it</p>
                        </div>
                    </div>

                    <div class="next-steps">
                        <h3>Next Steps</h3>
                        <ol>
                            <li>Check your email for the verification link</li>
                            <li>Click the link to verify your account</li>
                            <li>Complete your company profile</li>
                            <li>Start using LightGRC</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfoutput>

<script src="assets/js/bootstrap.bundle.min.js"></script>
<script>
function resendVerification() {
    // TODO: Implement resend verification functionality
    alert('Verification email resent! Please check your inbox.');
}
</script>
</body>
</html> 