-- Vista Totales de préstamos con detalle del monto por tipo de préstamo activo y determinación del total general, datos del último mes.

CREATE VIEW TotalesAV_ultimo_mes AS
SELECT 
    GREATEST(
        COALESCE(P_A.mes_cierre, 0),
        COALESCE(P_H.mes_cierre, 0),
        COALESCE(P_P.mes_cierre, 0),
        COALESCE(P_Pe.mes_cierre, 0)
    ) AS maximo_mes_cierre,
    A.id_cliente, 
    A.id_cuenta_A,
    COALESCE(P_A.total_adelantos, 0) AS total_adelantos,
    COALESCE(P_H.total_hipotecarios, 0) AS total_hipotecarios,
    COALESCE(P_P.total_prendarios, 0) AS total_prendarios,
    COALESCE(P_Pe.total_personales, 0) AS total_personales,
    (
        COALESCE(P_A.total_adelantos, 0)+
        COALESCE(P_H.total_hipotecarios, 0)+
        COALESCE(P_P.total_prendarios, 0)+
        COALESCE(P_Pe.total_personales, 0)
    ) AS total_prestamos
FROM 
    Activos A
LEFT JOIN (
    SELECT id_cuenta_A, total_adelantos, mes_cierre
    FROM P_Adelantos
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Adelantos)
) P_A ON P_A.id_cuenta_A = A.id_cuenta_A
LEFT JOIN (
    SELECT id_cuenta_A, total_hipotecarios, mes_cierre
    FROM P_Hipotecarios
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Hipotecarios)
) P_H ON P_H.id_cuenta_A = A.id_cuenta_A
LEFT JOIN (
    SELECT id_cuenta_A, total_prendarios, mes_cierre
    FROM P_Prendarios
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Prendarios)
) P_P ON P_P.id_cuenta_A = A.id_cuenta_A
LEFT JOIN (
    SELECT id_cuenta_A, total_personales, mes_cierre
    FROM P_Personales
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Personales)
) P_Pe ON P_Pe.id_cuenta_A = A.id_cuenta_A
WHERE 
    GREATEST(
        COALESCE(P_A.mes_cierre, 0),
        COALESCE(P_H.mes_cierre, 0),
        COALESCE(P_P.mes_cierre, 0),
        COALESCE(P_Pe.mes_cierre, 0)
    ) <> 0;

-- Vista Atrasos con detalle del atraso por tipo de préstamo activo y determinación el atraso mayor, del último mes.

CREATE VIEW AtrasosAV_ultimo_mes AS
SELECT 
	GREATEST(
        COALESCE(P_A.mes_cierre, 0),
        COALESCE(P_H.mes_cierre, 0),
        COALESCE(P_P.mes_cierre, 0),
        COALESCE(P_Pe.mes_cierre, 0)
    ) AS maximo_mes_cierre,
    A.id_cliente, 
    A.id_cuenta_A,
    COALESCE(P_A.atraso_adelantos, 0) AS atraso_adelantos,
    COALESCE(P_H.atraso_hipotecarios, 0) AS atraso_hipotecarios,
    COALESCE(P_P.atraso_prendarios, 0) AS atraso_prendarios,
    COALESCE(P_Pe.atraso_personales, 0) AS atraso_personales,
    GREATEST(
        COALESCE(P_A.atraso_adelantos, 0),
        COALESCE(P_H.atraso_hipotecarios, 0),
        COALESCE(P_P.atraso_prendarios, 0),
        COALESCE(P_Pe.atraso_personales, 0)
    ) AS maximo_atraso,
    CASE
        WHEN GREATEST(
            COALESCE(P_A.atraso_adelantos, 0),
            COALESCE(P_H.atraso_hipotecarios, 0),
            COALESCE(P_P.atraso_prendarios, 0),
            COALESCE(P_Pe.atraso_personales, 0)
        ) < 60 THEN 'Normal'
        WHEN GREATEST(
            COALESCE(P_A.atraso_adelantos, 0),
            COALESCE(P_H.atraso_hipotecarios, 0),
            COALESCE(P_P.atraso_prendarios, 0),
            COALESCE(P_Pe.atraso_personales, 0)
        ) < 90 THEN 'Moderado'
        ELSE 'Alto'
    END AS Riesgo_crediticio_atraso
