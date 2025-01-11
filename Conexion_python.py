
import sys
import psycopg2
import pytest

class portException(Exception): pass

def ask_port(msg):
    """
        ask for a valid TCP port
        ask_port :: String -> IO Integer | Exception
    """
    try:                                                                        # try
        answer  = input(msg)                                                    # pide el puerto
        port    = int(answer)                                                   # convierte a entero
        if (port < 1024) or (port > 65535):                                     # si el puerto no es valido
            raise ValueError                                                    # lanza una excepción
        else:
            return port
    except ValueError:     
        raise portException                                                     # raise portException
    #finally:                                                                    # finally
    #    return port                                                             # return port

def ask_conn_parameters():
    """
        ask_conn_parameters:: () -> IO String
        pide los parámetros de conexión
        TODO: cada estudiante debe introducir los valores para su base de datos
    """
    host = 'localhost'                                                          # 
    port = ask_port('TCP port number: ')                                        # pide un puerto TCP
    user = input('Introduce el usuario: ')                                      # TODO
    password = input('Introduce la contraseña: ')                                                               # TODO
    database = 'intercambio_discos'                                             # TODO
    return (host, port, user,
             password, database)

def mostrar_menu():
    """
        Mostrar un menú de opciones para que el usuario elija una consulta.
    """
    print("Seleccione una consulta para ejecutar:")
    print("1. Mostrar los discos que tengan más de 5 canciones.")
    print("2. Mostrar los vinilos que tiene el usuario Juan García Gómez.")
    print("3. Disco con mayor duración de la colección.")
    print("4. Discos que el usuario Juan García Gómez tiene en su lista de deseos.")
    print("5. Mostrar los discos publicados entre 1970 y 1972.")
    print("6. Listar los grupos que han publicado discos del género 'Electronic'.")
    print("7. Lista de discos con la duración total, editados antes del año 2000.")
    print("8. Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez.")
    print("9. Lista todas las ediciones de los discos que tiene el usuario Gómez García.")
    print("10. Listar todos los usuarios con el número de ediciones y años de sus discos.")
    print("11. Listar los grupos que tienen más de 5 ediciones de sus discos.")
    print("12. Lista el usuario que más discos,contando todas sus ediciones tiene en la base de datos.")

