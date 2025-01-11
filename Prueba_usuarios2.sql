SET client_encoding TO 'UTF8';
\echo '---------------------Establecemos el usuario Admin---------------------' 
SET ROLE adminRole;

\echo 'Hacemos consulta' 
SELECT nombre, contraseña FROM public.Usuario  WHERE nombre_usuario = 'juangomez';
\echo 'insertamos en la tabla Usuario'
INSERT INTO Usuario (nombre_usuario, contraseña, email, nombre) VALUES ('prueba', 'contraseña', 'email@email.com', 'prueba');
\echo 'borramos de la tabla Usuario'
DELETE FROM Usuario WHERE nombre = 'prueba';
\echo 'creamos una nueva tabla'
CREATE TABLE prueba_admin (id SERIAL PRIMARY KEY);
\echo 'Borramos la nueva tabla' 
DROP TABLE prueba_admin;  
RESET ROLE;


\echo '---------------------Establecemos el usuario Gestor---------------------' 
SET ROLE gestorRole;

\echo 'Hacemos consulta' 
SELECT nombre, contraseña FROM public.Usuario  WHERE nombre_usuario = 'juangomez' ;
\echo 'insertamos en la tabla Usuario'
INSERT INTO Usuario (nombre_usuario, contraseña, email, nombre) VALUES ('prueba', 'contraseña', 'email@email.com', 'prueba');
\echo 'modificamos datos de la tabla usuario'
UPDATE Usuario SET contraseña = 'nueva_contraseña' WHERE nombre = 'prueba';
\echo 'borramos de la tabla Usuario'
DELETE FROM Usuario WHERE nombre = 'prueba';
\echo 'intentamos crear una tabla (da error ya que no tiene permisos)'
CREATE TABLE prueba_admin (id SERIAL PRIMARY KEY); 
RESET ROLE;


\echo '---------------------Establecemos el usuario cliente---------------------' 
SET ROLE clienteRole;

\echo 'Hacemos consulta en la tabla Tiene'
SELECT titulo_disco FROM public.Tiene WHERE año_publicacion_disco = '2007' AND pais_edicion = 'Germany'  ;
\echo 'Insertamos en la tabla Desea' 
INSERT INTO public.Desea(nombre_usuario,titulo_disco,año_publicacion_disco) VALUES('juangomez', 'Ivy', '1991');
\echo 'intentamos seleccionar de otra tabla (no tiene permisos)'
SELECT * FROM public.Genero; 
\echo 'intentamos crear una tabla (da error ya que no tiene permisos)'
CREATE TABLE prueba_admin (id SERIAL PRIMARY KEY);  
RESET ROLE;


\echo '---------------------Establecemos el usuario Invitado---------------------'
SET ROLE invitadoRole;

\echo 'hacemos consulta en la tabla disco'
SELECT titulo_disco, año_publicacion FROM Disco WHERE año_publicacion = '2005' AND nombre_grupo = 'Andrea Berg';
\echo 'hacemos consulta en la tabla Cancion'
SELECT titulo_disco FROM Cancion WHERE titulo_cancion = 'The Cave' ;
\echo 'intentamos seleccionar de la tabla Tiene (da error al no tener permiso)'
SELECT * FROM public.Tiene WHERE año_publicacion_disco = '2005'  ;
\echo 'intentamos insertar en la tabla Usuario (dara error por el mismo motivo)'
INSERT INTO Usuario (nombre_usuario, contraseña, email, nombre) VALUES ('prueba', 'contraseña', 'email@email.com', 'prueba');
RESET ROLE;

\echo '--------------------------------------------------------------------------------------------------'

SET ROLE adminRole;

-- PARA BORRAR EL DISCO INSERTADO POR EL CLIENTE EN SU PRUEBA
\echo 'borramos de la tabla Usuario'
DELETE FROM Desea WHERE nombre_usuario = 'juangomez' AND año_publicacion_disco = '1991' AND titulo_disco = 'Ivy';

RESET ROLE;


ROLLBACK;