FROM 
    Activos A
LEFT JOIN (
    SELECT id_cuenta_A, atraso_adelantos, mes_cierre
    FROM P_Adelantos
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Adelantos)
) P_A ON P_A.id_cuenta_A = A.id_cuenta_A
LEFT JOIN (
    SELECT id_cuenta_A, atraso_hipotecarios, mes_cierre
    FROM P_Hipotecarios
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Hipotecarios)
) P_H ON P_H.id_cuenta_A = A.id_cuenta_A
LEFT JOIN (
    SELECT id_cuenta_A, atraso_prendarios, mes_cierre
    FROM P_Prendarios
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Prendarios)
) P_P ON P_P.id_cuenta_A = A.id_cuenta_A
LEFT JOIN (
    SELECT id_cuenta_A, atraso_personales, mes_cierre
    FROM P_Personales
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM P_Personales)
) P_Pe ON P_Pe.id_cuenta_A = A.id_cuenta_A
WHERE 
    GREATEST(
        COALESCE(P_A.mes_cierre, 0),
        COALESCE(P_H.mes_cierre, 0),
        COALESCE(P_P.mes_cierre, 0),
        COALESCE(P_Pe.mes_cierre, 0)
    ) <> 0;


-- Vista Riesgo_Global Completo con detarminación del valor (Normal, Moderado, Alto) por tipo de Riesgo (Pasivo, Patrimonial, Lavado, Juridico, por Comex, por operaciones de Cambio, Activo) y detalle de la variable fuente, del último mes.

CREATE VIEW riesgo_globalv_ultimo_mes AS
SELECT 
	GREATEST(
        COALESCE(Aavu.maximo_mes_cierre, 0),
        COALESCE(Co.mes_cierre, 0),
        COALESCE(Ca.mes_cierre, 0),
        COALESCE(P.mes_cierre, 0),
        COALESCE(PN.mes_cierre, 0),
        COALESCE(L.mes_cierre, 0),
        COALESCE(J.mes_cierre, 0)
    ) AS maximo_mes_cierre,
    C.id_cliente, 
    I.id_cuit,
    I.nombre,
    Aavu.riesgo_crediticio_atraso,
	CASE
        WHEN Co.sanciones_comex = 0 THEN 'Normal'
        WHEN Co.sanciones_comex < 3 THEN 'Moderado'
        ELSE 'Alto'
    END AS Riesgo_comex,
    CASE
        WHEN Ca.sanciones_cambios = 0 THEN 'Normal'
        WHEN Ca.sanciones_cambios < 3 THEN 'Moderado'
        ELSE 'Alto'
    END AS Riesgo_cambios,
    CASE
        WHEN P.total_pasivos > 100000 THEN 'Normal'
        WHEN P.total_pasivos > 0 THEN 'Moderado'
        ELSE 'Alto'
    END AS Riesgo_pasivo,
    CASE
        WHEN PN.total_PN > 200000 THEN 'Normal'
        WHEN PN.total_PN > 0 THEN 'Moderado'
        ELSE 'Alto'
    END AS Riesgo_patrimonial,
    CASE
        WHEN L.reporte_lavado = 0 THEN 'Normal'
        WHEN L.reporte_lavado < 2 THEN 'Moderado'
        ELSE 'Alto'
    END AS Riesgo_lavado,
    CASE
        WHEN J.cantidad_causas = 0 THEN 'Normal'
        WHEN J.cantidad_causas < 2 THEN 'Moderado'
        ELSE 'Alto'
    END AS Riesgo_juridico,
    CASE
        WHEN 'Alto' IN (
            Co.sanciones_comex,
            Ca.sanciones_cambios,
            P.total_pasivos,
            PN.total_PN,
            L.reporte_lavado,
            J.cantidad_causas
        ) THEN 'Alto'
        WHEN 'Moderado' IN (
            Co.sanciones_comex,
            Ca.sanciones_cambios,
            P.total_pasivos,
            PN.total_PN,
            L.reporte_lavado,
            J.cantidad_causas
        ) THEN 'Moderado'
        ELSE 'Normal'
    END AS Riesgo_global
FROM 
    Cliente C
