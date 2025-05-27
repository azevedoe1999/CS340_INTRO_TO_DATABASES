## Citations:
## From CS340 Exploration - Web Application Technology:
## Copied starter code for some of the app.py file and other webpages under Templates folder
## Used GitHub Copilot to help with the debugging process

from flask import Flask, render_template, json, redirect, request
from flask_mysqldb import MySQL
import os
import MySQLdb.cursors

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'classmysql.engr.oregonstate.edu'
app.config['MYSQL_USER'] = 'cs340_azevedoe'
app.config['MYSQL_PASSWORD'] = '2541'
app.config['MYSQL_DB'] = 'cs340_azevedoe'
app.config['MYSQL_CURSORCLASS'] = "DictCursor"

mysql = MySQL(app)

@app.route('/')
def index():
    return render_template("index.html")

################################ Customers CRUD Routes
@app.route("/customers", methods=["GET", "POST"])
def show_customers():
    error_message = None  # Optional error for duplicate email

    if request.method == "POST":
        try:
            # Regular cursor for stored procedure call
            proc_cursor = mysql.connection.cursor()

            first_name = request.form['first_name']
            last_name = request.form['last_name']
            email = request.form['email']
            phone = request.form['phone']

            proc_cursor.callproc("sp_CreateCustomer", [first_name, last_name, email, phone, None])

            mysql.connection.commit()

        except MySQLdb.IntegrityError as e:
            if e.args[0] == 1062:
                error_message = "That email address is already in use."
            else:
                error_message = f"An error occurred: {str(e)}"
        finally:
            proc_cursor.close()

    # DictCursor ONLY for fetching SELECT results
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM Customers WHERE isActive = 1;")
    customers_data = cursor.fetchall()
    cursor.close()

    return render_template("customers.html", customers=customers_data, error=error_message)




@app.route('/add_customer', methods=['GET', 'POST'])
def add_customer():
    if request.method == 'POST':
        proc_cursor = mysql.connection.cursor()  # regular cursor
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        email = request.form['email']
        phone = request.form['phone']

        proc_cursor.callproc("sp_CreateCustomer", [first_name, last_name, email, phone, None])
        proc_cursor.close()
        mysql.connection.commit()
        return redirect('/customers')

    return render_template('add_customers.html')


@app.route('/update_customer/<int:customerID>', methods=['GET', 'POST'])
def update_customer(customerID):
    cursor = mysql.connection.cursor()
    if request.method == 'POST':
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        email = request.form['email']
        phone = request.form['phone']

        cursor.callproc("sp_UpdateCustomer", [customerID, first_name, last_name, email, phone])
        mysql.connection.commit()
        return redirect('/customers')

    # GET request
    cursor.execute("SELECT * FROM Customers;")
    customers = cursor.fetchall()
    cursor.execute("SELECT * FROM Customers WHERE customerID = %s;", (customerID,))
    selected_customer = cursor.fetchone()
    cursor.close()

    return render_template("update_customers.html", customers=customers, selected_customer=selected_customer)

@app.route('/delete_customer/<int:customerID>')
def delete_customer(customerID):
    cursor = mysql.connection.cursor()
    cursor.callproc("sp_DeleteCustomer", [customerID])
    mysql.connection.commit()
    cursor.close()
    return redirect('/customers')



################################ Sales CRUD Routes

