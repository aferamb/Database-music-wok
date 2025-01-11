--Prueba del trigger auditoria
INSERT INTO Grupo VALUES ('Atlanticos', 'www.hola.com');
UPDATE Grupo SET Url_grupo = 'www.adios.com' WHERE Nombre = 'Atlanticos';

--Prueba del trigger de disco
INSERT INTO Usuario VALUES ('Alexito', 'Alex Ambros', 'holas@gmail.com', '1234');   
INSERT INTO Desea VALUES ('The Cave', '2014', 'Alexito');
SELECT * FROM Desea WHERE Nombre_user = 'Alexito' AND Titulo_disco = 'The Cave' AND Ano_publicacion = '2014';
INSERT INTO Tiene VALUES ('Alexito', 'The Cave', '2014', 'Vinyl', '2014', 'US', 'M');

--Mostar las tablas por pantalla para comprobar que los triggers han funcionado
SELECT * FROM auditoria;
SELECT * FROM Desea WHERE Nombre_user = 'Alexito' AND Titulo_disco = 'The Cave' AND Ano_publicacion = '2014';

-- Los siguientes comandos se ejecutan para limpiar la base de datos de los datos insertados en las pruebas
\echo 'Limpiando la base de datos de los datos insertados en las pruebas'
DELETE FROM Desea WHERE Nombre_user = 'Alexito' AND Titulo_disco = 'The Cave' AND Ano_publicacion = '2014';
DELETE FROM Tiene WHERE Nombre_user = 'Alexito' AND Titulo_disco = 'The Cave' AND Ano_publicacion = '2014';
DELETE FROM Usuario WHERE Nombre_user = 'Alexito';
DELETE FROM Grupo WHERE nombre = 'Atlanticos';