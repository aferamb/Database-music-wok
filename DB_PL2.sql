\pset pager off

SET client_encoding = 'UTF8';

/*
 * Buscar en la documentación oficial de PostgreSQL:
 * REGEXP_MATCHES_TO_TABLE
 * RPLACE
 * REGEXP_REPLACE
 * MAKE_INTERVAL
 * 
 */

BEGIN;
\echo 'creando el esquema para la BBDD de películas'


\echo 'creando un esquema temporal'


SET search_path='nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'


\echo 'insertando datos en el esquema final'

\echo 'Consulta 1: texto de la consulta'

\echo 'Consulta n':


ROLLBACK;                       -- importante! permite correr el script multiples veces...p