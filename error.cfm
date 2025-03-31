<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        .error-icon {
            font-size: 4rem;
            color: #dc3545;
            margin-bottom: 1.5rem;
        }
        .error-message {
            text-align: center;
            margin-bottom: 2rem;
        }
        .error-message h3 {
            margin-bottom: 1rem;
        }
        .error-details {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 0.5rem;
            padding: 1rem;
            margin: 1rem 0;
            font-size: 0.875rem;
            text-align: left;
            display: none;
        }
        .error-details.show {
            display: block;
        }
        .error-code {
            font-family: monospace;
            color: #dc3545;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!--- Error Content Side --->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Oops! Something went wrong</h2>
                    </div>
                    
                    <!--- Get error details --->
                    <cfset errorType = url.type ?: "general">
                    <cfset errorCode = url.code ?: "">
                    <cfset errorMessage = url.message ?: "">
                    
                    <div class="error-icon">
                        <i class="fas fa-exclamation-circle"></i>
                    </div>
                    
                    <div class="error-message">
                        <cfswitch expression="#errorType#">
                            <cfcase value="404">
                                <h3>Page Not Found</h3>
                                <p>The page you're looking for doesn't exist or has been moved.</p>
                            </cfcase>
                            
                            <cfcase value="403">
                                <h3>Access Denied</h3>
                                <p>You don't have permission to access this resource.</p>
                            </cfcase>
                            
                            <cfcase value="500">
                                <h3>Server Error</h3>
                                <p>We're experiencing some technical difficulties. Please try again later.</p>
                            </cfcase>
                            
                            <cfcase value="maintenance">
                                <h3>System Maintenance</h3>
                                <p>We're performing scheduled maintenance. Please check back soon.</p>
                            </cfcase>
                            
                            <cfdefaultcase>
                                <h3>An Error Occurred</h3>
                                <p>Something went wrong. Please try again or contact support if the problem persists.</p>
                            </cfdefaultcase>
                        </cfswitch>
                        
                        <!--- Show error details if available --->
                        <cfif len(errorCode) || len(errorMessage)>
                            <div class="error-details" id="errorDetails">
                                <cfif len(errorCode)>
                                    <p><strong>Error Code:</strong> <span class="error-code">#htmlEditFormat(errorCode)#</span></p>
                                </cfif>
                                <cfif len(errorMessage)>
                                    <p><strong>Error Message:</strong> #htmlEditFormat(errorMessage)#</p>
                                </cfif>
                            </div>
                            <button type="button" class="btn btn-link" onclick="toggleErrorDetails()">
                                Show Error Details
                            </button>
                        </cfif>
                    </div>
                    
                    <div class="text-center">
                        <a href="javascript:history.back();" class="btn btn-primary">
                            <i class="fas fa-arrow-left"></i> Go Back
                        </a>
                        <a href="dashboard.cfm" class="btn btn-outline-primary ml-2">
                            <i class="fas fa-home"></i> Dashboard
                        </a>
                    </div>
                </div>
            </div>
            
            <!--- Marketing Side --->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">We're Here to Help</h1>
                    <p class="lead-text">
                        Our support team is ready to assist you
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-headset"></i>
                            </div>
                            <h3>24/7 Support</h3>
                            <p>Expert assistance available</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-book"></i>
                            </div>
                            <h3>Documentation</h3>
                            <p>Comprehensive guides</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-comments"></i>
                            </div>
                            <h3>Community</h3>
                            <p>Connect with other users</p>
                        </div>
                    </div>
                    
                    <div class="next-steps">
                        <h3>Need Help?</h3>
                        <ul>
                            <li>Check our documentation</li>
                            <li>Contact support</li>
                            <li>Visit our community forum</li>
                            <li>Report a bug</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

<script src="assets/js/bootstrap.bundle.min.js"></script>
<script>
function toggleErrorDetails() {
    const details = document.getElementById('errorDetails');
    details.classList.toggle('show');
}
</script>
</body>
</html> 