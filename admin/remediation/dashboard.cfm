<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('remediation_dashboard', 'Remediation Dashboard')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .plan-card {
            transition: transform 0.2s;
        }
        .plan-card:hover {
            transform: translateY(-5px);
        }
        .task-progress {
            height: 8px;
        }
        .priority-high { border-left: 4px solid #dc3545; }
        .priority-medium { border-left: 4px solid #ffc107; }
        .priority-low { border-left: 4px solid #28a745; }
    </style>
</head>
<body>
    <cfset remediationService = new model.RemediationService()>
    <cfset plans = remediationService.getCompanyRemediationPlans(session.companyID)>
    <cfset stats = remediationService.getCompanyRemediationStats(session.companyID)>

    <div class="container-fluid mt-4">
        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('active_plans', 'Active Plans')#</cfoutput></h6>
                        <h2 class="mb-0"><cfoutput>#stats.activePlans#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('overdue_tasks', 'Overdue Tasks')#</cfoutput></h6>
                        <h2 class="mb-0"><cfoutput>#stats.overdueTasks#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('completed_tasks', 'Completed Tasks')#</cfoutput></h6>
                        <h2 class="mb-0"><cfoutput>#stats.completedTasks#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-info text-white">
                    <div class="card-body">
                        <h6 class="card-title"><cfoutput>#getLabel('completion_rate', 'Completion Rate')#</cfoutput></h6>
                        <h2 class="mb-0"><cfoutput>#stats.completionRate#%</cfoutput></h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="row mb-4">
            <div class="col">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3">
                                <label class="form-label"><cfoutput>#getLabel('status', 'Status')#</cfoutput></label>
                                <select class="form-select" id="statusFilter">
                                    <option value=""><cfoutput>#getLabel('all', 'All')#</cfoutput></option>
                                    <option value="pending"><cfoutput>#getLabel('pending', 'Pending')#</cfoutput></option>
                                    <option value="in_progress"><cfoutput>#getLabel('in_progress', 'In Progress')#</cfoutput></option>
                                    <option value="completed"><cfoutput>#getLabel('completed', 'Completed')#</cfoutput></option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label"><cfoutput>#getLabel('priority', 'Priority')#</cfoutput></label>
                                <select class="form-select" id="priorityFilter">
                                    <option value=""><cfoutput>#getLabel('all', 'All')#</cfoutput></option>
                                    <option value="high"><cfoutput>#getLabel('high', 'High')#</cfoutput></option>
                                    <option value="medium"><cfoutput>#getLabel('medium', 'Medium')#</cfoutput></option>
                                    <option value="low"><cfoutput>#getLabel('low', 'Low')#</cfoutput></option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label"><cfoutput>#getLabel('assignee', 'Assignee')#</cfoutput></label>
                                <select class="form-select" id="assigneeFilter">
                                    <option value=""><cfoutput>#getLabel('all', 'All')#</cfoutput></option>
                                    <cfoutput query="remediationService.getCompanyUsers(session.companyID)">
                                        <option value="#userID#">#firstName# #lastName#</option>
                                    </cfoutput>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label"><cfoutput>#getLabel('search', 'Search')#</cfoutput></label>
                                <input type="text" class="form-control" id="searchFilter" placeholder="Search plans...">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Remediation Plans -->
        <div class="row" id="plansList">
            <cfoutput query="plans">
                <div class="col-md-6 mb-4">
                    <div class="card plan-card priority-#priority#">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">#controlTitle#</h5>
                                <span class="badge bg-#status eq 'completed' ? 'success' : 
                                                (status eq 'in_progress' ? 'info' : 'secondary')#">
                                    #getLabel('status_' & status, status)#
                                </span>
                            </div>
                            <small class="text-muted">Audit: #auditReference#</small>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <small>#completedTasks# of #totalTasks# tasks completed</small>
                                    <small>#numberFormat((completedTasks/totalTasks)*100, '99.9')#%</small>
                                </div>
                                <div class="progress task-progress">
                                    <div class="progress-bar" role="progressbar" 
                                         style="width: #numberFormat((completedTasks/totalTasks)*100, '99.9')#%"></div>
                                </div>
                            </div>
                            
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <small class="text-muted">
                                        <i class="fas fa-calendar"></i> Created: #dateFormat(createdDate, "mmm d, yyyy")#
                                    </small>
                                </div>
                                <div>
                                    <button type="button" class="btn btn-sm btn-primary" 
                                            onclick="location.href='plan.cfm?id=#planID#'">
                                        <i class="fas fa-tasks"></i> #getLabel('manage', 'Manage')#
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </cfoutput>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterPlans() {
            const status = $('#statusFilter').val();
            const priority = $('#priorityFilter').val();
            const assignee = $('#assigneeFilter').val();
            const search = $('#searchFilter').val().toLowerCase();

            $('.plan-card').each(function() {
                const card = $(this);
                let show = true;

                if (status && card.find('.badge').text().toLowerCase() !== status) show = false;
                if (priority && !card.hasClass('priority-' + priority)) show = false;
                if (assignee && card.data('assignee') !== assignee) show = false;
                if (search && !card.text().toLowerCase().includes(search)) show = false;

                card.closest('.col-md-6')[show ? 'show' : 'hide']();
            });
        }

        $('#statusFilter, #priorityFilter, #assigneeFilter').change(filterPlans);
        $('#searchFilter').on('input', filterPlans);
    </script>
</body>
</html> 