<!DOCTYPE html>
<html>
<head>
    <title>Create Site Admin</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
        }
        .message {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
    </style>
</head>
<body>
    <h1>Create Site Admin</h1>
    
    <!--- Read admin password from file --->
    <cffile action="read" file="#expandPath('./admin_password.txt')#" variable="adminPassword">
    
    <!--- Initialize user service --->
    <cfset variables.userService = new api.user.index()>
    <cfset variables.companyService = new api.CompanyService()>
    <!--- Create admin user --->
    <cfset company = variables.companyService.createCompany(
            name = "lightGRC",
            status = "ce452891-0e3e-11f0-9017-3ebf08bd720f",
            email = "lightgrc.app"
        )> 
        <cfset adminUser = variables.userService.createUser(
            companyID = company.data.companyID,
            firstName = "site",
            lastName = "admin",
            email = "info@lightgrc.app",
            password = trim(adminPassword),
            role = "site.admin",
            status = "cfcbdfa1-0fef-11f0-a0a5-02e353546665"
        )>
        
        <div class="message success">
            <h2>Success!</h2>
            <p>Site admin user created successfully.</p>
            <p>Email: info@lightgrc.app</p>
            <p>Password: <cfoutput>#trim(adminPassword)#</cfoutput></p>
            <p><strong>Please save these credentials and delete this file for security.</strong></p>
        </div>
   
</body>
</html> 