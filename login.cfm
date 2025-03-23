<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Intelligent Governance, Risk & Compliance</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
<cfoutput>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!-- Login Side -->
            <div class="col-lg-4 login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-logo">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Welcome Back</h2>
                        <p class="text-muted">Access your GRC workspace</p>
                    </div>

                    <form action="login_process.cfm" method="post" class="login-form">
                        <cfif structKeyExists(url, "error")>
                            <div class="alert alert-danger">
                                Invalid credentials. Please try again.
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

                        <div class="form-group">
                            <label>Password</label>
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-lock"></i>
                                </span>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                        </div>

                        <div class="form-check mb-3">
                            <input type="checkbox" class="form-check-input" id="remember">
                            <label class="form-check-label" for="remember">Remember me</label>
                        </div>

                        <button type="submit" class="btn btn-primary btn-block">Sign In</button>
                        
                        <div class="auth-links">
                            <a href="forgot-password.cfm" class="forgot-link">Forgot your password?</a>
                            <div class="register-link">
                                New to LightGRC? 
                                <a href="register.cfm" class="btn btn-outline-primary">Register Your Company</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Marketing Side -->
            <div class="col-lg-8 marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Illuminate Your GRC Journey</h1>
                    <p class="lead-text">
                        LightGRC brings clarity and efficiency to governance, risk, and compliance with 
                        AI-powered insights and automation
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-lightbulb"></i>
                            </div>
                            <h3>Intelligent Insights</h3>
                            <p>AI-driven risk analysis and predictive controls</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-bolt"></i>
                            </div>
                            <h3>Swift Compliance</h3>
                            <p>Automated assessments and real-time monitoring</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h3>Enhanced Security</h3>
                            <p>Built-in controls and security frameworks</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-chart-line"></i>
                            </div>
                            <h3>Clear Visibility</h3>
                            <p>Comprehensive dashboards and reporting</p>
                        </div>
                    </div>

                    <div class="trust-section">
                        <div class="trust-badges">
                            <div class="badge-item">
                                <span class="number">99.9%</span>
                                <span class="label">Uptime</span>
                            </div>
                            <div class="badge-item">
                                <span class="number">500+</span>
                                <span class="label">Enterprise Clients</span>
                            </div>
                            <div class="badge-item">
                                <span class="number">24/7</span>
                                <span class="label">Support</span>
                            </div>
                        </div>
                        <div class="certification-badges">
                            <img src="assets/images/iso-27001.png" alt="ISO 27001" class="cert-badge">
                            <img src="assets/images/soc2.png" alt="SOC 2" class="cert-badge">
                            <img src="assets/images/gdpr.png" alt="GDPR Compliant" class="cert-badge">
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