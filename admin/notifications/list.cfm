<!DOCTYPE html>
<html>
<head>
    <title>Notification History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Notification History</h2>
            <div>
                <a href="index.cfm?page=preferences" class="btn btn-primary">Notification Preferences</a>
            </div>
        </div>

        <!--- Filter Form --->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" class="row g-3">
                    <input type="hidden" name="page" value="list">
                    
                    <div class="col-md-3">
                        <label class="form-label">Date Range</label>
                        <input type="text" class="form-control" id="dateRange" name="dateRange">
                        <input type="hidden" name="startDate" id="startDate">
                        <input type="hidden" name="endDate" id="endDate">
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label">Type</label>
                        <select name="type" class="form-select">
                            <option value="">All Types</option>
                            <cfoutput query="getNotificationTypes">
                                <option value="#typeID#" <cfif url.type eq typeID>selected</cfif>>#typeName#</option>
                            </cfoutput>
                        </select>
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select">
                            <option value="">All Status</option>
                            <option value="unread" <cfif url.status eq "unread">selected</cfif>>Unread</option>
                            <option value="read" <cfif url.status eq "read">selected</cfif>>Read</option>
                        </select>
                    </div>
                    
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary">Apply Filters</button>
                        <a href="index.cfm?page=list" class="btn btn-secondary ms-2">Reset</a>
                    </div>
                </form>
            </div>
        </div>

        <!--- Notifications Table --->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Date/Time</th>
                                <th>Type</th>
                                <th>Subject</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="getNotifications">
                                <tr class="#status eq 'unread' ? 'table-active' : ''#">
                                    <td>#dateTimeFormat(created, "yyyy-mm-dd HH:nn:ss")#</td>
                                    <td>
                                        <span class="badge bg-#typeColor#">#typeName#</span>
                                    </td>
                                    <td>#subject#</td>
                                    <td>
                                        <span class="badge bg-#status eq 'unread' ? 'warning' : 'secondary'#">
                                            #status#
                                        </span>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <button type="button" 
                                                    class="btn btn-sm btn-primary view-notification"
                                                    data-id="#notificationID#"
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="##notificationModal">
                                                View
                                            </button>
                                            <button type="button" 
                                                    class="btn btn-sm btn-secondary mark-read"
                                                    data-id="#notificationID#"
                                                    #status eq 'read' ? 'disabled' : ''#>
                                                Mark Read
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>

                <!--- Pagination --->
                <cfset totalPages = ceiling(totalRecords/pageSize)>
                <cfif totalPages gt 1>
                    <nav class="mt-3">
                        <ul class="pagination justify-content-center">
                            <cfoutput>
                                <li class="page-item #currentPage eq 1 ? 'disabled' : ''#">
                                    <a class="page-link" href="index.cfm?page=list&p=#currentPage-1#">&laquo;</a>
                                </li>
                                <cfloop from="1" to="#totalPages#" index="i">
                                    <li class="page-item #currentPage eq i ? 'active' : ''#">
                                        <a class="page-link" href="index.cfm?page=list&p=#i#">#i#</a>
                                    </li>
                                </cfloop>
                                <li class="page-item #currentPage eq totalPages ? 'disabled' : ''#">
                                    <a class="page-link" href="index.cfm?page=list&p=#currentPage+1#">&raquo;</a>
                                </li>
                            </cfoutput>
                        </ul>
                    </nav>
                </cfif>
            </div>
        </div>
    </div>

    <!--- Notification Modal --->
    <div class="modal fade" id="notificationModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Notification Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="notificationContent"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
    <script>
        $(document).ready(function() {
            // Initialize date range picker
            $('#dateRange').daterangepicker({
                autoUpdateInput: false,
                locale: {
                    cancelLabel: 'Clear'
                }
            });

            $('#dateRange').on('apply.daterangepicker', function(ev, picker) {
                $(this).val(picker.startDate.format('MM/DD/YYYY') + ' - ' + picker.endDate.format('MM/DD/YYYY'));
                $('#startDate').val(picker.startDate.format('YYYY-MM-DD'));
                $('#endDate').val(picker.endDate.format('YYYY-MM-DD'));
            });

            $('#dateRange').on('cancel.daterangepicker', function(ev, picker) {
                $(this).val('');
                $('#startDate').val('');
                $('#endDate').val('');
            });

            // View notification
            $('.view-notification').click(function() {
                const notificationID = $(this).data('id');
                $.get('/api/notifications/get', { id: notificationID }, function(response) {
                    if (response.success) {
                        $('#notificationContent').html(response.content);
                    }
                });
            });

            // Mark as read
            $('.mark-read').click(function() {
                const notificationID = $(this).data('id');
                const button = $(this);
                $.post('/api/notifications/markRead', { id: notificationID }, function(response) {
                    if (response.success) {
                        button.prop('disabled', true);
                        button.closest('tr').removeClass('table-active');
                    }
                });
            });
        });
    </script>
</body>
</html> 