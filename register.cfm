<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        .form-control.is-invalid {
            border-color: #dc3545;
            padding-right: calc(1.5em + 0.75rem);
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linecap='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }
        .invalid-feedback {
            display: none;
            width: 100%;
            margin-top: 0.25rem;
            font-size: 0.875em;
            color: #dc3545;
        }
        .form-control.is-invalid ~ .invalid-feedback {
            display: block;
        }
        .password-requirements {
            font-size: 0.875rem;
            color: #6c757d;
            margin-top: 0.25rem;
        }
        .success-message {
            display: none;
            text-align: center;
            padding: 2rem;
        }
        .success-message.show {
            display: block;
        }
        .form-container {
            display: block;
        }
        .form-container.hide {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!--- Registration Form Side --->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Create Your Account</h2>
                    </div>
                    
                    <!--- Success Message --->
                    <div class="success-message" id="successMessage">
                        <div class="verification-icon success">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="verification-message">
                            <h3>Registration Successful!</h3>
                            <p id="successText"></p>
                        </div>
                        <div class="action-buttons">
                            <a href="login.cfm" class="btn btn-primary">Log In</a>
                        </div>
                    </div>
                    
                    <!--- Registration Form --->
                    <div class="form-container" id="registrationForm">
                        <form id="registerForm" onsubmit="return handleSubmit(event)">
                            <div class="mb-3">
                                <label for="companyName" class="form-label">Company Name</label>
                                <input type="text" class="form-control" id="companyName" name="companyName" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="firstName" class="form-label">First Name</label>
                                <input type="text" class="form-control" id="firstName" name="firstName" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="lastName" class="form-label">Last Name</label>
                                <input type="text" class="form-control" id="lastName" name="lastName" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="email" class="form-label">Email Address</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                                <div class="password-requirements">
                                    Password must be at least 8 characters long and contain:
                                    <ul>
                                        <li>At least one uppercase letter</li>
                                        <li>At least one lowercase letter</li>
                                        <li>At least one number</li>
                                        <li>At least one special character</li>
                                    </ul>
                                </div>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="confirmPassword" class="form-label">Confirm Password</label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                                <div class="invalid-feedback"></div>
                            </div>
                            
                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="terms" name="terms" required>
                                <label class="form-check-label" for="terms">
                                    I agree to the <a href="terms.cfm" target="_blank">Terms of Service</a> and <a href="privacy.cfm" target="_blank">Privacy Policy</a>
                                </label>
                                <div class="invalid-feedback">You must agree to the terms and conditions</div>
                            </div>
                            
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary" id="submitButton">
                                    Create Account
                                </button>
                            </div>
                        </form>
                        
                        <div class="text-center mt-4">
                            <p>Already have an account? <a href="login.cfm">Log in</a></p>
                        </div>
                    </div>
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
                            <li>Create your account</li>
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
function handleSubmit(event) {
    event.preventDefault();
    
    // Reset form state
    resetForm();
    
    // Get form data
    const formData = {
        companyName: document.getElementById('companyName').value,
        firstName: document.getElementById('firstName').value,
        lastName: document.getElementById('lastName').value,
        email: document.getElementById('email').value,
        password: document.getElementById('password').value
    };
    
    // Validate passwords match
    if (formData.password !== document.getElementById('confirmPassword').value) {
        showError('confirmPassword', 'Passwords do not match');
        return false;
    }
    
    // Validate terms acceptance
    if (!document.getElementById('terms').checked) {
        showError('terms', 'You must agree to the terms and conditions');
        return false;
    }
    
    // Disable submit button and show loading state
    const submitButton = document.getElementById('submitButton');
    submitButton.disabled = true;
    submitButton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Creating Account...';
    
    // Make API call
    fetch('/api/register.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Show success message
            document.getElementById('successText').textContent = data.message;
            document.getElementById('successMessage').classList.add('show');
            document.getElementById('registrationForm').classList.add('hide');
        } else {
            // Show errors
            data.errors.forEach(error => {
                // Try to match error to specific field
                if (error.toLowerCase().includes('company name')) {
                    showError('companyName', error);
                } else if (error.toLowerCase().includes('first name')) {
                    showError('firstName', error);
                } else if (error.toLowerCase().includes('last name')) {
                    showError('lastName', error);
                } else if (error.toLowerCase().includes('email')) {
                    showError('email', error);
                } else if (error.toLowerCase().includes('password')) {
                    showError('password', error);
                } else {
                    // Show general error at the top
                    const alert = document.createElement('div');
                    alert.className = 'alert alert-danger mt-3';
                    alert.innerHTML = error;
                    document.getElementById('registerForm').insertBefore(alert, document.getElementById('registerForm').firstChild);
                    setTimeout(() => alert.remove(), 5000);
                }
            });
            
            // Reset button
            submitButton.disabled = false;
            submitButton.innerHTML = 'Create Account';
        }
    })
    .catch(error => {
        // Show error message
        const alert = document.createElement('div');
        alert.className = 'alert alert-danger mt-3';
        alert.innerHTML = 'An error occurred. Please try again.';
        document.getElementById('registerForm').insertBefore(alert, document.getElementById('registerForm').firstChild);
        
        // Reset button
        submitButton.disabled = false;
        submitButton.innerHTML = 'Create Account';
        
        // Remove alert after 5 seconds
        setTimeout(() => alert.remove(), 5000);
    });
    
    return false;
}

function showError(fieldId, message) {
    const field = document.getElementById(fieldId);
    const feedback = field.nextElementSibling;
    
    field.classList.add('is-invalid');
    feedback.textContent = message;
}

function resetForm() {
    // Remove all error states
    document.querySelectorAll('.is-invalid').forEach(field => {
        field.classList.remove('is-invalid');
    });
    
    // Remove all alerts
    document.querySelectorAll('.alert').forEach(alert => {
        alert.remove();
    });
}
</script>
</body>
</html> 