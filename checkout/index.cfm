<cfscript>
    securityService = new model.SecurityService();
    productService = new model.ProductService();
    monzoService = new model.MonzoService();
    
    // Require authentication
    securityService.requireAuthentication();
    
    // Get cart items from session
    cart = session.cart ?: [];
    
    if (structKeyExists(form, "processCheckout")) {
        // Create order
        orderID = productService.createOrder(
            userID: session.userID,
            items: cart
        );
        
        // Calculate total
        total = 0;
        for (var item in cart) {
            total += item.price * item.quantity;
        }
        
        // Create Monzo payment
        paymentResult = monzoService.createPayment(
            amount: total * 100, // Convert to pence
            description: "Order ##" & orderID,
            returnUrl: "https://yourdomain.com/checkout/complete.cfm?orderID=" & orderID,
            metadata: {
                "orderID": orderID,
                "userID": session.userID
            }
        );
        
        // Redirect to Monzo payment page
        location(url=paymentResult.redirectUrl, addToken=false);
    }
    
    // Display checkout page
    include "checkout.cfm";
</cfscript> 