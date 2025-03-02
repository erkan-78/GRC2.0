component {
    
    public void function init() {
        variables.monzoApiKey = application.config.monzo.apiKey;
        variables.monzoApiEndpoint = application.config.monzo.apiEndpoint;
        variables.webhookSecret = application.config.monzo.webhookSecret;
    }
    
    public struct function createPayment(
        required numeric amount,
        required string currency = "GBP",
        required string description,
        required string returnUrl,
        required string metadata = {}
    ) {
        var requestBody = {
            "amount": arguments.amount,
            "currency": arguments.currency,
            "description": arguments.description,
            "return_url": arguments.returnUrl,
            "metadata": arguments.metadata
        };
        
        var result = makeApiRequest(
            endpoint = "/payments",
            method = "POST",
            body = requestBody
        );
        
        return {
            "success": true,
            "paymentId": result.id,
            "redirectUrl": result.redirect_url
        };
    }
    
    public struct function getPaymentStatus(required string paymentId) {
        var result = makeApiRequest(
            endpoint = "/payments/#arguments.paymentId#",
            method = "GET"
        );
        
        return {
            "success": true,
            "status": result.status,
            "amount": result.amount,
            "currency": result.currency,
            "metadata": result.metadata
        };
    }
    
    public void function handleWebhook(required struct payload) {
        // Verify webhook signature
        if (!verifyWebhookSignature(payload)) {
            throw(type="MonzoError", message="Invalid webhook signature");
        }
        
        // Process the webhook based on type
        switch(payload.type) {
            case "payment.completed":
                processPaymentCompleted(payload);
                break;
            case "payment.failed":
                processPaymentFailed(payload);
                break;
            case "payment.refunded":
                processPaymentRefunded(payload);
                break;
        }
    }
    
    private boolean function verifyWebhookSignature(required struct payload) {
        var signature = getHttpRequestData().headers["Monzo-Signature"];
        var expectedSignature = hmac(serializeJSON(payload), variables.webhookSecret, "HMACSHA256");
        return signature == expectedSignature;
    }
    
    private void function processPaymentCompleted(required struct payload) {
        var orderID = payload.metadata.orderID;
        
        queryExecute("
            UPDATE orders
            SET status = 'completed',
                monzoPaymentID = :paymentID,
                modified = NOW()
            WHERE orderID = :orderID
        ", {
            paymentID: { value: payload.id, cfsqltype: "cf_sql_varchar" },
            orderID: { value: orderID, cfsqltype: "cf_sql_integer" }
        });
        
        // Record the transaction
        queryExecute("
            INSERT INTO monzo_transactions (
                orderID,
                monzoTransactionID,
                amount,
                status,
                responseData
            ) VALUES (
                :orderID,
                :transactionID,
                :amount,
                :status,
                :responseData
            )
        ", {
            orderID: { value: orderID, cfsqltype: "cf_sql_integer" },
            transactionID: { value: payload.id, cfsqltype: "cf_sql_varchar" },
            amount: { value: payload.amount, cfsqltype: "cf_sql_decimal" },
            status: { value: "completed", cfsqltype: "cf_sql_varchar" },
            responseData: { value: serializeJSON(payload), cfsqltype: "cf_sql_longvarchar" }
        });
    }
    
    private void function processPaymentFailed(required struct payload) {
        var orderID = payload.metadata.orderID;
        
        queryExecute("
            UPDATE orders
            SET status = 'failed',
                modified = NOW()
            WHERE orderID = :orderID
        ", {
            orderID: { value: orderID, cfsqltype: "cf_sql_integer" }
        });
        
        // Record the transaction
        queryExecute("
            INSERT INTO monzo_transactions (
                orderID,
                monzoTransactionID,
                amount,
                status,
                responseData
            ) VALUES (
                :orderID,
                :transactionID,
                :amount,
                :status,
                :responseData
            )
        ", {
            orderID: { value: orderID, cfsqltype: "cf_sql_integer" },
            transactionID: { value: payload.id, cfsqltype: "cf_sql_varchar" },
            amount: { value: payload.amount, cfsqltype: "cf_sql_decimal" },
            status: { value: "failed", cfsqltype: "cf_sql_varchar" },
            responseData: { value: serializeJSON(payload), cfsqltype: "cf_sql_longvarchar" }
        });
    }
    
    private struct function makeApiRequest(
        required string endpoint,
        required string method,
        struct body = {}
    ) {
        var httpService = new http();
        httpService.setMethod(arguments.method);
        httpService.setUrl(variables.monzoApiEndpoint & arguments.endpoint);
        httpService.addParam(type="header", name="Authorization", value="Bearer " & variables.monzoApiKey);
        httpService.addParam(type="header", name="Content-Type", value="application/json");
        
        if (arguments.method != "GET" && !structIsEmpty(arguments.body)) {
            httpService.addParam(type="body", value=serializeJSON(arguments.body));
        }
        
        var response = httpService.send().getPrefix();
        
        if (response.responseHeader.status_code != 200) {
            throw(
                type="MonzoError",
                message="Monzo API Error: " & response.fileContent,
                detail="Status Code: " & response.responseHeader.status_code
            );
        }
        
        return deserializeJSON(response.fileContent);
    }
} 