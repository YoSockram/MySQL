DELIMITER $$

DROP PROCEDURE IF EXISTS insert_oferta;

CREATE PROCEDURE insert_oferta(
    IN p_dia_evento DATE,
    IN p_numero_localidad INT,
    IN p_ciudad_recinto VARCHAR(50),
    IN p_nombre_recinto VARCHAR(50),
    IN p_tipo ENUM('Infantil', 'Jubilado', 'Adulto', 'Parado'),
    IN p_precio INT
)
BEGIN

    INSERT INTO AsocOfertas (
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto,
        Tipo,
        Precio
    ) VALUES (
        p_dia_evento,
        p_numero_localidad,
        p_ciudad_recinto,
        p_nombre_recinto,
        p_tipo,
        p_precio
    );
END$$

DELIMITER ;
