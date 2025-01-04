-- Crear el usuario administrador
CREATE USER admin WITH PASSWORD 'password_admin'; 
CREATE ROLE admin NOLOGIN;
GRANT ALL PRIVILEGES ON DATABASE intercambio_discos TO admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO admin;
GRANT CREATE ON SCHEMA public TO admin;

-- Crear el usuario gestor y otorgar permisos para manipular los datos, pero no para modificar la estructura
CREATE USER gestor WITH PASSWORD 'password_gestor';
CREATE ROLE gestor NOLOGIN;
REVOKE ALL PRIVILEGES ON DATABASE intercambio_discos FROM gestor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gestor;
-- Asegurarse de que el usuario pueda interactuar con las tablas futuras también
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO gestor;

-- Crear el usuario cliente y otorgar permisos de consulta e inserción solo en las tablas específicas
CREATE USER gumersindo WITH PASSWORD 'reconocer';
CREATE ROLE gumersindo NOLOGIN;
REVOKE ALL PRIVILEGES ON DATABASE intercambio_discos FROM gumersindo;
GRANT SELECT, INSERT ON Tiene TO gumersindo;
GRANT SELECT, INSERT ON Desea TO gumersindo;

-- Crear el usuario invitado y otorgar permisos de solo lectura (consulta) sobre las tablas específicas
CREATE USER invitado WITH PASSWORD 'password_invitado';
CREATE ROLE invitado NOLOGIN;
REVOKE ALL PRIVILEGES ON DATABASE intercambio_discos FROM invitado;
GRANT SELECT ON Grupo, Disco, Canciones TO invitado;


