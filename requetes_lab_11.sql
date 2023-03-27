--Révoquer tous les droits de l'utilisateur et supprimer tous les objets qui lui sont associés.
USE lab11;
GO
REVOKE INSERT FROM [user_nom]
GO
REVOKE SELECT FROM [user_nom]
GO
DROP USER [user_nom]
GO

-- Supprimer la connexion (login) :
USE [master]
GO
DROP LOGIN [login_nom]
GO


-- 1.	Créer un login et l’associer à un utilisateur créé
USE [master]
GO
CREATE LOGIN [login_nom] WITH PASSWORD=N'password'
GO

USE lab11;
GO
CREATE USER [user_nom] FOR LOGIN [login_nom]
GO


-- a.	Donner le droit d’insertion à l’utilisateur
USE lab11;
GO
GRANT INSERT TO [user_nom]
GO
-- b.	Donner le droit de sélection à l’utilisateur
USE lab11;
GO
GRANT SELECT TO [user_nom]
GO

-- c.	Enlever le droit d’insertion à l’utilisateur
USE lab11;
GO
REVOKE INSERT FROM [user_nom]
GO

-- 2.	Créer une transaction permettant de supprimer les produits qui n’ont jamais été commandés
BEGIN TRANSACTION
DELETE FROM ProductTable WHERE ProductID NOT IN (SELECT ProductID FROM OrderTable)
COMMIT TRANSACTION

-- 3.	Créer une procédure stockée affichant le montant des commandes comprise entre 50 et 300. 
-- Le préfixe "usp" signifie "User Stored Procedure"
CREATE PROCEDURE [usp_GetOrderTotal]
    /* Description: Retrieves the total amount of orders between 50 and 300. */
AS
BEGIN

--  SET NOCOUNT ON : Cela empêchera SQL Server de renvoyer le nombre de lignes affectées après chaque instruction, ce qui peut améliorer les performances.
    SET NOCOUNT ON;

    SELECT SUM(TotalAmount) AS OrderTotal
    FROM [OrderTable]
    WHERE TotalAmount BETWEEN 50 AND 300;

    /* Returns: OrderTotal */
    RETURN;
END

-- 4.	Créer une procédure stockée avec un paramètre de sortie qui calcule et retourne le chiffre d'affaires.
CREATE PROCEDURE [usp_GetRevenue]
    @Revenue DECIMAL(18,2) OUTPUT
AS
BEGIN
    SELECT @Revenue = SUM(OrderTotal)
    FROM (
        SELECT SUM(TotalAmount) AS OrderTotal
        FROM OrderTable
        GROUP BY OrderDate
    ) AS Orders
END
