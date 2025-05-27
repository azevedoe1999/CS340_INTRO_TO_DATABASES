-- PL/SQL for Señora Salsa 
-- Eric Azevedo & Jesus Garcia
-- GROUP 73

-- Citations:
-- Adapted from Canvas examples


-- #############################
-- CREATE Categories
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateCategory;

DELIMITER //
CREATE PROCEDURE sp_CreateCategory(
    IN p_categoryName VARCHAR(50), 
    IN p_description TEXT, 
    IN p_isActive TINYINT(1), 
    OUT p_categoryID INT
    )
BEGIN
    INSERT INTO Categories (categoryName, description, isActive) 
    VALUES (p_categoryName, p_description, p_isActive);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_categoryID;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;

-- #############################
-- CREATE Products
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateProduct;

DELIMITER //
CREATE PROCEDURE sp_CreateProduct(
    IN p_productName VARCHAR(100),
    IN p_description TEXT, 
    IN p_price DECIMAL(10, 2),
    IN p_stockQuantity INT,
    IN p_isActive TINYINT(1),
    IN p_categoryID INT,
    OUT p_productID INT
    )
BEGIN
    INSERT INTO Products (productName, description, price, stockQuantity, isActive, categoryID)
    VALUES (p_productName, p_description, p_price, p_stockQuantity, p_isActive, p_categoryID); 

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_productID;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;

-- #############################
-- CREATE SalesProducts
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateSaleProduct;

DELIMITER //
CREATE PROCEDURE sp_CreateSaleProduct(
    IN p_saleID INT,
    IN p_productID INT, 
    IN p_quantity INT,
    IN p_unitPriceAtSale DECIMAL(10, 2),
    OUT p_saleProductID INT
    )
BEGIN
    INSERT INTO SalesProducts (saleID, productID, quantity, unitPriceAtSale)
    VALUES (p_saleID, p_productID, p_quantity, p_unitPriceAtSale); 

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_saleProductID;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;

-- #############################
-- UPDATE Categories
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateCategory;

DELIMITER //
CREATE PROCEDURE sp_UpdateCategory(
    IN p_categoryid INT,
    IN p_categoryName VARCHAR(50), 
    IN p_description TEXT, 
    IN p_isActive TINYINT(1) 
    )

BEGIN
    UPDATE Categories 
    SET 
        categoryName = p_categoryName, 
        description = p_description, 
        isActive = p_isActive 
    WHERE categoryID = p_categoryid; 
END //
DELIMITER ;

-- #############################
-- UPDATE Products
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateProduct;

DELIMITER //
CREATE PROCEDURE sp_UpdateProduct(
    IN p_productID INT,
    IN p_productName VARCHAR(100), 
    IN p_description TEXT, 
    IN p_price DECIMAL(10, 2),
    IN p_stockQuantity INT,
    IN p_isActive TINYINT(1),
    IN p_categoryID INT
    )

BEGIN
    UPDATE Products 
    SET 
        productName = p_productName, 
        description = p_description, 
        price = p_price, 
        stockQuantity = p_stockQuantity, 
        isActive = p_isActive,
        categoryID = p_categoryID
    WHERE productID = p_productID; 
END //
DELIMITER ;

-- #############################
-- UPDATE SalesProducts
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateSaleProduct;

DELIMITER //
CREATE PROCEDURE sp_UpdateSaleProduct(
    IN p_saleProductID INT,
    IN p_saleID INT,
    IN p_productID INT,
    IN p_quantity INT,
    IN p_unitPriceAtSale DECIMAL(10, 2)
    )

BEGIN
    UPDATE SalesProducts 
    SET 
        saleID = p_saleID, 
        productID = p_productID, 
        quantity = p_quantity, 
        unitPriceAtSale = p_unitPriceAtSale
    WHERE saleProductID = p_saleProductID; 
END //
DELIMITER ;

-- #############################
-- DELETE Categories
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteCategory;

DELIMITER //
CREATE PROCEDURE sp_DeleteCategory(
    IN p_categoryID INT
    )
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM Categories WHERE categoryID = p_categoryID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Categories for id: ', p_categoryID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #############################
-- DELETE Products
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteProduct;

DELIMITER //
CREATE PROCEDURE sp_DeleteProduct(
    IN p_productID INT
    )
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM Products WHERE productID = p_productID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Products for id: ', p_productID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #############################
-- DELETE SalesProducts
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteSaleProduct;

DELIMITER //
CREATE PROCEDURE sp_DeleteSaleProduct(
    IN p_saleProductID INT
    )
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM SalesProducts WHERE saleProductID = p_saleProductID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in SalesProducts for id: ', p_saleProductID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 20, 2025

DROP PROCEDURE IF EXISTS sp_CreateCustomer;

DELIMITER //

CREATE PROCEDURE sp_CreateCustomer(
    IN p_firstName VARCHAR(50),
    IN p_lastName VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phoneNumber VARCHAR(20),
    OUT p_customerID INT
)
BEGIN
    INSERT INTO Customers (firstName, lastName, email, phoneNumber)
    VALUES (p_firstName, p_lastName, p_email, p_phoneNumber);

    SELECT LAST_INSERT_ID() INTO p_customerID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 20, 2025

DROP PROCEDURE IF EXISTS sp_CreateEmployee;

DELIMITER //

CREATE PROCEDURE sp_CreateEmployee(
    IN p_firstName VARCHAR(50),
    IN p_lastName VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_role ENUM('Sales', 'Manager', 'Support'),
    IN p_hireDate DATE,
    IN p_isActive TINYINT(1),
    OUT p_employeeID INT
)
BEGIN
    INSERT INTO Employees (firstName, lastName, email, role, hireDate, isActive)
    VALUES (p_firstName, p_lastName, p_email, p_role, p_hireDate, p_isActive);

    SELECT LAST_INSERT_ID() INTO p_employeeID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 20, 2025

