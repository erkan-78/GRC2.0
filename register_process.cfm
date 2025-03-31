<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Processing Registration - LightGRC</title>
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
        
        <!--- Get form data --->
        <cfset companyName = form.companyName>
        <cfset firstName = form.firstName>
        <cfset lastName = form.lastName>
        <cfset email = form.email>
        <cfset password = form.password>
        <cfset confirmPassword = form.confirm_password>
        
        <!--- Initialize error array --->
        <cfset errors = []>
        
        <!--- Validate required fields --->
        <cfif !len(trim(companyName))>
            <cfset arrayAppend(errors, "Company name is required")>
        </cfif>
        
        <cfif !len(trim(firstName))>
            <cfset arrayAppend(errors, "First name is required")>
        </cfif>
        
        <cfif !len(trim(lastName))>
            <cfset arrayAppend(errors, "Last name is required")>
        </cfif>
        
        <cfif !len(trim(email))>
            <cfset arrayAppend(errors, "Email is required")>
        <cfelseif !isValid("email", email)>
            <cfset arrayAppend(errors, "Invalid email format")>
        </cfif>
        
        <cfif !len(trim(password))>
            <cfset arrayAppend(errors, "Password is required")>
        <cfelseif !variables.securityService.isPasswordStrong(password)>
            <cfset arrayAppend(errors, "Password must be at least 8 characters long and contain numbers and letters")>
        </cfif>
        
        <cfif password neq confirmPassword>
            <cfset arrayAppend(errors, "Passwords do not match")>
        </cfif>
        
        <!--- If no validation errors, proceed with API call --->
        <cfif arrayLen(errors) eq 0>
            <!--- Prepare registration data --->
            <cfset registrationData = {
                companyName: companyName,
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            }>
            
            <!--- Make API call to register company --->
            <cfhttp url="#application.config.apiURL#/register" method="post" result="apiResponse">
                <cfhttpparam type="header" name="Content-Type" value="application/json">
                <cfhttpparam type="body" value="#serializeJSON(registrationData)#">
            </cfhttp>
            
            <!--- Parse API response --->
            <cfset responseData = deserializeJSON(apiResponse.fileContent)>
            
            <!--- Check API response --->
            <cfif responseData.success>
                <!--- Store success data in session --->
                <cfset session.registrationSuccess = {
                    email: email,
                    firstName: firstName
                }>
                
                <!--- Redirect to success page --->
                <cflocation url="register-success.cfm" addtoken="false">
            <cfelse>
                <!--- Add API errors to error array --->
                <cfif structKeyExists(responseData, "errors")>
                    <cfloop array="#responseData.errors#" index="error">
                        <cfset arrayAppend(errors, error)>
                    </cfloop>
                <cfelse>
                    <cfset arrayAppend(errors, "Registration failed. Please try again later.")>
                </cfif>
            </cfif>
        </cfif>
        
        <!--- If there are any errors, store them and redirect back --->
        <cfif arrayLen(errors)>
            <cfset session.registrationErrors = errors>
            <cfset session.registrationData = {
                companyName: companyName,
                firstName: firstName,
                lastName: lastName,
                email: email
            }>
            <cflocation url="register.cfm" addtoken="false">
        </cfif>
    </cfprocessingdirective>
</cfoutput>
</body>
</html> 