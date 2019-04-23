create database tp3_cursores;

use tp3_cursores;

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


/*1) Generar un stored procedure que liste los jugadores y a que equipo pertenecen
utilizando cursores.*/
DELIMITER $$
CREATE PROCEDURE pListarJugadoresCursores()

begin
  DECLARE vFinished int default 0;
  DECLARE cNombre varchar(50);
  DECLARE cApellido varchar(50);
  DECLARE cNombreEquipo varchar(50);
  DECLARE cListarJugadores CURSOR FOR SELECT j.nombre, j.apellido, e.nombre_equipo FROM jugadores j INNER JOIN equipos e on j.id_equipo = e.id_equipo;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;

  OPEN cListarJugadores;
  listar: loop
    FETCH cListarJugadores INTO cNombre, cApellido, cNombreEquipo;
    IF vFinished = 1 THEN 
    LEAVE listar;
    END IF;
    SELECT cNombre, cApellido, cNombreEquipo;
  end loop listar;
  CLOSE cListarJugadores;
end;
$$ 

call pListarJugadoresCursores();

/*2) Generar un stored procedure que liste los resultados de todos los partidos.*/
DELIMITER $$

CREATE PROCEDURE pListarResultados()

BEGIN
  DECLARE vFinished int default 0;
  DECLARE cId_Partido int;
  DECLARE cId_Equipo_Local int;
  DECLARE cId_Equipo_Visitante int;
  DECLARE cListarResultados CURSOR FOR SELECT
                p.id_partido,  -- El cursor va a obtener estos datos y los va a almacenar, fila por fila 
                p.id_equipo_local,
                p.id_equipo_visitante
                FROM partidos p;
                
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;

  OPEN cListarResultados;
  listar: loop
    FETCH cListarResultados INTO cId_Partido, cId_Equipo_Local, cId_Equipo_Visitante --guardamos los datos en las variables declaradas, en el mismo orden que en el select;
    IF vFinished = 1 THEN -- y de esta manera podemos trabajar sobre datos individuales fila por fila
    LEAVE listar;
    END IF;
    SELECT cId_Partido, e.nombre_equipo, sum(jep.puntos) as puntos_local, e2.nombre_equipo, sum(jep2.puntos) as puntos_visitante
    FROM jugadores_x_equipo_x_partido jep inner join jugadores j on jep.id_jugador = j.id_jugador inner join equipos e on j.id_equipo = e.id_equipo
    inner join jugadores_x_equipo_x_partido jep2 inner join jugadores j2 on jep2.id_jugador = j2.id_jugador inner join equipos e2 on j2.id_equipo = e2.id_equipo
    WHERE jep.id_partido = cId_Partido AND j.id_equipo = cId_Equipo_Local AND j2.id_equipo = cId_Equipo_Visitante
    AND e.id_equipo = cId_Equipo_Local AND e2.id_equipo = cId_Equipo_Visitante
    group by cId_Partido, e.nombre_equipo, e2.nombre_equipo;

  end loop listar;
  CLOSE cListarResultados;
  END;
 $$ 

 call pListarResultados();

 drop procedure pListarResultados;

/*3) Generar un stored procedure que agregue el resultado del partido en la tabla partidos*/