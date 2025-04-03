<!--- Database Configuration --->
<cfset application.datasource = {
    name = "grc2",
    host = "GRC-DB",
    database = "grc",
    username = "grc_user",
    password = "complexPassword!!44",
    port = 3306,
    type = "mysql",
    connectionTimeout = 30,
    maxConnections = 10,
    minConnections = 1,
    maxIdleTime = 30
}>

<!--- Create datasource if it doesn't exist --->
<cftry>
    <cfquery name="checkDS" datasource="grc2">
        SELECT 1
    </cfquery>
    <cfcatch type="database">
        <!--- Create the datasource --->
        <cfadmin 
            action="updateDatasource"
            name="grc2"
            host="#application.datasource.host#"
            database="#application.datasource.database#"
            username="#application.datasource.username#"
            password="#application.datasource.password#"
            port="#application.datasource.port#"
            type="#application.datasource.type#"
            connectionTimeout="#application.datasource.connectionTimeout#"
            maxConnections="#application.datasource.maxConnections#"
            minConnections="#application.datasource.minConnections#"
            maxIdleTime="#application.datasource.maxIdleTime#"
        >
    </cfcatch>
</cftry> 