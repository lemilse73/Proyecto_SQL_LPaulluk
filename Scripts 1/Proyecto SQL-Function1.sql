-- Funcion Count Riesgo Global por tipo de riesgo último mes ((prestamos/comex/cambios/pasivo/patrimonial/lavado/juridico)) y valor final (Normal/Moderado/Alto).

DELIMITER $$

CREATE FUNCTION riesgo_global_count_ultimo_mes (riesgo varchar(10), riesgo_valor varchar(10)) RETURNS INT READS SQL DATA DETERMINISTIC
BEGIN
    DECLARE riesgo_cliente_Count INT;
    IF (riesgo = 'prestamos' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
        IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_crediticio_atraso = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_crediticio_atraso = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_crediticio_atraso = 'Normal';
        END IF;
	ELSEIF (riesgo = 'comex' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
        IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_comex = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_comex = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_comex = 'Normal';
        END IF;
    ELSEIF (riesgo = 'cambios' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
        IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_cambios = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_cambios = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_cambios = 'Normal';
        END IF;
	ELSEIF (riesgo = 'pasivo' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
		IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_pasivo = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_pasivo = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_pasivo = 'Normal';
        END IF;
    ELSEIF (riesgo = 'patrimonial' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
        IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_patrimonial = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_patrimonial = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_patrimonial = 'Normal';
        END IF;
    ELSEIF (riesgo = 'lavado' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
        IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_lavado = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_lavado = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_lavado = 'Normal';
        END IF;
	ELSEIF (riesgo = 'juridico' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
        IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_juridico = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_juridico = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_juridico = 'Normal';
        END IF;
	ELSEIF (riesgo = 'global' AND riesgo_valor IN ('Alto', 'Moderado', 'Normal')) THEN
        IF riesgo_valor = 'Alto' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_global = 'Alto';
        ELSEIF riesgo_valor = 'Moderado' THEN
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_global = 'Moderado';
        ELSE
            SELECT COUNT(*) INTO riesgo_cliente_Count FROM riesgo_globalv_ultimo_mes WHERE riesgo_global = 'Normal';
        END IF;
    ELSE
       SET riesgo_cliente_Count = -1; 
    END IF;
    RETURN riesgo_cliente_Count;
END$$
DELIMITER ;

SELECT riesgo_global_count_ultimo_mes('prestamos','Alto');


-- Funcion Valor Riesgo por cliente y tipo de riesgo (prestamos/comex/cambios/pasivo/patrimonial/lavado/juridico) del último mes

DELIMITER $$

CREATE FUNCTION riesgo_tipo_cliente_ultimo_mes (cliente_id VARCHAR(10), riesgo VARCHAR(10)) RETURNS VARCHAR(100) READS SQL DATA DETERMINISTIC
BEGIN
    DECLARE riesgo_valor VARCHAR(100);

    IF riesgo = 'prestamos' THEN
        SELECT riesgo_crediticio_atraso INTO riesgo_valor FROM Riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id LIMIT 1;
    ELSEIF riesgo = 'comex' THEN
        SELECT riesgo_comex INTO riesgo_valor FROM Riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id LIMIT 1;  
    ELSEIF riesgo = 'cambios' THEN
        SELECT riesgo_cambios INTO riesgo_valor FROM Riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id LIMIT 1;   
    ELSEIF riesgo = 'pasivo' THEN
        SELECT riesgo_pasivo INTO riesgo_valor FROM Riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id LIMIT 1;   
    ELSEIF riesgo = 'patrimonial' THEN
        SELECT riesgo_patrimonial INTO riesgo_valor FROM Riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id LIMIT 1;    
    ELSEIF riesgo = 'lavado' THEN
        SELECT riesgo_lavado INTO riesgo_valor FROM Riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id LIMIT 1;   
    ELSEIF riesgo = 'juridico' THEN
        SELECT riesgo_juridico INTO riesgo_valor FROM Riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id LIMIT 1;   
    ELSE
        SET riesgo_valor = "Sin dato";
    END IF;

    RETURN riesgo_valor;
END$$

DELIMITER ;


SELECT riesgo_tipo_cliente_ultimo_mes('90001', 'comex');
