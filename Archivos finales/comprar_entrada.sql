DELIMITER $$

DROP PROCEDURE IF EXISTS create_cliente_and_buy;

CREATE PROCEDURE create_cliente_and_buy(
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_nif INT,
    IN p_metodo_pago ENUM('PayPal', 'Tarjeta', 'Bizum'),
    IN p_dia_evento DATE,
    IN p_numero_localidad INT,
    IN p_ciudad_recinto VARCHAR(50),
    IN p_nombre_recinto VARCHAR(50),
    IN p_tipo ENUM('Infantil', 'Jubilado', 'Adulto', 'Parado')
)
BEGIN
    -- DECLARE EXIT HANDLER FOR SQLEXCEPTION
    -- BEGIN
    --     ROLLBACK;
    --     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al crear cliente y comprar entrada';
    -- END;

    START TRANSACTION;
    IF NOT EXISTS (SELECT * FROM Cliente WHERE NIF = p_nif) THEN
        INSERT INTO Cliente (
            Nombre,
            Apellido,
            NIF,
            Metodo_Pago
        ) VALUES (
            p_nombre,
            p_apellido,
            p_nif,
            p_metodo_pago
        );
    END IF;

    INSERT INTO Vendidas (
        Dia_evento,
        Numero_localidad,
        Tipo,
        Ciudad_recinto,
        Nombre_recinto,
        Cliente
    ) VALUES (
        p_dia_evento,
        p_numero_localidad,
        p_tipo,
        p_ciudad_recinto,
        p_nombre_recinto,
        p_nif
    );
    COMMIT;
END$$

DELIMITER ;