def ejecutar_consulta(conn, opcion):
    """
        Ejecutar la consulta correspondiente según la opción elegida.
    """
    cur = conn.cursor()

    if opcion == 1:
        query = '''SELECT DISTINCT 
                    d.Titulo, 
                    d.Ano_publicacion, 
                    COUNT(c.Titulo_cancion) AS Num_canciones
                FROM Disco d
                JOIN Canciones c ON d.Titulo = c.Titulo_disco AND d.Ano_publicacion = c.Ano_publicacion
                GROUP BY d.Titulo, d.Ano_publicacion
                HAVING COUNT(c.Titulo_cancion) > 5 AND d.Ano_publicacion > 0
                ORDER BY Num_canciones DESC;'''

    elif opcion == 2:
        query = '''SELECT 
                        E.Formato, 
                        D.Titulo AS Titulo_Disco, 
                        E.Pais, 
                        E.Ano_edicion
                   FROM Usuario U
                   JOIN Tiene T ON U.Nombre_user = T.Nombre_user
                   JOIN Ediciones E ON T.Titulo_disco = E.Titulo_disco AND T.Ano_publicacion = E.Ano_publicacion
                   JOIN Disco D ON E.Titulo_disco = D.Titulo AND E.Ano_publicacion = D.Ano_publicacion
                   WHERE U.Nombre = 'Juan García Gómez' AND E.Formato = 'Vinyl' AND E.Ano_edicion > 0;'''
    elif opcion == 3:
        query = '''WITH Duraciones AS (
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
                ORDER BY Duracion_total DESC;'''
    elif opcion == 4:
        query = '''SELECT 
                    D.Titulo_disco,
                    G.Nombre_grupo
                FROM Desea D
                JOIN Disco G ON D.Titulo_disco = G.Titulo AND D.Ano_publicacion = G.Ano_publicacion
                JOIN Usuario U ON D.Nombre_user = U.Nombre_user 
                WHERE U.Nombre = 'Juan García Gómez'; '''
    elif opcion == 5:
        query = '''SELECT 
                    d.Titulo, 
                    d.Ano_publicacion, 
                    d.Nombre_grupo,
                    e.Formato, 
                    e.Ano_edicion, 
                    e.Pais
                FROM Ediciones e JOIN Disco d ON d.Titulo = e.Titulo_disco AND d.Ano_publicacion = e.Ano_publicacion
                WHERE d.Ano_publicacion BETWEEN 1970 AND 1972 AND d.Ano_publicacion > 0 
                ORDER BY d.Ano_publicacion, d.Titulo;  '''
    elif opcion == 6:
        query = '''SELECT G.Nombre AS Nombre_Grupo
                    FROM Grupo G 
                    JOIN Disco D ON G.Nombre = D.Nombre_grupo
                    JOIN Generos Ge ON D.Titulo = Ge.Titulo_disco AND D.Ano_publicacion = Ge.Ano_publicacion
                    WHERE Ge.Genero = 'Electronic'; '''
    elif opcion == 7:
        query = '''SELECT 
                    d.Titulo, 
                    d.Ano_publicacion, 
                    SUM(c.Duracion) AS Duracion_total
                FROM Disco d 
                JOIN Canciones c ON d.Titulo = c.Titulo_disco AND d.Ano_publicacion = c.Ano_publicacion
                WHERE d.Ano_publicacion < 2000 AND d.Ano_publicacion > 0
                GROUP BY d.Titulo, d.Ano_publicacion
                ORDER BY d.Ano_publicacion, d.Titulo; '''
    elif opcion == 8:
        query = '''SELECT 
                    D.Titulo, 
                    D.Ano_publicacion
                FROM Usuario U 
                JOIN Tiene T ON U.Nombre_user = T.Nombre_user
                JOIN Ediciones E ON T.Titulo_disco = E.Titulo_disco AND T.Ano_publicacion = E.Ano_publicacion
                JOIN Disco D ON E.Titulo_disco = D.Titulo AND E.Ano_publicacion = D.Ano_publicacion --se puede obviar
                WHERE U.Nombre = 'Juan García Gómez' AND D.Ano_publicacion > 0
                AND EXISTS (
                    SELECT 
                        Di.Titulo, 
                        Di.Ano_publicacion 
                    FROM Usuario U2
                    JOIN Desea D2 ON U2.Nombre_user = D2.Nombre_user
                    JOIN Disco Di ON D2.Titulo_disco = Di.Titulo AND D2.Ano_publicacion = Di.Ano_publicacion
                    WHERE U2.Nombre = 'Lorena Sáez Pérez' 
                ); '''
    elif opcion == 9:
        query = '''SELECT
                    u.Nombre, 
                    t.Titulo_disco, 
                    t.Ano_publicacion, 
                    t.Formato, 
                    t.Ano_edicion, 
                    t.Pais, 
                    t.Estado
                FROM Tiene t JOIN Usuario u ON t.Nombre_user = u.Nombre_user
                WHERE u.Nombre LIKE '%G_mez Garc_a%' AND Estado IN ('NM', 'M') AND t.Ano_publicacion > 0 AND t.Ano_edicion > 0; '''
    elif opcion == 10:
        query = '''WITH total_ediciones AS (
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
                    u.Nombre_user, te.total_ediciones;   '''
    elif opcion == 11:
        query = '''SELECT 
                    g.Nombre, 
                    COUNT(e.Titulo_disco) AS Num_ediciones
                FROM Grupo g
                JOIN Disco d ON g.Nombre = d.Nombre_grupo
                JOIN Ediciones e ON d.Titulo = e.Titulo_disco AND d.Ano_publicacion = e.Ano_publicacion
                GROUP BY g.Nombre
                HAVING COUNT(e.Titulo_disco) > 5; '''
    elif opcion == 12:
        query = '''WITH total_ediciones AS(
                    SELECT t.Nombre_user, COUNT(*) AS total_ediciones
                    FROM Tiene t
                    GROUP BY t.Nombre_user
                )
                SELECT u.Nombre_user, te.total_ediciones
                FROM usuario u JOIN total_ediciones te ON u.Nombre_user = te.Nombre_user
                WHERE te.total_ediciones=(SELECT MAX(total_ediciones)
                        FROM total_ediciones); '''

     # Ejecutar la consulta seleccionada
    cur.execute(query)
    for record in cur.fetchall():
        print(record)

    cur.close()

def main():
    """
        main :: () -> IO None
    """
    try:
        (host, port, user, password, database) = ask_conn_parameters()          #
        connstring = f'host={host} port={port} user={user} password={password} dbname={database}' 
        conn    = psycopg2.connect(connstring)                                  #

        # Mostrar el menú para que el usuario elija una consulta
        mostrar_menu()
        opcion = int(input("Elija una opción (1-12): "))    

        cur     = conn.cursor()                                                 # instacia un cursor
        query   = ejecutar_consulta(conn, opcion)                               # prepara una consulta de las 12 a elegir
        cur.execute(query)                                                      # ejecuta la consulta
        for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
            print(record)                                                       # imprime las filas
        cur.close                                                               # cierra el cursor
        conn.close                                                              # cierra la conexion
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        print("Program finished")

#def prueba_conexion():


if __name__ == "__main__":                                                      # Es el modula principal?
    if '--test' in sys.argv:                                                    # chequea el argumento cmdline buscando el modo test
        import doctest                                                          # importa la libreria doctest
        doctest.testmod()                                                       # corre los tests
    else:                                                                       # else
        main()                                                                  # ejecuta el programa principal
