SELECT * FROM pg_stat_activity

--1.1. Listar todas las películas que poseen entregas de películas de idioma inglés durante el año 2006. (P)

select *
from unc_esq_peliculas.pelicula p
where idioma like 'Inglés'
and exists (
	select 1
	from unc_esq_peliculas.renglon_entrega re
	where p.codigo_pelicula = re.codigo_pelicula
	and exists (
		select 1
		from unc_esq_peliculas.entrega e
		where re.nro_entrega = e.nro_entrega
		and extract(year from fecha_entrega) = 2006
	)
);

--1.2. Indicar la cantidad de películas que han sido entregadas en 2006 por un distribuidor nacional. Trate de resolverlo utilizando ensambles.(P)

	select sum(re.cantidad)
	from unc_esq_peliculas.renglon_entrega re
	where exists (
		select 1
		from (unc_esq_peliculas.entrega natural join unc_esq_peliculas.distribuidor) as de
		where re.nro_entrega = de.nro_entrega
		and extract(year from de.fecha_entrega) = 2006
		and tipo like 'N'
		)
		
--1.3. Indicar los departamentos que no posean empleados cuya diferencia de sueldo máximo y mínimo (asociado a la tarea que realiza) no supere el 40% del sueldo máximo. (P) (Probar con 10% para que retorne valores)

select id_departamento
from unc_esq_peliculas.departamento d
where not exists (
	select 1
	from (unc_esq_peliculas.empleado natural join unc_esq_peliculas.tarea) as te
	where te.id_departamento = d.id_departamento
	and (te.sueldo_maximo - te.sueldo_minimo ) <= (select max(sueldo_maximo) * 0.4 from unc_esq_peliculas.tarea)
);

--1.4. Liste las películas que nunca han sido entregadas por un distribuidor nacional.(P)

select titulo
from unc_esq_peliculas.pelicula p
where not exists (
	select  1
	from unc_esq_peliculas.renglon_entrega re
	where p.codigo_pelicula = re.codigo_pelicula
	and exists (
		select 1
		from unc_esq_peliculas.entrega e
		where e.nro_entrega = re.nro_entrega
		and exists (
			select 1
			from unc_esq_peliculas.distribuidor d
			where d.id_distribuidor = e.id_distribuidor
			and tipo like 'N'
		)
	)
);

select titulo
from unc_esq_peliculas.pelicula
where codigo_pelicula in (
	select distinct ree.codigo_pelicula
	from (unc_esq_peliculas.renglon_entrega natural join unc_esq_peliculas.entrega) as ree
	where ree.id_distribuidor not in (
		select d.id_distribuidor
		from unc_esq_peliculas.distribuidor d
		where d.tipo like 'N'
	)
);

--1.5. Determinar los jefes que poseen personal a cargo y cuyos departamentos (los del jefe) se encuentren en la Argentina.

	select distinct id_jefe
	from unc_esq_peliculas.empleado e1
	where exists (
		select id_jefe
		from unc_esq_peliculas.empleado e2
		where e1.id_jefe = e2.id_jefe
		and exists (
		select 1
		from unc_esq_peliculas.departamento d
		where e2.id_departamento = d.id_departamento
		and exists (
			select 1
			from unc_esq_peliculas.ciudad c
			where c.id_ciudad = d.id_ciudad
			and exists (
				select *
				from unc_esq_peliculas.pais p
				where p.id_pais = c.id_pais
				and nombre_pais like 'ARGENTINA'
			)
		)
	) );

--1.6. Liste el apellido y nombre de los empleados que pertenecen a aquellos departamentos de Argentina y donde el jefe de departamento posee una comisión de más del 10% de la que posee su empleado a cargo.

select apellido, nombre
from unc_esq_peliculas.empleado e1
		where exists (
		select 1
		from unc_esq_peliculas.departamento d
		where e1.id_departamento = d.id_departamento
			and exists (
			select 1
			from unc_esq_peliculas.ciudad c
			where c.id_ciudad = d.id_ciudad
			and exists (
				select *
				from unc_esq_peliculas.pais p
				where p.id_pais = c.id_pais
				and nombre_pais like 'ARGENTINA'
					)
			)
			and d.jefe_departamento in (
				select d2.id_empleado
				from unc_esq_peliculas.empleado d2
				where (d2.porc_comision - e1.porc_comision) > 10
			)
	) 
	
--1.7. Indicar la cantidad de películas entregadas a partir del 2010, por género.

select p.genero, sum(p.cantidad)
from (unc_esq_peliculas.pelicula natural join unc_esq_peliculas.renglon_entrega) as p
where exists (
		select 1
	from unc_esq_peliculas.entrega e
	where p.nro_entrega = e.nro_entrega
	and extract(year from e.fecha_entrega) >= 2010
)
group by p.genero;

--1.8. Realizar un resumen de entregas por día, indicando el video club al cual se le realizó la entrega y la cantidad entregada. Ordenar el resultado por fecha.

select fecha_entrega, sum(cantidad), id_video
from unc_esq_peliculas.renglon_entrega natural join unc_esq_peliculas.entrega
group by fecha_entrega, id_video
order by fecha_entrega;

--1.9. Listar, para cada ciudad, el nombre de la ciudad y la cantidad de empleados mayores de edad que desempeñan tareas en departamentos de la misma y que posean al menos 30 empleados.

select age(fecha_nacimiento), extract(year from age(fecha_nacimiento))
from unc_esq_peliculas.empleado


select *
from  unc_esq_peliculas.empleado e inner join unc_esq_peliculas.departamento d on e.id_departamento = d.id_departamento;

