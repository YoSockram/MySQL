DELIMITER $$
DROP TRIGGER IF EXISTS check_capacity_by_type;
CREATE TRIGGER check_capacity_by_type
BEFORE INSERT ON Vendidas
FOR EACH ROW
BEGIN
    DECLARE max_capacity INT;
    CASE NEW.Tipo
        WHEN 'Infantil' THEN
            SELECT Numero_inf INTO max_capacity FROM Evento WHERE Dia = NEW.Dia_evento AND Nombre_recinto = NEW.Nombre_recinto AND Ciudad_recinto = NEW.Ciudad_recinto;
        WHEN 'Jubilado' THEN
            SELECT Numero_jub INTO max_capacity FROM Evento WHERE Dia = NEW.Dia_evento AND Nombre_recinto = NEW.Nombre_recinto AND Ciudad_recinto = NEW.Ciudad_recinto;
        WHEN 'Adulto' THEN
            SELECT Numero_adu INTO max_capacity FROM Evento WHERE Dia = NEW.Dia_evento AND Nombre_recinto = NEW.Nombre_recinto AND Ciudad_recinto = NEW.Ciudad_recinto;
        WHEN 'Parado' THEN
            SELECT Numero_par INTO max_capacity FROM Evento WHERE Dia = NEW.Dia_evento AND Nombre_recinto = NEW.Nombre_recinto AND Ciudad_recinto = NEW.Ciudad_recinto;
    END CASE;

    SET @msg = CONCAT('La capacidad máxima para el tipo de usuario ', NEW.Tipo, ' ha sido alcanzada');

    IF (SELECT COUNT(*) FROM Vendidas WHERE Dia_evento = NEW.Dia_evento AND Ciudad_recinto = NEW.Ciudad_recinto AND Nombre_recinto = NEW.Nombre_recinto AND Tipo = NEW.Tipo) >= max_capacity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
    END IF;
END$$

DELIMITER ;
