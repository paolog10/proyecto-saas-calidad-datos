--Creación tabla tipada
CREATE TABLE ClientesExcelferreteriaTipada (
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    DNI INT,
    FechaNacimiento DATE,
    Email VARCHAR(255),
    Telefono VARCHAR(50),
    Direccion VARCHAR(255),
    Ciudad VARCHAR(100),
    FechaAlta DATE
);

--Insertamos  datos
INSERT INTO ClientesExcelferreteriaTipada (
    Nombre,
    Apellido,
    DNI,
    FechaNacimiento,
    Email,
    Telefono,
    Direccion,
    Ciudad,
    FechaAlta
)
SELECT
    LTRIM(RTRIM(Nombre)),
    LTRIM(RTRIM(Apellido)),

    TRY_CAST(DNI AS INT),

    TRY_CAST(FechaNacimiento AS DATE),

    NULLIF(LTRIM(RTRIM(Email)), ''),

    NULLIF(LTRIM(RTRIM(Telefono)), ''),

    NULLIF(LTRIM(RTRIM(Direccion)), ''),

    NULLIF(LTRIM(RTRIM(Ciudad)), ''),

    TRY_CAST(FechaAlta AS DATE)

FROM ClientesExcelFerreteriaOriginal;

--Si todo está correcto
SELECT COUNT(*) FROM ClientesExcelferreteriaTipada;

--Ver datos problemáticos
--Fechas sospechosas
SELECT *
FROM Clientes
WHERE FechaNacimiento > GETDATE()
   OR DATEDIFF(YEAR, FechaNacimiento, GETDATE()) < 18
   OR DATEDIFF(YEAR, FechaNacimiento, GETDATE()) > 100;

--Dni fuera de rango
SELECT *
FROM Clientes
WHERE DNI < 1000000 OR DNI > 99999999;

--Emails inválidos
SELECT *
FROM Clientes
WHERE Email IS NOT NULL
  AND Email NOT LIKE '%_@_%._%';

--Telefonos raros
SELECT *
FROM Clientes
WHERE Telefono IS NOT NULL
  AND Telefono LIKE '%[^0-9+]%';