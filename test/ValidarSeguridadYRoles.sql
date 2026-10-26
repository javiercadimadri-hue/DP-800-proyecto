USE NexarDevPortal;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminDevPortal')
   AND EXISTS (SELECT * FROM sys.database_principals WHERE name = 'DeveloperUser')
   AND EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RolDevPortalApp')
BEGIN
    PRINT '[PASS] Prueba 5 superada: Los roles de seguridad (AdminDevPortal, DeveloperUser, RolDevPortalApp) existen correctamente.';
END
ELSE
BEGIN
    PRINT '[FAIL] Prueba 5 fallida: Faltan roles de seguridad por crear.';
END
GO