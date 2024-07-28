/*  

-- Equipo: MONSTERS INC
-- Fecha de entrega: 30.05.2024
-- TP CUATRIMESTRAL GDD 2024 1C

-- Ciclo lectivo: 2024
-- Descripcion: Migracion de Tabla Maestra - Creacion Inicial

*/


USE [GD1C2024]
GO

PRINT '------ MONSTERS INC ------';
GO
PRINT '--- COMENZANDO MIGRACION  ---';
GO

/* DROPS */
DECLARE @DropConstraints NVARCHAR(max) = ''

SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'

                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)

FROM sys.foreign_keys

EXECUTE sp_executesql @DropConstraints;

PRINT '--- CONSTRAINTS DROPEADOS CORRECTAMENTE ---';

GO

/* DROPS PROCEDURES */
DECLARE @DropProcedures NVARCHAR(max) = ''

SELECT @DropProcedures += 'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.procedures;

EXECUTE sp_executesql @DropProcedures;

PRINT '--- PROCEDURES DROPEADOS CORRECTAMENTE ---';

GO

/* DROPS VISTAS */
DECLARE @DropViews NVARCHAR(max) = ''

SELECT @DropViews += 'DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.views
WHERE name LIKE '%' + 'BI_' + '%';

EXECUTE sp_executesql @DropViews;

PRINT '--- VISTAS DROPEADAS CORRECTAMENTE ---';

GO

/* DROPS FUNCTIONS */
DECLARE @DropFunctions NVARCHAR(MAX) = '';

SELECT @DropFunctions += 'DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF') AND name LIKE '%' + 'BI_' + '%';

EXEC sp_executesql @DropFunctions;

PRINT '--- FUNCTIONS DROPEADOS CORRECTAMENTE ---';

GO

/* DROP TABLES */

DECLARE @DropTables NVARCHAR(max) = ''

SELECT @DropTables += 'DROP TABLE MONSTERS_INC. ' + QUOTENAME(TABLE_NAME)

FROM INFORMATION_SCHEMA.TABLES

WHERE TABLE_SCHEMA = 'MONSTERS_INC' and TABLE_TYPE = 'BASE TABLE'

EXECUTE sp_executesql @DropTables;

PRINT '--- TABLAS DROPEADAS CORRECTAMENTE ---';

GO

IF EXISTS (SELECT name FROM sys.schemas WHERE name = 'MONSTERS_INC')
    DROP SCHEMA MONSTERS_INC
GO

CREATE SCHEMA MONSTERS_INC;
GO

PRINT '--- SCHEMA MONSTERS INC CREADO CORRECTAMENTE  ---';

/* SUBCATEGORIA */
CREATE TABLE [MONSTERS_INC].[Subcategoria]
(
    [subc_id] numeric(18) NOT NULL IDENTITY,
    [subc_descripcion] nvarchar(50),
    [subc_categoria_mayor] NUMERIC(18) NOT NULL
);

/* CATEGORIA MAYOR */
CREATE TABLE [MONSTERS_INC].[Categoria_Mayor]
(
    [catm_id] numeric(18) identity NOT NULL,
    [catm_descripcion] nvarchar(50)
);

/* PRODUCTO */
CREATE TABLE [MONSTERS_INC].[Producto]
(
    [prod_id] numeric(18) NOT NULL IDENTITY,
    [prod_subcategoria] numeric(18) NOT NULL,
    [prod_nombre] nvarchar(50),
    [prod_descripcion] nvarchar(50),
    [prod_precio] decimal(18,2),
	[prod_marca] nvarchar(50)
);

/* PROMOCION POR PRODUCTO */
CREATE TABLE [MONSTERS_INC].[Promocion_Por_Producto]
(
    [prom_prod_promocion] numeric(18) NOT NULL,
    [prom_prod_producto] numeric(18) NOT NULL
);

/* PROMOCION */
CREATE TABLE [MONSTERS_INC].[Promocion]
(
    [prom_id] numeric(18) NOT NULL IDENTITY,
    [prom_codigo] decimal(18),
    [prom_descripcion] nvarchar(255),
	[prom_fecha_inicio] datetime,
	[prom_fecha_fin] datetime,
	[prom_regla] numeric(18)
);

/* REGLA */
CREATE TABLE [MONSTERS_INC].[Regla]
(
    [reg_id] numeric(18) IDENTITY NOT NULL,
    [reg_descripcion] nvarchar(255) NULL,
	[reg_descuento] decimal(18,0),
    [reg_cantidad_aplicable] decimal(18,0),
    [reg_cantidad_descuento] decimal(18,0),
    [reg_cantidad_max] decimal(18,0),
    [reg_misma_marca] bit,
    [reg_mismo_producto] bit
);

/* SUPERMERCADO */
CREATE TABLE [MONSTERS_INC].[Supermercado]
(
    [super_id] numeric(18) IDENTITY NOT NULL,
    [super_nombre] nvarchar(4) NOT NULL,
    [super_razon_social] nvarchar(23) NOT NULL,
    [super_cuit] nvarchar(13) NOT NULL,
    [super_iibb] nvarchar(50) NOT NULL,
    [super_domicilio] nvarchar(30) NOT NULL,
	[super_fecha_inicio_actividad] date NOT NULL,
	[super_condicion_fiscal] nvarchar(25) NOT NULL
);

/* SUCURSAL */
CREATE TABLE [MONSTERS_INC].[Sucursal]
(
    [sucu_id] numeric(18) IDENTITY NOT NULL,
    [sucu_numero] nvarchar(17) NOT NULL,
	[sucu_direccion] nvarchar(50) NOT NULL,
	[sucu_localidad] numeric(18) NOT NULL,
	[sucu_supermercado] numeric(18) NOT NULL
);

/* ITEM_TICKET */
CREATE TABLE [MONSTERS_INC].[Item_Ticket]
(
    [item_tick_id] numeric(18) IDENTITY NOT NULL,
    [item_tick_ticket] numeric(18) NOT NULL,
    [item_tick_producto] numeric(18) NOT NULL,
	[item_tick_promocion] numeric(18),
    [item_tick_cantidad] decimal(18,0),
    [item_tick_total] decimal(18,2),
    [item_tick_descuento_aplicado] decimal(18,2)
);

/* CAJA */
CREATE TABLE [MONSTERS_INC].[Caja]
(
    [caja_id] numeric(18) IDENTITY NOT NULL,
    [caja_nro] decimal(18),
    [caja_tipo] nvarchar(50),
	[caja_sucursal] numeric(18) NOT NULL
);

/* TIPO COMPROBANTE */
CREATE TABLE [MONSTERS_INC].[Tipo_Comprobante]
(
    [tipo_comp_id] numeric(18) NOT NULL IDENTITY,
    [tipo_comp_detalle] char(1)
);

/* DESCUENTO MEDIO PAGO */
CREATE TABLE [MONSTERS_INC].[Descuento_Medio_Pago]
(
    [desc_id] numeric(18) IDENTITY NOT NULL,
    [desc_descripcion] nvarchar(100),
    [desc_fecha_inicio] datetime,
	[desc_fecha_fin] datetime,
	[desc_porcentaje] decimal(18,2),
	[desc_tope] decimal(18,2)
);

