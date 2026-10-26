USE NexarDevPortal;
GO

-- 1. Crear roles de base de datos de forma segura
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminDevPortal')
    CREATE ROLE AdminDevPortal;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'DeveloperUser')
    CREATE ROLE DeveloperUser;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RolDevPortalApp')
    CREATE ROLE RolDevPortalApp;
GO

-- 2. Asignar permisos al rol de Administrador
GRANT SELECT, INSERT, UPDATE, DELETE ON Equipos TO AdminDevPortal;
GRANT SELECT, INSERT, UPDATE, DELETE ON Microservicios TO AdminDevPortal;
GRANT SELECT, INSERT, UPDATE, DELETE ON EndpointsAPI TO AdminDevPortal;
GO

-- 3. Asignar permisos al rol de Desarrollador (Solo lectura)
GRANT SELECT ON Equipos TO DeveloperUser;
GRANT SELECT ON Microservicios TO DeveloperUser;
GRANT SELECT ON EndpointsAPI TO DeveloperUser;
DENY DELETE ON Microservicios TO DeveloperUser;
GO

-- 4. Permiso de ejecución para la aplicación sobre la búsqueda vectorial
GRANT EXECUTE ON dbo.BuscarMicroservicioSemantico TO RolDevPortalApp;
GO