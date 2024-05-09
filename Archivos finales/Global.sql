drop table if exists Vendidas;

drop table if exists AsocOfertas;

drop table if exists Localidad;

drop table if exists Evento;

drop table if exists Recinto;

drop table if exists Tipo_Usuario;

drop table if exists Cliente;

drop table if exists Anuladas;

CREATE TABLE Recinto (
    Nombre varchar(50),
    Ciudad varchar(50),
    Capacidad int NOT NULL,
    PRIMARY KEY(Ciudad, Nombre)
);

CREATE TABLE Cliente (
    Nombre varchar(50),
    Apellido varchar(50),
    NIF int,
    Metodo_Pago enum("PayPal", "Tarjeta", "Bizum"),
    PRIMARY KEY(NIF)
);

CREATE TABLE Localidad (
    Numero int check(Numero > 0),
    Nombre_recinto varchar(50),
    Ciudad_recinto varchar(50),
    PRIMARY KEY(Numero, Nombre_recinto, Ciudad_recinto),
    FOREIGN KEY (Ciudad_recinto, Nombre_recinto) REFERENCES Recinto(Ciudad, Nombre)
);

CREATE TABLE Tipo_Usuario (
    Tipo enum("Infantil", "Jubilado", "Adulto", "Parado"),
    PRIMARY KEY(Tipo)
);

CREATE TABLE Evento (
    Dia DATE,
    Nombre_recinto varchar(50),
    Ciudad_recinto varchar(50),
    Nombre_espectaculo varchar(50),
    Limite_entradas_usuario int NOT NULL DEFAULT 10,
    Estado enum("Abierto", "Cerrado", "Finalizado") NOT NULL DEFAULT "Abierto",
    TiempoAnulacion int NOT NULL DEFAULT 1,
    Penalizacion int NOT NULL DEFAULT 10,
    Numero_inf int DEFAULT 10,
    Numero_jub int DEFAULT 10,
    Numero_adu int DEFAULT 10,
    Numero_par int DEFAULT 10,
    PRIMARY KEY(
        Dia,
        Nombre_recinto,
        Ciudad_recinto
    ),
    FOREIGN KEY (Ciudad_recinto, Nombre_recinto) REFERENCES Recinto(Ciudad, Nombre)
);

CREATE TABLE AsocOfertas (
    Dia_evento DATE,
    Numero_localidad int,
    Ciudad_recinto varchar(50),
    Nombre_recinto varchar(50),
    Tipo enum("Infantil", "Jubilado", "Adulto", "Parado"),
    Precio int NOT NULL DEFAULT 10,
    PRIMARY KEY(
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto,
        Tipo
    ),
    FOREIGN KEY (Dia_evento, Nombre_recinto, Ciudad_recinto) REFERENCES Evento(Dia, Nombre_recinto, Ciudad_recinto),
    FOREIGN KEY (Numero_localidad, Nombre_recinto, Ciudad_recinto) REFERENCES Localidad(Numero, Nombre_recinto, Ciudad_recinto),
    FOREIGN KEY (Tipo) REFERENCES Tipo_Usuario(Tipo)
);

create table Vendidas(
    Dia_evento DATE,
    Numero_localidad int,
    Tipo enum("Infantil", "Jubilado", "Adulto", "Parado"),
    Ciudad_recinto varchar(50),
    Nombre_recinto varchar(50),
    Cliente int NOT NULL,
    PRIMARY KEY(
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto
    ),
    FOREIGN KEY (
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto,
        Tipo
    ) REFERENCES AsocOfertas(
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto,
        Tipo
    ),
    FOREIGN KEY (Tipo) REFERENCES Tipo_Usuario(Tipo),
    FOREIGN KEY (Cliente) REFERENCES Cliente(NIF)
);

CREATE TABLE Anuladas (
    Cliente int,
    Numero_localidad int,
    Dia_evento DATE,
    Nombre_recinto varchar(50),
    Ciudad_recinto varchar(50),
    Precio int,
    Momento_anulacion timestamp default NOW(),
    Penalizacion float default 0
);

-------------------------------------TRIGGERS-------------------------------------------
delimiter //

drop trigger if exists maxVendidasUsuario;

create trigger maxVendidasUsuario before
INSERT
 on Vendidas for each row BEGIN 



 DECLARE
 msg VARCHAR(255);
 DECLARE maxVendidasUsuario INT;
DECLARE maxVendidasUsuario_Evento INT;

select
 count(*) into maxVendidasUsuario
from
 Vendidas
where
 Cliente = NEW.Cliente
 and Dia_evento = NEW.Dia_evento
 and Ciudad_recinto = NEW.Ciudad_recinto
 and Nombre_recinto = NEW.Nombre_recinto;

