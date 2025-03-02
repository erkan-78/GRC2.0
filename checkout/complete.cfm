<!DOCTYPE html>
<html>
<head>
    <title>Order Confirmation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <cfscript>
            securityService = new model.SecurityService();
            productService = new model.ProductService();
            monzoService = new model.MonzoService();
            
            // Require authentication
            securityService.requireAuthentication();
            
            // Get order details
            orderID = url.orderID ?: 0;
            paymentID = url.payment_id ?: "";
            
            if (orderID && paymentID) {
                // Get payment status from Monzo
                paymentStatus = monzoService.getPaymentStatus(paymentID);
                
                if (paymentStatus.status == "completed") {
                    // Clear cart
                    structDelete(session, "cart");
                    
                    // Get order details
                    order = productService.getOrder(orderID);
                    writeOutput('
                        <div class="text-center">
                            <h1 class="text-success mb-4">Order Confirmed!</h1>
                            <p class="lead">Thank you for your order. Your order number is ##' & orderID & '</p>
                            <p>We will process your order shortly.</p>
                            <div class="mt-4">
                                <a href="/account/orders.cfm" class="btn btn-primary">View Your Orders</a>
                                <a href="/products/index.cfm" class="btn btn-secondary">Continue Shopping</a>
                            </div>
                        </div>
                    ');
                } else {
                    writeOutput('
                        <div class="text-center">
                            <h1 class="text-danger mb-4">Payment Failed</h1>
                            <p class="lead">There was a problem processing your payment.</p>
                            <p>Please try again or contact customer support if the problem persists.</p>
                            <div class="mt-4">
                                <a href="/checkout/index.cfm" class="btn btn-primary">Try Again</a>
                                <a href="/contact.cfm" class="btn btn-secondary">Contact Support</a>
                            </div>
                        </div>
                    ');
                }
            } else {
                writeOutput('
                    <div class="text-center">
                        <h1 class="text-warning mb-4">Invalid Order</h1>
                        <p class="lead">We could not find your order.</p>
                        <div class="mt-4">
                            <a href="/products/index.cfm" class="btn btn-primary">Continue Shopping</a>
                        </div>
                    </div>
                ');
            }
        </cfscript>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 