-- Data Manipulation Queries for Señora Salsa 
-- Eric Azevedo & Jesus Garcia
-- GROUP 73

-- Variable declarations will use the @ symbol

-------------------------------------------------------
-- SELECT QUERIES
-------------------------------------------------------

-- Query to view Categories table
SELECT categoryName, description, 
CASE WHEN isActive = 1 THEN 'Yes' ELSE 'No' END AS isActive 
FROM Categories;

-- Query to view Products table
SELECT Products.productName, Products.description, Products.price, Products.stockQuantity, 
CASE WHEN Products.isActive = 1 THEN 'Yes' ELSE 'No' END AS isActive, 
Categories.categoryName 
FROM Products
JOIN Categories ON Products.categoryID = Categories.categoryID;

-- Query to view SalesProducts table
SELECT SalesProducts.saleProductID, SalesProducts.saleID, Products.productName, SalesProducts.quantity, SalesProducts.unitPriceAtSale 
FROM SalesProducts
JOIN Products ON SalesProducts.productID = Products.productID
ORDER BY SalesProducts.saleProductID ASC;

-- Query to view product name instead of productID in SalesProducts
SELECT Products.productName 
FROM SalesProducts
JOIN Products ON SalesProducts.productID = Products.productID 
WHERE SalesProducts.saleProductID = @saleProductID;

-- Query to view category in Categories
SELECT * FROM Categories WHERE categoryID = @categoryID;

-- Query to view product in Products
SELECT * FROM Products WHERE productID = @productID;

-- Query to view sale_product in SalesProducts
SELECT * FROM SalesProducts WHERE saleProductID = @saleProductID;

-- Query to view Customers
SELECT * FROM Customers;

-- Query to view Customers with specific customerID
SELECT * FROM Customers WHERE customerID = @customerID;

-- Query to view Sales
SELECT * FROM Sales;

-- Query to view Sales with specific saleID
SELECT * FROM Sales WHERE saleID = @saleID;

-- Query to view Employees
SELECT * FROM Employees;

-- Query to view Employees with specific employeeID
SELECT * FROM Employees WHERE employeeID = @employeeID;

-- Query to view sale id in Sales
SELECT saleID FROM Sales;

-- Query to view sale id in Sales in ascending order
SELECT saleID FROM Sales
ORDER BY saleID ASC;

-- Query to view product id and name in Products
SELECT productID, productName FROM Products;

-- Query to view Sales with customer and employee names
SELECT 
    Sales.saleID,
    CONCAT(Customers.firstName, ' ', Customers.lastName) AS customerName,
    CONCAT(Employees.firstName, ' ', Employees.lastName) AS employeeName,
    Sales.saleDate, Sales.subtotal, Sales.discount, Sales.tax, Sales.totalAmount, Sales.paymentMethod
FROM Sales
JOIN Customers ON Sales.customerID = Customers.customerID
JOIN Employees ON Sales.employeeID = Employees.employeeID;

-- Query to view customerID, firstName, lastName in Customers
SELECT customerID, firstName, lastName FROM Customers;

-- Query to view employeeID, firstName, lastName in Employees
SELECT employeeID, firstName, lastName FROM Employees;



-------------------------------------------------------
-- INSERT QUERIES
-------------------------------------------------------

-- Query to add a new category
INSERT INTO Categories (categoryName, description, isActive)
VALUES (@categoryName, @description, @isActive);

-- Query to handle new product creations
INSERT INTO Products (productName, description, price, stockQuantity, isActive, categoryID)
VALUES (@productName, @description, @price, @stockQuantity, @isActive, @categoryID);

-- Query to handle new saleproduct creations
INSERT INTO SalesProducts (saleID, productID, quantity, unitPriceAtSale)
VALUES (@saleID, @productID, @quantity, @unitPriceAtSale);

-- Query to handle new customer creations
INSERT INTO Customers (firstName, lastName, email, phoneNumber)
VALUES (@firstName, @lastName, @email, @phoneNumber);

-- Query to handle new customer creations
INSERT INTO Customers (first_name, last_name) 
VALUES (@first_name, @last_name);

-- Query to handle new sale creations
INSERT INTO Sales (customerID, employeeID, saleDate, subtotal, discount, tax, totalAmount, paymentMethod)
VALUES (@customerID, @employeeID, @saleDate, @subtotal, @discount, @tax, @totalAmount, @paymentMethod);

-- Query to handle new employee creations
INSERT INTO Employees (firstName, lastName, email, role, hireDate, isActive)
VALUES (@firstName, @lastName, @email, @role, @hireDate, @isActive);

-------------------------------------------------------
-- UPDATE QUERIES


-- Query to update a category
UPDATE Categories 
SET categoryName= @categoryName, description= @description, isActive= @isActive
WHERE categoryID = @categoryID;

-- Query to update a product
UPDATE Products
SET productName= @productName, description= @description, price= @price , stockQuantity= @stockQuantity, isActive= @isActive, categoryID= @categoryID
WHERE productID = @productID;

-- Query to update a SalesProducts
UPDATE SalesProducts
SET saleID= @saleID, productID= @productID, quantity= @quantity, unitPriceAtSale= @unitPriceAtSale
WHERE saleProductID = @saleProductID;

-- Query to update a customer
UPDATE Customers 
SET firstName= @firstName, lastName= @lastName, email= @email, phoneNumber= @phoneNumber
WHERE customerID = @customerID;

-- Query to update a sale
UPDATE Sales SET customerID= @customerID, employeeID= @employeeID, saleDate= @saleDate, subtotal= @subtotal, discount= @discount, tax= @tax, totalAmount= @totalAmount, paymentMethod= @paymentMethod
WHERE saleID = @saleID;

-- Query to update an employee
UPDATE Employees
SET firstName= @firstName, lastName= @lastName, email= @email, role= @role, hireDate= @hireDate, isActive= @isActive
WHERE employeeID= @employeeID;

-------------------------------------------------------
-- DELETE QUERIES
-------------------------------------------------------

-- Query to delete a category
DELETE FROM Categories WHERE categoryID = @categoryID;

-- Query to delete a product
DELETE FROM Products WHERE productID = @productID;

-- Query to delete a customer
DELETE FROM Customers WHERE customerID = @customerID;

-- Query to delete a sale
DELETE FROM Sales WHERE saleID = @saleID;

-- Query to delete an employee
DELETE FROM Employees WHERE employeeID = @employeeID;