-- SET msg = CONCAT('Valor de maxVendidasUsuario: ', maxVendidasUsuario);

-- SIGNAL SQLSTATE '45000' SET message_text = msg;

select
 Limite_entradas_usuario into maxVendidasUsuario_Evento
from
 Evento
where
 Dia = NEW.Dia_evento
 and Ciudad_recinto = NEW.Ciudad_recinto
 and Nombre_recinto = NEW.Nombre_recinto;

-- SET msg = CONCAT('Valor de maxVendidasUsuario_Evento: ', maxVendidasUsuario_Evento);

-- SIGNAL SQLSTATE '45000' SET message_text = msg;
IF maxVendidasUsuario >= maxVendidasUsuario_Evento THEN 

SET msg = CONCAT('No se puede realizar la compra superado el máximo de entradas por usuario para este evento.');
SIGNAL SQLSTATE '45000' SET message_text = msg;

END IF;

END //

delimiter ;


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


------------------------------------PROCEDURES-------------------------------------------


DELIMITER //

DROP PROCEDURE IF EXISTS MostrarAsocOfertasDisponibles;
CREATE PROCEDURE MostrarAsocOfertasDisponibles()
BEGIN
    SELECT AsocOfertas.* FROM AsocOfertas
    LEFT JOIN Vendidas ON AsocOfertas.Dia_evento = Vendidas.Dia_evento AND
                          AsocOfertas.Numero_localidad = Vendidas.Numero_localidad AND
                          AsocOfertas.Ciudad_recinto = Vendidas.Ciudad_recinto AND
                          AsocOfertas.Nombre_recinto = Vendidas.Nombre_recinto
    INNER JOIN Evento ON AsocOfertas.Dia_evento = Evento.Dia AND
                         AsocOfertas.Ciudad_recinto = Evento.Ciudad_recinto AND
                         AsocOfertas.Nombre_recinto = Evento.Nombre_recinto
    WHERE Vendidas.Dia_evento IS NULL AND Evento.Estado ="Abierto";
END //
DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS MostrarAsocOfertasDisponiblesEvento;
CREATE PROCEDURE MostrarAsocOfertasDisponiblesEvento(IN dia_evento_aux DATE, IN ciudad_recinto_aux
 VARCHAR(50), IN nombre_recinto_aux VARCHAR(50))
BEGIN
    SELECT AsocOfertas.*,Evento.Nombre_espectaculo FROM AsocOfertas
    LEFT JOIN Vendidas ON AsocOfertas.Dia_evento = Vendidas.Dia_evento AND
                          AsocOfertas.Numero_localidad = Vendidas.Numero_localidad AND
                          AsocOfertas.Ciudad_recinto = Vendidas.Ciudad_recinto AND
                          AsocOfertas.Nombre_recinto = Vendidas.Nombre_recinto
    INNER JOIN Evento ON AsocOfertas.Dia_evento = Evento.Dia AND
                         AsocOfertas.Ciudad_recinto = Evento.Ciudad_recinto AND
                         AsocOfertas.Nombre_recinto = Evento.Nombre_recinto
    WHERE Vendidas.Dia_evento IS NULL AND Evento.Estado ="Abierto" AND
          AsocOfertas.Dia_evento = dia_evento_aux AND AsocOfertas.Ciudad_recinto = ciudad_recinto_aux AND AsocOfertas.Nombre_recinto = nombre_recinto_aux;
END //
DELIMITER ;


DELIMITER //

DROP PROCEDURE if exists modEvento;

CREATE PROCEDURE modEvento(IN DiaDelEvento DATE,in Recinto_nom varchar(50),in Recinto_ciudad varchar(50),in estado_aux varchar(50)) 

BEGIN

UPDATE
 Evento SET Estado=estado_aux

where
    Dia = DiaDelEvento and Nombre_recinto=Recinto_nom and Ciudad_recinto=Recinto_ciudad;

END // 
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_recinto;
DELIMITER $$

CREATE PROCEDURE insert_recinto(IN p_nombre VARCHAR(50), IN p_ciudad VARCHAR(50), IN p_capacidad INT)
BEGIN
    INSERT INTO Recinto (Nombre, Ciudad, Capacidad) VALUES (p_nombre, p_ciudad, p_capacidad);
END$$

DELIMITER ;

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

DROP PROCEDURE IF EXISTS insert_localidad;
DELIMITER $$

CREATE PROCEDURE insert_localidad(IN p_numero INT, IN p_nombre_recinto VARCHAR(50), IN p_ciudad_recinto VARCHAR(50))
BEGIN
    INSERT INTO Localidad (Numero, Nombre_recinto, Ciudad_recinto) VALUES (p_numero, p_nombre_recinto, p_ciudad_recinto);
