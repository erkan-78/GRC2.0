<!--- Set content type to JSON --->
<cfcontent type="application/json">

<!--- Initialize response structure --->
<cfset response = {
    "success": false,
    "message": "",
    "data": {}
}>

<!--- Check if form was submitted --->
<cfif structKeyExists(form, "email") and structKeyExists(form, "password")>
    <!--- Validate required fields --->
    <cfif len(trim(form.email)) eq 0 or len(trim(form.password)) eq 0>
        <cfset response.message = "Please enter both email and password">
    <cfelse>
        <!--- Initialize user service --->
        <cfset userService = new api.user.index()>
        
        <!--- Verify password and get user data --->
        <cfset result = userService.verifyPassword(form.email, form.password)>
        
        <!--- Check if verification was successful --->
        <cfif result.success>
            <!--- Update last login and preferred language if provided --->
            <cfset userService.updateLastLogin(result.data.userID)>
            <cfif structKeyExists(url, "languageID")>
                <cfset userService.updatePreferredLanguage(result.data.userID, url.languageID)>
            </cfif>
            
            <!--- Set session variables --->
            <cfset session.userID = result.data.userID>
            <cfset session.companyID = result.data.companyID>
            <cfset session.email = result.data.email>
            <cfset session.firstName = result.data.firstName>
            <cfset session.lastName = result.data.lastName>
            <cfset session.role = result.data.role>
            
            <!--- Set success response --->
            <cfset response.success = true>
            <cfset response.message = "Login successful">
            <cfset response.data = {
                "userID": result.data.userID,
                "companyID": result.data.companyID,
                "email": result.data.email,
                "firstName": result.data.firstName,
                "lastName": result.data.lastName,
                "role": result.data.role
            }>
        <cfelse>
            <!--- Set error response --->
            <cfset response.message = result.message>
        </cfif>
    </cfif>
<cfelse>
    <cfset response.message = "Invalid request">
</cfif>

<!--- Return JSON response --->
<cfoutput>#serializeJSON(response)#</cfoutput> 