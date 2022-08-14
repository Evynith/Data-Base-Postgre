--EJERCICIO 1
/*
--c) Cada palabra clave puede aparecer como máximo en 5 artículos.
ALTER TABLE p5p2e3_contiene
   ADD CONSTRAINT ck_cantpalabra_articulo
   CHECK ( NOT EXISTS (
             SELECT 1
             FROM p5p2e3_contiene
             GROUP BY idioma, cod_palabra
             HAVING COUNT(*) > 5));
*/

create or replace function fn_max_articulo_x_palabra()
returns trigger as $body$
declare cant_palabra integer;
BEGIN
	SELECT count(c.cod_palabra) into cant_palabra FROM p5p2e3_contiene c
	where new.id_articulo = c.id_articulo and new.idioma = c.idioma 
	--GROUP BY c.cod_palabra
	--no necesito agrupar porque solo traigo los necesarios
	if(cant_palabra >= 5 ) THEN
		raise exception 'supera el minimo de palabras por articulo';
	end if;
	return new;
end;
$body$ language 'plpgsql'


create trigger tr_max_articulo_x_palabra
before insert or update of idioma, cod_palabra on p5p2e3_contiene
for each row
execute procedure fn_max_articulo_x_palabra;

/*
--d)Sólo los autores argentinos pueden publicar artículos que contengan más de 10 palabras
-- claves, pero con un tope de 15 palabras, el resto de los autores sólo pueden publicar
-- artículos que contengan hasta 10 palabras claves.

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
*/

function fn_tope_palabras_x_articulo()
returns trigger as $body$
declare 
nacionalidad text;
cantidad integer;
begin
select a.nacionalidad into nacionalidad from p5p2e3_articulo a
where a.id_articulo = new.id_articulo;
select count(c.cod_palabra) into cantidad from p5p2e3_contiene c where c.idioma = new.idioma 
and new.id_articulo = c.id_articulo

if (nacionalidad = 'Argentina') then
	if (cantidad >= 15) then
		raise exception 'supera la cantidad maxima de palabras por articulo'
	end if
else if
	if (cantidad >= 10) then
		raise exception 'supera la cantidad maxima de palabras por articulo'
	end if
end if
return new;
end
$body$ language 'plpgsql'

create trigger tr_tope_palabras_x_articulo
before insert or update of id_articulo on p5p2e3_contiene
for each row execute procedure fn_tope_palabras_x_articulo

--EJERCICIO 2
/*   
--b) Cada imagen no debe tener más de 5 procesamientos.
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
*/

create or replace function fn_max_procesamientosXimg()
returns trigger as $body$
DECLARE
cant_procesamientos integer;
begin
 select count(*) into cant_procesamientos
 from p5p2e4.procesamiento
 where id_paciente = new.id_paciente
 and id_imagen = new.id_imagen
 
if (cant_procesamientos >= 5) then
	raise exception 'cantidad maxima de procesamientos alcanzada'
end if
return new
end
$body$ language 'plpjsql'

create trigger tr_max_procesamientosXimg
before insert or update of id_paciente, id_imagen on p5p2e4.procesamiento
for each row execute procedure fn_max_procesamientosXimg

/*
--c) Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una
-- indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen y controle
-- que la segunda no sea menor que la primera.

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
*/

create or replace function fn_fechas_relativas_procesamiento ()
returns trigger as $body$
--declare 
begin
	if (new.fecha_procesamiento < (select fecha_imagen from p5p2e4.imagen
	where new.id_paciente = id_paciente and new.id_imagen = id_imagen)) then
	raise exception 'la fecha es anterior a su imagen medica'
end if
return new
end
$body$ language 'plpgsql'

create trigger tr_fechas_relativas
before insert or update of fecha_procesamiento on p5p2e4.procesamiento
for each row execute procedure fn_fechas_relativas_procesamiento

create or replace function fn_fechas_relativas_imagen ()
returns trigger as $body$
--declare 
begin
	if (new.fecha_imagen > (select fecha_procesamiento from p5p2e4.procesamiento
	where new.id_paciente = id_paciente and new.id_imagen = id_imagen)) then
	raise exception 'la fecha es posterior a su procesamiento'
end if
return new
end
$body$ language 'plpgsql'

create trigger tr_fechas_relativas
before update of fecha_imagen on p5p2e4.imagen
for each row execute procedure fn_fechas_relativas_imagen

/*
--d) Cada paciente sólo puede realizar dos FLUOROSCOPIA anuales.
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
*/

