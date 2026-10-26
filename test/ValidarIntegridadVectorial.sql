USE NexarDevPortal;
GO

DECLARE @VectoresNulos INT;
SELECT @VectoresNulos = COUNT(*) 
FROM dbo.Microservicios 
WHERE DescripcionVector IS NULL;

IF @VectoresNulos = 0
    PRINT '[PASS] Prueba 2 superada: Todos los microservicios tienen generado su embedding VECTOR(1536).';
ELSE
    PRINT '[FAIL] Prueba 2 fallida: Hay ' + CAST(@VectoresNulos AS VARCHAR) + ' filas sin vectorizar. Ejecuta vectorizar_microservicios.py.';
GO