component {
    public function init() {
        return this;
    }

    public void function logActivity(
        required string activityType,
        required string activityDescription,
        struct additionalData = {},
        numeric userID = session.userID ?: "",
        numeric companyID = session.companyID ?: ""
    ) {
        try {
            var cgi = getPageContext().getCGI();
            
            queryExecute(
                "INSERT INTO activity_logs (
                    userID,
                    companyID,
                    activityType,
                    activityDescription,
                    ipAddress,
                    userAgent,
                    additionalData
                ) VALUES (
                    :userID,
                    :companyID,
                    :activityType,
                    :activityDescription,
                    :ipAddress,
                    :userAgent,
                    :additionalData
                )",
                {
                    userID: { value: userID, nullValue: "" },
                    companyID: { value: companyID, nullValue: "" },
                    activityType: { value: activityType, cfsqltype: "cf_sql_varchar" },
                    activityDescription: { value: activityDescription, cfsqltype: "cf_sql_longvarchar" },
                    ipAddress: { value: cgi.remote_addr, cfsqltype: "cf_sql_varchar" },
                    userAgent: { value: cgi.http_user_agent, cfsqltype: "cf_sql_varchar" },
                    additionalData: { value: serializeJSON(additionalData), cfsqltype: "cf_sql_longvarchar" }
                },
                { datasource: application.datasource }
            );
        } catch (any e) {
            // Log to error log but don't throw - we don't want logging failures to break the application
            writeLog(
                type = "error",
                text = "Error logging activity: #e.message# #e.detail#",
                file = "activity_log_errors"
            );
        }
    }

    remote function getActivityLogs(
        numeric companyID = 0,
        numeric userID = 0,
        string activityType = "",
        string startDate = "",
        string endDate = "",
        numeric page = 1,
        numeric pageSize = 50
    ) returnformat="json" {
        try {
            // Check if user is logged in and has appropriate access
            if (NOT isUserAuthorized()) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }

            var whereClause = [];
            var params = {};
            
            // For regular admins, force their company ID
            if (NOT session.isSuperAdmin) {
                arrayAppend(whereClause, "l.companyID = :companyID");
                params.companyID = { value: session.companyID, cfsqltype: "cf_sql_integer" };
            } else if (companyID > 0) {
                arrayAppend(whereClause, "l.companyID = :companyID");
                params.companyID = { value: companyID, cfsqltype: "cf_sql_integer" };
            }
            
            if (userID > 0) {
                arrayAppend(whereClause, "l.userID = :userID");
                params.userID = { value: userID, cfsqltype: "cf_sql_integer" };
            }
            
            if (len(activityType)) {
                arrayAppend(whereClause, "l.activityType = :activityType");
                params.activityType = { value: activityType, cfsqltype: "cf_sql_varchar" };
            }
            
            if (len(startDate)) {
                arrayAppend(whereClause, "l.activityDate >= :startDate");
                params.startDate = { value: startDate, cfsqltype: "cf_sql_timestamp" };
            }
            
            if (len(endDate)) {
                arrayAppend(whereClause, "l.activityDate <= :endDate");
                params.endDate = { value: endDate, cfsqltype: "cf_sql_timestamp" };
            }
            
            var sql = "
                SELECT l.*,
                       u.firstName,
                       u.lastName,
                       u.email as userEmail,
                       c.name as companyName
                FROM activity_logs l
                LEFT JOIN users u ON l.userID = u.userID
                LEFT JOIN companies c ON l.companyID = c.companyID
                #arrayLen(whereClause) ? 'WHERE ' & arrayToList(whereClause, ' AND ') : ''#
                ORDER BY l.activityDate DESC
                OFFSET :offset ROWS
                FETCH NEXT :pageSize ROWS ONLY
            ";
            
            params.offset = { value: (page - 1) * pageSize, cfsqltype: "cf_sql_integer" };
            params.pageSize = { value: pageSize, cfsqltype: "cf_sql_integer" };
            
            var result = queryExecute(sql, params, { datasource: application.datasource });
            var total = getActivityLogsCount(companyID, userID, activityType, startDate, endDate);
            
            return {
                "success": true,
                "data": queryToArray(result),
                "total": total,
                "page": page,
                "pageSize": pageSize
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error retrieving activity logs: " & e.message
            };
        }
    }

    public numeric function getActivityLogsCount(
        numeric companyID = 0,
        numeric userID = 0,
        string activityType = "",
        string startDate = "",
        string endDate = ""
    ) {
        var whereClause = [];
        var params = {};
        
        // For regular admins, force their company ID
        if (NOT session.isSuperAdmin) {
            arrayAppend(whereClause, "companyID = :companyID");
            params.companyID = { value: session.companyID, cfsqltype: "cf_sql_integer" };
        } else if (companyID > 0) {
            arrayAppend(whereClause, "companyID = :companyID");
            params.companyID = { value: companyID, cfsqltype: "cf_sql_integer" };
        }
        
        if (userID > 0) {
            arrayAppend(whereClause, "userID = :userID");
            params.userID = { value: userID, cfsqltype: "cf_sql_integer" };
        }
        
        if (len(activityType)) {
            arrayAppend(whereClause, "activityType = :activityType");
            params.activityType = { value: activityType, cfsqltype: "cf_sql_varchar" };
        }
        
        if (len(startDate)) {
            arrayAppend(whereClause, "activityDate >= :startDate");
            params.startDate = { value: startDate, cfsqltype: "cf_sql_timestamp" };
        }
        
        if (len(endDate)) {
            arrayAppend(whereClause, "activityDate <= :endDate");
            params.endDate = { value: endDate, cfsqltype: "cf_sql_timestamp" };
        }
        
        var result = queryExecute(
            "SELECT COUNT(*) as total
            FROM activity_logs
            #arrayLen(whereClause) ? 'WHERE ' & arrayToList(whereClause, ' AND ') : ''#",
            params,
            { datasource: application.datasource }
        );
        
        return result.total;
    }

    private boolean function isUserAuthorized() {
        return structKeyExists(session, "isLoggedIn") 
            AND session.isLoggedIn 
            AND (session.isSuperAdmin OR session.isAdmin);
    }

    private array function queryToArray(required query qry) {
        var array = [];
        for (var row in arguments.qry) {
            arrayAppend(array, row);
        }
        return array;
    }
} 