/* DESCUENTO MEDIO PAGO APLICADO */
CREATE TABLE [MONSTERS_INC].[Descuento_Medio_Pago_Aplicado]
(
    [desc_apli_id] numeric(18) IDENTITY NOT NULL,
    [desc_apli_pago] numeric(18) NOT NULL,
    [desc_apli_cod_descuento_mp] numeric(18) NOT NULL,
    [desc_apli_descuento_aplicado] decimal(18,2)
);

/* MEDIO PAGO */
CREATE TABLE [MONSTERS_INC].[Medio_Pago]
(
    [medio_pago_id] numeric(18) NOT NULL IDENTITY,
    [medio_pago_tipo] nvarchar(50),
    [medio_pago_nombre] nvarchar(50)
);

/* TARJETA */
CREATE TABLE [MONSTERS_INC].[Tarjeta]
(
    [tarj_id] numeric(18) NOT NULL IDENTITY,
    [tarj_numero] nvarchar(50),
    [tarj_vencimiento_tarjeta] datetime
);

/* DETALLE PAGO */
CREATE TABLE [MONSTERS_INC].[Detalle_Pago]
(
    [deta_id] numeric(18) NOT NULL IDENTITY,
    [deta_cliente] numeric(18),
    [deta_tarjeta] numeric(18) NOT NULL,
    [deta_tarjeta_cuotas] decimal(18)
);

/* PAGO */
CREATE TABLE [MONSTERS_INC].[Pago]
(
    [pago_id] numeric(18) NOT NULL IDENTITY,
    [pago_fecha] datetime,
    [pago_medio_pago] numeric(18) NOT NULL,
	[pago_detalle] numeric(18),
	[pago_importe] decimal(18,2),
	[pago_ticket] numeric(18)
);

/* ESTADO */
CREATE TABLE [MONSTERS_INC].[Estado]
(
    [esta_id] numeric(18) NOT NULL IDENTITY,
    [esta_descripcion] nvarchar(255),
);

/* ENTREGA */
CREATE TABLE [MONSTERS_INC].[Entrega]
(
    [entr_id] numeric(18) NOT NULL IDENTITY,
    [entr_fecha_hora_entrega] datetime
);

/* ENVIO */
CREATE TABLE [MONSTERS_INC].[Envio]
(
    [envio_id] numeric(18) NOT NULL IDENTITY,
    [envio_ticket] numeric(18) NOT NULL,
    [envio_fecha] datetime,
	[envio_hora_inicio] datetime,
	[envio_hora_fin] datetime,
	[envio_cliente] numeric(18) NOT NULL,
	[envio_costo] decimal(18,2),
	[envio_estado] numeric(18) NOT NULL,
	[envio_entrega] numeric(18)
);

/* CLIENTE */
CREATE TABLE [MONSTERS_INC].[Cliente]
(
    [clie_id] numeric(18) NOT NULL IDENTITY,
    [clie_dni] numeric(18),
    [clie_nombre] nvarchar(50),
	[clie_apellido] nvarchar(50),
	[clie_domicilio] nvarchar(100),
	[clie_localidad] numeric(18),
	[clie_fecha_nacimiento] datetime,
	[clie_fecha_registro] datetime,
	[clie_mail] nvarchar(50),
	[clie_telefono] numeric(18)
);

/* LOCALIDAD */
CREATE TABLE [MONSTERS_INC].[Localidad]
(
    [loca_id] numeric(18) NOT NULL IDENTITY,
    [loca_nombre] nvarchar(50),
	[loca_provincia] numeric(18) NOT NULL 
);

/* PROVINCIA */
CREATE TABLE [MONSTERS_INC].[Provincia]
(
    [prov_id] numeric(18) NOT NULL IDENTITY,
    [prov_nombre] nvarchar(50)
);

/* EMPLEADO */
CREATE TABLE [MONSTERS_INC].[Empleado]
(
    [empl_id] numeric(18) NOT NULL IDENTITY,
    [empl_sucursal] numeric(18) NOT NULL,
    [empl_nombre] nvarchar(50),
	[empl_apellido] nvarchar(50),
	[empl_dni] numeric(18),
	[empl_fecha_registro] datetime,
	[empl_telefono] numeric(18),
	[empl_mail] nvarchar(50),
	[empl_fecha_nacimiento] datetime
);

/* TICKET */
CREATE TABLE [MONSTERS_INC].[Ticket]
(
    [tick_id] numeric(18) NOT NULL IDENTITY,
    [tick_nro] decimal(18) NOT NULL,
    [tick_fecha_hora] datetime,
	[tick_caja] numeric(18),
	[tick_empleado] numeric(18),
	[tick_tipo_comprobante] numeric(18) NOT NULL,
	[tick_total_productos] decimal(18,2),
	[tick_total_descuento] decimal(18,2),
	[tick_total_descuento_mp] decimal(18,2),
	[tick_total_envio] decimal(18,2),
	[tick_total] decimal(18,2)
);

/* CONSTRAINT GENERATION - PRIMARY KEYS */

ALTER TABLE [MONSTERS_INC].[Categoria_Mayor]
    ADD CONSTRAINT [PK_Categoria_Mayor] PRIMARY KEY CLUSTERED ([catm_id] ASC)

ALTER TABLE [MONSTERS_INC].[Subcategoria]
    ADD CONSTRAINT [PK_Subcategoria] PRIMARY KEY CLUSTERED ([subc_id] ASC);

ALTER TABLE [MONSTERS_INC].[Producto]
    ADD CONSTRAINT [PK_Producto] PRIMARY KEY CLUSTERED ([prod_id] ASC);

ALTER TABLE [MONSTERS_INC].[Promocion_Por_Producto]
    ADD CONSTRAINT PK_Promocion_Por_Producto PRIMARY KEY CLUSTERED ([prom_prod_promocion] ASC, [prom_prod_producto] ASC);

ALTER TABLE [MONSTERS_INC].[Promocion]
    ADD CONSTRAINT [PK_Promocion] PRIMARY KEY CLUSTERED ([prom_id] ASC);

ALTER TABLE [MONSTERS_INC].[Regla]
    ADD CONSTRAINT [PK_Regla] PRIMARY KEY CLUSTERED ([reg_id] ASC);

ALTER TABLE [MONSTERS_INC].[Supermercado]
    ADD CONSTRAINT [PK_Supermercado] PRIMARY KEY CLUSTERED ([super_id] ASC);

ALTER TABLE [MONSTERS_INC].[Sucursal]
    ADD CONSTRAINT [PK_Sucursal] PRIMARY KEY CLUSTERED ([sucu_id] ASC);

ALTER TABLE [MONSTERS_INC].[Item_Ticket] 
    ADD CONSTRAINT [PK_Item_Ticket] PRIMARY KEY CLUSTERED ([item_tick_id] ASC);

ALTER TABLE [MONSTERS_INC].[Caja] 
    ADD CONSTRAINT [PK_Caja] PRIMARY KEY CLUSTERED ([caja_id] ASC);

