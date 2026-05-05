CREATE TABLE ClientesExcelFerreteria (
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    DNI VARCHAR(50),
    FechaNacimiento VARCHAR(50),
    Email VARCHAR(255),
    Telefono VARCHAR(50),
    Direccion VARCHAR(255),
    Ciudad VARCHAR(100),
    FechaAlta VARCHAR(50)
);

--Ver C:\SQLData -> Ahí está en .csv
BULK INSERT ClientesExcelFerreteria
FROM 'C:\SQLData\clientesFerreteria.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);

--SELECT servicename, service_account
--FROM sys.dm_server_services;

