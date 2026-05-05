CREATE DATABASE ProyectoSaaS;
GO

USE ProyectoSaaS;
GO

IF OBJECT_ID('Clientes', 'U') IS NOT NULL
    DROP TABLE Clientes;

SELECT name 
FROM sys.databases
WHERE name LIKE '%SaaS%';