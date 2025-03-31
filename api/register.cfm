<!--- Set response type to JSON --->
<cfheader name="Content-Type" value="application/json">
 
<!--- Initialize services --->
<cfset variables.userService = new UserService()>
test2
<cfabort>
<cfset variables.companyService = new CompanyService()>
<cfset variables.emailService = new EmailService()>
<cfset variables.securityService = new SecurityService()>

<!--- Get request body --->
<cfset requestBody = deserializeJSON(cgi.content)>


<!--- Initialize response --->
<cfset response = {
    success: false,
    errors: []
}>

<!--- Validate required fields --->
<cfif !structKeyExists(requestBody, "companyName") || !len(trim(requestBody.companyName))>
    <cfset arrayAppend(response.errors, {
        field: "companyName",
        message: "Company name is required"
    })>
</cfif>

<cfif !structKeyExists(requestBody, "firstName") || !len(trim(requestBody.firstName))>
    <cfset arrayAppend(response.errors, {
        field: "firstName",
        message: "First name is required"
    })>
</cfif>

<cfif !structKeyExists(requestBody, "lastName") || !len(trim(requestBody.lastName))>
    <cfset arrayAppend(response.errors, {
        field: "lastName",
        message: "Last name is required"
    })>
</cfif>

<cfif !structKeyExists(requestBody, "email") || !len(trim(requestBody.email))>
    <cfset arrayAppend(response.errors, {
        field: "email",
        message: "Email is required"
    })>
<cfelseif !isValid("email", requestBody.email)>
    <cfset arrayAppend(response.errors, {
        field: "email",
        message: "Invalid email format"
    })>
</cfif>

<cfif !structKeyExists(requestBody, "password") || !len(trim(requestBody.password))>
    <cfset arrayAppend(response.errors, {
        field: "password",
        message: "Password is required"
    })>
<cfelseif !variables.securityService.isPasswordStrong(requestBody.password)>
    <cfset arrayAppend(response.errors, {
        field: "password",
        message: "Password must be at least 8 characters long and contain numbers and letters"
    })>
</cfif>

<!--- Check if email already exists --->
<cfif structKeyExists(requestBody, "email") && variables.userService.emailExists(requestBody.email)>
    <cfset arrayAppend(response.errors, {
        field: "email",
        message: "Email already registered"
    })>
</cfif>

<!--- Check if company name already exists --->
<cfif structKeyExists(requestBody, "companyName") && variables.companyService.companyNameExists(requestBody.companyName)>
    <cfset arrayAppend(response.errors, {
        field: "companyName",
        message: "Company name already registered"
    })>
</cfif>

<!--- If no validation errors, proceed with registration --->
<cfif arrayLen(response.errors) eq 0>
    <cftry>
        <!--- Create company --->
        <cfset company = variables.companyService.createCompany(
            name = requestBody.companyName,
            status = "pending"
        )>
        
        <!--- Create user --->
        <cfset user = variables.userService.createUser(
            companyID = company.companyID,
            firstName = requestBody.firstName,
            lastName = requestBody.lastName,
            email = requestBody.email,
            password = requestBody.password,
            role = "company.admin",
            status = "pending"
        )>

        <!--- Generate verification token --->
        <cfset verificationToken = variables.securityService.generateVerificationToken(user.userID)>
        
        <!--- Send welcome email --->
        <cfset emailData = {
            to: requestBody.email,
            subject: "Welcome to LightGRC - Verify Your Account",
            template: "welcome_email",
            data: {
                firstName: requestBody.firstName,
                lastName: requestBody.lastName,
                companyName: requestBody.companyName,
                verificationLink: application.config.baseURL & "/verify-email.cfm?token=" & verificationToken,
                expiryHours: 24
            }
        }>
        
        <cfset variables.emailService.sendTemplatedEmail(emailData)>
        
        <!--- Set success response --->
        <cfset response.success = true>
        
        <cfcatch type="any">
            <!--- Log the error --->
            <cflog file="registration" type="error" text="Registration error: #cfcatch.message#">
            
            <!--- Add error to response --->
            <cfset arrayAppend(response.errors, {
                field: "general",
                message: "Registration failed. Please try again later."
            })>
        </cfcatch>
    </cftry>
</cfif>

<!--- Output JSON response --->
<cfoutput>#serializeJSON(response)#</cfoutput> 