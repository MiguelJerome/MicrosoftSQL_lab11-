--R�voquer tous les droits de l'utilisateur et supprimer tous les objets qui lui sont associ�s.
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


-- 1.	Cr�er un login et l�associer � un utilisateur cr��
USE [master]
GO
CREATE LOGIN [login_nom] WITH PASSWORD=N'password'
GO

USE lab11;
GO
CREATE USER [user_nom] FOR LOGIN [login_nom]
GO


-- a.	Donner le droit d�insertion � l�utilisateur
USE lab11;
GO
GRANT INSERT TO [user_nom]
GO
-- b.	Donner le droit de s�lection � l�utilisateur
USE lab11;
GO
GRANT SELECT TO [user_nom]
GO

-- c.	Enlever le droit d�insertion � l�utilisateur
USE lab11;
GO
REVOKE INSERT FROM [user_nom]
GO

-- 2.	Cr�er une transaction permettant de supprimer les produits qui n�ont jamais �t� command�s
BEGIN TRANSACTION
DELETE FROM ProductTable WHERE ProductID NOT IN (SELECT ProductID FROM OrderTable)
COMMIT TRANSACTION

-- 3.	Cr�er une proc�dure stock�e affichant le montant des commandes comprise entre 50 et 300. 
-- Le pr�fixe "usp" signifie "User Stored Procedure"
CREATE PROCEDURE [usp_GetOrderTotal]
    /* Description: Retrieves the total amount of orders between 50 and 300. */
AS
BEGIN

--  SET NOCOUNT ON : Cela emp�chera SQL Server de renvoyer le nombre de lignes affect�es apr�s chaque instruction, ce qui peut am�liorer les performances.
    SET NOCOUNT ON;

    SELECT SUM(TotalAmount) AS OrderTotal
    FROM [OrderTable]
    WHERE TotalAmount BETWEEN 50 AND 300;

    /* Returns: OrderTotal */
    RETURN;
END

-- 4.	Cr�er une proc�dure stock�e avec un param�tre de sortie qui calcule et retourne le chiffre d'affaires.
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
