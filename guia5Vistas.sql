create database tp4_transacciones;

use tp4_transacciones;

create table equipos (
    id_equipo int auto_increment,
    nombre_equipo varchar (50),
    CONSTRAINT pk_equipos PRIMARY KEY (id_equipo)
);
create table partidos (
    id_partido int auto_increment, /* poner not null*/
    id_equipo_local int,
    id_equipo_visitante int,
    fecha DateTime,
    CONSTRAINT pk_partidos PRIMARY KEY (id_partido),
    CONSTRAINT fk_partidos_equipo_local FOREIGN KEY (id_equipo_local) REFERENCES equipos (id_equipo),
    CONSTRAINT fk_partidos_equipo_visitante FOREIGN KEY (id_equipo_visitante) REFERENCES equipos (id_equipo)
);

create table jugadores (
    id_jugador int auto_increment,
    id_equipo int ,
    nombre varchar (50),
    apellido varchar (50),
    CONSTRAINT pk_jugadores PRIMARY KEY (id_jugador),
    CONSTRAINT fk_equipo_jugadores FOREIGN KEY (id_equipo) REFERENCES equipos (id_equipo)
);

create table jugadores_x_equipo_x_partido (
    id_jugador int ,
    id_partido int,
    puntos int,
    rebotes int,
    asistencias int,
    minutos int, 
    faltas int ,
    CONSTRAINT pk_jugador_x_equipo PRIMARY KEY (id_jugador, id_partido),
    CONSTRAINT fk_jugador_x_equipo_x_partido FOREIGN KEY (id_jugador) REFERENCES jugadores (id_jugador),
    CONSTRAINT fk_partido_x_jugador_x_equipo FOREIGN KEY (id_partido) REFERENCES partidos (id_partido)
);


insert into equipos(nombre_equipo) values('Peñarol'),('Regatas'),('Obras');
insert into jugadores(nombre,apellido,id_equipo) values('Juani','Marcos',1),('Paolo','Quinteros',2),('Selem','Safar',3);
insert into partidos(id_equipo_local,id_equipo_visitante,fecha) values (1,2,now()),(1,3,now());
insert into jugadores_x_equipo_x_partido(id_jugador,id_partido,puntos) values(1,1,20),(2,1,10),(1,2,33),(3,2,17);

/*1) Realizar una vista que muestre todos los jugadores de un equipo*/

create view view_jugadores_river as select j.id_jugador, j.nombre, j.apellido, e.nombre_equipo as equipo, e.id_equipo
from jugadores j inner join equipos e
on j.id_equipo = e.id_equipo where e.nombre_equipo ="River Plate";

SELECT * FROM view_jugadores_river; -- para llamar a la vista

DROP VIEW [IF EXISTS] view_jugadores_river; -- para borrar la vista

/*2) Realizar una vista que muestre nombre un equipo con sus jugadores*/

-- no se entiende bien

/*3) Realizar una vista que muestre el jugador con más puntos realizados*/

CREATE VIEW view_jugador_mas_puntos AS SELECT j.id_jugador, CONCAT(j.nombre, " ", j.apellido) as jugador, jep.puntos
FROM jugadores j inner join jugadores_x_equipo_x_partido jep on j.id_jugador = jep.id_jugador 
WHERE jep.puntos = (select max(jep.puntos) from jugadores_x_equipo_x_partido jep);

SELECT * FROM view_jugador_mas_puntos;
-- el concat por ahi si queremos trabajar con el nombre y el apellido por separado no sirve mucho

/*4) Realizar una vista que muestre todos los partidos del año en curso dividido por mes*/
