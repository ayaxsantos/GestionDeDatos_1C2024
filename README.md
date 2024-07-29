# TP Gestion de Datos - 1° Cuatrimestre 2024

Grupo: MONSTERS_INC

## Introduccion:

En el presente TP, se intenta realizar una simulacion de implementacion de un sistema para una cadena de supermercados. Este permite gestionar las ventas, promociones y envíos en las sucursales físicas.

La implementacion de dicho sistema, requiere que los datos persistidos hasta el momento sean migrados respetando un nuevo modelo. Por tal motivo, resulta necesario realizar un rediseño de la base de datos y los distintos procesos existentes, adecuandose a los nuevos requerimientos.

Una vez realizado esto se necesita ademas generar otro modelo, para consumir desde el nuevo sistema y asi poder generar metricas de gestion y analisis, que permitan en un futuro la toma de decisiones por parte del negocio.

## Despliegue:

Para su ejecucion, se debe disponer de los datos originales provistos, con el modelo previo conteniendo los datos en una tabla maestra sin ningun tipo de normalizacion.

Previamente, se debe crear un esquema nombrado "MONSTERS_INC". Puede hacerse con la siguiente sentencia SQL:

```sql:
    CREATE SCHEMA MONSTERS_INC
```

Luego, se deben ejecutar los scripts provistos en el siguiente orden:

- script_creacion_inicial.sql
- script_creacion_BI.sql

Finalmente, se pueden ejecutar los SELECTs que se encuentran al final del ultimo script mencionados, para
ejecutar las vistas del modelo BI.
