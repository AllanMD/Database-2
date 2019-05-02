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

/*Realizar los siguientes ejercicios de forma Explícita o Implícita.*/
set autocommit = 0;
/*1) Ejecutar una transacción que agregue un equipo con todos sus jugadores.*/
START TRANSACTION;
INSERT INTO equipos (nombre_equipo) VALUES ("River Plate");

SET @id_equipo = LAST_INSERT_ID();

INSERT INTO jugadores (id_equipo, nombre, apellido) values (@id_equipo, "Oso", "Pratto"), (@id_equipo, "Nacho","Scocco");
COMMIT;

/*2) Ejecutar las estadísticas de un jugador (puntos, asistencias, rebotes, faltas).*/

SELECT j.id_jugador, j.nombre, ifnull(avg(jep.puntos),0) as puntos, ifnull(avg(jep.asistencias),0) as asistencias,
 ifnull(avg(jep.rebotes),0) as rebotes, ifnull(avg(jep.faltas),0) as faltas
FROM jugadores j left outer join jugadores_x_equipo_x_partido jep on j.id_jugador = jep.id_jugador
group by j.id_jugador,j.nombre;

/*3) Ingresar de forma temporal 3 partidos y mostrar cómo quedaría la grilla de partidos
para esa fecha.*/

START TRANSACTION;

INSERT INTO partidos (id_equipo_local, id_equipo_visitante, fecha) values (5,3, now()), (1,5,now()), (2,3, now());

SELECT * FROM partidos;

ROLLBACK;

SELECT * FROM partidos;

/*4) Ingresar dos equipos con sus jugadores e ingresar un partido con dichos equipos
ingresados, todo en la misma transacción.*/