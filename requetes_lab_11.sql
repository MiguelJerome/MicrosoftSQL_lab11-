--Revoquer tous les droits de l'utilisateur et supprimer tous les objets qui lui sont associes.
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
PRINT @@TRANCOUNT  
BEGIN TRAN  
    PRINT @@TRANCOUNT 
    -- Trouver les produits qui n'ont jamais été commandés
    SELECT p.product_id
    --Cette transaction cree une table temporaire #products_to_delete pour stocker les identifiants des produits qui n'ont jamais ete commandes
    INTO #products_to_delete
    FROM production.products p
    LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
    WHERE oi.product_id IS NULL; 

    -- Supprimer les stocks correspondants
    DELETE FROM production.stocks
    WHERE product_id IN (SELECT product_id FROM #products_to_delete);
    DELETE FROM production.products WHERE product_id NOT IN (SELECT product_id FROM sales.orders)

    -- Supprimer les produits correspondants
    DELETE FROM production.products
    WHERE product_id IN (SELECT product_id FROM #products_to_delete);

    -- Valider la transaction
    COMMIT  
    PRINT @@TRANCOUNT  

-- 3.	Creer une procedure stockee affichant le montant des commandes comprise entre 50 et 300. 
-- Le prefixe "usp" signifie "User Stored Procedure"
CREATE PROCEDURE [usp_GetOrderTotal]
    /* Description: Retrieves the total amount of orders between 50 and 300. */
AS
BEGIN

--  SET NOCOUNT ON : Cela empechera SQL Server de renvoyer le nombre de lignes affectees apres chaque instruction, ce qui peut am�liorer les performances.
    SET NOCOUNT ON;

    SELECT SUM(TotalAmount) AS OrderTotal
    FROM [OrderTable]
    WHERE TotalAmount BETWEEN 50 AND 300;

    /* Returns: OrderTotal */
    RETURN;
END

-- 4.	Creer une procedure stockee avec un parametre de sortie qui calcule et retourne le chiffre d'affaires.
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
