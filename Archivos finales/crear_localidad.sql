DROP PROCEDURE IF EXISTS insert_localidad;
DELIMITER $$

CREATE PROCEDURE insert_localidad(IN p_numero INT, IN p_nombre_recinto VARCHAR(50), IN p_ciudad_recinto VARCHAR(50))
BEGIN
    INSERT INTO Localidad (Numero, Nombre_recinto, Ciudad_recinto) VALUES (p_numero, p_nombre_recinto, p_ciudad_recinto);
END$$

DELIMITER ;
