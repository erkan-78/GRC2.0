<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Email - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        .verification-icon {
            font-size: 4rem;
            margin-bottom: 1.5rem;
        }
        .verification-icon.success {
            color: #28a745;
        }
        .verification-icon.error {
            color: #dc3545;
        }
        .verification-message {
            text-align: center;
            margin-bottom: 2rem;
        }
        .verification-message h3 {
            margin-bottom: 1rem;
        }
        .action-buttons {
            margin-top: 2rem;
        }
        .resend-timer {
            font-size: 0.875rem;
            color: #6c757d;
            margin-top: 1rem;
        }
    </style>
</head>
<body>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!--- Verification Content Side --->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Email Verification</h2>
                    </div>
                    
                    <!--- Initialize services --->
                    <cfset variables.securityService = new SecurityService()>
                    <cfset variables.userService = new UserService()>
                    <cfset variables.companyService = new CompanyService()>
                    
                    <!--- Get verification token --->
                    <cfset token = url.token ?: "">
                    
                    <!--- Verify token --->
                    <cftry>
                        <cfset verificationResult = variables.securityService.verifyToken(token)>
                        
                        <cfif !isNull(verificationResult)>
                            <!--- Update user and company status --->
                            <cfset variables.userService.updateUserStatus(verificationResult.userID, "active")>
                            <cfset variables.companyService.updateCompanyStatus(verificationResult.companyID, "active")>
                            
                            <!--- Show success message --->
                            <div class="verification-icon success">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="verification-message">
                                <h3>Email Verified Successfully!</h3>
                                <p>Your email has been verified. You can now log in to your account.</p>
                            </div>
                            <div class="action-buttons">
                                <a href="login.cfm" class="btn btn-primary">Log In</a>
                            </div>
                        <cfelse>
                            <!--- Show error message --->
                            <div class="verification-icon error">
                                <i class="fas fa-exclamation-circle"></i>
                            </div>
                            <div class="verification-message">
                                <h3>Verification Failed</h3>
                                <p>The verification link is invalid or has expired.</p>
                                <p>Please request a new verification email.</p>
                            </div>
                            <div class="action-buttons">
                                <button type="button" class="btn btn-primary" onclick="resendVerification()" id="resendButton">
                                    Resend Verification Email
                                </button>
                                <div class="resend-timer" id="resendTimer"></div>
                                <a href="login.cfm" class="btn btn-outline-primary mt-3">Return to Login</a>
                            </div>
                        </cfif>
                        
                        <cfcatch type="any">
                            <!--- Log the error --->
                            <cflog file="email_verification" type="error" text="Verification error: #cfcatch.message#">
                            
                            <!--- Show error message --->
                            <div class="verification-icon error">
                                <i class="fas fa-exclamation-circle"></i>
                            </div>
                            <div class="verification-message">
                                <h3>Verification Error</h3>
                                <p>An error occurred during verification. Please try again later.</p>
                            </div>
                            <div class="action-buttons">
                                <a href="login.cfm" class="btn btn-primary">Return to Login</a>
                            </div>
                        </cfcatch>
                    </cftry>
                </div>
            </div>
            
            <!--- Marketing Side --->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Welcome to LightGRC</h1>
                    <p class="lead-text">
                        Your journey to better governance, risk management, and compliance starts here
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
                            <li>Verify your email</li>
                            <li>Complete your company profile</li>
                            <li>Start using LightGRC</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>

<script src="assets/js/bootstrap.bundle.min.js"></script>
<script>
function resendVerification() {
    const button = document.getElementById('resendButton');
    const timer = document.getElementById('resendTimer');
    
    // Disable button and show loading state
    button.disabled = true;
    button.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Sending...';
    
    // Make API call
    fetch('/api/resend-verification.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            email: '#jsStringFormat(verificationResult.email)#'
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Show success message
            button.innerHTML = 'Email Sent!';
            button.classList.remove('btn-primary');
            button.classList.add('btn-success');
            
            // Start countdown timer
            let timeLeft = data.timeLimit;
            timer.textContent = `Please wait ${timeLeft} minutes before requesting another email.`;
            
            const countdown = setInterval(() => {
                timeLeft--;
                if (timeLeft <= 0) {
                    clearInterval(countdown);
                    button.disabled = false;
                    button.innerHTML = 'Resend Verification Email';
                    button.classList.remove('btn-success');
                    button.classList.add('btn-primary');
                    timer.textContent = '';
                } else {
                    timer.textContent = `Please wait ${timeLeft} minutes before requesting another email.`;
                }
            }, 60000);
        } else {
            // Show error message
            button.disabled = false;
            button.innerHTML = 'Resend Verification Email';
            alert(data.errors[0]);
        }
    })
    .catch(error => {
        // Show error message
        button.disabled = false;
        button.innerHTML = 'Resend Verification Email';
        alert('An error occurred. Please try again.');
    });
}
</script>
</body>
</html> 