ALTER TABLE [MONSTERS_INC].[Tipo_Comprobante] 
    ADD CONSTRAINT [PK_Tipo_Comprobante] PRIMARY KEY CLUSTERED ([tipo_comp_id] ASC);

ALTER TABLE [MONSTERS_INC].[Descuento_Medio_Pago]
    ADD CONSTRAINT [PK_Descuento_Medio_Pago] PRIMARY KEY CLUSTERED ([desc_id] ASC);

ALTER TABLE [MONSTERS_INC].[Medio_Pago]
    ADD CONSTRAINT [PK_Medio_Pago] PRIMARY KEY CLUSTERED ([medio_pago_id] ASC);

ALTER TABLE [MONSTERS_INC].[Ticket]
    ADD CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED ([tick_id] ASC);

ALTER TABLE [MONSTERS_INC].[Empleado]
    ADD CONSTRAINT [PK_Empleado] PRIMARY KEY CLUSTERED ([empl_id] ASC);

ALTER TABLE [MONSTERS_INC].[Localidad]
    ADD CONSTRAINT [PK_Localidad] PRIMARY KEY CLUSTERED ([loca_id] ASC);

ALTER TABLE [MONSTERS_INC].[Provincia]
    ADD CONSTRAINT [PK_Provincia] PRIMARY KEY CLUSTERED ([prov_id] ASC);

ALTER TABLE [MONSTERS_INC].[Cliente] 
    ADD CONSTRAINT [PK_Cliente] PRIMARY KEY CLUSTERED ([clie_id] ASC);

ALTER TABLE [MONSTERS_INC].[Envio] 
    ADD CONSTRAINT [PK_Envio] PRIMARY KEY CLUSTERED ([envio_id] ASC);

ALTER TABLE [MONSTERS_INC].[Entrega] 
    ADD CONSTRAINT [PK_Entrega] PRIMARY KEY CLUSTERED ([entr_id] ASC);

ALTER TABLE [MONSTERS_INC].[Estado] 
    ADD CONSTRAINT [PK_Estado] PRIMARY KEY CLUSTERED ([esta_id] ASC);

ALTER TABLE [MONSTERS_INC].[Pago] 
    ADD CONSTRAINT [PK_Pago] PRIMARY KEY CLUSTERED ([pago_id] ASC);

ALTER TABLE [MONSTERS_INC].[Detalle_Pago] 
    ADD CONSTRAINT [PK_Detalle_Pago] PRIMARY KEY CLUSTERED ([deta_id] ASC);

ALTER TABLE [MONSTERS_INC].[Tarjeta] 
    ADD CONSTRAINT [PK_Tarjeta] PRIMARY KEY CLUSTERED ([tarj_id] ASC);

/* CONSTRAINT GENERATION - FOREIGN KEYS */

ALTER TABLE [MONSTERS_INC].[Subcategoria]
    ADD CONSTRAINT [FK_Subcategoria_subc_categoria_mayor] FOREIGN KEY ([subc_categoria_mayor])
    REFERENCES [MONSTERS_INC].[Categoria_Mayor]([catm_id]);

ALTER TABLE [MONSTERS_INC].[Producto]
    ADD CONSTRAINT [FK_Producto_prod_subcategoria] FOREIGN KEY ([prod_subcategoria])
    REFERENCES [MONSTERS_INC].[Subcategoria]([subc_id]);

ALTER TABLE [MONSTERS_INC].[Promocion_Por_Producto]
    ADD CONSTRAINT [FK_Promocion_Por_Producto_prom_prod_promocion] FOREIGN KEY ([prom_prod_promocion])
    REFERENCES [MONSTERS_INC].[Promocion]([prom_id]);

ALTER TABLE [MONSTERS_INC].[Promocion_Por_Producto]
    ADD CONSTRAINT [FK_Promocion_Por_Producto_prom_prod_producto] FOREIGN KEY ([prom_prod_producto])
    REFERENCES [MONSTERS_INC].[Producto]([prod_id]);

ALTER TABLE [MONSTERS_INC].[Promocion]
    ADD CONSTRAINT [FK_Promocion_prom_regla] FOREIGN KEY ([prom_regla])
    REFERENCES [MONSTERS_INC].[Regla]([reg_id]);

ALTER TABLE [MONSTERS_INC].[Localidad]
    ADD CONSTRAINT [FK_Localidad_loca_provincia] FOREIGN KEY ([loca_provincia])
    REFERENCES [MONSTERS_INC].[Provincia]([prov_id]);

ALTER TABLE [MONSTERS_INC].[Sucursal] 
    ADD CONSTRAINT [FK_Sucursal_sucu_localidad] FOREIGN KEY ([sucu_localidad])
    REFERENCES [MONSTERS_INC].[Localidad]([loca_id]);

ALTER TABLE [MONSTERS_INC].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_sucu_supermercado] FOREIGN KEY ([sucu_supermercado])
    REFERENCES [MONSTERS_INC].[Supermercado]([super_id]);

ALTER TABLE [MONSTERS_INC].[Caja]
    ADD CONSTRAINT [FK_Caja_caja_sucursal] FOREIGN KEY ([caja_sucursal])
    REFERENCES [MONSTERS_INC].[Sucursal]([sucu_id]);

ALTER TABLE [MONSTERS_INC].[Item_Ticket]
    ADD CONSTRAINT [FK_Item_Ticket_item_tick_ticket] FOREIGN KEY ([item_tick_ticket]) 
    REFERENCES [MONSTERS_INC].[Ticket]([tick_id]);

ALTER TABLE [MONSTERS_INC].[Item_Ticket]
    ADD CONSTRAINT [FK_Item_Ticket_item_tick_producto] FOREIGN KEY ([item_tick_producto]) 
    REFERENCES [MONSTERS_INC].[Producto]([prod_id]);

ALTER TABLE [MONSTERS_INC].[Item_Ticket]
    ADD CONSTRAINT [FK_Item_Ticket_item_tick_promocion] FOREIGN KEY ([item_tick_promocion]) 
    REFERENCES [MONSTERS_INC].[Promocion]([prom_id]);

ALTER TABLE [MONSTERS_INC].[Ticket]
    ADD CONSTRAINT [FK_Ticket_tick_caja] FOREIGN KEY ([tick_caja]) 
    REFERENCES [MONSTERS_INC].[Caja]([caja_id]);

ALTER TABLE [MONSTERS_INC].[Ticket]
    ADD CONSTRAINT [FK_Ticket_tick_empleado] FOREIGN KEY ([tick_empleado]) 
    REFERENCES [MONSTERS_INC].[Empleado]([empl_id]);

ALTER TABLE [MONSTERS_INC].[Ticket]
    ADD CONSTRAINT [FK_Ticket_tick_tipo_comprobante] FOREIGN KEY ([tick_tipo_comprobante]) 
    REFERENCES [MONSTERS_INC].[Tipo_Comprobante]([tipo_comp_id]);

ALTER TABLE [MONSTERS_INC].[Empleado]
    ADD CONSTRAINT [FK_Empleado_empl_sucursal] FOREIGN KEY ([empl_sucursal]) 
    REFERENCES [MONSTERS_INC].[Sucursal]([sucu_id]);

