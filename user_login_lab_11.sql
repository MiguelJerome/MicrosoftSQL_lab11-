-- This should give you a list of all SQL logins on your SQL Server instance, sorted by login name
SELECT name, sid, create_date, modify_date, default_database_name, is_disabled 
FROM sys.sql_logins 
ORDER BY name;

-- This will display a list of all the users, along with their type 
-- (either Windows login or SQL login) and authentication type 
-- (either Windows authentication or SQL Server authentication).
-= To see the database users, you can execute a similar query on the specific database:
SELECT name, type_desc, authentication_type_desc FROM sys.database_principals WHERE type_desc IN ('WINDOWS_USER', 'SQL_USER');

