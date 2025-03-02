<!DOCTYPE html>
<html>
<head>
    <title><cfoutput>#getLabel('workflow_designer', 'Workflow Designer')#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        #workflow-canvas {
            height: 600px;
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            position: relative;
        }
        .workflow-node {
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            background: white;
            cursor: move;
            max-width: 200px;
            position: absolute;
        }
        .workflow-node.task {
            background: #e3f2fd;
        }
        .workflow-node.approval {
            background: #fff3e0;
        }
        .workflow-node.condition {
            background: #f3e5f5;
        }
        .endpoint {
            width: 12px;
            height: 12px;
            background: #007bff;
            cursor: pointer;
            position: absolute;
        }
        .controls-list {
            max-height: 300px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <cfset workflowService = new model.WorkflowService()>
    <cfif structKeyExists(url, "id")>
        <cfset workflow = workflowService.getWorkflow(url.id)>
    </cfif>

    <div class="container-fluid mt-4">
        <div class="row mb-4">
            <div class="col">
                <div class="d-flex justify-content-between align-items-center">
                    <h2>
                        <cfoutput>
                            <cfif structKeyExists(url, "id")>
                                #getLabel('edit_workflow', 'Edit Workflow')#: #workflow.title#
                            <cfelse>
                                #getLabel('new_workflow', 'New Workflow')#
                            </cfif>
                        </cfoutput>
                    </h2>
                    <div>
                        <button type="button" class="btn btn-secondary" onclick="location.href='list.cfm'">
                            <i class="fas fa-arrow-left"></i> <cfoutput>#getLabel('back_to_list', 'Back to List')#</cfoutput>
                        </button>
                        <button type="button" class="btn btn-primary" onclick="saveWorkflow()">
                            <i class="fas fa-save"></i> <cfoutput>#getLabel('save_workflow', 'Save Workflow')#</cfoutput>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Workflow Canvas -->
            <div class="col-md-9">
                <div class="card">
                    <div class="card-header">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><cfoutput>#getLabel('workflow_diagram', 'Workflow Diagram')#</cfoutput></h5>
                            <div class="btn-group">
                                <button type="button" class="btn btn-sm btn-outline-primary" onclick="addNode('task')">
                                    <i class="fas fa-tasks"></i> <cfoutput>#getLabel('add_task', 'Add Task')#</cfoutput>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-primary" onclick="addNode('approval')">
                                    <i class="fas fa-check-circle"></i> <cfoutput>#getLabel('add_approval', 'Add Approval')#</cfoutput>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-primary" onclick="addNode('condition')">
                                    <i class="fas fa-code-branch"></i> <cfoutput>#getLabel('add_condition', 'Add Condition')#</cfoutput>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div id="workflow-canvas"></div>
                    </div>
                </div>
            </div>

            <!-- Workflow Properties -->
            <div class="col-md-3">
                <div class="card mb-3">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('workflow_properties', 'Workflow Properties')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('workflow_title', 'Workflow Title')#</cfoutput></label>
                            <input type="text" class="form-control" id="workflowTitle" 
                                   value="<cfoutput>#structKeyExists(url, 'id') ? workflow.title : ''#</cfoutput>">
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('workflow_description', 'Description')#</cfoutput></label>
                            <textarea class="form-control" id="workflowDescription" rows="3"><cfoutput>#structKeyExists(url, 'id') ? workflow.description : ''#</cfoutput></textarea>
                        </div>
                    </div>
                </div>

                <!-- Node Properties (displayed when a node is selected) -->
                <div class="card" id="nodeProperties" style="display: none;">
                    <div class="card-header">
                        <h5 class="mb-0"><cfoutput>#getLabel('node_properties', 'Node Properties')#</cfoutput></h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('node_title', 'Node Title')#</cfoutput></label>
                            <input type="text" class="form-control" id="nodeTitle">
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('node_type', 'Node Type')#</cfoutput></label>
                            <input type="text" class="form-control" id="nodeType" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><cfoutput>#getLabel('controls', 'Controls')#</cfoutput></label>
                            <div class="controls-list">
                                <cfoutput query="workflowService.getControls(session.companyID)">
                                    <div class="form-check">
                                        <input class="form-check-input node-control" type="checkbox" 
                                               value="#controlID#" id="control#controlID#">
                                        <label class="form-check-label" for="control#controlID#">
                                            #title#
                                        </label>
                                    </div>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jsPlumb/2.15.6/js/jsplumb.min.js"></script>
    <script>
        let jsPlumbInstance;
        let selectedNode = null;
        let nodeCounter = 0;

        // Initialize jsPlumb
        jsPlumb.ready(function() {
            jsPlumbInstance = jsPlumb.getInstance({
                Connector: ["Bezier", { curviness: 50 }],
                Endpoint: ["Dot", { radius: 5 }],
                PaintStyle: { stroke: "#007bff", strokeWidth: 2 },
                HoverPaintStyle: { stroke: "#0056b3" },
                ConnectionOverlays: [
                    ["Arrow", { location: 1, width: 10, length: 10 }]
                ],
                Container: "workflow-canvas"
            });

            // Load existing workflow if editing
            <cfif structKeyExists(url, "id")>
                loadWorkflow(<cfoutput>#url.id#</cfoutput>);
            </cfif>
        });

        function addNode(type) {
            nodeCounter++;
            const node = document.createElement('div');
            node.id = `node_${type}_${nodeCounter}`;
            node.className = `workflow-node ${type}`;
            node.innerHTML = `<div>${getLabel(type)}</div>`;
            node.style.left = '50px';
            node.style.top = '50px';

            document.getElementById('workflow-canvas').appendChild(node);

            jsPlumbInstance.draggable(node);
            jsPlumbInstance.addEndpoint(node, { anchor: "Right" }, { isSource: true });
            jsPlumbInstance.addEndpoint(node, { anchor: "Left" }, { isTarget: true });

            // Make node selectable
            node.addEventListener('click', function(e) {
                e.stopPropagation();
                selectNode(node);
            });
        }

        function selectNode(node) {
            if (selectedNode) {
                selectedNode.style.border = '1px solid #ccc';
            }
            selectedNode = node;
            node.style.border = '2px solid #007bff';
            
            // Show node properties
            document.getElementById('nodeProperties').style.display = 'block';
            document.getElementById('nodeTitle').value = node.innerText;
            document.getElementById('nodeType').value = node.className.split(' ')[1];
            
            // Load node controls
            loadNodeControls(node.id);
        }

        function loadNodeControls(nodeId) {
            // Clear existing selections
            document.querySelectorAll('.node-control').forEach(cb => cb.checked = false);
            
            // Load saved controls for the node
            const controls = getNodeControls(nodeId);
            controls.forEach(controlId => {
                document.getElementById(`control${controlId}`).checked = true;
            });
        }

        function saveWorkflow() {
            const workflowData = {
                title: document.getElementById('workflowTitle').value,
                description: document.getElementById('workflowDescription').value,
                nodes: [],
                connections: []
            };

            // Save nodes
            document.querySelectorAll('.workflow-node').forEach(node => {
                workflowData.nodes.push({
                    id: node.id,
                    type: node.className.split(' ')[1],
                    title: node.innerText,
                    position: {
                        left: node.style.left,
                        top: node.style.top
                    },
                    controls: getNodeControls(node.id)
                });
            });

            // Save connections
            jsPlumbInstance.getAllConnections().forEach(conn => {
                workflowData.connections.push({
                    sourceId: conn.sourceId,
                    targetId: conn.targetId
                });
            });

            // Save to server
            $.post('/api/workflow/save', workflowData, function(response) {
                if (response.success) {
                    location.href = 'list.cfm';
                } else {
                    alert(response.message);
                }
            });
        }

        function loadWorkflow(workflowId) {
            $.get(`/api/workflow/get?id=${workflowId}`, function(workflow) {
                // Load nodes
                workflow.nodes.forEach(node => {
                    addNode(node.type);
                    const nodeElement = document.getElementById(node.id);
                    nodeElement.style.left = node.position.left;
                    nodeElement.style.top = node.position.top;
                    nodeElement.innerText = node.title;
                });

                // Load connections
                workflow.connections.forEach(conn => {
                    jsPlumbInstance.connect({
                        source: conn.sourceId,
                        target: conn.targetId
                    });
                });
            });
        }

        // Clear node selection when clicking canvas
        document.getElementById('workflow-canvas').addEventListener('click', function(e) {
            if (e.target.id === 'workflow-canvas') {
                if (selectedNode) {
                    selectedNode.style.border = '1px solid #ccc';
                    selectedNode = null;
                    document.getElementById('nodeProperties').style.display = 'none';
                }
            }
        });

        // Update node title when changed
        document.getElementById('nodeTitle').addEventListener('change', function(e) {
            if (selectedNode) {
                selectedNode.innerText = e.target.value;
            }
        });
    </script>
</body>
</html> 