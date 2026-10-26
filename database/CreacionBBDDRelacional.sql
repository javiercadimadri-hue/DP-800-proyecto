-- 1. Crear la base de datos para Nexar Payments
CREATE DATABASE NexarDevPortal;
GO

USE NexarDevPortal;
GO


CREATE TABLE Equipos (
    EquipoID INT IDENTITY(1,1) PRIMARY KEY,
    NombreEquipo VARCHAR(100) NOT NULL,
    TechLead VARCHAR(100) NOT NULL,
    CanalSlack VARCHAR(50) NOT NULL
);

-- Tabla: Microservicios (Relacionada con Equipos)
CREATE TABLE Microservicios (
    ServicioID INT IDENTITY(1,1) PRIMARY KEY,
    EquipoID INT FOREIGN KEY REFERENCES Equipos(EquipoID),
    Nombre VARCHAR(100) NOT NULL,
    Lenguaje VARCHAR(50) NOT NULL,
    Descripcion TEXT NOT NULL,
    Estado VARCHAR(20) NOT NULL
);

-- Tabla: EndpointsAPI (Relacionada con Microservicios)
CREATE TABLE EndpointsAPI (
    EndpointID INT IDENTITY(1,1) PRIMARY KEY,
    ServicioID INT FOREIGN KEY REFERENCES Microservicios(ServicioID),
    Ruta VARCHAR(255) NOT NULL,
    MetodoHTTP VARCHAR(10) NOT NULL,
    DescripcionFuncional TEXT NOT NULL,
    EjemploPayload TEXT NULL
);
GO

-- 3. Poblar las tablas con los datos Legacy (El conocimiento a vectorizar)

-- Insertar Equipos
INSERT INTO Equipos (NombreEquipo, TechLead, CanalSlack) VALUES
('Core Backend', 'Laura Martinez', '#dev-core'),                 -- 1
('Payments Squad', 'Carlos Ruiz', '#dev-payments'),              -- 2
('Customer Experience', 'Ana Gomez', '#dev-cx'),                 -- 3
('Data Platform', 'Sergio Navarro', '#dev-data'),                -- 4
('Infra & SRE', 'Elena Torres', '#dev-sre'),                     -- 5
('Security Engineering', 'Miguel Ortega', '#dev-security');      -- 6

-- Insertar Microservicios
INSERT INTO Microservicios (EquipoID, Nombre, Lenguaje, Descripcion, Estado) VALUES
(1, 'AuthService', 'C# (.NET 8)', 'Servicio central encargado de la autenticación de usuarios mediante JWT y validación de roles contra Microsoft Entra ID.', 'Activo'),                                                         -- 1
(2, 'PaymentGateway', 'Go', 'Microservicio de alta concurrencia que procesa transacciones con tarjeta de crédito y se integra con la API de Stripe.', 'Activo'),                                                                  -- 2
(3, 'NotificationWorker', 'Python', 'Proceso en segundo plano que consume colas de RabbitMQ para enviar correos electrónicos y notificaciones push a los usuarios.', 'Activo'),                                                  -- 3
(1, 'UserProfileService', 'Java (Spring Boot)', 'Gestiona los perfiles de usuario: datos personales, preferencias de idioma, configuración de privacidad y consentimientos RGPD.', 'Activo'),                                   -- 4
(2, 'RefundService', 'Go', 'Procesa devoluciones totales o parciales de pagos ya capturados, coordinándose con PaymentGateway y emitiendo eventos de reembolso a Kafka.', 'Activo'),                                             -- 5
(6, 'FraudDetectionEngine', 'Python', 'Motor de scoring en tiempo real que evalúa el riesgo de cada transacción usando reglas configurables y un modelo de machine learning entrenado con histórico de fraude.', 'Activo'),         -- 6
(2, 'InvoiceService', 'C# (.NET 8)', 'Genera facturas en PDF conformes a la normativa fiscal española, calcula impuestos (IVA) y las envía automáticamente al cliente tras cada cobro exitoso.', 'Activo'),                           -- 7
(3, 'OrderService', 'Node.js (TypeScript)', 'Orquesta el ciclo de vida de los pedidos: creación, reserva de stock, confirmación de pago, envío y cancelación.', 'Activo'),                                                       -- 8
(3, 'CatalogService', 'Kotlin', 'Expone el catálogo de productos con búsqueda, filtrado por categorías y precios, y cachea las consultas más frecuentes en Redis.', 'Activo'),                                                   -- 9
(4, 'ReportingAPI', 'Python (FastAPI)', 'API de consulta para informes financieros y operativos: conciliación diaria, volumen de transacciones y métricas de conversión por comercio.', 'Activo'),                                -- 10
(4, 'DataIngestionPipeline', 'Scala', 'Pipeline de Spark que ingesta eventos desde Kafka, los normaliza y los almacena en el data lake para análisis posterior.', 'Activo'),                                                      -- 11
(6, 'AuditLogService', 'Rust', 'Registro inmutable de auditoría de todas las acciones sensibles del sistema (accesos, cambios de configuración, operaciones financieras) con retención de 7 años.', 'Activo'),                   -- 12
(5, 'ConfigService', 'Go', 'Servicio centralizado de configuración y feature flags. Permite activar o desactivar funcionalidades por entorno y por porcentaje de usuarios sin necesidad de desplegar.', 'Activo'),               -- 13
(1, 'FileStorageService', 'C# (.NET 8)', 'Gestiona la subida y descarga de documentos (justificantes, facturas, DNI) sobre Azure Blob Storage, con escaneo antivirus previo y enlaces firmados temporales.', 'En migración'),    -- 14
(5, 'LegacySOAPAdapter', 'Java (Spring)', 'Adaptador que expone servicios SOAP antiguos para clientes corporativos que aún no han migrado a REST. Será retirado tras la migración del último cliente.', 'Deprecado');            -- 15