JOIN informacion I ON I.id_cliente = C.id_cliente
JOIN atrasosav_ultimo_mes Aavu ON Aavu.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, sanciones_comex, mes_cierre
    FROM comex
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM comex)
) Co ON Co.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, sanciones_cambios, mes_cierre
    FROM cambios
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM cambios)
) Ca ON Ca.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, total_pasivos, mes_cierre
    FROM pasivos
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM pasivos)
) P ON P.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, total_PN, mes_cierre
    FROM PN
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM PN)
) PN ON PN.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, reporte_lavado, mes_cierre
    FROM lavado
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM lavado)
) L ON L.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, cantidad_causas, mes_cierre
    FROM judiciales
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM judiciales)
) J ON J.id_cliente = C.id_cliente;

-- Vista Riesgo_Global Otros incluyendo el resto de la información de las tablas de datos del último mes para conformar la vista de Riesgo Global COmpleto.

CREATE VIEW Riesgo_Global_otrosV_ultimo_mes AS
SELECT 
    GREATEST(
        COALESCE(Tavu.maximo_mes_cierre, 0),
        COALESCE(Co.mes_cierre, 0),
        COALESCE(Ca.mes_cierre, 0),
        COALESCE(P.mes_cierre, 0),
        COALESCE(PN.mes_cierre, 0),
        COALESCE(L.mes_cierre, 0),
        COALESCE(J.mes_cierre, 0)
    ) AS maximo_mes_cierre,
    C.id_cliente, 
    COALESCE(Tavu.total_prestamos, 0) AS total_activos,
    COALESCE(Co.total_comex, 0) AS total_comex,
    COALESCE(Ca.total_cambios, 0) AS total_cambios,
    COALESCE(P.total_pasivos, 0) AS total_pasivos,
    COALESCE(PN.total_PN, 0) AS total_PN,
    COALESCE(L.reporte_lavado, 0) AS Cantidad_reportes,
    COALESCE(J.cantidad_causas, 0) AS cantidad_causas
FROM 
    Cliente C
JOIN totalesav_ultimo_mes Tavu ON Tavu.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, total_comex, mes_cierre
    FROM comex
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM comex)
) Co ON Co.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, total_cambios, mes_cierre
    FROM cambios
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM cambios)
) Ca ON Ca.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, total_pasivos, mes_cierre
    FROM pasivos
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM pasivos)
) P ON P.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, total_PN, mes_cierre
    FROM PN
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM PN)
) PN ON PN.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, reporte_lavado, mes_cierre
    FROM lavado
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM lavado)
) L ON L.id_cliente = C.id_cliente
LEFT JOIN (
    SELECT id_cliente, cantidad_causas, mes_cierre
    FROM judiciales
    WHERE mes_cierre = (SELECT MAX(mes_cierre) FROM judiciales)
) J ON J.id_cliente = C.id_cliente;



-- Vista Riesgo_Global Completo con detarminación del valor por tipo de Riesgo y detalle de la variable fuente, del ultimo mes. Se conforma con un Join entre las vista riesgo_globalv_ultimo_mes y riesgo_global_otrosv_ultimo_mes en razón de inconsistencia del programa al generar el mismo proceso en una sola consulta.

CREATE VIEW Riesgo_Global_completoV_ultimo_mes AS
SELECT 
    RGvu.maximo_mes_cierre,
    RGvu.id_cliente, 
    RGvu.id_cuit,
    RGvu.nombre,
    RGvu.riesgo_crediticio_atraso,
    Tavu.total_prestamos AS total_activos,
	RGvu.Riesgo_comex,
	RGovu.total_comex,
	RGvu.Riesgo_cambios,
	RGovu.total_cambios,
	RGvu.Riesgo_pasivo,
	RGovu.total_pasivos,
	RGvu.Riesgo_patrimonial,
	RGovu.total_PN, 
    RGvu.Riesgo_lavado,
	RGovu.cantidad_reportes,
    RGvu.Riesgo_juridico,
	RGovu.cantidad_causas,
	RGvu.Riesgo_global
FROM 
    Cliente C
JOIN riesgo_globalv_ultimo_mes RGvu ON RGvu.id_cliente = C.id_cliente
JOIN totalesav_ultimo_mes Tavu ON Tavu.id_cliente = C.id_cliente
JOIN riesgo_global_otrosv_ultimo_mes RGovu ON RGovu.id_cliente = C.id_cliente;



