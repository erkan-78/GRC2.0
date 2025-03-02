component {
    public function init() {
        return this;
    }

    public function exportToXML(required struct workflow) {
        try {
            // Create XML structure
            var xml = '<?xml version="1.0" encoding="UTF-8"?>';
            xml &= '<workflow xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ';
            xml &= 'xsi:noNamespaceSchemaLocation="workflow.xsd">';

            // Add workflow properties
            xml &= '<properties>';
            xml &= '<title>' & xmlFormat(workflow.title) & '</title>';
            xml &= '<description>' & xmlFormat(workflow.description) & '</description>';
            xml &= '<created>' & dateFormat(now(), "yyyy-mm-dd") & 'T' & timeFormat(now(), "HH:mm:ss") & '</created>';
            xml &= '</properties>';

            // Add nodes
            xml &= '<nodes>';
            for (var node in workflow.nodes) {
                xml &= '<node id="#xmlFormat(node.id)#" type="#xmlFormat(node.type)#">';
                xml &= '<title>' & xmlFormat(node.title) & '</title>';
                xml &= '<position>';
                xml &= '<x>' & parseNumber(node.position.left) & '</x>';
                xml &= '<y>' & parseNumber(node.position.top) & '</y>';
                xml &= '</position>';

                // Add controls if they exist
                if (structKeyExists(node, "controls") && isArray(node.controls) && arrayLen(node.controls)) {
                    xml &= '<controls>';
                    for (var controlId in node.controls) {
                        xml &= '<control id="#xmlFormat(controlId)#" />';
                    }
                    xml &= '</controls>';
                }

                xml &= '</node>';
            }
            xml &= '</nodes>';

            // Add connections
            xml &= '<connections>';
            for (var conn in workflow.connections) {
                xml &= '<connection>';
                xml &= '<source>' & xmlFormat(conn.sourceId) & '</source>';
                xml &= '<target>' & xmlFormat(conn.targetId) & '</target>';
                xml &= '</connection>';
            }
            xml &= '</connections>';

            // Close workflow tag
            xml &= '</workflow>';

            // Create XML Schema
            var schema = '<?xml version="1.0" encoding="UTF-8"?>';
            schema &= '<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">';
            
            // Define workflow element
            schema &= '<xs:element name="workflow">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            
            // Properties
            schema &= '<xs:element name="properties">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            schema &= '<xs:element name="title" type="xs:string"/>';
            schema &= '<xs:element name="description" type="xs:string"/>';
            schema &= '<xs:element name="created" type="xs:dateTime"/>';
            schema &= '</xs:sequence>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            
            // Nodes
            schema &= '<xs:element name="nodes">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            schema &= '<xs:element name="node" maxOccurs="unbounded">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            schema &= '<xs:element name="title" type="xs:string"/>';
            schema &= '<xs:element name="position">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            schema &= '<xs:element name="x" type="xs:integer"/>';
            schema &= '<xs:element name="y" type="xs:integer"/>';
            schema &= '</xs:sequence>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            schema &= '<xs:element name="controls" minOccurs="0">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            schema &= '<xs:element name="control" maxOccurs="unbounded">';
            schema &= '<xs:complexType>';
            schema &= '<xs:attribute name="id" type="xs:string"/>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            schema &= '</xs:sequence>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            schema &= '</xs:sequence>';
            schema &= '<xs:attribute name="id" type="xs:string"/>';
            schema &= '<xs:attribute name="type" type="xs:string"/>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            schema &= '</xs:sequence>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            
            // Connections
            schema &= '<xs:element name="connections">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            schema &= '<xs:element name="connection" maxOccurs="unbounded">';
            schema &= '<xs:complexType>';
            schema &= '<xs:sequence>';
            schema &= '<xs:element name="source" type="xs:string"/>';
            schema &= '<xs:element name="target" type="xs:string"/>';
            schema &= '</xs:sequence>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            schema &= '</xs:sequence>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            
            schema &= '</xs:sequence>';
            schema &= '</xs:complexType>';
            schema &= '</xs:element>';
            schema &= '</xs:schema>';

            // Save files
            var tempFile = getTempFileName() & ".xml";
            var schemaFile = getDirectoryFromPath(tempFile) & "workflow.xsd";
            
            fileWrite(tempFile, xml);
            fileWrite(schemaFile, schema);

            return {
                success = true,
                fileUrl = "/temp/" & getFileFromPath(tempFile)
            };
        }
        catch (any e) {
            return {
                success = false,
                message = "Error exporting to XML: " & e.message
            };
        }
    }

    private function parseNumber(required string value) {
        return val(replace(value, "px", ""));
    }
} 