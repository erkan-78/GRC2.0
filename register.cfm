<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <link href="css/styles.css" rel="stylesheet">
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <h2>Create Account</h2>
            <form id="registerForm" onsubmit="submitRegistration(event)">
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" required class="form-control">
                </div>

                <div class="form-group">
                    <label for="firstName">First Name</label>
                    <input type="text" id="firstName" name="firstName" required class="form-control">
                </div>

                <div class="form-group">
                    <label for="lastName">Last Name</label>
                    <input type="text" id="lastName" name="lastName" required class="form-control">
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required class="form-control"
                           pattern="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$"
                           title="Password must be at least 8 characters long and include both letters and numbers">
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required class="form-control">
                </div>

                <div class="form-group">
                    <label for="companyID">Company ID</label>
                    <input type="text" id="companyID" name="companyID" required class="form-control"
                           pattern="[0-9]{1,9}"
                           title="Company ID must be a number with maximum 9 digits">
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Register</button>
                    <a href="login.cfm" class="btn btn-link">Already have an account? Login</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        async function submitRegistration(event) {
            event.preventDefault();
            
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                alert('Passwords do not match');
                return;
            }
            
            const formData = {
                email: document.getElementById('email').value,
                firstName: document.getElementById('firstName').value,
                lastName: document.getElementById('lastName').value,
                password: password,
                companyID: document.getElementById('companyID').value
            };
            
            try {
                const response = await fetch('api/auth.cfc?method=register', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(formData)
                });
                
                const data = await response.json();
                if (data.success) {
                    alert('Registration successful! Please login.');
                    window.location.href = 'login.cfm';
                } else {
                    alert(data.message);
                }
            } catch (error) {
                console.error('Error during registration:', error);
                alert('An error occurred during registration. Please try again.');
            }
        }
    </script>
</body>
</html> 