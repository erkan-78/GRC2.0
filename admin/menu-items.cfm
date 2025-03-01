<!DOCTYPE html>
<html>
<head>
    <title>Menu Items Management</title>
    <link href="css/admin.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <!--- Check if user is logged in and has admin role --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR session.userRole NEQ "admin">
        <cflocation url="../login.cfm" addtoken="false">
    </cfif>

    <div class="container">
        <h2 class="page-header">Menu Items Management</h2>

        <div class="admin-card">
            <div class="admin-card-header">
                <h5 class="admin-card-title">Menu Items</h5>
                <button type="button" class="admin-btn admin-btn-primary admin-btn-sm" onclick="showAddMenuItemModal()">
                    <i class="bi bi-plus admin-icon"></i> Add New Menu Item
                </button>
            </div>
            <div class="admin-card-body">
                <div class="admin-table-responsive">
                    <table class="admin-table" id="menuItemsTable">
                        <thead>
                            <tr>
                                <th>Order</th>
                                <th>Label</th>
                                <th>Parent</th>
                                <th>Icon</th>
                                <th>Route</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="menuItemsBody">
                            <!-- Will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add/Edit Menu Item Modal -->
    <div class="admin-modal" id="menuItemModal">
        <div class="admin-modal-dialog">
            <div class="admin-modal-content">
                <div class="admin-modal-header">
                    <h5 class="admin-modal-title" id="modalTitle">Add Menu Item</h5>
                    <button type="button" class="admin-btn admin-btn-secondary admin-btn-sm" onclick="closeModal()">×</button>
                </div>
                <div class="admin-modal-body">
                    <form id="menuItemForm">
                        <input type="hidden" id="menuItemID">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="parentMenuItem">Parent Menu Item</label>
                            <select class="admin-form-control" id="parentMenuItem">
                                <option value="">None (Top Level)</option>
                                <!-- Will be populated by JavaScript -->
                            </select>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="menuOrder">Order</label>
                            <input type="number" class="admin-form-control" id="menuOrder" required min="1">
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="icon">Icon (Bootstrap Icons class name)</label>
                            <input type="text" class="admin-form-control" id="icon" placeholder="e.g., house">
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="route">Route</label>
                            <input type="text" class="admin-form-control" id="route" required>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="translationKey">Translation Key</label>
                            <select class="admin-form-control" id="translationKey" required>
                                <!-- Will be populated by JavaScript -->
                            </select>
                        </div>
                        <div class="admin-form-check">
                            <input class="admin-form-check-input" type="checkbox" id="isActive" checked>
                            <label class="admin-form-label" for="isActive">Active</label>
                        </div>
                    </form>
                </div>
                <div class="admin-modal-footer">
                    <button type="button" class="admin-btn admin-btn-secondary" onclick="closeModal()">Cancel</button>
                    <button type="button" class="admin-btn admin-btn-primary" onclick="saveMenuItem()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let menuItemModal;
        let editingID = null;

        document.addEventListener('DOMContentLoaded', function() {
            menuItemModal = document.getElementById('menuItemModal');
            loadMenuItems();
            loadTranslationKeys();
        });

        function showAddMenuItemModal() {
            editingID = null;
            document.getElementById('modalTitle').textContent = 'Add Menu Item';
            document.getElementById('menuItemID').value = '';
            document.getElementById('parentMenuItem').value = '';
            document.getElementById('menuOrder').value = '';
            document.getElementById('icon').value = '';
            document.getElementById('route').value = '';
            document.getElementById('translationKey').value = '';
            document.getElementById('isActive').checked = true;
            
            menuItemModal.classList.add('show');
        }

        function closeModal() {
            menuItemModal.classList.remove('show');
        }

        async function loadMenuItems() {
            try {
                const response = await fetch('../api/admin.cfc?method=getAllMenuItems');
                const data = await response.json();
                
                if (data.success) {
                    const tbody = document.getElementById('menuItemsBody');
                    tbody.innerHTML = '';
                    
                    data.data.forEach(item => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td>${item.menuOrder}</td>
                            <td>${item.label}</td>
                            <td>${item.parentLabel || '-'}</td>
                            <td>${item.icon ? `<i class="bi bi-${item.icon} admin-icon"></i> ${item.icon}` : '-'}</td>
                            <td>${item.route}</td>
                            <td>
                                <span class="admin-badge ${item.isActive ? 'admin-badge-success' : 'admin-badge-danger'}">
                                    ${item.isActive ? 'Active' : 'Inactive'}
                                </span>
                            </td>
                            <td>
                                <button class="admin-btn admin-btn-primary admin-btn-sm" onclick="editMenuItem(${item.menuItemID})">
                                    <i class="bi bi-pencil admin-icon"></i>
                                </button>
                                <button class="admin-btn admin-btn-danger admin-btn-sm" onclick="deleteMenuItem(${item.menuItemID})">
                                    <i class="bi bi-trash admin-icon"></i>
                                </button>
                            </td>
                        `;
                        tbody.appendChild(row);
                    });

                    // Update parent menu items dropdown
                    const parentSelect = document.getElementById('parentMenuItem');
                    parentSelect.innerHTML = '<option value="">None (Top Level)</option>';
                    data.data.forEach(item => {
                        if (!item.parentMenuItemID) { // Only top-level items can be parents
                            parentSelect.innerHTML += `
                                <option value="${item.menuItemID}">${item.label}</option>
                            `;
                        }
                    });
                }
            } catch (error) {
                console.error('Error loading menu items:', error);
            }
        }

        async function loadTranslationKeys() {
            try {
                const response = await fetch('../api/admin.cfc?method=getTranslationKeys');
                const data = await response.json();
                
                if (data.success) {
                    const select = document.getElementById('translationKey');
                    select.innerHTML = '';
                    data.data.forEach(key => {
                        select.innerHTML += `<option value="${key}">${key}</option>`;
                    });
                }
            } catch (error) {
                console.error('Error loading translation keys:', error);
            }
        }

        async function editMenuItem(id) {
            try {
                const response = await fetch(`../api/admin.cfc?method=getMenuItem&menuItemID=${id}`);
                const data = await response.json();
                
                if (data.success) {
                    editingID = id;
                    const item = data.data;
                    
                    document.getElementById('modalTitle').textContent = 'Edit Menu Item';
                    document.getElementById('menuItemID').value = item.menuItemID;
                    document.getElementById('parentMenuItem').value = item.parentMenuItemID || '';
                    document.getElementById('menuOrder').value = item.menuOrder;
                    document.getElementById('icon').value = item.icon || '';
                    document.getElementById('route').value = item.route;
                    document.getElementById('translationKey').value = item.translationKey;
                    document.getElementById('isActive').checked = item.isActive;
                    
                    menuItemModal.classList.add('show');
                }
            } catch (error) {
                console.error('Error loading menu item:', error);
            }
        }

        async function saveMenuItem() {
            const menuItem = {
                menuItemID: document.getElementById('menuItemID').value,
                parentMenuItemID: document.getElementById('parentMenuItem').value || null,
                menuOrder: document.getElementById('menuOrder').value,
                icon: document.getElementById('icon').value,
                route: document.getElementById('route').value,
                translationKey: document.getElementById('translationKey').value,
                isActive: document.getElementById('isActive').checked
            };
            
            try {
                const response = await fetch('../api/admin.cfc?method=saveMenuItem', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        menuItem: menuItem,
                        isNew: !editingID
                    })
                });
                
                const data = await response.json();
                if (data.success) {
                    closeModal();
                    loadMenuItems();
                } else {
                    alert(data.message);
                }
            } catch (error) {
                console.error('Error saving menu item:', error);
            }
        }

        async function deleteMenuItem(id) {
            if (confirm('Are you sure you want to delete this menu item?')) {
                try {
                    const response = await fetch('../api/admin.cfc?method=deleteMenuItem', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({
                            menuItemID: id
                        })
                    });
                    
                    const data = await response.json();
                    if (data.success) {
                        loadMenuItems();
                    } else {
                        alert(data.message);
                    }
                } catch (error) {
                    console.error('Error deleting menu item:', error);
                }
            }
        }
    </script>
</body>
</html> 