ALTER TABLE [MONSTERS_INC].[Cliente]
    ADD CONSTRAINT [FK_Cliente_clie_localidad] FOREIGN KEY ([clie_localidad]) 
    REFERENCES [MONSTERS_INC].[Localidad]([loca_id]);

ALTER TABLE [MONSTERS_INC].[Envio]
    ADD CONSTRAINT [FK_Envio_envio_ticket] FOREIGN KEY ([envio_ticket]) 
    REFERENCES [MONSTERS_INC].[Ticket]([tick_id]);

ALTER TABLE [MONSTERS_INC].[Envio]
    ADD CONSTRAINT [FK_Envio_envio_cliente] FOREIGN KEY ([envio_cliente]) 
    REFERENCES [MONSTERS_INC].[Cliente]([clie_id]);

ALTER TABLE [MONSTERS_INC].[Envio]
    ADD CONSTRAINT [FK_Envio_envio_estado] FOREIGN KEY ([envio_estado]) 
    REFERENCES [MONSTERS_INC].[Estado]([esta_id]);

ALTER TABLE [MONSTERS_INC].[Envio]
    ADD CONSTRAINT [FK_Envio_envio_entrega] FOREIGN KEY ([envio_entrega]) 
    REFERENCES [MONSTERS_INC].[Entrega]([entr_id]);

ALTER TABLE [MONSTERS_INC].[Pago]
    ADD CONSTRAINT [FK_Pago_pago_medio_pago] FOREIGN KEY ([pago_medio_pago]) 
    REFERENCES [MONSTERS_INC].[Medio_Pago]([medio_pago_id]);

ALTER TABLE [MONSTERS_INC].[Pago]
    ADD CONSTRAINT [FK_Pago_pago_detalle] FOREIGN KEY ([pago_detalle]) 
    REFERENCES [MONSTERS_INC].[Detalle_Pago]([deta_id]);

ALTER TABLE [MONSTERS_INC].[Pago]
    ADD CONSTRAINT [FK_Pago_pago_ticket] FOREIGN KEY ([pago_ticket]) 
    REFERENCES [MONSTERS_INC].[Ticket]([tick_id]);

ALTER TABLE [MONSTERS_INC].[Descuento_Medio_Pago_Aplicado]
    ADD CONSTRAINT [FK_Descuento_Medio_Pago_Aplicado_desc_apli_pago] FOREIGN KEY ([desc_apli_pago]) 
    REFERENCES [MONSTERS_INC].[Pago]([pago_id]);

ALTER TABLE [MONSTERS_INC].[Descuento_Medio_Pago_Aplicado]
    ADD CONSTRAINT [FK_Descuento_Medio_Pago_Aplicado_desc_apli_cod_descuento_mp] FOREIGN KEY ([desc_apli_cod_descuento_mp]) 
    REFERENCES [MONSTERS_INC].[Descuento_Medio_Pago]([desc_id]);

ALTER TABLE [MONSTERS_INC].[Detalle_Pago]
    ADD CONSTRAINT [FK_Detalle_Pago_deta_cliente] FOREIGN KEY ([deta_cliente]) 
    REFERENCES [MONSTERS_INC].[Cliente]([clie_id]);

ALTER TABLE [MONSTERS_INC].[Detalle_Pago]
    ADD CONSTRAINT [FK_Detalle_Pago_deta_tarjeta] FOREIGN KEY ([deta_tarjeta]) 
    REFERENCES [MONSTERS_INC].[Tarjeta]([tarj_id]);


PRINT '--- TABLAS CREADAS CORRECTAMENTE ---';
GO

/* --- MIGRACION DE DATOS ---*/

CREATE PROCEDURE [MONSTERS_INC].Migrar_Provincia
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Provincia] (prov_nombre)
    SELECT DISTINCT SUPER_PROVINCIA AS prov_nombre
    FROM gd_esquema.Maestra
    WHERE SUPER_PROVINCIA NOT IN (SELECT prov_nombre FROM [MONSTERS_INC].[Provincia]);
    
    INSERT INTO [MONSTERS_INC].[Provincia] (prov_nombre)
    SELECT DISTINCT SUCURSAL_PROVINCIA AS prov_nombre
    FROM gd_esquema.Maestra
    WHERE SUCURSAL_PROVINCIA NOT IN (SELECT prov_nombre FROM [MONSTERS_INC].[Provincia]);

    INSERT INTO [MONSTERS_INC].[Provincia] (prov_nombre)
    SELECT DISTINCT CLIENTE_PROVINCIA AS prov_nombre
    FROM gd_esquema.Maestra
    WHERE CLIENTE_PROVINCIA NOT IN (SELECT prov_nombre FROM [MONSTERS_INC].[Provincia]);
END
GO

/* LOCALIDAD */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Localidad
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Localidad] (loca_nombre, loca_provincia)
        SELECT DISTINCT SUPER_LOCALIDAD AS localidad_nombre, prov_id AS loca_provincia
        FROM gd_esquema.Maestra
        JOIN [MONSTERS_INC].[Provincia] Provincia ON SUPER_PROVINCIA = prov_nombre
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [MONSTERS_INC].[Localidad] 
        WHERE [MONSTERS_INC].[Localidad].loca_nombre = SUPER_LOCALIDAD
            AND [MONSTERS_INC].[Localidad].loca_provincia = Provincia.prov_id
    )   AND SUPER_LOCALIDAD IS NOT NULL

    INSERT INTO [MONSTERS_INC].[Localidad] (loca_nombre, loca_provincia)
        SELECT DISTINCT SUCURSAL_LOCALIDAD AS localidad_nombre, prov_id AS loca_provincia
        FROM gd_esquema.Maestra
        JOIN [MONSTERS_INC].[Provincia] Provincia ON SUCURSAL_PROVINCIA = prov_nombre
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [MONSTERS_INC].[Localidad] 
        WHERE [MONSTERS_INC].[Localidad].loca_nombre = SUCURSAL_LOCALIDAD
            AND [MONSTERS_INC].[Localidad].loca_provincia = Provincia.prov_id
    )    AND SUCURSAL_LOCALIDAD IS NOT NULL

        INSERT INTO [MONSTERS_INC].[Localidad] (loca_nombre, loca_provincia)
        SELECT DISTINCT CLIENTE_LOCALIDAD AS localidad_nombre, prov_id AS loca_provincia
        FROM gd_esquema.Maestra
        JOIN [MONSTERS_INC].[Provincia] Provincia ON CLIENTE_PROVINCIA = prov_nombre
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [MONSTERS_INC].[Localidad] 
        WHERE [MONSTERS_INC].[Localidad].loca_nombre = CLIENTE_LOCALIDAD
            AND [MONSTERS_INC].[Localidad].loca_provincia = Provincia.prov_id
    )       AND CLIENTE_LOCALIDAD IS NOT NULL
END
GO


/* SUPERMERCADO */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Supermercado
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Supermercado]
        (super_nombre, super_razon_social, super_cuit, super_iibb, super_domicilio, super_fecha_inicio_actividad, super_condicion_fiscal)
    SELECT DISTINCT
        SUPER_NOMBRE,
        SUPER_RAZON_SOC,
        SUPER_CUIT,
        SUPER_IIBB,
        SUPER_DOMICILIO,
        SUPER_FECHA_INI_ACTIVIDAD,
        SUPER_CONDICION_FISCAL
    FROM gd_esquema.Maestra
