\pset pager off

SET client_encoding = 'UTF8';

BEGIN;

\echo '         Creando el esquema para la BBDD de intercambio de discos'

CREATE TABLE IF NOT EXISTS Grupo(
    Nombre TEXT NOT NULL,
    Url_grupo TEXT, 
    CONSTRAINT pk_grupo PRIMARY KEY (Nombre)
);

CREATE TABLE IF NOT EXISTS Disco(
    Titulo TEXT NOT NULL, 
    Ano_publicacion INT NOT NULL,
    --Generos TEXT, -- MULTIEVALUADO no se ponen los generos
    Url_portada TEXT,
    Nombre_grupo TEXT NOT NULL,
    CONSTRAINT pk_disco PRIMARY KEY (Titulo, Ano_publicacion),
    CONSTRAINT fk_disco_grupo FOREIGN KEY (Nombre_grupo) REFERENCES Grupo(Nombre) 
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Generos(
    Titulo_disco TEXT,
    Ano_publicacion INT,
    Genero TEXT,
    CONSTRAINT pk_genero PRIMARY KEY (Titulo_disco, Ano_publicacion, Genero) 
);

CREATE TABLE IF NOT EXISTS Canciones(
    Titulo_cancion TEXT NOT NULL,
    Titulo_disco TEXT NOT NULL,
    Ano_publicacion INT NOT NULL,
    Duracion INTERVAL NOT NULL, 
    CONSTRAINT pk_cancion PRIMARY KEY (Titulo_cancion, Titulo_disco, Ano_publicacion),
    CONSTRAINT fk_cancion_disco FOREIGN KEY (Titulo_disco, Ano_publicacion) REFERENCES Disco(Titulo, Ano_publicacion)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Ediciones(
    Titulo_disco TEXT NOT NULL,
    Ano_publicacion INT NOT NULL,
    Formato TEXT NOT NULL,
    Ano_edicion INT NOT NULL, 
    Pais TEXT NOT NULL,
    CONSTRAINT pk_edicion PRIMARY KEY (Titulo_disco, Ano_publicacion, Formato, Ano_edicion, Pais),
    CONSTRAINT fk_cancion_disco FOREIGN KEY (Titulo_disco, Ano_publicacion) REFERENCES Disco(Titulo, Ano_publicacion)
);

CREATE TABLE IF NOT EXISTS Usuario(
    Nombre_user TEXT NOT NULL,
    Nombre TEXT NOT NULL,
    Email TEXT NOT NULL,
    Contrasena TEXT NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (Nombre_user)
);

CREATE TABLE IF NOT EXISTS Tiene(
    Nombre_user TEXT NOT NULL,
    Titulo_disco TEXT NOT NULL,
    Ano_publicacion INT NOT NULL,
    Formato TEXT NOT NULL,
    Ano_edicion INT NOT NULL,
    Pais TEXT NOT NULL,
    Estado TEXT,
    CONSTRAINT pk_tiene PRIMARY KEY (Nombre_user, Titulo_disco, Ano_publicacion, Formato, Ano_edicion, Pais),
    CONSTRAINT fk_tiene_user FOREIGN KEY (Nombre_user) REFERENCES Usuario(Nombre_user)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tiene_disco FOREIGN KEY (Titulo_disco, Ano_publicacion, Formato, Ano_edicion, Pais) REFERENCES Ediciones(Titulo_disco, Ano_publicacion, Formato, Ano_edicion, Pais)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Desea(
    Titulo_disco TEXT NOT NULL,
    Ano_publicacion INT NOT NULL,
    Nombre_user TEXT NOT NULL,
    CONSTRAINT pk_desea PRIMARY KEY (Titulo_disco, Ano_publicacion, Nombre_user),
    CONSTRAINT fk_desea_user FOREIGN KEY (Nombre_user) REFERENCES Usuario(Nombre_user)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_desea_disco FOREIGN KEY (Titulo_disco, Ano_publicacion) REFERENCES Disco(Titulo, Ano_publicacion)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

\echo '         Creando un esquema temporal'

CREATE TABLE IF NOT EXISTS Canciones_temp(
    Id_disco TEXT,
    Titulo TEXT,
    Duracion TEXT
);

CREATE TABLE IF NOT EXISTS Discos_temp(
    Id_disco TEXT,
    Nombre_disco TEXT,
    Fecha_lanz TEXT,
    Id_grupo TEXT,
    Nombre_grupo TEXT,
    Url_grupo TEXT,
    Generos TEXT,
    Url_portada TEXT
);

CREATE TABLE IF NOT EXISTS Ediciones_temp(
    Id_disco TEXT,
    Ano_edicion TEXT,
    Pais TEXT,
    Formato TEXT
);

CREATE TABLE IF NOT EXISTS Usuario_desea_disco_temp(
    Nombre_user TEXT,
    Titulo_disco TEXT,
    Ano_lanz TEXT
);

CREATE TABLE IF NOT EXISTS Usuario_tiene_edicion_temp(
    Nombre_user TEXT,
    Titulo_disco TEXT,
    Ano_lanz TEXT,
    Ano_edicion TEXT,
    Pais TEXT,
    Formato TEXT,
    Estado TEXT
);

CREATE TABLE IF NOT EXISTS Usuarios_temp(
    Nombre_completo TEXT,
    Nombre_user TEXT,
    Email TEXT,
    Contrasena TEXT
);


SET search_path TO public;  --esquema public

\echo '         Cargando datos'

\COPY Canciones_temp FROM 'Datos/canciones.csv' DELIMITER ';' NULL 'NULL' CSV ENCODING 'UTF8' HEADER;
\COPY Discos_temp FROM 'Datos/discos.csv' DELIMITER ';' NULL 'NULL' CSV ENCODING 'UTF8' HEADER;
\COPY Ediciones_temp FROM 'Datos/ediciones.csv' DELIMITER ';' NULL 'NULL' CSV ENCODING 'UTF8' HEADER;
\COPY Usuario_desea_disco_temp FROM 'Datos/usuario_desea_disco.csv' DELIMITER ';' NULL 'NULL' CSV ENCODING 'UTF8' HEADER;
\COPY Usuario_tiene_edicion_temp FROM 'Datos/usuario_tiene_edicion.csv' DELIMITER ';' NULL 'NULL' CSV ENCODING 'UTF8' HEADER;
\COPY Usuarios_temp FROM 'Datos/usuarios.csv' DELIMITER ';' NULL 'NULL' CSV ENCODING 'UTF8' HEADER;

\echo '         Insertando datos en el esquema final'
\echo ''


\echo 'Insercion de datos tabla Grupo'
INSERT INTO Grupo(Nombre, Url_grupo) 
SELECT DISTINCT ON (Nombre_grupo)
    Nombre_grupo, 
    Url_grupo 
FROM Discos_temp;


\echo 'Insercion de datos tabla Disco'
INSERT INTO Disco(Titulo, Ano_publicacion, Url_portada, Nombre_grupo) 
SELECT DISTINCT ON (Nombre_disco, Fecha_lanz) 
    Nombre_disco, 
    Fecha_lanz::INT, 
    Url_portada, 
    Nombre_grupo 
FROM Discos_temp; 


\echo 'Insercion de datos tabla Generos'
INSERT INTO Generos (Titulo_disco, Ano_publicacion, Genero)
SELECT DISTINCT
    Nombre_disco, 
    Fecha_lanz::INT, 
    regexp_split_to_table(regexp_replace(Generos, '\[|\]|&|/|''', '', 'g'), E',')
FROM Discos_temp;


\echo 'Insercion de datos tabla Canciones'
INSERT INTO Canciones(Titulo_cancion, Titulo_disco, Ano_publicacion, Duracion)
SELECT DISTINCT ON (Titulo, Nombre_disco, Fecha_lanz)
    Titulo, -- Titulo de la canción
    Nombre_disco, -- Nombre del disco
    Fecha_lanz::INT, 
    make_interval( -- Convertir Duracion (mm:ss) a INTERVAL usando make_interval
        mins => split_part(Duracion, ':', 1)::INT, 
        secs => split_part(Duracion, ':', 2)::INT
    )
FROM Canciones_temp c 
JOIN Discos_temp d ON c.Id_disco = d.Id_disco
WHERE c.Titulo != '' AND Duracion IS NOT NULL; -- No se insertan canciones sin título y sin duración


\echo 'Insercion de datos tabla Ediciones'
INSERT INTO Ediciones(Titulo_disco, Ano_publicacion, Formato, Ano_edicion, Pais)
SELECT DISTINCT -- en todo porque todo es PK
    Nombre_disco, 
    Fecha_lanz::INT, 
    Formato, 
    Ano_edicion::INT, 
    Pais
FROM Ediciones_temp e JOIN Discos_temp d ON e.Id_disco = d.Id_disco;


\echo 'Insercion de datos tabla Usuario'
INSERT INTO Usuario(Nombre_user, Nombre, Email, Contrasena)
SELECT DISTINCT ON (Nombre_user)
    Nombre_user, 
    Nombre_completo, 
    Email, 
    Contrasena
FROM Usuarios_temp;


\echo 'Insercion de datos tabla Tiene'
-- No se incluyen los usuarios que no existen en la tabla de usuarios
INSERT INTO Tiene(Nombre_user, Titulo_disco, Ano_publicacion, Formato, Ano_edicion, Pais, Estado)
SELECT DISTINCT ON (ute.Nombre_user, ute.Titulo_disco, ute.Ano_lanz, ute.Formato, ute.Ano_edicion, ute.Pais)
    ute.Nombre_user, 
    Titulo_disco, 
    Ano_lanz::INT, 
    Formato, 
    Ano_edicion::INT, 
    Pais, 
    Estado
FROM Usuario_tiene_edicion_temp ute JOIN Usuarios_temp u ON ute.Nombre_user = u.Nombre_user;


\echo 'Insercion de datos tabla Desea'
-- No se incluyen los usuarios que no existen en la tabla de usuarios
INSERT INTO Desea(Titulo_disco, Ano_publicacion, Nombre_user)
SELECT DISTINCT
    Titulo_disco, 
    Ano_lanz::INT, 
    udd.Nombre_user
FROM Usuario_desea_disco_temp udd JOIN Usuarios_temp u ON udd.Nombre_user = u.Nombre_user; 

\echo ''
\echo '         Datos insertados correctamente'
\echo ''

\echo 'Consulta 1: Mostrar los discos que tengan más de 5 canciones. Construir la expresión equivalente en álgebra relacional.'
\echo ''

SELECT DISTINCT 
    d.Titulo, 
    d.Ano_publicacion, 
    COUNT(c.Titulo_cancion) AS Num_canciones
FROM Disco d
JOIN Canciones c ON d.Titulo = c.Titulo_disco AND d.Ano_publicacion = c.Ano_publicacion
GROUP BY d.Titulo, d.Ano_publicacion
HAVING COUNT(c.Titulo_cancion) > 5 AND d.Ano_publicacion > 0
ORDER BY Num_canciones DESC;

\echo ''
\echo 'Consulta 2: Mostrar los vinilos que tiene el usuario Juan García Gómez junto con el título del disco, y el país y año de edición del mismo'
\echo ''
SELECT 
    E.Formato, 
    D.Titulo AS Titulo_Disco, 
    E.Pais, 
    E.Ano_edicion
FROM Usuario U
JOIN Tiene T ON U.Nombre_user = T.Nombre_user
JOIN Ediciones E ON T.Titulo_disco = E.Titulo_disco AND T.Ano_publicacion = E.Ano_publicacion AND T.Formato = E.Formato AND T.Ano_edicion = E.Ano_edicion AND T.Pais = E.Pais
JOIN Disco D ON E.Titulo_disco = D.Titulo AND E.Ano_publicacion = D.Ano_publicacion
WHERE U.Nombre = 'Juan García Gómez' AND E.Formato = 'Vinyl' AND E.Ano_edicion > 0;

\echo ''
\echo 'Consulta 3: Disco con mayor duración de la colección. Construir la expresión equivalente en álgebra relacional.'
\echo ''

WITH Duraciones AS (
    SELECT  
        d.Titulo, 
        d.Ano_publicacion, 
        SUM(c.Duracion) AS Duracion_total
    FROM Disco d
    JOIN Canciones c ON d.Titulo = c.Titulo_disco AND d.Ano_publicacion = c.Ano_publicacion
    WHERE d.Ano_publicacion > 0
    GROUP BY d.Titulo, d.Ano_publicacion
)
SELECT 
    Titulo, 
    Ano_publicacion, 
    Duracion_total
FROM Duraciones
WHERE Duracion_total = (
    SELECT MAX(Duracion_total)
    FROM Duraciones
) 
ORDER BY Duracion_total DESC;

/*  Muestra el disco con mayor duración de cada colección de cada usuario
SELECT 
    u.Nombre_user, 
    d.Titulo, 
    d.Ano_publicacion, 
    SUM(c.Duracion) AS Duracion_total
FROM Usuario u
JOIN Tiene t ON u.Nombre_user = t.Nombre_user
JOIN Canciones c ON t.Titulo_disco = c.Titulo_disco AND t.Ano_publicacion = c.Ano_publicacion
JOIN Disco d ON c.Titulo_disco = d.Titulo AND c.Ano_publicacion = d.Ano_publicacion
GROUP BY u.Nombre_user, d.Titulo, d.Ano_publicacion
HAVING SUM(c.Duracion) = (
    SELECT MAX(Duracion_total)
    FROM (
        SELECT 
            u2.Nombre_user, 
            SUM(c2.Duracion) AS Duracion_total
        FROM Usuario u2
        JOIN Tiene t2 ON u2.Nombre_user = t2.Nombre_user
        JOIN Canciones c2 ON t2.Titulo_disco = c2.Titulo_disco AND t2.Ano_publicacion = c2.Ano_publicacion
        GROUP BY u2.Nombre_user, c2.Titulo_disco, c2.Ano_publicacion
    ) AS subquery
    WHERE subquery.Nombre_user = u.Nombre_user
)
ORDER BY u.Nombre_user, Duracion_total DESC;
*/

\echo ''
\echo 'Consulta 4: De los discos que tiene en su lista de deseos el usuario Juan García Gómez, indicar el nombre de los grupos musicales que los interpretan.'
\echo ''

SELECT 
    D.Titulo_disco,
    G.Nombre_grupo
FROM Desea D
JOIN Disco G ON D.Titulo_disco = G.Titulo AND D.Ano_publicacion = G.Ano_publicacion
JOIN Usuario U ON D.Nombre_user = U.Nombre_user
WHERE U.Nombre = 'Juan García Gómez';

\echo ''
\echo 'Consulta 5: Mostrar los discos publicados entre 1970 y 1972 junto con sus ediciones ordenados por el año de publicación.'
\echo '' 

SELECT 
    d.Titulo, 
    d.Ano_publicacion, 
    d.Nombre_grupo,
    e.Formato, 
    e.Ano_edicion, 
    e.Pais
FROM Ediciones e JOIN Disco d ON d.Titulo = e.Titulo_disco AND d.Ano_publicacion = e.Ano_publicacion
WHERE d.Ano_publicacion BETWEEN 1970 AND 1972 AND d.Ano_publicacion > 0 --
ORDER BY d.Ano_publicacion, d.Titulo; 

\echo ''
\echo 'Consulta 6: Listar el nombre de todos los grupos que han publicado discos del género ‘Electronic’. Construir la expresión equivalente en álgebra relacional.'
\echo ''

SELECT G.Nombre AS Nombre_Grupo
FROM Grupo G 
JOIN Disco D ON G.Nombre = D.Nombre_grupo
JOIN Generos Ge ON D.Titulo = Ge.Titulo_disco AND D.Ano_publicacion = Ge.Ano_publicacion
WHERE Ge.Genero = 'Electronic';

\echo ''
\echo 'Consulta 7: Lista de discos con la duración total del mismo, editados antes del año 2000.'
\echo ''

SELECT 
    d.Titulo, 
    d.Ano_publicacion, 
    SUM(c.Duracion) AS Duracion_total
FROM Disco d 
JOIN Canciones c ON d.Titulo = c.Titulo_disco AND d.Ano_publicacion = c.Ano_publicacion
WHERE d.Ano_publicacion < 2000 AND d.Ano_publicacion > 0
GROUP BY d.Titulo, d.Ano_publicacion
ORDER BY d.Ano_publicacion, d.Titulo;

\echo ''
\echo 'Consulta 8: Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez que tiene el usuario Juan García Gómez'
\echo ''

SELECT 
    D.Titulo, 
    D.Ano_publicacion
FROM Usuario U 
JOIN Tiene T ON U.Nombre_user = T.Nombre_user
JOIN Ediciones E ON T.Titulo_disco = E.Titulo_disco AND T.Ano_publicacion = E.Ano_publicacion
JOIN Disco D ON E.Titulo_disco = D.Titulo AND E.Ano_publicacion = D.Ano_publicacion
WHERE U.Nombre = 'Juan García Gómez' AND D.Ano_publicacion > 0
AND EXISTS (
    SELECT 
        Di.Titulo, 
        Di.Ano_publicacion 
    FROM Usuario U2
    JOIN Desea D2 ON U2.Nombre_user = D2.Nombre_user
    JOIN Disco Di ON D2.Titulo_disco = Di.Titulo AND D2.Ano_publicacion = Di.Ano_publicacion
    WHERE U2.Nombre = 'Lorena Sáez Pérez' 
);

\echo ''
\echo 'Consulta 9: Lista todas las ediciones de los discos que tiene el usuario Gómez García en un estado NM o M. Construir la expresión equivalente en álgebra relacional.'
\echo ''

SELECT
    u.Nombre, 
    t.Titulo_disco, 
    t.Ano_publicacion, 
    t.Formato, 
    t.Ano_edicion, 
    t.Pais, 
    t.Estado
FROM Tiene t JOIN Usuario u ON t.Nombre_user = u.Nombre_user
WHERE u.Nombre LIKE '%G_mez Garc_a%' AND Estado IN ('NM', 'M') AND t.Ano_publicacion > 0 AND t.Ano_edicion > 0;

\echo ''
\echo 'Consulta 10: Listar todos los usuarios junto al número de ediciones que tiene de todos los discos junto al año de lanzamiento de su disco más antiguo, el año de lanzamiento de su disco más nuevo, y el año medio de todos sus discos de su colección'
\echo ''

WITH total_ediciones AS (
    SELECT t.Nombre_user, COUNT(*) AS total_ediciones
    FROM Tiene t
    GROUP BY t.Nombre_user
)
SELECT 
    u.Nombre_user, 
    te.total_ediciones, 
    MIN(T.Ano_publicacion) AS Ano_lanzamiento_mas_antiguo, 
    MAX(T.Ano_publicacion) AS Ano_lanzamiento_mas_reciente, 
    ROUND(AVG(T.Ano_publicacion), 0) AS Ano_medio
FROM 
    usuario u 
    JOIN total_ediciones te ON u.Nombre_user = te.Nombre_user
    JOIN Tiene T ON u.Nombre_user = T.Nombre_user
WHERE 
    T.Ano_publicacion > 0
GROUP BY 
    u.Nombre_user, te.total_ediciones;  


\echo ''
\echo 'Consulta 11: Listar el nombre de los grupos que tienen más de 5 ediciones de sus discos en la base de datos'
\echo ''

SELECT 
    g.Nombre, 
    COUNT(e.Titulo_disco) AS Num_ediciones
FROM Grupo g
JOIN Disco d ON g.Nombre = d.Nombre_grupo
JOIN Ediciones e ON d.Titulo = e.Titulo_disco AND d.Ano_publicacion = e.Ano_publicacion
GROUP BY g.Nombre
HAVING COUNT(e.Titulo_disco) > 5;

\echo ''
\echo 'Consulta 12: Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos'
\echo ''

WITH total_ediciones AS(
    SELECT t.Nombre_user, COUNT(*) AS total_ediciones
    FROM Tiene t
    GROUP BY t.Nombre_user
)
SELECT u.Nombre_user, te.total_ediciones
FROM usuario u JOIN total_ediciones te ON u.Nombre_user = te.Nombre_user
WHERE te.total_ediciones=(SELECT MAX(total_ediciones)
        FROM total_ediciones);



ROLLBACK;     -- importante! permite correr el script multiples veces