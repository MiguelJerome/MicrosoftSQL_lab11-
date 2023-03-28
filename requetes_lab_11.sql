-- Revoquer tous les droits de l'utilisateur et supprimer tous les objets qui lui sont associes.
USE BD_Sales;
GO
REVOKE INSERT FROM user_nom_test
GO
REVOKE SELECT FROM user_nom_test
GO
DROP USER user_nom_test
GO

-- Supprimer la connexion (login) :
USE [master]
GO
DROP LOGIN login_nom_test
GO


-- 1.	Creer un login et l'associer a un utilisateur cree
USE [master]
GO
CREATE LOGIN login_nom_test WITH PASSWORD=N'passwordTest123'
GO

USE BD_Sales;
GO
CREATE USER user_nom_test FOR LOGIN login_nom_test
GO


-- a.	Donner le droit d'insertion a l'utilisateur
USE BD_Sales;
GO
GRANT INSERT TO user_nom_test
GO
-- b.	Donner le droit de selection a l'utilisateur
USE BD_Sales;
GO
GRANT SELECT TO user_nom_test
GO

-- c.	Enlever le droit d'insertion a l'utilisateur
USE BD_Sales;
GO
REVOKE INSERT FROM user_nom_test
GO

-- 2.	Creer une transaction permettant de supprimer les produits qui n'ont jamais ete commandes
USE BD_Sales;
PRINT @@TRANCOUNT;
BEGIN TRAN;
PRINT @@TRANCOUNT;

-- Supprimer la table temporaire si elle existe deja
IF OBJECT_ID('tempdb..#products_to_delete') IS NOT NULL
  DROP TABLE #products_to_delete;
-- Trouver les produits qui n'ont jamais été commandés
SELECT p.product_id, p.product_name
-- Cette transaction cree une table temporaire #products_to_delete pour stocker les identifiants des produits qui n ont jamais ete commandes
INTO #products_to_delete
FROM production.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id; 

-- vérifier que la table a bien été remplie avec les identifiants de produits qui n'ont jamais été commandés
SELECT * FROM #products_to_delete
ORDER BY product_id ASC;

-- Supprimer les stocks correspondants
DELETE FROM production.stocks
WHERE product_id IN (SELECT product_id FROM #products_to_delete);

-- Supprimer les produits correspondants
DELETE FROM production.products
WHERE product_id IN (SELECT product_id FROM #products_to_delete);

-- Vérifier que les produits ont bien été supprimés
SELECT * FROM production.products;
GO
SELECT * FROM production.stocks;

-- Valider la transaction
COMMIT;
PRINT @@TRANCOUNT;

-- Annuler toutes les modifications apportées à la base de données depuis le début de la transaction en cours.
ROLLBACK;
PRINT @@TRANCOUNT;

-- Vérifier que les produits ont bien été, annuler pour toutes les modifications apportées
SELECT * FROM production.products;
GO
SELECT * FROM production.stocks;

PRINT @@TRANCOUNT;


-- 3.	Creer une procedure stockee affichant le montant des commandes comprise entre 50 et 300. 
USE BD_Sales
GO

CREATE PROCEDURE sp_GetOrdersBetween50And300
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SUM(list_price * quantity) AS TotalAmount
    FROM sales.order_items
    WHERE list_price BETWEEN 50 AND 300;
END
GO

EXEC sp_GetOrdersBetween50And300

-- Supprimer la procédure stockée sp_GetOrdersBetween50And300de la base de données.
USE BD_Sales
GO

DROP PROCEDURE sp_GetOrdersBetween50And300
GO

-- 4.	Créer une procédure stockée avec un paramètre de sortie qui calcule et retourne le chiffre d'affaires.
USE BD_Sales;
GO

-- La procédure stockée prend deux dates en entrée
-- et calcule le chiffre d'affaires entre ces deux dates en interrogeant les tables des commandes et des articles.
-- La valeur calculée est stockée dans une variable de sortie @revenue de type DECIMAL(10, 2).
CREATE PROCEDURE CalculateSalesRevenue
@startDate DATE,
@endDate DATE,
@revenue DECIMAL(10, 2) OUTPUT
AS
BEGIN
SET NOCOUNT ON;
SELECT oi.order_id, oi.product_id, oi.list_price, oi.quantity, (oi.list_price * oi.quantity) AS line_total, o.order_date
FROM sales.order_items oi
JOIN sales.orders o ON oi.order_id = o.order_id
WHERE o.order_date >= @startDate AND o.order_date <= @endDate;

SELECT @revenue = SUM(oi.list_price * oi.quantity)
FROM sales.order_items oi
JOIN sales.orders o ON oi.order_id = o.order_id
WHERE o.order_date >= @startDate AND o.order_date <= @endDate;
END;
GO

-- DECLARE @revenue DECIMAL(10, 2)
-- exécute la procédure stockée CalculateSalesRevenue en utilisant deux dates comme paramètres d'entrée 
-- et stocke le chiffre d'affaires calculé dans la variable @revenue,
-- puis affiche la valeur stockée dans la variable @revenue
DECLARE @revenue DECIMAL(10, 2);
EXEC CalculateSalesRevenue '2016-01-01', '2016-01-31', @revenue OUTPUT;
SELECT @revenue;

-- Supprimer la procédure stockée CalculateSalesRevenue de la base de données.
DROP PROCEDURE CalculateSalesRevenue;
