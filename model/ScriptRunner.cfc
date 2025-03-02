component {
    public function execute(
        required string scriptType,
        required string scriptContent,
        required struct parameters,
        string inputFile = ""
    ) {
        var tempDir = getTempDirectory();
        var timestamp = createUUID();
        var scriptFile = tempDir & timestamp & getScriptExtension(arguments.scriptType);
        var outputDir = tempDir & timestamp & "_output";
        
        try {
            // Create output directory
            directoryCreate(outputDir);
            
            // Write script to temp file
            fileWrite(scriptFile, processScript(
                arguments.scriptContent,
                arguments.parameters,
                arguments.inputFile,
                outputDir
            ));
            
            // Execute script based on type
            var result = executeScript(
                arguments.scriptType,
                scriptFile,
                arguments.inputFile,
                outputDir
            );
            
            return {
                textOutput: fileRead(outputDir & "/result.txt"),
                fileOutput: outputDir & "/result.csv"
            };
            
        } finally {
            // Cleanup temp files
            if (fileExists(scriptFile)) {
                fileDelete(scriptFile);
            }
        }
    }

    private function processScript(
        required string scriptContent,
        required struct parameters,
        required string inputFile,
        required string outputDir
    ) {
        var script = arguments.scriptContent;
        
        // Replace parameters
        for (var param in arguments.parameters) {
            script = replace(script, "#{#param#}", arguments.parameters[param], "all");
        }
        
        // Replace special variables
        script = replace(script, "#INPUT_FILE#", arguments.inputFile, "all");
        script = replace(script, "#OUTPUT_DIR#", arguments.outputDir, "all");
        
        return script;
    }

    private function executeScript(
        required string scriptType,
        required string scriptFile,
        required string inputFile,
        required string outputDir
    ) {
        var command = "";
        
        switch (arguments.scriptType) {
            case "python":
                command = "python #arguments.scriptFile#";
                break;
            case "powershell":
                command = "powershell -File #arguments.scriptFile#";
                break;
            case "sql":
                command = "sqlcmd -i #arguments.scriptFile#";
                break;
            default:
                throw("Unsupported script type: #arguments.scriptType#");
        }
        
        var process = createObject("java", "java.lang.Runtime")
            .getRuntime()
            .exec(command);
            
        process.waitFor();
        
        if (process.exitValue() != 0) {
            throw(
                type="ScriptExecutionError",
                message=createObject("java", "java.io.InputStreamReader")
                    .init(process.getErrorStream())
                    .read()
            );
        }
    }

    private function getScriptExtension(required string scriptType) {
        switch (arguments.scriptType) {
            case "python": return ".py";
            case "powershell": return ".ps1";
            case "sql": return ".sql";
            default: return ".txt";
        }
    }
} 