DROP PROCEDURE IF EXISTS sp_CreateSale;

DELIMITER //

CREATE PROCEDURE sp_CreateSale(
    IN p_customerID INT,
    IN p_employeeID INT,
    IN p_saleDate DATE,
    IN p_subtotal DECIMAL(10,2),
    IN p_discount DECIMAL(10,2),
    IN p_tax DECIMAL(10,2),
    IN p_totalAmount DECIMAL(10,2),
    IN p_paymentMethod ENUM('Cash', 'Yappy', 'Credit Card', 'Debit Card'),
    OUT p_saleID INT
)
BEGIN
    INSERT INTO Sales (customerID, employeeID, saleDate, subtotal, discount, tax, totalAmount, paymentMethod)
    VALUES (p_customerID, p_employeeID, p_saleDate, p_subtotal, p_discount, p_tax, p_totalAmount, p_paymentMethod);

    SELECT LAST_INSERT_ID() INTO p_saleID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 21, 2025

-- sp_DeleteCustomer.sql
-- Soft delete instead of physical delete

DROP PROCEDURE IF EXISTS sp_DeleteCustomer;

DELIMITER //

CREATE PROCEDURE sp_DeleteCustomer(
    IN p_customerID INT
)
BEGIN
    UPDATE Customers
    SET isActive = 0
    WHERE customerID = p_customerID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 20, 2025

DROP PROCEDURE IF EXISTS sp_DeleteEmployee;

DELIMITER //

CREATE PROCEDURE sp_DeleteEmployee(
    IN p_employeeID INT
)
BEGIN
    UPDATE Employees
    SET isActive = 0
    WHERE employeeID = p_employeeID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 20, 2025

DROP PROCEDURE IF EXISTS sp_DeleteSale;

DELIMITER //

CREATE PROCEDURE sp_DeleteSale(
    IN p_saleID INT
)
BEGIN
    DELETE FROM Sales
    WHERE saleID = p_saleID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 21, 2025

DROP PROCEDURE IF EXISTS sp_UpdateCustomer;

DELIMITER //

CREATE PROCEDURE sp_UpdateCustomer(
    IN p_customerID INT,
    IN p_firstName VARCHAR(50),
    IN p_lastName VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phoneNumber VARCHAR(20)
)
BEGIN
    UPDATE Customers
    SET firstName = p_firstName,
        lastName = p_lastName,
        email = p_email,
        phoneNumber = p_phoneNumber
    WHERE customerID = p_customerID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 20, 2025

DROP PROCEDURE IF EXISTS sp_UpdateEmployee;

DELIMITER //

CREATE PROCEDURE sp_UpdateEmployee(
    IN p_employeeID INT,
    IN p_firstName VARCHAR(50),
    IN p_lastName VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_role ENUM('Sales', 'Manager', 'Support'),
    IN p_hireDate DATE,
    IN p_isActive TINYINT(1)
)
BEGIN
    UPDATE Employees
    SET firstName = p_firstName,
        lastName = p_lastName,
        email = p_email,
        role = p_role,
        hireDate = p_hireDate,
        isActive = p_isActive
    WHERE employeeID = p_employeeID;
END //

DELIMITER ;


-- Code source citation
-- Based on Module 8 Exploration - Implementing CUD operations in your app
-- Adapted for Señora Salsa Project by Jesús García, May 20, 2025

DROP PROCEDURE IF EXISTS sp_UpdateSale;

DELIMITER //

CREATE PROCEDURE sp_UpdateSale(
    IN p_saleID INT,
    IN p_customerID INT,
    IN p_employeeID INT,
    IN p_saleDate DATE,
    IN p_subtotal DECIMAL(10,2),
    IN p_discount DECIMAL(10,2),
    IN p_tax DECIMAL(10,2),
    IN p_totalAmount DECIMAL(10,2),
    IN p_paymentMethod ENUM('Cash', 'Yappy', 'Credit Card', 'Debit Card')
)
BEGIN
    UPDATE Sales
    SET customerID = p_customerID,
        employeeID = p_employeeID,
        saleDate = p_saleDate,
        subtotal = p_subtotal,
        discount = p_discount,
        tax = p_tax,
        totalAmount = p_totalAmount,
        paymentMethod = p_paymentMethod
    WHERE saleID = p_saleID;
END //

DELIMITER ;


-- Code source citation:
-- Adapted by Jesús García for Señora Salsa Project, Step 4 - May 2025

DROP PROCEDURE IF EXISTS sp_Reset;

DELIMITER //

CREATE PROCEDURE sp_Reset()
BEGIN
    -- Disable foreign key checks
    SET FOREIGN_KEY_CHECKS = 0;

    -- Clear dependent tables first
    DELETE FROM SalesProducts;
    DELETE FROM Sales;
    DELETE FROM Products;
    DELETE FROM Categories;
    DELETE FROM Employees;
    DELETE FROM Customers;

    -- Reset AUTO_INCREMENT counters
    ALTER TABLE Customers AUTO_INCREMENT = 1;
    ALTER TABLE Employees AUTO_INCREMENT = 1;
    ALTER TABLE Sales AUTO_INCREMENT = 1;
    ALTER TABLE Categories AUTO_INCREMENT = 1;
    ALTER TABLE Products AUTO_INCREMENT = 1;
    ALTER TABLE SalesProducts AUTO_INCREMENT = 1;

    -- Re-enable foreign key checks
    SET FOREIGN_KEY_CHECKS = 1;

    -- Reinsert sample data
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
END //

DELIMITER ;
