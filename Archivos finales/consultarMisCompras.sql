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