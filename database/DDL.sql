-- Data Definition Queries for Señora Salsa
-- Eric Azevedo & Jesus Gracia
-- GROUP 73

DROP PROCEDURE IF EXISTS `sp_load_senorasalsaDB`;
DELIMITER //

CREATE PROCEDURE `sp_load_senorasalsaDB`()
BEGIN

    -- Disable commits & foreign key checks
    SET FOREIGN_KEY_CHECKS=0;
    SET AUTOCOMMIT = 0;

    -- -----------------------------------------------------
    -- CREATE TABLES
    -- -----------------------------------------------------

    -- Customers table
    -- This table stores customer information
    CREATE OR REPLACE TABLE Customers (
        customerID INT NOT NULL AUTO_INCREMENT,
        firstName VARCHAR(50) NOT NULL,
        lastName VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        phoneNumber VARCHAR(20),
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        isActive TINYINT(1) DEFAULT 1,
        PRIMARY KEY (customerID)
    );

    -- Employees table
    -- This table stores employee information
    CREATE OR REPLACE TABLE Employees (
        employeeID INT NOT NULL AUTO_INCREMENT,
        firstName VARCHAR(50) NOT NULL,
        lastName VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL,
        role ENUM('Sales', 'Manager', 'Support') NOT NULL,
        hireDate DATE NOT NULL,
        isActive TINYINT(1),    -- 1 for active, 0 for inactive
        PRIMARY KEY (employeeID)
    );

    -- Sales table
    -- This table stores sales information
    CREATE OR REPLACE TABLE Sales (
        saleID INT NOT NULL AUTO_INCREMENT,
        customerID INT NOT NULL,
        employeeID INT NOT NULL,
        saleDate DATE NOT NULL,
        subtotal DECIMAL(10, 2) NOT NULL,
        discount DECIMAL(10, 2) DEFAULT 0.00 NOT NULL,
        tax DECIMAL(10, 2) DEFAULT 0.00 NOT NULL,
        totalAmount DECIMAL(10, 2) NOT NULL,
        paymentMethod ENUM('Cash', 'Yappy', 'Credit Card', 'Debit Card') NOT NULL,
        PRIMARY KEY (saleID),
        FOREIGN KEY (customerID) REFERENCES Customers(customerID) ON DELETE CASCADE,
        FOREIGN KEY (employeeID) REFERENCES Employees(employeeID) ON DELETE CASCADE
    );

    -- Categories table
    -- This table stores product categories
    CREATE OR REPLACE TABLE Categories (
        categoryID INT NOT NULL AUTO_INCREMENT,
        categoryName VARCHAR(50) UNIQUE NOT NULL,
        description TEXT NULL,
        isActive TINYINT(1) DEFAULT 1 NOT NULL, -- 1 for active, 0 for inactive
        PRIMARY KEY (categoryID)
    );

    -- Products table
    -- This table stores product information
    CREATE OR REPLACE TABLE Products (
        productID INT NOT NULL AUTO_INCREMENT,
        productName VARCHAR(100) NOT NULL,
        description TEXT,
        price DECIMAL(10, 2) NOT NULL,
        stockQuantity INT NOT NULL,
        isActive TINYINT(1),    -- 1 for active, 0 for inactive
        categoryID INT NULL,    
        PRIMARY KEY (productID),
        FOREIGN KEY (categoryID) REFERENCES Categories(categoryID) ON DELETE SET NULL
    );

    -- SalesProducts intersection table
    -- This table stores the relationship between sales and products
    CREATE OR REPLACE TABLE SalesProducts (
        saleProductID INT AUTO_INCREMENT,
        saleID INT NOT NULL,
        productID INT NOT NULL,
        quantity INT NOT NULL,
        unitPriceAtSale DECIMAL(10, 2) NOT NULL COMMENT 'Price of the product at the time of sale',
        PRIMARY KEY (saleProductID),
        FOREIGN KEY (saleID) REFERENCES Sales(saleID) ON DELETE RESTRICT,
        FOREIGN KEY (productID) REFERENCES Products(productID) ON DELETE RESTRICT
    );


    -- -----------------------------------------------------
    -- INSERT DATA
    -- -----------------------------------------------------

    -- Customers
    INSERT INTO Customers (firstName, lastName, email, phoneNumber) VALUES
    ('Carlos', 'Ramirez', 'carlos.ramirez@example.com', '50761234567'),
    ('Maria', 'Lopez', 'maria.lopez@example.com', '50769876543'),
    ('Ernesto', 'Diaz', 'ernesto.diaz@example.com', '50763457890'),
    ('Lucia', 'Fernandez', 'lucia.fernandez@example.com', '50762345678'),
    ('Jorge', 'Mendoza', 'jorge.mendoza@example.com', '50764567890');

    -- Employees
    INSERT INTO Employees (firstName, lastName, email, role, hireDate, isActive) VALUES
    ('Ana', 'Torres', 'ana.torres@salsa.com', 'Sales', '2025-01-10', 1),
    ('Luis', 'Gomez', 'luis.gomez@salsa.com', 'Manager', '2025-01-15', 1),
    ('Camila', 'Vega', 'camila.vega@salsa.com', 'Sales', '2025-02-01', 1),
    ('Rafael', 'Castillo', 'rafael.castillo@salsa.com', 'Support', '2025-02-10', 1),
    ('Valeria', 'Morales', 'valeria.morales@salsa.com', 'Sales', '2025-03-01', 1);

    -- Sales
    INSERT INTO Sales (customerID, employeeID, saleDate, subtotal, discount, tax, totalAmount, paymentMethod) VALUES
    (1,1,'2025-01-10',13,0,0.91,13.91,'Credit Card'),
    (2,2,'2025-01-20',10,1,0.63,9.63,'Yappy'),
    (3,3,'2025-02-05',10.5,0,0.74,11.24,'Cash'),
    (4,1,'2025-02-25',9.5,0,0.66,10.16,'Debit Card'),
    (5,4,'2025-03-01',13,0,0.91,13.91,'Credit Card'),
    (1,2,'2025-03-15',14.5,1,0.94,14.44,'Cash'),
    (2,5,'2025-03-25',10.25,0,0.72,10.97,'Yappy'),
    (3,1,'2025-04-02',15,2,0.91,13.91,'Credit Card'),
    (4,2,'2025-04-10',5,0,0.35,5.35,'Debit Card'),
    (5,3,'2025-04-22',8.5,0,0.6,9.1,'Cash');

    -- Categories
    INSERT INTO Categories (categoryName, description, isActive) VALUES
    ('Salsa', 'Traditional chili oil and tomato-based sauces.', 1),
    ('Pickled products', 'Vegetables preserved in vinegar or brine.', 1),
    ('Hummus', 'Chickpea-based spreads with spices and olive oil.', 1);

    -- Products
    INSERT INTO Products (productName, description, price, stockQuantity, isActive, categoryID) VALUES
    ('La Pili (Hot)', 'Original hot chili oil salsa.', 6.5, 100, 1, 1),
    ('La Pili (Mild)', 'Mild version of La Pili.', 6, 100, 1, 1),
    ('La PanaMex (Hot)', 'Hot salsa blending Panamanian and Mexican flavors.', 5.5, 100, 1, 1),
    ('La PanaMex (Mild)', 'Mild salsa blending Panamanian and Mexican flavors.', 5, 100, 1, 1),
    ('El Chombi (Hot)', 'Fiery salsa with bold spices.', 5.5, 100, 1, 1),
    ('El Chombi (Mild)', 'Smooth and mild variation of El Chombi.', 5, 100, 1, 1),
    ('Pickled Jalapeños and Veggies', 'Crunchy mix of jalapeños and seasonal vegetables.', 4.75, 80, 1, 2), 
    ('Hummus', 'Smooth chickpea-based spread with olive oil.', 4.25, 60, 1, 3);

    -- SalesProducts
    INSERT INTO SalesProducts (saleID, productID, quantity, unitPriceAtSale) VALUES
    (1,1,2,6.5),
    (2,4,2,5),
    (3,5,2,5.5),
    (4,2,1,6),
    (4,3,1,5.5),
    (5,1,2,6.5),
    (6,2,1,6),
    (6,6,1,5),
    (6,8,1,4.25),
    (7,2,1,6),
    (7,7,1,4.75),
    (7,8,1,4.25),
    (8,1,1,6.5),
    (8,3,1,5.5),
    (9,6,1,5),
    (10,3,1,5.5),
    (10,2,1,6);

    -- -----------------------------------------------------
    --  INSERT STATEMENTS
    -- -----------------------------------------------------

    -- Query to add a new category
    INSERT INTO Categories (categoryName, description, isActive)
    VALUES ('Hot Sauces', 'A variety of spicy sauces.', 1);

    -- Query to add a new product
    INSERT INTO Products (productName, description, price, stockQuantity, isActive, categoryID)
    VALUES ('Spicy Mango Salsa', 'A sweet and spicy mango-based salsa.', 7.5, 50, 1, 1);

    -- Query to handle new saleproduct creations
    INSERT INTO SalesProducts (saleID, productID, quantity, unitPriceAtSale)
    VALUES (1, 2, 3, 6.0);

    -- Query to handle new customer creations
    INSERT INTO Customers (firstName, lastName, email, phoneNumber)
    VALUES ('Sofia', 'Martinez', 'sofia.martinez@example.com', '50761234567');

    -- Query to handle new customer creations
    INSERT INTO Customers (firstName, lastName, email)
    VALUES ('Diego', 'Hernandez', 'diego.hernandez@example.com');

    -- Query to handle new sale creations
    INSERT INTO Sales (customerID, employeeID, saleDate, subtotal, discount, tax, totalAmount, paymentMethod)
    VALUES (2, 3, '2025-05-01', 20.0, 2.0, 1.4, 19.4, 'Cash');

    -- Query to handle new employee creations
    INSERT INTO Employees (firstName, lastName, email, role, hireDate, isActive)
    VALUES ('Isabel', 'Garcia', 'isabel.garcia@salsa.com', 'Support', '2025-04-15', 1);



    -- Enable commits & foreign key checks
    SET FOREIGN_KEY_CHECKS=1;
    COMMIT;

END //
DELIMITER ;
