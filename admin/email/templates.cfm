<!DOCTYPE html>
<html>
<head>
    <title>Manage Email Templates</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Email Templates</h2>
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#templateModal">
                Add New Template
            </button>
        </div>

        <!--- Templates List --->
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Template Name</th>
                        <th>Subject</th>
                        <th>Last Modified</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getTemplates">
                        <tr>
                            <td>#templateName#</td>
                            <td>#subject#</td>
                            <td>#dateFormat(lastModified, "yyyy-mm-dd")#</td>
                            <td>
                                <button class="btn btn-sm btn-primary edit-template" 
                                        data-id="#templateID#"
                                        data-name="#templateName#"
                                        data-subject="#subject#"
                                        data-content="#htmlEditFormat(content)#">
                                    Edit
                                </button>
                                <button class="btn btn-sm btn-danger delete-template" 
                                        data-id="#templateID#">
                                    Delete
                                </button>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
    </div>

    <!--- Template Modal --->
    <div class="modal fade" id="templateModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="/api/email/saveTemplate" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title">Email Template</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="templateID" id="templateID">
                        <div class="mb-3">
                            <label for="templateName" class="form-label">Template Name:</label>
                            <input type="text" class="form-control" id="templateName" name="templateName" required>
                        </div>
                        <div class="mb-3">
                            <label for="subject" class="form-label">Subject:</label>
                            <input type="text" class="form-control" id="subject" name="subject" required>
                        </div>
                        <div class="mb-3">
                            <label for="content" class="form-label">Content:</label>
                            <textarea class="form-control" id="content" name="content" rows="10"></textarea>
                        </div>
                        <div class="mb-3">
                            <h6>Available Variables:</h6>
                            <code>{firstName}</code>, <code>{lastName}</code>, <code>{email}</code>, <code>{company}</code>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Save Template</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#content').summernote({
                height: 300,
                toolbar: [
                    ['style', ['style']],
                    ['font', ['bold', 'underline', 'clear']],
                    ['color', ['color']],
                    ['para', ['ul', 'ol', 'paragraph']],
                    ['table', ['table']],
                    ['insert', ['link']],
                    ['view', ['fullscreen', 'codeview']]
                ]
            });

            $('.edit-template').click(function() {
                $('#templateID').val($(this).data('id'));
                $('#templateName').val($(this).data('name'));
                $('#subject').val($(this).data('subject'));
                $('#content').summernote('code', $(this).data('content'));
                $('#templateModal').modal('show');
            });

            $('.delete-template').click(function() {
                if (confirm('Are you sure you want to delete this template?')) {
                    const templateID = $(this).data('id');
                    $.post('/api/email/deleteTemplate', { templateID: templateID }, function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert(response.message);
                        }
                    });
                }
            });
        });
    </script>
</body>
</html> 