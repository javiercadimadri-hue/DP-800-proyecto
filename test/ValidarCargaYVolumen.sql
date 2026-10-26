USE NexarDevPortal;
GO

DECLARE @CantEquipos INT, @CantMicroservicios INT, @CantEndpoints INT;

SELECT @CantEquipos = COUNT(*) FROM dbo.Equipos;
SELECT @CantMicroservicios = COUNT(*) FROM dbo.Microservicios;
SELECT @CantEndpoints = COUNT(*) FROM dbo.EndpointsAPI;

IF @CantEquipos >= 6 AND @CantMicroservicios >= 15 AND @CantEndpoints >= 30
    PRINT '[PASS] Prueba 1 superada: Dataset completo (' + CAST(@CantEquipos AS VARCHAR) + ' equipos, ' + CAST(@CantMicroservicios AS VARCHAR) + ' microservicios, ' + CAST(@CantEndpoints AS VARCHAR) + ' endpoints).';
ELSE
    PRINT '[FAIL] Prueba 1 fallida: Revisa la ejecución de CreacionBBDDRelacional.sql.';
GO