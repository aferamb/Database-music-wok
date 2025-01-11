--Crear los usuatios
CREATE USER admin WITH PASSWORD 'admin';
CREATE USER gestor WITH PASSWORD 'gestor';
CREATE USER cliente WITH PASSWORD 'cliente';
CREATE USER invitado WITH PASSWORD 'invitado';

--Crear los roles
CREATE ROLE admin NOLOGIN;
CREATE ROLE gestor NOLOGIN;
CREATE ROLE cliente NOLOGIN;
CREATE ROLE invitado NOLOGIN;

--Asignar los permisos a los roles
--Admin
GRANT ALL PRIVILEGES ON DATABASE intercambio_discos TO admin;
GRANT USAGE, CREATE ON SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

--Gestor, otorgar permisos para manipular los datos, pero no para modificar la estructura
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gestor;

-- Asegurarse de que el usuario pueda interactuar con las tablas futuras también
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO gestor;

--Cliente
GRANT SELECT, INSERT ON TABLE Tiene, Desea TO cliente;

--Cliente invitado
GRANT SELECT ON TABLE Grupo, Disco, Canciones TO invitado;



