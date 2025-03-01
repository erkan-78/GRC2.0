<!DOCTYPE html>
<html>
<head>
    <title>Reset Password</title>
    <link href="css/styles.css" rel="stylesheet">
</head>
<body>
    <h2>Reset Password</h2>
    <form id="resetPasswordForm">
        <div>
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
        </div>
        <div>
            <label for="newPassword">New Password:</label>
            <input type="password" id="newPassword" name="newPassword" required>
        </div>
        <div>
            <label for="confirmPassword">Confirm Password:</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required>
        </div>
        <button type="button" onclick="resetPassword()">Reset Password</button>
    </form>

    <script>
        function resetPassword() {
            const formData = {
                email: document.getElementById('email').value,
                newPassword: document.getElementById('newPassword').value,
                confirmPassword: document.getElementById('confirmPassword').value
            };

            fetch('../api/auth.cfc?method=resetPassword', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Password reset successfully');
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error resetting password:', error);
            });
        }
    </script>
</body>
</html>