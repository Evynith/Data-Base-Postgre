select * from unc_esq_voluntario.institucion;

--1. Seleccione el identificador y nombre de todas las instituciones que son Fundaciones.(V)
select id_institucion, nombre_institucion
from unc_esq_voluntario.institucion
where nombre_institucion ILIKE 'fundacion%';

--2. Seleccione el identificador de distribuidor, identificador de departamento y nombre de todos los departamentos.(P)
select id_distribuidor, id_departamento, nombre
from unc_esq_peliculas.departamento;

--3. Muestre el nombre, apellido y el teléfono de todos los empleados cuyo id_tarea sea 7231, ordenados por apellido y nombre.(P)
select nombre, apellido , telefono
from unc_esq_peliculas.empleado
where id_tarea = '7231'
order by apellido, nombre;

--4. Muestre el apellido e identificador de todos los empleados que no cobran porcentaje de comisión.(P)
select id_empleado, apellido
from unc_esq_peliculas.empleado
where porc_comision IS NULL;

--5. Muestre el apellido y el identificador de la tarea de todos los voluntarios que no tienen coordinador.(V)
select apellido, nro_voluntario
from unc_esq_voluntario.voluntario
where id_coordinador IS NULL;


select * 
from unc_esq_peliculas.distribuidor;

--6. Muestre los datos de los distribuidores internacionales que no tienen registrado teléfono. (P)
select * 
from unc_esq_peliculas.distribuidor
where tipo LIKE 'I'
and telefono IS NULL;

--7. Muestre los apellidos, nombres y mails de los empleados con cuentas de gmail y cuyo sueldo sea superior a $ 1000. (P)
select apellido, nombre, e_mail
from unc_esq_peliculas.empleado
where sueldo > 1000;

--8. Seleccione los diferentes identificadores de tareas que se utilizan en la tabla empleado. (P)
select distinct id_tarea
from unc_esq_peliculas.empleado
order by id_tarea asc;

--9. Muestre el apellido, nombre y mail de todos los voluntarios cuyo teléfono comienza con +51. Coloque el encabezado de las columnas de los títulos &#39;Apellido y Nombre&#39; y &#39;Dirección de mail&#39;. (V)
select apellido || ',' || nombre as "Apellido y Nombre", e_mail as "Direccion de mail"
from unc_esq_voluntario.voluntario
where telefono LIKE '+51%';

--10. Hacer un listado de los cumpleaños de todos los empleados donde se muestre el nombre y el apellido (concatenados y separados por una coma) y su fecha de cumpleaños (solo el día y el mes), ordenado de acuerdo al mes y día de cumpleaños en forma ascendente. (P)
select nombre || ',' || apellido as "Nombre y Apellido", extract(day from fecha_nacimiento) || '/' ||extract(month from fecha_nacimiento) as "Cumpleaños"
from unc_esq_peliculas.empleado
order by extract(month from fecha_nacimiento), extract(day from fecha_nacimiento) asc;

--11. Recupere la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios nacidos desde 1990. (V)
select min(horas_aportadas), max(horas_aportadas), avg(horas_aportadas)
from unc_esq_voluntario.voluntario
where extract(year from fecha_nacimiento) > 1990;

--12. Listar la cantidad de películas que hay por cada idioma. (P)
select idioma, count(idioma)
from unc_esq_peliculas.pelicula
group by idioma;

--13. Calcular la cantidad de empleados por departamento. (P)
select id_departamento, count(*)
from unc_esq_peliculas.empleado
group by id_departamento;

--14. Mostrar los códigos de películas que han recibido entre 3 y 5 entregas. (veces entregadas, NO cantidad de películas entregadas).
select codigo_pelicula
from unc_esq_peliculas.renglon_entrega
group by codigo_pelicula
having count(*) between 3 and 5;

--15. ¿Cuántos cumpleaños de voluntarios hay cada mes?
select extract (month from fecha_nacimiento) ,count(*)
from unc_esq_voluntario.voluntario
group by extract (month from fecha_nacimiento)
order by extract (month from fecha_nacimiento);

--16. ¿Cuáles son las 2 instituciones que más voluntarios tienen?
select id_institucion, count(*)
from unc_esq_voluntario.voluntario
group by id_institucion
order by count(*) desc
limit 2;

--17. ¿Cuáles son los id de ciudades que tienen más de un departamento?
select id_ciudad, count(*)
from unc_esq_peliculas.departamento
group by id_ciudad
having count(*) > 1;