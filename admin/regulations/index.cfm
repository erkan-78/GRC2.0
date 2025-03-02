<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Regulation Management</title>
    <link href="/assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="/assets/css/font-awesome.min.css" rel="stylesheet">
    <link href="/assets/css/jstree.min.css" rel="stylesheet">
    <link href="/assets/css/custom.css" rel="stylesheet">
</head>
<body>
    <cfinclude template="/includes/header.cfm">
    
    <div class="container-fluid mt-4">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Regulations</h5>
                    </div>
                    <div class="card-body">
                        <div id="regulationTree"></div>
                    </div>
                    <div class="card-footer">
                        <button class="btn btn-primary btn-sm" onclick="showNewRegulationModal()">
                            <i class="fa fa-plus"></i> New Regulation
                        </button>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-9">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0">Regulation Details</h5>
                        <div class="btn-group">
                            <button class="btn btn-success btn-sm" onclick="submitForApproval()" id="btnSubmitApproval">
                                <i class="fa fa-check"></i> Submit for Approval
                            </button>
                            <button class="btn btn-primary btn-sm" onclick="editRegulation()" id="btnEdit">
                                <i class="fa fa-edit"></i> Edit
                            </button>
                            <button class="btn btn-info btn-sm" onclick="showVersionHistory()" id="btnVersions">
                                <i class="fa fa-history"></i> Versions
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div id="regulationDetails">
                            <!-- Regulation details will be loaded here -->
                        </div>
                        
                        <div class="mt-4">
                            <ul class="nav nav-tabs" id="regulationTabs" role="tablist">
                                <li class="nav-item">
                                    <a class="nav-link active" id="subitems-tab" data-toggle="tab" href="##subitems">
                                        Subitems
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="controls-tab" data-toggle="tab" href="##controls">
                                        Linked Controls
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="policies-tab" data-toggle="tab" href="##policies">
                                        Linked Policies
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="documents-tab" data-toggle="tab" href="##documents">
                                        Documents
                                    </a>
                                </li>
                            </ul>
                            
                            <div class="tab-content mt-3" id="regulationTabContent">
                                <div class="tab-pane fade show active" id="subitems">
                                    <div class="mb-3">
                                        <button class="btn btn-primary btn-sm" onclick="showNewSubitemModal()">
                                            <i class="fa fa-plus"></i> Add Subitem
                                        </button>
                                    </div>
                                    <div id="subitemsList">
                                        <!-- Subitems will be loaded here -->
                                    </div>
                                </div>
                                
                                <div class="tab-pane fade" id="controls">
                                    <div class="mb-3">
                                        <button class="btn btn-primary btn-sm" onclick="showLinkControlModal()">
                                            <i class="fa fa-link"></i> Link Control
                                        </button>
                                    </div>
                                    <div id="linkedControlsList">
                                        <!-- Linked controls will be loaded here -->
                                    </div>
                                </div>
                                
                                <div class="tab-pane fade" id="policies">
                                    <div class="mb-3">
                                        <button class="btn btn-primary btn-sm" onclick="showLinkPolicyModal()">
                                            <i class="fa fa-link"></i> Link Policy
                                        </button>
                                    </div>
                                    <div id="linkedPoliciesList">
                                        <!-- Linked policies will be loaded here -->
                                    </div>
                                </div>
                                
                                <div class="tab-pane fade" id="documents">
                                    <div class="mb-3">
                                        <button class="btn btn-primary btn-sm" onclick="showUploadDocumentModal()">
                                            <i class="fa fa-upload"></i> Upload Document
                                        </button>
                                    </div>
                                    <div id="documentsList">
                                        <!-- Documents will be loaded here -->
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modals -->
    <div class="modal fade" id="regulationModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">New Regulation</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="regulationForm">
                        <div class="form-group">
                            <label>Title</label>
                            <input type="text" class="form-control" name="title" required>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <textarea class="form-control" name="description" rows="4"></textarea>
                        </div>
                        <div class="form-group">
                            <label>Document</label>
                            <input type="file" class="form-control-file" name="document">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveRegulation()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="subitemModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">New Subitem</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="subitemForm">
                        <div class="form-group">
                            <label>Parent Item</label>
                            <select class="form-control" name="parentID" id="parentSubitem">
                                <option value="0">None (Top Level)</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Title</label>
                            <input type="text" class="form-control" name="title" required>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <textarea class="form-control" name="description" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveSubitem()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script src="/assets/js/jquery.min.js"></script>
    <script src="/assets/js/bootstrap.bundle.min.js"></script>
    <script src="/assets/js/jstree.min.js"></script>
    <script>
        let currentRegulationID = null;
        
        // Initialize regulation tree
        $('##regulationTree').jstree({
            'core': {
                'data': {
                    'url': '/api/regulations/tree',
                    'dataType': 'json'
                }
            }
        }).on('select_node.jstree', function(e, data) {
            loadRegulationDetails(data.node.id);
        });

        function loadRegulationDetails(regulationID) {
            currentRegulationID = regulationID;
            $.get('/api/regulations/' + regulationID, function(data) {
                $('##regulationDetails').html(`
                    <h3>${data.title}</h3>
                    <p class="text-muted">Version ${data.version} - ${data.status}</p>
                    <div class="mt-3">${data.description}</div>
                `);
                
                loadSubitems(regulationID);
                loadLinkedControls(regulationID);
                loadLinkedPolicies(regulationID);
                loadDocuments(regulationID);
                
                updateButtonStates(data.status);
            });
        }

        function loadSubitems(regulationID) {
            $.get('/api/regulations/' + regulationID + '/subitems', function(data) {
                let html = '<div class="list-group">';
                data.forEach(item => {
                    html += `
                        <div class="list-group-item">
                            <div class="d-flex justify-content-between align-items-center">
                                <h6 class="mb-1">${item.title}</h6>
                                <div class="btn-group">
                                    <button class="btn btn-sm btn-outline-primary" onclick="editSubitem(${item.subitemID})">
                                        <i class="fa fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteSubitem(${item.subitemID})">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                            <p class="mb-1">${item.description}</p>
                            <small>Level ${item.level}</small>
                        </div>
                    `;
                });
                html += '</div>';
                $('##subitemsList').html(html);
            });
        }

        function updateButtonStates(status) {
            $('##btnSubmitApproval').prop('disabled', status !== 'draft');
            $('##btnEdit').prop('disabled', status === 'pending_approval');
        }

        function showNewRegulationModal() {
            $('##regulationForm')[0].reset();
            $('##regulationModal .modal-title').text('New Regulation');
            $('##regulationModal').modal('show');
        }

        function saveRegulation() {
            const formData = new FormData($('##regulationForm')[0]);
            $.ajax({
                url: '/api/regulations',
                method: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    $('##regulationModal').modal('hide');
                    $('##regulationTree').jstree(true).refresh();
                }
            });
        }

        function showNewSubitemModal() {
            $('##subitemForm')[0].reset();
            $('##subitemModal').modal('show');
            
            // Load parent options
            $.get('/api/regulations/' + currentRegulationID + '/subitems', function(data) {
                let options = '<option value="0">None (Top Level)</option>';
                data.forEach(item => {
                    if (item.level < 3) {
                        options += `<option value="${item.subitemID}">${item.title}</option>`;
                    }
                });
                $('##parentSubitem').html(options);
            });
        }

        function saveSubitem() {
            const formData = new FormData($('##subitemForm')[0]);
            formData.append('regulationID', currentRegulationID);
            
            $.ajax({
                url: '/api/regulations/subitems',
                method: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    $('##subitemModal').modal('hide');
                    loadSubitems(currentRegulationID);
                }
            });
        }

        // Additional functions for handling controls, policies, and documents
        function loadLinkedControls(regulationID) {
            $.get('/api/regulations/' + regulationID + '/controls', function(data) {
                let html = '<div class="table-responsive"><table class="table">';
                html += '<thead><tr><th>Control</th><th>Description</th><th>Actions</th></tr></thead><tbody>';
                data.forEach(control => {
                    html += `
                        <tr>
                            <td>${control.controlTitle}</td>
                            <td>${control.controlDescription}</td>
                            <td>
                                <button class="btn btn-sm btn-danger" onclick="unlinkControl(${control.controlID})">
                                    <i class="fa fa-unlink"></i>
                                </button>
                            </td>
                        </tr>
                    `;
                });
                html += '</tbody></table></div>';
                $('##linkedControlsList').html(html);
            });
        }

        function loadLinkedPolicies(regulationID) {
            $.get('/api/regulations/' + regulationID + '/policies', function(data) {
                let html = '<div class="table-responsive"><table class="table">';
                html += '<thead><tr><th>Policy</th><th>Version</th><th>Actions</th></tr></thead><tbody>';
                data.forEach(policy => {
                    html += `
                        <tr>
                            <td>${policy.policyTitle}</td>
                            <td>${policy.policyVersion}</td>
                            <td>
                                <button class="btn btn-sm btn-danger" onclick="unlinkPolicy(${policy.policyID})">
                                    <i class="fa fa-unlink"></i>
                                </button>
                            </td>
                        </tr>
                    `;
                });
                html += '</tbody></table></div>';
                $('##linkedPoliciesList').html(html);
            });
        }

        function loadDocuments(regulationID) {
            $.get('/api/regulations/' + regulationID + '/documents', function(data) {
                let html = '<div class="table-responsive"><table class="table">';
                html += '<thead><tr><th>Document</th><th>Version</th><th>Upload Date</th><th>Actions</th></tr></thead><tbody>';
                data.forEach(doc => {
                    html += `
                        <tr>
                            <td>${doc.fileName}</td>
                            <td>${doc.version}</td>
                            <td>${doc.uploadDate}</td>
                            <td>
                                <div class="btn-group">
                                    <button class="btn btn-sm btn-primary" onclick="downloadDocument(${doc.documentID})">
                                        <i class="fa fa-download"></i>
                                    </button>
                                    <button class="btn btn-sm btn-danger" onclick="deleteDocument(${doc.documentID})">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    `;
                });
                html += '</tbody></table></div>';
                $('##documentsList').html(html);
            });
        }
    </script>
</body>
</html>
</cfoutput> 