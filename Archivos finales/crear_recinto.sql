DROP PROCEDURE IF EXISTS insert_recinto;
DELIMITER $$

CREATE PROCEDURE insert_recinto(IN p_nombre VARCHAR(50), IN p_ciudad VARCHAR(50), IN p_capacidad INT)
BEGIN
    INSERT INTO Recinto (Nombre, Ciudad, Capacidad) VALUES (p_nombre, p_ciudad, p_capacidad);
END$$

DELIMITER ;
