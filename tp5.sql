-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-09-23 21:41:16.165

-- tables
-- Table: P5P1E1_ARTICULO
CREATE TABLE esq_P5P1E1.ARTICULO (
    id_articulo int  NOT NULL,
    titulo varchar(120)  NOT NULL,
    autor varchar(30)  NOT NULL,
    CONSTRAINT P5P1E1_ARTICULO_pk PRIMARY KEY (id_articulo)
);

-- Table: P5P1E1_CONTIENE
CREATE TABLE esq_P5P1E1.CONTIENE (
    id_articulo int  NOT NULL,
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    CONSTRAINT P5P1E1_CONTIENE_pk PRIMARY KEY (id_articulo,idioma,cod_palabra)
);

-- Table: P5P1E1_PALABRA
CREATE TABLE esq_P5P1E1.PALABRA (
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    descripcion varchar(25)  NOT NULL,
    CONSTRAINT P5P1E1_PALABRA_pk PRIMARY KEY (idioma,cod_palabra)
);

-- foreign keys
-- Reference: FK_P5P1E1_CONTIENE_ARTICULO (table: P5P1E1_CONTIENE)
ALTER TABLE esq_P5P1E1.CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_ARTICULO
    FOREIGN KEY (id_articulo)
    REFERENCES esq_P5P1E1.ARTICULO (id_articulo)  
	--se agrega cascade para punto a
    on delete cascade
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P1E1_CONTIENE_PALABRA (table: P5P1E1_CONTIENE)
ALTER TABLE esq_P5P1E1.CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES esq_P5P1E1.PALABRA (idioma, cod_palabra)  
    --se agrega cascade para punto a
    --on delete cascade
	--se agrega para punto b
	on delete restrict
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

---------EJERCICIO 1
--a) Cómo debería implementar las Restricciones de Integridad Referencial (RIR) si se desea que cada vez que se elimine un registro de la tabla PALABRA , también se eliminen los artículos que la referencian en la tabla CONTIENE.
	
insert into esq_p5p1e1.articulo (id_articulo, titulo, autor)
values (1, 'un titulo', 'un autor');

insert into esq_p5p1e1.palabra (cod_palabra, idioma, descripcion) 
values (1, 'ES', 'descripcion');

insert into esq_p5p1e1.contiene (id_articulo, idioma, cod_palabra)
values (1, 'ES', 1);

select * from esq_p5p1e1.articulo;
select * from esq_p5p1e1.contiene;
select * from esq_p5p1e1.palabra;

delete from esq_p5p1e1.palabra where cod_palabra = 1;

--b) Verifique qué sucede con las palabras contenidas en cada artículo, al eliminar una palabra, si definen la Acción Referencial para las bajas (ON DELETE) de la RIR correspondiente como:
-- ii) Restrict
-- rta: viola la FK!, no lo borra
-- iii) Es posible para éste ejemplo colocar SET NULL o SET DEFAULT para ON DELETE y ON UPDATE?
-- rta: no, porque no se especifico ningun default en la tabla, y la definicion de la tabla creada dice que no admite nulos

--EJERCICIO 2

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-09-24 19:20:52.273

-- tables
-- Table: TP5_P1_EJ2_AUSPICIO
CREATE TABLE tp5_p1_ej2.AUSPICIO (
    id_proyecto int  NOT NULL,
    nombre_auspiciante varchar(20)  NOT NULL,
    tipo_empleado char(2)  NULL,
    nro_empleado int  NULL,
    CONSTRAINT TP5_P1_EJ2_AUSPICIO_pk PRIMARY KEY (id_proyecto,nombre_auspiciante)
);

-- Table: TP5_P1_EJ2_EMPLEADO
CREATE TABLE tp5_p1_ej2.EMPLEADO (
    tipo_empleado char(2)  NOT NULL,
    nro_empleado int  NOT NULL,
    nombre varchar(40)  NOT NULL,
    apellido varchar(40)  NOT NULL,
    cargo varchar(15)  NOT NULL,
    CONSTRAINT TP5_P1_EJ2_EMPLEADO_pk PRIMARY KEY (tipo_empleado,nro_empleado)
);

