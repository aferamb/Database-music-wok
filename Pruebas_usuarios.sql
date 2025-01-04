BEGIN;

\echo '--------- Inicio de prueba de usuarios ---------'

-- Probar el usuario administrador
\echo 'Prueba de usuario administrador (Estas consultas deberían ejecutarse correctamente solo cuando se conecte el usuario admin)'
/*
CREATE TABLE IF NOT EXISTS Prueba(
    Nombre TEXT NOT NULL,
    Numero INT, 
    CONSTRAINT pk_prueba PRIMARY KEY (Nombre)
);
DROP TABLE IF EXISTS Prueba;
*/


-- Probar el usuario gestor
\echo 'Prueba de usuario gestor (y tambien el admin) (Estas consultas deberían ejecutarse correctamente cuando se conecte el usuario gestor o admin)'
INSERT INTO Grupo VALUES ('Maneskin', 'www.maneskin.com');
UPDATE Grupo SET Url_grupo = 'www.maneskinMola.com' WHERE Nombre = 'Maneskin';
SELECT * FROM Grupo WHERE nombre = 'Maneskin';
DELETE FROM Grupo WHERE nombre = 'Maneskin';

-- Probar el usuario cliente (Gumersindo)
\echo 'Prueba de usuario cliente (Estas consultas deberían ejecutarse correctamente cuando se conecte el usuario gumersindo (cliente), o los usuarios admin y gestor)'
INSERT INTO Desea VALUES ('The Cave', '2014', 'Alexito');
SELECT * FROM Desea WHERE Nombre_user = 'martamoreno';
INSERT INTO Tiene VALUES ('Alexito', 'The Cave', '2014', 'Vinyl', '1984', 'UK', 'M');
SELECT * FROM Tiene WHERE Nombre_user = 'analópez';


-- Probar el usuario invitado
\echo 'Prueba de usuario invitado (Estas consultas deberían ejecutarse correctamente cuando se conecte el usuario invitado, o los usuarios admin, gestor, pero no cliente)'
-- Aunque no se lo ideal utilizar limit en las consultas, se ha hecho para que no se muestren todas las filas de las tablas
SELECT * FROM Grupo 
LIMIT 5;
SELECT * FROM Disco
LIMIT 5;
SELECT * FROM Canciones
LIMIT 5;

ROLLBACK;