create or replace function fn_max_fluoroscopia_anual ()
returns trigger as $body$
declare cant integer;
begin
select count(*) into cant from p5p2e4.imagen_medica where new.id_paciente = id_paciente
and modalidad like 'FLUOROSCOPIA' group by id_imagen, extract(year from fecha_imagen)
if (cant > 2) then
	raise exception 'supera el maximo de fluoroscopias anuales'
end if
return new
end
$body$ language 'plpgsql'

create trigger tr_max_fluoroscopia_anual
before insert or update of modalidad on p5p2e4.imagen_medica
for each row execute procedure fn_max_fluoroscopia_anual

/*
--e) No se pueden aplicar algoritmos de costo computacional “O(n)”
-- a imágenes de FLUOROSCOPIA

CREATE ASSERTION
   CHECK ( NOT EXISTS (
                SELECT 1
                FROM p5p2e4_imagen_medica i JOIN p5p2e4_procesamiento p ON
                    (i.id_paciente = p.id_paciente AND i.id_imagen = p.id_imagen)
                    JOIN p5p2e4_algoritmo a ON ( p.id_algoritmo = a.id_algoritmo )
                WHERE modalidad = 'FLUOROSCOPIA' AND
                    costo_computacional = 'O(n)'
));
*/

create or replace function fn_costo_fluoroscopia ()
returns trigger as $body$
declare 
tipo boolean;
costo boolean;
begin
select modalidad like 'FLUOROSCOPIA' into tipo from p5p2e4.imagen_medica where id_paciente = new.id_paciente and 
new.id_imagen = id_imagen and modalidad like 'FLUOROSCOPIA'
select costo_computacional like 'O(n)' from p5p2e4.algoritmo
where id_algoritmo = new.id_algoritmo limit 1
if(tipo = true and costo = true) then
	raise exception 'fluoroscopia no puede  ser de costo O(n)'
end if
return new
end
$body$ language 'plpgsql'

create trigger tr_costo_fluoroscopia
before insert or update of id_algoritmo on p5p2e4.procesamiento
for each row execute procedure fn_costo_fluoroscopia

--EJERCICIO 3

	/*   
--b) Los descuentos realizados en fechas de liquidación deben superar el 30%.
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
*/ 

create or replace function fn_max_porc_liq ()
returns trigger as $body$
--DECLARE 
begin
if (new.descuento <= 30) then
	if (exists (select 1 from p5p2e5.fecha_liq li
	where extract(month from new.fecha) = li.mes_liq
	and extract(day from new.fecha) between li.dia_liq and (li.dia_liq + li.cant_dias))) THEN
		raise exception 'el dia de ofertadebe superarel 30 porciento';
	end if;
end if;
return new;
end;
$body$ language 'plpgsql';

create trigger tr_max_porc_liq
BEFORE INSERT OR UPDATE OF fecha, descuento on p5p2e5.venta
for each row execute procedure fn_max_porc_liq ();

--------
insert into p5p2e5.fecha_liq (dia_liq, mes_liq, cant_dias) 
values (1, 5, 5);
select * from p5p2e5.fecha_liq

insert into p5p2e5.cliente (id_cliente,apellido, nombre, estado)
values (1,'uno','nombre','a');
insert into p5p2e5.prenda (id_prenda,precio,descripcion,tipo,categoria)
values (1,40.6,'prenda','remera','top')

insert into p5p2e5.venta (id_venta, descuento, fecha, id_prenda, id_cliente)
values (1,26,to_timestamp('02-05-2022', 'dd-mm-yyyy'), 1,1) --o to_date
delete from p5p2e5.venta
select * from p5p2e5.venta
/*
--c) Las liquidaciones de Julio y Diciembre no deben superar los 5 días.
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
*/

create or replace function fn_jd_max_dias ()
returns trigger as $body$
BEGIN
if (new.cant_dias > 5 ) then
	raise exception 'supera cantidad de dias'
end if
return new
end
$body$ language 'plpgsql'

create trigger tr_jd_max_dias
before insert or update of mes_liq on p5p2e5.fecha_liq
when mes_liq in (07,12)
for each row execute procedure fn_jd_max_dias ()

/*
--d) Las prendas de categoría ‘oferta’ no tienen descuentos.
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
*/

create or replace function fn_sin_descuento ()
returns trigger as $body$
declare cat p5p2e5.prenda.categoria%rowtype;
begin
select categoria into cat from p5p2e5.prenda where id_prenda = new.id_prenda
if (cat = 'oferta') then
	raise exception 'no corresponde un descuento' 
end if
return new
end
$body$ language 'plpgsql'

