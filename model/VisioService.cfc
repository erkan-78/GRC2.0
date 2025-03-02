component {
    public function init() {
        variables.visioLib = createObject("java", "org.apache.poi.xdgf.usermodel.XDGFShape");
        return this;
    }

    public function exportToVisio(required struct workflow) {
        try {
            // Create new Visio document
            var document = createVisioDocument();
            var page = document.createPage();

            // Add shapes for nodes
            var shapes = {};
            for (var node in workflow.nodes) {
                var shape = addNodeShape(page, node);
                shapes[node.id] = shape;
            }

            // Add connectors for connections
            for (var conn in workflow.connections) {
                addConnector(page, shapes[conn.sourceId], shapes[conn.targetId]);
            }

            // Save to temporary file
            var tempFile = getTempFileName() & ".vsdx";
            document.save(tempFile);

            // Return file info
            return {
                success = true,
                fileUrl = "/temp/" & getFileFromPath(tempFile)
            };
        }
        catch (any e) {
            return {
                success = false,
                message = "Error exporting to Visio: " & e.message
            };
        }
    }

    public function importFromVisio(required string filePath) {
        try {
            // Read Visio file
            var document = readVisioDocument(filePath);
            var page = document.getPages().get(0);

            // Extract nodes
            var nodes = [];
            var shapes = page.getShapes();
            for (var shape in shapes) {
                if (isNodeShape(shape)) {
                    nodes.append({
                        id = "node_" & createUUID(),
                        type = getNodeType(shape),
                        title = shape.getText(),
                        position = {
                            left = shape.getXForm().getPinX() & "px",
                            top = shape.getXForm().getPinY() & "px"
                        }
                    });
                }
            }

            // Extract connections
            var connections = [];
            var connectors = page.getConnects();
            for (var connector in connectors) {
                connections.append({
                    sourceId = findNodeId(nodes, connector.getFromShape()),
                    targetId = findNodeId(nodes, connector.getToShape())
                });
            }

            return {
                success = true,
                workflow = {
                    title = "Imported Workflow",
                    description = "Imported from Visio",
                    nodes = nodes,
                    connections = connections
                }
            };
        }
        catch (any e) {
            return {
                success = false,
                message = "Error importing from Visio: " & e.message
            };
        }
    }

    private function createVisioDocument() {
        // Create new Visio document using POI XDGF
        return createObject("java", "org.apache.poi.xdgf.usermodel.XDGFDocument").init();
    }

    private function readVisioDocument(required string filePath) {
        // Read existing Visio document using POI XDGF
        var fileInputStream = createObject("java", "java.io.FileInputStream").init(filePath);
        return createObject("java", "org.apache.poi.xdgf.usermodel.XDGFDocument").init(fileInputStream);
    }

    private function addNodeShape(required any page, required struct node) {
        // Add shape based on node type
        var shape = page.createShape();
        
        switch (node.type) {
            case "task":
                shape.setMaster("Process");
                break;
            case "approval":
                shape.setMaster("Decision");
                break;
            case "condition":
                shape.setMaster("Diamond");
                break;
        }

        // Set shape properties
        shape.setText(node.title);
        shape.getXForm().setPinX(parseNumber(node.position.left));
        shape.getXForm().setPinY(parseNumber(node.position.top));

        return shape;
    }

    private function addConnector(required any page, required any fromShape, required any toShape) {
        // Add connector between shapes
        var connector = page.createConnector();
        connector.setFromShape(fromShape);
        connector.setToShape(toShape);
        return connector;
    }

    private function isNodeShape(required any shape) {
        // Check if shape represents a node (not a connector or other shape)
        var masterName = shape.getMaster().getName();
        return listFindNoCase("Process,Decision,Diamond", masterName);
    }

    private function getNodeType(required any shape) {
        // Determine node type based on Visio shape
        var masterName = shape.getMaster().getName();
        switch (masterName) {
            case "Process":
                return "task";
            case "Decision":
                return "approval";
            case "Diamond":
                return "condition";
            default:
                return "task";
        }
    }

    private function findNodeId(required array nodes, required any shape) {
        // Find node ID based on shape position
        for (var node in nodes) {
            if (node.position.left == shape.getXForm().getPinX() & "px" &&
                node.position.top == shape.getXForm().getPinY() & "px") {
                return node.id;
            }
        }
        return "";
    }

    private function parseNumber(required string value) {
        // Parse pixel value to number
        return val(replace(value, "px", ""));
    }
} 