-- Insertar Documentación de Endpoints
INSERT INTO EndpointsAPI (ServicioID, Ruta, MetodoHTTP, DescripcionFuncional, EjemploPayload) VALUES
-- AuthService (1)
(1, '/api/v1/auth/login', 'POST', 'Autentica a un usuario usando credenciales de correo y contraseña. Devuelve un token JWT con validez de 1 hora.', '{"email": "user@test.com", "password": "123"}'),
(1, '/api/v1/auth/refresh', 'POST', 'Renueva un token JWT caducado utilizando el refresh token almacenado de forma segura en la cookie HTTP-Only.', NULL),
(1, '/api/v1/auth/logout', 'POST', 'Invalida el token JWT activo y elimina la cookie del refresh token. El token queda registrado en una lista de revocación hasta su expiración natural.', NULL),
(1, '/api/v1/auth/mfa/verify', 'POST', 'Verifica el código de autenticación multifactor (TOTP de 6 dígitos) enviado por el usuario tras un login correcto. Tras 5 intentos fallidos la cuenta se bloquea durante 15 minutos.', '{"userId": 4521, "code": "384920"}'),

-- PaymentGateway (2)
(2, '/api/v1/payments/charge', 'POST', 'Inicia un cobro en la tarjeta de crédito del usuario. Requiere un token de idempotencia en los headers para evitar cobros duplicados en caso de reintentos.', '{"amount": 50.00, "currency": "EUR", "payment_method_id": "pm_123"}'),
(2, '/api/v1/payments/{paymentId}', 'GET', 'Consulta el estado actual de un pago (pendiente, capturado, fallido o reembolsado) junto con su historial de eventos.', NULL),
(2, '/api/v1/payments/methods', 'POST', 'Registra un nuevo método de pago tokenizado para un usuario. Los datos de la tarjeta nunca pasan por nuestros servidores: se tokenizan directamente en Stripe desde el cliente.', '{"userId": 4521, "stripe_token": "tok_visa_4242"}'),
(2, '/api/v1/payments/webhook/stripe', 'POST', 'Recibe los webhooks de Stripe (payment_intent.succeeded, charge.failed, etc.). Valida la firma HMAC del header Stripe-Signature antes de procesar el evento.', NULL),

