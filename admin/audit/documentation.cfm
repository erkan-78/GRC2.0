<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Documentation</title>
    <link href="/assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="/assets/css/font-awesome.min.css" rel="stylesheet">
    <link href="/assets/css/summernote.min.css" rel="stylesheet">
    <link href="/assets/css/dropzone.min.css" rel="stylesheet">
    <link href="/assets/css/custom.css" rel="stylesheet">
</head>
<body>
    <cfinclude template="/includes/header.cfm">
    
    <div class="container-fluid mt-4">
        <div class="row">
            <!-- Control List Sidebar -->
            <div class="col-md-3">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Audit Controls</h5>
                    </div>
                    <div class="card-body">
                        <div class="list-group" id="controlsList">
                            <cfset controls = application.auditService.getAuditControls(url.auditID)>
                            <cfloop query="controls">
                                <a href="##" class="list-group-item list-group-item-action" 
                                   onclick="loadControlDocumentation(#controlID#)">
                                    <h6 class="mb-1">#title#</h6>
                                    <small class="text-muted">
                                        <cfif len(trim(reference))>#reference# - </cfif>
                                        #status#
                                    </small>
                                </a>
                            </cfloop>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-9">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0" id="controlTitle">Select a Control</h5>
                        <button class="btn btn-primary" onclick="showNewDocumentationModal()" id="btnAddDoc" disabled>
                            <i class="fa fa-plus"></i> Add Documentation
                        </button>
                    </div>
                    <div class="card-body">
                        <div id="controlDetails" class="mb-4">
                            <!-- Control details will be loaded here -->
                        </div>
                        
                        <div id="documentationList">
                            <!-- Documentation list will be loaded here -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- New Documentation Modal -->
    <div class="modal fade" id="documentationModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add Documentation</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="documentationForm">
                        <input type="hidden" name="controlID" id="docControlID">
                        <input type="hidden" name="auditID" value="#url.auditID#">
                        
                        <div class="form-group">
                            <label>Documentation Type</label>
                            <select class="form-control" name="documentType" required>
                                <option value="evidence">Evidence</option>
                                <option value="observation">Observation</option>
                                <option value="test_result">Test Result</option>
                                <option value="interview">Interview Notes</option>
                                <option value="analysis">Analysis</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Content</label>
                            <textarea class="form-control" name="content" id="documentationContent"></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label>Attachments</label>
                            <div id="attachmentDropzone" class="dropzone">
                                <div class="dz-message">
                                    Drop files here or click to upload
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveDocumentation()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script src="/assets/js/jquery.min.js"></script>
    <script src="/assets/js/bootstrap.bundle.min.js"></script>
    <script src="/assets/js/summernote.min.js"></script>
    <script src="/assets/js/dropzone.min.js"></script>
    <script>
        let currentControlID = null;
        let dropzone = null;
        
        $(document).ready(function() {
            // Initialize Summernote
            $('##documentationContent').summernote({
                height: 300,
                toolbar: [
                    ['style', ['bold', 'italic', 'underline', 'clear']],
                    ['font', ['strikethrough']],
                    ['para', ['ul', 'ol']],
                    ['insert', ['link']],
                    ['view', ['fullscreen', 'codeview']]
                ]
            });
            
            // Initialize Dropzone
            dropzone = new Dropzone("##attachmentDropzone", {
                url: "/api/audit/documentation/upload",
                autoProcessQueue: false,
                addRemoveLinks: true,
                maxFiles: 10,
                parallelUploads: 10
            });
        });

        function loadControlDocumentation(controlID) {
            currentControlID = controlID;
            $('##docControlID').val(controlID);
            $('##btnAddDoc').prop('disabled', false);
            
            // Load control details
            $.get('/api/audit/controls/' + controlID, function(data) {
                $('##controlTitle').text(data.title);
                $('##controlDetails').html(`
                    <div class="alert alert-info">
                        <h6>Description</h6>
                        <p>${data.description}</p>
                        <hr>
                        <div class="row">
                            <div class="col-md-4">
                                <strong>Reference:</strong> ${data.reference}
                            </div>
                            <div class="col-md-4">
                                <strong>Type:</strong> ${data.type}
                            </div>
                            <div class="col-md-4">
                                <strong>Status:</strong> ${data.status}
                            </div>
                        </div>
                    </div>
                `);
                
                loadDocumentationList(controlID);
            });
        }

        function loadDocumentationList(controlID) {
            $.get('/api/audit/documentation/' + controlID, function(data) {
                let html = '';
                data.forEach(doc => {
                    html += `
                        <div class="card mb-3">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="badge badge-primary">${doc.documentType}</span>
                                    <small class="text-muted ml-2">
                                        Added by ${doc.createdBy} on ${doc.createdDate}
                                    </small>
                                </div>
                                <div class="btn-group">
                                    <button class="btn btn-sm btn-outline-primary" onclick="editDocumentation(${doc.documentationID})">
                                        <i class="fa fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteDocumentation(${doc.documentationID})">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="documentation-content mb-3">
                                    ${doc.content}
                                </div>
                                
                                <cfif doc.attachmentCount gt 0>
                                    <div class="attachments-section">
                                        <h6><i class="fa fa-paperclip"></i> Attachments (${doc.attachmentCount})</h6>
                                        <div class="list-group">
                                            ${getAttachmentsList(doc.documentationID)}
                                        </div>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                    `;
                });
                
                $('##documentationList').html(html || '<div class="alert alert-info">No documentation added yet.</div>');
            });
        }

        function showNewDocumentationModal() {
            $('##documentationForm')[0].reset();
            $('##documentationContent').summernote('code', '');
            dropzone.removeAllFiles();
            $('##documentationModal').modal('show');
        }

        function saveDocumentation() {
            const formData = new FormData($('##documentationForm')[0]);
            formData.append('content', $('##documentationContent').summernote('code'));
            
            // First save the documentation
            $.ajax({
                url: '/api/audit/documentation',
                method: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    // Then upload attachments if any
                    if (dropzone.files.length > 0) {
                        dropzone.options.url = '/api/audit/documentation/' + response.documentationID + '/attachments';
                        dropzone.processQueue();
                    } else {
                        documentationSaved();
                    }
                }
            });
        }

        dropzone.on("queuecomplete", function() {
            documentationSaved();
        });

        function documentationSaved() {
            $('##documentationModal').modal('hide');
            loadDocumentationList(currentControlID);
        }

        function getAttachmentsList(documentationID) {
            let html = '';
            $.ajax({
                url: '/api/audit/documentation/' + documentationID + '/attachments',
                method: 'GET',
                async: false,
                success: function(attachments) {
                    attachments.forEach(att => {
                        html += `
                            <div class="list-group-item d-flex justify-content-between align-items-center">
                                <div>
                                    <i class="fa fa-file"></i>
                                    <span class="ml-2">${att.fileName}</span>
                                    <small class="text-muted ml-2">${formatFileSize(att.fileSize)}</small>
                                </div>
                                <div class="btn-group">
                                    <button class="btn btn-sm btn-outline-primary" onclick="downloadAttachment(${att.attachmentID})">
                                        <i class="fa fa-download"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteAttachment(${att.attachmentID})">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                        `;
                    });
                }
            });
            return html;
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        function downloadAttachment(attachmentID) {
            window.location.href = '/api/audit/documentation/attachment/' + attachmentID + '/download';
        }

        function deleteAttachment(attachmentID) {
            if (confirm('Are you sure you want to delete this attachment?')) {
                $.ajax({
                    url: '/api/audit/documentation/attachment/' + attachmentID,
                    method: 'DELETE',
                    success: function() {
                        loadDocumentationList(currentControlID);
                    }
                });
            }
        }

        function editDocumentation(documentationID) {
            $.get('/api/audit/documentation/' + documentationID, function(doc) {
                $('##documentationForm')[0].reset();
                $('##docControlID').val(doc.controlID);
                $('[name="documentType"]').val(doc.documentType);
                $('##documentationContent').summernote('code', doc.content);
                
                // Load existing attachments
                dropzone.removeAllFiles();
                doc.attachments.forEach(att => {
                    dropzone.emit("addedfile", att);
                    dropzone.emit("complete", att);
                });
                
                $('##documentationModal').modal('show');
            });
        }

        function deleteDocumentation(documentationID) {
            if (confirm('Are you sure you want to delete this documentation?')) {
                $.ajax({
                    url: '/api/audit/documentation/' + documentationID,
                    method: 'DELETE',
                    success: function() {
                        loadDocumentationList(currentControlID);
                    }
                });
            }
        }
    </script>
</body>
</html>
</cfoutput> 