create database guia0;

use guia0;

create table equipos (
    id_equipo int auto_increment,
    nombre_equipo varchar (50),
    CONSTRAINT pk_equipos PRIMARY KEY (id_equipo)
)
create table partidos (
    id_partido int auto_increment, /* poner not null*/
    id_equipo_local int,
    id_equipo_visitante int,
    fecha DateTime,
    CONSTRAINT pk_partidos PRIMARY KEY (id_partido),
    CONSTRAINT fk_partidos_equipo_local FOREIGN KEY (id_equipo_local) REFERENCES equipos (id_equipo)
    CONSTRAINT fk_partidos_equipo_visitante FOREIGN KEY (id_equipo_visitante) REFERENCES equipos (id_equipo)
)

create table jugadores (
    id_jugador int auto_increment,
    id_equipo int ,
    nombre varchar (50),
    apellido varchar (50),
    CONSTRAINT pk_jugadores PRIMARY KEY (id_jugador),
    CONSTRAINT fk_ /*terminar*/
)


/* 2)Generar un Stored Procedure que permita agregar un jugador. Se debe generar unerror con código 1 si el equipo no existe*/
DELIMITER $$
create Procedure pinsertarJugador (pIdEquipo bigint(20), pNombre varchar(50), pApellido varchar (50), pDni varchar (12), OUT pIdJugador bigint (20))

BEGIN 
declare vIdEquipo bigint (20) DEFAULT 0;
select id_equipo into vIdEquipo from equipos where id_equipo = pIdEquipo;
IF (vIdEquipo <> 0) then
    insert into jugadores (nombre, apellido, dni, id_equipo)
    values (pNombre,pApellido, pDni, pIdEquipo);
    SET pIdJugador = LAST_INSERT_ID();
else 
    signal SQLSTATE  "11111" SET MESSAGE_TEXT "No existe el equipo", mysql_errno = "10000" 
    /*signal sqlstate es para tirrar un error, excepcion */
END IF;
END

$$

CALL pinsertarJugador (9999, "pablo", "fino", "2222",@vidJugador)

/*otra forma de resolver // lo mismo pero con // se supone q es mas eficiente (?*/
if exists (select id_equipo from equipos where id_equipo = pIdEquipo) then 

/*3)Generar un Stored Procedure que permita agregar un jugador pero se debe pasar elnombre del equipo y no el Id.*/

/* 4)Generar un Stored Procedure que permita dar de alta un equipo y sus jugadores.Devolver en un parámetro output el id del equipo. */

create temporary table jugadoresInsertar ( nombre varchar (50),
                                            apellido varchar (50),
                                            dni varchar (12) primary key);

insert into jugadoresInsertar(nombre,apellido, dni ) values ("ignacio", "casales", "4000000");
insert into jugadoresInsertar(nombre,apellido, dni ) values ("juancho", "talarga", "432320");

DELIMITER $$
CREATE PROCEDURE pInstertarEquiposJugadores (pNombreEquipo varchar(50), OUT pIdEquipo bigint(20))
BEGIN
insert into equipos (nombre_equipo) values (pNombreEquipo);
SET pIdEquipo = LAST_INSERT_ID();

insert into jugadores (nombre, apellido, dni, id_equipo)
SELECT nombre,apellido,dni, pid_equipo from jugadoresInsertar;

END
$$

CALL pInstertarEquiposJugadores ("utn team", @vIdEquipo) /*que hace @vIdEquipo? */ 

/* 6)Generar un Stored Procedure que devuelva el resultado de un partido pasando porparámetro los nombres de los equipos.
 El resultado debe ser devuelto en dos variables output */