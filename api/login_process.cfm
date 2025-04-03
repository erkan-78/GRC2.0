<!--- Initialize services --->
<cfset variables.userService = new api.UserService()>
<cfset variables.securityService = new api.SecurityService()>

<!--- Get form data --->
<cfset formData = {
    email = form.email ?: "",
    password = form.password ?: "",
    languageID = form.languageID ?: "en-US"
}>

<!--- Validate input --->
<cfif !len(trim(formData.email)) || !len(trim(formData.password))>
    <cflocation url="login.cfm?error=missing_fields" addtoken="false">
</cfif>

<!--- Validate email format --->
<cfif !isValid("email", formData.email)>
    <cflocation url="login.cfm?error=invalid_email" addtoken="false">
</cfif>

<!--- Attempt login --->
<cftry>
    <!--- Get user by email --->
    <cfset user = variables.userService.getUserByEmail(formData.email)>
    
    <!--- Check if user exists and is active --->
    <cfif !isNull(user) && user.status eq "active">
        <!--- Verify password --->
        <cfif variables.securityService.verifyPassword(formData.password, user.password, user.passwordSalt)>
            <!--- Set session variables --->
            <cfset session.userID = user.userID>
            <cfset session.companyID = user.companyID>
            <cfset session.email = user.email>
            <cfset session.firstName = user.firstName>
            <cfset session.lastName = user.lastName>
            <cfset session.role = user.role>
            <cfset session.languageID = formData.languageID>
            
            <!--- Update last login and language preference --->
            <cfset variables.userService.updateLastLogin(user.userID)>
            <cfset variables.userService.updateLanguagePreference(user.userID, formData.languageID)>
            
            <!--- Redirect to dashboard --->
            <cflocation url="dashboard.cfm" addtoken="false">
        <cfelse>
            <cflocation url="login.cfm?error=invalid_credentials" addtoken="false">
        </cfif>
    <cfelse>
        <cflocation url="login.cfm?error=invalid_credentials" addtoken="false">
    </cfif>
    
    <cfcatch type="any">
        <!--- Log the error --->
        <cflog file="login" type="error" text="Login error: #cfcatch.message#">
        <cflocation url="login.cfm?error=system_error" addtoken="false">
    </cfcatch>
</cftry> 