-- NotificationWorker (3)
(3, '/api/v1/notifications/send', 'POST', 'Encola un mensaje para ser enviado. Soporta canales como email, SMS y Push. Valida que el formato del correo sea correcto antes de aceptar el request.', '{"userId": 998, "channel": "email", "message": "Tu pedido ha sido enviado"}'),
(3, '/api/v1/notifications/{notificationId}/status', 'GET', 'Devuelve el estado de entrega de una notificación concreta: en cola, enviada, entregada o fallida, con el motivo del error si lo hubiera.', NULL),
(3, '/api/v1/notifications/templates', 'GET', 'Lista las plantillas de notificación disponibles con sus variables dinámicas. Las plantillas están versionadas y localizadas en español, inglés y catalán.', NULL),

-- UserProfileService (4)
(4, '/api/v1/users/{userId}', 'GET', 'Obtiene el perfil completo de un usuario. Los campos sensibles como el documento de identidad se devuelven enmascarados salvo que el solicitante tenga el rol Admin.', NULL),
(4, '/api/v1/users/{userId}', 'PATCH', 'Actualiza parcialmente los datos del perfil del usuario. Solo se modifican los campos incluidos en el body y se registra el cambio en el servicio de auditoría.', '{"preferredLanguage": "es", "marketingConsent": false}'),
(4, '/api/v1/users/{userId}/gdpr/export', 'POST', 'Genera una exportación completa de los datos personales del usuario en formato JSON conforme al derecho de portabilidad del RGPD. El archivo se entrega por email en un plazo máximo de 24 horas.', NULL),
(4, '/api/v1/users/{userId}', 'DELETE', 'Solicita el borrado de la cuenta (derecho al olvido). Los datos personales se anonimizan de inmediato, pero las transacciones financieras se conservan por obligación legal.', NULL),

-- RefundService (5)
(5, '/api/v1/refunds', 'POST', 'Crea una solicitud de reembolso sobre un pago capturado. Admite importes parciales, pero la suma de reembolsos nunca puede superar el importe original. Requiere token de idempotencia.', '{"paymentId": "pay_88213", "amount": 20.00, "reason": "producto_defectuoso"}'),
(5, '/api/v1/refunds/{refundId}', 'GET', 'Consulta el estado de un reembolso. Los reembolsos a tarjeta pueden tardar entre 5 y 10 días hábiles en reflejarse en la cuenta del cliente.', NULL),
(5, '/api/v1/refunds/{refundId}/cancel', 'POST', 'Cancela un reembolso que todavía se encuentra en estado pendiente de aprobación. No es posible cancelar reembolsos ya enviados al procesador de pagos.', NULL),

-- FraudDetectionEngine (6)
(6, '/api/v1/fraud/evaluate', 'POST', 'Evalúa el riesgo de una transacción y devuelve un score entre 0 y 100 junto con la decisión recomendada (aprobar, revisar manualmente o rechazar). Tiempo de respuesta objetivo inferior a 150 ms.', '{"transactionId": "txn_5521", "amount": 1200.00, "ipAddress": "85.12.44.7", "deviceId": "dev_a91"}'),
(6, '/api/v1/fraud/rules', 'GET', 'Lista las reglas de detección de fraude activas, como límite de importe por hora, países de alto riesgo o múltiples tarjetas desde un mismo dispositivo.', NULL),
(6, '/api/v1/fraud/cases/{caseId}/resolve', 'POST', 'Permite a un analista cerrar un caso de revisión manual marcándolo como fraude confirmado o falso positivo. Esta retroalimentación se usa para reentrenar el modelo.', '{"resolution": "falso_positivo", "analystId": 77}'),

-- InvoiceService (7)
(7, '/api/v1/invoices', 'POST', 'Genera una factura para un pago confirmado. Calcula el IVA según el país del cliente y asigna un número de factura correlativo por serie fiscal.', '{"paymentId": "pay_88213", "customerTaxId": "B12345678", "country": "ES"}'),
(7, '/api/v1/invoices/{invoiceId}/pdf', 'GET', 'Descarga la factura en formato PDF. El documento incluye código QR de verificación y se genera de forma asíncrona si no existía previamente.', NULL),
(7, '/api/v1/invoices/{invoiceId}/void', 'POST', 'Anula una factura emitiendo automáticamente una factura rectificativa. Solo es posible dentro del periodo fiscal abierto.', NULL),