-- Table: TP5_P1_EJ2_PROYECTO
CREATE TABLE tp5_p1_ej2.PROYECTO (
    id_proyecto int  NOT NULL,
    nombre_proyecto varchar(40)  NOT NULL,
    anio_inicio int  NOT NULL,
    anio_fin int  NULL,
    CONSTRAINT TP5_P1_EJ2_PROYECTO_pk PRIMARY KEY (id_proyecto)
);

-- Table: TP5_P1_EJ2_TRABAJA_EN
CREATE TABLE tp5_p1_ej2.TRABAJA_EN (
    tipo_empleado char(2)  NOT NULL,
    nro_empleado int  NOT NULL,
    id_proyecto int  NOT NULL,
    cant_horas int  NOT NULL,
    tarea varchar(20)  NOT NULL,
    CONSTRAINT TP5_P1_EJ2_TRABAJA_EN_pk PRIMARY KEY (tipo_empleado,nro_empleado,id_proyecto)
);

-- foreign keys
-- Reference: FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO (table: TP5_P1_EJ2_AUSPICIO)
ALTER TABLE tp5_p1_ej2.AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO
    FOREIGN KEY (tipo_empleado, nro_empleado)
    REFERENCES tp5_p1_eJ2.EMPLEADO (tipo_empleado, nro_empleado)
	MATCH FULL
    ON DELETE  SET NULL 
    ON UPDATE  RESTRICT 
;

-- Reference: FK_TP5_P1_EJ2_AUSPICIO_PROYECTO (table: TP5_P1_EJ2_AUSPICIO)
ALTER TABLE tp5_p1_ej2.AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_PROYECTO
    FOREIGN KEY (id_proyecto)
    REFERENCES tp5_p1_ej2.PROYECTO (id_proyecto)
    ON DELETE  RESTRICT 
    ON UPDATE  RESTRICT 
;

-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO (table: TP5_P1_EJ2_TRABAJA_EN)
ALTER TABLE tp5_p1_ej2.TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO
    FOREIGN KEY (tipo_empleado, nro_empleado)
    REFERENCES tp5_p1_ej2.EMPLEADO (tipo_empleado, nro_empleado)
    ON DELETE  CASCADE 
    ON UPDATE  RESTRICT 
;

-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO (table: TP5_P1_EJ2_TRABAJA_EN)
ALTER TABLE tp5_p1_ej2.TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO
    FOREIGN KEY (id_proyecto)
    REFERENCES tp5_p1_ej2.PROYECTO (id_proyecto)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
;

-- End of file.

-- EMPLEADO
INSERT INTO tp5_p1_ej2.empleado VALUES ('A ', 1, 'Juan', 'Garcia', 'Jefe');
INSERT INTO tp5_p1_ej2.empleado VALUES ('B', 1, 'Luis', 'Lopez', 'Adm');
INSERT INTO tp5_p1_ej2.empleado VALUES ('A ', 2, 'María', 'Casio', 'CIO');

-- PROYECTO
INSERT INTO tp5_p1_ej2.proyecto VALUES (1, 'Proy 1', 2019, NULL);
INSERT INTO tp5_p1_ej2.proyecto VALUES (2, 'Proy 2', 2018, 2019);
INSERT INTO tp5_p1_ej2.proyecto VALUES (3, 'Proy 3', 2020, NULL);

-- TRABAJA_EN
INSERT INTO tp5_p1_ej2.trabaja_en VALUES ('A ', 1, 1, 35, 'T1');
INSERT INTO tp5_p1_ej2.trabaja_en VALUES ('A ', 2, 2, 25, 'T3');

-- AUSPICIO
INSERT INTO tp5_p1_ej2.auspicio VALUES (2, 'McDonald', 'A ', 2);


