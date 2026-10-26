USE NexarDevPortal;
GO

BEGIN TRY
    DECLARE @VectorPrueba VECTOR(1536);
    
    SELECT @VectorPrueba = DescripcionVector 
    FROM dbo.Microservicios 
    WHERE ServicioID = 2;

    CREATE TABLE #Resultados (
        ServicioID INT,
        Nombre VARCHAR(100),
        Descripcion VARCHAR(MAX),
        DescripcionVector VECTOR(1536),
        DistanciaCosine FLOAT
    );

    INSERT INTO #Resultados
    EXEC dbo.BuscarMicroservicioSemantico @VectorPregunta = @VectorPrueba, @TopN = 3;

    DECLARE @Filas INT, @Distancia FLOAT;
    SELECT @Filas = COUNT(*) FROM #Resultados;
    SELECT TOP 1 @Distancia = DistanciaCosine FROM #Resultados ORDER BY DistanciaCosine ASC;

    IF @Filas = 3 AND @Distancia = 0
        PRINT '[PASS] Prueba 3 superada: Búsqueda vectorial exacta y ordenada por menor distancia coseno.';
    ELSE
        PRINT '[FAIL] Prueba 3 fallida: El procedimiento almacenado no calculó la distancia correctamente.';

    DROP TABLE #Resultados;
END TRY
BEGIN CATCH
    PRINT '[FAIL] Prueba 3 fallida con error: ' + ERROR_MESSAGE();
END CATCH;
GO