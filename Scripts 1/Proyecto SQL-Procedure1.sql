-- Procedure Obtener detalle de las vistas de riesgo (global, completo, préstamos) del último mes o combinado (combinado) de un cliente

DELIMITER $$
CREATE PROCEDURE Riesgo_global_cliente(IN cliente_id VARCHAR(10), tipo_detalle VARCHAR(50))
BEGIN
    IF tipo_detalle = 'global' THEN
        SELECT * FROM riesgo_globalv_ultimo_mes WHERE id_cliente = cliente_id;
    ELSEIF tipo_detalle = 'completo' THEN
        SELECT * FROM riesgo_global_completov_ultimo_mes WHERE id_cliente = cliente_id;
    ELSEIF tipo_detalle = 'prestamos' THEN
        SELECT * FROM atrasosav_ultimo_mes WHERE id_cliente = cliente_id;
	ELSEIF tipo_detalle = 'combinado' THEN
        SELECT * FROM riesgo_globalv_combinado_mes_anterior_ultimo WHERE id_cliente = cliente_id;
    ELSE
        SELECT 'Sin dato' AS mensaje;
    END IF;
END $$
DELIMITER ; 


 call Riesgo_global_cliente('90001', 'combinado');
 
-- Procedure Obtener detalle de la conformación del riesgo credicio de un cliente por tipo de detalle según los meses informados (ultimo, combinado)

DELIMITER $$

CREATE PROCEDURE Riesgo_crediticio_cliente_detalle(IN cliente_id VARCHAR(10), detalle VARCHAR(10))
BEGIN
    IF detalle = 'ultimo' THEN
        SELECT
            aavu.maximo_mes_cierre,
            aavu.id_cliente,
            aavu.id_cuenta_A,
            aavu.riesgo_crediticio_atraso,
            tavu.total_prestamos,
            aavu.maximo_atraso,
            tavu.total_adelantos,
            aavu.atraso_adelantos,
            tavu.total_hipotecarios,
            aavu.atraso_hipotecarios,
            tavu.total_prendarios,
            aavu.atraso_prendarios,
            tavu.total_personales,
            aavu.atraso_personales
        FROM
            atrasosav_ultimo_mes aavu
        INNER JOIN
            totalesav_ultimo_mes tavu ON aavu.id_cuenta_A = tavu.id_cuenta_A
        WHERE
            aavu.id_cliente = cliente_id;
    ELSEIF detalle = 'completo' THEN
        -- Datos del último mes
        SELECT
            aavu.maximo_mes_cierre,
            aavu.id_cliente,
            aavu.id_cuenta_A,
            aavu.riesgo_crediticio_atraso,
            tavu.total_prestamos,
            aavu.maximo_atraso,
            tavu.total_adelantos,
            aavu.atraso_adelantos,
            tavu.total_hipotecarios,
            aavu.atraso_hipotecarios,
            tavu.total_prendarios,
            aavu.atraso_prendarios,
            tavu.total_personales,
            aavu.atraso_personales
        FROM
            atrasosav_ultimo_mes aavu
        INNER JOIN
            totalesav_ultimo_mes tavu ON aavu.id_cuenta_A = tavu.id_cuenta_A
        WHERE
            aavu.id_cliente = cliente_id

        UNION ALL

        -- Datos del mes anterior
        SELECT
            aava.mes_anterior,
            aava.id_cliente,
            aava.id_cuenta_A,
            aava.riesgo_crediticio_atraso,
            tava.total_prestamos,
            aava.maximo_atraso,
            tava.total_adelantos,
            aava.atraso_adelantos,
            tava.total_hipotecarios,
            aava.atraso_hipotecarios,
            tava.total_prendarios,
            aava.atraso_prendarios,
            tava.total_personales,
            aava.atraso_personales
        FROM
            atrasosav_mes_anterior aava
        INNER JOIN
            totalesav_mes_anterior tava ON aava.id_cuenta_A = tava.id_cuenta_A
        WHERE
            aava.id_cliente = cliente_id;
    END IF;
END $$

DELIMITER ;

 call Riesgo_crediticio_cliente_detalle('90001','completo');
 
 
 