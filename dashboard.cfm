<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - User Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .sidebar {
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            z-index: 100;
            padding: 48px 0 0;
            box-shadow: inset -1px 0 0 rgba(0, 0, 0, .1);
            width: 250px;
        }
        .sidebar-sticky {
            position: relative;
            top: 0;
            height: calc(100vh - 48px);
            padding-top: .5rem;
            overflow-x: hidden;
            overflow-y: auto;
        }
        .main-content {
            margin-left: 250px;
        }
        .nav-link {
            color: #333;
        }
        .nav-link.active {
            color: #0d6efd;
        }
        .submenu {
            padding-left: 2rem;
        }
    </style>
</head>
<body>
    <!--- Check if user is logged in --->
    <cfif NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn>
        <cflocation url="login.cfm" addtoken="false">
    </cfif>
    
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">User Management System</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                </ul>
                <div class="d-flex align-items-center">
                    <select id="languageSelector" class="form-select form-select-sm me-3" style="width: 120px;">
                    </select>
                    <div class="navbar-text me-3 text-white">
                        Welcome, #session.userName#!
                    </div>
                    <form method="post" action="logout.cfm" class="d-flex">
                        <button type="submit" class="btn btn-outline-light btn-sm">Logout</button>
                    </form>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <nav class="sidebar bg-light">
                <div class="sidebar-sticky" id="sideMenu">
                    <!-- Menu will be populated by JavaScript -->
                </div>
            </nav>

            <main class="main-content col px-md-4">
                <div class="pt-5">
                    <div id="mainContent">
                        <!-- Main content will be loaded here -->
                        <div class="card mt-3">
                            <div class="card-header">
                                <h3 data-translation-key="yourProfile">Your Profile</h3>
                            </div>
                            <div class="card-body">
                                <cfquery name="getUserInfo" datasource="#application.datasource#">
                                    SELECT username, email, firstName, lastName, createdDate, lastLoginDate
                                    FROM users
                                    WHERE userID = <cfqueryparam value="#session.userID#" cfsqltype="cf_sql_integer">
                                </cfquery>
                                
                                <div class="row mb-3">
                                    <div class="col-md-3 fw-bold" data-translation-key="username">Username:</div>
                                    <div class="col-md-9">#getUserInfo.username#</div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-3 fw-bold" data-translation-key="email">Email:</div>
                                    <div class="col-md-9">#getUserInfo.email#</div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-3 fw-bold" data-translation-key="firstName">First Name:</div>
                                    <div class="col-md-9">#getUserInfo.firstName#</div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-3 fw-bold" data-translation-key="lastName">Last Name:</div>
                                    <div class="col-md-9">#getUserInfo.lastName#</div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-3 fw-bold" data-translation-key="memberSince">Member Since:</div>
                                    <div class="col-md-9">#dateFormat(getUserInfo.createdDate, "mmmm d, yyyy")#</div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-3 fw-bold" data-translation-key="lastLogin">Last Login:</div>
                                    <div class="col-md-9">#dateFormat(getUserInfo.lastLoginDate, "mmmm d, yyyy")# #timeFormat(getUserInfo.lastLoginDate, "hh:mm tt")#</div>
                                </div>
                                
                                <div class="mt-4">
                                    <a href="edit-profile.cfm" class="btn btn-primary">Edit Profile</a>
                                    <a href="change-password.cfm" class="btn btn-secondary">Change Password</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let translations = {};
        let currentLanguage = '<cfoutput>#session.preferredLanguage#</cfoutput>';

        // Load languages
        async function loadLanguages() {
            try {
                const response = await fetch('api/language.cfc?method=getLanguages');
                const data = await response.json();
                
                if (data.success) {
                    const selector = document.getElementById('languageSelector');
                    data.data.forEach(lang => {
                        const option = document.createElement('option');
                        option.value = lang.languageID;
                        option.text = lang.languageName;
                        option.selected = lang.languageID === currentLanguage;
                        selector.appendChild(option);
                    });
                }
            } catch (error) {
                console.error('Error loading languages:', error);
            }
        }

        // Load translations
        async function loadTranslations(languageID) {
            try {
                const response = await fetch(`api/language.cfc?method=getTranslations&languageID=${languageID}`);
                const data = await response.json();
                
                if (data.success) {
                    translations = data.data;
                    applyTranslations();
                }
            } catch (error) {
                console.error('Error loading translations:', error);
            }
        }

        // Apply translations to the page
        function applyTranslations() {
            document.querySelectorAll('[data-translation-key]').forEach(element => {
                const key = element.getAttribute('data-translation-key');
                if (translations[key]) {
                    element.textContent = translations[key];
                }
            });
        }

        // Load menu
        async function loadMenu() {
            try {
                const response = await fetch('api/menu.cfc?method=getUserMenu&userID=<cfoutput>#session.userID#</cfoutput>');
                const data = await response.json();
                
                if (data.success) {
                    const menuHtml = buildMenuHtml(data.data);
                    document.getElementById('sideMenu').innerHTML = menuHtml;
                }
            } catch (error) {
                console.error('Error loading menu:', error);
            }
        }

        // Build menu HTML
        function buildMenuHtml(menuItems) {
            let html = '<ul class="nav flex-column">';
            
            menuItems.forEach(item => {
                html += `
                    <li class="nav-item">
                        <a class="nav-link" href="${item.route || '#'}" data-translation-key="${item.translationKey}">
                            ${item.icon ? `<i class="bi bi-${item.icon}"></i> ` : ''}${item.label}
                        </a>
                `;
                
                if (item.children && item.children.length) {
                    html += '<ul class="nav flex-column submenu">';
                    item.children.forEach(child => {
                        html += `
                            <li class="nav-item">
                                <a class="nav-link" href="${child.route || '#'}" data-translation-key="${child.translationKey}">
                                    ${child.icon ? `<i class="bi bi-${child.icon}"></i> ` : ''}${child.label}
                                </a>
                            </li>
                        `;
                    });
                    html += '</ul>';
                }
                
                html += '</li>';
            });
            
            html += '</ul>';
            return html;
        }

        // Handle language change
        document.getElementById('languageSelector').addEventListener('change', async (e) => {
            const newLanguage = e.target.value;
            try {
                const response = await fetch('api/language.cfc?method=updateUserLanguage', {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        userID: <cfoutput>#session.userID#</cfoutput>,
                        languageID: newLanguage
                    })
                });
                
                const data = await response.json();
                if (data.success) {
                    currentLanguage = newLanguage;
                    await loadTranslations(newLanguage);
                    await loadMenu();
                }
            } catch (error) {
                console.error('Error updating language:', error);
            }
        });

        // Initialize
        async function init() {
            await loadLanguages();
            await loadTranslations(currentLanguage);
            await loadMenu();
        }

        init();
    </script>
</body>
</html> 