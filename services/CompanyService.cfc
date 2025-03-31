component {
    
    public void function init() {
        variables.datasource = application.datasource;
    }
    
    public boolean function companyNameExists(required string name) {
        var result = queryExecute(
            "SELECT COUNT(*) as count FROM companies WHERE name = :name",
            {name = {value=arguments.name, cfsqltype="cf_sql_varchar"}},
            {datasource=variables.datasource}
        );
        
        return result.count > 0;
    }
    
    public struct function createCompany(required string name, required string status) {
        // Generate company salt for password hashing
        var salt = generateSalt();
        
        // Insert company
        var result = queryExecute(
            "INSERT INTO companies (
                name,
                status,
                salt,
                createdDate
            ) VALUES (
                :name,
                :status,
                :salt,
                CURRENT_TIMESTAMP
            )",
            {
                name = {value=arguments.name, cfsqltype="cf_sql_varchar"},
                status = {value=arguments.status, cfsqltype="cf_sql_varchar"},
                salt = {value=salt, cfsqltype="cf_sql_varchar"}
            },
            {datasource=variables.datasource}
        );
        
        // Get the created company
        var company = queryExecute(
            "SELECT * FROM companies WHERE companyID = :companyID",
            {companyID = {value=result.generatedKey, cfsqltype="cf_sql_integer"}},
            {datasource=variables.datasource}
        );
        
        return company;
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