<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    
    <link href="assets/css/base.css" rel="stylesheet">
    <style>
        body {
            background-color: #f1f3f4;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .register-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
            padding: 30px;
            width: 100%;
            max-width: 800px;
        }

        

        

        .action-row {
            text-align: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #dadce0;
        }

        .btn-register {
            background: #1a73e8;
            color: white;
            border: none;
            padding: 10px 30px;
            border-radius: 4px;
            font-weight: 500;
            cursor: pointer;
        }
    </style>
</head>
<body>
<div class="register-container">
    <div class="logo-text">Light<span class="highlight">GRC</span></div>
    
    <form action="register_process.cfm" method="post">
        <table class="register-table">
            <tr>
                <th>Company Name:</th>
                <td><input type="text" name="companyName" required></td>
            </tr>
            <tr>
                <th>Industry:</th>
                <td>
                    <select name="industry" required>
                        <option value="">Select Industry...</option>
                        <option value="finance">Financial Services</option>
                        <option value="healthcare">Healthcare</option>
                        <option value="technology">Technology</option>
                        <option value="manufacturing">Manufacturing</option>
                        <option value="retail">Retail</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th>Company Size:</th>
                <td>
                    <select name="companySize" required>
                        <option value="">Select Size...</option>
                        <option value="1-50">1-50 employees</option>
                        <option value="51-200">51-200 employees</option>
                        <option value="201-1000">201-1000 employees</option>
                        <option value="1000+">1000+ employees</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th>First Name:</th>
                <td><input type="text" name="firstName" required></td>
            </tr>
            <tr>
                <th>Last Name:</th>
                <td><input type="text" name="lastName" required></td>
            </tr>
            <tr>
                <th>Work Email:</th>
                <td><input type="email" name="email" required></td>
            </tr>
            <tr>
                <th>Phone:</th>
                <td><input type="tel" name="phone" required></td>
            </tr>
            <tr>
                <th>Password:</th>
                <td><input type="password" name="password" required></td>
            </tr>
            <tr>
                <th>Confirm Password:</th>
                <td><input type="password" name="confirmPassword" required></td>
            </tr>
            <tr>
                <th>Terms:</th>
                <td>
                    <input type="checkbox" id="terms" required> <label for="terms">I agree to the <a href="terms.cfm">Terms of Service</a> and <a href="privacy.cfm">Privacy Policy</a></label>
                </td>
            </tr>
        </table>

        <div class="action-row">
            <button type="submit" class="btn-register">Register Company</button>
            <div style="margin-top: 10px;">
                <a href="login.cfm" style="color: #1a73e8; text-decoration: none;">
                    Already have an account? Sign in
                </a>
            </div>
        </div>
    </form>
</div>

<script>
document.querySelector('form').addEventListener('submit', function(e) {
    const password = document.querySelector('input[name="password"]').value;
    const confirm = document.querySelector('input[name="confirmPassword"]').value;
    
    if (password !== confirm) {
        e.preventDefault();
        alert('Passwords do not match!');
    }
});
</script>
</body>
</html> 