--a) Indique el resultado de las siguientes operaciones, teniendo en cuenta las acciones
-- referenciales e instancias dadas. En caso de que la operación no se pueda realizar, indicar qué
-- regla/s entra/n en conflicto y cuál es la causa. En caso de que sea aceptada, comente el
-- resultado que produciría (NOTA: en cada caso considere el efecto sobre la instancia original de
-- la BD, los resultados no son acumulativos).

--b.1) delete from tp5_p1_ej2_proyecto where id_proyecto = 3;

select * from tp5_p1_ej2.proyecto;
select * from tp5_p1_ej2.empleado;
select * from tp5_p1_ej2.auspicio;
select * from tp5_p1_ej2.trabaja_en;

delete from tp5_p1_ej2.proyecto;
delete from tp5_p1_ej2.empleado;
delete from tp5_p1_ej2.auspicio;
delete from tp5_p1_ej2.trabaja_en;

delete from tp5_p1_ej2.proyecto where id_proyecto = 3;
--lo borra, nadie lo referencia

--b.2) update tp5_p1_ej2_proyecto set id_proyecto = 7 where id_proyecto = 3;

update tp5_p1_ej2.proyecto set id_proyecto = 9 where id_proyecto = 2;
--hace el update, si trabajaraalguien en p3seactualiza,pero si hayun auspicio no hubiera dejado

--b.3) delete from tp5_p1_ej2_proyecto where id_proyecto = 1;

delete from tp5_p1_ej2.proyecto where id_proyecto = 1;
--error! no puede eliminarlo porqueestásiendo referenciado en latabla"trbaja_en", estarestrict, osea, si lo referencian no hace la acción

--b.4) delete from tp5_p1_ej2_empleado where tipo_empleado = ‘A’ and nro_empleado = 2;
delete from tp5_p1_ej2.empleado where tipo_empleado = 'A' and nro_empleado = 2;
-- error! no existe eltipo de empleado "A" (estan mal las comillas), si lo arreglo -> lo borra en empleado, asu referencia en auspicio setea null y en sureferencia en trabajaen esta en cascade, por ende tambien lo borradeesaabla

--b.5) update tp5_p1_ej2_trabaja_en set id_proyecto = 3 where id_proyecto =1;

update tp5_p1_ej2.trabaja_en set id_proyecto = 3 where id_proyecto =1;
--lo hace 

--b.6) update tp5_p1_ej2_proyecto set id_proyecto = 5 where id_proyecto = 2;
update tp5_p1_ej2.proyecto set id_proyecto = 5 where id_proyecto = 2;
--error! viola la fk auspicio-proyecto ya que update esta en retringido en la tabla auspicio

--auspicio-empleado = delete:set null, update:restrict
--auspicio-proyecto = delete y update : restrict
--trabaja en-empleado = delete:cascade, update:restrict
--trabaja en-proyecto = delete:restrict, update:cascade

--b) Indique el resultado de la siguiente operaciones justificando su elección:

update auspicio set id_proyecto= 66, nro_empleado = 10
where id_proyecto = 22
and tipo_empleado = 'A';
and nro_empleado = 5;

--opciones:
--i. realiza la modificación si existe el proyecto 22 y el empleado TipoE = &#39;A&#39; ,NroE = 5
--ii. realiza la modificación si existe el proyecto 22 sin importar si existe el empleado TipoE = 'A'; ,NroE = 5
--iii.se modifican los valores, dando de alta el proyecto 66 en caso de que no exista (si no se violan restricciones de nulidad), sin importar si existe el empleado
--iv. se modifican los valores, y se da de alta el proyecto 66 y el empleado correspondiente (si no se violan restricciones de nulidad)
--v. no permite en ningún caso la actualización debido a la modalidad de la restricción entre la tabla empleado y auspicio.
--vi. ninguna de las anteriores, cuál?

--rta: esta restricto para la actualizacion del id_proyecto y restricto para la actualizacion de empleado.. no se hace ningun cambio
--PROBAR

