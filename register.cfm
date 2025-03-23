<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register Your Company - GRC Platform</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/register.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="registration-card">
            <div class="registration-header">
                <img src="assets/images/logo.png" alt="GRC Platform Logo" class="register-logo">
                <h2>Register Your Company</h2>
                <p>Join the leading GRC platform for enterprises</p>
            </div>

            <form action="register_process.cfm" method="post" class="registration-form">
                <div class="row">
                    <div class="col-md-6">
                        <h4>Company Information</h4>
                        <div class="form-group">
                            <label>Company Name</label>
                            <input type="text" name="companyName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Industry</label>
                            <select name="industry" class="form-control" required>
                                <option value="">Select Industry...</option>
                                <option value="finance">Financial Services</option>
                                <option value="healthcare">Healthcare</option>
                                <option value="technology">Technology</option>
                                <option value="manufacturing">Manufacturing</option>
                                <option value="retail">Retail</option>
                                <option value="other">Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Company Size</label>
                            <select name="companySize" class="form-control" required>
                                <option value="">Select Size...</option>
                                <option value="1-50">1-50 employees</option>
                                <option value="51-200">51-200 employees</option>
                                <option value="201-1000">201-1000 employees</option>
                                <option value="1000+">1000+ employees</option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <h4>Admin Account</h4>
                        <div class="form-group">
                            <label>First Name</label>
                            <input type="text" name="firstName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Last Name</label>
                            <input type="text" name="lastName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Work Email</label>
                            <input type="email" name="email" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Phone</label>
                            <input type="tel" name="phone" class="form-control" required>
                        </div>
                    </div>
                </div>

                <div class="form-group terms-section">
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input" id="terms" required>
                        <label class="form-check-label" for="terms">
                            I agree to the <a href="terms.cfm">Terms of Service</a> and 
                            <a href="privacy.cfm">Privacy Policy</a>
                        </label>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-block">Register Company</button>
                
                <div class="login-link">
                    Already have an account? <a href="login.cfm">Sign in</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html> 