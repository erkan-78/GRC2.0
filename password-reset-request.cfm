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
        <cfset variables.emailService = new EmailService()>
        <cfset variables.userService = new UserService()>
        <cfset variables.securityService = new SecurityService()>
        
        <!--- Get email from form --->
        <cfset email = form.email>
        
        <!--- Check if user exists --->
        <cfset user = variables.userService.getUserByEmail(email)>
        
        <!--- If user exists, generate reset token and send email --->
        <cfif isStruct(user)>
            <!--- Generate reset token --->
            <cfset resetToken = variables.securityService.generateResetToken(user.userID)>
            
            <!--- Prepare email data --->
            <cfset emailData = {
                to: user.email,
                subject: "Password Reset Request - LightGRC",
                template: "password_reset_request",
                data: {
                    firstName: user.firstName,
                    lastName: user.lastName,
                    resetLink: application.config.baseURL & "/password-reset-verify.cfm?token=" & resetToken,
                    expiryMinutes: 30
                }
            }>
            
            <!--- Send email --->
            <cfset variables.emailService.sendTemplatedEmail(emailData)>
        </cfif>
        
        <!--- Redirect back to forgot password page with success message --->
        <cflocation url="forgot-password.cfm?success=1" addtoken="false">
    </cfprocessingdirective>
</cfoutput>
</body>
</html> 