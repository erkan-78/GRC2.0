<!DOCTYPE html>
<html>
<head>
    <title>Product Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Product Management</h2>
            <div>
                <a href="index.cfm?page=orders" class="btn btn-info me-2">View Orders</a>
                <a href="index.cfm?page=edit" class="btn btn-primary">Add New Product</a>
            </div>
        </div>

        <!--- Status Filter --->
        <div class="card mb-4">
            <div class="card-body">
                <form action="index.cfm" method="get" class="row g-3">
                    <div class="col-md-3">
                        <label for="status" class="form-label">Status:</label>
                        <select name="status" id="status" class="form-control">
                            <option value="">All Status</option>
                            <option value="active" <cfif url.status eq "active">selected</cfif>>Active</option>
                            <option value="inactive" <cfif url.status eq "inactive">selected</cfif>>Inactive</option>
                            <option value="discontinued" <cfif url.status eq "discontinued">selected</cfif>>Discontinued</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-primary w-100">Filter</button>
                    </div>
                </form>
            </div>
        </div>

        <!--- Products Table --->
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>SKU</th>
                        <th>Name</th>
                        <th>Price</th>
                        <th>Status</th>
                        <th>Last Modified</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getProducts">
                        <tr>
                            <td>#sku#</td>
                            <td>#name#</td>
                            <td>£#numberFormat(price, ",.2")#</td>
                            <td>
                                <span class="badge bg-#status eq 'active' ? 'success' : (status eq 'inactive' ? 'warning' : 'danger')#">
                                    #status#
                                </span>
                            </td>
                            <td>#dateTimeFormat(modified, "yyyy-mm-dd HH:nn:ss")#</td>
                            <td>
                                <a href="index.cfm?page=edit&id=#productID#" class="btn btn-sm btn-primary">Edit</a>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <!--- Pagination --->
        <cfif getProducts.recordCount GT 0>
            <div class="d-flex justify-content-between align-items-center mt-4">
                <div>
                    Showing #((currentPage-1)*pageSize)+1# to #min(currentPage*pageSize, totalRecords)# of #totalRecords# products
                </div>
                <nav>
                    <ul class="pagination">
                        <cfloop from="1" to="#ceiling(totalRecords/pageSize)#" index="i">
                            <li class="page-item #i eq currentPage ? 'active' : ''#">
                                <a class="page-link" href="index.cfm?page=list&p=#i#&status=#url.status#">#i#</a>
                            </li>
                        </cfloop>
                    </ul>
                </nav>
            </div>
        </cfif>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 