# Initialize services
<cfset auditService = new model.AuditService()>
<cfset evidenceService = new model.AuditEvidenceService()>
<cfset securityService = new model.SecurityService()>

# Require authentication
<cfif !securityService.isAuthenticated()>
    <cfheader statusCode="401">
    <cfreturn>
</cfif>

<cfswitch expression="#url.action#">
    
    <!--- Get Control Details --->
    <cfcase value="control">
        <cfif !structKeyExists(url, "id")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Control ID is required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset control = auditService.getControlDetails(url.id)>
        <cfoutput>#serializeJSON({"success": true, "control": control})#</cfoutput>
    </cfcase>

    <!--- Assign Control --->
    <cfcase value="assignControl">
        <cfif !isJSON(getHTTPRequestData().content)>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Invalid request format"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset requestData = deserializeJSON(getHTTPRequestData().content)>
        
        <cfif !structKeyExists(requestData, "controlID") || !structKeyExists(requestData, "assignedTo")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Required parameters missing"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset result = auditService.assignControl(
            requestData.controlID,
            requestData.assignedTo,
            session.userID
        )>
        
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcase>

    <!--- Upload Evidence --->
    <cfcase value="uploadEvidence">
        <cfif !structKeyExists(form, "controlID") || !structKeyExists(form, "description")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Required parameters missing"}</cfoutput>
            <cfreturn>
        </cfif>

        <!--- Handle file upload --->
        <cffile action="upload" destination="#getTempDirectory()#" nameconflict="makeunique" result="uploadResults">
        
        <cfset result = evidenceService.uploadEvidence(
            form.controlID,
            form.description,
            [uploadResults],
            session.userID
        )>
        
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcase>

    <!--- Get Evidence --->
    <cfcase value="evidence">
        <cfif !structKeyExists(url, "controlID")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Control ID is required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset evidence = evidenceService.getEvidence(url.controlID)>
        <cfoutput>#serializeJSON({"success": true, "evidence": evidence})#</cfoutput>
    </cfcase>

    <!--- Download Evidence --->
    <cfcase value="downloadEvidence">
        <cfif !structKeyExists(url, "id")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Evidence ID is required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset result = evidenceService.downloadEvidence(url.id, session.userID)>
        
        <cfif result.success>
            <cfheader name="Content-Disposition" value="attachment; filename=""#result.originalFileName#""">
            <cfheader name="Content-Type" value="#result.mimeType#">
            <cfcontent file="#result.tempFile#" deletefile="yes">
        <cfelse>
            <cfheader statusCode="403">
            <cfoutput>#serializeJSON(result)#</cfoutput>
        </cfif>
    </cfcase>

    <!--- Get Activity Timeline --->
    <cfcase value="activity">
        <cfif !structKeyExists(url, "controlID")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Control ID is required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset activities = auditService.getControlActivities(url.controlID)>
        <cfoutput>#serializeJSON({"success": true, "activities": activities})#</cfoutput>
    </cfcase>

    <!--- Update Control Status --->
    <cfcase value="updateControlStatus">
        <cfif !isJSON(getHTTPRequestData().content)>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Invalid request format"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset requestData = deserializeJSON(getHTTPRequestData().content)>
        
        <cfif !structKeyExists(requestData, "controlID") || 
              !structKeyExists(requestData, "action") ||
              !structKeyExists(requestData, "notes")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Required parameters missing"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset result = auditService.updateControlStatus(
            requestData.controlID,
            requestData.action,
            requestData.notes,
            session.userID
        )>
        
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcase>

    <!--- AI Risk Analysis --->
    <cfcase value="analyzeControl">
        <cfif !structKeyExists(url, "controlID") || !structKeyExists(url, "auditID")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Control ID and Audit ID are required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset aiService = new model.AIRiskAnalysisService()>
        <cfset result = aiService.analyzeControlEvidence(url.controlID, url.auditID)>
        
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcase>

    <!--- Get Analysis History --->
    <cfcase value="analysisHistory">
        <cfif !structKeyExists(url, "controlID")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Control ID is required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset analyses = queryExecute("
            SELECT aca.*,
                   a.activityDate as performedDate,
                   u.firstName + ' ' + u.lastName as requestedBy
            FROM audit_control_analysis aca
            JOIN audit_activity a ON a.metadata LIKE '%' + CAST(aca.analysisID as varchar) + '%'
            JOIN users u ON a.userID = u.userID
            WHERE aca.controlID = :controlID
            ORDER BY a.activityDate DESC
        ", {
            controlID = url.controlID
        })>
        
        <cfoutput>#serializeJSON({"success": true, "analyses": analyses})#</cfoutput>
    </cfcase>

    <!--- Generate Remediation Plan --->
    <cfcase value="generateRemediation">
        <cfif !structKeyExists(url, "controlID") || !structKeyExists(url, "auditID")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Control ID and Audit ID are required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset remediationService = new model.RemediationService()>
        <cfset result = remediationService.generateRemediationPlan(url.controlID, url.auditID)>
        
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcase>

    <!--- Get Remediation Plan --->
    <cfcase value="getRemediationPlan">
        <cfif !structKeyExists(url, "planID")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Plan ID is required"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset remediationService = new model.RemediationService()>
        <cfset plan = remediationService.getRemediationPlan(url.planID)>
        
        <cfoutput>#serializeJSON({"success": true, "plan": plan})#</cfoutput>
    </cfcase>

    <!--- Update Remediation Task --->
    <cfcase value="updateRemediationTask">
        <cfif !isJSON(getHTTPRequestData().content)>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Invalid request format"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset requestData = deserializeJSON(getHTTPRequestData().content)>
        
        <cfif !structKeyExists(requestData, "taskID") || 
              !structKeyExists(requestData, "status") ||
              !structKeyExists(requestData, "notes")>
            <cfheader statusCode="400">
            <cfoutput>{"success": false, "message": "Required parameters missing"}</cfoutput>
            <cfreturn>
        </cfif>

        <cfset remediationService = new model.RemediationService()>
        <cfset result = remediationService.updateTaskStatus(
            requestData.taskID,
            requestData.status,
            requestData.notes,
            session.userID
        )>
        
        <cfoutput>#serializeJSON(result)#</cfoutput>
    </cfcase>

    <!--- Default Case --->
    <cfdefaultcase>
        <cfheader statusCode="404">
        <cfoutput>{"success": false, "message": "Action not found"}</cfoutput>
    </cfdefaultcase>

</cfswitch> 