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