create trigger tr_sin_descuento
before insert  or update of descuento on p5p2e5.venta
when descuento not in (0)
for each row  execute procedure fn_sin_descuento ()

create trigger tr_sin_descuento
before update of categoria on p5p2e5.prenda
when categoria like 'oferta'
for each row  execute procedure fn_sin_descuento_prenda ()

--EJERCICIO 4
--Cree la tabla ESTADISTICA con la siguiente sentencia para tabla pelicula:
--schema: p6e4p1

CREATE TABLE p6e4p1.Pelicula AS
SELECT * FROM unc_esq_peliculas.pelicula;

CREATE TABLE p6e4p1.estadistica AS
SELECT genero, COUNT(*) total_peliculas, count (distinct idioma) cantidad_idiomas
FROM p6e4p1.Pelicula GROUP BY genero;

-- c) Cree un trigger que cada vez que se realice una modificación en la tabla película (la creada
-- en su esquema) tiene que actualizar la tabla estadística.No se olvide de identificar:
-- i) la granularidad del trigger.
-- ii) Eventos ante los cuales se debe disparar.
-- iii) Analice si conviene modificar por cada operación de actualización o reconstruirla de
-- cero.

create or replace function fn_peli_estadistica ()
returns trigger as $body$
begin

insert into p6e4p1.estadistica (genero, total_peliculas, cantidad_idiomas)
values (select genero, count(*), count (distinct idioma) from  p6e4p1.pelicula group by genero )
if (TG_OP = 'INSERT' or TG_OP = 'UPDATE' ) THEN
return new
else if (TG_OP = 'DELETE') THEN
return old
end if
end
$body$ language 'plpgsql'

create trigger tr_peli_estadistica
after insert or update or delete on p6e4p1.Pelicula
for each statement execute procedure fn_peli_estadistica ()

--TP6 PARTE2
--EJERCICIO 1
-- Para el esquema unc_voluntarios considere que se quiere mantener un registro de quién y
-- cuándo realizó actualizaciones sobre la tabla TAREA en la tabla HIS_TAREA. Dicha tabla tiene la
-- siguiente estructura:
--HIS_TAREA(nro_registro, fecha, operación, cant_reg_afectados, usuario)

-- a) Provea el/los trigger/s necesario/s para mantener en forma automática la tabla HIS_TAREA
-- cuando se realizan actualizaciones (insert, update o delete) en la tabla TAREA.

-- b) Muestre los resultados de las tablas si se ejecuta la operación:

DELETE FROM TAREA
WHERE id_tarea like ‘AD%’;

SELECT * FROM pg_stat_activity

create table if not exists unc_esq_voluntario.his_tarea (
nro_registro serial not null,
fecha date not null,
operacion varchar (6) not null,
cant_reg_afectados integer not null,
usuario varchar (100) not null,
constraint pk_nro_registro primary key (nro_registro))

create or replace function fk_log_usuario ()
returns trigger as $body$
DECLARE
usuario text := CURRENT_USER;
cant int := 0;
registro integer := 0;
	begin
insert into unc_esq_voluntario.his_tarea (fecha, operacion, cant_reg_afectados, usuario)
values (now(), TG_OP,0,usuario);
	--@@identity auoincrementales 
	GET DIAGNOSTICS cant = ROW_COUNT;
update unc_esq_voluntario.his_tarea set cant_reg_afectados = cant where nro_registro = registro;
if (tg_op = 'INSERT' or tg_op = 'UPDATE') then
return new;
elsif (tg_op = 'DELETE') then
	if (old.id_tarea like ‘AD%’) then
	 	RAISE NOTICE 'delete: % %', tg_event, tg_tag;
	end if;
return old;
end if;
	end;
$body$ LANGUAGE 'plpgsql';


create trigger tr_log_usuario
after insert or update or delete on unc_esq_voluntario.tarea
for each row execute procedure fk_log_usuario ();
--debe ser  for each row ya que debo saber que cantidad de registros modifiqué por cada fila

insert into unc_esq_voluntario.tarea (id_tarea, nombre_tarea, min_horas, max_horas)
values ('TR_TEST4', 'nombre para test user', 15000, 13000);
select * from unc_esq_voluntario.tarea
select * from unc_esq_voluntario.his_tarea

delete FROM unc_esq_voluntario.TAREA WHERE id_tarea like 'AD%';

--sudo -u postgres createuser test
ALTER USER test WITH PASSWORD 'Evynith';
GRANT select, insert, update, delete on all tables in SCHEMA unc_esq_voluntario to test;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA unc_esq_voluntario TO test;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA unc_esq_voluntario TO test;

