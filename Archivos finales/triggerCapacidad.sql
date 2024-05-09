DROP TRIGGER IF EXISTS comprobarCapacidad;
-- DELIMITER //
-- CREATE TRIGGER comprobarCapacidad
-- BEFORE INSERT ON Localidad
-- FOR EACH ROW
-- BEGIN
--     DECLARE capacidad_aux INT;
--     DECLARE Msg varchar(255);
--     SELECT Capacidad INTO capacidad_aux FROM Recinto WHERE Ciudad = NEW.Ciudad_recinto AND Nombre = NEW.Nombre_recinto;

--     IF capacidad_aux < (SELECT COUNT(*) FROM Localidad WHERE Ciudad_recinto = NEW.Ciudad_recinto AND Nombre_recinto = NEW.Nombre_recinto) + 1 THEN
--         SIGNAL SQLSTATE '45000' SET message_Text = 'La capacidad máxima del recinto ha sido alcanzada';
--     END IF;
-- END//
-- DELIMITER ;

DELIMITER $$

DROP TRIGGER if exists  check_capacity;

CREATE TRIGGER check_capacity

BEFORE INSERT ON Localidad

FOR EACH ROW

BEGIN

    DECLARE max_capacity INT;

    SELECT Capacidad INTO max_capacity FROM Recinto WHERE Ciudad = NEW.Ciudad_recinto AND Nombre = NEW.Nombre_recinto;

    IF NEW.Numero > max_capacity THEN

        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La capacidad del recinto ha sido superada';

    END IF;

END$$

DELIMITER ;