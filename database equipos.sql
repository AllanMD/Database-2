drop database equipos;
create database equipos;
use equipos;

create table partido (
	id int auto_increment,
    id_equipo_local int not null,
    id_equipo_visita int not null,
    fecha datetime,
    
    constraint pk_partido primary key (id)
);

create table equipo (
	id int auto_increment,
    nombre_equipo varchar(50) not null,
    
    constraint pk_equipo primary key (id)
);

create table jugador (
	id int auto_increment,
    id_equipo int not null,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    
    constraint pk_jugador primary key (id)
);

create table jugadores_x_partido (
    id_jugador int not null,
    id_partido int not null,
    puntos int,
    rebotes int,
    asistencias int,
    minutos int,
    faltas int,
    
    constraint pk_jugador primary key (id_jugador, id_partido)
);

alter table jugador add constraint fk_jugador_equipo foreign key (id_equipo) references equipo(id);
alter table partido add constraint fk_partido_equipo_local foreign key (id_equipo_local) references equipo(id);
alter table partido add constraint fk_partido_equipo_visita foreign key (id_equipo_visita) references equipo(id);
alter table jugadores_x_partido add constraint fk_jugadores_x_partido_jugador foreign key (id_jugador) references jugador(id);
alter table jugadores_x_partido add constraint fk_jugadores_x_partido_partido foreign key (id_partido) references partido(id);

insert into equipo (nombre_equipo) values ('Club Agropecuario Argentino'),
('Club Almagro'),('Arsenal Fútbol Club'),('Asociación M. S. y D. Atlético de Rafaela'),
('Club Atlético Brown'),('Club Atlético Central Córdoba'),('Club Atlético Chacarita Juniors'),
('Club Atlético Defensores de Belgrano'),('Club Deportivo Morón'),('Club Ferro Carril Oeste'),
('Club Atlético Gimnasia y Esgrima'),('Club Atlético Gimnasia y Esgrima'),('Club Social y Atlético Guillermo Brown'),
('Club Sportivo Independiente Rivadavia'),('Instituto Atlético Central Córdoba'),
('Club Atlético Mitre'),('Club Atlético Nueva Chicago'),('Club Olimpo'),('Club Atlético Platense'),
('Quilmes Atlético Club'),('Club y Biblioteca Ramón Santamarina'),('Club Atlético Los Andes'),
('Club Atlético Sarmiento'),('Club Atlético Temperley'),('Club Villa Dálmine');

insert into jugador (nombre,apellido,id_equipo) values 
("Giancarlos","Cortés","1"),("Geovanny","López","1"),("Donovan","Orellana","1"),("Maicol","Vidal","1"),
("Arthur","Bravo","2"),("Arturo","Fernández","2"),("George","Rivera","2"),("Axcel","Lagos","2"),
("Ayron","Díaz","3"),("Thiago","Yáñez","3"),("Ademir","Herrera","3"),("Renato","Gómez","3"),
("Lian","Soto","4"),("Álvaro","Riquelme","4"),("Joshua","Aguilera","4"),("Fabiano","Salazar","4"),
("Dastyn","Maldonado","5"),("Maikel","Peña","5"),("Lucas","Saavedra","5"),("Yordan","Guerrero","5"),
("André","Cárdenas","6"),("Noel","Venegas","6"),("Anton","San Martín","6"),("Román","Paredes","6"),
("Samuel","Olivares","7"),("Borja","Sáez","7"),("Farid","Espinoza","7"),("Byron","Rojas","7"),
("Dayron","Alvarado","8"),("Cristopher","Palma","8"),("Guillermo","Reyes","8"),("Jhon","Ortega","8"),
("Adolfo","Sanhueza","9"),("Eidan","Cáceres","9"),("Jesus","Vásquez","9"),("Jhans","Torres","9"),
("Simón","Navarro","10"),("Dámian","Flores","10"),("Raúl","Sánchez","10"),("Giovani","Medina","10"),
("Rodolfo","Parra","11"),("Omar","Sánchez","11"),("Gamaliel","Aguilera","11"),("Lenin","Molina","11"),
("Nicanor","López","12"),("Andres","Reyes","12"),("Fabián","Vargas","12"),("Elio","Cáceres","12"),
("Yeferson","Poblete","13"),("Frank","Peña","13"),("Noel","Vergara","13"),("Yhan","Pino","13"),
("Hector","Sanhueza","14"),("Akiles","Carvajal","14"),("Mariano","Farías","14"),("Jhostin","Cáceres","14"),
("Adriano","Silva","15"),("Augusto","Leiva","15"),("Luka","Figueroa","15"),("Joaquín","Peña","15"),
("Estefano","Tapia","16"),("Doménico","Álvarez","16"),("Nathaniel","López","16"),("Amaru","Sandoval","16"),
("Favio","Maldonado","17"),("Dilan","Morales","17"),("Domingo","Sandoval","17"),("Amaro","Moreno","17"),
("Philip","Pizarro","18"),("Kenneth","Ramírez","18"),("Benjamin","Soto","18"),("Sebastian","Gallardo","18"),
("Giordano","Escobar","19"),("Franco","Alvarado","19"),("Alfonso","Godoy","19"),("Geovanny","Zúñiga","19"),
("Heydan","Peña","20"),("Jim","Rivera","20"),("Edison","Sanhueza","20"),("Mijael","Vásquez","20"),
("Yojan","Ortiz","21"),("Ivo","Figueroa","21"),("Dylann","Zúñiga","21"),("David","Carrasco","21"),
("Alen","Flores","22"),("Matthias","Navarro","22"),("Victor","Ortega","22"),("Efraín","Sepúlveda","22"),
("Billy","Castillo","23"),("Ian","Salazar","23"),("Deivi","Cárdenas","23"),("Nikolas","Rivera","23"),
("Agustin","Toro","24"),("Eliam","Muñoz","24"),("Elmer","Pérez","24"),("Marck","Silva","24"),
("Bryam","Jiménez","25"),("Domingo","Alvarado","25"),("Alen","Ortiz","25"),("Otoniel","Escobar","25");