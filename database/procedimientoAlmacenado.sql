USE NexarDevPortal;
GO

-- 1. Creamos o actualizamos el procedimiento almacenado
CREATE OR ALTER PROCEDURE dbo.BuscarMicroservicioSemantico
    @VectorPregunta VECTOR(1536),
    @TopN INT = 3
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        ServicioID,
        Nombre,
        Descripcion,
        DescripcionVector,
        VECTOR_DISTANCE('cosine', DescripcionVector, @VectorPregunta) AS DistanciaCosine
    FROM dbo.Microservicios
    WHERE DescripcionVector IS NOT NULL
    ORDER BY DistanciaCosine ASC;
END;
GO

-- 2. Probamos la ejecución del procedimiento
DECLARE @VectorSimulado VECTOR(1536);

SELECT @VectorSimulado = DescripcionVector 
FROM dbo.Microservicios 
WHERE ServicioID = 2;

EXEC dbo.BuscarMicroservicioSemantico 
    @VectorPregunta = @VectorSimulado, 
    @TopN = 3;
GO