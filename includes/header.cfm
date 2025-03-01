<!--- Get company logo and user info --->
<cfif structKeyExists(session, "companyID")>
    <cfquery name="getCompanyLogo" datasource="#application.datasource#">
        SELECT logo
        FROM companies
        WHERE companyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>

<!--- Get available languages --->
<cfquery name="getLanguages" datasource="#application.datasource#">
    SELECT languageID, languageName
    FROM languages
    WHERE isActive = 1
    ORDER BY languageName
</cfquery>

<header class="admin-header">
    <div class="admin-header-container">
        <div class="admin-header-logo">
            <cfif structKeyExists(session, "companyID") AND len(getCompanyLogo.logo)>
                <img src="../uploads/logos/#getCompanyLogo.logo#" alt="Company Logo" class="company-logo">
            <cfelse>
                <img src="../assets/images/default-logo.png" alt="Default Logo" class="company-logo">
            </cfif>
        </div>
        
        <cfif structKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
            <div class="admin-header-user">
                <div class="language-selector">
                    <select id="languageSelect" onchange="changeLanguage(this.value)">
                        <cfoutput query="getLanguages">
                            <option value="#languageID#" <cfif session.preferredLanguage EQ languageID>selected</cfif>>#languageName#</option>
                        </cfoutput>
                    </select>
                </div>
                
                <div class="user-info">
                    <span class="user-name"><cfoutput>#session.firstName# #session.lastName#</cfoutput></span>
                    <a href="../logout.cfm" class="logout-btn">
                        <i class="bi bi-box-arrow-right"></i>
                        Logout
                    </a>
                </div>
            </div>
        </cfif>
    </div>
</header>

<style>
.admin-header {
    background: #fff;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    padding: 1rem 0;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
}

.admin-header-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
}

.admin-header-logo {
    height: 50px;
}

.company-logo {
    height: 100%;
    width: auto;
    max-width: 200px;
    object-fit: contain;
}

.admin-header-user {
    display: flex;
    align-items: center;
    gap: 1.5rem;
}

.language-selector select {
    padding: 0.5rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    background: #fff;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 1rem;
}

.user-name {
    font-weight: 500;
}

.logout-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    background: #dc3545;
    color: #fff;
    text-decoration: none;
    transition: background-color 0.2s;
}

.logout-btn:hover {
    background: #c82333;
}

/* Add margin to main content to account for fixed header */
body {
    margin-top: 82px;
}
</style>

<script>
async function changeLanguage(languageID) {
    try {
        const response = await fetch('../api/language.cfc?method=setPreferredLanguage', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ languageID })
        });
        
        const data = await response.json();
        if (data.success) {
            window.location.reload();
        }
    } catch (error) {
        console.error('Error changing language:', error);
    }
}
</script> 