END
GO

/* SUCURSAL */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Sucursal
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Sucursal]
        (sucu_numero, sucu_direccion, sucu_localidad, sucu_supermercado)
    SELECT DISTINCT
        SUCURSAL_NOMBRE,
        SUCURSAL_DIRECCION,
        loc.loca_id AS sucu_localidad,
        sm.super_id AS sucu_supermercado
    FROM gd_esquema.Maestra AS M
    LEFT JOIN [MONSTERS_INC].[Localidad] AS loc ON loc.loca_nombre = M.SUCURSAL_LOCALIDAD
    LEFT JOIN [MONSTERS_INC].[Supermercado] AS sm ON sm.super_cuit = M.SUPER_CUIT;
END
GO

/* REGLA */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Regla
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Regla]
        (reg_descripcion, reg_descuento, reg_cantidad_aplicable, reg_cantidad_descuento, reg_cantidad_max, reg_misma_marca, reg_mismo_producto)
    SELECT DISTINCT 
        REGLA_DESCRIPCION, 
        REGLA_DESCUENTO_APLICABLE_PROD, 
        REGLA_CANT_APLICA_DESCUENTO, 
        REGLA_CANT_APLICABLE_REGLA,  
        REGLA_CANT_MAX_PROD, 
        REGLA_APLICA_MISMA_MARCA,
        REGLA_APLICA_MISMO_PROD
    FROM gd_esquema.Maestra
    WHERE 
        REGLA_DESCRIPCION IS NOT NULL AND 
        REGLA_DESCUENTO_APLICABLE_PROD IS NOT NULL AND 
        REGLA_CANT_APLICA_DESCUENTO IS NOT NULL AND 
        REGLA_CANT_APLICABLE_REGLA IS NOT NULL AND   
        REGLA_CANT_MAX_PROD IS NOT NULL AND 
        REGLA_APLICA_MISMA_MARCA IS NOT NULL AND   
        REGLA_APLICA_MISMO_PROD IS NOT NULL;
END
GO

/* PROMOCION */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Promocion
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Promocion]
        (prom_codigo, prom_descripcion, prom_fecha_inicio, prom_fecha_fin, prom_regla)
    SELECT DISTINCT
        PROMO_CODIGO,
        PROMOCION_DESCRIPCION,
        PROMOCION_FECHA_INICIO,
        PROMOCION_FECHA_FIN,
        R.reg_id AS prom_regla
    FROM gd_esquema.Maestra AS M
    LEFT JOIN [MONSTERS_INC].[Regla] AS R ON R.reg_descripcion = M.REGLA_DESCRIPCION
    WHERE PROMO_CODIGO IS NOT NULL
END
GO

/* CATEGORÍA MAYOR */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Categoria_Mayor
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Categoria_Mayor]
        (catm_descripcion)
    SELECT DISTINCT PRODUCTO_CATEGORIA
    FROM gd_esquema.Maestra
    WHERE PRODUCTO_CATEGORIA IS NOT NULL
END
GO

/* SUB_CATEGORIA */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Sub_Categoria
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Subcategoria]
        (subc_descripcion, subc_categoria_mayor)
    SELECT DISTINCT
        PRODUCTO_SUB_CATEGORIA,
        CM.catm_id AS subc_categoria_mayor
    FROM gd_esquema.Maestra AS M
    LEFT JOIN [MONSTERS_INC].[Categoria_Mayor] AS CM ON CM.catm_descripcion = M.PRODUCTO_CATEGORIA
    WHERE M.PRODUCTO_SUB_CATEGORIA IS NOT NULL;
END
GO

/* PRODUCTO */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Producto
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Producto]
        (prod_descripcion, prod_marca, prod_nombre, prod_precio, prod_subcategoria)
    SELECT
        PRODUCTO_DESCRIPCION,
        PRODUCTO_MARCA,
        PRODUCTO_NOMBRE,
        MAX(PRODUCTO_PRECIO) AS prod_precio,
        MIN(SC.subc_id) AS prod_subcategoria 
    FROM gd_esquema.Maestra AS M
    LEFT JOIN [MONSTERS_INC].[Subcategoria] AS SC ON SC.subc_descripcion = M.PRODUCTO_SUB_CATEGORIA
    INNER JOIN [MONSTERS_INC].[Categoria_Mayor] AS CM ON CM.catm_descripcion = M.PRODUCTO_CATEGORIA AND CM.catm_id = SC.subc_categoria_mayor
    WHERE M.PRODUCTO_DESCRIPCION IS NOT NULL
        AND M.PRODUCTO_MARCA IS NOT NULL
        AND M.PRODUCTO_NOMBRE IS NOT NULL
        AND M.PRODUCTO_PRECIO IS NOT NULL
    GROUP BY
        PRODUCTO_DESCRIPCION,
        PRODUCTO_MARCA,
        PRODUCTO_NOMBRE;
END
GO


/* Promocion Por Producto */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Promocion_Por_Producto
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Promocion_Por_Producto]
        (prom_prod_producto, prom_prod_promocion)
    SELECT DISTINCT
        P.prod_id AS prom_prod_producto,
        PR.prom_id AS prom_prod_promocion
    FROM gd_esquema.Maestra AS M
    INNER JOIN [MONSTERS_INC].[Producto] AS P ON P.prod_descripcion = M.PRODUCTO_DESCRIPCION 
        AND P.prod_nombre = M.PRODUCTO_NOMBRE 
        AND P.prod_marca = M.PRODUCTO_MARCA
    INNER JOIN [MONSTERS_INC].[Promocion] AS PR ON PR.prom_descripcion = M.PROMOCION_DESCRIPCION 
        AND PR.prom_codigo = M.PROMO_CODIGO
END
GO


/* CAJA */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Caja
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Caja]
        (caja_nro, caja_tipo, caja_sucursal)
    SELECT DISTINCT
        CAJA_NUMERO AS caja_nro,
        CAJA_TIPO AS caja_tipo,
        S.sucu_id AS caja_sucursal
    FROM gd_esquema.Maestra AS M
    LEFT JOIN [MONSTERS_INC].[Sucursal] AS S ON S.sucu_numero = M.SUCURSAL_NOMBRE AND S.sucu_direccion = M.SUCURSAL_DIRECCION 
    WHERE CAJA_NUMERO IS NOT NULL AND CAJA_TIPO IS NOT NULL
        AND S.sucu_id IS NOT NULL; 
END
GO

/* TIPO COMPROBANTE */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Tipo_Comprobante
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Tipo_Comprobante]
        (tipo_comp_detalle)
    SELECT DISTINCT TICKET_TIPO_COMPROBANTE
    FROM gd_esquema.Maestra
    WHERE TICKET_TIPO_COMPROBANTE IS NOT NULL
END
GO

