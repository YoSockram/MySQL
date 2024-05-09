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