/* =========================================================
   DUOC UC – Consultas unificadas para entrega
   Alumno: Cristian Olivares Sandia
   Esquema: PRY2205_S2
   Fecha: 10-11-2025
   ========================================================= */

/* Uniformar formato fecha en la sesión */
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';

/* =========================
   CONFIGURACIÓN DE FORMATEO
   ========================= */
SET LINESIZE 200
SET PAGESIZE 50

/* Formato para Caso 1 */
COL "RUT Cliente" FORMAT A12
COL "Nombre Completo Cliente" FORMAT A40
COL "Dirección Cliente" FORMAT A35
COL "Renta Cliente" FORMAT A15
COL "Celular Cliente" FORMAT A12
COL "Tramo Renta Cliente" FORMAT A8

/* Formato para Caso 2 */
COL "codigo_categoria" FORMAT 99
COL "Categoría Empleado" FORMAT A25
COL "Sucursal" FORMAT A30
COL "Cantidad Empleados" FORMAT 999
COL "Sueldo Promedio" FORMAT A15

/* Formato para Caso 3 */
COL "codigo_tipo" FORMAT A1
COL "Tipo Propiedad" FORMAT A20
COL "Total Propiedades" FORMAT 999
COL "Arriendo Promedio" FORMAT A15
COL "Superficie Promedio m2" FORMAT A20
COL "Valor Arriendo m2" FORMAT A15
COL "Categoría Valor m2" FORMAT A15

/* =========================
   VARIABLES DE SUSTITUCIÓN
   ========================= */

/* =========================================================
   CASO 1: Listado de Clientes con Rango de Renta (Figura 2)
   - Mostrar solo clientes entre rango de renta (variables)
   - RUT con puntos y guion
   - Solo clientes con número de celular
   - Clasificación por tramos de renta
   - Orden por nombre completo ascendente
   ========================================================= */
PROMPT ========================================================
PROMPT CASO 1: Listado de Clientes con Rango de Renta
PROMPT ========================================================
PROMPT Ingrese el rango de renta a consultar:
ACCEPT RENTA_MINIMA NUMBER PROMPT 'Renta mínima: '
ACCEPT RENTA_MAXIMA NUMBER PROMPT 'Renta máxima: '
PROMPT

SELECT
    REGEXP_REPLACE(NUMRUT_CLI || DVRUT_CLI, '(\d{1,2})(\d{3})(\d{3})(\w{1})', '\1.\2.\3-\4') AS "RUT Cliente",
    INITCAP(NOMBRE_CLI) || ' ' || INITCAP(APPATERNO_CLI) || ' ' || INITCAP(APMATERNO_CLI) AS "Nombre Completo Cliente",
    DIRECCION_CLI AS "Dirección Cliente",
    TO_CHAR(RENTA_CLI, 'FM$999G999G999') AS "Renta Cliente",
    '56-' || SUBSTR(TO_CHAR(CELULAR_CLI), 1, 1) || '-' || SUBSTR(TO_CHAR(CELULAR_CLI), 2) AS "Celular Cliente",
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
   - Clasificar por categoría y sucursal
   - Calcular promedio de sueldo formateado
   - Filtrar por sueldo promedio mínimo (variable)
   - Orden por sueldo promedio descendente
   ========================================================= */
PROMPT
PROMPT ========================================================
PROMPT CASO 2: Sueldo Promedio por Categoría de Empleado
PROMPT ========================================================
ACCEPT SUELDO_PROMEDIO_MINIMO NUMBER PROMPT 'Sueldo promedio mínimo: '
PROMPT

SELECT
    ID_CATEGORIA_EMP AS "codigo_categoria",
    CASE ID_CATEGORIA_EMP 
        WHEN 1 THEN 'Gerente'
        WHEN 2 THEN 'Supervisor'
        WHEN 3 THEN 'Ejecutivo de Arriendo'
        WHEN 4 THEN 'Auxiliar'
        ELSE 'Otra Categoría'
    END AS "Categoría Empleado",
    CASE ID_SUCURSAL
        WHEN 10 THEN 'Sucursal Las Condes'
        WHEN 20 THEN 'Sucursal Santiago Centro'
        WHEN 30 THEN 'Sucursal Providencia'
        WHEN 40 THEN 'Sucursal Vitacura'
        ELSE 'Otra Sucursal'
    END AS "Sucursal",
    COUNT(*) AS "Cantidad Empleados",
    TO_CHAR(ROUND(AVG(SUELDO_EMP), 0), 'FM$999G999G999') AS "Sueldo Promedio"
FROM EMPLEADO 
GROUP BY ID_CATEGORIA_EMP, ID_SUCURSAL
HAVING AVG(SUELDO_EMP) >= &SUELDO_PROMEDIO_MINIMO
ORDER BY AVG(SUELDO_EMP) DESC;

/

/* =========================================================
   CASO 3: Arriendo Promedio por Tipo de Propiedad (Figura 4)
   - Agrupar por tipo de propiedad
   - Calcular total propiedades, promedio arriendo y superficie
   - Calcular razón arriendo por m2
   - Clasificar por valor arriendo por m2
   - Filtrar promedio arriendo por m2 > 1000
   - Orden por valor arriendo por m2 descendente
   ========================================================= */
PROMPT
PROMPT ========================================================
PROMPT CASO 3: Arriendo Promedio por Tipo de Propiedad
PROMPT ========================================================
PROMPT

SELECT
    ID_TIPO_PROPIEDAD AS "codigo_tipo",
    CASE ID_TIPO_PROPIEDAD
        WHEN 'A' THEN 'CASA'
        WHEN 'B' THEN 'DEPARTAMENTO'
        WHEN 'C' THEN 'LOCAL'
        WHEN 'D' THEN 'PARCELA SIN CASA'
        WHEN 'E' THEN 'PARCELA CON CASA'
        ELSE 'OTRO TIPO'
    END AS "Tipo Propiedad",
    COUNT(*) AS "Total Propiedades",
    TO_CHAR(ROUND(AVG(VALOR_ARRIENDO), 0), 'FM$999G999G999') AS "Arriendo Promedio",
    TO_CHAR(ROUND(AVG(SUPERFICIE), 0), 'FM999G990') AS "Superficie Promedio m2",
    TO_CHAR(ROUND(AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)), 0), 'FM999G990') AS "Valor Arriendo m2",
    CASE
        WHEN ROUND(AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)), 0) < 5000 THEN 'Económico'
        WHEN ROUND(AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)), 0) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoría Valor m2"
FROM PROPIEDAD 
GROUP BY ID_TIPO_PROPIEDAD
HAVING AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)) > 1000
ORDER BY AVG(VALOR_ARRIENDO / NULLIF(SUPERFICIE, 0)) DESC;

/

/* =========================
   RESTAURAR CONFIGURACIÓN
   ========================= */
PROMPT
PROMPT ========================================================
PROMPT Consultas ejecutadas exitosamente
PROMPT ========================================================

CLEAR COLUMNS
SET LINESIZE 80
SET PAGESIZE 14