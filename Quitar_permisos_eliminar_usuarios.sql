REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM admin; 
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM gestor;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM cliente;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM invitado;

REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM admin;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM gestor;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM cliente; 
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM invitado;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM admin;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM gestor;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM cliente; 
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM invitado;

REVOKE ALL PRIVILEGES ON DATABASE intercambio_discos FROM admin;
REVOKE ALL PRIVILEGES ON DATABASE intercambio_discos FROM gestor;
REVOKE ALL PRIVILEGES ON DATABASE intercambio_discos FROM cliente; 
REVOKE ALL PRIVILEGES ON DATABASE intercambio_discos FROM invitado;

REVOKE ALL PRIVILEGES ON SCHEMA public FROM admin;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM gestor;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM cliente; 
REVOKE ALL PRIVILEGES ON SCHEMA public FROM invitado;

DROP USER IF EXISTS admin;
DROP USER IF EXISTS gestor;
DROP USER IF EXISTS cliente; 
DROP USER IF EXISTS invitado;


-- Si alguno da por saco y no se puede borrar, se puede hacer esto:
-- -Comprueba qué dependencias tiene el usuario con la base de datos
-- -Si de verdad quieres borrarlo, borra las dependencias con un delete en estas queries, y luego borra el usuario
-- !!! OJO, NO HACER ESTO EN PRODUCCIÓN, PUEDE ROMPER COSAS !!!
-- !!! HACERLO EN UNA COPIA DE LA BASE DE DATOS !!!
SELECT * FROM pg_shdepend WHERE refobjid = (SELECT oid FROM pg_roles WHERE rolname = 'admin');
SELECT * FROM pg_roles r JOIN pg_shdepend d ON r.oid = d.refobjid JOIN pg_database db ON d.dbid = db.oid WHERE r.rolname = 'admin';