select id_ciudad, count(*)
from unc_esq_peliculas.empleado e inner join unc_esq_peliculas.departamento d on e.id_departamento = d.id_departamento
where extract(year from age(fecha_nacimiento)) >= 18
and e.id_departamento in (
	select e2.id_departamento
	from unc_esq_peliculas.empleado e2
	group by e2.id_departamento
	having count(*) >= 30
)
group by id_ciudad;

--
select id_ciudad from unc_esq_peliculas.departamento where id_departamento = 8;

select e1.id_departamento, count(extract(year from age(fecha_nacimiento)) >= 18) as m18,
	(select id_ciudad from unc_esq_peliculas.departamento as d where e1.id_departamento = d.id_departamento limit 1) as id_ciudad
-- select e1.id_departamento, count(*)
from unc_esq_peliculas.empleado e1
where e1.id_departamento in (
	select e2.id_departamento
	from unc_esq_peliculas.empleado e2
	group by e2.id_departamento
	having count(*) >= 30
)
group by e1.id_departamento;


--EJERCICIO 2
--2.1. Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan aportes. Ordene el resultado por nombre de institución.

select nombre_institucion, count(*)
from (unc_esq_voluntario.institucion natural join unc_esq_voluntario.voluntario) as iv
where iv.horas_aportadas is not null
group by nombre_institucion
order by nombre_institucion

select * from unc_esq_voluntario.historico

--2.2. Determine la cantidad de coordinadores en cada país, agrupados por nombre de país y nombre de continente. Etiquete la primer columna como &#39;Número de coordinadores&#39;

select count(*) as "Número de coordinadores", nombre_pais,nombre_continente
from unc_esq_voluntario.pais natural join unc_esq_voluntario.continente natural join unc_esq_voluntario.direccion natural join unc_esq_voluntario.institucion natural join unc_esq_voluntario.voluntario
where nro_voluntario in (
	select distinct id_coordinador
	from unc_esq_voluntario.voluntario
)
group by nombre_pais,nombre_continente

select count(*) as "Número de coordinadores", nombre_pais,nombre_continente
from (unc_esq_voluntario.pais natural join unc_esq_voluntario.continente natural join unc_esq_voluntario.direccion natural join unc_esq_voluntario.institucion natural join unc_esq_voluntario.voluntario) as l
where exists (
	select distinct id_coordinador
	from unc_esq_voluntario.voluntario
	where l.nro_voluntario = id_coordinador
)
group by nombre_pais,nombre_continente

--2.3. Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de cualquier voluntario que trabaje en la misma institución que el Sr. de apellido Zlotkey. Excluya del resultado a Zlotkey.

select v.apellido, v.nombre, v.fecha_nacimiento
from unc_esq_voluntario.voluntario v
where apellido not like 'Zlotkey'
and v.id_institucion in (
	select v2.id_institucion
	from unc_esq_voluntario.voluntario v2
	where apellido like 'Zlotkey'
)

--2.4. Cree una consulta para mostrar los números de voluntarios y los apellidos de todos los voluntarios cuya cantidad de horas aportadas sea mayor que la media de las horas aportadas. Ordene los resultados por horas aportadas en orden ascendente.

select nro_voluntario, apellido
from unc_esq_voluntario.voluntario
where horas_aportadas > (
	select avg(horas_aportadas)
	from unc_esq_voluntario.voluntario
)
order by horas_aportadas asc;

--EJERCICIO 3
--3.1 Se solicita llenarla con la información correspondiente a los datos completos de todos los distribuidores nacionales.

CREATE TABLE unc_esq_peliculas.DistribuidorNac
(
id_distribuidor numeric(5,0) NOT NULL,
nombre character varying(80) NOT NULL,
direccion character varying(120) NOT NULL,
telefono character varying(20),
nro_inscripcion numeric(8,0) NOT NULL,
encargado character varying(60) NOT NULL,
id_distrib_mayorista numeric(5,0),
CONSTRAINT pk_distribuidorNac PRIMARY KEY (id_distribuidor)
);

insert into unc_esq_peliculas.DistribuidorNac (id_distribuidor, nombre, direccion, telefono, nro_inscripcion, encargado, id_distrib_mayorista) 
select id_distribuidor, nombre, direccion, telefono, nro_inscripcion, encargado, id_distrib_mayorista from unc_esq_peliculas.distribuidor natural join unc_esq_peliculas.nacional;

select * from unc_esq_peliculas.DistribuidorNac;

--3.2 Agregar a la definición de la tabla DistribuidorNac, el campo &quot;codigo_pais&quot; que indica el código de país del distribuidor mayorista que atiende a cada distribuidor nacional.(codigo_pais character varying(5) NULL)

alter TABLE  unc_esq_peliculas.DistribuidorNac
add column codigo_pais character varying(5) NULL;

--3.3. Para todos los registros de la tabla DistribuidorNac, llenar el nuevo campo &quot;codigo_pais&quot; con el valor correspondiente existente en la tabla &quot;Internacional&quot;.

update unc_esq_peliculas.DistribuidorNac set codigo_pais = 
(select codigo_pais from unc_esq_peliculas.internacional i where id_distrib_mayorista is not null and id_distrib_mayorista = i.id_distribuidor );

select * from unc_esq_peliculas.distribuidor natural join unc_esq_peliculas.nacional where id_distrib_mayorista is not null;

--3.4. Eliminar de la tabla DistribuidorNac los registros que no tienen asociado un distribuidor mayorista.

delete from unc_esq_peliculas.DistribuidorNac where id_distrib_mayorista is null;