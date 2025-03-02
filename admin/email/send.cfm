<!DOCTYPE html>
<html>
<head>
    <title>Send Email</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
</head>
<body>
    <div class="container mt-4">
        <h2>Send Email</h2>
        
        <form action="/api/email/send" method="post" class="mt-4">
            <div class="mb-3">
                <label class="form-label">Select Recipients By:</label>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="selectionType" id="userSelection" value="users" checked>
                    <label class="form-check-label" for="userSelection">Individual Users</label>
                </div>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="selectionType" id="companySelection" value="company">
                    <label class="form-check-label" for="companySelection">Company</label>
                </div>
            </div>

            <div id="userSelectionDiv" class="mb-3">
                <label for="selectedUsers" class="form-label">Select Users:</label>
                <select name="selectedUsers" id="selectedUsers" class="form-control select2" multiple>
                    <cfoutput query="getUsers">
                        <option value="#userID#">#firstName# #lastName# (#email#)</option>
                    </cfoutput>
                </select>
            </div>

            <div id="companySelectionDiv" class="mb-3" style="display: none;">
                <label for="selectedCompany" class="form-label">Select Company:</label>
                <select name="selectedCompany" id="selectedCompany" class="form-control select2">
                    <cfoutput query="getCompanies">
                        <option value="#companyID#">#companyName#</option>
                    </cfoutput>
                </select>
            </div>

            <div class="mb-3">
                <label for="templateID" class="form-label">Email Template:</label>
                <select name="templateID" id="templateID" class="form-control select2" required>
                    <option value="">Select a template...</option>
                    <cfoutput query="getTemplates">
                        <option value="#templateID#">#templateName# - #subject#</option>
                    </cfoutput>
                </select>
            </div>

            <div class="mb-3">
                <label for="subject" class="form-label">Subject:</label>
                <input type="text" name="subject" id="subject" class="form-control" required>
            </div>

            <div class="mb-3">
                <label for="emailContent" class="form-label">Email Content:</label>
                <textarea name="emailContent" id="emailContent" class="form-control" rows="10" required></textarea>
            </div>

            <button type="submit" class="btn btn-primary">Send Email</button>
            <a href="templates.cfm" class="btn btn-secondary">Manage Templates</a>
        </form>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        $(document).ready(function() {
            $('.select2').select2();

            $('input[name="selectionType"]').change(function() {
                if ($(this).val() === 'users') {
                    $('#userSelectionDiv').show();
                    $('#companySelectionDiv').hide();
                } else {
                    $('#userSelectionDiv').hide();
                    $('#companySelectionDiv').show();
                }
            });

            $('#templateID').change(function() {
                const templateID = $(this).val();
                if (templateID) {
                    $.get('/api/email/getTemplate', { templateID: templateID }, function(data) {
                        $('#subject').val(data.subject);
                        $('#emailContent').val(data.content);
                    });
                }
            });
        });
    </script>
</body>
</html> 