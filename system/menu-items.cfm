<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LightGRC - Menu Items Management</title>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="../assets/css/base.css" rel="stylesheet">
    <link href="../assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            min-height: 100vh;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        .page-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .brand-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .logo-text {
            font-size: 2rem;
            font-weight: 700;
            color: #1a237e;
        }
        .logo-text .highlight {
            color: #0d47a1;
        }
        .admin-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 2rem;
        }
        .admin-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .admin-card-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #1a237e;
            margin: 0;
        }
        .admin-btn {
            padding: 0.5rem 1rem;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .admin-btn-primary {
            background-color: #1a237e;
            color: white;
        }
        .admin-btn-primary:hover {
            background-color: #0d47a1;
        }
        .admin-btn-secondary {
            background-color: #e0e0e0;
            color: #333;
        }
        .admin-btn-secondary:hover {
            background-color: #bdbdbd;
        }
        .admin-btn-danger {
            background-color: #d32f2f;
            color: white;
        }
        .admin-btn-danger:hover {
            background-color: #b71c1c;
        }
        .admin-btn-success {
            background-color: #388e3c;
            color: white;
        }
        .admin-btn-success:hover {
            background-color: #1b5e20;
        }
        .admin-btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
        }
        .admin-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        .admin-table th,
        .admin-table td {
            padding: 1rem;
            border-bottom: 1px solid #e0e0e0;
            text-align: left;
        }
        .admin-table th {
            background-color: #f5f5f5;
            font-weight: 600;
        }
        .admin-table tr:hover {
            background-color: #f8f9fa;
        }
        .admin-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        .admin-modal.show {
            display: block;
        }
        .admin-modal-dialog {
            max-width: 600px;
            margin: 2rem auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
        }
        .admin-modal-content {
            padding: 2rem;
        }
        .admin-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .admin-modal-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #1a237e;
            margin: 0;
        }
        .admin-form-group {
            margin-bottom: 1.5rem;
        }
        .admin-form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #333;
        }
        .admin-form-control {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            font-size: 1rem;
        }
        .admin-form-control:focus {
            outline: none;
            border-color: #1a237e;
        }
        .admin-modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 2rem;
        }
        .language-selector {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
        }
        .form-select {
            padding: 0.5rem;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            background-color: white;
        }
        .nav-tabs {
            margin-bottom: 1.5rem;
        }
        .nav-tabs .nav-link {
            color: #1a237e;
            border: none;
            border-bottom: 2px solid transparent;
            padding: 0.5rem 1rem;
            margin-right: 1rem;
        }
        .nav-tabs .nav-link.active {
            color: #1a237e;
            border-bottom: 2px solid #1a237e;
            font-weight: 600;
        }
        .translation-inputs {
            display: none;
            margin-top: 1rem;
        }
        .translation-inputs.active {
            display: block;
        }
        .language-tabs {
            margin-bottom: 1rem;
        }
        .language-tab {
            padding: 0.5rem 1rem;
            margin-right: 0.5rem;
            cursor: pointer;
            border: 1px solid #dee2e6;
            border-radius: 0.25rem;
        }
        .language-tab.active {
            background-color: #1a237e;
            color: white;
            border-color: #1a237e;
        }
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            .admin-card {
                padding: 1rem;
            }
            .admin-modal-dialog {
                margin: 1rem;
            }
        }
    </style>
