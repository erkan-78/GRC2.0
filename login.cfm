<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link href="css/styles.css" rel="stylesheet">
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <h2>Login</h2>
            <form id="loginForm" onsubmit="submitLogin(event)">
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" required class="form-control" onchange="checkSSOAvailability()">
                </div>

                <div id="passwordSection" class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control">
                </div>

                <div id="ssoSection" style="display: none;" class="form-group text-center">
                    <p class="sso-message">SSO is available for your organization</p>
                    <button type="button" onclick="initiateSSO()" class="btn btn-secondary">Continue with SSO</button>
                    <hr>
                    <p class="small">or use password below</p>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Login</button>
                    <a href="register.cfm" class="btn btn-link">Need an account? Register</a>
                    <a href="company-application.cfm" class="btn btn-link">Register your company</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        async function checkSSOAvailability() {
            const email = document.getElementById('email').value;
            if (!email) return;

            try {
                const response = await fetch('api/sso.cfc?method=initiateSSOLogin', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ email: email })
                });
                
                const data = await response.json();
                const ssoSection = document.getElementById('ssoSection');
                const passwordSection = document.getElementById('passwordSection');
                const password = document.getElementById('password');

                if (data.success) {
                    ssoSection.style.display = 'block';
                    password.required = false;
                } else {
                    ssoSection.style.display = 'none';
                    password.required = true;
                }
            } catch (error) {
                console.error('Error checking SSO availability:', error);
            }
        }

        async function initiateSSO() {
            const email = document.getElementById('email').value;
            
            try {
                const response = await fetch('api/sso.cfc?method=initiateSSOLogin', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ email: email })
                });
                
                const data = await response.json();
                if (data.success) {
                    window.location.href = data.data.redirectURL;
                } else {
                    alert(data.message);
                }
            } catch (error) {
                console.error('Error initiating SSO:', error);
                alert('An error occurred while initiating SSO. Please try again.');
            }
        }

        async function submitLogin(event) {
            event.preventDefault();
            
            const formData = {
                email: document.getElementById('email').value,
                password: document.getElementById('password').value
            };
            
            try {
                const response = await fetch('api/auth.cfc?method=login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(formData)
                });
                
                const data = await response.json();
                if (data.success) {
                    window.location.href = 'dashboard.cfm';
                } else {
                    alert(data.message);
                }
            } catch (error) {
                console.error('Error during login:', error);
                alert('An error occurred during login. Please try again.');
            }
        }
    </script>
</body>
</html> 