--d) Indique cuáles de las siguientes operaciones serán aceptadas/rechazadas, según se considere para las relaciones AUSPICIO-EMPLEADO y AUSPICIO-PROYECTO match: i) simple, ii) parcial, o iii) full:
--insert into Auspicio values (1, Dell , B, null);
--AUSPICIO-EMPLEADO
--simple: lo hace si existe
--partial: lo hace si existe
--full: lo hace si existe
--AUSPICIO-PROYECTO - no afecta a FK simples - no admite nulos la tabla
--simple: lo hace si existe
--partial: lo hace si existe
--full: lo hace si existe

--insert into Auspicio values (2, Oracle, null, null);
--AUSPICIO-EMPLEADO
--simple: si.. no corrobora si existe ya que uno es nulo
--partial: sólo si el valor no nulo existe
--full: no, deberia ser todo nulo o existir ambos
--AUSPICIO-PROYECTO - no afecta a FK simples - no admite nulos la tabla
--simple: lo hace si existe
--partial: lo hace si existe
--full: lo hace si existe

--insert into Auspicio values (3, Google, A, 3);
--AUSPICIO-EMPLEADO
--simple: lo hace si existe
--partial: lo hace si existe
--full: lo hace si existe
--AUSPICIO-PROYECTO - no afecta a FK simples - no admite nulos la tabla
--simple: lo hace si existe
--partial: lo hace si existe
--full: lo hace si existe

--insert into Auspicio values (1, HP, null, 3);
--AUSPICIO-EMPLEADO
--simple: si.. no corrobora si existe ya que uno es nulo
--partial: sólo si el valor no nulo existe
--full: no, deberia ser todo nulo o existir ambos
--AUSPICIO-PROYECTO - no afecta a FK simples - no admite nulos la tabla
--simple: lo hace si existe
--partial: lo hace si existe
--full: lo hace si existe
--PROBAR

--EJERCICIO 3

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2022-08-01 22:34:23.515

-- tables
-- Table: carretera
CREATE TABLE tp5_e3.carretera (
    descripcion varchar(200)  NOT NULL,
    categoria int  NOT NULL,
    nro_carretera int  NOT NULL,
    CONSTRAINT carretera_pk PRIMARY KEY (nro_carretera)
);

-- Table: ciudad
CREATE TABLE tp5_e3.ciudad (
    cod_ciudad int  NOT NULL,
    nombre varchar(15)  NOT NULL,
    cant_habitantes int  NOT NULL,
    CONSTRAINT ciudad_pk PRIMARY KEY (cod_ciudad)
);

-- Table: ruta
CREATE TABLE tp5_e3.ruta (
    cod_ciudad_desde int  NOT NULL,
    cod_ciudad_hasta int  NOT NULL,
    nro_carretera int  NOT NULL,
    km int  NOT NULL,
    CONSTRAINT ruta_pk PRIMARY KEY (cod_ciudad_desde,cod_ciudad_hasta,nro_carretera)
);

-- foreign keys
-- Reference: fk_ruta_carretera (table: ruta)
ALTER TABLE tp5_e3.ruta ADD CONSTRAINT fk_ruta_carretera
    FOREIGN KEY (nro_carretera)
    REFERENCES tp5_e3.carretera (nro_carretera)
    ON DELETE  SET NULL 
    ON UPDATE  SET NULL 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_ruta_ciudad_desde (table: ruta)
ALTER TABLE tp5_e3.ruta ADD CONSTRAINT fk_ruta_ciudad_desde
    FOREIGN KEY (cod_ciudad_desde)
    REFERENCES tp5_e3.ciudad (cod_ciudad)
    ON DELETE  RESTRICT  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: fk_ruta_ciudad_hasta (table: ruta)
ALTER TABLE tp5_e3.ruta ADD CONSTRAINT fk_ruta_ciudad_hasta
    FOREIGN KEY (cod_ciudad_hasta)
    REFERENCES tp5_e3.ciudad (cod_ciudad)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.


