<cfscript>
    securityService = new model.SecurityService();
    productService = new model.ProductService();
    
    // Require authentication and product management permission
    securityService.requireAuthentication();
    securityService.requirePermission("products.manage");
    
    // Get the requested page
    page = url.page ?: "list";
    
    // Include the appropriate page
    switch(page) {
        case "list":
            // Get pagination parameters
            pageSize = 20;
            currentPage = val(url.p ?: 1);
            
            // Get products with their stats
            getProducts = productService.getProducts(
                page: currentPage,
                pageSize: pageSize,
                status: url.status ?: ""
            );
            
            totalRecords = productService.getProductCount(status: url.status ?: "");
            include "list.cfm";
            break;
            
        case "edit":
            productID = val(url.id ?: 0);
            if (productID > 0) {
                product = productService.getProduct(productID);
            }
            include "edit.cfm";
            break;
            
        case "orders":
            // Get pagination parameters
            pageSize = 20;
            currentPage = val(url.p ?: 1);
            
            // Get orders with their details
            getOrders = productService.getOrders(
                page: currentPage,
                pageSize: pageSize,
                status: url.status ?: ""
            );
            
            totalRecords = productService.getOrderCount(status: url.status ?: "");
            include "orders.cfm";
            break;
    }
</cfscript> 