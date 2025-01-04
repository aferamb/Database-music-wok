--Triger de auditoría

CREATE TABLE IF NOT EXISTS auditoria (
    id INT AUTO_INCREMENT NOT NULL,
    tabla VARCHAR(100) NOT NULL,
    operacion VARCHAR(100) NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha TIMESTAMP NOT NULL,   --en el select se separará en fecha y hora
    CONSTRAINT pk_auditoria PRIMARY KEY (id)

);


-- Se crea la función que se ejecutará 

CREATE OR REPLACE FUNCTION fn_auditoria() RETURNS TRIGGER AS $fn_auditoria$
  DECLARE
  --  no declaro nada porque no me hace falta...de hecho DECLARE podría haberlo omitido en éste caso
  BEGIN
  -- Se determina que acción a activado el trigger e inserta un nuevo valor en la tabla dependiendo
  -- del dicha acción
  -- Junto con la acción se escribe fecha y hora en la que se ha producido la acción
   IF TG_OP='INSERT' THEN
     INSERT INTO auditoria VALUES (TG_TABLE_NAME, 'alta', SESSION_USER, current_timestamp);  -- Cuando hay una inserción
   ELSIF TG_OP='UPDATE'	THEN
     INSERT INTO auditoria VALUES (TG_TABLE_NAME, 'modificación', SESSION_USER, current_timestamp); -- Cuando hay una modificación
   ELSEIF TG_OP='DELETE' THEN
     INSERT INTO auditoria VALUES (TG_TABLE_NAME, 'borrado', SESSION_USER, current_timestamp); -- Cuando hay un borrado
   END IF;	 
   RETURN NULL;
  END;
$fn_auditoria$ LANGUAGE plpgsql;



-- Se crea el trigger que se dispara cuando hay una inserción, modificación o borrado en la tabla sala

CREATE TRIGGER tg_auditoria after INSERT or UPDATE or DELETE
  ON nombre_tabla FOR EACH ROW
  EXECUTE PROCEDURE fn_auditoria(); 


--Trigger disco

-- Se crea la función que se ejecutará 

CREATE OR REPLACE FUNCTION fn_eliminar_de_deseados() RETURNS TRIGGER AS $fn_eliminar_de_deseados$
BEGIN
    -- Comprobar si el disco insertado está en la lista de deseados del usuario
    IF EXISTS (
        SELECT 1
        FROM lista_deseados
        WHERE id_usuario = NEW.id_usuario
          AND id_disco = NEW.id_disco
    ) THEN
        -- Eliminar el disco de la lista de deseados
        DELETE FROM lista_deseados
        WHERE id_usuario = NEW.id_usuario
          AND id_disco = NEW.id_disco;
    END IF;

    -- Continuar con la inserción normalmente
    RETURN NEW;
END;
$fn_eliminar_de_deseados$ LANGUAGE plpgsql;


-- Se crea el trigger que se dispara cuando hay una inserción, modificación o borrado en la tabla sala

CREATE TRIGGER tg_eliminar_de_deseados
    AFTER INSERT
    ON usuario_tiene_edicion
    FOR EACH ROW
    EXECUTE PROCEDURE fn_eliminar_de_deseados();