END$$

DELIMITER ;


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


DELIMITER //
DROP PROCEDURE IF EXISTS ComprasPorCliente;
CREATE PROCEDURE ComprasPorCliente(IN nif_cliente INT)
BEGIN
    SELECT v.Dia_evento, v.Numero_localidad, v.Tipo, v.Ciudad_recinto, v.Nombre_recinto, a.Precio
    FROM Vendidas v
    JOIN AsocOfertas a
    ON v.Dia_evento = a.Dia_evento AND v.Numero_localidad = a.Numero_localidad AND v.Ciudad_recinto = a.Ciudad_recinto AND v.Nombre_recinto = a.Nombre_recinto AND v.Tipo = a.Tipo
    WHERE v.Cliente = nif_cliente;
END //
DELIMITER ;


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


DELIMITER //
DROP PROCEDURE IF EXISTS search_eventos_by_tipo;

CREATE PROCEDURE search_eventos_by_tipo(IN tipo_usuario ENUM('Infantil', 'Jubilado', 'Adulto', 'Parado'))
BEGIN
    SELECT AsocOfertas.* FROM AsocOfertas
    LEFT JOIN Vendidas ON AsocOfertas.Dia_evento = Vendidas.Dia_evento AND
                          AsocOfertas.Numero_localidad = Vendidas.Numero_localidad AND
                          AsocOfertas.Ciudad_recinto = Vendidas.Ciudad_recinto AND
                          AsocOfertas.Nombre_recinto = Vendidas.Nombre_recinto
    INNER JOIN Evento ON AsocOfertas.Dia_evento = Evento.Dia AND
                         AsocOfertas.Ciudad_recinto = Evento.Ciudad_recinto AND
                         AsocOfertas.Nombre_recinto = Evento.Nombre_recinto
    WHERE Vendidas.Dia_evento IS NULL AND Evento.Estado="Abierto" AND
          AsocOfertas.Tipo = tipo_usuario;
END //
DELIMITER ;


DELIMITER //

DROP PROCEDURE IF EXISTS search_eventos_by_recinto;

CREATE PROCEDURE search_eventos_by_recinto(IN nombre_recinto VARCHAR(50), IN ciudad_recinto VARCHAR(50))
BEGIN
    SELECT AsocOfertas.* FROM AsocOfertas
    LEFT JOIN Vendidas ON AsocOfertas.Dia_evento = Vendidas.Dia_evento AND
                          AsocOfertas.Numero_localidad = Vendidas.Numero_localidad AND
                          AsocOfertas.Ciudad_recinto = Vendidas.Ciudad_recinto AND
                          AsocOfertas.Nombre_recinto = Vendidas.Nombre_recinto
    INNER JOIN Evento ON AsocOfertas.Dia_evento = Evento.Dia AND
                         AsocOfertas.Ciudad_recinto = Evento.Ciudad_recinto AND
                         AsocOfertas.Nombre_recinto = Evento.Nombre_recinto
    WHERE Vendidas.Dia_evento IS NULL AND Evento.Estado ="Abierto" AND
          AsocOfertas.Ciudad_recinto = ciudad_recinto AND AsocOfertas.Nombre_recinto = nombre_recinto;
END //
DELIMITER ;


DELIMITER //
DROP PROCEDURE IF EXISTS buscar_ofertas_espectaculo;
CREATE PROCEDURE buscar_ofertas_espectaculo(IN nombre_espectaculo VARCHAR(50))
BEGIN
    SELECT AsocOfertas.* FROM AsocOfertas
    LEFT JOIN Vendidas ON AsocOfertas.Dia_evento = Vendidas.Dia_evento AND
                          AsocOfertas.Numero_localidad = Vendidas.Numero_localidad AND
                          AsocOfertas.Ciudad_recinto = Vendidas.Ciudad_recinto AND
                          AsocOfertas.Nombre_recinto = Vendidas.Nombre_recinto
    INNER JOIN Evento ON AsocOfertas.Dia_evento = Evento.Dia AND
                         AsocOfertas.Ciudad_recinto = Evento.Ciudad_recinto AND
                         AsocOfertas.Nombre_recinto = Evento.Nombre_recinto
    WHERE Vendidas.Dia_evento IS NULL AND Evento.Estado="Abierto" AND
          Evento.Nombre_espectaculo = nombre_espectaculo;
          end //
DELIMITER ;



DROP PROCEDURE IF EXISTS search_eventos_by_dia;

