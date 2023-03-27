--- Creer la base donnee 
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'lab11') 
BEGIN
    CREATE DATABASE lab11;
END

USE lab11;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductTable' AND type = 'U')
BEGIN
	CREATE TABLE ProductTable
	(
		ProductID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
		ProductName VARCHAR(50),
		Price DECIMAL(18,2),
		CONSTRAINT UC_ProductTable UNIQUE (ProductID)
	)
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderTable' AND type = 'U')
BEGIN
	CREATE TABLE OrderTable
	(
		OrderID INT PRIMARY KEY,
		OrderDate DATETIME,
		TotalAmount DECIMAL(18,2),
		CONSTRAINT UC_OrderTable UNIQUE (OrderID)
	)
END