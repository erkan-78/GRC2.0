<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verifying Password Reset - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
<cfoutput>
    <cfprocessingdirective suppresswhitespace="true">
        <!--- Initialize services --->
        <cfset variables.emailService = new EmailService()>
        <cfset variables.userService = new UserService()>
        <cfset variables.securityService = new SecurityService()>
        
        <!--- Get token from URL --->
        <cfset resetToken = url.token>
        
        <!--- Verify token and get user --->
        <cfset user = variables.securityService.verifyResetToken(resetToken)>
        
        <!--- If token is valid, generate new token and send second email --->
        <cfif isStruct(user)>
            <!--- Generate new reset token --->
            <cfset newResetToken = variables.securityService.generateResetToken(user.userID)>
            
            <!--- Prepare email data --->
            <cfset emailData = {
                to: user.email,
                subject: "Password Reset Verification - LightGRC",
                template: "password_reset_verify",
                data: {
                    firstName: user.firstName,
                    lastName: user.lastName,
                    resetLink: application.config.baseURL & "/password-reset.cfm?token=" & newResetToken,
                    expiryMinutes: 30
                }
            }>
            
            <!--- Send email --->
            <cfset variables.emailService.sendTemplatedEmail(emailData)>
            
            <!--- Redirect to success page --->
            <cflocation url="password-reset-sent.cfm" addtoken="false">
        <cfelse>
            <!--- Invalid or expired token --->
            <cflocation url="forgot-password.cfm?error=invalid_token" addtoken="false">
        </cfif>
    </cfprocessingdirective>
</cfoutput>
</body>
</html> 