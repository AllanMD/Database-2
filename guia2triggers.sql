create database triggers;

use triggers;

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

/*1)Generar un trigger que evite la carga de nuevos jugadores.*/

CREATE TRIGGER TIB_EVITAR_CARGA_JUGADOR BEFORE INSERT ON jugadores FOR EACH ROW

        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'NO SE PUEDE INGRESAR JUGADOR';


/*2)Generar un trigger que evite la carga de jugadores con el mismo nombre y apellido enel mismo equipo.*/

DELIMITER $$
CREATE TRIGGER TIB_EVITAR_CARGA_MISMO_NOMBRE_APELLIDO_MISMO_EQUIPO BEFORE INSERT ON jugadores FOR EACH ROW
BEGIN
DECLARE cont int DEFAULT 0;

SELECT count(*) into cont FROM jugadores where nombre = new.nombre AND apellido = new.apellido AND id_equipo = new.id_equipo;

IF (cont > 0) THEN
        SIGNAL SQLSTATE '16146'
		SET MESSAGE_TEXT = 'NO SE PUEDE INGRESAR JUGADOR, YA EXISTE EN EL EQUIPO';
END IF;

END$$ 

/*3)Generar un trigger que no permita ingresar los datos de un jugador a la tabla jugadores_x_equipo_x_partido ​que no haya juado el partido*/

DELIMITER $$

CREATE TRIGGER TIB_EVITAR_CARGA_JUGADOR_NO_JUGO_PARTIDO BEFORE INSERT ON jugadores_x_equipo_x_partido FOR EACH ROW
BEGIN


DECLARE cont int DEFAULT 0;

SELECT count(*) into cont FROM 
(SELECT * FROM partidos p inner join equipos e on p.id_equipo_local = e.id_equipo where p.id_partido = new.id_partido
UNION
SELECT * FROM partidos p inner join equipos e on p.id_equipo_visitante = e.id_equipo where p.id_partido = new.id_partido) as equipos inner join jugadores j 
on equipos.id_equipo = j.id_equipo where j.id_jugador = new.id_jugador;

IF (cont = 0) THEN
       SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'NO SE PUEDE INGRESAR JUGADOR, NO JUGO EL PARTIDO';
END IF;

END $$

insert into jugadores_x_equipo_x_partido (id_jugador, id_partido, puntos, rebotes, asistencias, faltas)
values (4,1,1,1,1,1); /*para probar*/


/*4)Agregar el campo cantidad_jugadores a la tabla equipos y calcularlo mediante los triggers necesarios para ello */
ALTER TABLE equipos ADD cantidad_jugadores int;

DELIMITER $$

CREATE TRIGGER TIB_CALCULAR_CANTIDAD_JUGADORES AFTER INSERT ON jugadores FOR EACH ROW
BEGIN

DECLARE cantidad int default 0;

SELECT count(*) into cantidad FROM equipos e inner join jugadores j 
on e.id_equipo = j.id_equipo WHERE e.id_equipo = new.id_equipo;

UPDATE equipos SET cantidad_jugadores = cantidad where id_equipo = new.id_equipo; 

END $$


insert into jugadores (nombre,apellido, id_equipo) values ( "aaa" , "sss", 1);


/* no es necesario sumar +1 porq el select se hace despues de insertar el jugador */
/*despues de agregar un jugador, hacer update de cant jugadores*/

/* 5)Agregar los campos fecha_nacimiento y edad a la tabla de jugadores y 
cuando se inserte o modifique la fecha de nacimiento recalcule la edad actual del jugador. */

ALTER TABLE jugadores ADD fecha_nacimiento date;
ALTER TABLE jugadores ADD edad int;

DELIMITER $$

CREATE TRIGGER TIB_CALCULAR_FECHA_NACIMIENTO BEFORE INSERT ON jugadores FOR EACH ROW
BEGIN 

SET new.edad = (TIMESTAMPDIFF(year,new.fecha_nacimiento,CURDATE()));

END $$

insert into jugadores (id_jugador, id_equipo, nombre, apellido, fecha_nacimiento) values (7,7,"uasddsu", "hdsdsh", "1997-09-28");
/*para probar // terminar el ejercicio, falta al modificar

/* 6)Agregar los campos puntos_equipo_local y puntos_equipo_visitante a la tabla de partidos y realizar los
 triggers necesarios para mantener automaticamente el resultado del partido en base a lo cargado en la tabla jugadores_x_equipo_x_partido*/

ALTER TABLE partidos ADD puntos_equipo_local int default 0;
ALTER TABLE partidos ADD puntos_equipo_visitante int default 0;

DELIMITER $$

CREATE TRIGGER TIB_ACTUALIZAR_RESULTADOS AFTER INSERT ON jugadores_x_equipo_x_partido FOR EACH ROW
BEGIN

DECLARE id_equipo_jugador int default 0;
DECLARE id_local int;
DECLARE id_visitante int;
DECLARE puntos_local int default 0;
DECLARE puntos_visitante int default 0;

SELECT id_equipo INTO id_equipo_jugador FROM jugadores WHERE id_jugador = new.id_jugador;
SELECT id_equipo_local into id_local FROM partidos WHERE id_partido = new.id_partido;
SELECT id_equipo_visitante into id_visitante FROM partidos WHERE id_partido = new.id_partido ;

SELECT puntos_equipo_local into puntos_local FROM partidos where id_partido = new.id_partido;
SELECT puntos_equipo_local into puntos_visitante FROM partidos where id_partido = new.id_partido;

 CASE 
    WHEN id_equipo_jugador = id_local THEN
    UPDATE partidos SET puntos_equipo_local = puntos_local + new.puntos 
    WHERE id_partido = new.id_partido; 

    WHEN id_equipo_jugador = id_visitante THEN
    UPDATE partidos SET puntos_equipo_visitante = puntos_visitante + new.puntos 
    WHERE id_partido = new.id_partido;
 END CASE;

END $$

/*para probar*/

DELETE FROM jugadores_x_equipo_x_partido WHERE id_jugador = 1;

INSERT INTO jugadores_x_equipo_x_partido (id_jugador, id_partido, puntos, rebotes, asistencias,
minutos, faltas) values (1,1,500,2,3,4,5);



