/* =========================================================
   DUOC UC – Consultas unificadas para entrega
   Alumnos: Cristian Olivares Sandia
   Esquema: PRY2205_S2
   Fecha: 02-11-2025
   ========================================================= */

/* Uniformar formato fecha en la sesión */
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';

/* =========================
   CONFIGURACIÓN DE FORMATEO
   ========================= */
SET LINESIZE 200
SET PAGESIZE 50

/* Formato para Caso 1 */
COL "RUT Cliente" FORMAT A15
COL "Nombre Completo Cliente" FORMAT A40
COL "Dirección Cliente" FORMAT A35
COL "Renta Cliente" FORMAT A13
COL "Celular Cliente" FORMAT A12
COL "Tramo Renta Cliente" FORMAT A6

/* Formato para Caso 2 */
COL "codigo_categoria" FORMAT 99
COL "descripcion_categoria" FORMAT A25
COL "cantidad_empleados" FORMAT 999
COL "sucursal" FORMAT A30
COL "sueldo_promedio" FORMAT A15

/* Formato para Caso 3 */
COL "codigo_tipo" FORMAT A1
COL "descripcion_tipo" FORMAT A20
COL "total_propiedades" FORMAT 999
COL "promedio_Arriendo" FORMAT A15
COL "promedio_superficie" FORMAT A10
COL "valor_arriendo_m2" FORMAT A15
COL "clasificacion" FORMAT A20

/* =========================
   VARIABLES DE SUSTITUCIÓN
   ========================= */

/* =========================================================
   CASO 1: Listado de Clientes con Rango de Renta (Figura 2)
   ========================================================= */
PROMPT --- CASO 1: Listado de Clientes con Rango de Renta ---
PROMPT Ingrese el rango de renta a consultar:
ACCEPT RENTA_MINIMA NUMBER PROMPT 'Renta mínima: '
ACCEPT RENTA_MAXIMA NUMBER PROMPT 'Renta máxima: '

SELECT
    REGEXP_REPLACE(NUMRUT_CLI || DVRUT_CLI, '(\d{1,2})(\d{3})(\d{3})(\w{1})', '\1.\2.\3-\4') AS "RUT Cliente",
    INITCAP(NOMBRE_CLI) || ' ' || INITCAP(APPATERNO_CLI) || ' ' || INITCAP(APMATERNO_CLI) AS "Nombre Completo Cliente",
    DIRECCION_CLI AS "Dirección Cliente",
    TO_CHAR(RENTA_CLI, 'FM$999G999G999') AS "Renta Cliente",
    TO_CHAR(CELULAR_CLI, 'FM9G999G9999') AS "Celular Cliente",
    CASE
        WHEN RENTA_CLI > 500000 THEN 'TRAMO 1'
        WHEN RENTA_CLI BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN RENTA_CLI BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        ELSE 'TRAMO 4'
    END AS "Tramo Renta Cliente"
FROM CLIENTE 
WHERE RENTA_CLI BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA
    AND CELULAR_CLI IS NOT NULL
ORDER BY "Nombre Completo Cliente" ASC;

/

/* =========================================================
   CASO 2: Sueldo Promedio por Categoría de Empleado (Figura 3)
   ========================================================= */
PROMPT --- CASO 2: Sueldo Promedio por Categoría de Empleado ---
ACCEPT SUELDO_PROMEDIO_MINIMO NUMBER PROMPT 'Sueldo promedio mínimo: '

SELECT
    ID_CATEGORIA_EMP AS "codigo_categoria",
    CASE ID_CATEGORIA_EMP 
        WHEN 1 THEN 'Gerente'
        WHEN 2 THEN 'Supervisor'
        WHEN 3 THEN 'Ejecutivo de Arriendo'
        WHEN 4 THEN 'Auxiliar'
        ELSE 'Sin Categoría'
    END AS "descripcion_categoria",
    COUNT(*) AS "cantidad_empleados",
    CASE ID_SUCURSAL
        WHEN 10 THEN 'Sucursal Las Condes'
        WHEN 20 THEN 'Sucursal Santiago Centro'
        WHEN 30 THEN 'Sucursal Providencia'
        WHEN 40 THEN 'Sucursal Vitacura'
        ELSE 'Otra Sucursal'
    END AS "sucursal",
    TO_CHAR(ROUND(AVG(SUELDO_EMP), 0), 'FM$999G999G999') AS "sueldo_promedio"
FROM EMPLEADO 
GROUP BY ID_CATEGORIA_EMP, ID_SUCURSAL
HAVING AVG(SUELDO_EMP) >= &SUELDO_PROMEDIO_MINIMO
ORDER BY AVG(SUELDO_EMP) DESC;

/

/* =========================================================
   CASO 3: Arriendo Promedio por Tipo de Propiedad (Figura 4)
   ========================================================= */
PROMPT --- CASO 3: Arriendo Promedio por Tipo de Propiedad ---

SELECT
    ID_TIPO_PROPIEDAD AS "codigo_tipo",
    CASE ID_TIPO_PROPIEDAD
        WHEN 'A' THEN 'CASA'
        WHEN 'B' THEN 'DEPARTAMENTO'
        WHEN 'C' THEN 'LOCAL'
        WHEN 'D' THEN 'PARCELA SIN CASA'
        WHEN 'E' THEN 'PARCELA CON CASA'
        ELSE 'OTRO TIPO'
    END AS "descripcion_tipo",
    COUNT(*) AS "total_propiedades",
    TO_CHAR(ROUND(AVG(VALOR_ARRIENDO), 0), 'FM$999G999G999') AS "promedio_Arriendo",
    TO_CHAR(ROUND(AVG(SUPERFICIE), 0), 'FM999G990') AS "promedio_superficie",
    TO_CHAR(ROUND(AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)), 0), 'FM999G990') AS "valor_arriendo_m2",
    CASE
        WHEN ROUND(AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)), 0) < 5000 THEN 'Económico'
        WHEN ROUND(AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)), 0) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Alto'
    END AS "clasificacion"
FROM PROPIEDAD 
GROUP BY ID_TIPO_PROPIEDAD
HAVING AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)) > 1000
ORDER BY AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)) DESC;

/

/* =========================
   RESTAURAR CONFIGURACIÓN
   ========================= */
CLEAR COLUMNS
SET LINESIZE 80
SET PAGESIZE 14