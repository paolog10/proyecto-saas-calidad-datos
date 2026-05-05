--Creación de tabla
IF OBJECT_ID('Clientes', 'U') IS NOT NULL
    DROP TABLE Clientes;

CREATE TABLE Clientes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    DNI INT,
    FechaNacimiento DATE,
    Email VARCHAR(255),
    Telefono VARCHAR(50),
    Direccion VARCHAR(255),
    Ciudad VARCHAR(100),
    FechaAlta DATETIME
);

--Insertar datos al azar
SET NOCOUNT ON;

DECLARE @i INT = 1;

WHILE @i <= 1000
BEGIN
    DECLARE 
        @Nombre VARCHAR(100),
        @Apellido VARCHAR(100),
        @DNI INT,
        @FechaNacimiento DATE,
        @Email VARCHAR(255),
        @Telefono VARCHAR(50),
        @Direccion VARCHAR(255),
        @Ciudad VARCHAR(100),
        @FechaAlta DATETIME,
        @tipoEmail INT;

    -- Nombres
    SET @Nombre = 
        CASE ABS(CHECKSUM(NEWID())) % 8
            WHEN 0 THEN 'Juan'
            WHEN 1 THEN 'Maria'
            WHEN 2 THEN 'Pedro'
            WHEN 3 THEN 'Ana'
            WHEN 4 THEN 'Luis'
            WHEN 5 THEN 'Sofia'
            WHEN 6 THEN 'Carlos'
            WHEN 7 THEN 'Lucia'
        END;

    -- Apellidos
    SET @Apellido = 
        CASE ABS(CHECKSUM(NEWID())) % 8
            WHEN 0 THEN 'Perez'
            WHEN 1 THEN 'Gomez'
            WHEN 2 THEN 'Lopez'
            WHEN 3 THEN 'Martinez'
            WHEN 4 THEN 'Garcia'
            WHEN 5 THEN 'Fernandez'
            WHEN 6 THEN 'Rodriguez'
            WHEN 7 THEN 'Diaz'
        END;

    -- DNI (algunos duplicados intencionales)
    SET @DNI = 
        CASE WHEN ABS(CHECKSUM(NEWID())) % 10 = 0 
            THEN 30000000 + (@i % 50)  -- duplicados
            ELSE 20000000 + ABS(CHECKSUM(NEWID())) % 20000000
        END;

    -- Fecha nacimiento (18 a 80 años)
    SET @FechaNacimiento = DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 22000), GETDATE());

    -- Email
    SET @tipoEmail = ABS(CHECKSUM(NEWID())) % 6;

    SET @Email =
        CASE @tipoEmail
            WHEN 0 THEN LOWER(@Nombre) + '.' + LOWER(@Apellido) + CAST(@i AS VARCHAR) + '@gmail.com'
            WHEN 1 THEN UPPER(@Nombre) + CAST(@i AS VARCHAR) + '@MAIL.COM'
            WHEN 2 THEN '  ' + LOWER(@Nombre) + '@hotmail.com  '
            WHEN 3 THEN LOWER(@Nombre) + @Apellido + '.com'
            WHEN 4 THEN LOWER(@Nombre) + '@'
            WHEN 5 THEN NULL
        END;

    -- Teléfono (con errores)
    SET @Telefono =
        CASE ABS(CHECKSUM(NEWID())) % 5
            WHEN 0 THEN '351' + CAST(1000000 + ABS(CHECKSUM(NEWID())) % 9000000 AS VARCHAR)
            WHEN 1 THEN '+54 9 351 ' + CAST(100000 + ABS(CHECKSUM(NEWID())) % 900000 AS VARCHAR)
            WHEN 2 THEN 'ABC123456'
            WHEN 3 THEN ''
            WHEN 4 THEN NULL
        END;

    -- Dirección
    SET @Direccion =
        CASE ABS(CHECKSUM(NEWID())) % 5
            WHEN 0 THEN 'Calle Falsa ' + CAST(100 + ABS(CHECKSUM(NEWID())) % 900 AS VARCHAR)
            WHEN 1 THEN 'Av. Siempre Viva ' + CAST(100 + ABS(CHECKSUM(NEWID())) % 900 AS VARCHAR)
            WHEN 2 THEN 'San Martin ' + CAST(1000 + ABS(CHECKSUM(NEWID())) % 9000 AS VARCHAR)
            WHEN 3 THEN ''
            WHEN 4 THEN NULL
        END;

    -- Ciudad
    SET @Ciudad =
        CASE ABS(CHECKSUM(NEWID())) % 5
            WHEN 0 THEN 'Cordoba'
            WHEN 1 THEN 'Buenos Aires'
            WHEN 2 THEN 'Rosario'
            WHEN 3 THEN 'Mendoza'
            WHEN 4 THEN NULL
        END;

    -- Fecha alta (últimos 5 años)
    SET @FechaAlta = DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 1825), GETDATE());

    INSERT INTO Clientes (
        Nombre, Apellido, DNI, FechaNacimiento, Email,
        Telefono, Direccion, Ciudad, FechaAlta
    )
    VALUES (
        @Nombre, @Apellido, @DNI, @FechaNacimiento, @Email,
        @Telefono, @Direccion, @Ciudad, @FechaAlta
    );

    SET @i = @i + 1;
END;

/*
Qué tiene este dataset (muy importante)
Simula problemas reales:
-emails inválidos / null / duplicados
-teléfonos mal formateados
-DNI duplicados
-direcciones vacías
-ciudades null
-fechas inconsistentes posibles

👉 Esto es MUY parecido a lo que vas a encontrar en clientes reales.
*/

--Insertamos duplicados
INSERT INTO Clientes (Nombre, Apellido, DNI, FechaNacimiento, Email, Telefono, Direccion, Ciudad, FechaAlta)
SELECT TOP 100 Nombre, Apellido, DNI, FechaNacimiento, Email, Telefono, Direccion, Ciudad, FechaAlta
FROM Clientes
WHERE Email IS NOT NULL;

--SELECT
SELECT * 
FROM Clientes

--NULLS
SELECT COUNT(*) AS "NULLS" FROM Clientes WHERE Email IS NULL;

--INVÁLIDOS
SELECT *
FROM Clientes
WHERE Email NOT LIKE '%_@_%._%' OR Email IS NULL;

--DUPLICADOS
SELECT Email, COUNT(*) 
FROM Clientes
WHERE Email IS NOT NULL
GROUP BY Email
HAVING COUNT(*) > 1;