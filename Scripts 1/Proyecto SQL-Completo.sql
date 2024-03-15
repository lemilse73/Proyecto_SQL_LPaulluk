-- Creación de la base de datos:
CREATE DATABASE IF NOT EXISTS Riesgo_Global1;

-- Uso de la base de datos:
USE Riesgo_Global1;

-- Tables:

-- Creación de Tabla Cliente (eje del modelo. Registra y acumula la totalidad de clientes. Solo se registran cuando ingresan al proceso identificando mes de ingreso):
CREATE TABLE IF NOT EXISTS Cliente (
    id_cliente VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    mes_ingreso	DATE
    );

-- Creación de Tabla Información (Registra y acumula la información de los id_clientes. Solo se registran cuando ingresan al proceso identificando mes de ingreso):
CREATE TABLE IF NOT EXISTS Informacion (
    id_cuit VARCHAR(13) PRIMARY KEY NOT NULL UNIQUE,
    id_cliente VARCHAR(10),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    nombre VARCHAR (35),
    mes_ingreso	DATE
    );
  
-- Creación de Tabla Judiciales (Registra información del PJN de los id_clientes. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS Judiciales (
	id_PJN  VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cuit_PJN VARCHAR(13),
    id_cliente VARCHAR(10),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    cantidad_causas INT,
    mes_cierre DATE
    ); 
    
 -- Creación de Tabla PN (Registra información del PN de los id_clientes. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS PN (
    Id_PN  VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cuit_PN VARCHAR(13),
    id_cliente VARCHAR(10), 
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    total_PN INT,
    mes_cierre DATE
    );    
    
     -- Creación de Tabla Pasivos (Registra información de las operaciones Pasivas de los id_clientes. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS Pasivos (
    id_cuenta_P VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cliente VARCHAR(10),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    total_pasivos INT,
    mes_cierre DATE
    );
    
     -- Creación de Tabla Lavado (Registra información de los reportes de Lavado de Activos de los id_clientes. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS Lavado (
    id_cuenta_L VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cliente VARCHAR(10),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    reporte_lavado INT,
    mes_cierre DATE
    );   
    
     -- Creación de Tabla Comex (Registra información de las operaciones de Comex de los id_clientes. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS Comex (
    id_cuenta_Cx VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cliente VARCHAR(10),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    total_comex INT, 
    sanciones_comex INT,
	mes_cierre DATE
    );  
    
    -- Creación de Tabla Cambios (Registra información de las operaciones de Cambio de los id_clientes. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS Cambios (
    id_cuenta_C VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cliente VARCHAR(10),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    total_cambios INT, 
    sanciones_cambios INT,
    mes_cierre DATE
    ); 
 
 -- Creación de Tabla Activos (Registra y acumula la totalidad de clientes con operaciones Activas. Solo se registran cuando ingresan al proceso identificando mes de ingreso):
CREATE TABLE IF NOT EXISTS Activos (
    id_cuenta_A VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cliente VARCHAR(10),
    FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente),
    mes_ingreso DATE
);


-- Creación de tabla P_Adelantos (Registra información de las operaciones Activas de Préstamos Adelantos de los id_cuenta_A. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS P_Adelantos (
    id_adelantos VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cuenta_A VARCHAR(10),
    FOREIGN KEY (id_cuenta_A) REFERENCES Activos (id_cuenta_A),
    total_adelantos INT,
    atraso_adelantos INT,
    mes_cierre DATE
);

-- Creación de tabla P_Prendarios (Registra información de las operaciones Activas de Préstamos Hipotecarios de los id_cuenta_A. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS P_Prendarios (
    id_prendarios VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cuenta_A VARCHAR(10),
    FOREIGN KEY (id_cuenta_A) REFERENCES Activos (id_cuenta_A),
    total_prendarios INT,
    atraso_prendarios INT,
    mes_cierre DATE
);

-- Creación de tabla P_Hipotecarios (Registra información de las operaciones Activas de Préstamos Prendarios de los id_cuenta_A. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS P_Hipotecarios (
    id_hipotecarios VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cuenta_A VARCHAR(10) ,
    FOREIGN KEY (id_cuenta_A) REFERENCES Activos (id_cuenta_A),
    total_hipotecarios INT,
    atraso_Hipotecarios INT,
    mes_cierre DATE
);

-- Creación de tabla P_Personales (Registra información de las operaciones Activas de Préstamos Personales de los id_cuenta_A. Se registran al cierre de cada mes informado, acumulando los datos de todos los meses):
CREATE TABLE IF NOT EXISTS P_Personales (
    id_personales VARCHAR(10) PRIMARY KEY NOT NULL UNIQUE,
    id_cuenta_A VARCHAR(10) ,
    FOREIGN KEY (id_cuenta_A) REFERENCES Activos (id_cuenta_A),
    total_personales INT,
    atraso_Personales INT,
    mes_cierre DATE
);

-- Creación de tabla Cliente_papelera (repositorio de Trigger):
CREATE TABLE IF NOT EXISTS Cliente_Papelera (
	id_cliente_papelera INT AUTO_INCREMENT PRIMARY KEY, 
	id_cliente VARCHAR(10),
	user VARCHAR(25),
	fecha TIMESTAMP
);

-- Views

-- Vistas sobre datos del último mes

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

-- Vistas sobre datos del mes anterior

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


-- Vista comparativa con los datos de riesgos de los clientes de los meses analizados (combina las vistas de riesgo global del mes anterior y el último mes).

CREATE VIEW riesgo_globalv_combinado_mes_anterior_ultimo AS
SELECT * FROM riesgo_globalv_ultimo_mes
UNION
SELECT * FROM riesgo_globalv_mes_anterior
ORDER BY id_cliente;

-- Function

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


-- Stored Procedures
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
 
 -- Triggers
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

-- INSERT

-- insert de datos cuyo origen son tablas .xls--
/*INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90001', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90002', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90003', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90004', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90005', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90006', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90007', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90008', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90009', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90010', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90011', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90012', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90013', '2023-01-31');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90014', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90015', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90016', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90017', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90018', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90019', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90020', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90021', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90022', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90023', '2023-02-28');
INSERT INTO cliente (id_cliente, mes_ingreso) VALUES ('90024', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345678', '90001', 'Juan', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345679', '90002', 'Pedro', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345680', '90003', 'Augusto', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345681', '90004', 'Andrea', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345682', '90005', 'Sofia', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345683', '90006', 'Marcos', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345684', '90007', 'Pepe', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345685', '90008', 'Maria', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345686', '90009', 'Morena', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345687', '90010', 'Malena', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345688', '90011', 'Marcelo', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345689', '90012', 'Claudio', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345690', '90013', 'Lorena', '2023-01-31');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345691', '90014', 'Sandro', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345692', '90015', 'Melchor', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345693', '90016', 'Fran', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345694', '90017', 'Jose', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345695', '90018', 'Sandra', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345696', '90019', 'Piana', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345697', '90020', 'Merlin', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345698', '90021', 'Wendy', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345699', '90022', 'Lola', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345700', '90023', 'Rodolfo', '2023-02-28');
INSERT INTO informacion (id_cuit, id_cliente, nombre, mes_ingreso) VALUES ('20012345701', '90024', 'Jey', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000001', '90001', '3000', '0', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000002', '90002', '2000', '0', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000003', '90003', '1000', '0', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000004', '90007', '2000', '0', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000005', '90008', '22000', '1', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000006', '90009', '9000', '2', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000007', '90010', '18000', '0', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000008', '90011', '9000', '0', '2023-01-31');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000009', '90004', '8000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000010', '90005', '60000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000011', '90006', '24000', '2', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000012', '90011', '34000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000013', '90014', '16000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000014', '90015', '8000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000015', '90016', '38000', '1', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000016', '90017', '17000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000017', '90018', '68000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000018', '90019', '9000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000019', '90020', '40000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000020', '90021', '16000', '0', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000021', '90022', '36000', '1', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000022', '90023', '23000', '1', '2023-02-28');
INSERT INTO cambios (id_cuenta_C, id_cliente, total_cambios, sanciones_cambios, mes_cierre) VALUES ('CA000023', '90024', '88000', '1', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000001', '90001', '5000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000002', '90002', '3000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000003', '90003', '4000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000004', '90004', '10000', '2', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000005', '90005', '15000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000006', '90006', '10000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000007', '90007', '2000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000008', '90008', '8000', '4', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000009', '90009', '7000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000010', '90011', '9000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000011', '90012', '6000', '1', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000012', '90013', '5000', '0', '2023-01-31');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000013', '90004', '15000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000014', '90005', '7000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000015', '90006', '13000', '1', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000016', '90007', '12000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000017', '90011', '10000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000018', '90012', '17000', '1', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000019', '90013', '24000', '1', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000020', '90014', '12000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000021', '90015', '19000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000022', '90020', '23000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000023', '90021', '10000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000024', '90022', '8000', '1', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000025', '90023', '9000', '0', '2023-02-28');
INSERT INTO comex (id_cuenta_Cx, id_cliente, total_comex, sanciones_comex, mes_cierre) VALUES ('CX000026', '90024', '15000', '0', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000001', '90001', '20000', '2023-01-31');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000002', '90002', '30000', '2023-01-31');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000003', '90003', '50000', '2023-01-31');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000004', '90008', '23000', '2023-01-31');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000005', '90009', '22000', '2023-01-31');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000006', '90012', '31000', '2023-01-31');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000007', '90013', '23000', '2023-01-31');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000008', '90001', '30000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000009', '90002', '40000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000010', '90003', '60000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000011', '90008', '33000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000012', '90009', '32000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000013', '90010', '46000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000014', '90011', '60000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000015', '90012', '20000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000016', '90013', '10000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000017', '90014', '39000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000018', '90015', '80000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000019', '90016', '39000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000020', '90021', '25000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000021', '90022', '45000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000022', '90023', '100000', '2023-02-28');
INSERT INTO pasivos (id_cuenta_P, id_cliente, total_pasivos, mes_cierre) VALUES ('P0000023', '90024', '55000', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00001', '20012345678', '90001', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00002', '20012345679', '90002', '8', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00003', '20012345680', '90003', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00004', '20012345681', '90004', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00005', '20012345683', '90006', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00006', '20012345684', '90007', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00007', '20012345685', '90008', '3', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00008', '20012345686', '90009', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00009', '20012345687', '90010', '4', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00010', '20012345688', '90011', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00011', '20012345689', '90012', '2', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00012', '20012345690', '90013', '0', '2023-01-31');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00013', '20012345691', '90014', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00014', '20012345692', '90015', '1', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00015', '20012345693', '90016', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00016', '20012345694', '90017', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00017', '20012345695', '90018', '1', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00018', '20012345696', '90019', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00019', '20012345697', '90020', '1', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00020', '20012345698', '90021', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00021', '20012345699', '90022', '1', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00022', '20012345700', '90023', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00023', '20012345701', '90024', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00024', '20012345678', '90001', '1', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00025', '20012345679', '90002', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00026', '20012345680', '90003', '3', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00027', '20012345681', '90004', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00028', '20012345682', '90005', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00029', '20012345684', '90007', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00030', '20012345685', '90008', '8', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00031', '20012345686', '90009', '1', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00032', '20012345687', '90010', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00033', '20012345688', '90011', '0', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00034', '20012345689', '90012', '5', '2023-02-28');
INSERT INTO judiciales (id_PJN, id_cuit_PJN, id_cliente, cantidad_causas, mes_cierre) VALUES ('PJN00035', '20012345690', '90013', '0', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000001', '20012345678', '90001', '10000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000002', '20012345679', '90002', '20000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000003', '20012345680', '90003', '-2000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000004', '20012345681', '90004', '15000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000005', '20012345683', '90006', '33000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000006', '20012345684', '90007', '11000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000007', '20012345685', '90008', '25000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000008', '20012345686', '90009', '4000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000009', '20012345687', '90010', '13000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000010', '20012345688', '90011', '34000', '2023-01-31');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000011', '20012345691', '90014', '12000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000012', '20012345692', '90015', '30000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000013', '20012345693', '90016', '10000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000014', '20012345694', '90017', '11000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000015', '20012345695', '90018', '35000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000016', '20012345696', '90019', '13000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000017', '20012345697', '90020', '35000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000018', '20012345698', '90021', '16000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000019', '20012345699', '90022', '9000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000020', '20012345700', '90023', '36000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000021', '20012345701', '90024', '14000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000022', '20012345678', '90001', '45000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000023', '20012345680', '90003', '28000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000024', '20012345681', '90004', '5000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000025', '20012345682', '90005', '38000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000026', '20012345684', '90007', '16000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000027', '20012345685', '90008', '50000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000028', '20012345686', '90009', '34000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000029', '20012345687', '90010', '3000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000030', '20012345688', '90011', '39000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000031', '20012345689', '90012', '17000', '2023-02-28');
INSERT INTO pn (id_PN, id_cuit_PN, id_cliente, total_PN, mes_cierre) VALUES ('PN000032', '20012345690', '90013', '55000', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000001', '90003', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000002', '90004', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000003', '90005', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000004', '90006', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000005', '90007', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000006', '90008', '1', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000007', '90009', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000008', '90010', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000009', '90011', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000010', '90012', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000011', '90013', '0', '2023-01-31');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000012', '90014', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000013', '90017', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000014', '90018', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000015', '90019', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000016', '90020', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000017', '90021', '2', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000018', '90022', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000019', '90023', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000020', '90024', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000027', '90001', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000028', '90002', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000029', '90003', '3', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000030', '90004', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000031', '90005', '1', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000032', '90006', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000033', '90007', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000034', '90008', '1', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000035', '90009', '2', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000036', '90011', '0', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000037', '90012', '4', '2023-02-28');
INSERT INTO lavado (id_cuenta_L, id_cliente, reporte_lavado, mes_cierre) VALUES ('L0000038', '90013', '0', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000001', '90001', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000002', '90004', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000003', '90005', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000004', '90006', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000005', '90007', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000006', '90008', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000007', '90009', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000008', '90010', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000009', '90011', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000010', '90012', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000011', '90013', '2023-01-31');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000012', '90014', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000013', '90015', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000014', '90016', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000015', '90017', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000016', '90018', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000017', '90019', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000018', '90020', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000019', '90023', '2023-02-28');
INSERT INTO activos (id_cuenta_A, id_cliente, mes_ingreso) VALUES ('A0000020', '90024', '2023-02-28');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00001', 'A0000001', '1000', '0', '2023-01-31');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00002', 'A0000005', '3000', '90', '2023-01-31');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00003', 'A0000009', '7000', '20', '2023-01-31');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00004', 'A0000010', '8000', '0', '2023-01-31');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00005', 'A0000011', '9000', '0', '2023-01-31');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00006', 'A0000012', '10000', '10', '2023-01-31');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00007', 'A0000020', '18000', '0', '2023-02-28');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00010', 'A0000004', '21000', '30', '2023-02-28');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00011', 'A0000005', '3000', '90', '2023-02-28');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00012', 'A0000006', '23000', '0', '2023-02-28');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00013', 'A0000007', '24000', '0', '2023-02-28');
INSERT INTO p_adelantos (id_adelantos, id_cuenta_A, total_adelantos, atraso_adelantos, mes_cierre) VALUES ('AAD00014', 'A0000008', '25000', '0', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00001', 'A0000001', '200000', '0', '2023-01-31');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00002', 'A0000004', '300000', '30', '2023-01-31');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00003', 'A0000005', '400000', '90', '2023-01-31');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00004', 'A0000006', '500000', '0', '2023-01-31');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00005', 'A0000007', '600000', '175', '2023-01-31');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00006', 'A0000008', '700000', '0', '2023-01-31');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00007', 'A0000009', '800000', '20', '2023-01-31');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00008', 'A0000014', '1300000', '0', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00009', 'A0000019', '1800000', '45', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00010', 'A0000020', '1900000', '0', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00013', 'A0000001', '10000', '0', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00014', 'A0000004', '300000', '60', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00015', 'A0000005', '400000', '120', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00016', 'A0000006', '400000', '0', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00017', 'A0000008', '600000', '0', '2023-02-28');
INSERT INTO p_hipotecarios (id_hipotecarios, id_cuenta_A, total_hipotecarios, atraso_hipotecarios, mes_cierre) VALUES ('AHI00018', 'A0000009', '500000', '0', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00001', 'A0000001', '1000', '0', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00002', 'A0000004', '2000', '30', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00003', 'A0000005', '3000', '90', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00004', 'A0000007', '5000', '175', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00005', 'A0000008', '6000', '0', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00006', 'A0000010', '8000', '0', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00007', 'A0000012', '10000', '10', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00008', 'A0000013', '11000', '0', '2023-01-31');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00009', 'A0000014', '12000', '0', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00010', 'A0000015', '13000', '200', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00011', 'A0000016', '14000', '300', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00012', 'A0000017', '15000', '0', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00013', 'A0000004', '2000', '30', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00014', 'A0000005', '4000', '120', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00015', 'A0000006', '15000', '0', '2023-02-28');
INSERT INTO p_prendarios (id_prendarios, id_cuenta_A, total_prendarios, atraso_prendarios, mes_cierre) VALUES ('APR00016', 'A0000007', '6000', '205', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00001', 'A0000001', '800', '0', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00002', 'A0000004', '900', '30', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00003', 'A0000005', '1000', '90', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00004', 'A0000006', '1100', '0', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00005', 'A0000007', '1200', '175', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00006', 'A0000008', '1300', '0', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00007', 'A0000009', '1400', '20', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00008', 'A0000010', '1500', '0', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00009', 'A0000011', '1600', '0', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00010', 'A0000012', '1700', '10', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00011', 'A0000013', '1800', '0', '2023-01-31');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00012', 'A0000014', '1900', '0', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00013', 'A0000016', '2100', '300', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00014', 'A0000018', '2300', '0', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00015', 'A0000020', '2500', '0', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00017', 'A0000001', '2800', '0', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00018', 'A0000004', '1100', '60', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00019', 'A0000007', '3200', '205', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00020', 'A0000008', '3300', '0', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00021', 'A0000009', '1600', '50', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00022', 'A0000011', '1000', '0', '2023-02-28');
INSERT INTO p_personales (id_personales, id_cuenta_A, total_personales, atraso_personales, mes_cierre) VALUES ('APE00023', 'A0000012', '1900', '40', '2023-02-28');
*/

-- Usuarios y Privilegios

create user "usuario"@"localhost" identified by "123";
create user "usuario1"@"localhost" identified by "456";
create user "usuario2"@"localhost" identified by "789";

-- Permisos otorgados

-- Usuario con todos los privilegios sobre la BD

grant all privileges on *.* to "usuario"@"localhost";

-- Usuario1 con todos los privilegios sobre la tabla Información

grant all on riesgo_global1.informacion to "usuario1"@"localhost";

-- Usuario2 con privilegio de Select sobre toda la BD

grant select on *.* to "usuario2"@"localhost"; 

 
