-- EJERCICIO 1

-- Considere las siguientes sentencias de creación de vistas en el esquema de Películas:
-- Nota: el planteo es sólo teórico porque no podrá insertar registros en unc_esq_peliculas por los
-- permisos

CREATE VIEW unc_esq_peliculas.Distribuidor_200 AS
SELECT id_distribuidor, nombre, tipo
FROM unc_esq_peliculas.distribuidor
WHERE id_distribuidor > 200;

CREATE VIEW unc_esq_peliculas.Departamento_dist_200 AS
SELECT id_departamento, nombre, id_ciudad, jefe_departamento
FROM unc_esq_peliculas.departamento
WHERE id_distribuidor > 200;

-- a. Discuta si las vistas son actualizables o no y justifique.
--la 1er vista si lo es, contiene la pk completa y es sobre una sola tabla.. no contiene nada más
--la 2da vista no lo es, falta una de lascolumnas de la pk de su tabla origen

-- b. Considere que algunos registros de la tabla Distribuidor son:

-- id_distribuidor |  nombre          | direccion | telefono     | tipo
-- 1049            |Distribuidor 1049 | Doro      | 7372214-6352 | N
-- 1050            |Distribuidor 1050 | Lakhagarh | 569842-2643  | N 

select * from unc_esq_peliculas.distribuidor where id_distribuidor = 1050;
--y se ha creado la vista:
CREATE VIEW unc_esq_peliculas.Distribuidor_1000 AS
SELECT *
FROM unc_esq_peliculas.distribuidor d
WHERE id_distribuidor > 1000;

-- Si se ejecuta la siguiente sentencia:
INSERT INTO unc_esq_peliculas.Distribuidor_1000 VALUES (1050, 'NuevoDistribuidor 1050', 'Montiel 340', '569842-2643', 'N');

-- Indique y justifique la opción correcta:
-- A. Falla porque la vista no es actualizable.
-- B. Falla porque si bien la vista es actualizable viola una restricción de foreign key.
-- C. Falla porque si bien la vista es actualizable viola una restricción de primary key. X esta es la correcta!!
-- D. Procede exitosamente.

--EJERCICIO 2

-- Considere el esquema de la BD unc_esq_peliculas:
-- 1. Escriba las sentencias de creación de cada una de las vistas solicitadas en cada caso.
-- 2. Indique si para el estandar SQL y/o Postgresql dicha vista es actualizable o no, si es de
-- Proyección-Selección (una tabla) o Proyección-Selección-Ensamble (más de una tabla).
-- Justifique cada respuesta.

-- 1. Cree una vista EMPLEADO_DIST que liste el nombre, apellido, sueldo, y fecha_nacimiento de
-- los empleados que pertenecen al distribuidor cuyo identificador es 20.

CREATE VIEW unc_esq_peliculas.EMPLEADO_DIST AS
SELECT nombre, apellido, sueldo, fecha_nacimiento from unc_esq_peliculas.empleado
where id_distribuidor = 20;
--Proyección-Selección = 1 sola tabla, no es actualizable, lefalta "id_empleado"

-- 2. Sobre la vista anterior defina otra vista EMPLEADO_DIST_2000 con el nombre, apellido y sueldo
-- de los empleados que cobran más de 2000.

create view unc_esq_peliculas.EMPLEADO_DIST_2000 as
    select nombre, apellido, sueldo from unc_esq_peliculas.EMPLEADO_DIST
where sueldo > 2000;

--Proyección-Selección = 1 sola tabla, no es actualizable, lefalta "id_empleado"

-- 3. Sobre la vista EMPLEADO_DIST cree la vista EMPLEADO_DIST_20_70 con aquellos
-- empleados que han nacido en la década del 70 (entre los años 1970 y 1979).

create view unc_esq_peliculas.EMPLEADO_DIST_20_70 as
select * from unc_esq_peliculas.EMPLEADO_DIST
where extract(year from fecha_nacimiento) between 1970 and 1979;

--Proyección-Selección = 1 sola tabla, no es actualizable, lefalta "id_empleado"

-- 4. Cree una vista PELICULAS_ENTREGADA que contenga el código de la película y la cantidad de
-- unidades entregadas.

create view unc_esq_peliculas.PELICULAS_ENTREGADA as
select codigo_pelicula, cantidad from unc_esq_peliculas.renglon_entrega;

--Proyección-Selección = 1 sola tabla, no es actualizable, lefalta "nro_entrega"

-- 5. Cree una vista ACCION_2000 con el código, el titulo el idioma y el formato de las películas del
-- género ‘Acción’ entregadas en el año 2006.

create  view unc_esq_peliculas.ACCION_2000 as
select codigo_pelicula, titulo, idioma, formato from unc_esq_peliculas.pelicula p join unc_esq_peliculas.renglon_entrega re
on p.codigo_pelicula = re.codigo_pelicula join unc_esq_peliculas.entrega e on e.nro_entrega = re.nro_entrega
where genero in ('Acción') and extract(year from fecha_entrega) in (2006);

--Proyección-Selección-Ensamble = 3 tablas, puedo ctualizar sólo filas delatablapelicula porque sólo tengo pk de esa

-- 6. Cree una vista DISTRIBUIDORAS_ARGENTINA con los datos completos de las distribuidoras
-- nacionales y sus respectivos departamentos.

create view unc_esq_peliculas.DISTRIBUIDORAS_ARGENTINA as
select * from unc_esq_peliculas.distribuidor d join unc_esq_peliculas.departamento dto on d.id_distribuidor = dto.id_distribuidor
where tipo in ('N');