--a) Se podrá declarar como acción referencial de la (RIR) FK_Ruta_ciudad_desde DELETE CASCADE y para la RIR FK_Ruta_ciudad_hasta DELETE RESTRICT ?
--rta: si

--b) Es posible colocar DELETE SET NULL o UPDATE SET NULL ckomo acción referencial de la RIR FK_Ruta_Carretera ?
--rta: no, porque no puede haber pk nulas (en tabla carretera)

--EJERCICIO 4
--Es posible definir las siguientes RIRs tal como se declaran en cada punto? Indique V o F según corresponda y justifique.

--a) 
ALTER TABLE Desemp-Etapa
ADD CONSTRAINT FK_DesempEtapa_Auto FOREIGN KEY (id_equipo)
REFERENCES Auto (id_equipo);
--falso, la pk de auto es compuesta.. debe respetarse ambos elementos en el mismo orden de definicion y tipo

--b)
ALTER TABLE Equipo
ADD CONSTRAINT FK_Equipo_Auto FOREIGN KEY (id_equipo, contacto)
REFERENCES Auto (id_equipo, conductor);
--falso, la fk va del lado referendo("que hacereferencia a... "), la pk de auto es compuesta y no se pueden referencias filas que no sean pk

--c) 
ALTER TABLE Desemp-Etapa
ADD CONSTRAINT FK_DesempEtapa_Etapa FOREIGN KEY (Netapa, id_equipo)
REFERENCES Etapa (etapa, id_equipo);
--falso, debe corresponder con el tipo y cantidad de latabla referenciada

--d) 
ALTER TABLE Auspicia
ADD CONSTRAINT FK_Auspicia_Etapa FOREIGN KEY (nro_auto)
REFERENCES Etapa (nro_auto);
--falso, según el gráfico no hay relacion entre esas tablas

--e) 
ALTER TABLE Auto
ADD CONSTRAINT FK_Auto_Equipo FOREIGN KEY (id_equipo)
REFERENCES Equipo (id_equipo);
--verdadero??

--f) 
ALTER TABLE Desemp-Etapa
ADD CONSTRAINT FK_DesempEtapa_Auto FOREIGN KEY (id_equipo, nro_auto)
REFERENCES Auto (id_equipo, nro_auto);
--verdadero, cumple con el orden, tipo y cantidad de pk dela tabla referenciada

--PARTE 2
--1A)
alter table unc_esq_voluntario.voluntario
add constraint ck_edad_voluntario 
CHECK (extract (year from (age(fecha_nacimiento)) > 70)

--1B) 

	   --forma declarativa(que no anda en postgreSQL)
alter table unc_esq_voluntario.voluntario
add constraint ck_menos_horas_coordinador
CHECK( not exists (
	select 1
from unc_esq_voluntario.voluntario v
where v.nro_voluntario = nro_voluntario
v.horas_aportadas < (
select cord.horas_aportadas
from unc_esq_voluntario.voluntario cord
where cord.nro_voluntario = v.nro_voluntario
) ))
	   
--1C) --forma declarativa(que no anda en postgreSQL)
alter table unc_esq_voluntario.voluntario
	   add constraint ck_horas_correspondientes
	   CHECK (
	   exists (
	   		select 1
		   from unc_esq_voluntario.voluntario natural join unc_esq_voluntario.tarea vt
			where vt.nro_voluntario = nro_voluntario
		   and horas_aportadas between vt.min_horas and vt.max_horas
	   )
	   )
	   
--1D) 
	 alter table unc_esq_voluntario.voluntario
add constraint ck_menos_misma_tarea_coord
CHECK( exists (
	select 1
from unc_esq_voluntario.voluntario v
where v.nro_voluntario = nro_voluntario
v.id_tarea IN (
select cord.id_tarea
from unc_esq_voluntario.voluntario cord
where cord.nro_voluntario = v.nro_voluntario
) )) 
	   