@app.route("/sales", methods=["GET", "POST"])
def show_sales():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    error_message = None

    if request.method == "POST":
        try:
            customer_id = int(request.form["customer_id"])
            employee_id = int(request.form["employee_id"])
            sale_date = request.form["sale_date"]
            subtotal = float(request.form["subtotal"])
            discount = float(request.form["discount"])
            tax = float(request.form["tax"])
            total_amount = float(request.form["total_amount"])
            payment_method = request.form["payment_method"]

            cursor.callproc("sp_CreateSale", [
                customer_id, employee_id, sale_date,
                subtotal, discount, tax, total_amount,
                payment_method, None
            ])
            mysql.connection.commit()

        except Exception as e:
            error_message = f"An error occurred: {str(e)}"

    # Fetch dropdown values
    cursor.execute("SELECT customerID, firstName, lastName FROM Customers WHERE isActive = 1;")
    customers = cursor.fetchall()

    cursor.execute("SELECT employeeID, firstName, lastName FROM Employees WHERE isActive = 1;")
    employees = cursor.fetchall()

    # Fetch sales WITH customer and employee names, sorted by saleID ascending
    cursor.execute("""
        SELECT
            s.saleID,
            CONCAT(c.firstName, ' ', c.lastName) AS customerName,
            CONCAT(e.firstName, ' ', e.lastName) AS employeeName,
            s.saleDate,
            s.subtotal,
            s.discount,
            s.tax,
            s.totalAmount,
            s.paymentMethod
        FROM Sales s
        JOIN Customers c ON s.customerID = c.customerID
        JOIN Employees e ON s.employeeID = e.employeeID
        ORDER BY s.saleID ASC;
    """)
    sales = cursor.fetchall()

    cursor.close()
    return render_template(
        "sales.html",
        sales=sales,
        customers=customers,
        employees=employees,
        error=error_message
    )


@app.route("/update_sale/<int:saleID>", methods=["GET", "POST"])
def update_sale(saleID):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    if request.method == "POST":
        customer_id = int(request.form["customer_id"])
        employee_id = int(request.form["employee_id"])
        sale_date = request.form["sale_date"]
        subtotal = float(request.form["subtotal"])
        discount = float(request.form["discount"])
        tax = float(request.form["tax"])
        total_amount = float(request.form["total_amount"])
        payment_method = request.form["payment_method"]

        cursor.callproc("sp_UpdateSale", [
            saleID, customer_id, employee_id, sale_date,
            subtotal, discount, tax, total_amount, payment_method
        ])
        mysql.connection.commit()
        cursor.close()
        return redirect("/sales")

    # GET request
    # Fetch all sales
    cursor.execute("""
        SELECT
            s.saleID,
            CONCAT(c.firstName, ' ', c.lastName) AS customerName,
            CONCAT(e.firstName, ' ', e.lastName) AS employeeName,
            s.saleDate,
            s.subtotal,
            s.discount,
            s.tax,
            s.totalAmount,
            s.paymentMethod
        FROM Sales s
        JOIN Customers c ON s.customerID = c.customerID
        JOIN Employees e ON s.employeeID = e.employeeID
        ORDER BY s.saleID ASC;
    """)
    sales = cursor.fetchall()

    # Fetch selected sale (raw) for the form inputs
    cursor.execute("SELECT * FROM Sales WHERE saleID = %s;", (saleID,))
    selected_sale = cursor.fetchone()

    # Fetch customers and employees for dropdowns
    cursor.execute("SELECT customerID, firstName, lastName FROM Customers WHERE isActive = 1;")
    customers = cursor.fetchall()

    cursor.execute("SELECT employeeID, firstName, lastName FROM Employees WHERE isActive = 1;")
    employees = cursor.fetchall()

    cursor.close()
    return render_template(
        "update_sale.html",
        sales=sales,
        selected_sale=selected_sale,
        customers=customers,
        employees=employees
    )


@app.route("/delete_sale/<int:saleID>")
def delete_sale(saleID):
    cursor = mysql.connection.cursor()
    cursor.callproc("sp_DeleteSale", [saleID])
    mysql.connection.commit()
    cursor.close()
    return redirect("/sales")


################################ Employees CRUD Routes

@app.route("/employees", methods=["GET", "POST"])
def show_employees():
    error_message = None
    cursor = mysql.connection.cursor()

    if request.method == "POST":
        try:
            first_name = request.form['first_name']
            last_name = request.form['last_name']
            email = request.form['email']
            role = request.form['role']
            hire_date = request.form['hire_date']
            is_active = int(request.form['is_active'])

            cursor.callproc("sp_CreateEmployee", [first_name, last_name, email, role, hire_date, is_active, None])
            mysql.connection.commit()
        except Exception as e:
            error_message = f"An error occurred: {str(e)}"

    # Show only active employees
    cursor.execute("SELECT * FROM Employees WHERE isActive = 1;")
    employees = cursor.fetchall()
    cursor.close()
    return render_template("employees.html", employees=employees, error=error_message)


