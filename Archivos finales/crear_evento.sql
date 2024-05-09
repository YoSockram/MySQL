DELIMITER $$

DROP PROCEDURE IF EXISTS insert_evento;

CREATE PROCEDURE insert_evento(
    IN p_dia DATE,
    IN p_nombre_recinto VARCHAR(50),
    IN p_ciudad_recinto VARCHAR(50),
    IN p_nombre_espectaculo VARCHAR(50),
    IN p_limite_entradas_usuario INT,
    IN p_estado ENUM("Abierto", "Cerrado", "Finalizado"),
    IN tiempo_anul INT,
    IN penal_aux int,
    IN p_numero_inf INT,
    IN p_numero_jub INT,
    IN p_numero_adu INT,
    IN p_numero_par INT
)
BEGIN

    INSERT INTO Evento (
        Dia,
        Nombre_recinto,
        Ciudad_recinto,
        Nombre_espectaculo,
        Limite_entradas_usuario,
        Estado,
        TiempoAnulacion,
        Penalizacion,
        Numero_inf,
        Numero_jub,
        Numero_adu,
        Numero_par
    ) VALUES (
        p_dia,
        p_nombre_recinto,
        p_ciudad_recinto,
        p_nombre_espectaculo,
        p_limite_entradas_usuario,
        p_estado,
        tiempo_anul,
        penal_aux,
        p_numero_inf,
        p_numero_jub,
        p_numero_adu,
        p_numero_par
    );
END$$

DELIMITER ;
