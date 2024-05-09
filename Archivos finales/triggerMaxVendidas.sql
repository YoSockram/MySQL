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