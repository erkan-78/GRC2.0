<!--- Get recent notifications --->
<cfset notificationService = new model.NotificationService()>
<cfset recentNotifications = notificationService.getNotifications(
    userID: session.userID,
    status: "unread",
    page: 1,
    pageSize: 5
)>
<cfset unreadCount = notificationService.getNotificationCount(
    userID: session.userID,
    status: "unread"
)>

<div class="card">
    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Recent Notifications</h5>
        <cfif unreadCount gt 0>
            <span class="badge bg-warning">#unreadCount# Unread</span>
        </cfif>
    </div>
    <div class="card-body p-0">
        <div class="list-group list-group-flush">
            <cfoutput query="recentNotifications">
                <div class="list-group-item list-group-item-action">
                    <div class="d-flex w-100 justify-content-between">
                        <h6 class="mb-1">
                            <span class="badge bg-#typeColor# me-2">#typeName#</span>
                            #subject#
                        </h6>
                        <small>#dateTimeFormat(created, "mm/dd/yyyy HH:nn")#</small>
                    </div>
                    <div class="mt-2">
                        <button type="button" 
                                class="btn btn-sm btn-primary view-notification"
                                data-id="#notificationID#"
                                data-bs-toggle="modal" 
                                data-bs-target="##notificationModal">
                            View
                        </button>
                        <button type="button" 
                                class="btn btn-sm btn-secondary mark-read"
                                data-id="#notificationID#">
                            Mark Read
                        </button>
                    </div>
                </div>
            </cfoutput>
            <cfif !recentNotifications.recordCount>
                <div class="list-group-item text-center text-muted">
                    No unread notifications
                </div>
            </cfif>
        </div>
    </div>
    <div class="card-footer text-end">
        <a href="/admin/notifications/index.cfm" class="btn btn-primary btn-sm">View All</a>
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

<script>
$(document).ready(function() {
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
                button.closest('.list-group-item').fadeOut();
                updateUnreadCount();
            }
        });
    });

    function updateUnreadCount() {
        $.get('/api/notifications/unreadCount', function(response) {
            if (response.success) {
                const badge = $('.card-header .badge');
                if (response.count > 0) {
                    badge.text(response.count + ' Unread').show();
                } else {
                    badge.hide();
                }
            }
        });
    }
});
</script> 