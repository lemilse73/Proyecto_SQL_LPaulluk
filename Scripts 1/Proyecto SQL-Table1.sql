-- Creación de la base de datos:
CREATE DATABASE IF NOT EXISTS Riesgo_Global1;

-- Uso de la base de datos:
USE Riesgo_Global1;

-- Tablas:

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

