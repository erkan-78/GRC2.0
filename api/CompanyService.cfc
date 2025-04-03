component {
    
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public boolean function companyDomainExists(required string emailDomain) {
        var result = queryExecute(
            "SELECT COUNT(*) as count FROM companies WHERE email = :emailDomain",
            {emailDomain = {value=arguments.emailDomain, cfsqltype="cf_sql_varchar"}},
            {datasource=variables.datasource}
        );
        
        return result.count > 0;
    }
    
    public struct function createCompany(required string name, required string status, required string email) {
        
        // Generate company salt for password hashing
        var salt = generateSalt(); 
        
         var result = queryExecute(
            "INSERT INTO companies (
                name,
                statusId,
                salt,
                applicationDate,
                email
            ) VALUES (
                :name,
                :status,
                :salt,
                current_timestamp(),
                :email
            )",
            {
                name = {value=arguments.name, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.status, cfsqltype="cf_sql_varchar"},
                salt = {value=salt, cfsqltype="cf_sql_varchar"},
                email = {value=arguments.email, cfsqltype="cf_sql_varchar"}
            },
            {datasource="grc"}
        ); 
        
        // Get the created company
        var company = queryExecute(
            "SELECT * FROM companies WHERE email = :email",
            {email = {value=arguments.email, cfsqltype="cf_sql_varchar"}},
            {datasource="grc" , result="company"}
        ); 
        // Insert company
     
         return {
                    "success": true,
                    "message": "Company created successfully",
                    "data": {
                        "companyID": company.companyID
                    }
                };
    }
    
    public void function updateCompanyStatus(required numeric companyID, required string status) {
        queryExecute(
            "UPDATE companies SET status = :status WHERE companyID = :companyID",
            {
                companyID = {value=arguments.companyID, cfsqltype="cf_sql_integer"},
                status = {value=arguments.status, cfsqltype="cf_sql_varchar"}
            },
            {datasource=variables.datasource}
        );
    }
    
    private string function generateSalt() {
        return hash(createUUID() & now(), "SHA-256");
    }
} 