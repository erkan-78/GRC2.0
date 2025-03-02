<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('remediation_plan', 'Remediation Plan')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .task-card {
            border-left-width: 4px;
        }
        .task-card.priority-high { border-left-color: #dc3545; }
        .task-card.priority-medium { border-left-color: #ffc107; }
        .task-card.priority-low { border-left-color: #28a745; }
        .comment-thread {
            margin-left: 2rem;
            padding-left: 1rem;
            border-left: 2px solid #dee2e6;
        }
        .evidence-file {
            border: 1px solid #dee2e6;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <cfset remediationService = new model.RemediationService()>
    <cfset plan = remediationService.getRemediationPlan(url.id)>
    <cfset tasks = remediationService.getRemediationTasks(url.id)>

    <div class="container-fluid mt-4">
        <!-- Header -->
        <div class="row mb-4">
            <div class="col">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2><cfoutput>#plan.controlTitle#</cfoutput></h2>
                        <p class="text-muted mb-0">
                            <cfoutput>
                                #getLabel('audit', 'Audit')#: #plan.auditReference#<br>
                                #getLabel('created_date', 'Created Date')#: #dateFormat(plan.createdDate, "mmm d, yyyy")#
                            </cfoutput>
                        </p>
                    </div>
                    <div>
                        <button type="button" class="btn btn-secondary" onclick="location.href='dashboard.cfm'">
                            <i class="fas fa-arrow-left"></i> <cfoutput>#getLabel('back', 'Back')#</cfoutput>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Tasks Column -->
            <div class="col-md-8">
                <div class="card mb-4">
                    <div class="card-header">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><cfoutput>#getLabel('tasks', 'Tasks')#</cfoutput></h5>
                            <button type="button" class="btn btn-primary btn-sm" onclick="showAddTaskModal()">
                                <i class="fas fa-plus"></i> <cfoutput>#getLabel('add_task', 'Add Task')#</cfoutput>
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <cfoutput query="tasks">
                            <div class="card task-card mb-3 priority-#priority#">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" 
                                                       #status eq 'completed' ? 'checked' : ''#
                                                       onchange="updateTaskStatus(#taskID#, this.checked)">
                                                <label class="form-check-label #status eq 'completed' ? 'text-muted text-decoration-line-through' : ''#">
                                                    #taskDescription#
                                                </label>
                                            </div>
                                            <small class="text-muted d-block mt-1">
                                                Due: #dateFormat(dueDate, "mmm d, yyyy")# |
                                                Assigned to: #assignedToName# |
                                                Priority: #priority#
                                            </small>
                                        </div>
                                        <div class="btn-group">
                                            <button type="button" class="btn btn-sm btn-outline-primary" 
                                                    onclick="showTaskDetails(#taskID#)">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-outline-secondary" 
                                                    onclick="showEditTaskModal(#taskID#)">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <!-- Progress Bar -->
                                    <div class="progress mt-2" style="height: 5px;">
                                        <div class="progress-bar" role="progressbar" 
                                             style="width: #numberFormat(progress, '999.9')#%"></div>
                                    </div>
                                </div>
                            </div>
                        </cfoutput>
                    </div>
                </div>

                <!-- Task Details Section (Initially Hidden) -->
                <div id="taskDetails" class="card mb-4" style="display: none;">
                    <div class="card-header">
                        <h5 class="mb-0" id="taskTitle"></h5>
                    </div>
                    <div class="card-body">
                        <!-- Comments Section -->
                        <div class="mb-4">
                            <h6><cfoutput>#getLabel('comments', 'Comments')#</cfoutput></h6>
                            <div id="commentsList" class="comment-thread mb-3"></div>
                            
                            <form id="commentForm" onsubmit="return addComment(event)">
                                <input type="hidden" id="taskIDForComment">
                                <div class="mb-3">
                                    <textarea class="form-control" id="commentText" rows="2" required></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary btn-sm">
                                    <i class="fas fa-comment"></i> <cfoutput>#getLabel('add_comment', 'Add Comment')#</cfoutput>
                                </button>
                            </form>
                        </div>

                        <!-- Evidence Section -->
                        <div>
                            <h6><cfoutput>#getLabel('evidence', 'Evidence')#</cfoutput></h6>
                            <div id="evidenceList" class="mb-3"></div>
                            
                            <form id="evidenceForm" onsubmit="return uploadEvidence(event)">
                                <input type="hidden" id="taskIDForEvidence">
                                <div class="mb-3">
                                    <input type="file" class="form-control" id="evidenceFile" required>
                                </div>
                                <div class="mb-3">
                                    <input type="text" class="form-control" id="evidenceDescription" 
                                           placeholder="Description" required>
                                </div>
                                <button type="submit" class="btn btn-primary btn-sm">
                                    <i class="fas fa-upload"></i> <cfoutput>#getLabel('upload', 'Upload')#</cfoutput>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Plan Details Column -->
            <div class="col-md-4">
                <!-- Status Card -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('status', 'Status')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('completion', 'Completion')#</cfoutput></label>
                            <div class="progress mb-2">
                                <div class="progress-bar" role="progressbar" 
                                     style="width: <cfoutput>#numberFormat((plan.completedTasks/plan.totalTasks)*100, '999.9')#%</cfoutput>">
                                    <cfoutput>#numberFormat((plan.completedTasks/plan.totalTasks)*100, '999.9')#%</cfoutput>
                                </div>
                            </div>
                            <small class="text-muted">
                                <cfoutput>#plan.completedTasks# of #plan.totalTasks# tasks completed</cfoutput>
                            </small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('current_status', 'Current Status')#</cfoutput></label>
                            <div>
                                <span class="badge bg-<cfoutput>#plan.status eq 'completed' ? 'success' : 
                                                        (plan.status eq 'in_progress' ? 'info' : 'secondary')#</cfoutput>">
                                    <cfoutput>#getLabel('status_' & plan.status, plan.status)#</cfoutput>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Plan Details -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('plan_details', 'Plan Details')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('resource_requirements', 'Resource Requirements')#</cfoutput></label>
                            <p class="form-control-plaintext"><cfoutput>#plan.resourceRequirements#</cfoutput></p>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('success_metrics', 'Success Metrics')#</cfoutput></label>
                            <p class="form-control-plaintext"><cfoutput>#plan.successMetrics#</cfoutput></p>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('monitoring_plan', 'Monitoring Plan')#</cfoutput></label>
                            <p class="form-control-plaintext"><cfoutput>#plan.monitoringPlan#</cfoutput></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add/Edit Task Modal -->
    <div class="modal fade" id="taskModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="taskModalTitle"></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="taskForm" onsubmit="return saveTask(event)">
                    <div class="modal-body">
                        <input type="hidden" id="taskID">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('description', 'Description')#</cfoutput></label>
                            <textarea class="form-control" id="taskDescription" rows="3" required></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('assignee', 'Assignee')#</cfoutput></label>
                            <select class="form-select" id="taskAssignee" required>
                                <option value=""><cfoutput>#getLabel('select_assignee', 'Select Assignee')#</cfoutput></option>
                                <cfoutput query="remediationService.getCompanyUsers(session.companyID)">
                                    <option value="#userID#">#firstName# #lastName#</option>
                                </cfoutput>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('due_date', 'Due Date')#</cfoutput></label>
                            <input type="date" class="form-control" id="taskDueDate" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('priority', 'Priority')#</cfoutput></label>
                            <select class="form-select" id="taskPriority" required>
                                <option value="high"><cfoutput>#getLabel('high', 'High')#</cfoutput></option>
                                <option value="medium"><cfoutput>#getLabel('medium', 'Medium')#</cfoutput></option>
                                <option value="low"><cfoutput>#getLabel('low', 'Low')#</cfoutput></option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <cfoutput>#getLabel('cancel', 'Cancel')#</cfoutput>
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <cfoutput>#getLabel('save', 'Save')#</cfoutput>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let taskModal;
        let currentTaskID;

        document.addEventListener('DOMContentLoaded', function() {
            taskModal = new bootstrap.Modal(document.getElementById('taskModal'));
        });

        function showAddTaskModal() {
            $('#taskModalTitle').text(getLabel('add_task', 'Add Task'));
            $('#taskID').val('');
            $('#taskForm')[0].reset();
            taskModal.show();
        }

        function showEditTaskModal(taskID) {
            $('#taskModalTitle').text(getLabel('edit_task', 'Edit Task'));
            
            $.get(`/api/remediation/task?id=${taskID}`, function(response) {
                if (response.success) {
                    const task = response.task;
                    $('#taskID').val(task.taskID);
                    $('#taskDescription').val(task.description);
                    $('#taskAssignee').val(task.assignedTo);
                    $('#taskDueDate').val(task.dueDate);
                    $('#taskPriority').val(task.priority);
                    taskModal.show();
                }
            });
        }

        function saveTask(event) {
            event.preventDefault();
            
            const taskData = {
                taskID: $('#taskID').val(),
                planID: '<cfoutput>#url.id#</cfoutput>',
                description: $('#taskDescription').val(),
                assignedTo: $('#taskAssignee').val(),
                dueDate: $('#taskDueDate').val(),
                priority: $('#taskPriority').val()
            };

            $.post('/api/remediation/saveTask', taskData, function(response) {
                if (response.success) {
                    location.reload();
                } else {
                    alert(response.message);
                }
            });

            return false;
        }

        function showTaskDetails(taskID) {
            currentTaskID = taskID;
            
            $.get(`/api/remediation/taskDetails?id=${taskID}`, function(response) {
                if (response.success) {
                    $('#taskTitle').text(response.task.description);
                    $('#taskIDForComment').val(taskID);
                    $('#taskIDForEvidence').val(taskID);
                    
                    updateCommentsList(response.task.comments);
                    updateEvidenceList(response.task.evidence);
                    
                    $('#taskDetails').show();
                }
            });
        }

        function updateCommentsList(comments) {
            const commentsList = $('#commentsList');
            commentsList.empty();
            
            comments.forEach(comment => {
                commentsList.append(`
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <strong>${comment.userFullName}</strong>
                            <small class="text-muted">${new Date(comment.commentDate).toLocaleString()}</small>
                        </div>
                        <p class="mb-0">${comment.commentText}</p>
                    </div>
                `);
            });
        }

        function updateEvidenceList(evidence) {
            const evidenceList = $('#evidenceList');
            evidenceList.empty();
            
            evidence.forEach(item => {
                evidenceList.append(`
                    <div class="evidence-file">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="mb-1">${item.description}</h6>
                                <small class="text-muted">
                                    ${getLabel('uploaded_by', 'Uploaded by')}: ${item.uploadedByName}<br>
                                    ${getLabel('upload_date', 'Upload Date')}: ${new Date(item.uploadDate).toLocaleString()}
                                </small>
                            </div>
                            <button type="button" class="btn btn-sm btn-primary" 
                                    onclick="downloadEvidence(${item.evidenceID})">
                                <i class="fas fa-download"></i>
                            </button>
                        </div>
                    </div>
                `);
            });
        }

        function addComment(event) {
            event.preventDefault();
            
            $.post('/api/remediation/addComment', {
                taskID: $('#taskIDForComment').val(),
                commentText: $('#commentText').val()
            }, function(response) {
                if (response.success) {
                    $('#commentText').val('');
                    showTaskDetails(currentTaskID);
                }
            });

            return false;
        }

        function uploadEvidence(event) {
            event.preventDefault();
            
            const formData = new FormData();
            formData.append('taskID', $('#taskIDForEvidence').val());
            formData.append('description', $('#evidenceDescription').val());
            formData.append('file', $('#evidenceFile')[0].files[0]);
            
            $.ajax({
                url: '/api/remediation/uploadEvidence',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    if (response.success) {
                        $('#evidenceForm')[0].reset();
                        showTaskDetails(currentTaskID);
                    }
                }
            });

            return false;
        }

        function downloadEvidence(evidenceID) {
            window.location.href = `/api/remediation/downloadEvidence?id=${evidenceID}`;
        }

        function updateTaskStatus(taskID, completed) {
            $.post('/api/remediation/updateTaskStatus', {
                taskID: taskID,
                status: completed ? 'completed' : 'pending'
            }, function(response) {
                if (response.success) {
                    location.reload();
                }
            });
        }
    </script>
</body>
</html> 