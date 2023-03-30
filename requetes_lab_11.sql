-- RÉINITIALISER TOUT UTILISATEUR ET CONNEXION
-- Revoquer tous les droits de l'utilisateur et supprimer tous les objets qui lui sont associes.
SETUSER
GO
USE BD_Sales;
GO
REVOKE INSERT FROM user_nom_test
GO
REVOKE SELECT FROM user_nom_test
GO
DROP USER user_nom_test
GO
-- Vérifiez si le produit existe avant de le supprimer
IF EXISTS (SELECT 1 FROM [production].[products] WHERE [product_id] = 400)
BEGIN
    DELETE FROM [production].[products] WHERE [product_id] = 400;
END
-- Supprimer la connexion (login) :
USE BD_Sales
GO
DROP LOGIN login_nom_test
GO
-- VÉRIFIEZ que la réinitialisation fonctionne, LA SORTIE APRÈS TOUT UTILISATEUR ET CONNEXION
SELECT name, sid, create_date, modify_date, default_database_name, is_disabled 
FROM sys.sql_logins 
ORDER BY name;

-- 1.	Creer un login et l'associer a un utilisateur cree
-- 1) Creer un login
USE BD_Sales
GO
CREATE LOGIN login_nom_test WITH PASSWORD=N'passwordTest123'
GO
-- Afficher output
-- vous donner une liste de tous les logins SQL sur votre instance SQL Server, triés par nom de login.
SELECT name, sid, create_date, modify_date, default_database_name, is_disabled 
FROM sys.sql_logins 
ORDER BY name;

-- 1) Creer l'associer a un utilisateur cree
USE BD_Sales;
GO
CREATE USER user_nom_test FOR LOGIN login_nom_test
GO
-- Afficher output
-- Cela affichera une liste de tous les utilisateurs, ainsi que leur type
-- (soit une connexion Windows, soit une connexion SQL) et leur mode d'authentification
-- (soit une authentification Windows, soit une authentification SQL Server).
-- Pour voir les utilisateurs de la base de données, vous pouvez exécuter une requête similaire sur la base de données spécifique :
SELECT name, type_desc, authentication_type_desc FROM sys.database_principals WHERE type_desc IN ('WINDOWS_USER', 'SQL_USER');

-- a.	Donner le droit d'insertion a l'utilisateur
USE BD_Sales;
GO
GRANT INSERT ON DATABASE::BD_SALES TO user_nom_test;
GRANT INSERT ON [production].[brands] TO user_nom_test;
GRANT INSERT ON [production].[categories] TO user_nom_test;
GRANT INSERT ON [production].[products] TO user_nom_test;
GRANT INSERT ON [production].[stocks] TO user_nom_test;
GRANT INSERT ON [sales].[customers] TO user_nom_test;
GRANT INSERT ON [sales].[order_items] TO user_nom_test;
GRANT INSERT ON [sales].[orders] TO user_nom_test;
GRANT INSERT ON [sales].[staffs] TO user_nom_test;
GRANT INSERT ON [sales].[stores] TO user_nom_test;
GO

SET IDENTITY_INSERT [production].[products] ON;
GO
SETUSER 'user_nom_test'
GO
INSERT INTO [production].[products] ([product_id], [product_name], [brand_id], [category_id], [model_year], [list_price])
VALUES (400, 'Product 4', 2, 2, 2023, 40.00);
      

-- b.	Donner le droit de selection a l'utilisateur
SETUSER
USE BD_Sales;
GO
GRANT SELECT ON DATABASE::BD_SALES TO user_nom_test
GO
GRANT SELECT ON [production].[brands] TO user_nom_test;
GRANT SELECT ON [production].[categories] TO user_nom_test;
GRANT SELECT ON [production].[products] TO user_nom_test;
GRANT SELECT ON [production].[stocks] TO user_nom_test;
GRANT SELECT ON [sales].[customers] TO user_nom_test;
GRANT SELECT ON [sales].[order_items] TO user_nom_test;
GRANT SELECT ON [sales].[orders] TO user_nom_test;
GRANT SELECT ON [sales].[staffs] TO user_nom_test;
GRANT SELECT ON [sales].[stores] TO user_nom_test;
GO
SETUSER 'user_nom_test'
GO
SELECT * FROM [production].[products] WHERE [product_id] = 400;

-- c.	Enlever le droit d'insertion a l'utilisateur
SETUSER 
USE BD_Sales;
GO
REVOKE INSERT ON DATABASE::BD_SALES FROM user_nom_test;
GO
REVOKE INSERT ON [production].[brands] TO user_nom_test;
REVOKE INSERT ON [production].[categories] TO user_nom_test;
REVOKE INSERT ON [production].[products] TO user_nom_test;
REVOKE INSERT ON [production].[stocks] TO user_nom_test;
REVOKE INSERT ON [sales].[customers] TO user_nom_test;
REVOKE INSERT ON [sales].[order_items] TO user_nom_test;
REVOKE INSERT ON [sales].[orders] TO user_nom_test;
REVOKE INSERT ON [sales].[staffs] TO user_nom_test;
REVOKE INSERT ON [sales].[stores] TO user_nom_test;
GO
SET IDENTITY_INSERT [production].[products] ON;
GO
SETUSER 'user_nom_test'
GO
INSERT INTO [production].[products] ([product_id], [product_name], [brand_id], [category_id], [model_year], [list_price])
VALUES (410, 'Product 410', 2, 2, 2023, 410.00);


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
-- spGetEachOrdersBetween50And300
USE BD_Sales
GO

CREATE PROCEDURE spGetEachOrdersBetween50And300 AS
BEGIN
    SELECT orders.order_id, CAST(SUM(order_items.quantity * order_items.list_price * (1 - order_items.discount)) AS decimal(10, 2)) AS total_amount
	FROM sales.order_items
	JOIN sales.orders ON sales.order_items.order_id = sales.orders.order_id
	GROUP BY sales.orders.order_id
	HAVING SUM(order_items.quantity * order_items.list_price * (1 - order_items.discount)) BETWEEN 50 AND 300;
END

EXEC spGetEachOrdersBetween50And300;
GO
-- Supprimer la procédure stockée sp_GetEachOrdersBetween50And300 de la base de données.
USE BD_Sales
GO

DROP PROCEDURE IF EXISTS spGetEachOrdersBetween50And300
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
SELECT "Chiffre d'affaires entre '2016-01-01' et '2016-01-31'" = @revenue;

-- Supprimer la procédure stockée CalculateSalesRevenue de la base de données.
DROP PROCEDURE IF EXISTS CalculateSalesRevenue;
