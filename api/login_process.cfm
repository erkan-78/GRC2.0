<!--- Initialize services --->
<cfset variables.userService = new api.user.index()>
<cfset variables.securityService = new api.SecurityService()>
<cfset requestBody = deserializeJSON(getHttpRequestData().content)>
<!--- Get form data --->
<cfset formData = {
    email = requestBody.email ?: "",
    password = requestBody.password ?: "",
    languageID = requestBody.languageID ?: "en-US"
}>
<!--- Validate input --->
<cfif !len(trim(formData.email)) || !len(trim(formData.password))>
    <cflocation url="/login.cfm?error=missing_fields" addtoken="false">
</cfif>

<!--- Validate email format --->
<cfif !isValid("email", formData.email)>
    <cflocation url="/login.cfm?error=invalid_email" addtoken="false">
</cfif>

 
<!--- Attempt login--->
<cftry> 
    <!--- Get user by email --->
   <cfset user = variables.userService.getUserByEmail(formData.email)>
    <!--- Check if user exists and is active --->
    <cfif !isNull(user) && user.data.statusId eq "cfcbdfa1-0fef-11f0-a0a5-02e353546665">
        <!--- Verify password --->   
        <cfset verifyPassword = variables.userService.verifyPassword(formData.email, formData.password)>
          <cfif verifyPassword.success>
            <!--- Set session variables --->
            <cfset session.userID = user.data.userID>
            <cfset session.companyID = user.data.companyID>
            <cfset session.email = user.data.email>
            <cfset session.firstName = user.data.firstName>
            <cfset session.lastName = user.data.lastName>
            <cfset session.role = user.data.role>
            <cfset session.languageID = formData.languageID>
            <cfset session.isLoggedIn = true>
       
            <!--- Update last login and language preference --->
            <cfset variables.userService.updateLastLogin(user.data.userID)>  
            <cfset variables.userService.updatePreferredLanguage(user.data.userID, formData.languageID)>
            
            <!--- Redirect to dashboard --->
            {
       "success": true,
       "message": "Login successful"}
        <cfelse>
            {
       "success": false,
       "message": "Please enter both email and password",
       "data": {}
   }
        </cfif>
    <cfelse>
           {
       "success": false,
       "message": "Please enter both email and password",
       "data": {}
   }
    </cfif>
    
    <cfcatch type="any">
        <!--- Log the error --->
        <cflog file="login" type="error" text="Login error: #cfcatch.message#">
          {
       "success": false,
       "message": "Please enter both email and password",
       "data": {}
   }
    </cfcatch>
</cftry>