</head>
<body>
    <!--- Check if user is logged in and has admin role --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn OR session.userRole NEQ "admin">
        <cflocation url="../login.cfm" addtoken="false">
    </cfif>

    <!--- Get available languages --->
    <cfquery name="getLanguages" datasource="#application.datasource#">
        SELECT languageID, languageName
        FROM languages
        WHERE isActive = 1
        ORDER BY languageName
    </cfquery>

    <!--- Get translations for the current language --->
    <cfset languageID = session.preferredLanguage ?: "en-US">
    <cfquery name="getTranslations" datasource="#application.datasource#">
        SELECT translationKey, translationValue
        FROM translations
        WHERE languageID = <cfqueryparam value="#languageID#" cfsqltype="cf_sql_varchar">
        and page = 'menu-items'
    </cfquery>
    
    <cfset translations = {}>
    <cfloop query="getTranslations">
        <cfset translations[translationKey] = translationValue>
    </cfloop>

    <div class="language-selector">
        <select id="languageSelect" class="form-select form-select-sm" onchange="changeLanguage(this.value)">
            <cfoutput query="getLanguages">
                <option value="#languageID#" <cfif languageID EQ session.preferredLanguage>selected</cfif>>#languageName#</option>
            </cfoutput>
        </select>
    </div>

    <div class="container">
        <div class="brand-header">
            <span class="logo-text">Light<span class="highlight">GRC</span></span>
        </div>
        <h2 class="page-header" data-translation-key="menu-items.title">Menu Items Management</h2>

        <!--- Tabs for Categories and Menu Items --->
        <ul class="nav nav-tabs" id="menuTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="categories-tab" data-bs-toggle="tab" data-bs-target="#categories" type="button" role="tab" aria-controls="categories" aria-selected="true" data-translation-key="menu-items.categories">Menu Categories</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="items-tab" data-bs-toggle="tab" data-bs-target="#items" type="button" role="tab" aria-controls="items" aria-selected="false" data-translation-key="menu-items.items">Menu Items</button>
            </li>
        </ul>

        <!--- Tab Content --->
        <div class="tab-content" id="menuTabContent">
            <!--- Categories Tab --->
            <div class="tab-pane fade show active" id="categories" role="tabpanel" aria-labelledby="categories-tab">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h5 class="admin-card-title" data-translation-key="menu-items.categories">Menu Categories</h5>
                        <button type="button" class="admin-btn admin-btn-primary admin-btn-sm" onclick="showAddCategoryModal()">
                            <i class="bi bi-plus"></i> <span data-translation-key="menu-items.addCategory">Add New Category</span>
                        </button>
                    </div>
                    <div class="admin-card-body">
                        <div class="admin-table-responsive">
                            <table class="admin-table" id="categoriesTable">
                                <thead>
                                    <tr>
                                        <th data-translation-key="menu-items.categoryName">Category Name</th>
                                        <th data-translation-key="menu-items.displayOrder">Display Order</th>
                                        <th data-translation-key="menu-items.icon">Icon</th>
                                        <th data-translation-key="menu-items.status">Status</th>
                                        <th data-translation-key="menu-items.actions">Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="categoriesBody">
                                    <!-- Will be populated by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Menu Items Tab --->
            <div class="tab-pane fade" id="items" role="tabpanel" aria-labelledby="items-tab">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h5 class="admin-card-title" data-translation-key="menu-items.menuItems">Menu Items</h5>
                        <button type="button" class="admin-btn admin-btn-primary admin-btn-sm" onclick="showAddMenuItemModal()">
                            <i class="bi bi-plus"></i> <span data-translation-key="menu-items.addMenuItem">Add New Menu Item</span>
                        </button>
                    </div>
                    <div class="admin-card-body">
                        <div class="admin-table-responsive">
                            <table class="admin-table" id="menuItemsTable">
                                <thead>
                                    <tr>
                                        <th data-translation-key="menu-items.category">Category</th>
                                        <th data-translation-key="menu-items.name">Name</th>
                                        <th data-translation-key="menu-items.route">Route</th>
                                        <th data-translation-key="menu-items.status">Status</th>
                                        <th data-translation-key="menu-items.actions">Actions</th>
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
        </div>
    </div>

    <!-- Add/Edit Category Modal -->
    <div class="admin-modal" id="categoryModal">
        <div class="admin-modal-dialog">
            <div class="admin-modal-content">
                <div class="admin-modal-header">
                    <h5 class="admin-modal-title" id="categoryModalTitle" data-translation-key="menu-items.addCategory">Add Category</h5>
                    <button type="button" class="admin-btn admin-btn-secondary admin-btn-sm" onclick="closeCategoryModal()">×</button>
                </div>
                <div class="admin-modal-body">
                    <form id="categoryForm">
                        <input type="hidden" id="categoryID" value="0">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="categoryName" data-translation-key="menu-items.categoryName">Category Name</label>
                            <input type="text" class="admin-form-control" id="categoryName" required>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="displayOrder" data-translation-key="menu-items.displayOrder">Display Order</label>
                            <input type="number" class="admin-form-control" id="displayOrder" value="0" min="0">
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="icon" data-translation-key="menu-items.icon">Icon (Bootstrap Icons)</label>
                            <input type="text" class="admin-form-control" id="icon" placeholder="bi-speedometer2">
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="isActive" data-translation-key="menu-items.status">Status</label>
                            <select class="admin-form-control" id="isActive">
                                <option value="1" data-translation-key="menu-items.active">Active</option>
                                <option value="0" data-translation-key="menu-items.inactive">Inactive</option>
                            </select>
                        </div>
                        
                        <h6 class="mt-4" data-translation-key="menu-items.translations">Translations</h6>
                        <div id="categoryLanguageTabs" class="language-tabs">
                            <!-- Will be populated by JavaScript -->
                        </div>
                        <div id="categoryTranslationInputs">
                            <!-- Will be populated by JavaScript -->
                        </div>
                    </form>
                </div>
                <div class="admin-modal-footer">
                    <button type="button" class="admin-btn admin-btn-secondary" onclick="closeCategoryModal()" data-translation-key="menu-items.cancel">Cancel</button>
                    <button type="button" class="admin-btn admin-btn-primary" onclick="saveCategory()" data-translation-key="menu-items.save">Save</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Add/Edit Menu Item Modal -->
    <div class="admin-modal" id="menuItemModal">
        <div class="admin-modal-dialog">
            <div class="admin-modal-content">
                <div class="admin-modal-header">
                    <h5 class="admin-modal-title" id="menuItemModalTitle" data-translation-key="menu-items.addMenuItem">Add Menu Item</h5>
                    <button type="button" class="admin-btn admin-btn-secondary admin-btn-sm" onclick="closeMenuItemModal()">×</button>
                </div>
                <div class="admin-modal-body">
                    <form id="menuItemForm">
                        <input type="hidden" id="menuItemID" value="0">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="category" data-translation-key="menu-items.category">Category</label>
                            <select class="admin-form-control" id="category" required>
                                <option value="">Select Category</option>
                                <!-- Will be populated by JavaScript -->
                            </select>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="permissionName" data-translation-key="menu-items.name">Permission Name</label>
                            <input type="text" class="admin-form-control" id="permissionName" required>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="route" data-translation-key="menu-items.route">Route</label>
                            <input type="text" class="admin-form-control" id="route" required>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="menuItemIsActive" data-translation-key="menu-items.status">Status</label>
                            <select class="admin-form-control" id="menuItemIsActive">
                                <option value="1" data-translation-key="menu-items.active">Active</option>
                                <option value="0" data-translation-key="menu-items.inactive">Inactive</option>
                            </select>
                        </div>
                        
                        <h6 class="mt-4" data-translation-key="menu-items.translations">Translations</h6>
                        <div id="menuItemLanguageTabs" class="language-tabs">
                            <!-- Will be populated by JavaScript -->
                        </div>
                        <div id="menuItemTranslationInputs">
                            <!-- Will be populated by JavaScript -->
                        </div>
                    </form>
                </div>
                <div class="admin-modal-footer">
                    <button type="button" class="admin-btn admin-btn-secondary" onclick="closeMenuItemModal()" data-translation-key="menu-items.cancel">Cancel</button>
                    <button type="button" class="admin-btn admin-btn-primary" onclick="saveMenuItem()" data-translation-key="menu-items.save">Save</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Global variables
        let currentLanguages = [];
        let menuCategories = [];
        let menuItems = [];
        let categoryTranslations = {};
        let menuItemTranslations = {};

        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            loadLanguages();
            loadMenuCategories();
            loadMenuItems();
            setupLanguageTabs();
        });

        // Load languages
        function loadLanguages() {
            <cfoutput query="getLanguages">
                currentLanguages.push({
                    id: '#languageID#',
                    name: '#languageName#'
                });
            </cfoutput>
        }

        // Load menu categories
        function loadMenuCategories() {
            fetch('../api/menu.cfc?method=getMenuSections')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        menuCategories = data.data;
                        refreshCategoriesTable();
                        populateCategoryDropdown();
                    }
                })
                .catch(error => console.error('Error loading menu categories:', error));
        }

        // Load menu items
        function loadMenuItems() {
            fetch('../api/admin.cfc?method=getAllPermissions')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        menuItems = data.data;
                        refreshMenuItemsTable();
                    }
                })
                .catch(error => console.error('Error loading menu items:', error));
        }

        // Setup language tabs
        function setupLanguageTabs() {
            const categoryTabsContainer = document.getElementById('categoryLanguageTabs');
            const menuItemTabsContainer = document.getElementById('menuItemLanguageTabs');
            
            if (categoryTabsContainer) {
                categoryTabsContainer.innerHTML = currentLanguages.map((lang, index) => 
                    `<span class="language-tab ${index === 0 ? 'active' : ''}" data-lang="${lang.id}" onclick="switchCategoryLanguage('${lang.id}')">${lang.name}</span>`
                ).join('');
            }
            
            if (menuItemTabsContainer) {
                menuItemTabsContainer.innerHTML = currentLanguages.map((lang, index) => 
                    `<span class="language-tab ${index === 0 ? 'active' : ''}" data-lang="${lang.id}" onclick="switchMenuItemLanguage('${lang.id}')">${lang.name}</span>`
                ).join('');
            }
            
            // Initialize translation inputs
            setupCategoryTranslationInputs();
            setupMenuItemTranslationInputs();
        }

        // Setup category translation inputs
        function setupCategoryTranslationInputs() {
            const container = document.getElementById('categoryTranslationInputs');
            if (container) {
                container.innerHTML = currentLanguages.map((lang, index) => `
                    <div class="translation-inputs ${index === 0 ? 'active' : ''}" data-lang="${lang.id}">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="category_label_${lang.id}">Label (${lang.name})</label>
                            <input type="text" class="admin-form-control" id="category_label_${lang.id}" required>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="category_description_${lang.id}">Description (${lang.name})</label>
                            <input type="text" class="admin-form-control" id="category_description_${lang.id}">
                        </div>
                    </div>
                `).join('');
            }
        }

        // Setup menu item translation inputs
        function setupMenuItemTranslationInputs() {
            const container = document.getElementById('menuItemTranslationInputs');
            if (container) {
                container.innerHTML = currentLanguages.map((lang, index) => `
                    <div class="translation-inputs ${index === 0 ? 'active' : ''}" data-lang="${lang.id}">
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="menuItem_label_${lang.id}">Label (${lang.name})</label>
                            <input type="text" class="admin-form-control" id="menuItem_label_${lang.id}" required>
                        </div>
                        <div class="admin-form-group">
                            <label class="admin-form-label" for="menuItem_description_${lang.id}">Description (${lang.name})</label>
                            <input type="text" class="admin-form-control" id="menuItem_description_${lang.id}">
                        </div>
                    </div>
                `).join('');
            }
        }

        // Switch category language
        function switchCategoryLanguage(languageID) {
            const tabs = document.querySelectorAll('#categoryLanguageTabs .language-tab');
            const inputs = document.querySelectorAll('#categoryTranslationInputs .translation-inputs');
            
            tabs.forEach(tab => {
                if (tab.getAttribute('data-lang') === languageID) {
                    tab.classList.add('active');
                } else {
                    tab.classList.remove('active');
                }
            });
            
            inputs.forEach(input => {
                if (input.getAttribute('data-lang') === languageID) {
                    input.classList.add('active');
                } else {
                    input.classList.remove('active');
                }
            });
        }

        // Switch menu item language
        function switchMenuItemLanguage(languageID) {
            const tabs = document.querySelectorAll('#menuItemLanguageTabs .language-tab');
            const inputs = document.querySelectorAll('#menuItemTranslationInputs .translation-inputs');
            
            tabs.forEach(tab => {
                if (tab.getAttribute('data-lang') === languageID) {
                    tab.classList.add('active');
                } else {
                    tab.classList.remove('active');
                }
            });
            
            inputs.forEach(input => {
                if (input.getAttribute('data-lang') === languageID) {
                    input.classList.add('active');
                } else {
                    input.classList.remove('active');
                }
            });
        }

        // Show add category modal
        function showAddCategoryModal() {
            document.getElementById('categoryID').value = '0';
            document.getElementById('categoryForm').reset();
            document.getElementById('categoryModalTitle').textContent = document.querySelector('[data-translation-key="menu-items.addCategory"]').textContent;
            
            // Reset translation inputs
            currentLanguages.forEach(lang => {
                document.getElementById(`category_label_${lang.id}`).value = '';
                document.getElementById(`category_description_${lang.id}`).value = '';
            });
            
            document.getElementById('categoryModal').classList.add('show');
        }

        // Close category modal
        function closeCategoryModal() {
            document.getElementById('categoryModal').classList.remove('show');
        }

        // Show edit category modal
        function editCategory(categoryName) {
            const category = menuCategories.find(c => c.sectionName === categoryName);
            if (category) {
                document.getElementById('categoryID').value = category.sectionName;
                document.getElementById('categoryName').value = category.sectionName;
                document.getElementById('displayOrder').value = category.displayOrder;
                document.getElementById('icon').value = category.icon;
                document.getElementById('isActive').value = category.isActive;
                
                // Get category translations
                fetch(`../api/admin.cfc?method=getSectionTranslations&sectionName=${encodeURIComponent(categoryName)}`)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            categoryTranslations = data.data;
                            
                            // Populate translation inputs
                            currentLanguages.forEach(lang => {
                                const translation = categoryTranslations.find(t => t.languageID === lang.id);
                                if (translation) {
                                    document.getElementById(`category_label_${lang.id}`).value = translation.label || '';
                                    document.getElementById(`category_description_${lang.id}`).value = translation.description || '';
                                } else {
                                    document.getElementById(`category_label_${lang.id}`).value = '';
                                    document.getElementById(`category_description_${lang.id}`).value = '';
                                }
                            });
                        }
                    })
                    .catch(error => console.error('Error loading category translations:', error));
                
                document.getElementById('categoryModalTitle').textContent = document.querySelector('[data-translation-key="menu-items.editCategory"]').textContent;
                document.getElementById('categoryModal').classList.add('show');
            }
        }

        // Save category
        function saveCategory() {
            const categoryID = document.getElementById('categoryID').value;
            const categoryName = document.getElementById('categoryName').value;
            const displayOrder = document.getElementById('displayOrder').value;
            const icon = document.getElementById('icon').value;
            const isActive = document.getElementById('isActive').value;
            
            // Collect translations
            const translations = currentLanguages.map(lang => ({
                languageID: lang.id,
                label: document.getElementById(`category_label_${lang.id}`).value,
                description: document.getElementById(`category_description_${lang.id}`).value
            }));
            
            const categoryData = {
                sectionID: categoryID,
                sectionName: categoryName,
                displayOrder: displayOrder,
                icon: icon,
                isActive: isActive,
                translations: translations
            };
            
            fetch('../api/menu.cfc?method=saveMenuSection', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(categoryData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    closeCategoryModal();
                    loadMenuCategories();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => console.error('Error saving category:', error));
        }

        // Delete category
        function deleteCategory(categoryName) {
            if (confirm(document.querySelector('[data-translation-key="menu-items.confirmDeleteCategory"]').textContent)) {
                fetch('../api/menu.cfc?method=deleteMenuSection', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        sectionName: categoryName
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        loadMenuCategories();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(error => console.error('Error deleting category:', error));
            }
        }

        // Refresh categories table
        function refreshCategoriesTable() {
            const tbody = document.getElementById('categoriesBody');
            if (tbody) {
                tbody.innerHTML = menuCategories
                    .filter(category => category.languageID === currentLanguages[0].id)
                    .map(category => `
                        <tr>
                            <td>${category.sectionLabel || category.sectionName}</td>
                            <td>${category.displayOrder}</td>
                            <td><i class="bi ${category.icon}"></i> ${category.icon}</td>
                            <td>${category.isActive ? 'Active' : 'Inactive'}</td>
                            <td>
                                <button onclick="editCategory('${category.sectionName}')" class="admin-btn admin-btn-sm admin-btn-primary">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button onclick="deleteCategory('${category.sectionName}')" class="admin-btn admin-btn-sm admin-btn-danger">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    `).join('');
            }
        }

        // Populate category dropdown
        function populateCategoryDropdown() {
            const categorySelect = document.getElementById('category');
            if (categorySelect) {
                categorySelect.innerHTML = '<option value="">Select Category</option>';
                menuCategories
                    .filter(category => category.languageID === currentLanguages[0].id)
                    .forEach(category => {
                        categorySelect.innerHTML += `<option value="${category.sectionName}">${category.sectionLabel || category.sectionName}</option>`;
                    });
            }
        }

        // Show add menu item modal
        function showAddMenuItemModal() {
            document.getElementById('menuItemID').value = '0';
            document.getElementById('menuItemForm').reset();
            document.getElementById('menuItemModalTitle').textContent = document.querySelector('[data-translation-key="menu-items.addMenuItem"]').textContent;
            
            // Reset translation inputs
            currentLanguages.forEach(lang => {
                document.getElementById(`menuItem_label_${lang.id}`).value = '';
                document.getElementById(`menuItem_description_${lang.id}`).value = '';
            });
            
            document.getElementById('menuItemModal').classList.add('show');
        }

        // Close menu item modal
        function closeMenuItemModal() {
            document.getElementById('menuItemModal').classList.remove('show');
        }

        // Edit menu item
        function editMenuItem(permissionID) {
            const menuItem = menuItems.find(item => item.permissionID == permissionID);
            if (menuItem) {
                document.getElementById('menuItemID').value = menuItem.permissionID;
                document.getElementById('permissionName').value = menuItem.permissionName;
                document.getElementById('category').value = menuItem.sectionName || '';
                document.getElementById('route').value = menuItem.route;
                document.getElementById('menuItemIsActive').value = menuItem.isActive;
                
                // Get menu item translations
                fetch(`../api/admin.cfc?method=getPermissionTranslations&permissionKey=${menuItem.permissionName}`)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            menuItemTranslations = data.data;
                            
                            // Populate translation inputs
                            currentLanguages.forEach(lang => {
                                const translation = menuItemTranslations.find(t => t.languageID === lang.id);
                                if (translation) {
                                    document.getElementById(`menuItem_label_${lang.id}`).value = translation.label || '';
                                    document.getElementById(`menuItem_description_${lang.id}`).value = translation.description || '';
                                } else {
                                    document.getElementById(`menuItem_label_${lang.id}`).value = '';
                                    document.getElementById(`menuItem_description_${lang.id}`).value = '';
                                }
                            });
                        }
                    })
                    .catch(error => console.error('Error loading menu item translations:', error));
                
                document.getElementById('menuItemModalTitle').textContent = document.querySelector('[data-translation-key="menu-items.editMenuItem"]').textContent;
                document.getElementById('menuItemModal').classList.add('show');
            }
        }

        // Save menu item
        function saveMenuItem() {
            const menuItemID = document.getElementById('menuItemID').value;
            const categoryName = document.getElementById('category').value;
            const permissionName = document.getElementById('permissionName').value;
            const route = document.getElementById('route').value;
            const isActive = document.getElementById('menuItemIsActive').value;
            
            // Collect translations
            const translations = currentLanguages.map(lang => ({
                languageID: lang.id,
                label: document.getElementById(`menuItem_label_${lang.id}`).value,
                description: document.getElementById(`menuItem_description_${lang.id}`).value
            }));
            
            const menuItemData = {
                permissionID: menuItemID,
                sectionName: categoryName,
                permissionName: permissionName,
                route: route,
                isActive: isActive,
                translations: translations
            };
            
            fetch('../api/admin.cfc?method=savePermission', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(menuItemData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    closeMenuItemModal();
                    loadMenuItems();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => console.error('Error saving menu item:', error));
        }

        // Toggle menu item status
        function toggleMenuItemStatus(permissionID) {
            const menuItem = menuItems.find(item => item.permissionID == permissionID);
            if (menuItem) {
                const newStatus = menuItem.isActive ? 0 : 1;
                
                fetch('../api/admin.cfc?method=updatePermissionStatus', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        permissionID: permissionID,
                        isActive: newStatus
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        loadMenuItems();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(error => console.error('Error updating menu item status:', error));
            }
        }

        // Refresh menu items table
        function refreshMenuItemsTable() {
            const tbody = document.getElementById('menuItemsBody');
            if (tbody) {
                tbody.innerHTML = menuItems.map(item => {
                    const category = menuCategories.find(c => c.sectionName === item.sectionName);
                    const categoryName = category ? (category.sectionLabel || category.sectionName) : 'Unassigned';
                    
                    return `
                        <tr>
                            <td>${categoryName}</td>
                            <td>${item.permissionName}</td>
                            <td>${item.route}</td>
                            <td>${item.isActive ? 'Active' : 'Inactive'}</td>
                            <td>
                                <button onclick="editMenuItem(${item.permissionID})" class="admin-btn admin-btn-sm admin-btn-primary">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button onclick="toggleMenuItemStatus(${item.permissionID})" class="admin-btn admin-btn-sm admin-btn-${item.isActive ? 'danger' : 'success'}">
                                    ${item.isActive ? 'Deactivate' : 'Activate'}
                                </button>
                            </td>
                        </tr>
                    `;
                }).join('');
            }
        }

        // Change language
        function changeLanguage(languageCode) {
            fetch('../api/language/update.cfm', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    languageCode: languageCode
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    window.location.reload();
                }
            })
            .catch(error => console.error('Error:', error));
        }

        // Update translations
        function updateTranslations() {
            const elements = document.querySelectorAll('[data-translation-key]');
            elements.forEach(element => {
                const key = element.getAttribute('data-translation-key');
                if (translations[key]) {
                    element.textContent = translations[key];
                }
            });
        }
    </script>
</body>
</html> 