SET client_encoding TO 'UTF8';
SET search_path TO public;


-- Prueba de usuario admin
\echo ''
\echo '---------------------Establecemos el usuario Admin---------------------' 
SET ROLE adminRole;


\echo 'Hacemos consulta' 
SELECT * FROM Usuario WHERE Nombre_user = 'analópez';

\echo 'Insercion en la tabla Usuario'
INSERT INTO Usuario (Nombre_user, Nombre, Email, Contrasena) VALUES ('prueba', 'prueba', 'prueba@email.com', 'reconocer');

\echo 'Modificamos datos de la tabla Usuario'
UPDATE Usuario SET Contrasena = 'nueva_contraseña' WHERE nombre = 'prueba';

\echo 'Borrado en la tabla Usuario'
DELETE FROM Usuario WHERE Nombre_user = 'prueba';

\echo 'Creacion de una nueva tabla'
CREATE TABLE prueba_admin (id SERIAL, CONSTRAINT pk_prueba PRIMARY KEY (id));

\echo 'Borrado de la nueva tabla' 
DROP TABLE prueba_admin;  

RESET ROLE;


-- Prueba de usuario gestor
\echo ''
\echo '---------------------Establecemos el usuario Gestor---------------------' 
SET ROLE gestorRole;


\echo 'Hacemos consulta' 
SELECT * FROM Usuario WHERE Nombre_user = 'analópez';

\echo 'Insercion en la tabla Usuario'
INSERT INTO Usuario (Nombre_user, Nombre, Email, Contrasena) VALUES ('prueba', 'prueba', 'prueba@email.com', 'reconocer');

\echo 'Modificamos datos de la tabla Usuario'
UPDATE Usuario SET Contrasena = 'nueva_contraseña' WHERE nombre = 'prueba';

\echo 'Borrado en la tabla Usuario'
DELETE FROM Usuario WHERE Nombre_user = 'prueba';

\echo 'Intentamos crear una tabla (da error ya que no tiene permisos)'
CREATE TABLE prueba_admin (id SERIAL, CONSTRAINT pk_prueba PRIMARY KEY (id));

RESET ROLE;


-- Prueba de usuario cliente
\echo ''
\echo '---------------------Establecemos el usuario cliente---------------------' 
SET ROLE clienteRole;


\echo 'Hacemos consulta en la tabla Tiene'
SELECT titulo_disco FROM Tiene WHERE Ano_publicacion = '2007' AND Pais = 'Germany'  ;

\echo 'Insertamos en la tabla Desea' 
INSERT INTO Desea(Titulo_disco,Ano_publicacion,Nombre_user) VALUES('Ivy', 1991, 'juangomez');

\echo 'Intentamos seleccionar de otra tabla (da error ya que no tiene permisos)'
SELECT * FROM Generos; 

\echo 'Intentamos crear una tabla (da error ya que no tiene permisos)'
CREATE TABLE prueba_admin (id SERIAL, CONSTRAINT pk_prueba PRIMARY KEY (id));

RESET ROLE;


-- Prueba de usuario invitado
\echo ''
\echo '---------------------Establecemos el usuario Invitado---------------------'
SET ROLE invitadoRole;


\echo 'Hacemos consulta en la tabla disco'
SELECT Titulo, Ano_publicacion FROM Disco WHERE Ano_publicacion = '2005' AND Nombre_grupo = 'Andrea Berg';

\echo 'Hacemos consulta en la tabla Cancion'
SELECT Titulo_disco FROM Canciones WHERE Titulo_cancion = 'The Cave' ;

\echo 'Intentamos seleccionar de la tabla Tiene (da error al no tener permiso)'
SELECT * FROM Tiene WHERE Ano_publicacion = '2005'  ;

\echo 'Intentamos insertar en la tabla Usuario (da error al no tener permiso)'
INSERT INTO Usuario (Nombre_user, Nombre, Email, Contrasena) VALUES ('prueba', 'prueba', 'prueba@email.com', 'reconocer');

RESET ROLE;

\echo '--------------------------------------------------------------------------------------------------'

SET ROLE adminRole;

-- PARA BORRAR EL DISCO INSERTADO POR EL CLIENTE EN SU PRUEBA
\echo 'Borramos el disco insertado por el cliente en su prueba'
DELETE FROM Desea WHERE Nombre_user = 'juangomez' AND Ano_publicacion = '1991' AND Titulo_disco = 'Ivy';

RESET ROLE;


