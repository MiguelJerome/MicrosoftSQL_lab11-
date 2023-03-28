USE BD_Sales;

-- Insertion de 10 enregistrements dans la table ProductTable
INSERT INTO ProductTable (ProductName, Price)
VALUES ('Produit 1', 10.99),
       ('Produit 2', 24.99),
       ('Produit 3', 12.50),
       ('Produit 4', 9.99),
       ('Produit 5', 19.99),
       ('Produit 6', 8.75),
       ('Produit 7', 14.99),
       ('Produit 8', 22.50),
       ('Produit 9', 7.99),
       ('Produit 10', 18.50);

-- Insertion de 10 enregistrements dans la table OrderTable
INSERT INTO OrderTable (OrderID, OrderDate, TotalAmount)
VALUES (1, '2023-03-01', 80.00),
       (2, '2023-03-02', 120.00),
       (3, '2023-03-03', 65.00),
       (4, '2023-03-04', 25.00),
       (5, '2023-03-05', 95.00),
       (6, '2023-03-06', 50.00),
       (7, '2023-03-07', 150.00),
       (8, '2023-03-08', 80.00),
       (9, '2023-03-09', 110.00),
       (10, '2023-03-10', 200.00);