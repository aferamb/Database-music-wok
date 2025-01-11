--Crear los usuatios
CREATE USER admin WITH PASSWORD 'admin';
CREATE USER gestor WITH PASSWORD 'gestor';
CREATE USER cliente WITH PASSWORD 'cliente';
CREATE USER invitado WITH PASSWORD 'invitado';

--Crear los roles
CREATE ROLE adminRole NOLOGIN;
CREATE ROLE gestorRole NOLOGIN;
CREATE ROLE clienteRole NOLOGIN;
CREATE ROLE invitadoRole NOLOGIN;

--Asignar roles
GRANT adminRole TO admin;
GRANT gestorRole TO gestor;
GRANT clienteRole TO cliente;
GRANT invitadoRole TO invitado;

--Asignar los permisos a los roles
--Admin
GRANT ALL PRIVILEGES ON DATABASE intercambio_discos TO adminRole;
GRANT USAGE, CREATE ON SCHEMA public TO adminRole;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO adminRole;

--Gestor, otorgar permisos para manipular los datos, pero no para modificar la estructura
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gestorRole;

-- Asegurarse de que el usuario pueda interactuar con las tablas futuras también
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO gestor;

--Cliente
GRANT SELECT, INSERT ON TABLE Tiene, Desea TO clienteRole;

--Cliente invitado
GRANT SELECT ON TABLE Grupo, Disco, Canciones TO invitadoRole;



