<!--- Set response type to JSON --->
<cfcontent type="application/json">

<!--- Initialize service --->
<cfset variables.verificationService = new VerificationService()>

<!--- Get request body --->
<cfset requestBody = deserializeJSON(cgi.input)>

<!--- Process verification request --->
<cfset response = variables.verificationService.resendVerification(requestBody.email)>

<!--- Output response --->
<cfoutput>#serializeJSON(response)#</cfoutput> 