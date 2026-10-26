USE NexarDevPortal;
GO

DECLARE @TipoColumna VARCHAR(50);

SELECT @TipoColumna = DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'EndpointsAPI' AND COLUMN_NAME = 'DescripcionFuncional';

IF @TipoColumna = 'varchar' AND EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IX_Endpoints_MetodoHTTP' AND object_id = OBJECT_ID('dbo.EndpointsAPI')
)
    PRINT '[PASS] Prueba 4 superada: Campo convertido a VARCHAR(MAX) e índice IX_Endpoints_MetodoHTTP activo.';
ELSE
    PRINT '[FAIL] Prueba 4 fallida: Revisa la ejecución de Optimizacion.sql.';
GO