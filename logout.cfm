<cfset structClear(session)>
<cfset session.isLoggedIn = false>
<cflocation url="login.cfm" addtoken="false"> 