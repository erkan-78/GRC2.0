<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Processing Password Reset - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
<cfoutput>
    <cfprocessingdirective suppresswhitespace="true">
        <!--- Initialize services --->
        <cfset variables.securityService = new SecurityService()>
        <cfset variables.userService = new UserService()>
        <cfset variables.emailService = new EmailService()>
        
        <!--- Get form data --->
        <cfset resetToken = form.token>
        <cfset password = form.password>
        <cfset confirmPassword = form.confirm_password>
        
        <!--- Validate passwords --->
        <cfif password neq confirmPassword>
            <cflocation url="password-reset.cfm?token=#resetToken#&error=password_mismatch" addtoken="false">
        </cfif>
        
        <!--- Validate password strength --->
        <cfif !variables.securityService.isPasswordStrong(password)>
            <cflocation url="password-reset.cfm?token=#resetToken#&error=password_weak" addtoken="false">
        </cfif>
        
        <!--- Verify token and get user --->
        <cfset user = variables.securityService.verifyResetToken(resetToken)>
        
        <!--- If token is valid, update password --->
        <cfif isStruct(user)>
            <!--- Update password --->
            <cfset variables.userService.updatePassword(user.userID, password)>
            
            <!--- Send confirmation email --->
            <cfset emailData = {
                to: user.email,
                subject: "Password Reset Successful - LightGRC",
                template: "password_reset_success",
                data: {
                    firstName: user.firstName,
                    lastName: user.lastName,
                    loginLink: application.config.baseURL & "/login.cfm"
                }
            }>
            
            <cfset variables.emailService.sendTemplatedEmail(emailData)>
            
            <!--- Redirect to success page --->
            <cflocation url="password-reset-success.cfm" addtoken="false">
        <cfelse>
            <!--- Invalid or expired token --->
            <cflocation url="forgot-password.cfm?error=invalid_token" addtoken="false">
        </cfif>
    </cfprocessingdirective>
</cfoutput>
</body>
</html> 