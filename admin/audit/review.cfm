<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('audit_control_review', 'Audit Control Review')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .evidence-file {
            border: 1px solid #dee2e6;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 4px;
        }
        .status-badge {
            font-size: 0.9rem;
            padding: 0.5rem 1rem;
        }
        .activity-timeline {
            position: relative;
            padding-left: 30px;
        }
        .activity-timeline::before {
            content: '';
            position: absolute;
            left: 15px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #dee2e6;
        }
        .activity-item {
            position: relative;
            margin-bottom: 1.5rem;
        }
        .activity-item::before {
            content: '';
            position: absolute;
            left: -23px;
            top: 5px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #007bff;
        }
    </style>
</head>
<body>
    <cfset auditService = new model.AuditService()>
    <cfset controlService = new model.ControlService()>
    <cfset audit = auditService.getAudit(url.id)>
    <cfset controls = auditService.getAuditControls(url.id)>

    <div class="container-fluid mt-4">
        <div class="row mb-4">
            <div class="col">
                <div class="d-flex justify-content-between align-items-center">
                    <h2>
                        <cfoutput>#getLabel('audit_control_review', 'Audit Control Review')#: #audit.reference#</cfoutput>
                    </h2>
                    <div>
                        <button type="button" class="btn btn-secondary" onclick="location.href='edit.cfm?id=<cfoutput>#url.id#</cfoutput>'">
                            <i class="fas fa-arrow-left"></i> <cfoutput>#getLabel('back_to_audit', 'Back to Audit')#</cfoutput>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Controls List -->
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('controls', 'Controls')#</cfoutput></h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="list-group list-group-flush">
                            <cfoutput query="controls">
                                <a href="##" class="list-group-item list-group-item-action" 
                                   onclick="loadControlDetails(#controlID#)">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6 class="mb-1">#title#</h6>
                                            <small class="text-muted">#left(description, 100)#...</small>
                                        </div>
                                        <span class="badge bg-#status eq 'approved' ? 'success' :
                                                    (status eq 'being_reviewed' ? 'warning' :
                                                    (status eq 'waiting_approval' ? 'info' : 'secondary'))#">
                                            #getLabel('status_' & status, status)#
                                        </span>
                                    </div>
                                </a>
                            </cfoutput>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Control Details -->
            <div class="col-md-8">
                <div id="controlDetails" style="display: none;">
                    <div class="card mb-4">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="mb-0" id="controlTitle"></h5>
                                <span class="badge status-badge" id="controlStatus"></span>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('description', 'Description')#</cfoutput></label>
                                <p id="controlDescription" class="form-control-plaintext"></p>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('test_procedures', 'Test Procedures')#</cfoutput></label>
                                <p id="controlTestProcedures" class="form-control-plaintext"></p>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('evidence_requirements', 'Evidence Requirements')#</cfoutput></label>
                                <p id="controlEvidenceRequirements" class="form-control-plaintext"></p>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('assigned_to', 'Assigned To')#</cfoutput></label>
                                <select class="form-select" id="assignedTo" onchange="updateAssignment()">
                                    <option value=""><cfoutput>#getLabel('select_assignee', 'Select Assignee')#</cfoutput></option>
                                    <cfoutput query="auditService.getAuditTeamMembers(url.id)">
                                        <option value="#userID#">#firstName# #lastName#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Evidence Upload -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('evidence', 'Evidence')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <form id="evidenceForm" onsubmit="return uploadEvidence(event)">
                                <input type="hidden" id="currentControlID" name="controlID">
                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('evidence_description', 'Evidence Description')#</cfoutput></label>
                                    <textarea class="form-control" name="description" rows="3" required></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('files', 'Files')#</cfoutput></label>
                                    <input type="file" class="form-control" name="files" multiple required>
                                </div>
                                <div class="text-end">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-upload"></i> <cfoutput>#getLabel('upload', 'Upload')#</cfoutput>
                                    </button>
                                </div>
                            </form>

                            <hr>

                            <div id="evidenceList">
                                <!-- Evidence files will be loaded here -->
                            </div>
                        </div>
                    </div>

                    <!-- Review Actions -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('review_actions', 'Review Actions')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label"><cfoutput>#getLabel('review_notes', 'Review Notes')#</cfoutput></label>
                                <textarea class="form-control" id="reviewNotes" rows="3"></textarea>
                            </div>
                            <div class="text-end">
                                <button type="button" class="btn btn-warning" onclick="startReview()">
                                    <i class="fas fa-clock"></i> <cfoutput>#getLabel('start_review', 'Start Review')#</cfoutput>
                                </button>
                                <button type="button" class="btn btn-info" onclick="submitForApproval()">
                                    <i class="fas fa-paper-plane"></i> <cfoutput>#getLabel('submit_for_approval', 'Submit for Approval')#</cfoutput>
                                </button>
                                <button type="button" class="btn btn-success" onclick="approve()">
                                    <i class="fas fa-check"></i> <cfoutput>#getLabel('approve', 'Approve')#</cfoutput>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Activity Timeline -->
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><cfoutput>#getLabel('activity_timeline', 'Activity Timeline')#</cfoutput></h5>
                        </div>
                        <div class="card-body">
                            <div id="activityTimeline" class="activity-timeline">
                                <!-- Activity items will be loaded here -->
                            </div>
                        </div>
                    </div>

                    <!-- AI Analysis -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><cfoutput>#getLabel('ai_analysis', 'AI Risk Analysis')#</cfoutput></h5>
                                <button type="button" class="btn btn-primary btn-sm" onclick="performAIAnalysis()">
                                    <i class="fas fa-robot"></i> <cfoutput>#getLabel('analyze', 'Analyze')#</cfoutput>
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <div id="analysisLoading" style="display: none;">
                                <div class="text-center">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                    <p class="mt-2"><cfoutput>#getLabel('analyzing', 'Analyzing evidence and generating insights...')#</cfoutput></p>
                                </div>
                            </div>

                            <div id="analysisResults" style="display: none;">
                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('risk_score', 'Risk Score')#</cfoutput></label>
                                    <div class="progress">
                                        <div id="riskScoreBar" class="progress-bar" role="progressbar"></div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('coverage', 'Control Coverage')#</cfoutput></label>
                                    <p id="coverageAnalysis" class="form-control-plaintext"></p>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('completeness', 'Evidence Completeness')#</cfoutput></label>
                                    <p id="completenessAnalysis" class="form-control-plaintext"></p>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('gaps', 'Identified Gaps')#</cfoutput></label>
                                    <p id="gapsAnalysis" class="form-control-plaintext"></p>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('risk_level', 'Risk Level Assessment')#</cfoutput></label>
                                    <p id="riskLevelAnalysis" class="form-control-plaintext"></p>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('recommendations', 'Recommendations')#</cfoutput></label>
                                    <p id="recommendationsAnalysis" class="form-control-plaintext"></p>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label"><cfoutput>#getLabel('additional_controls', 'Additional Controls Needed')#</cfoutput></label>
                                    <p id="additionalControlsAnalysis" class="form-control-plaintext"></p>
                                </div>
                            </div>

                            <div id="analysisHistory" class="mt-4">
                                <h6><cfoutput>#getLabel('analysis_history', 'Analysis History')#</cfoutput></h6>
                                <div class="list-group" id="analysisHistoryList">
                                    <!-- Analysis history items will be loaded here -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Remediation Plan -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><cfoutput>#getLabel('remediation_plan', 'Remediation Plan')#</cfoutput></h5>
                                <button type="button" class="btn btn-primary btn-sm" onclick="generateRemediationPlan()">
                                    <i class="fas fa-tools"></i> <cfoutput>#getLabel('generate_plan', 'Generate Plan')#</cfoutput>
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <div id="remediationLoading" style="display: none;">
                                <div class="text-center">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                    <p class="mt-2"><cfoutput>#getLabel('generating_plan', 'Generating remediation plan...')#</cfoutput></p>
                                </div>
                            </div>

                            <div id="remediationPlan" style="display: none;">
                                <!-- Timeline Progress -->
                                <div class="mb-4">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <h6 class="mb-0"><cfoutput>#getLabel('implementation_timeline', 'Implementation Timeline')#</cfoutput></h6>
                                        <span id="completionStatus" class="badge bg-secondary"></span>
                                    </div>
                                    <div class="progress" style="height: 25px;">
                                        <div id="taskProgress" class="progress-bar" role="progressbar"></div>
                                    </div>
                                </div>

                                <!-- Action Sections -->
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="card h-100">
                                            <div class="card-header bg-warning text-white">
                                                <h6 class="mb-0"><cfoutput>#getLabel('immediate_actions', 'Immediate Actions (30 Days)')#</cfoutput></h6>
                                            </div>
                                            <div class="card-body">
                                                <div id="immediateActions" class="task-list"></div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card h-100">
                                            <div class="card-header bg-info text-white">
                                                <h6 class="mb-0"><cfoutput>#getLabel('short_term', 'Short-term (60-90 Days)')#</cfoutput></h6>
                                            </div>
                                            <div class="card-body">
                                                <div id="shortTermActions" class="task-list"></div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card h-100">
                                            <div class="card-header bg-success text-white">
                                                <h6 class="mb-0"><cfoutput>#getLabel('long_term', 'Long-term (90+ Days)')#</cfoutput></h6>
                                            </div>
                                            <div class="card-body">
                                                <div id="longTermActions" class="task-list"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Details Accordion -->
                                <div class="accordion mt-4" id="remediationDetails">
                                    <div class="accordion-item">
                                        <h2 class="accordion-header">
                                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#resourcesSection">
                                                <cfoutput>#getLabel('resource_requirements', 'Resource Requirements')#</cfoutput>
                                            </button>
                                        </h2>
                                        <div id="resourcesSection" class="accordion-collapse collapse" data-bs-parent="#remediationDetails">
                                            <div class="accordion-body" id="resourceRequirements"></div>
                                        </div>
                                    </div>

                                    <div class="accordion-item">
                                        <h2 class="accordion-header">
                                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#metricsSection">
                                                <cfoutput>#getLabel('success_metrics', 'Success Metrics')#</cfoutput>
                                            </button>
                                        </h2>
                                        <div id="metricsSection" class="accordion-collapse collapse" data-bs-parent="#remediationDetails">
                                            <div class="accordion-body" id="successMetrics"></div>
                                        </div>
                                    </div>

                                    <div class="accordion-item">
                                        <h2 class="accordion-header">
                                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#challengesSection">
                                                <cfoutput>#getLabel('challenges', 'Potential Challenges')#</cfoutput>
                                            </button>
                                        </h2>
                                        <div id="challengesSection" class="accordion-collapse collapse" data-bs-parent="#remediationDetails">
                                            <div class="accordion-body" id="potentialChallenges"></div>
                                        </div>
                                    </div>

                                    <div class="accordion-item">
                                        <h2 class="accordion-header">
                                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#costSection">
                                                <cfoutput>#getLabel('cost_benefit', 'Cost-Benefit Analysis')#</cfoutput>
                                            </button>
                                        </h2>
                                        <div id="costSection" class="accordion-collapse collapse" data-bs-parent="#remediationDetails">
                                            <div class="accordion-body" id="costBenefitAnalysis"></div>
                                        </div>
                                    </div>

                                    <div class="accordion-item">
                                        <h2 class="accordion-header">
                                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#alternativesSection">
                                                <cfoutput>#getLabel('alternatives', 'Alternative Solutions')#</cfoutput>
                                            </button>
                                        </h2>
                                        <div id="alternativesSection" class="accordion-collapse collapse" data-bs-parent="#remediationDetails">
                                            <div class="accordion-body" id="alternativeSolutions"></div>
                                        </div>
                                    </div>

                                    <div class="accordion-item">
                                        <h2 class="accordion-header">
                                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#monitoringSection">
                                                <cfoutput>#getLabel('monitoring', 'Monitoring Plan')#</cfoutput>
                                            </button>
                                        </h2>
                                        <div id="monitoringSection" class="accordion-collapse collapse" data-bs-parent="#remediationDetails">
                                            <div class="accordion-body" id="monitoringPlan"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function loadControlDetails(controlID) {
            $('#currentControlID').val(controlID);
            
            $.get(`/api/audit/control?id=${controlID}`, function(response) {
                if (response.success) {
                    const control = response.control;
                    
                    $('#controlTitle').text(control.title);
                    $('#controlDescription').text(control.description);
                    $('#controlTestProcedures').text(control.testProcedures);
                    $('#controlEvidenceRequirements').text(control.evidenceRequirements);
                    $('#assignedTo').val(control.assignedTo || '');
                    
                    updateControlStatus(control.status);
                    loadEvidence(controlID);
                    loadActivityTimeline(controlID);
                    
                    $('#controlDetails').show();
                }
            });
        }

        function updateControlStatus(status) {
            const statusBadge = $('#controlStatus');
            statusBadge.removeClass().addClass('badge status-badge');
            
            switch(status) {
                case 'not_reviewed':
                    statusBadge.addClass('bg-secondary').text(getLabel('status_not_reviewed', 'Not Reviewed'));
                    break;
                case 'being_reviewed':
                    statusBadge.addClass('bg-warning').text(getLabel('status_being_reviewed', 'Being Reviewed'));
                    break;
                case 'waiting_approval':
                    statusBadge.addClass('bg-info').text(getLabel('status_waiting_approval', 'Waiting Approval'));
                    break;
                case 'approved':
                    statusBadge.addClass('bg-success').text(getLabel('status_approved', 'Approved'));
                    break;
            }
        }

        function updateAssignment() {
            const controlID = $('#currentControlID').val();
            const assignedTo = $('#assignedTo').val();
            
            $.post('/api/audit/assignControl', {
                controlID: controlID,
                assignedTo: assignedTo
            }, function(response) {
                if (response.success) {
                    loadActivityTimeline(controlID);
                }
            });
        }

        function uploadEvidence(event) {
            event.preventDefault();
            const form = event.target;
            const formData = new FormData(form);
            
            $.ajax({
                url: '/api/audit/uploadEvidence',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    if (response.success) {
                        form.reset();
                        loadEvidence($('#currentControlID').val());
                        loadActivityTimeline($('#currentControlID').val());
                    } else {
                        alert(response.message);
                    }
                }
            });

            return false;
        }

        function loadEvidence(controlID) {
            $.get(`/api/audit/evidence?controlID=${controlID}`, function(response) {
                if (response.success) {
                    const evidenceList = $('#evidenceList');
                    evidenceList.empty();
                    
                    response.evidence.forEach(evidence => {
                        evidenceList.append(`
                            <div class="evidence-file">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="mb-1">${evidence.description}</h6>
                                        <small class="text-muted">
                                            ${getLabel('uploaded_by', 'Uploaded by')}: ${evidence.uploadedByName}<br>
                                            ${getLabel('upload_date', 'Upload Date')}: ${new Date(evidence.uploadDate).toLocaleString()}
                                        </small>
                                    </div>
                                    <div>
                                        <button type="button" class="btn btn-sm btn-primary" onclick="downloadEvidence(${evidence.evidenceID})">
                                            <i class="fas fa-download"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `);
                    });
                }
            });
        }

        function loadActivityTimeline(controlID) {
            $.get(`/api/audit/activity?controlID=${controlID}`, function(response) {
                if (response.success) {
                    const timeline = $('#activityTimeline');
                    timeline.empty();
                    
                    response.activities.forEach(activity => {
                        timeline.append(`
                            <div class="activity-item">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h6 class="mb-1">${activity.action}</h6>
                                        <small class="text-muted">
                                            ${activity.userFullName} - ${new Date(activity.activityDate).toLocaleString()}
                                        </small>
                                    </div>
                                </div>
                                <p class="mb-0">${activity.details}</p>
                            </div>
                        `);
                    });
                }
            });
        }

        function startReview() {
            updateControlWorkflow('start_review');
        }

        function submitForApproval() {
            updateControlWorkflow('submit_approval');
        }

        function approve() {
            updateControlWorkflow('approve');
        }

        function updateControlWorkflow(action) {
            const controlID = $('#currentControlID').val();
            const notes = $('#reviewNotes').val();
            
            $.post('/api/audit/updateControlStatus', {
                controlID: controlID,
                action: action,
                notes: notes
            }, function(response) {
                if (response.success) {
                    loadControlDetails(controlID);
                    $('#reviewNotes').val('');
                } else {
                    alert(response.message);
                }
            });
        }

        function downloadEvidence(evidenceID) {
            window.location.href = `/api/audit/downloadEvidence?id=${evidenceID}`;
        }

        function performAIAnalysis() {
            const controlID = $('#currentControlID').val();
            const auditID = '<cfoutput>#url.id#</cfoutput>';
            
            $('#analysisLoading').show();
            $('#analysisResults').hide();
            
            $.get(`/api/audit/analyzeControl?controlID=${controlID}&auditID=${auditID}`, function(response) {
                if (response.success) {
                    updateAnalysisResults(response.analysis);
                    loadAnalysisHistory(controlID);
                } else {
                    alert(response.message || 'Analysis failed');
                }
                $('#analysisLoading').hide();
            });
        }

        function updateAnalysisResults(analysis) {
            $('#riskScoreBar')
                .css('width', `${(analysis.riskScore / 5) * 100}%`)
                .text(`${analysis.riskScore}/5`)
                .removeClass()
                .addClass(`progress-bar ${getRiskScoreClass(analysis.riskScore)}`);
            
            $('#coverageAnalysis').text(analysis.coverage);
            $('#completenessAnalysis').text(analysis.completeness);
            $('#gapsAnalysis').text(analysis.gaps);
            $('#riskLevelAnalysis').text(analysis.riskLevel);
            $('#recommendationsAnalysis').text(analysis.recommendations);
            $('#additionalControlsAnalysis').text(analysis.additionalControls);
            
            $('#analysisResults').show();
        }

        function loadAnalysisHistory(controlID) {
            $.get(`/api/audit/analysisHistory?controlID=${controlID}`, function(response) {
                if (response.success) {
                    const historyList = $('#analysisHistoryList');
                    historyList.empty();
                    
                    response.analyses.forEach(analysis => {
                        historyList.append(`
                            <div class="list-group-item">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="mb-1">Risk Score: ${analysis.riskScore}/5</h6>
                                        <small class="text-muted">
                                            ${getLabel('analyzed_by', 'Analyzed by')}: ${analysis.requestedBy}<br>
                                            ${getLabel('date', 'Date')}: ${new Date(analysis.performedDate).toLocaleString()}
                                        </small>
                                    </div>
                                    <span class="badge ${getRiskScoreClass(analysis.riskScore)}">
                                        ${getRiskLabel(analysis.riskScore)}
                                    </span>
                                </div>
                            </div>
                        `);
                    });
                }
            });
        }

        function getRiskScoreClass(score) {
            if (score <= 1) return 'bg-success';
            if (score <= 2) return 'bg-info';
            if (score <= 3) return 'bg-warning';
            return 'bg-danger';
        }

        function getRiskLabel(score) {
            if (score <= 1) return getLabel('risk_low', 'Low Risk');
            if (score <= 2) return getLabel('risk_moderate', 'Moderate Risk');
            if (score <= 3) return getLabel('risk_high', 'High Risk');
            return getLabel('risk_critical', 'Critical Risk');
        }

        function generateRemediationPlan() {
            const controlID = $('#currentControlID').val();
            const auditID = '<cfoutput>#url.id#</cfoutput>';
            
            $('#remediationLoading').show();
            $('#remediationPlan').hide();
            
            $.get(`/api/audit/generateRemediation?controlID=${controlID}&auditID=${auditID}`, function(response) {
                if (response.success) {
                    loadRemediationPlan(response.planID);
                } else {
                    alert(response.message || 'Failed to generate remediation plan');
                    $('#remediationLoading').hide();
                }
            });
        }

        function loadRemediationPlan(planID) {
            $.get(`/api/audit/getRemediationPlan?planID=${planID}`, function(response) {
                if (response.success) {
                    updateRemediationPlan(response.plan);
                    $('#remediationLoading').hide();
                    $('#remediationPlan').show();
                }
            });
        }

        function updateRemediationPlan(plan) {
            // Update progress
            const progress = (plan.completedTasks / plan.totalTasks) * 100;
            $('#taskProgress')
                .css('width', `${progress}%`)
                .text(`${plan.completedTasks}/${plan.totalTasks} tasks completed`);
            
            // Update status badge
            $('#completionStatus')
                .text(getLabel(`status_${plan.status}`, plan.status))
                .removeClass()
                .addClass(`badge ${getStatusClass(plan.status)}`);
            
            // Update task lists
            updateTaskList('immediateActions', plan.tasks.filter(t => t.dueDate <= 30));
            updateTaskList('shortTermActions', plan.tasks.filter(t => t.dueDate > 30 && t.dueDate <= 90));
            updateTaskList('longTermActions', plan.tasks.filter(t => t.dueDate > 90));
            
            // Update details sections
            $('#resourceRequirements').html(formatText(plan.resourceRequirements));
            $('#successMetrics').html(formatText(plan.successMetrics));
            $('#potentialChallenges').html(formatText(plan.potentialChallenges));
            $('#costBenefitAnalysis').html(formatText(plan.costBenefitAnalysis));
            $('#alternativeSolutions').html(formatText(plan.alternativeSolutions));
            $('#monitoringPlan').html(formatText(plan.monitoringPlan));
        }

        function updateTaskList(elementId, tasks) {
            const container = $(`#${elementId}`);
            container.empty();
            
            tasks.forEach(task => {
                container.append(`
                    <div class="task-item mb-2">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" 
                                   ${task.status === 'completed' ? 'checked' : ''}
                                   onchange="updateTaskStatus(${task.taskID}, this.checked)">
                            <label class="form-check-label ${task.status === 'completed' ? 'text-muted text-decoration-line-through' : ''}">
                                ${task.taskDescription}
                                <small class="d-block text-muted">
                                    ${getLabel('due', 'Due')}: ${new Date(task.dueDate).toLocaleDateString()}
                                </small>
                            </label>
                        </div>
                    </div>
                `);
            });
        }

        function updateTaskStatus(taskID, completed) {
            $.post('/api/audit/updateRemediationTask', {
                taskID: taskID,
                status: completed ? 'completed' : 'pending',
                notes: completed ? 'Task completed' : 'Task reopened'
            }, function(response) {
                if (response.success) {
                    loadRemediationPlan(currentPlanID);
                }
            });
        }

        function getStatusClass(status) {
            switch (status) {
                case 'completed': return 'bg-success';
                case 'in_progress': return 'bg-info';
                default: return 'bg-secondary';
            }
        }

        function formatText(text) {
            return text.split('\n').map(line => `<p>${line}</p>`).join('');
        }
    </script>
</body>
</html> 