CREATE OR ALTER PROCEDURE SanitizarClientesExcelFerreteriaTipada
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.ClientesSanitizados') IS NOT NULL
        DROP TABLE dbo.ClientesSanitizados;

    --------------------------------------------------
    -- BASE + SANITIZACIÓN
    --------------------------------------------------
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
        b.Id,
        b.Nombre,
        b.Apellido,
        b.DNI,

        -- Fecha válida
        CASE 
            WHEN b.FechaNacimiento > GETDATE() THEN NULL
            WHEN DATEDIFF(YEAR, b.FechaNacimiento, GETDATE()) < 18 THEN NULL
            WHEN DATEDIFF(YEAR, b.FechaNacimiento, GETDATE()) > 100 THEN NULL
            ELSE b.FechaNacimiento
        END AS FechaNacimiento,

        -- Email sanitizado
        CASE 
            WHEN b.Email IS NULL THEN NULL
            WHEN b.Email NOT LIKE '%_@_%._%' THEN NULL
            WHEN d.Email IS NOT NULL THEN NULL
            ELSE b.Email
        END AS Email,

        -- Teléfono sanitizado
        CASE 
            WHEN b.Telefono IS NULL OR b.Telefono = '' THEN NULL
            WHEN b.Telefono LIKE '%[^0-9+ ]%' THEN NULL
            WHEN LEN(b.Telefono) < 7 THEN NULL
            ELSE b.Telefono
        END AS Telefono,

        NULLIF(b.Direccion, '') AS Direccion,
        NULLIF(b.Ciudad, '') AS Ciudad

    INTO ClientesSanitizados
    FROM Base b
    LEFT JOIN DupEmail d ON b.Email = d.Email;

    --------------------------------------------------
    -- RESULTADO TABULAR
    --------------------------------------------------
    SELECT 
        COUNT(*) AS totalRegistros,

        SUM(CASE WHEN Email IS NOT NULL THEN 1 ELSE 0 END) AS emailsUtilizables,
        CAST(SUM(CASE WHEN Email IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pctEmailsUtilizables,

        SUM(CASE WHEN Telefono IS NOT NULL THEN 1 ELSE 0 END) AS telefonosUtilizables,
        CAST(SUM(CASE WHEN Telefono IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pctTelefonosUtilizables,

        SUM(CASE WHEN Email IS NOT NULL OR Telefono IS NOT NULL THEN 1 ELSE 0 END) AS registrosUtilizables,
        CAST(SUM(CASE WHEN Email IS NOT NULL OR Telefono IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pctUtilizables,

        CAST(
            (SUM(CASE WHEN Email IS NOT NULL OR Telefono IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
        AS INT) AS scoreCalidad

    FROM ClientesSanitizados;

    --------------------------------------------------
    -- JSON PARA FRONTEND 
    --------------------------------------------------
    SELECT 
        COUNT(*) AS totalRegistros,

        SUM(CASE WHEN Email IS NOT NULL THEN 1 ELSE 0 END) AS emailsUtilizables,
        CAST(SUM(CASE WHEN Email IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pctEmailsUtilizables,

        SUM(CASE WHEN Telefono IS NOT NULL THEN 1 ELSE 0 END) AS telefonosUtilizables,
        CAST(SUM(CASE WHEN Telefono IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pctTelefonosUtilizables,

        SUM(CASE WHEN Email IS NOT NULL OR Telefono IS NOT NULL THEN 1 ELSE 0 END) AS registrosUtilizables,
        CAST(SUM(CASE WHEN Email IS NOT NULL OR Telefono IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pctUtilizables,

        CAST(
            (SUM(CASE WHEN Email IS NOT NULL OR Telefono IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
        AS INT) AS scoreCalidad

    FROM ClientesSanitizados
    FOR JSON PATH, ROOT('resumen');

END;

--Ejecutar SP
EXEC SanitizarClientesExcelFerreteriaTipada;