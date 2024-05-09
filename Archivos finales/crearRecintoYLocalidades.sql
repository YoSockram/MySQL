DELIMITER //
DROP PROCEDURE IF EXISTS generar_localidades;
CREATE PROCEDURE generar_localidades(IN ciudad_recinto VARCHAR(50), IN nombre_recinto VARCHAR(50), IN capacidad_recinto INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    
    INSERT INTO Recinto (Nombre, Ciudad, Capacidad) VALUES (nombre_recinto, ciudad_recinto, capacidad_recinto);
    
    WHILE i <= capacidad_recinto DO
        INSERT INTO Localidad (Numero, Nombre_recinto, Ciudad_recinto) VALUES (i, nombre_recinto, ciudad_recinto);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;