DELIMITER //
CREATE PROCEDURE search_eventos_by_dia(IN dia_evento DATE) 
BEGIN
    SELECT AsocOfertas.* FROM AsocOfertas
    LEFT JOIN Vendidas ON AsocOfertas.Dia_evento = Vendidas.Dia_evento AND
                          AsocOfertas.Numero_localidad = Vendidas.Numero_localidad AND
                          AsocOfertas.Ciudad_recinto = Vendidas.Ciudad_recinto AND
                          AsocOfertas.Nombre_recinto = Vendidas.Nombre_recinto
    INNER JOIN Evento ON AsocOfertas.Dia_evento = Evento.Dia AND
                         AsocOfertas.Ciudad_recinto = Evento.Ciudad_recinto AND
                         AsocOfertas.Nombre_recinto = Evento.Nombre_recinto
    WHERE Vendidas.Dia_evento IS NULL AND Evento.Estado ="Abierto" AND
          AsocOfertas.Dia_evento = dia_evento;
END //

DELIMITER ;

DELIMITER //  

DROP PROCEDURE if exists anularEntrada;

CREATE PROCEDURE anularEntrada(
    IN ID_Cliente int,
    IN DiaDelEvento DATE,
    in Recinto_nom varchar(50),
    in Recinto_ciudad varchar(50),
    in num_loc int
) BEGIN DECLARE filas INT;
DECLARE MSG VARCHAR(1024);
DECLARE estado_aux varchar(50);
DECLARE tipo_aux varchar(50);


DECLARE tiempo_aux int;


DECLARE precio_aux int;

DECLARE penalización_aux int;

select
    Tipo into tipo_aux
from
    Vendidas
where
    Cliente = ID_Cliente
    and Dia_evento = DiaDelEvento
    and Nombre_recinto = Recinto_nom
    and Ciudad_recinto = Recinto_ciudad
    and Numero_localidad = num_loc;



if tipo_aux is null then
SET msg = CONCAT('No has comprado la entrada de la localidad ', num_loc, ' para ese evento');

SIGNAL SQLSTATE '45000'
SET message_text = msg;


else

delete from
    Vendidas
where
    Cliente = ID_Cliente
    and Dia_evento = DiaDelEvento
    and Nombre_recinto = Recinto_nom
    and Ciudad_recinto = Recinto_ciudad
    and Numero_localidad = num_loc;



SELECT
    
    TiempoAnulacion,
    Penalizacion INTO 
    tiempo_aux,
    penalización_aux
FROM
    Evento
WHERE
    Dia = DiaDelEvento
    AND Nombre_recinto = Recinto_nom
    AND Ciudad_recinto = Recinto_ciudad;




IF (
    select
        date_add(DiaDelEvento, interval - tiempo_aux day)
) < NOW() THEN

SELECT
    AO.Precio into precio_aux
from
    AsocOfertas AO WHERE  Dia_Evento= DiaDelEvento
    AND Nombre_recinto = Recinto_nom
    AND Ciudad_recinto = Recinto_ciudad
    AND Tipo=tipo_aux
    AND Numero_localidad=num_loc;
       
       

INSERT into
    Anuladas (
        Cliente,
        Numero_localidad,
        Dia_evento,
        Nombre_recinto,
        Ciudad_recinto,
        Precio,
        Penalizacion
    )
VALUES
(
        ID_Cliente,
        num_loc,
        DiaDelEvento,
        Recinto_nom,
        Recinto_ciudad,
        precio_aux,
(penalización_aux / 100 * precio_aux)
    );
    
SET
    msg = CONCAT(
        'Anulación fuera del plazo máximo: ',
        (
            select
                date_add(DiaDelEvento, interval - tiempo_aux day)
        ),
        " se aplicara una penalización del ",
        penalización_aux,
        "%. Serán ",
        (penalización_aux / 100 * precio_aux),
        "€"
    );

SIGNAL SQLSTATE '45000'
SET message_text = msg;
else
SELECT
    AO.Precio into precio_aux
from
    AsocOfertas AO WHERE  Dia_Evento= DiaDelEvento
    AND Nombre_recinto = Recinto_nom
    AND Ciudad_recinto = Recinto_ciudad
    AND Tipo=tipo_aux
    AND Numero_localidad=num_loc;
INSERT into
    Anuladas (
        Cliente,
        Numero_localidad,
        Dia_evento,
        Nombre_recinto,
        Ciudad_recinto,
        Precio
        
    )
VALUES
(
        ID_Cliente,
        num_loc,
        DiaDelEvento,
        Recinto_nom,
        Recinto_ciudad,
        precio_aux
    );
    end if;

end if;

END //

DELIMITER ;

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
