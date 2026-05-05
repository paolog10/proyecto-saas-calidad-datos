CREATE OR ALTER PROCEDURE AnalizarClientesExcelFerreteriaTipada
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#Analisis') IS NOT NULL
        DROP TABLE #Analisis;

    ---------------------------------------
    -- BASE
    ---------------------------------------
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
        FROM ClientesExcelFerreteriaTipada
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

        CASE WHEN b.Email IS NULL OR b.Email NOT LIKE '%_@_%._%' THEN 0 ELSE 1 END AS EmailValido,
        CASE WHEN d.Email IS NOT NULL THEN 1 ELSE 0 END AS EmailDuplicado,

        CASE 
            WHEN b.Telefono IS NULL OR b.Telefono = '' THEN 0
            WHEN b.Telefono LIKE '%[^0-9+ ]%' THEN 0
            WHEN LEN(b.Telefono) < 7 THEN 0
            ELSE 1
        END AS TelefonoValido,

        CASE WHEN b.DNI < 1000000 OR b.DNI > 99999999 THEN 0 ELSE 1 END AS DNIValido,

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

    ---------------------------------------
    -- MÉTRICAS
    ---------------------------------------
    DECLARE 
        @Total INT,
        @ConProblemas INT,
        @Perfectos INT,
        @Utilizables INT,
        @Score INT;

    SELECT 
        @Total = COUNT(*),

        @ConProblemas = SUM(
            CASE 
                WHEN EmailValido = 0 OR EmailDuplicado = 1
                  OR TelefonoValido = 0 OR DNIValido = 0
                  OR FechaValida = 0 OR NombreValido = 0 OR ApellidoValido = 0
                THEN 1 ELSE 0
            END
        ),

        @Perfectos = SUM(
            CASE 
                WHEN EmailValido = 1 AND EmailDuplicado = 0
                 AND TelefonoValido = 1 AND DNIValido = 1
                 AND FechaValida = 1 AND NombreValido = 1 AND ApellidoValido = 1
                THEN 1 ELSE 0
            END
        ),

        @Utilizables = SUM(
            CASE 
                WHEN (EmailValido = 1 AND EmailDuplicado = 0)
                     OR TelefonoValido = 1
                THEN 1 ELSE 0
            END
        )

    FROM #Analisis;

    SET @Score = 100 - (@ConProblemas * 100 / @Total);

    ---------------------------------------
    -- JSON FINAL
    ---------------------------------------
    SELECT
        (
            SELECT 
                @Total AS totalRegistros,
                @Perfectos AS registrosPerfectos,
                CAST(@Perfectos * 100.0 / @Total AS DECIMAL(5,2)) AS pctPerfectos,
                @Utilizables AS registrosUtilizables,
                CAST(@Utilizables * 100.0 / @Total AS DECIMAL(5,2)) AS pctUtilizables,
                @ConProblemas AS registrosConProblemas,
                CAST(@ConProblemas * 100.0 / @Total AS DECIMAL(5,2)) AS pctConProblemas,
                @Score AS scoreCalidad
            FOR JSON PATH
        ) AS resumen,

        (
            SELECT 
                SUM(CASE WHEN EmailValido = 0 THEN 1 ELSE 0 END) AS emailsInvalidos,
                SUM(CASE WHEN EmailDuplicado = 1 THEN 1 ELSE 0 END) AS emailsDuplicados,
                SUM(CASE WHEN TelefonoValido = 0 THEN 1 ELSE 0 END) AS telefonosInvalidos,
                SUM(CASE WHEN DNIValido = 0 THEN 1 ELSE 0 END) AS dniInvalidos,
                SUM(CASE WHEN FechaValida = 0 THEN 1 ELSE 0 END) AS fechasInvalidas
            FROM #Analisis
            FOR JSON PATH
        ) AS errores,

        (
            SELECT TOP 3 *
            FROM #Analisis
            WHERE EmailValido = 0 
               OR EmailDuplicado = 1
               OR TelefonoValido = 0
               OR DNIValido = 0
               OR FechaValida = 0
            FOR JSON PATH
        ) AS ejemplos

    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;

--EXEC AnalizarClientesExcelFerreteriaTipada;