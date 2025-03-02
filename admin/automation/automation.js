let currentScript = null;

// Initialize the page
$(document).ready(function() {
    initializeCodeEditor();
    loadExecutionHistory();
});

// Initialize code editor
function initializeCodeEditor() {
    $('.code-editor').each(function() {
        CodeMirror.fromTextArea(this, {
            mode: 'python',
            theme: 'monokai',
            lineNumbers: true,
            autoCloseBrackets: true,
            matchBrackets: true,
            indentUnit: 4
        });
    });
}

// Load script details
function selectScript(scriptID) {
    $.get('/api/automation/script', { scriptID: scriptID }, function(data) {
        currentScript = data;
        updateParameterFields(data.parameters);
        $('#inputFileField').toggle(data.inputType === 'csv');
    });
}

// Update parameter fields based on script definition
function updateParameterFields(parameters) {
    const container = $('#parameterFields');
    container.empty();

    parameters.forEach(param => {
        container.append(`
            <div class="form-group">
                <label>${param.label}</label>
                <input type="text" class="form-control" 
                       name="param_${param.name}"
                       placeholder="${param.description || ''}"
                       ${param.required ? 'required' : ''}>
            </div>
        `);
    });
}

// Execute script
function executeScript() {
    const form = $('#executionForm');
    const formData = new FormData(form[0]);
    
    // Add script ID
    formData.append('scriptID', currentScript.scriptID);
    
    // Collect parameters
    const parameters = {};
    currentScript.parameters.forEach(param => {
        parameters[param.name] = form.find(`[name="param_${param.name}"]`).val();
    });
    formData.append('parameters', JSON.stringify(parameters));

    $.ajax({
        url: '/api/automation/execute',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            if (response.success) {
                showNotification('Script execution started');
                loadExecutionHistory();
            } else {
                showError(response.message);
            }
        }
    });
}

// Load execution history
function loadExecutionHistory() {
    const controlID = $('#executionForm [name="controlID"]').val();
    
    $.get('/api/automation/history', { controlID: controlID }, function(data) {
        const container = $('#executionHistory');
        container.empty();
        
        data.forEach(execution => {
            container.append(`
                <div class="execution-item ${execution.status}">
                    <h6>${execution.scriptTitle}</h6>
                    <div class="execution-details">
                        <span class="badge badge-${getStatusBadgeClass(execution.status)}">
                            ${execution.status}
                        </span>
                        <small>${execution.executionDate}</small>
                        <small>by ${execution.executedByName}</small>
                    </div>
                    ${execution.status === 'completed' ? `
                        <div class="execution-actions">
                            <button class="btn btn-sm btn-info" 
                                    onclick="viewResults(${execution.executionID})">
                                View Results
                            </button>
                        </div>
                    ` : ''}
                </div>
            `);
        });
    });
}

// View execution results
function viewResults(executionID) {
    $.get('/api/automation/results', { executionID: executionID }, function(data) {
        // Show results in modal
        showResultsModal(data);
    });
}

// Helper function for status badge classes
function getStatusBadgeClass(status) {
    switch (status) {
        case 'completed': return 'success';
        case 'running': return 'primary';
        case 'failed': return 'danger';
        default: return 'secondary';
    }
} 