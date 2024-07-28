/*  

------------------------------------------------------------------------
-- Equipo: MONSTERS INC
-- Fecha de entrega: 30.06.2024
-- TP CUATRIMESTRAL GDD 2024 1C

-- Ciclo lectivo: 2024
-- Descripcion: Migracion a modelo BI
------------------------------------------------------------------------

*/

USE [GD1C2024]
GO

PRINT '------ MONSTERS INC ------';
GO
PRINT '--- COMENZANDO MIGRACION BI  ---';
GO

/* DROPS */
DECLARE @DropConstraints NVARCHAR(max) = ''

SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'
                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)
FROM sys.foreign_keys
WHERE name LIKE '%' + 'BI_' + '%';

EXECUTE sp_executesql @DropConstraints;

PRINT '--- CONSTRAINTS BI DROPEADOS CORRECTAMENTE ---';


/* DROPS PROCEDURES */
DECLARE @DropProcedures NVARCHAR(max) = ''

SELECT @DropProcedures += 'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.procedures
WHERE name LIKE '%' + 'BI_' + '%';

EXECUTE sp_executesql @DropProcedures;

PRINT '--- PROCEDURES BI DROPEADOS CORRECTAMENTE ---';


/* DROPS FUNCTIONS */
DECLARE @DropFunctions NVARCHAR(MAX) = '';

SELECT @DropFunctions += 'DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF') AND name LIKE '%' + 'BI_' + '%';

EXEC sp_executesql @DropFunctions;

PRINT '--- FUNCTIONS BI DROPEADOS CORRECTAMENTE ---';


