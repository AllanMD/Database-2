create database guia6_indices;

use guia6_indices;

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


/*1_ Crear índices UNIQUE para que no se repita el mismo partido , no se repita
unnombre de equipo y no se pueda registrar un nombre y apellido de un jugador en elmismo equipo.*/

CREATE UNIQUE INDEX idx_partidos_equipos ON partidos (id_equipo_local,id_equipo_visitante) USING HASH;
CREATE UNIQUE INDEX idx_equipos_nombres ON equipos(nombre_equipo) USING HASH;
CREATE UNIQUE INDEX idx_jugadores ON jugadores(nombre,apellido) USING HASH; --preguntar si usar hash o btree

/*2_ Escribir una consulta que nos permita obtener los nombres de los equipos
 ordenados por orden alfabetico descendente y realizar las estructuras de índices necesarias para optimizar el ordenado*/

SELECT nombre_equipo FROM equipos order by nombre_equipo desc;

 CREATE INDEX idx_equipos_nombres_ordenados ON equipos(nombre_equipo desc) USING BTREE; 

 DROP INDEX idx_equipos_nombres_ordenados ON equipos; -- para borrar un indice

/*3_ Listar nombre y apellido jugadores de los jugadores cuyo apellido
 comience con una determinada letra, sin la necesidad de realizar un Full Scan.*/

CREATE INDEX idx_listar_jugadores ON jugadores (nombre asc, apellido asc) USING BTREE;

select * from jugadores WHERE apellido like "M%"; --el indice va a estar formado primero por nombre y despues por apellido

explain select * from jugadores WHERE apellido like "M%"; -- para comprobar que la busqueda se hace con el indice

/*4) Realizar las estructuras necesarias para poder buscar jugadores optimamente por
Nombre y Apellido de manera exacta, es decir Nombre = “pepe” apellido = “juarez”*/

CREATE INDEX idx_jugadores_nombres ON jugadores(nombre) USING HASH;
CREATE INDEX idx_jugadores_apellidos ON jugadores(apellido)USING HASH;

explain select * FROM jugadores WHERE nombre = "Juani" AND apellido = "Marcos";

/*5) Generar las estructuras necesarias para buscar optimamente partidos jugados entre
dos fechas .*/

CREATE INDEX idx_partidos_fechas ON partidos (fecha) USING BTREE;

explain select * from partidos where fecha BETWEEN "2019-05-23" AND "2019-05-27";

/*6) Generar los índices necesarios para buscar equipos que comiencen con determinada
letra.*/

CREATE UNIQUE INDEX idx_equipos_nombres ON equipos(nombre_equipo) USING BTREE;

explain select * from equipos where nombre_equipo LIKE "P%";