-- OrderService (8)
(8, '/api/v1/orders', 'POST', 'Crea un nuevo pedido y reserva el stock de los artículos durante 15 minutos mientras se completa el pago. Si el pago no se confirma, la reserva se libera automáticamente.', '{"customerId": 4521, "items": [{"sku": "SKU-1001", "quantity": 2}], "shippingAddressId": 33}'),
(8, '/api/v1/orders/{orderId}', 'GET', 'Obtiene el detalle de un pedido con su estado actual, líneas de producto, importes y seguimiento del envío.', NULL),
(8, '/api/v1/orders/{orderId}/cancel', 'POST', 'Cancela un pedido que aún no ha sido enviado. Si ya estaba pagado, dispara automáticamente el proceso de reembolso y libera el stock reservado.', NULL),

-- CatalogService (9)
(9, '/api/v1/catalog/products', 'GET', 'Busca productos con paginación y filtros por categoría, rango de precio y disponibilidad. Los resultados se cachean 5 minutos en Redis.', NULL),
(9, '/api/v1/catalog/products/{sku}', 'GET', 'Devuelve la ficha completa de un producto: descripción, imágenes, variantes, precio vigente y stock disponible.', NULL),

-- ReportingAPI (10)
(10, '/api/v1/reports/reconciliation/daily', 'GET', 'Devuelve el informe de conciliación diaria entre los pagos registrados internamente y los liquidados por Stripe, señalando las discrepancias detectadas.', NULL),
(10, '/api/v1/reports/transactions/summary', 'GET', 'Resume el volumen y el importe de transacciones agrupados por comercio, método de pago y rango de fechas. Soporta exportación a CSV.', NULL),

-- DataIngestionPipeline (11)
(11, '/api/v1/ingestion/jobs', 'POST', 'Lanza manualmente un job de reingesta de eventos para un rango de fechas concreto. Se utiliza para recuperar datos tras incidencias en el pipeline.', '{"topic": "payments.events", "from": "2025-01-01", "to": "2025-01-02"}'),
(11, '/api/v1/ingestion/jobs/{jobId}', 'GET', 'Consulta el progreso y el resultado de un job de ingesta, incluyendo el número de eventos procesados y los descartados por errores de esquema.', NULL),

-- AuditLogService (12)
(12, '/api/v1/audit/events', 'POST', 'Registra un evento de auditoría inmutable. Cada entrada incluye actor, acción, recurso afectado, IP de origen y un hash encadenado para detectar manipulaciones.', '{"actor": "user:4521", "action": "UPDATE_PROFILE", "resource": "users/4521", "ip": "85.12.44.7"}'),
(12, '/api/v1/audit/events', 'GET', 'Consulta eventos de auditoría filtrando por actor, acción o rango de fechas. Requiere el rol SecurityAuditor y la consulta queda a su vez auditada.', NULL),

-- ConfigService (13)
(13, '/api/v1/config/flags/{flagName}', 'GET', 'Devuelve el valor de un feature flag para el entorno y el usuario indicados, aplicando las reglas de despliegue progresivo por porcentaje.', NULL),
(13, '/api/v1/config/flags/{flagName}', 'PUT', 'Modifica el estado de un feature flag. Los cambios en producción requieren aprobación de un segundo ingeniero y se propagan a los servicios en menos de 30 segundos.', '{"enabled": true, "rolloutPercentage": 25, "environment": "production"}'),

-- FileStorageService (14)
(14, '/api/v1/files/upload', 'POST', 'Sube un documento a Blob Storage. El archivo se analiza con antivirus antes de quedar disponible y se rechazan los ficheros de más de 10 MB o con extensiones no permitidas.', NULL),
(14, '/api/v1/files/{fileId}/download-link', 'GET', 'Genera un enlace firmado de descarga con validez de 10 minutos. Nunca se exponen las URLs directas del almacenamiento.', NULL),

-- LegacySOAPAdapter (15)
(15, '/soap/PaymentService', 'POST', 'Endpoint SOAP heredado que traduce las peticiones XML de clientes corporativos a llamadas REST contra PaymentGateway. Está deprecado y no admite nuevas integraciones.', NULL),
(15, '/soap/PaymentService?wsdl', 'GET', 'Devuelve el contrato WSDL del servicio SOAP legacy. Se mantiene únicamente para los clientes corporativos pendientes de migrar.', NULL);
GO