/*

Michael jordan telleria guadalajara 1ro DAM

10.-Muestra todos los datos que contienen las tablas, para ello deberías ejecutar 
los comandos SQL (DML) necesarios (analiza bien cada una de las tablas, para poder 
resolver las siguientes preguntas).

1.-Equipos que forman parte de la conferencia Oeste(West).
2.-Equipos cuyo nombre comienza por H y termina por S.
3.-¿Cuántos jugadores argentinos juegan en la NBA?.
4.-Jugadores españoles que juegan en los equipos Lakers y Raptors.
5,-Jugadores que no proceden de Florida, Utah o España.
6.-Visualizar el número de jugadores españoles y franceses, con el país correspondiente.
 7.-Muestra el jugador que más puntos a metido en la NBA.
8.-¿Cuántos jugadores tiene cada equipo de la conferencia Este (East)?.
9.-¿Cuál es la temporada en la que Lebrón James consiguió más puntos por partido? 
*/
use nba;

select * from equipos, estadisticas, jugadores,partidos;

/*Equipos que forman parte de la conferencia Oeste(West)*/
select nombre,conferencia
from equipos where conferencia = 'West';

/*Equipos cuyo nombre comienza por H y termina por S.*/
select nombre
from equipos
where left(nombre,1)='H'
and right(nombre,1)='S'	;

/*¿Cuántos jugadores argentinos juegan en la NBA?.*/

select count(nombre),procedencia
from jugadores
where Procedencia ='argentina';

/*Jugadores españoles que juegan en los equipos Lakers y Raptors.*/

select nombre, procedencia,nombre_equipo
from jugadores 
where procedencia= 'Spain'and
nombre_equipo= 'lakers' or 'Raptors';


/*Jugadores que no proceden de Florida, Utah o España*/

select nombre, procedencia,count(procedencia)as Jugadores_de
from jugadores 
where procedencia 
not in('florida','Utah','Spain') 
group by procedencia asc;

/*Visualizar el número de jugadores españoles y franceses, con el país correspondiente*/

select procedencia as pais,count(procedencia)as cantidad 
from jugadores
where Procedencia in ('Spain','france')
group by pais;

/*Muestra el jugador que más puntos a metido en la NBA*/

select jugadores.nombre,(partidos.puntos_local + partidos.puntos_visitante)
 as total
from jugadores
inner join partidos
on jugadores.codigo = partidos.codigo 
order by total desc limit 1;


/*¿Cuántos jugadores tiene cada equipo  
    de la conferencia Este (East)?
*/

select equipos.nombre as equipo, equipos.conferencia,count(jugadores.codigo) as total_jugadores 
from equipos
join jugadores on equipos.nombre = jugadores.nombre_equipo
 where conferencia='East'
 group by equipos.nombre
 order by total_jugadores ;

/*  ¿Cuál es la temporada en la que Lebrón James consiguió 
    más puntos por partido? 
*/
select jugadores.nombre as Nombre_jugador,estadisticas.puntos_por_partido as MaximaPuntuacion_temporada,partidos.temporada
from jugadores 
join estadisticas on estadisticas.puntos_por_partido
join partidos on partidos.temporada
where jugadores.nombre='LeBron james'
order by estadisticas.puntos_por_partido desc limit 1  ;




