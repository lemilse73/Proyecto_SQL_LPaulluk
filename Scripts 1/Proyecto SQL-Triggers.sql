-- Trigger clientes_eliminados con identificación de usuario y fecha

DELIMITER $$

CREATE TRIGGER clientes_eliminados

BEFORE DELETE ON cliente
FOR EACH ROW

BEGIN
     INSERT INTO  Cliente_papelera (id_cliente, user,fecha)
	 VALUE (OLD.id_cliente, user(), now());

END $$

DELIMITER ;

delete from cliente where id_cliente = 90001;