--1E)
alter table unc_esq_voluntario.historico
add constraint ck_limite_cambio_anual
CHECK ( 3 >= (
	select count(h.fecha_inicio)
from unc_esq_voluntario.historico h
where nro_voluntario = h.nro_voluntario
and extract(year from h.fecha_inicio) in (extract(year from fecha_inicio))
group by h.fecha_inicio
))
	   
--1F)
alter table unc_esq_voluntario.historico
add constraint ck_fecha_orden
CHECK (fecha_inicio < fecha_fin)
	   
--EJERCICIO2
--2A)
alter table unc_esq_peliculas.tarea
add constraint ck_sueldo_correspondiente
CHECK (sueldo_minimo < sueldo_maximo)
	   
--2B)
alter table unc_esq_peliculas.empleado
add constraint ck_cant_empleados_dep
CHECK(not exists (
select 1
from unc_esq_peliculas.empleado e
group by id_departamento 
having count(*) > 70
)
)
	   
--2C)
alter table unc_esq_peliculas.empleado
add constraint ck_mismo_depto
CHECK (
id_departamento in (
select j.id_departamento
from unc_esq_peliculas.empleado e
where e.id_empleado = id_jefe
)
)	   

--2D)
	   
	   
--2E)
alter table unc_esq_peliculas.empresa_productora
add constraint ck_max_por_ciudad
CHECK ( not exists (
select 1
from unc_esq_peliculas.empresa_productora
group by id_ciudad
having count(*) > 10
))

--2F)	   
alter table unc_esq_peliculas.pelicula
add constraint ck_max_por_ciudad
CHECK (formato in ('8mm') and idioma in ('Francés') or formato not in ('8mm'))
	   
--2G)


--EJERCICIO 3
--a)
ALTER TABLE p5p2e3_articulo
   ADD CONSTRAINT ck_articulo_nacionalidad
   CHECK ( nacionalidad in ('Argentina','Español','Ingles','Aleman','Chilena'))
;
--b)	   
ALTER TABLE p5p2e3_articulo
   ADD CONSTRAINT ck_articulo_fecha_publicacion
   CHECK ( extract(year from fecha_publicacion) >= 2010 )
;
--c)
ALTER TABLE p5p2e3_contiene
   ADD CONSTRAINT ck_cantpalabra_articulo
   CHECK ( NOT EXISTS (
             SELECT 1
             FROM p5p2e3_contiene
             GROUP BY idioma, cod_palabra
             HAVING COUNT(*) > 5));
--d)
CREATE ASSERTION CK_CANTIDAD_PALABRAS
   CHECK (NOT EXISTS (
            SELECT 1
            FROM p5p2e3_articulo
            WHERE (nacionalidad LIKE 'Argentina' AND
                  id_articulo IN (SELECT id_articulo
                                  FROM p5p2e3_contiene
                                  GROUP BY id_articulo
                                    HAVING COUNT(*) > 15) ) OR
                  (nacionalidad NOT LIKE 'Argentina' AND
                  id_articulo IN (SELECT id_articulo
                                  FROM p5p2e3_contiene
                                  GROUP BY id_articulo
                                    HAVING COUNT(*) > 10) )))
;

--EJERCICIO 4
	   
-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-09-28 21:22:26.905

-- tables
-- Table: P5P2E4_ALGORITMO
CREATE TABLE p5p2e4.ALGORITMO (
    id_algoritmo int  NOT NULL,
    nombre_metadata varchar(40)  NOT NULL,
    descripcion varchar(256)  NOT NULL,
    costo_computacional varchar(15)  NOT NULL,
    CONSTRAINT PK_P5P2E4_ALGORITMO PRIMARY KEY (id_algoritmo)
);

