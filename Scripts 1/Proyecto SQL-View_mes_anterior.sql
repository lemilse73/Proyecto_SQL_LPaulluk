-- Vista Totales de préstamos con detalle del monto por tipo de préstamo activo y determinación del total general, datos del mes anterior.

CREATE VIEW TotalesAV_mes_anterior AS
SELECT 
    LAST_DAY(DATE_SUB(Tavu.maximo_mes_cierre, INTERVAL 1 MONTH)) AS mes_anterior,
    A.id_cliente, 
    A.id_cuenta_A,
    COALESCE(P_A.total_adelantos, 0) AS total_adelantos,
    COALESCE(P_H.total_hipotecarios, 0) AS total_hipotecarios,
    COALESCE(P_P.total_prendarios, 0) AS total_prendarios,
    COALESCE(P_Pe.total_personales, 0) AS total_personales,
    (
        COALESCE(P_A.total_adelantos, 0) +
        COALESCE(P_H.total_hipotecarios, 0) +
        COALESCE(P_P.total_prendarios, 0) +
        COALESCE(P_Pe.total_personales, 0)
    ) AS total_prestamos
FROM 
    Activos A
JOIN totalesav_ultimo_mes Tavu ON A.id_cliente = Tavu.id_cliente
LEFT JOIN P_Adelantos P_A ON A.id_cuenta_A = P_A.id_cuenta_A AND P_A.mes_cierre = LAST_DAY(DATE_SUB(Tavu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN P_Hipotecarios P_H ON A.id_cuenta_A = P_H.id_cuenta_A AND P_H.mes_cierre = LAST_DAY(DATE_SUB(Tavu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN P_Prendarios P_P ON A.id_cuenta_A = P_P.id_cuenta_A AND P_P.mes_cierre = LAST_DAY(DATE_SUB(Tavu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN P_Personales P_Pe ON A.id_cuenta_A = P_Pe.id_cuenta_A AND P_Pe.mes_cierre = LAST_DAY(DATE_SUB(Tavu.maximo_mes_cierre, INTERVAL 1 MONTH))
WHERE 
    GREATEST(
        COALESCE(P_A.mes_cierre, 0),
        COALESCE(P_H.mes_cierre, 0),
        COALESCE(P_P.mes_cierre, 0),
        COALESCE(P_Pe.mes_cierre, 0)
    ) <> 0;



-- Vista Atrasos con detalle del atraso por tipo de préstamo activo y determinación el atraso mayor, del mes anterior.

CREATE VIEW AtrasosAV_mes_anterior AS
SELECT 
	LAST_DAY(DATE_SUB(Aavu.maximo_mes_cierre, INTERVAL 1 MONTH)) AS mes_anterior,
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
JOIN atrasosav_ultimo_mes Aavu ON A.id_cliente = Aavu.id_cliente
LEFT JOIN P_Adelantos P_A ON A.id_cuenta_A = P_A.id_cuenta_A AND P_A.mes_cierre = LAST_DAY(DATE_SUB(Aavu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN P_Hipotecarios P_H ON A.id_cuenta_A = P_H.id_cuenta_A AND P_H.mes_cierre = LAST_DAY(DATE_SUB(Aavu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN P_Prendarios P_P ON A.id_cuenta_A = P_P.id_cuenta_A AND P_P.mes_cierre = LAST_DAY(DATE_SUB(Aavu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN P_Personales P_Pe ON A.id_cuenta_A = P_Pe.id_cuenta_A AND P_Pe.mes_cierre = LAST_DAY(DATE_SUB(Aavu.maximo_mes_cierre, INTERVAL 1 MONTH))
WHERE 
    GREATEST(
        COALESCE(P_A.mes_cierre, 0),
        COALESCE(P_H.mes_cierre, 0),
        COALESCE(P_P.mes_cierre, 0),
        COALESCE(P_Pe.mes_cierre, 0)
) <> 0;


-- Vista Riesgo_Global Completo con detarminación del valor (Normal, Moderado, Alto) por tipo de Riesgo (Pasivo, Patrimonial, Lavado, Juridico, por Comex, por operaciones de Cambio, Activo) y detalle de la variable fuente, del último mes.

CREATE VIEW riesgo_globalv_mes_anterior AS
 SELECT 
	 LAST_DAY(DATE_SUB(RGvu.maximo_mes_cierre, INTERVAL 1 MONTH)) AS mes_anterior,
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
 JOIN riesgo_globalv_ultimo_mes RGvu ON RGvu.id_cliente = C.id_cliente
 JOIN informacion I ON I.id_cliente = C.id_cliente
 JOIN atrasosav_ultimo_mes Aavu ON Aavu.id_cliente = C.id_cliente
 LEFT JOIN Comex Co ON Co.id_cliente = C.id_cliente AND Co.mes_cierre = LAST_DAY(DATE_SUB(RGvu.maximo_mes_cierre, INTERVAL 1 MONTH))
 LEFT JOIN cambios Ca ON Ca.id_cliente = C.id_cliente AND Ca.mes_cierre = LAST_DAY(DATE_SUB(RGvu.maximo_mes_cierre, INTERVAL 1 MONTH))
 LEFT JOIN pasivos P ON P.id_cliente = C.id_cliente AND P.mes_cierre = LAST_DAY(DATE_SUB(RGvu.maximo_mes_cierre, INTERVAL 1 MONTH))
 LEFT JOIN PN PN ON PN.id_cliente = C.id_cliente AND PN.mes_cierre = LAST_DAY(DATE_SUB(RGvu.maximo_mes_cierre, INTERVAL 1 MONTH))
 LEFT JOIN lavado L ON L.id_cliente = C.id_cliente AND L.mes_cierre = LAST_DAY(DATE_SUB(RGvu.maximo_mes_cierre, INTERVAL 1 MONTH))
 LEFT JOIN judiciales J ON J.id_cliente = C.id_cliente AND J.mes_cierre = LAST_DAY(DATE_SUB(RGvu.maximo_mes_cierre, INTERVAL 1 MONTH));

-- Vista Riesgo_Global Otros incluyendo el resto de la información de las tablas de datos del último mes para conformar la vista de Riesgo Global COmpleto.

CREATE VIEW Riesgo_Global_otrosV_mes_anterior AS
SELECT 
    LAST_DAY(DATE_SUB(RGovu.maximo_mes_cierre, INTERVAL 1 MONTH)) AS mes_anterior,
    C.id_cliente, 
    COALESCE(Tavma.total_prestamos, 0) AS total_activos,
    COALESCE(Co.total_comex, 0) AS total_comex,
    COALESCE(Ca.total_cambios, 0) AS total_cambios,
    COALESCE(P.total_pasivos, 0) AS total_pasivos,
    COALESCE(PN.total_PN, 0) AS total_PN,
    COALESCE(L.reporte_lavado, 0) AS Cantidad_reportes,
    COALESCE(J.cantidad_causas, 0) AS cantidad_causas
FROM 
    Cliente C
JOIN totalesav_mes_anterior Tavma ON Tavma.id_cliente = C.id_cliente
JOIN riesgo_global_otrosv_ultimo_mes RGovu ON RGovu.id_cliente = C.id_cliente
LEFT JOIN Comex Co ON Co.id_cliente = C.id_cliente AND Co.mes_cierre = LAST_DAY(DATE_SUB(RGovu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN cambios Ca ON Ca.id_cliente = C.id_cliente AND Ca.mes_cierre = LAST_DAY(DATE_SUB(RGovu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN pasivos P ON P.id_cliente = C.id_cliente AND P.mes_cierre = LAST_DAY(DATE_SUB(RGovu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN PN PN ON PN.id_cliente = C.id_cliente AND PN.mes_cierre = LAST_DAY(DATE_SUB(RGovu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN lavado L ON L.id_cliente = C.id_cliente AND L.mes_cierre = LAST_DAY(DATE_SUB(RGovu.maximo_mes_cierre, INTERVAL 1 MONTH))
LEFT JOIN judiciales J ON J.id_cliente = C.id_cliente AND J.mes_cierre = LAST_DAY(DATE_SUB(RGovu.maximo_mes_cierre, INTERVAL 1 MONTH));

-- Vista Riesgo_Global Completo con detarminación del valor por tipo de Riesgo y detalle de la variable fuente, del ultimo mes. Se conforma con un Join entre las vista riesgo_globalv_mes_anterior y riesgo_global_otrosv_mes_anterior en razón de inconsistencia del programa al generar el mismo proceso en una sola consulta.

CREATE VIEW Riesgo_Global_completoV_mes_anterior AS
SELECT 
    RGva.mes_anterior,
    RGva.id_cliente, 
    RGva.id_cuit,
    RGva.nombre,
    RGva.riesgo_crediticio_atraso,
    Tava.total_prestamos AS total_activos,
    RGva.Riesgo_comex,
    RGova.total_comex,
    RGva.Riesgo_cambios,
    RGova.total_cambios,
    RGva.Riesgo_pasivo,
    RGova.total_pasivos,
    RGva.Riesgo_patrimonial,
    RGova.total_PN, 
    RGva.Riesgo_lavado,
    RGova.cantidad_reportes,
    RGva.Riesgo_juridico,
    RGova.cantidad_causas,
    RGva.Riesgo_global
FROM 
    Cliente C
JOIN riesgo_globalv_mes_anterior RGva ON RGva.id_cliente = C.id_cliente
JOIN totalesav_mes_anterior Tava ON Tava.id_cliente = C.id_cliente
JOIN riesgo_global_otrosv_mes_anterior RGova ON RGova.id_cliente = C.id_cliente;


