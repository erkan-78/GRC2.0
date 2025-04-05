<!DOCTYPE html>
<html>
<head>
    <title>Activity Logs</title>
    <link href="css/admin.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .filters {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }
        
        .filter-item {
            flex: 1;
            min-width: 200px;
        }
        
        .activity-type {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        .activity-type-login { background: #e3f2fd; color: #0d47a1; }
        .activity-type-update { background: #f3e5f5; color: #7b1fa2; }
        .activity-type-create { background: #e8f5e9; color: #2e7d32; }
        .activity-type-delete { background: #fbe9e7; color: #c62828; }
        
        .admin-pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 1rem;
            margin-top: 1rem;
        }
        
        .admin-pagination-info {
            font-size: 0.875rem;
            color: #666;
        }
    </style>
</head>
<body>
    <!--- Check if user is logged in and has admin access --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR NOT (session.isSuperAdmin OR session.isAdmin)>
        <cflocation url="../login.cfm" addtoken="false">
    </cfif>

    <!--- Include header --->
    <cfinclude template="../includes/header.cfm">

    <div class="container">
        <h2 class="page-header">Activity Logs</h2>

        <div class="admin-card">
            <div class="admin-card-header">
                <h5 class="admin-card-title">
                    <cfif session.isSuperAdmin>
                        All Companies Activity Log Management
                    <cfelse>
                        Company Activity Log Management
                    </cfif>
                </h5>
            </div>
            <div class="admin-card-body">
                <div class="filters">
                    <div class="filter-item">
                        <label class="admin-form-label" for="activityType">Activity Type</label>
                        <select class="admin-form-control" id="activityType">
                            <option value="">All Types</option>
                            <option value="LOGIN">Login</option>
                            <option value="LOGOUT">Logout</option>
                            <option value="CREATE">Create</option>
                            <option value="UPDATE">Update</option>
                            <option value="DELETE">Delete</option>
                        </select>
                    </div>
                    
                    <cfif session.isSuperAdmin>
                        <div class="filter-item">
                            <label class="admin-form-label" for="companyFilter">Company</label>
                            <select class="admin-form-control" id="companyFilter">
                                <option value="">All Companies</option>
                            </select>
                        </div>
                    </cfif>
                    
                    <div class="filter-item">
                        <label class="admin-form-label" for="startDate">Start Date</label>
                        <input type="date" class="admin-form-control" id="startDate">
                    </div>
                    
                    <div class="filter-item">
                        <label class="admin-form-label" for="endDate">End Date</label>
                        <input type="date" class="admin-form-control" id="endDate">
                    </div>
                </div>

                <div class="admin-table-responsive">
                    <table class="admin-table" id="logsTable">
                        <thead>
                            <tr>
                                <th>Date/Time</th>
                                <th>User</th>
                                <cfif session.isSuperAdmin>
                                    <th>Company</th>
                                </cfif>
                                <th>Activity Type</th>
                                <th>Description</th>
                                <th>IP Address</th>
                            </tr>
                        </thead>
                        <tbody id="logsBody">
                            <!-- Will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>

                <div class="admin-pagination" id="pagination">
                    <!-- Will be populated by JavaScript -->
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentPage = 1;
        let totalPages = 1;
        const pageSize = 50;
        const isSuperAdmin = <cfoutput>#session.isSuperAdmin#</cfoutput>;

        document.addEventListener('DOMContentLoaded', function() {
            loadActivityLogs();
            if (isSuperAdmin) {
                loadCompanies();
            }

            // Add event listeners for filters
            document.getElementById('activityType').addEventListener('change', () => {
                currentPage = 1;
                loadActivityLogs();
            });

            if (isSuperAdmin) {
                document.getElementById('companyFilter').addEventListener('change', () => {
                    currentPage = 1;
                    loadActivityLogs();
                });
            }

            document.getElementById('startDate').addEventListener('change', () => {
                currentPage = 1;
                loadActivityLogs();
            });

            document.getElementById('endDate').addEventListener('change', () => {
                currentPage = 1;
                loadActivityLogs();
            });
        });

        async function loadActivityLogs() {
            const params = new URLSearchParams({
                page: currentPage,
                pageSize: pageSize,
                activityType: document.getElementById('activityType').value,
                startDate: document.getElementById('startDate').value,
                endDate: document.getElementById('endDate').value
            });

            if (isSuperAdmin && document.getElementById('companyFilter')) {
                params.append('companyID', document.getElementById('companyFilter').value);
            }

            try {
                const response = await fetch(`../api/logger.cfc?method=getActivityLogs&${params}`);
                const data = await response.json();
                
                if (data.success) {
                    const tbody = document.getElementById('logsBody');
                    tbody.innerHTML = '';
                    
                    data.data.forEach(log => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td>${formatDate(log.activityDate)}</td>
                            <td>${log.firstName} ${log.lastName}<br><small>${log.userEmail}</small></td>
                            ${isSuperAdmin ? `<td>${log.companyName || 'N/A'}</td>` : ''}
                            <td><span class="activity-type activity-type-${log.activityType.toLowerCase()}">${log.activityType}</span></td>
                            <td>${log.activityDescription}</td>
                            <td>${log.ipAddress}</td>
                        `;
                        tbody.appendChild(row);
                    });

                    totalPages = Math.ceil(data.total / pageSize);
                    updatePagination();
                } else {
                    console.error('Error loading logs:', data.message);
                }
            } catch (error) {
                console.error('Error loading activity logs:', error);
            }
        }

        async function loadCompanies() {
            try {
                const response = await fetch('../api/company.cfc?method=getAllCompanies');
                const data = await response.json();
                
                if (data.success) {
                    const select = document.getElementById('companyFilter');
                    data.data.forEach(company => {
                        const option = document.createElement('option');
                        option.value = company.companyID;
                        option.textContent = company.name;
                        select.appendChild(option);
                    });
                }
            } catch (error) {
                console.error('Error loading companies:', error);
            }
        }

        function updatePagination() {
            const pagination = document.getElementById('pagination');
            let html = '';

            if (totalPages > 1) {
                html += `<button class="admin-btn admin-btn-secondary" ${currentPage === 1 ? 'disabled' : ''} onclick="changePage(${currentPage - 1})">Previous</button>`;
                html += `<span class="admin-pagination-info">Page ${currentPage} of ${totalPages}</span>`;
                html += `<button class="admin-btn admin-btn-secondary" ${currentPage === totalPages ? 'disabled' : ''} onclick="changePage(${currentPage + 1})">Next</button>`;
            }

            pagination.innerHTML = html;
        }

        function changePage(page) {
            if (page >= 1 && page <= totalPages) {
                currentPage = page;
                loadActivityLogs();
            }
        }

        function formatDate(dateString) {
            return new Date(dateString).toLocaleString();
        }
    </script>
</body>
</html> 