/* MEDIO DE PAGO */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Medio_De_Pago
AS
BEGIN
    INSERT INTO [MONSTERS_INC].Medio_Pago
        (medio_pago_nombre, medio_pago_tipo)
    SELECT DISTINCT PAGO_MEDIO_PAGO, PAGO_TIPO_MEDIO_PAGO
    FROM gd_esquema.Maestra
    WHERE PAGO_MEDIO_PAGO IS NOT NULL AND PAGO_TIPO_MEDIO_PAGO IS NOT NULL
END
GO

/* CLIENTE */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Cliente
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Cliente]
        (clie_nombre, clie_apellido, clie_dni, clie_fecha_registro, clie_telefono, clie_mail, clie_fecha_nacimiento, clie_domicilio, clie_localidad)
    SELECT DISTINCT
        M.CLIENTE_NOMBRE,
        M.CLIENTE_APELLIDO,
        M.CLIENTE_DNI,
        M.CLIENTE_FECHA_REGISTRO,
        M.CLIENTE_TELEFONO,
        M.CLIENTE_MAIL,
        M.CLIENTE_FECHA_NACIMIENTO,
        M.CLIENTE_DOMICILIO,
        L.loca_id AS clie_localidad
    FROM gd_esquema.Maestra M
    LEFT JOIN [MONSTERS_INC].[Localidad] L ON L.loca_nombre = M.CLIENTE_LOCALIDAD 
    LEFT JOIN [MONSTERS_INC].[Provincia] P ON P.prov_id = l.loca_provincia
    WHERE M.CLIENTE_NOMBRE IS NOT NULL 
        AND M.CLIENTE_APELLIDO IS NOT NULL
        AND M.CLIENTE_DNI IS NOT NULL
        AND M.CLIENTE_FECHA_REGISTRO IS NOT NULL
        AND M.CLIENTE_TELEFONO IS NOT NULL
        AND M.CLIENTE_MAIL IS NOT NULL
        AND M.CLIENTE_FECHA_NACIMIENTO IS NOT NULL
        AND M.CLIENTE_DOMICILIO IS NOT NULL
        AND P.prov_nombre = M.CLIENTE_PROVINCIA;
END
GO

/* Empleado */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Empleado
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Empleado]
        (empl_nombre, empl_apellido, empl_dni, empl_fecha_registro, empl_telefono, empl_mail, empl_fecha_nacimiento, empl_sucursal)
    SELECT DISTINCT
        M.EMPLEADO_NOMBRE,
        M.EMPLEADO_APELLIDO,
        M.EMPLEADO_DNI,
        M.EMPLEADO_FECHA_REGISTRO,
        M.EMPLEADO_TELEFONO,
        M.EMPLEADO_MAIL,
        M.EMPLEADO_FECHA_NACIMIENTO,
        S.sucu_id AS empl_sucursal
    FROM gd_esquema.Maestra M
    LEFT JOIN [MONSTERS_INC].[Sucursal] S ON S.sucu_numero = M.SUCURSAL_NOMBRE
    WHERE M.EMPLEADO_NOMBRE IS NOT NULL 
        AND M.EMPLEADO_APELLIDO IS NOT NULL
        AND M.EMPLEADO_DNI IS NOT NULL
        AND M.EMPLEADO_FECHA_REGISTRO IS NOT NULL
        AND M.EMPLEADO_TELEFONO IS NOT NULL
        AND M.EMPLEADO_MAIL IS NOT NULL
        AND M.EMPLEADO_FECHA_NACIMIENTO IS NOT NULL;
END
GO

/* Tarjeta */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Tarjeta
AS
BEGIN
    INSERT INTO [MONSTERS_INC].Tarjeta (tarj_numero, tarj_vencimiento_tarjeta)
        SELECT PAGO_TARJETA_NRO, PAGO_TARJETA_FECHA_VENC
        FROM gd_esquema.Maestra
        WHERE PAGO_TARJETA_NRO IS NOT NULL AND PAGO_TARJETA_FECHA_VENC IS NOT NULL
END
GO

/* Detalle Pago */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Detalle_Pago
AS
BEGIN
    INSERT INTO [MONSTERS_INC].Detalle_Pago 
    (deta_cliente, deta_tarjeta, deta_tarjeta_cuotas) 
    SELECT (SELECT clie_id
    FROM [MONSTERS_INC].Cliente
    WHERE CLIENTE_DNI = clie_dni) AS deta_cliente, 
    (SELECT tarj_id 
    FROM [MONSTERS_INC].Tarjeta
    WHERE PAGO_TARJETA_NRO = tarj_numero) AS deta_tarjeta,
    PAGO_TARJETA_CUOTAS AS deta_tarjeta_cuotas
    FROM gd_esquema.Maestra
    WHERE PAGO_TARJETA_NRO IS NOT NULL
END
GO

/* Descuento_Medio_Pago */
-- Se tiene, una fila por descuento con su porcentaje asociado

CREATE PROCEDURE [MONSTERS_INC].Migrar_Descuento_Medio_Pago
AS
BEGIN
    INSERT INTO [MONSTERS_INC].Descuento_Medio_Pago 
    (desc_descripcion, desc_fecha_inicio, desc_fecha_fin, desc_porcentaje, desc_tope) 
        SELECT DISTINCT 
            DESCUENTO_DESCRIPCION AS desc_descripcion,
            DESCUENTO_FECHA_INICIO AS desc_fecha_inicio, 
            DESCUENTO_FECHA_FIN AS desc_fecha_fin, 
            DESCUENTO_PORCENTAJE_DESC AS desc_porcentaje,
            DESCUENTO_TOPE AS desc_tope
        FROM gd_esquema.Maestra
        WHERE DESCUENTO_DESCRIPCION IS NOT NULL 
            AND DESCUENTO_FECHA_INICIO IS NOT NULL
            AND DESCUENTO_FECHA_FIN IS NOT NULL
            AND DESCUENTO_PORCENTAJE_DESC IS NOT NULL
            AND DESCUENTO_TOPE IS NOT NULL
END
GO

/* Ticket */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Ticket
AS
BEGIN
    INSERT INTO [MONSTERS_INC].Ticket
    (
        tick_nro, tick_fecha_hora, tick_caja, tick_empleado, tick_tipo_comprobante, tick_total_productos,
        tick_total_descuento, tick_total_descuento_mp, tick_total_envio, tick_total
    )
    SELECT DISTINCT
        m.TICKET_NUMERO AS tick_nro,
        m.TICKET_FECHA_HORA AS tick_fecha_hora,
        c.caja_id AS tick_caja,
        e.empl_id AS tick_empleado,
        tc.tipo_comp_id AS tick_tipo_comprobante,
        m.TICKET_SUBTOTAL_PRODUCTOS AS tick_total_productos,
        m.TICKET_TOTAL_DESCUENTO_APLICADO AS tick_total_descuento,
        m.TICKET_TOTAL_DESCUENTO_APLICADO_MP AS tick_total_descuento_mp,
        m.TICKET_TOTAL_ENVIO AS tick_total_envio,
        m.TICKET_TOTAL_TICKET AS tick_total
    FROM 
        gd_esquema.Maestra m
    LEFT JOIN 
        [MONSTERS_INC].Empleado e ON m.EMPLEADO_DNI = e.empl_dni 
                                  AND m.EMPLEADO_APELLIDO = e.empl_apellido 
                                  AND m.EMPLEADO_NOMBRE = e.empl_nombre
    LEFT JOIN 
        [MONSTERS_INC].Tipo_Comprobante tc ON m.TICKET_TIPO_COMPROBANTE = tc.tipo_comp_detalle
    LEFT JOIN
        [MONSTERS_INC].Caja c ON m.CAJA_NUMERO = c.caja_nro AND e.empl_sucursal = c.caja_sucursal
    WHERE 
        m.TICKET_FECHA_HORA IS NOT NULL
        AND e.empl_id IS NOT NULL 
        AND c.caja_id IS NOT NULL
        AND m.TICKET_SUBTOTAL_PRODUCTOS IS NOT NULL
        AND m.TICKET_TOTAL_DESCUENTO_APLICADO IS NOT NULL
        AND m.TICKET_TOTAL_DESCUENTO_APLICADO_MP IS NOT NULL
        AND m.TICKET_TOTAL_ENVIO IS NOT NULL
        AND m.TICKET_TOTAL_TICKET IS NOT NULL
        AND m.TICKET_NUMERO IS NOT NULL;
