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
