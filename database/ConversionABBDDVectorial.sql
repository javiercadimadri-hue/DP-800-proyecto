USE NexarDevPortal;
GO

-- Añadir columna vectorial a los microservicios
ALTER TABLE Microservicios 
ADD DescripcionVector VECTOR(1536);
GO

-- Añadir columna vectorial a los endpoints
ALTER TABLE EndpointsAPI 
ADD EndpointVector VECTOR(1536);
GO