END
GO

/* Estado */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Estado
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Estado]
        (esta_descripcion)
    SELECT DISTINCT ENVIO_ESTADO
    FROM gd_esquema.Maestra
    WHERE ENVIO_ESTADO IS NOT NULL
END
GO

/* Entrega */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Entrega
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Entrega]
        (entr_fecha_hora_entrega)
    SELECT DISTINCT ENVIO_FECHA_ENTREGA
    FROM gd_esquema.Maestra
    WHERE ENVIO_FECHA_ENTREGA IS NOT NULL
END
GO

/* DATOS DIRECCION */
CREATE PROCEDURE [MONSTERS_INC].Migrar_Envio
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Envio]
        (envio_ticket, envio_fecha, envio_hora_inicio, envio_hora_fin, envio_cliente, envio_costo, envio_entrega, envio_estado)
    SELECT 
        t.tick_id AS envio_ticket,
        m.ENVIO_FECHA_PROGRAMADA AS envio_fecha,
        m.ENVIO_HORA_INICIO AS envio_hora_inicio,
        m.ENVIO_HORA_FIN AS envio_hora_fin,
        c.clie_id AS envio_cliente, 
        m.ENVIO_COSTO AS envio_costo, 
        e.entr_id AS envio_entrega,
        es.esta_id AS envio_estado
    FROM 
        gd_esquema.Maestra m
    LEFT JOIN 
        [MONSTERS_INC].Cliente c ON m.CLIENTE_DNI = c.clie_dni 
                  AND m.CLIENTE_APELLIDO = c.clie_apellido 
                  AND m.CLIENTE_NOMBRE = c.clie_nombre
    LEFT JOIN 
        [MONSTERS_INC].Entrega e ON m.ENVIO_FECHA_ENTREGA = e.entr_fecha_hora_entrega
    LEFT JOIN 
        [MONSTERS_INC].Estado es ON m.ENVIO_ESTADO = es.esta_descripcion
    LEFT JOIN 
        [MONSTERS_INC].Ticket t ON m.TICKET_FECHA_HORA = t.tick_fecha_hora 
                 AND m.TICKET_NUMERO = t.tick_nro
    WHERE 
        m.ENVIO_COSTO IS NOT NULL
        AND m.ENVIO_FECHA_PROGRAMADA IS NOT NULL
        AND m.ENVIO_HORA_INICIO IS NOT NULL
        AND m.ENVIO_HORA_FIN IS NOT NULL;
END
GO

/* Item Ticket */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Item_Ticket
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[Item_Ticket]
        (item_tick_ticket, item_tick_producto, item_tick_promocion, item_tick_cantidad, item_tick_total, item_tick_descuento_aplicado)
    SELECT
        t.tick_id AS item_tick_ticket,
        pr.prod_id AS item_tick_producto,
        pm.prom_id AS item_tick_promocion,
        TICKET_DET_CANTIDAD AS item_tick_cantidad,
        TICKET_DET_PRECIO AS item_tick_total,
        TICKET_TOTAL_DESCUENTO_APLICADO AS item_tick_descuento_aplicado
    FROM gd_esquema.Maestra
    LEFT JOIN [MONSTERS_INC].Ticket t ON TICKET_FECHA_HORA = t.tick_fecha_hora 
        AND TICKET_NUMERO = t.tick_nro
    LEFT JOIN [MONSTERS_INC].Producto pr ON PRODUCTO_NOMBRE = pr.prod_nombre 
        AND PRODUCTO_DESCRIPCION = pr.prod_descripcion
        AND PRODUCTO_MARCA = pr.prod_marca
    LEFT JOIN [MONSTERS_INC].Regla ON REGLA_DESCRIPCION = reg_descripcion
    LEFT JOIN [MONSTERS_INC].Promocion pm ON PROMOCION_DESCRIPCION = pm.prom_descripcion 
        AND PROMOCION_FECHA_INICIO = pm.prom_fecha_inicio
        AND PROMOCION_FECHA_FIN = pm.prom_fecha_fin
        AND pm.prom_regla = reg_id
    WHERE TICKET_DET_CANTIDAD IS NOT NULL
    AND TICKET_TOTAL_TICKET IS NOT NULL
    AND TICKET_TOTAL_DESCUENTO_APLICADO IS NOT NULL
    AND pr.prod_id IS NOT NULL
END
GO

/* Pago */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Pago
AS
BEGIN
    INSERT INTO [MONSTERS_INC].Pago
    (pago_fecha, pago_medio_pago, pago_detalle, pago_importe, pago_ticket)
    SELECT PAGO_FECHA AS pago_fecha,
    medio_pago_id AS pago_medio_pago,
    deta_id AS pago_detalle,
    PAGO_IMPORTE AS pago_importe,
    tick_id AS pago_ticket
    FROM gd_esquema.Maestra
    LEFT JOIN [MONSTERS_INC].Medio_Pago ON PAGO_TIPO_MEDIO_PAGO = medio_pago_tipo 
        AND PAGO_MEDIO_PAGO = medio_pago_nombre
    LEFT JOIN [MONSTERS_INC].Tarjeta ON PAGO_TARJETA_NRO = tarj_numero 
        AND PAGO_TARJETA_FECHA_VENC = tarj_vencimiento_tarjeta
    LEFT JOIN [MONSTERS_INC].Detalle_Pago ON deta_tarjeta = tarj_id
    LEFT JOIN [MONSTERS_INC].Ticket ON TICKET_NUMERO = tick_nro AND TICKET_FECHA_HORA = tick_fecha_hora
    WHERE PAGO_TIPO_MEDIO_PAGO IS NOT NULL
    AND PAGO_MEDIO_PAGO IS NOT NULL
END
GO

/* Descuento_Medio_Pago_Aplicado */