-- Table: P5P2E4_IMAGEN_MEDICA
CREATE TABLE p5p2e4.IMAGEN_MEDICA (
    id_paciente int  NOT NULL,
    id_imagen int  NOT NULL,
    modalidad varchar(80)  NOT NULL,
    descripcion varchar(180)  NOT NULL,
    descripcion_breve varchar(80)  NULL,
    CONSTRAINT PK_P5P2E4_IMAGEN_MEDICA PRIMARY KEY (id_paciente,id_imagen)
);

-- Table: P5P2E4_PACIENTE
CREATE TABLE p5p2e4.PACIENTE (
    id_paciente int  NOT NULL,
    apellido varchar(80)  NOT NULL,
    nombre varchar(80)  NOT NULL,
    domicilio varchar(120)  NOT NULL,
    fecha_nacimiento date  NOT NULL,
    CONSTRAINT PK_P5P2E4_PACIENTE PRIMARY KEY (id_paciente)
);

-- Table: P5P2E4_PROCESAMIENTO
CREATE TABLE p5p2e4.PROCESAMIENTO (
    id_algoritmo int  NOT NULL,
    id_paciente int  NOT NULL,
    id_imagen int  NOT NULL,
    nro_secuencia int  NOT NULL,
    parametro decimal(15,3)  NOT NULL,
    CONSTRAINT PK_P5P2E4_PROCESAMIENTO PRIMARY KEY (id_algoritmo,id_paciente,id_imagen,nro_secuencia)
);

-- foreign keys
-- Reference: FK_P5P2E4_IMAGEN_MEDICA_PACIENTE (table: P5P2E4_IMAGEN_MEDICA)
ALTER TABLE p5p2e4.IMAGEN_MEDICA ADD CONSTRAINT FK_P5P2E4_IMAGEN_MEDICA_PACIENTE
    FOREIGN KEY (id_paciente)
    REFERENCES p5p2e4.PACIENTE (id_paciente)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P2E4_PROCESAMIENTO_ALGORITMO (table: P5P2E4_PROCESAMIENTO)
ALTER TABLE p5p2e4.PROCESAMIENTO ADD CONSTRAINT FK_P5P2E4_PROCESAMIENTO_ALGORITMO
    FOREIGN KEY (id_algoritmo)
    REFERENCES p5p2e4.ALGORITMO (id_algoritmo)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P2E4_PROCESAMIENTO_IMAGEN_MEDICA (table: P5P2E4_PROCESAMIENTO)
ALTER TABLE p5p2e4.PROCESAMIENTO ADD CONSTRAINT FK_P5P2E4_PROCESAMIENTO_IMAGEN_MEDICA
    FOREIGN KEY (id_paciente, id_imagen)
    REFERENCES p5p2e4.IMAGEN_MEDICA (id_paciente, id_imagen)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

--a)
alter table p5p2e4.imagen_medica
add constraint ck_valores_modalidad
CHECK(
modalidad in ('RADIOLOGIA CONVENCIONAL', 'FLUOROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON
FLUOROSCOPIA', 'MAMOGRAFIA', 'SONOGRAFIA')
)
	   
--b)
alter table p5p2e4.procesamiento
add constraint ck_max_cant_procesamiento
check (
not exists (
select 1
from p5p2e4.procesamiento
group by id_paciente, id_imagen
having count(*) > 5
)
)
--c)
alter table p5p2e4.procesamiento
add column fecha_procesamiento DATE NOT NULL;
alter table p5p2e4.imagen_medica
add column fecha_imagen DATE NOT NULL;

