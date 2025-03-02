<cfset automationService = application.automationService>
<cfset scripts = automationService.getScripts()>

<cfoutput>
<div class="container-fluid">
    <div class="row">
        <!-- Script Library -->
        <div class="col-md-4">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5>Script Library</h5>
                    <button class="btn btn-primary" onclick="showNewScript()">
                        <i class="fas fa-plus"></i> New Script
                    </button>
                </div>
                <div class="card-body">
                    <div class="list-group">
                        <cfloop query="scripts">
                            <a href="##" class="list-group-item list-group-item-action"
                               onclick="selectScript(#scripts.scriptID#)">
                                <h6>#scripts.title#</h6>
                                <small>#scripts.description#</small>
                            </a>
                        </cfloop>
                    </div>
                </div>
            </div>
        </div>

        <!-- Script Execution -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h5>Script Execution</h5>
                </div>
                <div class="card-body">
                    <form id="executionForm">
                        <div class="form-group">
                            <label>Control</label>
                            <select class="form-control" name="controlID" required>
                                <option value="">Select Control...</option>
                                <!--- Populated via AJAX based on selected audit --->
                            </select>
                        </div>

                        <div id="parameterFields">
                            <!--- Dynamically populated based on selected script --->
                        </div>

                        <div id="inputFileField" style="display:none;">
                            <div class="form-group">
                                <label>Input File (CSV)</label>
                                <input type="file" class="form-control" name="inputFile" 
                                       accept=".csv">
                            </div>
                        </div>

                        <button type="button" class="btn btn-primary" onclick="executeScript()">
                            Execute Script
                        </button>
                    </form>
                </div>
            </div>

            <!-- Execution History -->
            <div class="card mt-3">
                <div class="card-header">
                    <h5>Execution History</h5>
                </div>
                <div class="card-body">
                    <div id="executionHistory">
                        <!--- Populated via AJAX --->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- New Script Modal -->
<div class="modal fade" id="scriptModal">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">New Automation Script</h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <form id="scriptForm">
                    <div class="form-group">
                        <label>Title</label>
                        <input type="text" class="form-control" name="title" required>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <textarea class="form-control" name="description" rows="3"></textarea>
                    </div>
                    <div class="form-group">
                        <label>Script Type</label>
                        <select class="form-control" name="scriptType" required>
                            <option value="python">Python</option>
                            <option value="powershell">PowerShell</option>
                            <option value="sql">SQL</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Script Content</label>
                        <textarea class="form-control code-editor" name="scriptContent" 
                                rows="10"></textarea>
                    </div>
                    <div class="form-group">
                        <label>Input Type</label>
                        <select class="form-control" name="inputType">
                            <option value="none">None</option>
                            <option value="csv">CSV</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Parameters</label>
                        <div id="parameterList">
                            <button type="button" class="btn btn-sm btn-secondary" 
                                    onclick="addParameter()">
                                Add Parameter
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">
                    Cancel
                </button>
                <button type="button" class="btn btn-primary" onclick="saveScript()">
                    Save Script
                </button>
            </div>
        </div>
    </div>
</div>
</cfoutput> 