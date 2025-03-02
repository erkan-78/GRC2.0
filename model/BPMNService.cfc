component {
    public function init() {
        return this;
    }

    public function exportToBPMN(required struct workflow) {
        try {
            // Create BPMN XML structure
            var bpmn = '<?xml version="1.0" encoding="UTF-8"?>';
            bpmn &= '<bpmn:definitions xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL" ';
            bpmn &= 'xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" ';
            bpmn &= 'xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" ';
            bpmn &= 'xmlns:di="http://www.omg.org/spec/DD/20100524/DI" ';
            bpmn &= 'id="Definitions_' & createUUID() & '" ';
            bpmn &= 'targetNamespace="http://bpmn.io/schema/bpmn">';

            // Add process
            bpmn &= '<bpmn:process id="Process_' & createUUID() & '" isExecutable="false">';

            // Add start event
            var startEventId = "StartEvent_" & createUUID();
            bpmn &= '<bpmn:startEvent id="#startEventId#" name="Start" />';

            // Add nodes
            var nodeElements = "";
            var sequenceFlows = "";
            var startNodeId = "";

            // Find start node (node without incoming connections)
            for (var node in workflow.nodes) {
                var hasIncoming = false;
                for (var conn in workflow.connections) {
                    if (conn.targetId == node.id) {
                        hasIncoming = true;
                        break;
                    }
                }
                if (!hasIncoming) {
                    startNodeId = node.id;
                    break;
                }
            }

            // Add first sequence flow from start event to first node
            if (len(startNodeId)) {
                var firstFlowId = "Flow_" & createUUID();
                sequenceFlows &= '<bpmn:sequenceFlow id="#firstFlowId#" sourceRef="#startEventId#" targetRef="#startNodeId#" />';
            }

            // Add nodes and connections
            for (var node in workflow.nodes) {
                var nodeId = node.id;
                
                // Convert node type to BPMN element
                switch (node.type) {
                    case "task":
                        nodeElements &= '<bpmn:task id="#nodeId#" name="#xmlFormat(node.title)#">';
                        nodeElements &= '</bpmn:task>';
                        break;
                    case "approval":
                        nodeElements &= '<bpmn:userTask id="#nodeId#" name="#xmlFormat(node.title)#">';
                        nodeElements &= '</bpmn:userTask>';
                        break;
                    case "condition":
                        nodeElements &= '<bpmn:exclusiveGateway id="#nodeId#" name="#xmlFormat(node.title)#">';
                        nodeElements &= '</bpmn:exclusiveGateway>';
                        break;
                }
            }

            // Add sequence flows
            for (var conn in workflow.connections) {
                var flowId = "Flow_" & createUUID();
                sequenceFlows &= '<bpmn:sequenceFlow id="#flowId#" sourceRef="#conn.sourceId#" targetRef="#conn.targetId#" />';
            }

            // Add end event
            var endEventId = "EndEvent_" & createUUID();
            bpmn &= nodeElements;
            bpmn &= sequenceFlows;
            bpmn &= '<bpmn:endEvent id="#endEventId#" name="End" />';

            // Close process and definitions
            bpmn &= '</bpmn:process>';

            // Add diagram information
            bpmn &= '<bpmndi:BPMNDiagram id="BPMNDiagram_1">';
            bpmn &= '<bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_1">';
            
            // Add diagram elements for each node
            for (var node in workflow.nodes) {
                bpmn &= '<bpmndi:BPMNShape id="#node.id#_di" bpmnElement="#node.id#">';
                bpmn &= '<dc:Bounds x="#parseNumber(node.position.left)#" y="#parseNumber(node.position.top)#" width="100" height="80" />';
                bpmn &= '</bpmndi:BPMNShape>';
            }

            // Add diagram elements for connections
            for (var conn in workflow.connections) {
                bpmn &= '<bpmndi:BPMNEdge id="#conn.sourceId#_to_#conn.targetId#_di" bpmnElement="#conn.sourceId#_to_#conn.targetId#">';
                bpmn &= '<di:waypoint x="#parseNumber(workflow.nodes[conn.sourceId].position.left) + 50#" y="#parseNumber(workflow.nodes[conn.sourceId].position.top) + 40#" />';
                bpmn &= '<di:waypoint x="#parseNumber(workflow.nodes[conn.targetId].position.left) + 50#" y="#parseNumber(workflow.nodes[conn.targetId].position.top) + 40#" />';
                bpmn &= '</bpmndi:BPMNEdge>';
            }

            bpmn &= '</bpmndi:BPMNPlane>';
            bpmn &= '</bpmndi:BPMNDiagram>';
            bpmn &= '</bpmn:definitions>';

            // Save to temporary file
            var tempFile = getTempFileName() & ".bpmn";
            fileWrite(tempFile, bpmn);

            return {
                success = true,
                fileUrl = "/temp/" & getFileFromPath(tempFile)
            };
        }
        catch (any e) {
            return {
                success = false,
                message = "Error exporting to BPMN: " & e.message
            };
        }
    }

    private function parseNumber(required string value) {
        return val(replace(value, "px", ""));
    }
} 