alter table p5p2e4.procesamiento
add constraint ck_fecha_correcta
check (
fecha_procesamiento < (
	--hcer un join con ambas tablas y hacer el not exists
select fecha_imagen
from p5p2e4.imagen_medica im
where im.id_paciente = id_paciente
and im.id_imagen = id_imagen
)
)
--d) 
alter table p5p2e4.imagen_medica
add constraint ck_fluoroscopias_anuales
check (
not exists (
select 1
from p5p2e4.imagen_medica
where modalidad in ('FLUOROSCOPIA')
group by modalidad, extract (year from fecha_imagen)
having count(*) > 2
)
)
--e)
CREATE ASSERTION
   CHECK ( NOT EXISTS (
                SELECT 1
                FROM p5p2e4_imagen_medica i JOIN p5p2e4_procesamiento p ON
                    (i.id_paciente = p.id_paciente AND i.id_imagen = p.id_imagen)
                    JOIN p5p2e4_algoritmo a ON ( p.id_algoritmo = a.id_algoritmo )
                WHERE modalidad = 'FLUOROSCOPIA' AND
                    costo_computacional = 'O(n)'
));

--EJERCICIO 5
-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-09-28 23:11:03.915

-- tables
-- Table: P5P2E5_CLIENTE
CREATE TABLE p5p2e5.CLIENTE (
    id_cliente int  NOT NULL,
    apellido varchar(80)  NOT NULL,
    nombre varchar(80)  NOT NULL,
    estado char(5)  NOT NULL,
    CONSTRAINT PK_P5P2E5_CLIENTE PRIMARY KEY (id_cliente)
);

-- Table: P5P2E5_FECHA_LIQ
CREATE TABLE p5p2e5.FECHA_LIQ (
    dia_liq int  NOT NULL,
    mes_liq int  NOT NULL,
    cant_dias int  NOT NULL,
    CONSTRAINT PK_P5P2E5_FECHA_LIQ PRIMARY KEY (dia_liq,mes_liq)
);

-- Table: P5P2E5_PRENDA
CREATE TABLE p5p2e5.PRENDA (
    id_prenda int  NOT NULL,
    precio decimal(10,2)  NOT NULL,
    descripcion varchar(120)  NOT NULL,
    tipo varchar(40)  NOT NULL,
    categoria varchar(80)  NOT NULL,
    CONSTRAINT PK_P5P2E5_PRENDA PRIMARY KEY (id_prenda)
);

-- Table: P5P2E5_VENTA
CREATE TABLE p5p2e5.VENTA (
    id_venta int  NOT NULL,
    descuento decimal(10,2)  NOT NULL,
    fecha timestamp  NOT NULL,
    id_prenda int  NOT NULL,
    id_cliente int  NOT NULL,
    CONSTRAINT PK_P5P2E5_VENTA PRIMARY KEY (id_venta)
);

-- foreign keys
-- Reference: FK_P5P2E5_VENTA_CLIENTE (table: P5P2E5_VENTA)
ALTER TABLE p5p2e5.VENTA ADD CONSTRAINT FK_P5P2E5_VENTA_CLIENTE
    FOREIGN KEY (id_cliente)
    REFERENCES p5p2e5.CLIENTE (id_cliente)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P2E5_VENTA_PRENDA (table: P5P2E5_VENTA)
ALTER TABLE p5p2e5.VENTA ADD CONSTRAINT FK_P5P2E5_VENTA_PRENDA
    FOREIGN KEY (id_prenda)
    REFERENCES p5p2e5.PRENDA (id_prenda)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.	

--a)
alter table p5p2e5.venta 
add constraint ck_descuento
CHECK(descuente between 0 and 100);
	   
--b) 
alter table p5p2e5.venta 
add constraint ck_dias_descuento
check (
not exists (
select 1
from p5p2e5.fecha_liq li, p5p2e5.venta v
where extract(month from v.fecha) = li.mes_liq
and extract(day from v.fecha) between li.dia_liq and (li.dia_liq + li.cant_dias)
	and v.descuento <= 30
)
)

--c)
alter table p5p2e5.fecha_liq
add constraint ck_julio_diciembre_limite
check (
not exists (
select 1
from p5p2e5.fecha_liq
where mes_liq in (7,12)
and cant_dias > 5
)
)

--d)
alter table p5p2e5.venta
add constraint ck_sin descuento
check (
not exists(
select 1
from p5p2e5.venta natural join p5p2e5.prenda
where categoria in ('oferta')
and descuento = 0
)
)