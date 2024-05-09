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