@app.route("/update_employee/<int:employeeID>", methods=["GET", "POST"])
def update_employee(employeeID):
    cursor = mysql.connection.cursor()

    if request.method == "POST":
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        email = request.form['email']
        role = request.form['role']
        hire_date = request.form['hire_date']
        is_active = int(request.form['is_active'])

        cursor.callproc("sp_UpdateEmployee", [employeeID, first_name, last_name, email, role, hire_date, is_active])
        mysql.connection.commit()
        cursor.close()
        return redirect("/employees")

    # GET request
    cursor.execute("SELECT * FROM Employees WHERE isActive = 1;")
    employees = cursor.fetchall()
    cursor.execute("SELECT * FROM Employees WHERE employeeID = %s;", (employeeID,))
    selected_employee = cursor.fetchone()
    cursor.close()
    return render_template("update_employee.html", employees=employees, selected_employee=selected_employee)


@app.route("/delete_employee/<int:employeeID>")
def delete_employee(employeeID):
    cursor = mysql.connection.cursor()
    cursor.callproc("sp_DeleteEmployee", [employeeID])
    mysql.connection.commit()
    cursor.close()
    return redirect("/employees")


################################ Categories CRUD Routes

@app.route("/categories", methods=["GET", "POST"])
def show_categories():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        
        # Handle new category creation
        if request.method == "POST":
            category_name = request.form['category_name']
            category_description = request.form['category_description']
            category_isActive = request.form['category_isActive']

            query1 = "CALL sp_CreateCategory(%s, %s, %s, @new_id);"
            cursor.execute(query1, (category_name, category_description, category_isActive))
            new_id_row = cursor.fetchone()
            new_id = new_id_row['new_id'] 
            cursor.nextset() 
            mysql.connection.commit()
            print(f"CREATE Categories. ID: {new_id} Name: {category_name}")

        # Fetch categories list
        query_fetch = """
        SELECT categoryID, categoryName, description, 
        CASE WHEN isActive = 1 THEN 'Yes' ELSE 'No' END AS isActive 
        FROM Categories;
        """
        cursor.execute(query_fetch)
        category = cursor.fetchall()
        cursor.close()

        # Render file, and also send the renderer a couple objects that contains category information
        return render_template(
            "categories.j2", category=category
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()

@app.route("/add_category", methods=["POST"])
def add_category():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Get form data
        category_name = request.form["category_name"]
        category_description = request.form['category_description']
        category_isActive = request.form["category_isActive"]


        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_CreateCategory(%s, %s, %s, @new_id);"
        cursor.execute(query1, (category_name, category_description, category_isActive))

        # Store ID of last inserted row
        new_id_row = cursor.fetchone()
        new_id = new_id_row['new_id']

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        mysql.connection.commit()  # commit the transaction

        print(f"CREATE Categories. ID: {new_id} Name: {category_name}")

        # Redirect the user to the updated webpage
        return redirect("/categories")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()

@app.route("/update_category/<int:categoryID>", methods=["GET", "POST"])
def update_category(categoryID):
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Update category list
        if request.method == "POST":
            # Get form data
            category_name = request.form['category_name']
            description = request.form['description']
            is_active = request.form['is_active']

            # Create and execute our queries
            # Using parameterized queries (Prevents SQL injection attacks)
            query1 = "CALL sp_UpdateCategory(%s, %s, %s, %s);"
            cursor.execute(query1, (categoryID, category_name, description, is_active))

            # Consume the result set (if any) before running the next query
            cursor.nextset()  # Move to the next result set (for CALL statements)

            mysql.connection.commit()  # commit the transaction

            query2 = "SELECT * FROM Categories WHERE categoryID = %s;"
            cursor.execute(query2, (categoryID,))
            rows = cursor.fetchone()  # Fetch name info on updated person

            print(f"UPDATE Categories. ID: {categoryID} Name: {rows['categoryName']}")

            # Redirect the user to the updated webpage
            return redirect("/categories")

        # Fetch all categories and the selected category
        cursor.execute("SELECT * FROM Categories;")
        category = cursor.fetchall()
        cursor.execute("SELECT * FROM Categories WHERE categoryID = %s;", (categoryID,))
        selected_category = cursor.fetchone()

        return render_template("update_category.j2", category=category, selected_category=selected_category)

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()


@app.route("/delete_category/<int:categoryID>")
def delete_category(categoryID):
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Fetch the category name for logging
        cursor.execute("SELECT categoryName FROM Categories WHERE categoryID = %s;", (categoryID,))
        row = cursor.fetchone()
        category_name = row['categoryName']

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteCategory(%s);"
        cursor.execute(query1, (categoryID,))

        mysql.connection.commit()  # commit the transaction

        print(f"DELETE Categories. ID: {categoryID} Name: {category_name}")

        # Redirect to the categories page
        return redirect("/categories")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()

################################ Products CRUD Routes

@app.route("/products", methods=["GET", "POST"])
def show_products():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Handle new product creation
        if request.method == "POST":
            product_name = request.form['product_name']
            product_description = request.form['product_description']
            product_price = request.form['product_price']
            product_stockQuantity = request.form['product_stockQuantity']
            product_isActive = request.form['product_isActive']
            product_categoryID = request.form['product_categoryID']

            query1 = "CALL sp_CreateProduct(%s, %s, %s, %s, %s, %s, @new_id);"
            cursor.execute(query1, (product_name, product_description, product_price, product_stockQuantity, product_isActive, product_categoryID))
            new_id_row = cursor.fetchone()
            new_id = new_id_row['new_id'] 
            cursor.nextset() 
            mysql.connection.commit()
            print(f"CREATE Products. ID: {new_id} Name: {product_name}")

        # Fetch categories list for the dropdown
        query_categories = "SELECT categoryID, categoryName FROM Categories;"
        cursor.execute(query_categories)
        category = cursor.fetchall()

        # Fetch products list
        query_fetch = """
        SELECT Products.productID, Products.productName, Products.description, Products.price, Products.stockQuantity, 
        CASE WHEN Products.isActive = 1 THEN 'Yes' ELSE 'No' END AS isActive, 
        Categories.categoryName 
        FROM Products
        JOIN Categories ON Products.categoryID = Categories.categoryID;
        """

        cursor.execute(query_fetch)
        product = cursor.fetchall()
        cursor.close()

        # Render file, and also send the renderer a couple objects that contains product information
        return render_template(
            "products.j2", product=product, category=category
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()

@app.route("/add_product", methods=["POST"])
def add_product():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        product_name = request.form['product_name']
        product_description = request.form['product_description']
        product_price = request.form['product_price']
        product_stockQuantity = request.form['product_stockQuantity']
        product_isActive = request.form['product_isActive']
        product_categoryID = request.form['product_categoryID']
        
        
        query1 = "CALL sp_CreateProduct(%s, %s, %s, %s, %s, %s, @new_id);"
        cursor.execute(query1, (product_name, product_description, product_price, product_stockQuantity, product_isActive, product_categoryID))
        new_id_row = cursor.fetchone()
        new_id = new_id_row['new_id'] 
        cursor.nextset() 
        mysql.connection.commit()
        print(f"CREATE Products. ID: {new_id} Name: {product_name}")

        # Redirect to the products page
        return redirect("/products")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()

@app.route("/update_product/<int:productID>", methods=["GET", "POST"])
def update_product(productID):
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Update product list
        if request.method == "POST":
            product_name = request.form['product_name']
            product_description = request.form['product_description']
            product_price = request.form['product_price']
            product_stockQuantity = request.form['product_stockQuantity']
            product_isActive = request.form['product_isActive']
            product_categoryID = request.form['product_categoryID']

            # Create and execute our queries
            # Using parameterized queries (Prevents SQL injection attacks)
            query1 = "CALL sp_UpdateProduct(%s, %s, %s, %s, %s, %s, %s);"
            cursor.execute(query1, (productID, product_name, product_description, product_price, product_stockQuantity, product_isActive, product_categoryID,))

            # Consume the result set (if any) before running the next query
            cursor.nextset()  # Move to the next result set (for CALL statements)

            mysql.connection.commit()  # commit the transaction

            query2 = "SELECT * FROM Products WHERE productID = %s;"
            cursor.execute(query2, (productID,))
            rows = cursor.fetchone()  # Fetch name info on updated person

            print(f"UPDATE Products. ID: {productID} Name: {rows['productName']}")

            # Redirect the user to the updated webpage
            return redirect("/products")

        # Fetch all products and selected product
        cursor.execute("SELECT * FROM Products;")
        product = cursor.fetchall()
        cursor.execute("SELECT * FROM Products WHERE productID = %s;", (productID,))
        selected_product = cursor.fetchone()

        # Fetch categories list for the dropdown
        query_categories = "SELECT categoryID, categoryName FROM Categories;"
        cursor.execute(query_categories)
        category = cursor.fetchall()

        return render_template("update_product.j2", product=product, selected_product=selected_product, category=category)

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()


@app.route("/delete_product/<int:productID>")
def delete_product(productID):
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Fetch the product name for logging
        cursor.execute("SELECT productName FROM Products WHERE productID = %s;", (productID,))
        row = cursor.fetchone()
        product_name = row['productName']
        
        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteProduct(%s);"
        cursor.execute(query1, (productID,))

        mysql.connection.commit()  # commit the transaction

        print(f"DELETE Products. ID: {productID} Name: {product_name}")

        # Redirect to the categories page
        return redirect("/products")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()


################################ Sales_Products CRUD Routes
@app.route("/sales_products", methods=["GET", "POST"])
def show_sales_products():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Handle new sale_product creation
        if request.method == "POST":
            sale_id = request.form['sale_id']
            product_id = request.form['product_id']
            quantity = request.form['quantity']
            unit_price_at_sale = request.form['unit_price_at_sale']
            
            query1 = "CALL sp_CreateSaleProduct(%s, %s, %s, %s, @new_id);"
            cursor.execute(query1, (sale_id, product_id, quantity, unit_price_at_sale))
            new_id_row = cursor.fetchone()
            new_id = new_id_row['new_id'] 
            cursor.nextset() 
            mysql.connection.commit()

            query2 = """
            SELECT SalesProducts.productID, Products.productName 
            FROM SalesProducts
            JOIN Products ON SalesProducts.productID = Products.productID
            WHERE saleProductID = %s;
            """
            cursor.execute(query2, (new_id,))
            rows = cursor.fetchone()
            product_name = rows['productName']

            print(f"CREATE SalesProducts. ID: {new_id} Name: {product_name}")

        # Fetch sales_products list
        query_fetch = """
        SELECT SalesProducts.saleProductID, SalesProducts.saleID, Products.productName, SalesProducts.quantity, SalesProducts.unitPriceAtSale 
        FROM SalesProducts
        JOIN Products ON SalesProducts.productID = Products.productID
        ORDER BY SalesProducts.saleProductID ASC;
        """

        cursor.execute(query_fetch)
        sale_product = cursor.fetchall()

        # Fetch all sales for dropdown
        cursor.execute("""
        SELECT saleID FROM Sales
        ORDER BY saleID ASC;
        """)
        sales = cursor.fetchall()

        # Fetch all products for dropdown
        cursor.execute("SELECT productID, productName FROM Products;")
        products = cursor.fetchall()

        cursor.close()

        # Render file, and also send the renderer a couple objects that contains category information
        return render_template(
            "sales_products.j2", sale_product=sale_product, sales=sales, products=products)

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()


@app.route("/update_sale_product/<int:saleProductID>", methods=["GET", "POST"])
def update_sale_product(saleProductID):
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Update sale_product list
        if request.method == "POST":
            sale_id = request.form['sale_id']
            product_id = request.form['product_id']
            quantity = request.form['quantity']
            unit_price_at_sale = request.form['unit_price_at_sale']

            # Create and execute our queries
            # Using parameterized queries (Prevents SQL injection attacks)
            query1 = "CALL sp_UpdateSaleProduct(%s, %s, %s, %s, %s);"
            cursor.execute(query1, (saleProductID, sale_id, product_id, quantity, unit_price_at_sale,))

            # Consume the result set (if any) before running the next query
            cursor.nextset()  # Move to the next result set (for CALL statements)

            mysql.connection.commit()  # commit the transaction

            query2 = """
            SELECT SalesProducts.*, Products.productName 
            FROM SalesProducts
            JOIN Products ON SalesProducts.productID = Products.productID
            WHERE saleProductID = %s;
            """
            cursor.execute(query2, (saleProductID,))
            rows = cursor.fetchone()  # Fetch name info on updated person

            print(f"UPDATE SalesProducts. ID: {saleProductID} SalesID: {rows['saleID']} ProductName: {rows['productName']}")

            # Redirect the user to the updated webpage
            return redirect("/sales_products")

        # Fetch all sales_products and selected sale_product
        query_all = """
        SELECT SalesProducts.*, Products.productName 
        FROM SalesProducts
        JOIN Products ON SalesProducts.productID = Products.productID
        ORDER BY SalesProducts.saleProductID ASC;
        """
        cursor.execute(query_all)
        sale_product = cursor.fetchall()
        
        query_selected = """
        SELECT SalesProducts.*, Products.productName 
        FROM SalesProducts
        JOIN Products ON SalesProducts.productID = Products.productID
        WHERE saleProductID = %s;
        """
        cursor.execute(query_selected, (saleProductID,))
        selected_sale_product = cursor.fetchone()

        # Fetch sales and products for dropdowns
        cursor.execute("SELECT saleID FROM Sales;")
        sales = cursor.fetchall()
        cursor.execute("SELECT productID, productName FROM Products;")
        products = cursor.fetchall()

        return render_template("update_sale_product.j2", sale_product=sale_product, selected_sale_product=selected_sale_product, sales=sales, products=products)


    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()


@app.route("/add_sale_product", methods=["POST"])
def add_sale_product():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        sale_id = request.form['sale_id']
        product_id = request.form['product_id']
        quantity = request.form['quantity']
        unit_price_at_sale = request.form['unit_price_at_sale']
        
        query1 = "CALL sp_CreateSaleProduct(%s, %s, %s, %s, @new_id);"
        cursor.execute(query1, (sale_id, product_id, quantity, unit_price_at_sale))
        new_id_row = cursor.fetchone()
        new_id = new_id_row['new_id'] 
        cursor.nextset() 
        mysql.connection.commit()

        query2 = """
        SELECT SalesProducts.productID, Products.productName 
        FROM SalesProducts
        JOIN Products ON SalesProducts.productID = Products.productID
        WHERE saleProductID = %s;
        """
        cursor.execute(query2, (new_id,))
        rows = cursor.fetchone()
        product_name = rows['productName']

        print(f"CREATE SalesProducts. ID: {new_id} Name: {product_name}")

        # Redirect to the products page
        return redirect("/sales_products")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()


@app.route("/delete_sale_product/<int:saleProductID>")
def delete_sale_product(saleProductID):
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        # Fetch the product name for logging
        cursor.execute("""
        SELECT Products.productName 
        FROM SalesProducts
        JOIN Products ON SalesProducts.productID = Products.productID 
        WHERE SalesProducts.saleProductID = %s;
        """, (saleProductID,))
        row = cursor.fetchone()
        product_name = row['productName']
        
        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteSaleProduct(%s);"
        cursor.execute(query1, (saleProductID,))

        mysql.connection.commit()  # commit the transaction

        print(f"DELETE SalesProducts. ID: {saleProductID} Name: {product_name}")

        # Redirect to the categories page
        return redirect("/sales_products")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()

################################# RESET DATABASE
@app.route("/reset")
def reset():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("CALL sp_Reset()")
        mysql.connection.commit()  # commit the transaction

        # Redirect to the home page
        return redirect("/")


    except Exception as e:
        print(f"Error executing reset: {e}")
        return "An error occurred while executing the reset query.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and cursor:
            cursor.close()


################################ LISTENER

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=20669, debug=True)