CREATE PROCEDURE [MONSTERS_INC].Migrar_Descuento_Medio_Pago_Aplicado
AS
BEGIN
    INSERT INTO [MONSTERS_INC].Descuento_Medio_Pago_Aplicado
    (desc_apli_pago, desc_apli_cod_descuento_mp , desc_apli_descuento_aplicado)
    SELECT
        p.pago_id AS desc_apli_pago,
        d.desc_id AS desc_apli_cod_descuento_mp,
        m.PAGO_DESCUENTO_APLICADO AS desc_apli_descuento_aplicado
    FROM gd_esquema.Maestra m
    INNER JOIN [MONSTERS_INC].Ticket t ON m.TICKET_NUMERO = t.tick_nro
    INNER JOIN [MONSTERS_INC].Pago p ON tick_id = p.pago_ticket AND p.pago_fecha = m.PAGO_FECHA
    LEFT JOIN [MONSTERS_INC].Descuento_Medio_Pago d ON m.DESCUENTO_DESCRIPCION = d.desc_descripcion 
        AND m.DESCUENTO_FECHA_FIN = d.desc_fecha_fin and m.DESCUENTO_FECHA_INICIO = d.desc_fecha_inicio and m.DESCUENTO_PORCENTAJE_DESC = d.desc_porcentaje
    WHERE m.DESCUENTO_DESCRIPCION IS NOT NULL
END
GO

/* EJECUCIONES */

PRINT '--- COMENZANDO LA MIGRACION DE DATOS ---'

/* Tablas primarias sin FK */
execute MONSTERS_INC.[Migrar_Provincia]
execute MONSTERS_INC.[Migrar_Entrega]
execute MONSTERS_INC.[Migrar_Estado]
execute MONSTERS_INC.[Migrar_Tarjeta]
execute MONSTERS_INC.[Migrar_Medio_De_Pago]
execute MONSTERS_INC.[Migrar_Tipo_Comprobante]
execute MONSTERS_INC.[Migrar_Categoria_Mayor]
execute MONSTERS_INC.[Migrar_Regla]


/* Tablas con FK */
execute MONSTERS_INC.[Migrar_Promocion]
execute MONSTERS_INC.[Migrar_Sub_Categoria]
execute MONSTERS_INC.[Migrar_Localidad]
execute MONSTERS_INC.[Migrar_Supermercado]
execute MONSTERS_INC.[Migrar_Sucursal]
execute MONSTERS_INC.[Migrar_Caja] 
execute MONSTERS_INC.[Migrar_Producto]
execute MONSTERS_INC.[Migrar_Empleado]
execute MONSTERS_INC.[Migrar_Descuento_Medio_Pago]
execute MONSTERS_INC.[Migrar_Ticket]
execute MONSTERS_INC.[Migrar_Item_Ticket]
execute MONSTERS_INC.[Migrar_Cliente]
execute MONSTERS_INC.[Migrar_Envio]
execute MONSTERS_INC.[Migrar_Detalle_Pago]
execute MONSTERS_INC.[Migrar_Pago]
execute MONSTERS_INC.[Migrar_Descuento_Medio_Pago_Aplicado]
execute MONSTERS_INC.[Migrar_Promocion_Por_Producto]

PRINT '--- TABLAS MIGRADAS CORRECTAMENTE ---'


/* CREACION DE INDICES */

PRINT '--- CREACION DE INDICES ---'

/*  PROVINCIA   */
CREATE INDEX IDX_PROVINCIA_ID ON [MONSTERS_INC].[Provincia] (prov_id);

/*  ENTREGA   */
CREATE INDEX IDX_ENTREGA_ID ON [MONSTERS_INC].[Entrega] (entr_id);

/*  ESTADO   */
CREATE INDEX IDX_ESTADO_ID ON [MONSTERS_INC].[Estado] (esta_id);

/*  TARJETA   */
CREATE INDEX IDX_TARJETA_ID ON [MONSTERS_INC].[Tarjeta] (tarj_id);

/*  MEDIO DE PAGO   */
CREATE INDEX IDX_MEDIO_PAGO_ID ON [MONSTERS_INC].[Medio_Pago] (medio_pago_id);

/*  TIPO COMPROBANTE   */
CREATE INDEX IDX_TIPO_COMPROBANTE_ID ON [MONSTERS_INC].[Tipo_Comprobante] (tipo_comp_id);

/*  CATEGORIA MAYOR   */
CREATE INDEX IDX_CATEGORIA_MAYOR_ID ON [MONSTERS_INC].[Categoria_Mayor] (catm_id);

/*  REGLA   */
CREATE INDEX IDX_REGLA_ID ON [MONSTERS_INC].[Regla] (reg_id);

/*  PROMOCION   */
CREATE INDEX IDX_PROMOCION_ID ON [MONSTERS_INC].[Promocion] (prom_id);

/*  SUB CATEGORIA   */
CREATE INDEX IDX_SUBCATEGORIA_ID ON [MONSTERS_INC].[Subcategoria] (subc_id);

/*  LOCALIDAD   */
CREATE INDEX IDX_LOCALIDAD_ID ON [MONSTERS_INC].[Localidad] (loca_id);

/*  SUPERMERCADO   */
CREATE INDEX IDX_SUPERMERCADO_ID ON [MONSTERS_INC].[Supermercado] (super_id);

/*  SUCURSAL   */
CREATE INDEX IDX_SUCURSAL_ID ON [MONSTERS_INC].[Sucursal] (sucu_id);

/*  CAJA   */
CREATE INDEX IDX_CAJA_ID ON [MONSTERS_INC].[Caja] (caja_id);

/*  PRODUCTO   */
CREATE INDEX IDX_PROD_ID ON [MONSTERS_INC].[Producto] (prod_id);

/*  EMPLEADO   */
CREATE INDEX IDX_EMPLEADO_ID ON [MONSTERS_INC].[Empleado] (empl_id);

/*  DESCUENTO MEDIO PAGO   */
CREATE INDEX IDX_DESCUENTO_MEDIO_PAGO_ID ON [MONSTERS_INC].[Descuento_Medio_Pago] (desc_id);

/*  TICKET   */
CREATE INDEX IDX_TICKET_ID ON [MONSTERS_INC].[Ticket] (tick_id);

/*  ITEM TICKET   */
CREATE INDEX IDX_ITEM_TICKET_ID ON [MONSTERS_INC].[Item_Ticket] (item_tick_id);

/*  CLIENTE   */
CREATE INDEX IDX_CLIENTE_ID ON [MONSTERS_INC].[Cliente] (clie_id);

/*  ENVIO   */
CREATE INDEX IDX_ENVIO_ID ON [MONSTERS_INC].[Envio] (envio_id);

/*  DETALLE PAGO   */
CREATE INDEX IDX_DETALLE_PAGO_ID ON [MONSTERS_INC].[Detalle_Pago] (deta_id);

/*  DESCUENTO MEDIO PAGO APLICADO   */
CREATE INDEX IDX_ESCUENTO_MEDIO_PAGO_APLICADO_ID ON [MONSTERS_INC].[Descuento_Medio_Pago_Aplicado] (desc_apli_id);

/*  PROMOCION POR PRODUCTO   */
CREATE INDEX IDX_PROMOCION_POR_PRODUCTO_ID ON [MONSTERS_INC].[Promocion_Por_Producto] (prom_prod_promocion, prom_prod_producto);

PRINT '--- FINALIZACION DE EJECUCION ---'
