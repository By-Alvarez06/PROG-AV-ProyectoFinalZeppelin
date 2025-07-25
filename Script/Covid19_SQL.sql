CREATE SCHEMA msp_covid;
USE msp_covid;

-- Creacion de la tabla principal, con la informacion de los casos de COVID en el ECUADOR
CREATE TABLE m_covid (
    fecha_notificacion DATE,
    anio_notificacion INT,
    mes_notificacion INT,
    dia_notificacion INT,
    
    cod_provincia INT,
    provincia VARCHAR(100),
    cod_canton INT,
    canton VARCHAR(100),

    fecha_atencion DATE,
    anio_atencion INT,
    mes_atencion INT,
    dia_atencion INT,

    cod_provincia_residencia INT,
    provincia_residencia VARCHAR(100),
    cod_canton_residencia INT,
    canton_residencia VARCHAR(100),

    edad_paciente INT,
    tipo_edad VARCHAR(20), -- Ej. ANIOS, MESES, DIAS
    sexo_paciente VARCHAR(10), -- Ej. HOMBRE, MUJER

    condicion_final VARCHAR(20), -- Ej. VIVO, FALLECIDO
    fecha_defuncion DATE,
    anio_defuncion INT,
    mes_defuncion INT,
    dia_defuncion INT,

    clasificacion_final VARCHAR(50),
    ae_se_notificacion VARCHAR(20) -- Parece ser un código epidemiológico (ej. 202038)
);

-- Importacion de la informacion utilizando el comando LOAD DATA para mejorar tiempo de importacion
-- debido a la cantidad de datos (2 864 033)
-- Desde consola: mysql --local-infile=1 -u root -p
LOAD DATA LOCAL INFILE '/home/byron/Descargas/Covid19Clean.csv'
INTO TABLE m_covid
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Agregamos un ID a la tabla m_covid
ALTER TABLE `msp_covid`.`m_covid` 
ADD COLUMN `id` INT NOT NULL AUTO_INCREMENT FIRST,
ADD PRIMARY KEY (`id`);
;

-- Agregamos un ID a la tabla cantones
ALTER TABLE `msp_covid`.`cantones` 
CHANGE COLUMN `cod_canton` `cod_canton` INT NOT NULL ,
CHANGE COLUMN `cod_prov` `cod_prov` INT NOT NULL ,
ADD PRIMARY KEY (`cod_canton`, `cod_prov`);
;

-- Agregamos un ID a la tabla provincias
ALTER TABLE `msp_covid`.`provincias` 
CHANGE COLUMN `cod_prov` `cod_prov` INT NOT NULL ,
ADD PRIMARY KEY (`cod_prov`);
;

SELECT count(*)
FROM m_covid;

-- Exportar informacion en un CSV para cargar en Zeppelin: Covid19Export.csv

-- Insertamos los datos de provincias, cantones
-- Y la poblacion tomado del CSV pop_2022

CREATE TABLE poblacion(
	cod_canton INT,
    cod_provincia INT,
    cant_poblacion INT
);

SELECT *
FROM m_covid;
    
-- Cambiar parametros de SQL para permitir mas tiempo de conexion en consultas pesadas
SET SESSION net_read_timeout=600;
SET SESSION net_write_timeout=600;
SET SESSION wait_timeout=600;

-- Consultas SQL para muestra de datos
-- 1
SELECT 
	 tipo_edad,
     COUNT(edad_paciente) AS 'count',
     AVG(edad_paciente) AS 'mean',
     STDDEV(edad_paciente) AS 'stddev',
     MIN(edad_paciente) AS 'min',
     MAX(edad_paciente) AS 'max'
FROM m_covid
GROUP BY tipo_edad;

-- 2
SELECT edad_paciente, COUNT(*)
FROM m_covid
WHERE tipo_edad = 'ANIOS'
GROUP BY edad_paciente
ORDER BY edad_paciente ASC;

-- 3
SELECT clasificacion_final, anio_notificacion, COUNT(*)
FROM m_covid
GROUP BY clasificacion_final, anio_notificacion;

SELECT 
    clasificacion_final,
    COUNT(CASE WHEN anio_notificacion = 2020 THEN 1 END) AS `2020`,
    COUNT(CASE WHEN anio_notificacion = 2021 THEN 1 END) AS `2021`,
    COUNT(CASE WHEN anio_notificacion = 2022 THEN 1 END) AS `2022`
FROM m_covid
GROUP BY clasificacion_final;



