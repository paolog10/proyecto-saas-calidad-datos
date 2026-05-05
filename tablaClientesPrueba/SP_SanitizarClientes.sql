--Agrego columnas extras, no quiero borrar datos
ALTER TABLE Clientes ADD 
    EmailNormalizado VARCHAR(255),
    EmailValido BIT,
    EmailDuplicado BIT,
    TelefonoNormalizado VARCHAR(50),
    TelefonoValido BIT,
    DNIValido BIT,
    FechaNacimientoValida BIT;

--Creación SP SanitizarClientes
/*
Esto YA es un motor de calidad de datos que:
-limpia strings
-normaliza emails
-limpia teléfonos
-detecta errores
-detecta duplicados
-mide calidad

Qué NO hace (a propósito)
No hace cosas peligrosas como:

-inventar emails
-borrar duplicados
-corregir DNI automáticamente

eso se hace después, con reglas de negocio
*/
CREATE OR ALTER PROCEDURE SanitizarClientes
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------
    -- 1. NORMALIZACIÓN
    --------------------------------------------------
    UPDATE Clientes
    SET 
        Nombre = LTRIM(RTRIM(Nombre)),
        Apellido = LTRIM(RTRIM(Apellido)),
        Direccion = LTRIM(RTRIM(Direccion)),
        Ciudad = LTRIM(RTRIM(Ciudad)),
        EmailNormalizado = LOWER(LTRIM(RTRIM(Email))),
        Telefono = LTRIM(RTRIM(Telefono));

    --------------------------------------------------
    -- 2. EMAIL VALIDACIÓN
    --------------------------------------------------
    UPDATE Clientes
    SET EmailValido =
        CASE 
            WHEN EmailNormalizado IS NULL THEN 0
            WHEN EmailNormalizado NOT LIKE '%_@_%._%' THEN 0
            ELSE 1
        END;

    --------------------------------------------------
    -- 3. EMAIL DUPLICADOS
    --------------------------------------------------
    ;WITH Dup AS (
        SELECT EmailNormalizado
        FROM Clientes
        WHERE EmailNormalizado IS NOT NULL
        GROUP BY EmailNormalizado
        HAVING COUNT(*) > 1
    )
    UPDATE c
    SET EmailDuplicado =
        CASE WHEN d.EmailNormalizado IS NOT NULL THEN 1 ELSE 0 END
    FROM Clientes c
    LEFT JOIN Dup d ON c.EmailNormalizado = d.EmailNormalizado;

    --------------------------------------------------
    -- 4. TELÉFONO NORMALIZACIÓN
    --------------------------------------------------
    UPDATE Clientes
    SET TelefonoNormalizado = 
        REPLACE(REPLACE(REPLACE(REPLACE(Telefono, ' ', ''), '-', ''), '(', ''), ')', '');

    --------------------------------------------------
    -- 5. TELÉFONO VALIDACIÓN
    --------------------------------------------------
    UPDATE Clientes
    SET TelefonoValido =
        CASE 
            WHEN TelefonoNormalizado IS NULL OR TelefonoNormalizado = '' THEN 0
            WHEN TelefonoNormalizado LIKE '%[^0-9+]%' THEN 0
            WHEN LEN(TelefonoNormalizado) < 7 THEN 0
            ELSE 1
        END;

    --------------------------------------------------
    -- 6. DNI VALIDACIÓN
    --------------------------------------------------
    UPDATE Clientes
    SET DNIValido =
        CASE 
            WHEN DNI < 1000000 OR DNI > 99999999 THEN 0
            ELSE 1
        END;

    --------------------------------------------------
    -- 7. FECHA VALIDACIÓN
    --------------------------------------------------
    UPDATE Clientes
    SET FechaNacimientoValida =
        CASE 
            WHEN FechaNacimiento > GETDATE() THEN 0
            WHEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) < 18 THEN 0
            WHEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) > 100 THEN 0
            ELSE 1
        END;

    --------------------------------------------------
    -- 8. MÉTRICAS
    --------------------------------------------------
    DECLARE 
        @Total INT,
        @ConProblemas INT,
        @Perfectos INT,
        @Score INT;

    SELECT 
        @Total = COUNT(*),

        @Perfectos = SUM(
            CASE 
                WHEN EmailValido = 1 
                 AND EmailDuplicado = 0
                 AND TelefonoValido = 1
                 AND DNIValido = 1
                 AND FechaNacimientoValida = 1
                THEN 1 ELSE 0
            END
        ),

        @ConProblemas = SUM(
            CASE 
                WHEN EmailValido = 0 
                  OR EmailDuplicado = 1
                  OR TelefonoValido = 0
                  OR DNIValido = 0
                  OR FechaNacimientoValida = 0
                THEN 1 ELSE 0
            END
        )
    FROM Clientes;

    IF @Total > 0
        SET @Score = 100 - (@ConProblemas * 100 / @Total);
    ELSE
        SET @Score = 100;

    --------------------------------------------------
    -- 9. JSON FINAL (NIVEL PRODUCTO)
    --------------------------------------------------
    SELECT 
        @Total AS totalRegistros,

        @Perfectos AS registrosPerfectos,
        CAST(@Perfectos * 100.0 / NULLIF(@Total,0) AS DECIMAL(5,2)) AS pctPerfectos,

        SUM(CASE WHEN EmailValido = 1 AND EmailDuplicado = 0 THEN 1 ELSE 0 END) AS emailsUtilizables,
        CAST(SUM(CASE WHEN EmailValido = 1 AND EmailDuplicado = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(@Total,0) AS DECIMAL(5,2)) AS pctEmailsUtilizables,

        SUM(CASE WHEN EmailValido = 0 THEN 1 ELSE 0 END) AS emailsInvalidos,
        CAST(SUM(CASE WHEN EmailValido = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(@Total,0) AS DECIMAL(5,2)) AS pctEmailsInvalidos,

        SUM(CASE WHEN EmailDuplicado = 1 THEN 1 ELSE 0 END) AS emailsDuplicados,
        CAST(SUM(CASE WHEN EmailDuplicado = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(@Total,0) AS DECIMAL(5,2)) AS pctEmailsDuplicados,

        SUM(CASE WHEN TelefonoValido = 1 THEN 1 ELSE 0 END) AS telefonosOK,
        SUM(CASE WHEN TelefonoValido = 0 THEN 1 ELSE 0 END) AS telefonosInvalidos,

        SUM(CASE WHEN DNIValido = 1 THEN 1 ELSE 0 END) AS dniOK,
        SUM(CASE WHEN DNIValido = 0 THEN 1 ELSE 0 END) AS dniInvalidos,

        SUM(CASE WHEN FechaNacimientoValida = 1 THEN 1 ELSE 0 END) AS fechasOK,
        SUM(CASE WHEN FechaNacimientoValida = 0 THEN 1 ELSE 0 END) AS fechasInvalidas,

        @ConProblemas AS registrosConProblemas,
        CAST(@ConProblemas * 100.0 / NULLIF(@Total,0) AS DECIMAL(5,2)) AS pctConProblemas,

        @Score AS scoreCalidad

    FROM Clientes
    FOR JSON PATH, ROOT('resumen');

END;

--Ejecutar SP
EXEC SanitizarClientes;