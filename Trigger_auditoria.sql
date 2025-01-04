--Triger de auditoría

CREATE TABLE IF NOT EXISTS auditoria (
    id SERIAL NOT NULL,
    tabla VARCHAR(100) NOT NULL,
    operacion VARCHAR(100) NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha TIMESTAMP NOT NULL,   --en el select se separará en fecha y hora
    CONSTRAINT pk_auditoria PRIMARY KEY (id)
);

CREATE OR REPLACE FUNCTION fn_auditoria() RETURNS TRIGGER AS $fn_auditoria$
  DECLARE
  --  no declaro nada porque no me hace falta...de hecho DECLARE podría haberlo omitido en éste caso
  BEGIN
  -- Insertar una fila en la tabla de auditoría con los valores de la tabla, operación, usuario y fecha actual
    INSERT INTO auditoria (tabla, operacion, usuario, fecha) VALUES (TG_TABLE_NAME, TG_OP, SESSION_USER, current_timestamp);
    RETURN NULL;
  END;
$fn_auditoria$ LANGUAGE plpgsql;

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Grupo FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria(); 

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Disco FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Generos FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Canciones FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Ediciones FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Usuario FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Tiene FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON Desea FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria();


--Trigger disco

CREATE OR REPLACE FUNCTION fn_eliminar_de_deseados() RETURNS TRIGGER AS $fn_eliminar_de_deseados$
BEGIN
    -- Comprobar si el disco insertado está en la lista de deseados del usuario
    IF EXISTS (
        SELECT 1
        FROM Desea
        WHERE Nombre_user = NEW.Nombre_user
          AND Titulo_disco = NEW.Titulo_disco
    ) THEN
        -- Eliminar el disco de la lista de deseados
        DELETE FROM Desea
        WHERE Nombre_user = NEW.Nombre_user
          AND Titulo_disco = NEW.Titulo_disco;
    END IF;

    -- Continuar con la inserción normalmente
    RETURN NEW;
END;
$fn_eliminar_de_deseados$ LANGUAGE plpgsql;

CREATE TRIGGER tg_eliminar_de_deseados
    AFTER INSERT
    ON Tiene FOR EACH ROW
    EXECUTE PROCEDURE fn_eliminar_de_deseados();

/*

--Trigger de restricción de clientes

CREATE OR REPLACE FUNCTION fn_restric_clientes() RETURNS TRIGGER AS $fn_restric_clientes$
  DECLARE
  --  no declaro nada porque no me hace falta...de hecho DECLARE podría haberlo omitido en éste caso
  BEGIN
  -- Insertar una fila en la tabla de auditoría con los valores de la tabla, operación, usuario y fecha actual
    IF SESSION_USER =  (
        SELECT 1
        FROM Desea
        WHERE Nombre_user = NEW.Nombre_user
          AND Titulo_disco = NEW.Titulo_disco
    ) THEN
        -- Eliminar el disco de la lista de deseados
        DELETE FROM Desea
        WHERE Nombre_user = NEW.Nombre_user
          AND Titulo_disco = NEW.Titulo_disco;
    END IF;
    RETURN NEW;
  END;
$fn_restric_clientes$ LANGUAGE plpgsql;

*/
