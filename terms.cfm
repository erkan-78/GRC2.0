<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms of Service - LightGRC</title>
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

        .terms-container {
            background: var(--white);
            border-radius: 12px;
            box-shadow: var(--shadow-md);
            width: 100%;
            max-width: 900px;
            padding: 2rem;
        }

        .terms-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1.5rem;
        }

        .terms-table th,
        .terms-table td {
            padding: 1rem;
            border: 1px solid var(--gray-200);
        }

        .terms-table th {
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
        <div class="terms-container">
            <div class="brand-header">
                <div class="logo-text">Light<span class="highlight">GRC</span></div>
                <h2>Terms of Service</h2>
                <p class="text-muted">Last updated: #dateFormat(now(), "mmmm d, yyyy")#</p>
            </div>

            <table class="terms-table">
                <tr class="section-title">
                    <th colspan="2">1. Service Description</th>
                </tr>
                <tr>
                    <th width="30%">Platform Features</th>
                    <td>
                        • Risk Management and Assessment<br>
                        • Policy and Procedure Management<br>
                        • Audit Management and Documentation<br>
                        • Compliance Management and Monitoring<br>
                        • Automated Control Testing
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">2. Subscription Terms</th>
                </tr>
                <tr>
                    <th>License Details</th>
                    <td>
                        • User-based licensing model<br>
                        • Annual subscription terms<br>
                        • Enterprise support included<br>
                        • Unlimited storage allocation
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">3. Data Security</th>
                </tr>
                <tr>
                    <th>Security Measures</th>
                    <td>
                        • End-to-end encryption<br>
                        • Multi-factor authentication<br>
                        • Regular security audits<br>
                        • Automated backup systems
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">4. Service Level Agreement</th>
                </tr>
                <tr>
                    <th>Availability</th>
                    <td>
                        • 99.9% uptime guarantee<br>
                        • 24/7 monitoring<br>
                        • 4-hour response time<br>
                        • Scheduled maintenance windows
                    </td>
                </tr>

                <tr class="section-title">
                    <th colspan="2">5. Support Services</th>
                </tr>
                <tr>
                    <th>Support Coverage</th>
                    <td>
                        • Technical support (24/5)<br>
                        • Implementation assistance<br>
                        • Training resources<br>
                        • Documentation access
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