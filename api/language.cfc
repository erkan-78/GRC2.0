component {
    // Set response type to JSON
    remote any function init() {
        getPageContext().getResponse().setContentType("application/json");
    }

    remote struct function getLanguages() httpmethod="GET" {
        init();
        
        try {
            var qLanguages = queryExecute(
                "SELECT languageID, languageName FROM languages WHERE isActive = 1",
                {},
                {datasource=application.datasource}
            );
            
            return {
                "success": true,
                "data": queryToArray(qLanguages)
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while fetching languages",
                "error": e.message
            };
        }
    }

    remote struct function getTranslations(required string languageID, required string page) returnformat="json" {
        try {
            var qTranslations = queryExecute(
                "SELECT translationKey, translationValue FROM translations WHERE languageID = :languageID and page = :page",
                {languageID = {value=languageID, cfsqltype="cf_sql_varchar"}, page = {value=page, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            var translations = {};
            for (var i = 1; i <= qTranslations.recordCount; i++) {
                translations[qTranslations.translationKey[i]] = qTranslations.translationValue[i];
            }

            return {
                "success": true,
                "data": translations
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error fetching translations: " & e.message
            };
        }
    }

    remote struct function updateUserLanguage(
        required numeric userID,
        required string languageID
    ) httpmethod="PUT" {
        init();
        
        try {
            if (NOT session.isLoggedIn OR session.userID NEQ arguments.userID) {
                return {
                    "success": false,
                    "message": "Unauthorized access"
                };
            }
            
            queryExecute(
                "UPDATE users SET preferredLanguage = :languageID WHERE userID = :userID",
                {
                    userID = {value=arguments.userID, cfsqltype="cf_sql_integer"},
                    languageID = {value=arguments.languageID, cfsqltype="cf_sql_varchar"}
                },
                {datasource=application.datasource}
            );
            
            session.preferredLanguage = arguments.languageID;
            
            return {
                "success": true,
                "message": "Language preference updated successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "An error occurred while updating language preference",
                "error": e.message
            };
        }
    }

    private array function queryToArray(required query qry) {
        var array = [];
        for (var row in arguments.qry) {
            arrayAppend(array, row);
        }
        return array;
    }

    remote function getAllLanguages() returnformat="json" {
        try {
            var qLanguages = queryExecute(
                "SELECT languageID, languageName, isActive FROM languages",
                [],
                {datasource=application.datasource}
            );

            return {
                "success": true,
                "data": qLanguages.toArray()
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error fetching languages: " & e.message
            };
        }
    }

    remote function saveLanguage(required struct formData) returnformat="json" {
        try {
            if (NOT structKeyExists(formData, "languageID") OR 
                NOT structKeyExists(formData, "languageName")) {
                return {
                    "success": false,
                    "message": "Language ID and name are required"
                };
            }

            if (formData.languageID) {
                // Update existing language
                queryExecute(
                    "UPDATE languages SET languageName = :languageName, isActive = :isActive WHERE languageID = :languageID",
                    {
                        languageName = {value=formData.languageName, cfsqltype="cf_sql_varchar"},
                        isActive = {value=formData.isActive, cfsqltype="cf_sql_bit"},
                        languageID = {value=formData.languageID, cfsqltype="cf_sql_varchar"}
                    },
                    {datasource=application.datasource}
                );
            } else {
                // Insert new language
                queryExecute(
                    "INSERT INTO languages (languageID, languageName, isActive) VALUES (:languageID, :languageName, :isActive)",
                    {
                        languageID = {value=formData.languageCode, cfsqltype="cf_sql_varchar"},
                        languageName = {value=formData.languageName, cfsqltype="cf_sql_varchar"},
                        isActive = {value=formData.isActive, cfsqltype="cf_sql_bit"}
                    },
                    {datasource=application.datasource}
                );
            }

            return {
                "success": true,
                "message": "Language saved successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error saving language: " & e.message
            };
        }
    }

    remote function getLanguage(required string languageID) returnformat="json" {
        try {
            var qLanguage = queryExecute(
                "SELECT languageID, languageName, isActive FROM languages WHERE languageID = :languageID",
                {languageID = {value=languageID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (qLanguage.recordCount) {
                return {
                    "success": true,
                    "data": qLanguage.toArray()[1]
                };
            } else {
                return {
                    "success": false,
                    "message": "Language not found"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "Error fetching language: " & e.message
            };
        }
    }

    remote function toggleLanguage(required struct formData) returnformat="json" {
        try {
            if (NOT structKeyExists(formData, "languageID")) {
                return {
                    "success": false,
                    "message": "Language ID is required"
                };
            }

            queryExecute(
                "UPDATE languages SET isActive = NOT isActive WHERE languageID = :languageID",
                {languageID = {value=formData.languageID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            return {
                "success": true,
                "message": "Language status updated successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error toggling language: " & e.message
            };
        }
    }

    remote function getAllCurrencies() returnformat="json" {
        try {
            var qCurrencies = queryExecute(
                "SELECT currencyID, currencyName, isActive FROM currencies",
                [],
                {datasource=application.datasource}
            );

            return {
                "success": true,
                "data": qCurrencies.toArray()
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error fetching currencies: " & e.message
            };
        }
    }

    remote function saveCurrency(required struct formData) returnformat="json" {
        try {
            if (NOT structKeyExists(formData, "currencyID") OR 
                NOT structKeyExists(formData, "currencyName")) {
                return {
                    "success": false,
                    "message": "Currency ID and name are required"
                };
            }

            if (formData.currencyID) {
                // Update existing currency
                queryExecute(
                    "UPDATE currencies SET currencyName = :currencyName, isActive = :isActive WHERE currencyID = :currencyID",
                    {
                        currencyName = {value=formData.currencyName, cfsqltype="cf_sql_varchar"},
                        isActive = {value=formData.isActive, cfsqltype="cf_sql_bit"},
                        currencyID = {value=formData.currencyID, cfsqltype="cf_sql_varchar"}
                    },
                    {datasource=application.datasource}
                );
            } else {
                // Insert new currency
                queryExecute(
                    "INSERT INTO currencies (currencyID, currencyName, isActive) VALUES (:currencyID, :currencyName, :isActive)",
                    {
                        currencyID = {value=formData.currencyID, cfsqltype="cf_sql_varchar"},
                        currencyName = {value=formData.currencyName, cfsqltype="cf_sql_varchar"},
                        isActive = {value=formData.isActive, cfsqltype="cf_sql_bit"}
                    },
                    {datasource=application.datasource}
                );
            }

            return {
                "success": true,
                "message": "Currency saved successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error saving currency: " & e.message
            };
        }
    }

    remote function getCurrency(required string currencyID) returnformat="json" {
        try {
            var qCurrency = queryExecute(
                "SELECT currencyID, currencyName, isActive FROM currencies WHERE currencyID = :currencyID",
                {currencyID = {value=currencyID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (qCurrency.recordCount) {
                return {
                    "success": true,
                    "data": qCurrency.toArray()[1]
                };
            } else {
                return {
                    "success": false,
                    "message": "Currency not found"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "Error fetching currency: " & e.message
            };
        }
    }

    remote function getAllExchangeRates() returnformat="json" {
        try {
            var qExchangeRates = queryExecute(
                "SELECT er.rateID, c.currencyID, er.exchangeRate, er.startDate, er.endDate 
                 FROM exchange_rates er 
                 JOIN currencies c ON er.currencyID = c.currencyID",
                [],
                {datasource=application.datasource}
            );

            return {
                "success": true,
                "data": qExchangeRates.toArray()
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error fetching exchange rates: " & e.message
            };
        }
    }

    remote function saveExchangeRate(required struct formData) returnformat="json" {
        try {
            if (NOT structKeyExists(formData, "exchangeCurrencyID") OR 
                NOT structKeyExists(formData, "exchangeRate") OR 
                NOT structKeyExists(formData, "startDate")) {
                return {
                    "success": false,
                    "message": "Currency ID, exchange rate, and start date are required"
                };
            }

            if (formData.rateID) {
                // Update existing exchange rate
                queryExecute(
                    "UPDATE exchange_rates SET exchangeRate = :exchangeRate, startDate = :startDate, endDate = :endDate WHERE rateID = :rateID",
                    {
                        exchangeRate = {value=formData.exchangeRate, cfsqltype="cf_sql_decimal"},
                        startDate = {value=formData.startDate, cfsqltype="cf_sql_timestamp"},
                        endDate = {value=formData.endDate, cfsqltype="cf_sql_timestamp"},
                        rateID = {value=formData.rateID, cfsqltype="cf_sql_integer"}
                    },
                    {datasource=application.datasource}
                );
            } else {
                // Insert new exchange rate
                queryExecute(
                    "INSERT INTO exchange_rates (currencyID, companyID, exchangeRate, startDate, endDate) VALUES (:currencyID, :companyID, :exchangeRate, :startDate, :endDate)",
                    {
                        currencyID = {value=formData.exchangeCurrencyID, cfsqltype="cf_sql_varchar"},
                        companyID = {value=session.companyID, cfsqltype="cf_sql_varchar"}, // Assuming companyID is in session
                        exchangeRate = {value=formData.exchangeRate, cfsqltype="cf_sql_decimal"},
                        startDate = {value=formData.startDate, cfsqltype="cf_sql_timestamp"},
                        endDate = {value=formData.endDate, cfsqltype="cf_sql_timestamp"}
                    },
                    {datasource=application.datasource}
                );
            }

            return {
                "success": true,
                "message": "Exchange rate saved successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error saving exchange rate: " & e.message
            };
        }
    }

    remote function getExchangeRate(required string rateID) returnformat="json" {
        try {
            var qRate = queryExecute(
                "SELECT rateID, currencyID, exchangeRate, startDate, endDate FROM exchange_rates WHERE rateID = :rateID",
                {rateID = {value=rateID, cfsqltype="cf_sql_integer"}},
                {datasource=application.datasource}
            );

            if (qRate.recordCount) {
                return {
                    "success": true,
                    "data": qRate.toArray()[1]
                };
            } else {
                return {
                    "success": false,
                    "message": "Exchange rate not found"
                };
            }
        } catch (any e) {
            return {
                "success": false,
                "message": "Error fetching exchange rate: " & e.message
            };
        }
    }

    remote function sendEmail(required string to, required string subject, required string body, string companyID = "") returnformat="json" {
        try {
            var emailConfig = getEmailConfig(companyID);
            var mail = createObject("component", "mail");
            mail.setTo(to);
            mail.setSubject(subject);
            mail.setBody(body);
            mail.setFrom(emailConfig.from);
            mail.setUsername(emailConfig.username);
            mail.setPassword(emailConfig.password);
            mail.setHost(emailConfig.host);
            mail.setPort(emailConfig.port);
            mail.setSSL(emailConfig.ssl);

            mail.send();
            return {
                "success": true,
                "message": "Email sent successfully"
            };
        } catch (any e) {
            return {
                "success": false,
                "message": "Error sending email: " & e.message
            };
        }
    }

    private function getEmailConfig(required string companyID) {
        // Fetch email configuration from the database
        if (companyID) {
            var qEmailConfig = queryExecute(
                "SELECT email, username, password, host, port, ssl FROM company_email WHERE companyID = :companyID",
                {companyID = {value=companyID, cfsqltype="cf_sql_varchar"}},
                {datasource=application.datasource}
            );

            if (qEmailConfig.recordCount) {
                return {
                    "from": qEmailConfig.email,
                    "username": qEmailConfig.username,
                    "password": qEmailConfig.password,
                    "host": qEmailConfig.host,
                    "port": qEmailConfig.port,
                    "ssl": qEmailConfig.ssl
                };
            }
        }

        // Fallback to site-level email configuration
        return {
            "from": application.siteEmail,
            "username": application.siteEmailUsername,
            "password": application.siteEmailPassword,
            "host": application.siteEmailHost,
            "port": application.siteEmailPort,
            "ssl": application.siteEmailSSL
        };
    }
} 