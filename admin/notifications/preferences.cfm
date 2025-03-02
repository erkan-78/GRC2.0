<!DOCTYPE html>
<html>
<head>
    <title>Notification Preferences</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Notification Preferences</h2>
            <div>
                <a href="index.cfm?page=list" class="btn btn-secondary">Back to History</a>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <form id="preferencesForm" method="post" action="/api/notifications/savePreferences">
                    <div class="row">
                        <div class="col-md-6">
                            <h4>Email Notifications</h4>
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Notification Type</th>
                                            <th>Email</th>
                                            <th>In-App</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfoutput query="getNotificationTypes">
                                            <tr>
                                                <td>#typeName#</td>
                                                <td>
                                                    <div class="form-check">
                                                        <input type="checkbox" 
                                                               class="form-check-input" 
                                                               name="email_#typeID#" 
                                                               id="email_#typeID#"
                                                               <cfif listFind(preferences.emailTypes, typeID)>checked</cfif>>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="form-check">
                                                        <input type="checkbox" 
                                                               class="form-check-input" 
                                                               name="inapp_#typeID#" 
                                                               id="inapp_#typeID#"
                                                               <cfif listFind(preferences.inAppTypes, typeID)>checked</cfif>>
                                                    </div>
                                                </td>
                                            </tr>
                                        </cfoutput>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <h4>Reminder Settings</h4>
                            <div class="mb-3">
                                <label class="form-label">Reminder Frequency</label>
                                <select name="reminderFrequency" class="form-select">
                                    <cfoutput>
                                        <option value="never" #preferences.reminderFrequency eq "never" ? "selected" : ""#>Never</option>
                                        <option value="daily" #preferences.reminderFrequency eq "daily" ? "selected" : ""#>Daily</option>
                                        <option value="weekly" #preferences.reminderFrequency eq "weekly" ? "selected" : ""#>Weekly</option>
                                    </cfoutput>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Daily Digest Time</label>
                                <select name="digestTime" class="form-select">
                                    <cfoutput>
                                        <cfloop from="0" to="23" index="hour">
                                            <cfset formattedHour = numberFormat(hour, "00")>
                                            <option value="#formattedHour#:00" 
                                                    #preferences.digestTime eq "#formattedHour#:00" ? "selected" : ""#>
                                                #formattedHour#:00
                                            </option>
                                        </cfloop>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4">
                        <button type="submit" class="btn btn-primary">Save Preferences</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#preferencesForm').submit(function(e) {
                e.preventDefault();
                
                $.post($(this).attr('action'), $(this).serialize(), function(response) {
                    if (response.success) {
                        alert('Preferences saved successfully');
                    } else {
                        alert('Error saving preferences: ' + response.message);
                    }
                });
            });
        });
    </script>
</body>
</html> 