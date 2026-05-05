/*
SP AnalizarClientes:

-analiza múltiples campos
-no modifica datos
-devuelve resumen + porcentajes
-devuelve ejemplos reales
-listo para mostrar a cliente

-Qué analiza
-Email (formato + duplicados + nulls)
-Teléfono (formato)
-DNI (rango)
-FechaNacimiento (edad lógica)
-Campos vacíos (nombre, dirección, etc.)
*/

CREATE OR ALTER PROCEDURE AnalizarClientes
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#Analisis') IS NOT NULL
        DROP TABLE #Analisis;

    ;WITH Base AS (
        SELECT 
            Id,
            LTRIM(RTRIM(Nombre)) AS Nombre,
            LTRIM(RTRIM(Apellido)) AS Apellido,
            DNI,
            FechaNacimiento,
            LOWER(LTRIM(RTRIM(Email))) AS Email,
            LTRIM(RTRIM(Telefono)) AS Telefono,
            LTRIM(RTRIM(Direccion)) AS Direccion,
            LTRIM(RTRIM(Ciudad)) AS Ciudad
        FROM Clientes
    ),
    DupEmail AS (
        SELECT Email
        FROM Base
        WHERE Email IS NOT NULL
        GROUP BY Email
        HAVING COUNT(*) > 1
    )
    SELECT 
        b.*,

        CASE 
            WHEN b.Email IS NULL THEN 0
            WHEN b.Email NOT LIKE '%_@_%._%' THEN 0
            ELSE 1
        END AS EmailValido,

        CASE 
            WHEN d.Email IS NOT NULL THEN 1
            ELSE 0
        END AS EmailDuplicado,

        CASE 
            WHEN b.Telefono IS NULL OR b.Telefono = '' THEN 0
            WHEN b.Telefono LIKE '%[^0-9+ ]%' THEN 0
            WHEN LEN(b.Telefono) < 7 THEN 0
            ELSE 1
        END AS TelefonoValido,

        CASE 
            WHEN b.DNI < 1000000 OR b.DNI > 99999999 THEN 0
            ELSE 1
        END AS DNIValido,

        CASE 
            WHEN b.FechaNacimiento > GETDATE() THEN 0
            WHEN DATEDIFF(YEAR, b.FechaNacimiento, GETDATE()) < 18 THEN 0
            WHEN DATEDIFF(YEAR, b.FechaNacimiento, GETDATE()) > 100 THEN 0
            ELSE 1
        END AS FechaValida,

        CASE WHEN b.Nombre IS NULL OR b.Nombre = '' THEN 0 ELSE 1 END AS NombreValido,
        CASE WHEN b.Apellido IS NULL OR b.Apellido = '' THEN 0 ELSE 1 END AS ApellidoValido

    INTO #Analisis
    FROM Base b
    LEFT JOIN DupEmail d ON b.Email = d.Email;

    --------------------------------------------------
    -- MÉTRICAS
    --------------------------------------------------
    DECLARE 
        @Total INT,
        @ConProblemas INT,
        @Score INT;

    SELECT 
        @Total = COUNT(*),
        @ConProblemas = SUM(
            CASE 
                WHEN EmailValido = 0 
                  OR EmailDuplicado = 1
                  OR TelefonoValido = 0
                  OR DNIValido = 0
                  OR FechaValida = 0
                  OR NombreValido = 0
                  OR ApellidoValido = 0
                THEN 1 ELSE 0
            END
        )
    FROM #Analisis;

    SET @Score = 100 - (@ConProblemas * 100 / @Total);

    --------------------------------------------------
    -- RESULTADOS
    --------------------------------------------------
    SELECT 
        @Total AS totalRegistros,
        @ConProblemas AS registrosConProblemas,
        @Score AS scoreCalidad;

    SELECT 
        SUM(CASE WHEN EmailValido = 0 THEN 1 ELSE 0 END) AS emailsInvalidos,
        SUM(CASE WHEN EmailDuplicado = 1 THEN 1 ELSE 0 END) AS emailsDuplicados,
        SUM(CASE WHEN TelefonoValido = 0 THEN 1 ELSE 0 END) AS telefonosInvalidos,
        SUM(CASE WHEN DNIValido = 0 THEN 1 ELSE 0 END) AS dniInvalidos,
        SUM(CASE WHEN FechaValida = 0 THEN 1 ELSE 0 END) AS fechasInvalidas
    FROM #Analisis;

    SELECT TOP 10 *
    FROM #Analisis
    WHERE EmailValido = 0 
       OR EmailDuplicado = 1
       OR TelefonoValido = 0
       OR DNIValido = 0
       OR FechaValida = 0;

END;

--Ejecutar SP
EXEC AnalizarClientes