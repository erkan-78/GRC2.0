<!--- Get user menu --->

<cfset menuService = new api.menu.index()>

<cfset menuResult = menuService.getUserMenu(session.userID, session.languageID)>

<cfif menuResult.success> 
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="/dashboard.cfm">
                <span class="logo-text">Light<span class="highlight">GRC</span></span>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <cfoutput>
                        <cfloop array="#menuResult.data#" index="menuItem">
                            <li class="nav-item">
                                <a class="nav-link" href="#menuItem.route#" data-translation-key="#menuItem.translationKey#">
                                    <i class="bi bi-#menuItem.icon#"></i> #menuItem.label#
                                </a>
                                <cfif structKeyExists(menuItem, "children") && arrayLen(menuItem.children)>
                                    <ul class="nav flex-column submenu">
                                        <cfloop array="#menuItem.children#" index="childItem">
                                            <li class="nav-item">
                                                <a class="nav-link" href="/#childItem.route#" data-translation-key="#childItem.translationKey#">
                                                    <i class="bi bi-#childItem.icon#"></i> #childItem.label#
                                                </a>
                                            </li>
                                        </cfloop>
                                    </ul>
                                </cfif>
                            </li>
                        </cfloop>
                    </cfoutput>
                </ul>
                <div class="d-flex align-items-center">
                    <select id="languageSelect" class="form-select form-select-sm me-3" style="width: 120px;"  onchange="changeLanguage(this.value)">>
                        <cfoutput query="getLanguages">
                            <option value="#languageID#" <cfif languageID EQ session.languageID>selected</cfif>>#languageName#</option>
                        </cfoutput>
                    </select>
                    <div class="navbar-text me-3 text-white">
                       <cfoutput>
                        #session.firstName# #session.lastName#</cfoutput>
                    </div>
                    <form method="post" action="logout.cfm" class="d-flex">
                        <button type="submit" class="btn btn-outline-light btn-sm">Logout</button>
                    </form>
                </div>
            </div>
        </div>
    </nav>

    <style>
        .navbar {
            padding: 0.5rem 1rem;
        }
        .navbar-brand {
            font-size: 1.5rem;
            font-weight: 600;
        }
        .nav-link {
            color: rgba(255,255,255,.8) !important;
            padding: 0.5rem 1rem;
        }
        .nav-link:hover {
            color: #fff !important;
        }
        .nav-link i {
            margin-right: 0.5rem;
        }
        .submenu {
            padding-left: 1rem;
            display: none;
        }
        .nav-item:hover .submenu {
            display: block;
        }
        .submenu .nav-link {
            padding: 0.25rem 1rem;
            font-size: 0.9rem;
        }
        .navbar-text {
            color: rgba(255,255,255,.8) !important;
        }
        .btn-outline-light {
            border-color: rgba(255,255,255,.5);
        }
        .btn-outline-light:hover {
            background-color: rgba(255,255,255,.1);
        }
    </style>
</cfif> 

 <script>
        let translations = <cfoutput>#serializeJSON(translations)#</cfoutput>;
        let currentLanguage = '<cfoutput>#languageID#</cfoutput>';

        // Update links with current language
        function updateLinks() {
            document.querySelectorAll('a[data-href]').forEach(link => {
                const baseUrl = link.getAttribute('data-href');
                link.href = `${baseUrl}?languageID=${currentLanguage}`;
            });
        }

        // Apply translations to the page
        function applyTranslations() {
            document.querySelectorAll('[data-translation-key]').forEach(element => {
                const key = element.getAttribute('data-translation-key');
                if (translations[key]) {
                    if (element.tagName === 'INPUT' && element.type === 'placeholder') {
                        element.placeholder = translations[key];
                    } else {
                        element.textContent = translations[key];
                    }
                }
            });
            updateLinks();
        }

        // Load translations for a specific language
        async function loadTranslations(languageID) {
            try {
                const response = await fetch(`/api/language.cfc?method=getTranslations&languageID=${languageID}&page=<cfoutput>#pageid#</cfoutput>`);
                const data = await response.json();
                
                if (data.success) {
                    translations = data.data;
                    currentLanguage = languageID;
                    applyTranslations();
                    // Update the hidden input with new language
                    document.querySelector('input[name="languageID"]').value = languageID;
                }
                
            } catch (error) {
                console.error('Error loading translations:', error);
            }
        }


        // Load translations for a specific language
        async function loadTranslations2(languageID) {
            try {
                const response = await fetch(`/api/language.cfc?method=getTranslations&languageID=${languageID}&page=menu`);
                const data = await response.json();
                
                if (data.success) {
                    translations = data.data;
                    currentLanguage = languageID;
                    applyTranslations();
                    // Update the hidden input with new language
                    document.querySelector('input[name="languageID"]').value = languageID;
                }
                
            } catch (error) {
                console.error('Error loading translations:', error);
            }
        }

        // Handle language change
            async function changeLanguage(languageID) {
                await loadTranslations(languageID);
                await loadTranslations2(languageID);
        }

        // Apply translations on page load
        applyTranslations();
    </script>