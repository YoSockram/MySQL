DROP TRIGGER IF EXISTS validarAnulacion;

DELIMITER // 
CREATE TRIGGER validarAnulacion BEFORE DELETE ON Vendidas FOR EACH ROW 
BEGIN 

DECLARE estado_aux varchar(50);

DECLARE tiempo_aux int;

DECLARE dia_aux DATE;

DECLARE msg varchar(1024);

DECLARE precio_aux int;

DECLARE penalización_aux int;

SELECT
    Estado,
    Dia,
    TiempoAnulacion,
    Penalizacion INTO estado_aux,
    dia_aux,
    tiempo_aux,
    penalización_aux
FROM
    Evento
WHERE
    Dia = OLD.Dia_evento
    AND Nombre_recinto = OLD.Nombre_recinto
    AND Ciudad_recinto = OLD.Ciudad_recinto;

IF estado_aux = 'Cerrado'
OR estado_aux = 'Finalizado' THEN
SET
    msg = CONCAT(
        'No puedes anular una entrada para un evento que se encuentra: ',
        estado_aux
    );

SIGNAL SQLSTATE '45000'
SET
    message_text = msg;

END IF;

END // 

DELIMITER ;