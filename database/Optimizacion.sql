USE NexarDevPortal;
GO

-- 1. Solución al problema: Actualizamos el tipo de dato obsoleto TEXT al moderno VARCHAR(MAX)
ALTER TABLE EndpointsAPI ALTER COLUMN DescripcionFuncional VARCHAR(MAX) NOT NULL;
GO

-- 2. Ahora sí, creamos el índice no clúster cubriente sin problemas
CREATE NONCLUSTERED INDEX IX_Endpoints_MetodoHTTP
ON EndpointsAPI (MetodoHTTP)
INCLUDE (Ruta, DescripcionFuncional);
GO

-- 3. Comprobamos que funciona (Index Seek)
SELECT Ruta, DescripcionFuncional
FROM EndpointsAPI
WHERE MetodoHTTP = 'POST';
GO