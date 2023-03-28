--R�voquer tous les droits de l'utilisateur et supprimer tous les objets qui lui sont associ�s.
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


-- 1.	Cr�er un login et l�associer � un utilisateur cr��
USE [master]
GO
CREATE LOGIN login_nom_test WITH PASSWORD=N'password'
GO

USE BD_Sales;
GO
CREATE USER user_nom_test FOR LOGIN login_nom_test
GO


-- a.	Donner le droit d�insertion � l�utilisateur
USE BD_Sales;
GO
GRANT INSERT TO user_nom_test
GO
-- b.	Donner le droit de s�lection � l�utilisateur
USE BD_Sales;
GO
GRANT SELECT TO user_nom_test
GO

-- c.	Enlever le droit d�insertion � l�utilisateur
USE BD_Sales;
GO
REVOKE INSERT FROM user_nom_test
GO

-- 2.	Cr�er une transaction permettant de supprimer les produits qui n�ont jamais �t� command�s
BEGIN TRANSACTION
DELETE FROM [ProductTable] WHERE ProductID NOT IN (SELECT ProductID FROM [OrderTable])
COMMIT TRANSACTION

-- 3.	Cr�er une proc�dure stock�e affichant le montant des commandes comprise entre 50 et 300. 
CREATE PROCEDURE [usp_GetOrderTotal]
AS
BEGIN
    SELECT SUM(TotalAmount) AS OrderTotal
    FROM [OrderTable]
    WHERE TotalAmount BETWEEN 50 AND 300
END

-- 4.	Cr�er une proc�dure stock�e avec un param�tre de sortie qui calcule et retourne le chiffre d'affaires.
CREATE PROCEDURE [usp_GetRevenue]
    @Revenue DECIMAL(18,2) OUTPUT
AS
BEGIN
    SELECT @Revenue = SUM(OrderTotal)
    FROM (
        SELECT SUM(TotalAmount) AS OrderTotal
        FROM [OrderTable]
        GROUP BY OrderDate
    ) AS Orders
END
