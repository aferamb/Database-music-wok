
INSERT INTO Grupo VALUES ('Atlanticos', 'www.hola.com');
UPDATE Grupo SET Url_grupo = 'www.adios.com' WHERE Nombre = 'Atlanticos';
DELETE FROM Grupo WHERE nombre = 'Atlanticos';

INSERT INTO Usuario VALUES ('Alexito', 'Alex Ambros', 'holas@gmail.com', '1234');   
INSERT INTO Desea VALUES ('The Cave', '2014', 'Alexito');
SELECT * FROM Desea WHERE Nombre_user = 'Alexito' AND Titulo_disco = 'The Cave' AND Ano_publicacion = '2014';
INSERT INTO Tiene VALUES ('Alexito', 'The Cave', '2014', 'Vinyl', '2014', 'US', 'M');


SELECT * FROM auditoria;
SELECT * FROM Desea WHERE Nombre_user = 'Alexito' AND Titulo_disco = 'The Cave' AND Ano_publicacion = '2014';