--Proyección-Selección-Ensamble = 2 tablas, puedo ctualizar cualquier tabla referida yaquetengo sus pk completas, pero una por vez

-- 7. De la vista anterior cree la vista Distribuidoras_mas_2_emp con los datos completos de las
-- distribuidoras cuyos departamentos tengan más de 2 empleados.

create view unc_esq_peliculas.Distribuidoras_mas_2_emp as
    select * from unc_esq_peliculas.DISTRIBUIDORAS_ARGENTINA da
where 2 < (select count(*) from unc_esq_peliculas.empleado e where da.id_departamento = e.id_departamento);

--Proyección-Selección = 1 tabla (tabla de vista + subconsulta), puedo ctualizar cualquier tabla referida de la vista referida por separado

-- 8. Cree la vista PELI_ARGENTINA con los datos completos de las productoras y las películas que
-- fueron producidas por empresas productoras de nuestro país.

create view unc_esq_peliculas.PELI_ARGENTINA as
    select * from unc_esq_peliculas.pelicula p join unc_esq_peliculas.empresa_productora ep on p.codigo_productora = ep.codigo_productora
where exists (
    select 1 from unc_esq_peliculas.ciudad c where ep.id_ciudad = c.id_ciudad and exists (
        select 1 from unc_esq_peliculas.pais p where p.id_pais = c.id_pais and nombre_pais in ('ARGENTINA')
        )
          );

--Proyección-Selección-Ensamble = 2 tablas, puedo ctualizar cualquier tabla referida yaquetengo sus pk completas, pero una por vez

-- 9. De la vista anterior cree la vista ARGENTINAS_NO_ENTREGADA para las películas producidas
-- por empresas argentinas pero que no han sido entregadas

create view unc_esq_peliculas.ARGENTINAS_NO_ENTREGADA as
    select * from unc_esq_peliculas.PELI_ARGENTINA
where codigo_pelicula not in (select codigo_pelicula from unc_esq_peliculas.renglon_entrega);

--Proyección-Selección = 1 tabla (tabla de vista + subconsulta), puedo ctualizar cualquier tabla referida de la vista referida por separado

-- 10. Cree una vista PRODUCTORA_MARKETINERA con las empresas productoras que hayan
-- entregado películas a TODOS los distribuidores.

create view unc_esq_peliculas.PRODUCTORA_MARKETINERA as
    select * from unc_esq_peliculas.empresa_productora ep
where exists (
select 1 from (unc_esq_peliculas.pelicula natural join unc_esq_peliculas.renglon_entrega natural join unc_esq_peliculas.entrega) as ent
where ep.codigo_productora = ent.codigo_productora and ent.id_distribuidor = all (select distinct id_distribuidor from unc_esq_peliculas.distribuidor)
    );

create view unc_esq_peliculas.PRODUCTORA_MARKETINERA as
    select * from unc_esq_peliculas.empresa_productora ep
where ep.codigo_productora = all (
select codigo_productora from unc_esq_peliculas.pelicula natural join unc_esq_peliculas.renglon_entrega natural join unc_esq_peliculas.entrega
 );
--REHACEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRRRRRRRRRRRR!!!!!!!!!

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2022-08-11 21:30:16.731

-- tables
-- Table: tabla1
CREATE TABLE prueba.tabla1 (
    id int  NOT NULL,
    nombre varchar(10)  NOT NULL,
    CONSTRAINT tabla1_pk PRIMARY KEY (id)
);

-- Table: tabla2
CREATE TABLE prueba.tabla2 (
    id int  NOT NULL,
    nombre varchar(10)  NOT NULL,
    tabla1_id int  NOT NULL,
    CONSTRAINT tabla2_pk PRIMARY KEY (id)
);

-- foreign keys
-- Reference: tabla2_tabla1 (table: tabla2)
ALTER TABLE prueba.tabla2 ADD CONSTRAINT tabla2_tabla1
    FOREIGN KEY (tabla1_id)
    REFERENCES prueba.tabla1 (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.

create or replace view prueba.usa_todos as
    select * from prueba.tabla1 t1
where t1.id = all (select distinct tabla1_id from prueba.tabla2)
    ;

insert into prueba.tabla1 values (1, 'n1');
insert into prueba.tabla1 values (2, 'n2');
insert into prueba.tabla1 values (3, 'n3');

insert into prueba.tabla2 values (1, 'nn1', 1);
insert into prueba.tabla2 values (2, 'nn2', 1);
insert into prueba.tabla2 values (3, 'nn3', 1);
insert into prueba.tabla2 values (4, 'nn4', 1);
insert into prueba.tabla2 values (5, 'nn5', 1);
insert into prueba.tabla2 values (6, 'nn5', 2);

select  * from prueba.usa_todos;
select * from prueba.tabla2;
--elemento 1 de la tabla1 le hacen todos referencia antes de gregar la referencia a 2

-- Ejercicio 3
-- Analice cuáles serían los controles y el comportamiento ante actualizaciones sobre las vistas
-- EMPLEADO_DIST, EMPLEADO_DIST_2000 y EMPLEADO_DIST_20_70 creadas en el ej. 2, si las
-- mismas están definidas con WITH CHECK OPTION LOCAL o CASCADE en cada una de ellas.
-- Evalúe todas las alternativas.

--EMPLEADO_DIST
    --WITH CHECK OPTION LOCAL
    --WITH CHECK OPTION CASCADE
--EMPLEADO_DIST_2000
    --WITH CHECK OPTION LOCAL
    --WITH CHECK OPTION CASCADE
--EMPLEADO_DIST_20_70
    --WITH CHECK OPTION LOCAL
    --WITH CHECK OPTION CASCADE
