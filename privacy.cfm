<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <style>
        .page-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--gray-100);
            padding: 2rem;
        }

        .privacy-container {
            background: var(--white);
            border-radius: 12px;
            box-shadow: var(--shadow-md);
            width: 100%;
            max-width: 900px;
            padding: 2rem;
        }

        .privacy-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1.5rem;
        }

        .privacy-table th,
        .privacy-table td {
            padding: 1rem;
            border: 1px solid var(--gray-200);
        }

        .privacy-table th {
            background-color: var(--gray-50);
            font-weight: 600;
            text-align: left;
        }

        .section-title {
            background-color: var(--light-blue);
            color: var(--primary-blue);
            font-weight: 600;
        }
    </style>
</head>
<body>
<cfoutput>
    <div class="page-container">
        <div class="privacy-container">
            <div class="brand-header">
                <div class="logo-text">Light<span class="highlight">GRC</span></div>
                <h2>Privacy Policy</h2>
                <p class="text-muted">Last updated: #dateFormat(now(), "mmmm d, yyyy")#</p>
            </div>

            <table class="privacy-table">
                <tr class="section-title">
                    <th colspan="2">1. Data Collection</th>
                </tr>
                <tr>
                    <th width="30%">Information We Collect</th>
                    <td>
                        • User account information<br>
                        • Company profile data<br>
                        • Risk assessment data<br>
                        • Audit documentation<br>
                        • System usage logs
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">2. Data Protection</th>
                </tr>
                <tr>
                    <th>Security Measures</th>
                    <td>
                        • AES-256 encryption<br>
                        • Multi-factor authentication<br>
                        • Regular security audits<br>
                        • Access logging and monitoring
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">3. Data Usage</th>
                </tr>
                <tr>
                    <th>How We Use Data</th>
                    <td>
                        • Service provision<br>
                        • System improvements<br>
                        • Security monitoring<br>
                        • Compliance reporting
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">4. Data Rights</th>
                </tr>
                <tr>
                    <th>Your Rights</th>
                    <td>
                        • Access your data<br>
                        • Request corrections<br>
                        • Data portability<br>
                        • Request deletion
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">5. Data Retention</th>
                </tr>
                <tr>
                    <th>Retention Policy</th>
                    <td>
                        • Active account data: Indefinite<br>
                        • Audit logs: 7 years<br>
                        • System backups: 30 days<br>
                        • Deleted data: 90 days
                    </td>
                </tr>
            </table>

        
            <div class="action-section">
                
                <div class="mt-3 text-center">
                     <a href="javascript:history.back();" class="text-primary">Return to Previous Page</a>
                </div>
            </div>
        </div>
    </div>
</cfoutput>

 
</body>
</html> 