--EJERCICIO 2
-- c) Completar una tabla denominada MAS_ENTREGADAS con los datos de las 20 películas
-- más entregadas en los últimos seis meses desde la ejecución del procedimiento. Esta tabla
-- por lo menos debe tener las columnas código_pelicula, nombre, cantidad_de_entregas (en
-- caso de coincidir en cantidad de entrega ordenar por código de película).

create table if not exists unc_esq_peliculas.mas_entregadas(
cantidad_de_entregas numeric(5,0) not null,
codigo_pelicula numeric(5,0) not null, 
nombre char(60) not null, 
constraint pk_mas_entregadas primary key (codigo_pelicula)
)

create or replace function fn_20_mas_entregadas ()
returns void as $body$
begin
insert into unc_esq_peliculas.mas_entregadas (select sum(cantidad) cantidad_de_entregas,codigo_pelicula, titulo
from unc_esq_peliculas.pelicula natural join unc_esq_peliculas.renglon_entrega natural join unc_esq_peliculas.entrega
where  extract(day from(now() - fecha_entrega)) <= 182
group by codigo_pelicula order by cantidad_de_entregas desc limit 20);
-- 6 meses son igual a 182 dias
end;
$body$ language 'plpgsql';

select * from unc_esq_peliculas.mas_entregadas

-- d) Generar los datos para una tabla denominada SUELDOS, con los datos de los empleados
-- cuyas comisiones superen a la media del departamento en el que trabajan. Esta tabla
-- debe tener las columnas id_empleado, apellido, nombre, sueldo, porc_comision.

create table if not exists unc_esq_peliculas.sueldos(
id_empleado numeric(6,0) not null,
apellido varchar(30) not null,
nombre varchar(30) not null,
sueldo numeric(8,2),
porc_comision numeric(6,2),
constraint pk_sueldo_empleado primary key (id_empleado) 
)

create or replace function fn_emp_sup_media ()
returns void as $body$
BEGIN
insert into unc_esq_peliculas.sueldos (
select id_empleado, apellido, nombre, sueldo, porc_comision from unc_esq_peliculas.empleado
where porc_comision > ( select avg(porc_comision) from unc_esq_peliculas.empleado e where e.id_departamento = id_departamento)
);
end;
$body$ language 'plpgsql';

-- e) Cambiar el distribuidor de las entregas sucedidas a partir de una fecha dada, siendo que el
-- par de valores de distribuidor viejo y distribuidor nuevo es variable.

create or replace function fn_cambiar_dist_fecha (fecha_anterior date, dist_nvo integer,dist_vjo integer)
returns void as $body$
BEGIN
update unc_esq_peliculas.entrega set id_distribuidor = dist_nvo
where fecha_entrega > fecha_anterior and id_distribuidor = dist_vjo;
end;
$body$ language 'plpgsql';

select * from unc_esq_peliculas.entrega order by fecha_entrega desc limit 10;
select fn_cambiar_dist_fecha(to_date('06-09-2006','dd-mm-yyyy'), 869, 64 );

--EJERCICIO 3
-- Para el esquema unc_voluntarios se desea conocer la cantidad de voluntarios que hay en cada
-- tarea al inicio de cada mes y guardarla a lo largo de los meses. Para esto es necesario hacer un
-- procedimiento que calcule la cantidad y la almacene en una tabla denominada
-- CANT_VOLUNTARIOSXTAREA con la siguiente estructura:

--CANT_VOLUNTARIOSXTAREA (anio, mes, id_tarea, nombre_tarea, cant_voluntarios)

create table if not exists unc_esq_voluntario.cant_voluntariosxtarea(
anio numeric(6,0) not null,
mes numeric(2,0) not null,
id_tarea char(10) not null,
nombre_tarea varchar(40) not null,
cant_voluntarios numeric(6,0),
constraint pk_vxt primary key (id_tarea)
) 

create or replace function fn_voluntariosxmes()
returns void as $body$
begin
--select id_tarea, count(*) from unc_esq_voluntario.voluntario group by id_tarea;
insert into unc_esq_voluntario.cant_voluntariosxtarea 
(select extract(year from now()), extract(month from now()), id_tarea, nombre_tarea, count(*) cant_voluntarios 
from unc_esq_voluntario.voluntario natural join unc_esq_voluntario.tarea
group by id_tarea, nombre_tarea
);
end;
$body$ language 'plpgsql';

-- para hacerlo cada inicio de mes necesitaia usar 'pg_cron'
-- https://docs.aws.amazon.com/es_es/AmazonRDS/latest/UserGuide/PostgreSQL_pg_cron.html