/* DROPS TABLAS */
IF OBJECT_ID('MONSTERS_INC.BI_Tiempo', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Tiempo;
IF OBJECT_ID('MONSTERS_INC.BI_Ubicacion', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Ubicacion;
IF OBJECT_ID('MONSTERS_INC.BI_Sucursal', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Sucursal;
IF OBJECT_ID('MONSTERS_INC.BI_Rango_Etario', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Rango_Etario;
IF OBJECT_ID('MONSTERS_INC.BI_Turno', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Turno;
IF OBJECT_ID('MONSTERS_INC.BI_Medio_Pago', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Medio_Pago;
IF OBJECT_ID('MONSTERS_INC.BI_Categoria', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Categoria;
IF OBJECT_ID('MONSTERS_INC.BI_Item_Ticket', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Item_Ticket;
IF OBJECT_ID('MONSTERS_INC.BI_Hechos_Venta', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Hechos_Venta;
IF OBJECT_ID('MONSTERS_INC.BI_Caja_Tipo', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Caja_Tipo;
IF OBJECT_ID('MONSTERS_INC.BI_Hechos_Envio', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Hechos_Envio;
IF OBJECT_ID('MONSTERS_INC.BI_Hechos_Promocion', 'U') IS NOT NULL DROP TABLE MONSTERS_INC.BI_Hechos_Promocion;

PRINT '--- TABLAS BI DROPEADAS CORRECTAMENTE ---';

------------------------------------------------------------------------

PRINT '--- CREACION TABLAS DE DIMENSIONES  ---';
GO

/* BI Tiempo */
CREATE TABLE [MONSTERS_INC].[BI_Tiempo]
(
    [bi_tiempo_id] numeric(18) IDENTITY NOT NULL,
    [bi_tiempo_anio] numeric(18) NOT NULL,
    [bi_tiempo_cuatrimestre] numeric(6) NOT NULL,
    [bi_tiempo_mes] numeric(16) NOT NULL
);

/* BI Ubicacion */
CREATE TABLE [MONSTERS_INC].[BI_Ubicacion]
(
    [bi_ubicacion_id] numeric(18) IDENTITY NOT NULL,
    [provincia_desc] nvarchar(255) NOT NULL,
    [localidad_desc] nvarchar(255) NOT NULL
);

/* BI Sucursal */
CREATE TABLE [MONSTERS_INC].[BI_Sucursal]
(
    [bi_sucursal_id] numeric(18) IDENTITY NOT NULL,
    [sucursal_desc] nvarchar(255) NOT NULL
);


/* BI Rango_Etario */
CREATE TABLE [MONSTERS_INC].[BI_Rango_Etario]
(
    [bi_rango_etario_id] numeric(18) IDENTITY NOT NULL,
    [rango_etario_desc] nvarchar(255) NOT NULL
);

/* BI Turno */
CREATE TABLE [MONSTERS_INC].[BI_Turno]
(
    [bi_turno_id] numeric(18) IDENTITY NOT NULL,
    [turno_desc] nvarchar(255) NOT NULL
);


/* BI Medio_Pago */
CREATE TABLE [MONSTERS_INC].[BI_Medio_Pago]
(
    [bi_medio_pago_id] numeric(18) IDENTITY NOT NULL,
    [medio_pago_tipo] nvarchar(50) NOT NULL,
    [medio_pago_nombre] nvarchar(50) NOT NULL
);

/* BI Categoria */
CREATE TABLE [MONSTERS_INC].[BI_Categoria]
(
    [bi_categoria_id] numeric(18) IDENTITY NOT NULL,
    [subc_descripcion] nvarchar(50) NOT NULL,
    [catm_descripcion] nvarchar(50) NOT NULL
);

/* BI_Caja_Tipo */
CREATE TABLE [MONSTERS_INC].[BI_Caja_Tipo]
(
    [bi_caja_tipo_id] numeric(18) IDENTITY NOT NULL,
    [caja_desc] nvarchar(255),
    [caja_nro] nvarchar(18)
);

------------------------------------------------------------------------

PRINT '--- CREACION TABLAS DE HECHOS  ---';
GO

/* BI Hechos_Venta */
CREATE TABLE [MONSTERS_INC].[BI_Hechos_Venta]
(
    [bi_hechos_venta_id] numeric(18) IDENTITY NOT NULL,
    [bi_venta_tiempo_id] numeric(18) NOT NULL,
    [bi_venta_turno_id] numeric(18) NOT NULL,
    [bi_venta_caja_tipo_id] numeric(18) NOT NULL,
    [bi_venta_rango_etario_id] numeric(18) NOT NULL,
    [bi_venta_medio_pago_id] numeric(18) NOT NULL,
    [bi_venta_ubicacion_id] numeric(18) NOT NULL,
    [bi_venta_sucursal_id] numeric(18) NOT NULL,
    [venta_prom_total] decimal(18,2),
    [venta_total_monto] decimal(18,2),
    [venta_cant_prom_productos] numeric(18),
    [venta_cantidad] numeric(18),
    [venta_total_importe_cuotas] decimal(18,2),
    [venta_promedio_cuota] decimal(18,2)
);

/* BI Hechos_Envio */
CREATE TABLE [MONSTERS_INC].[BI_Hechos_Envio]
(
    [bi_hechos_envio_id] numeric(18) IDENTITY NOT NULL,
    [bi_envio_tiempo_id] numeric(18) NOT NULL,
    [bi_envio_rango_etario_id] numeric(18) NOT NULL,
    [bi_envio_ubicacion_id] numeric(18) NOT NULL,
    [bi_envio_sucursal_id] numeric(18),
    [bi_envio_cantidad] numeric(18) NOT NULL,
    [bi_envio_max_costo] decimal(18,2) NOT NULL,
    [bi_envio_porc_cumpl] decimal(18,2) NOT NULL
);


/* BI Hechos_Promocion */
CREATE TABLE [MONSTERS_INC].[BI_Hechos_Promocion]
(
    [bi_hechos_promo_id] numeric(18) IDENTITY NOT NULL,
    [bi_promo_tiempo_id] numeric(18) NOT NULL,
    [bi_promo_categoria_id] numeric(18) NOT NULL,
    [bi_promo_mp_id] numeric(18) NOT NULL,
    [bi_promo_porc_desc] decimal(18,2),
    [bi_promo_max_desc] decimal(18,2),
    [bi_promo_porc_desc_aplicado] decimal(18,2)
);

------------------------------------------------------------------------

/* CONSTRAINT GENERATION - PKs*/

ALTER TABLE [MONSTERS_INC].[BI_Tiempo]
    ADD CONSTRAINT [PK_BI_Tiempo] PRIMARY KEY CLUSTERED ([bi_tiempo_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Ubicacion]
    ADD CONSTRAINT [PK_BI_Ubicacion] PRIMARY KEY CLUSTERED ([bi_ubicacion_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Sucursal]
    ADD CONSTRAINT [PK_BI_Sucursal] PRIMARY KEY CLUSTERED ([bi_sucursal_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Rango_Etario]
    ADD CONSTRAINT [PK_BI_Rango_Etario] PRIMARY KEY CLUSTERED ([bi_rango_etario_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Turno]
    ADD CONSTRAINT [PK_BI_Turno] PRIMARY KEY CLUSTERED ([bi_turno_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Medio_Pago]
    ADD CONSTRAINT [PK_BI_Medio_Pago] PRIMARY KEY CLUSTERED ([bi_medio_pago_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Categoria]
    ADD CONSTRAINT [PK_BI_Categoria] PRIMARY KEY CLUSTERED ([bi_categoria_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Caja_Tipo]
    ADD CONSTRAINT [PK_BI_Caja_Tipo] PRIMARY KEY CLUSTERED ([bi_caja_tipo_id] ASC)

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Envio]
    ADD CONSTRAINT [PK_BI_Hechos_Envio] PRIMARY KEY CLUSTERED ([bi_hechos_envio_id] ASC) 

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Promocion]
    ADD CONSTRAINT [PK_BI_Hechos_Promocion] PRIMARY KEY CLUSTERED ([bi_hechos_promo_id] ASC) 


/* CONSTRAINT GENERATION - FKs*/

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Venta]
    ADD CONSTRAINT [FK_BI_Hechos_Venta_bi_venta_ubicacion_id] FOREIGN KEY ([bi_venta_ubicacion_id])
    REFERENCES [MONSTERS_INC].[BI_Ubicacion]([bi_ubicacion_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Venta]
    ADD CONSTRAINT [FK_BI_Hechos_Venta_bi_venta_tiempo_id] FOREIGN KEY ([bi_venta_tiempo_id])
    REFERENCES [MONSTERS_INC].[BI_Tiempo]([bi_tiempo_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Venta]
    ADD CONSTRAINT [FK_BI_Hechos_Venta_bi_venta_turno_id] FOREIGN KEY ([bi_venta_turno_id])
    REFERENCES [MONSTERS_INC].[BI_Turno]([bi_turno_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Venta]
    ADD CONSTRAINT [FK_BI_Hechos_Venta_bi_venta_caja_tipo_id] FOREIGN KEY ([bi_venta_caja_tipo_id])
    REFERENCES [MONSTERS_INC].[BI_Caja_Tipo]([bi_caja_tipo_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Venta]
    ADD CONSTRAINT [FK_BI_Hechos_Venta_bi_venta_rango_etario_id] FOREIGN KEY ([bi_venta_rango_etario_id])
    REFERENCES [MONSTERS_INC].[BI_Rango_Etario]([bi_rango_etario_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Venta]
    ADD CONSTRAINT [FK_BI_Hechos_Venta_bi_venta_medio_pago_id] FOREIGN KEY ([bi_venta_medio_pago_id])
    REFERENCES [MONSTERS_INC].[BI_Medio_Pago]([bi_medio_pago_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Venta]
    ADD CONSTRAINT [FK_BI_Hechos_Venta_bi_venta_sucursal_id] FOREIGN KEY ([bi_venta_sucursal_id])
    REFERENCES [MONSTERS_INC].[BI_Sucursal]([bi_sucursal_id]);

--

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Envio]
    ADD CONSTRAINT [FK_BI_Hechos_Envio_bi_envio_tiempo_id] FOREIGN KEY ([bi_envio_tiempo_id])
    REFERENCES [MONSTERS_INC].[BI_Tiempo]([bi_tiempo_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Envio]
    ADD CONSTRAINT [FK_BI_Hechos_Envio_bi_envio_sucursal_id] FOREIGN KEY ([bi_envio_sucursal_id])
    REFERENCES [MONSTERS_INC].[BI_Sucursal]([bi_sucursal_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Envio]
    ADD CONSTRAINT [FK_BI_Hechos_Envio_bi_envio_rango_etario_id] FOREIGN KEY ([bi_envio_rango_etario_id])
    REFERENCES [MONSTERS_INC].[BI_Rango_Etario]([bi_rango_etario_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Envio]
    ADD CONSTRAINT [FK_BI_Hechos_Envio_bi_envio_ubicacion_id] FOREIGN KEY ([bi_envio_ubicacion_id])
    REFERENCES [MONSTERS_INC].[BI_Ubicacion]([bi_ubicacion_id]);

--

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Promocion]
    ADD CONSTRAINT [FK_BI_Hechos_Cuota_bi_promo_tiempo_id] FOREIGN KEY ([bi_promo_tiempo_id])
    REFERENCES [MONSTERS_INC].[BI_Tiempo]([bi_tiempo_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Promocion]
    ADD CONSTRAINT [FK_BI_Hechos_Cuota_bi_promo_categoria_id] FOREIGN KEY ([bi_promo_categoria_id])
    REFERENCES [MONSTERS_INC].[BI_Categoria]([bi_categoria_id]);

ALTER TABLE [MONSTERS_INC].[BI_Hechos_Promocion]
    ADD CONSTRAINT [FK_BI_Hechos_Cuota_bi_promo_mp_id] FOREIGN KEY ([bi_promo_mp_id])
    REFERENCES [MONSTERS_INC].[BI_Medio_Pago]([bi_medio_pago_id]);

--

PRINT '--- TABLAS DE DIMENSIONES CREADAS CORRECTAMENTE ---';
GO

/* Funciones para ganar declaratividad y evitar repetir logica */

CREATE FUNCTION [MONSTERS_INC].BI_Resolver_Rango_Etario(@unaFechaDeNacimiento datetime)
RETURNS nvarchar(255)
AS
    BEGIN
        DECLARE @unaEdad AS numeric(6) = Datediff(year, @unaFechaDeNacimiento, GETDATE())

        IF @unaEdad < 25
            RETURN '< 25 anios'
        IF @unaEdad BETWEEN 25 AND 35
            RETURN '25-35 anios'
        IF @unaEdad BETWEEN 35 AND 50
            RETURN '35-50 anios'
        IF @unaEdad > 50
            RETURN '> 50 anios'

        RETURN 'Fuera de Rango Etario'
    END
GO

CREATE FUNCTION [MONSTERS_INC].BI_Resolver_Turno(@unaFechaHora datetime)
RETURNS nvarchar(255)
AS
    BEGIN
        DECLARE @unHorario AS numeric(6) = datepart(hh, @unaFechaHora)

        IF @unHorario BETWEEN 8 AND 12
            RETURN '08:00 - 12:00'
        IF @unHorario BETWEEN 16 AND 16
            RETURN '12:00 - 16:00'
        IF @unHorario BETWEEN 16 AND 20
            RETURN '16:00 - 20:00'

        RETURN 'Fuera de Turno'
    END
GO

CREATE FUNCTION [MONSTERS_INC].BI_Obtener_Id_Rango_Etario(@idPersona numeric(18))
RETURNS numeric(18)
AS
    BEGIN
        DECLARE @idRangoEtario AS numeric(18)
        DECLARE @fechaNacimientoPersona AS datetime

        SELECT 
            @fechaNacimientoPersona = em.empl_fecha_nacimiento
        FROM [MONSTERS_INC].Empleado em
        WHERE em.empl_id = @idPersona

        SELECT 
            @idRangoEtario = re.bi_rango_etario_id
        FROM [MONSTERS_INC].BI_Rango_Etario re
        WHERE [MONSTERS_INC].BI_Resolver_Rango_Etario(@fechaNacimientoPersona) = re.rango_etario_desc

        RETURN @idRangoEtario
    END
GO

CREATE FUNCTION [MONSTERS_INC].BI_Obtener_Id_Rango_Etario_Clie(@idPersona numeric(18))
RETURNS numeric(18)
AS
    BEGIN
        DECLARE @idRangoEtario AS numeric(18)
        DECLARE @fechaNacimientoPersona AS datetime

        SELECT 
            @fechaNacimientoPersona = cl.clie_fecha_nacimiento
        FROM [MONSTERS_INC].Cliente cl
        WHERE cl.clie_id = @idPersona

        SELECT 
            @idRangoEtario = re.bi_rango_etario_id
        FROM [MONSTERS_INC].BI_Rango_Etario re
        WHERE [MONSTERS_INC].BI_Resolver_Rango_Etario(@fechaNacimientoPersona) = re.rango_etario_desc

        RETURN @idRangoEtario
    END
GO

/* --- MIGRACION DE DATOS HACIA MODELO BI ---*/

/* BI_Tiempo */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Tiempo
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Tiempo
    (bi_tiempo_anio, bi_tiempo_cuatrimestre , bi_tiempo_mes)
    SELECT 
        year(t.tick_fecha_hora),
        (  
            CASE
                WHEN MONTH(t.tick_fecha_hora) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(t.tick_fecha_hora) BETWEEN 5 AND 8 THEN 2
                WHEN MONTH(t.tick_fecha_hora) BETWEEN 9 AND 12 THEN 3
            END
        ),
        --datepart(Q, t.tick_fecha_hora),
        month(t.tick_fecha_hora)
    FROM [MONSTERS_INC].Ticket t
    UNION
    SELECT 
        year(e.entr_fecha_hora_entrega),
        (  
            CASE
                WHEN MONTH(e.entr_fecha_hora_entrega) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(e.entr_fecha_hora_entrega) BETWEEN 5 AND 8 THEN 2
                WHEN MONTH(e.entr_fecha_hora_entrega) BETWEEN 9 AND 12 THEN 3
            END
        ),
        month(e.entr_fecha_hora_entrega)
    FROM [MONSTERS_INC].Entrega e
    UNION
    SELECT 
        year(en.envio_fecha),
        (  
            CASE
                WHEN MONTH(en.envio_fecha) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(en.envio_fecha) BETWEEN 5 AND 8 THEN 2
                WHEN MONTH(en.envio_fecha) BETWEEN 9 AND 12 THEN 3
            END
        ),
        month(en.envio_fecha)
    FROM [MONSTERS_INC].Envio en
    UNION
    SELECT 
        year(d.desc_fecha_fin),
        (  
            CASE
                WHEN MONTH(d.desc_fecha_fin) BETWEEN 1 AND 4 THEN 1
                WHEN MONTH(d.desc_fecha_fin) BETWEEN 5 AND 8 THEN 2
                WHEN MONTH(d.desc_fecha_fin) BETWEEN 9 AND 12 THEN 3
            END
        ),
        month(d.desc_fecha_fin)
    FROM [MONSTERS_INC].Descuento_Medio_Pago d
END
GO

/* BI_Ubicacion */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Ubicacion
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Ubicacion
    (provincia_desc, localidad_desc)
    SELECT
        p.prov_nombre,
        l.loca_nombre
    FROM [MONSTERS_INC].Provincia p
        INNER JOIN [MONSTERS_INC].Localidad l ON p.prov_id = l.loca_provincia
END
GO

/* BI_Sucursal */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Sucursal
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Sucursal
    (sucursal_desc)
    SELECT
        s.sucu_numero
    FROM [MONSTERS_INC].Sucursal s
END
GO

/* BI_Rango_Etario */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Rango_Etario
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Rango_Etario
    (rango_etario_desc)
    SELECT
        [MONSTERS_INC].BI_Resolver_Rango_Etario(e.empl_fecha_nacimiento)
    FROM [MONSTERS_INC].Empleado e
    UNION
    SELECT
        [MONSTERS_INC].BI_Resolver_Rango_Etario(c.clie_fecha_nacimiento)
    FROM [MONSTERS_INC].Cliente c
END
GO

--

/* BI_Turno */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Turno
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Turno
    (turno_desc)
    SELECT DISTINCT
        [MONSTERS_INC].BI_Resolver_Turno(t.tick_fecha_hora)
    FROM [MONSTERS_INC].Ticket t
END
GO

/* BI_Categoria */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Categoria
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Categoria
    (subc_descripcion, catm_descripcion)
    SELECT
        c.subc_descripcion,
        cm.catm_descripcion
    FROM [MONSTERS_INC].Subcategoria c
        INNER JOIN [MONSTERS_INC].Categoria_Mayor cm on c.subc_categoria_mayor = cm.catm_id 
END
GO

/* BI_Caja_Tipo */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Caja_Tipo
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Caja_Tipo
    (caja_desc, caja_nro)
    SELECT DISTINCT
        c.caja_tipo,
        c.caja_nro
    FROM [MONSTERS_INC].Caja c
END
GO

/* BI_Medio_Pago */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Medio_Pago
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Medio_Pago
    (medio_pago_tipo, medio_pago_nombre)
    SELECT DISTINCT
        m.medio_pago_tipo,
        m.medio_pago_nombre
    FROM [MONSTERS_INC].Medio_Pago m
END
GO

/* BI_Hechos_Venta */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Hechos_Venta
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Hechos_Venta
    (bi_venta_tiempo_id, bi_venta_turno_id, bi_venta_caja_tipo_id, bi_venta_rango_etario_id, 
    bi_venta_medio_pago_id, bi_venta_ubicacion_id, bi_venta_sucursal_id, venta_prom_total, venta_total_monto, 
    venta_cant_prom_productos, venta_cantidad, venta_total_importe_cuotas, venta_promedio_cuota)     
    select
        (
            SELECT 
                ts.bi_tiempo_id
            FROM [MONSTERS_INC].BI_Tiempo ts
            WHERE year(t.tick_fecha_hora) = ts.bi_tiempo_anio AND 
            ( 
                CASE
                    WHEN MONTH(t.tick_fecha_hora) BETWEEN 1 AND 4 THEN 1
                    WHEN MONTH(t.tick_fecha_hora) BETWEEN 5 AND 8 THEN 2
                    WHEN MONTH(t.tick_fecha_hora) BETWEEN 9 AND 12 THEN 3
                END
            ) = ts.bi_tiempo_cuatrimestre AND month(t.tick_fecha_hora) = ts.bi_tiempo_mes
        ) as TiempoVenta,
        (
            SELECT 
                ts.bi_turno_id
            FROM [MONSTERS_INC].BI_Turno ts
            WHERE [MONSTERS_INC].BI_Resolver_Turno(t.tick_fecha_hora) = ts.turno_desc
        ) as TurnoVenta,
        (
            SELECT 
                ct.bi_caja_tipo_id
            FROM [MONSTERS_INC].Caja cs
                INNER JOIN [MONSTERS_INC].BI_Caja_Tipo ct ON ct.caja_desc = cs.caja_tipo AND ct.caja_nro = cs.caja_nro
            WHERE cs.caja_id = t.tick_caja
        ) as CajaTipoVenta,
        [MONSTERS_INC].BI_Obtener_Id_Rango_Etario(t.tick_empleado) as RangoEtarioEmpleado,
        (
            SELECT
                mpb.bi_medio_pago_id
            FROM [MONSTERS_INC].Medio_Pago m
                INNER JOIN [MONSTERS_INC].BI_Medio_Pago mpb on mpb.medio_pago_nombre = m.medio_pago_nombre 
                    AND mpb.medio_pago_tipo = m.medio_pago_tipo
            WHERE m.medio_pago_id = p.pago_medio_pago
        ) as MedioPagoVenta,
        (
            SELECT TOP 1
                u.bi_ubicacion_id
            FROM [MONSTERS_INC].BI_Ubicacion u
            WHERE u.provincia_desc = pr.prov_nombre AND u.localidad_desc = l.loca_nombre
        ) as UbicacionVenta,
        (
            SELECT 
                sc.bi_sucursal_id
            FROM [MONSTERS_INC].BI_Sucursal sc
            WHERE sc.sucursal_desc = s.sucu_numero
        ) SucursalVenta,
        avg(distinct t.tick_total) as PromedioTotalVenta,
        sum(distinct t.tick_total) as TotalVenta,
        sum(it.item_tick_cantidad) / count(*) as CantidadPromedioProductos,
        count(distinct t.tick_id) as CantidadVentas,
        sum(distinct (
            case 
                when d.deta_tarjeta_cuotas is null then 0
                else t.tick_total
            end
        )) as TotalImporteVentasEnCuotas,
        sum(distinct (
            case 
                when d.deta_tarjeta_cuotas is null then 0
                else t.tick_total / d.deta_tarjeta_cuotas 
            end
        )) / nullif(
            count(distinct case when p.pago_detalle is not null then p.pago_detalle else -1 end) - 1 + sum(distinct case when p.pago_detalle is not null then 1 else 0 end)
            , 0) as ImportePromedioCuota -- No considera filas que no tengan pagos en cuotas, esto evita un warning de ANSI SQL (en terminos de estandar). Es equivalente a nullif(count(distinct p.pago_detalle))
        FROM [MONSTERS_INC].Ticket t
            INNER JOIN [MONSTERS_INC].Item_Ticket it on it.item_tick_ticket = t.tick_id
            INNER JOIN [MONSTERS_INC].Pago p on p.pago_ticket = t.tick_id
            LEFT JOIN [MONSTERS_INC].Detalle_Pago d on d.deta_id = p.pago_detalle
            INNER JOIN [MONSTERS_INC].Caja c on c.caja_id = t.tick_caja
            INNER JOIN [MONSTERS_INC].Sucursal s on s.sucu_id = c.caja_sucursal
            INNER JOIN [MONSTERS_INC].Localidad l on l.loca_id = s.sucu_localidad
            INNER JOIN [MONSTERS_INC].Provincia pr on pr.prov_id = l.loca_provincia
    group by  
        year(t.tick_fecha_hora),
        month(t.tick_fecha_hora),
        [MONSTERS_INC].BI_Resolver_Turno(t.tick_fecha_hora),
        t.tick_caja,
        [MONSTERS_INC].BI_Obtener_Id_Rango_Etario(t.tick_empleado),
        p.pago_medio_pago,
        pr.prov_nombre, l.loca_nombre,
        s.sucu_numero
END
GO

/* BI_Hechos_Envio */
-- Se valida, la tabla queda con menos filas, respecto de Envio del modelo creado anteriormente

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Hechos_Envio
AS
BEGIN
    INSERT INTO [MONSTERS_INC].BI_Hechos_Envio
    (bi_envio_tiempo_id, bi_envio_rango_etario_id, bi_envio_ubicacion_id,
     bi_envio_sucursal_id, bi_envio_cantidad, bi_envio_max_costo, bi_envio_porc_cumpl)
    select 
        (
            SELECT 
                ts.bi_tiempo_id
            FROM [MONSTERS_INC].BI_Tiempo ts
            WHERE year(en.entr_fecha_hora_entrega) = ts.bi_tiempo_anio AND 
            ( 
                CASE
                    WHEN month(en.entr_fecha_hora_entrega) BETWEEN 1 AND 4 THEN 1
                    WHEN month(en.entr_fecha_hora_entrega) BETWEEN 5 AND 8 THEN 2
                    WHEN month(en.entr_fecha_hora_entrega) BETWEEN 9 AND 12 THEN 3
                END
            ) = ts.bi_tiempo_cuatrimestre AND month(en.entr_fecha_hora_entrega) = ts.bi_tiempo_mes
        ) as TiempoEnvio,
        [MONSTERS_INC].BI_Obtener_Id_Rango_Etario_Clie(c.clie_id) as RangoEtarioCliente,
        (        
            SELECT TOP 1
                u.bi_ubicacion_id
            FROM [MONSTERS_INC].BI_Ubicacion u
            WHERE u.provincia_desc = p.prov_nombre AND u.localidad_desc = l.loca_nombre
        ) as UbicacionCliente,
        (
            SELECT 
                sn.bi_sucursal_id
            FROM [MONSTERS_INC].BI_Sucursal sn
            WHERE sn.sucursal_desc = s.sucu_numero
        ) as SucursalEnvio,
        count(distinct e.envio_id) as CantidadEnvios,
        max(e.envio_costo) as EnvioMaximo,
        (SUM(CASE WHEN CAST(en.entr_fecha_hora_entrega AS date) <= CAST(e.envio_fecha AS date) THEN 1 ELSE 0 END) 
        / 
        count(distinct e.envio_id)) * 100 AS PorcentajeCumplimiento
    FROM [MONSTERS_INC].Envio e
        INNER JOIN [MONSTERS_INC].Entrega en on en.entr_id = e.envio_entrega
        INNER JOIN [MONSTERS_INC].Cliente c on c.clie_id = e.envio_cliente
        inner join [MONSTERS_INC].Localidad l on l.loca_id = c.clie_localidad
        inner join [MONSTERS_INC].Provincia p on p.prov_id = l.loca_provincia
        inner join [MONSTERS_INC].Ticket t on t.tick_id = e.envio_ticket
        inner join [MONSTERS_INC].Caja cj on cj.caja_id = t.tick_caja
        inner join [MONSTERS_INC].Sucursal s on s.sucu_id = cj.caja_sucursal
    group by
        year(en.entr_fecha_hora_entrega),
        month(en.entr_fecha_hora_entrega),
        [MONSTERS_INC].BI_Obtener_Id_Rango_Etario_Clie(c.clie_id),
        p.prov_nombre, 
        l.loca_nombre,
        s.sucu_numero
END
GO

/* BI_Hechos_Promocion */

CREATE PROCEDURE [MONSTERS_INC].Migrar_BI_Hechos_Promocion
AS
BEGIN
    INSERT INTO [MONSTERS_INC].[BI_Hechos_Promocion]
    (bi_promo_tiempo_id, bi_promo_categoria_id, bi_promo_mp_id, 
    bi_promo_porc_desc, bi_promo_max_desc, bi_promo_porc_desc_aplicado)
    SELECT
        (
            SELECT 
                ts.bi_tiempo_id
            FROM [MONSTERS_INC].BI_Tiempo ts
            WHERE year(t.tick_fecha_hora) = ts.bi_tiempo_anio AND 
            ( 
                CASE
                    WHEN MONTH(t.tick_fecha_hora) BETWEEN 1 AND 4 THEN 1
                    WHEN MONTH(t.tick_fecha_hora) BETWEEN 5 AND 8 THEN 2
                    WHEN MONTH(t.tick_fecha_hora) BETWEEN 9 AND 12 THEN 3
                END
            ) = ts.bi_tiempo_cuatrimestre AND month(t.tick_fecha_hora) = ts.bi_tiempo_mes
        ) as TiempoPromocion,
        (    
            SELECT 
                c.bi_categoria_id
            FROM [MONSTERS_INC].BI_Categoria c
            WHERE c.catm_descripcion = cm.catm_descripcion and c.subc_descripcion = s.subc_descripcion
        ) as CategoriaProductoEnPromocion,
        (
            SELECT
                mpb.bi_medio_pago_id
            FROM [MONSTERS_INC].Medio_Pago m
                JOIN [MONSTERS_INC].BI_Medio_Pago mpb ON m.medio_pago_nombre = mpb.medio_pago_nombre AND m.medio_pago_tipo = mpb.medio_pago_tipo
            WHERE m.medio_pago_id = pg.pago_medio_pago
        ) as MedioPagoPromocion,
        sum(distinct t.tick_total_descuento + t.tick_total_descuento_mp) / sum(distinct t.tick_total_productos) * 100 as PorcentajeDescAplicado,
        sum(item_tick_descuento_aplicado) as SumDescuentoAplicadoProducto,
        sum(distinct t.tick_total_descuento_mp) / sum(distinct t.tick_total_productos) * 100 as PorcentajeDesc
    FROM [MONSTERS_INC].Ticket t
        INNER JOIN [MONSTERS_INC].Item_Ticket it on it.item_tick_ticket = t.tick_id
        inner join [MONSTERS_INC].Producto p on p.prod_id = it.item_tick_producto
        inner join [MONSTERS_INC].Subcategoria s on s.subc_id = p.prod_subcategoria
        inner join [MONSTERS_INC].Categoria_Mayor cm on s.subc_categoria_mayor = cm.catm_id
        inner join [MONSTERS_INC].Pago pg on pg.pago_ticket = t.tick_id
    group by
        year(t.tick_fecha_hora), month(t.tick_fecha_hora),
        cm.catm_descripcion, s.subc_descripcion,
        pg.pago_medio_pago
END
GO

/* CREACION DE VISTAS */

PRINT '--- CREACION DE VISTAS ---';

-----------------------------------------------------------------------------  1

IF Object_id('MONSTERS_INC.BI_Vista_Ticket_Promedio_Mensual') IS NOT NULL 
  DROP VIEW [MONSTERS_INC].BI_Vista_Ticket_Promedio_Mensual
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Ticket_Promedio_Mensual AS
SELECT
    avg(v.venta_prom_total) as Promedio,
    u.localidad_desc as Localidad,
    t.bi_tiempo_anio AS Anio,
    t.bi_tiempo_mes AS Mes
FROM [MONSTERS_INC].BI_Hechos_Venta v
	JOIN [MONSTERS_INC].BI_Tiempo t ON v.bi_venta_tiempo_id = t.bi_tiempo_id
	JOIN [MONSTERS_INC].BI_Ubicacion u ON v.bi_venta_ubicacion_id = u.bi_ubicacion_id
GROUP BY
    t.bi_tiempo_mes,
    t.bi_tiempo_anio,
    u.localidad_desc
GO

-----------------------------------------------------------------------------  2

IF Object_id('MONSTERS_INC.BI_Vista_Cantidad_Unidades_Promedio') IS NOT NULL 
  DROP VIEW [MONSTERS_INC].BI_Vista_Cantidad_Unidades_Promedio
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Cantidad_Unidades_Promedio AS
SELECT
	avg(v.venta_cant_prom_productos) as Promedio,
	--para cada turno
	tu.turno_desc as Turno,
    --para cada cuatrimestre
	t.bi_tiempo_cuatrimestre as Cuatrimestre,
    --para cada anio
	t.bi_tiempo_anio as Año
FROM [MONSTERS_INC].BI_Hechos_Venta v
	inner join [MONSTERS_INC].BI_Tiempo t on v.bi_venta_tiempo_id = t.bi_tiempo_id
	inner join [MONSTERS_INC].BI_Turno tu on tu.bi_turno_id = v.bi_venta_turno_id
GROUP BY
	tu.turno_desc,
	t.bi_tiempo_cuatrimestre,
	t.bi_tiempo_anio
GO

-----------------------------------------------------------------------------  3

IF Object_id('MONSTERS_INC.BI_Vista_Porcentaje_Anual_Cuatrimestre') IS NOT NULL 
  DROP VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Anual_Cuatrimestre
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Anual_Cuatrimestre AS
SELECT
    r.rango_etario_desc as RangoEtario,
    c.caja_desc as TipoCaja,
    t.bi_tiempo_cuatrimestre as Cuatrimestre,
    t.bi_tiempo_anio as Anio,
    sum(v.venta_cantidad) / (
        select 
            sum(vs.venta_cantidad)
        from [MONSTERS_INC].BI_Hechos_Venta vs
            inner join [MONSTERS_INC].BI_Tiempo ts on vs.bi_venta_tiempo_id = ts.bi_tiempo_id
        where ts.bi_tiempo_anio = t.bi_tiempo_anio
    ) * 100 as Porcentaje
FROM 
    [MONSTERS_INC].BI_Hechos_Venta v
	JOIN [MONSTERS_INC].BI_Tiempo t ON v.bi_venta_tiempo_id = t.bi_tiempo_id
	JOIN [MONSTERS_INC].BI_Caja_Tipo c ON c.bi_caja_tipo_id = v.bi_venta_caja_tipo_id
	JOIN [MONSTERS_INC].BI_Rango_Etario r on r.bi_rango_etario_id = v.bi_venta_rango_etario_id
GROUP BY
    r.rango_etario_desc,
    c.caja_desc,	
    t.bi_tiempo_cuatrimestre,
    t.bi_tiempo_anio
GO

-----------------------------------------------------------------------------  4

IF Object_id('MONSTERS_INC.BI_Vista_Cantidad_Ventas_Por_Turno') IS NOT NULL 
  DROP VIEW [MONSTERS_INC].BI_Vista_Cantidad_Ventas_Por_Turno
GO


CREATE VIEW [MONSTERS_INC].BI_Vista_Cantidad_Ventas_Por_Turno AS
SELECT
    u.localidad_desc as Localidad,
    t.bi_tiempo_mes as Mes,
    t.bi_tiempo_anio as Año,
	tu.turno_desc as Turno,
    sum(v.venta_cantidad) as CantidadProductos
FROM [MONSTERS_INC].BI_Hechos_Venta v
    JOIN [MONSTERS_INC].BI_Tiempo t ON t.bi_tiempo_id = v.bi_venta_tiempo_id
	JOIN [MONSTERS_INC].BI_Turno tu ON tu.bi_turno_id = v.bi_venta_turno_id
    JOIN [MONSTERS_INC].BI_Ubicacion u ON v.bi_venta_ubicacion_id = u.bi_ubicacion_id
GROUP BY
    tu.turno_desc,
	u.localidad_desc,
    t.bi_tiempo_mes,
    t.bi_tiempo_anio
GO

-----------------------------------------------------------------------------  5

IF Object_id('MONSTERS_INC.BI_Vista_Porcentaje_Descuento_aplicado') IS NOT NULL 
  DROP VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Descuento_aplicado
    GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Descuento_aplicado AS
SELECT
	t.bi_tiempo_anio as Año,
	t.bi_tiempo_mes as Mes,
    sum(p.bi_promo_porc_desc) / count(*) as Porcentaje 
FROM [MONSTERS_INC].BI_Hechos_Promocion p
	JOIN [MONSTERS_INC].BI_Tiempo t on t.bi_tiempo_id = p.bi_promo_tiempo_id
GROUP BY
	t.bi_tiempo_anio,
	t.bi_tiempo_mes
GO

-----------------------------------------------------------------------------  6

IF Object_id('MONSTERS_INC.BI_Vista_Top_3_Categorias_Descuento') IS NOT NULL
  DROP VIEW [MONSTERS_INC].BI_Vista_Top_3_Categorias_Descuento
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Top_3_Categorias_Descuento AS
    WITH DescuentosPorCategoria AS (
        SELECT
            t.bi_tiempo_anio AS Anio,
            t.bi_tiempo_cuatrimestre AS Cuatrimestre,
            c.catm_descripcion AS Categoria,
            MAX(p.bi_promo_max_desc) AS SumatoriaDescuentosAplicados,
            ROW_NUMBER() OVER (PARTITION BY t.bi_tiempo_anio, t.bi_tiempo_cuatrimestre ORDER BY max(p.bi_promo_max_desc) DESC) AS NumeroFila
        FROM [MONSTERS_INC].BI_Hechos_Promocion p
        INNER JOIN [MONSTERS_INC].BI_Tiempo t ON t.bi_tiempo_id = p.bi_promo_tiempo_id
        INNER JOIN [MONSTERS_INC].BI_Categoria c ON c.bi_categoria_id = p.bi_promo_categoria_id
        GROUP BY
            t.bi_tiempo_anio,
            t.bi_tiempo_cuatrimestre,
            c.catm_descripcion
    )
    SELECT
        Anio,
        Cuatrimestre,
        Categoria,
        SumatoriaDescuentosAplicados
    FROM DescuentosPorCategoria
    WHERE NumeroFila <= 3
GO

-----------------------------------------------------------------------------  7

IF Object_id('MONSTERS_INC.BI_Vista_Porcentaje_Cumplimiento_Envios') IS NOT NULL
  DROP VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Cumplimiento_Envios
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Cumplimiento_Envios AS
SELECT
    s.bi_sucursal_id AS Sucursal,
    t.bi_tiempo_anio AS Año,
    t.bi_tiempo_mes AS Mes,
	sum(e.bi_envio_porc_cumpl) / count(*) AS PorcentajeCumplimiento
FROM [MONSTERS_INC].BI_Hechos_Envio e
    JOIN [MONSTERS_INC].BI_Tiempo t ON t.bi_tiempo_id = e.bi_envio_tiempo_id
    JOIN [MONSTERS_INC].BI_Sucursal s ON e.bi_envio_sucursal_id = s.bi_sucursal_id
GROUP BY s.bi_sucursal_id, t.bi_tiempo_anio, t.bi_tiempo_mes;
GO

-----------------------------------------------------------------------------  8

IF Object_id('MONSTERS_INC.BI_Vista_Cantidad_Envios_Rango_Etario_Cliente') IS NOT NULL
  DROP VIEW [MONSTERS_INC].BI_Vista_Cantidad_Envios_Rango_Etario_Cliente
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Cantidad_Envios_Rango_Etario_Cliente AS
SELECT
    r.rango_etario_desc as RangoEtario, 
    t.bi_tiempo_cuatrimestre as Cuatrimeste,
    t.bi_tiempo_anio as Año,
    count(e.bi_envio_cantidad) as CantidadEnvios
FROM [MONSTERS_INC].BI_Hechos_Envio e
    JOIN [MONSTERS_INC].BI_Tiempo t ON t.bi_tiempo_id = e.bi_envio_tiempo_id 
	JOIN [MONSTERS_INC].BI_Rango_Etario r ON r.bi_rango_etario_id = e.bi_envio_rango_etario_id
GROUP BY
    r.rango_etario_desc,
    t.bi_tiempo_cuatrimestre,
    t.bi_tiempo_anio;
GO

-----------------------------------------------------------------------------  9

IF Object_id('MONSTERS_INC.BI_Vista_Top_5_Localidades_Mayor_Costo_Envio') IS NOT NULL
  DROP VIEW [MONSTERS_INC].BI_Vista_Top_5_Localidades_Mayor_Costo_Envio
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Top_5_Localidades_Mayor_Costo_Envio AS
SELECT TOP 5
    u.localidad_desc as Localidad,
    max(e.bi_envio_max_costo) as CostoEnvio
FROM [MONSTERS_INC].BI_Hechos_Envio e
	JOIN [MONSTERS_INC].BI_Ubicacion u on u.bi_ubicacion_id = e.bi_envio_ubicacion_id
GROUP BY
	u.localidad_desc
ORDER BY 2 desc
GO

-----------------------------------------------------------------------------  10

IF Object_id('MONSTERS_INC.BI_Vista_Top_3_Sucursales_Importe_Cuotas') IS NOT NULL
  DROP VIEW [MONSTERS_INC].BI_Vista_Top_3_Sucursales_Importe_Cuotas
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Top_3_Sucursales_Importe_Cuotas AS
SELECT top 3
    s.bi_sucursal_id as Sucursal,
    mp.medio_pago_nombre as MedioDePago,
    t.bi_tiempo_anio as Anio,
    t.bi_tiempo_mes as Mes,
    v.venta_total_importe_cuotas as ImporteCuota
FROM [MONSTERS_INC].BI_Hechos_Venta v
    JOIN [MONSTERS_INC].BI_Tiempo t ON t.bi_tiempo_id = v.bi_venta_tiempo_id
	join [MONSTERS_INC].BI_Sucursal s on v.bi_venta_sucursal_id = s.bi_sucursal_id
    join [MONSTERS_INC].BI_Medio_Pago mp on mp.bi_medio_pago_id = v.bi_venta_medio_pago_id 
GROUP BY
    s.bi_sucursal_id,
	t.bi_tiempo_anio,
    t.bi_tiempo_mes,
    mp.medio_pago_nombre,
    v.venta_total_importe_cuotas
ORDER BY
    v.venta_total_importe_cuotas desc
GO

-----------------------------------------------------------------------------  11

IF Object_id('MONSTERS_INC.BI_Vista_Promedio_Importe_Cuota_RangoEtario') IS NOT NULL
  DROP VIEW [MONSTERS_INC].BI_Vista_Promedio_Importe_Cuota_RangoEtario
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Promedio_Importe_Cuota_RangoEtario AS
SELECT
    re.rango_etario_desc AS RangoEtario,
    sum(isnull(v.venta_promedio_cuota,0)) / sum(
        case when v.venta_promedio_cuota is not null then 1 else 0 end
    ) AS PromedioImporteCuota  -- Evita warning de ANSI SQL, equivalente a avg(v.venta_promedio_cuota)
FROM [MONSTERS_INC].BI_Hechos_Venta v
    INNER JOIN [MONSTERS_INC].BI_Rango_Etario re ON re.bi_rango_etario_id = v.bi_venta_rango_etario_id
GROUP BY
    re.rango_etario_desc
GO

-----------------------------------------------------------------------------  12

IF Object_id('MONSTERS_INC.BI_Vista_Porcentaje_Descuento_Por_Medio_Pago') IS NOT NULL
  DROP VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Descuento_Por_Medio_Pago
GO

CREATE VIEW [MONSTERS_INC].BI_Vista_Porcentaje_Descuento_Por_Medio_Pago AS
SELECT
    m.medio_pago_nombre as MedioPago,
    t.bi_tiempo_anio as Año,
    t.bi_tiempo_cuatrimestre as Cuatrimestre,
    sum(p.bi_promo_porc_desc_aplicado) / count(*) as Porcentaje
FROM [MONSTERS_INC].BI_Hechos_Promocion p
    JOIN [MONSTERS_INC].BI_Tiempo t ON t.bi_tiempo_id = p.bi_promo_tiempo_id
	join [MONSTERS_INC].BI_Medio_Pago m on p.bi_promo_mp_id = m.bi_medio_pago_id
GROUP BY
    m.medio_pago_nombre,
    t.bi_tiempo_anio,
    t.bi_tiempo_cuatrimestre
GO

-----------------------------------------------------------------------------  

PRINT '--- COMENZANDO LA MIGRACION DE DATOS BI ---'

/* EJECUTAR PROCEDURES MIGRACION BI */

EXEC [MONSTERS_INC].Migrar_BI_Tiempo
EXEC [MONSTERS_INC].Migrar_BI_Ubicacion
EXEC [MONSTERS_INC].Migrar_BI_Categoria
EXEC [MONSTERS_INC].Migrar_BI_Sucursal
EXEC [MONSTERS_INC].Migrar_BI_Rango_Etario
EXEC [MONSTERS_INC].Migrar_BI_Turno
EXEC [MONSTERS_INC].Migrar_BI_Caja_Tipo
EXEC [MONSTERS_INC].Migrar_BI_Medio_Pago
EXEC [MONSTERS_INC].Migrar_BI_Hechos_Venta
EXEC [MONSTERS_INC].Migrar_BI_Hechos_Envio
EXEC [MONSTERS_INC].Migrar_BI_Hechos_Promocion

PRINT '--- MIGRACION REALIZADA ---';

-- Referencia a vistas con fines de prueba

/*

select * from [MONSTERS_INC].BI_Vista_Ticket_Promedio_Mensual
select * from [MONSTERS_INC].BI_Vista_Cantidad_Unidades_Promedio
select * from [MONSTERS_INC].BI_Vista_Porcentaje_Anual_Cuatrimestre

select * from [MONSTERS_INC].BI_Vista_Cantidad_Ventas_Por_Turno
select * from [MONSTERS_INC].BI_Vista_Porcentaje_Descuento_aplicado
select * from [MONSTERS_INC].BI_Vista_Top_3_Categorias_Descuento

select * from [MONSTERS_INC].BI_Vista_Porcentaje_Cumplimiento_Envios
select * from [MONSTERS_INC].BI_Vista_Cantidad_Envios_Rango_Etario_Cliente
select * from [MONSTERS_INC].BI_Vista_Top_5_Localidades_Mayor_Costo_Envio

select * from [MONSTERS_INC].BI_Vista_Top_3_Sucursales_Importe_Cuotas
select * from [MONSTERS_INC].BI_Vista_Promedio_Importe_Cuota_RangoEtario
select * from [MONSTERS_INC].BI_Vista_Porcentaje_Descuento_Por_Medio_Pago

*/
