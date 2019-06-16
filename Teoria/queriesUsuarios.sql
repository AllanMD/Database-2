Capítulo 7 del Manual de referencia de MySQL trata todos estos temas
https://dev.mysql.com/doc/refman/5.7/en/security.html

/*
 *	Estas son las diferentes tablas dentro de la base de datos
 *	mysql donde el motor almacena los permisos.
 **/
• user: User accounts, global privileges, and other non-privilege columns
• db: Database-level privileges
• tables_priv: Table-level privileges
• columns_priv: Column-level privileges
• procs_priv: Stored procedure and function privileges
• proxies_priv: Proxy-user privileges

/**
 * Estos son los diferentes tipos de privilegios que
 * pueden otorgarse y revocarse a los usuarios
 **/
Privilege Type                         Description                                                         
ALL                                    Grants all privileges, except WITH GRANT OPTION                      
ALTER                                  Grants use of ALTER TABLE 
CREATE                                 Grants use of CREATE TABLE  
CREATE TEMPORARY TABLES                Grants use of CREATE TEMPORARY TABLE
DELETE                                 Grants use of DELETE 
DROP                                   Grants use of DROP TABLE 
EXECUTE                                Grants use of stored procedures
FILE                                   Grants use of SELECT INTO OUTFILE and LOAD DATA INFILE 
GRANT OPTION                           Used to revoke WITH GRANT OPTION 
INDEX                                  Grants use of CREATE INDEX and DROP INDEX 
INSERT                                 Grants use of INSERT 
LOCK TABLES                            Grants use of LOCK TABLES on tables on which the user already has the SELECT privilege
PROCESS                                Grants use of SHOW FULL PROCESSLIST 
RELOAD                                 Grants use of FLUSH 
REPLICATION CLIENT                     Grants ability to ask where the slaves/masters are
REPLICATION SLAVE                      Grants ability of the replication slaves to read information from master
SELECT                                 Grants use of SELECT 
SHOW DATABASES                         Grants use of SHOW DATABASES 
SHUTDOWN                               Grants use of MYSQLADMIN SHUTDOWN 
SUPER                                  Grants the user one connection, one time, 
                                       even if the server is at maximum connections limit, 
                                       and grants use of CHANGE MASTER, KILL THREAD, MYSQLADMIN DEBUG, 
                                       PURGE MASTER LOGS, and SET GLOBAL 
UPDATE                                 Grants use of UPDATE 
USAGE                                  Grants access to log in to the MySQL Server but bestows no privileges 
WITH GRANT OPTION                      Grants ability for users to grant any privilege they possess to another user 

-- Ingresan a MySQL con usuario root
mysql -u root -p

-- Crean una base de datos nueva
create database clase_usuarios;

-- Crean un usuario nuevo
-- (en el link de abajo tienen información (usando root como ejemplo)
-- de por qué es necesario crear el mismo usuario para diferentes 
-- "versiones" de localhost).
-- https://dba.stackexchange.com/questions/59412/multiple-root-users-in-mysql
create user 'adminclaseusuarios'@'localhost' identified by 'adminclaseusuarios';

-- Le dan todos los permisos posibles, se transforma
-- en su ADMIN para esta base de datos.
GRANT ALL PRIVILEGES ON clase_usuarios.* TO 'ssssss'@'localhost' WITH GRANT OPTION;

-- Cierren la conexión actual e ingresen a MySQL con el nuevo usuario creado
mysql -u adminclaseusuarios -p

-- Verifiquen que solo tienen acceso a dos bases de datos.
SHOW databases;

-- Verifiquen los permisos que tiene su usuario actual
SHOW GRANTS FOR CURRENT_USER();

-- Creamos tablas. Con este usuario no deberían tener problemas.
-- Se van a utilizar en la guía luego.
CREATE TABLE `productos` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `descripcion` varchar(50) NOT NULL,
 `monto` decimal(10,4) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `clientes` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `razon_social` varchar(50) NOT NULL,
 `cuit` varchar(30) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `sucursales` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `nombre` varchar(50) NOT NULL,
 `domicilio` varchar(50) NOT NULL,
 `host` varchar(50) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `empleados` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `nombre` varchar(50) NOT NULL,
 `sucursal_id` int(10) unsigned NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `facturas` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `sucursal_id` int(10) unsigned NOT NULL,
 `empleado_id` int(10) unsigned NOT NULL,
 `cliente_id` int(10) unsigned NOT NULL,
 `fecha` datetime NOT NULL,
 `monto` decimal(10,4) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `stock` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `sucursal_id` int(10) unsigned NOT NULL,
 `producto_id` int(10) unsigned NOT NULL,
 `cantidad` int(11) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `item_factura` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `producto_id` int(10) unsigned NOT NULL,
 `factura_id` int(10) unsigned NOT NULL,
 `cantidad` int(11) NOT NULL,
 `monto` decimal(10,4) NOT NULL,
 PRIMARY KEY (`id`)
);

-- Creamos un nuevo usuario. ¿Funciona? Si no funciona soluciónelo.
CREATE USER 'pruebasclaseusuarios'@'localhost';

-- Ahora le asignamos contraseña. No olvidarse de utilizar
-- la función PASSWORD para encriptarla.
SET PASSWORD FOR 'pruebasclaseusuarios'@'localhost' = PASSWORD('pruebasclaseusuarios');

-- Desde otra terminal ingresen con este nuevo usuario
-- y vayan probando los permisos a medida que los vayamos asignando.
-- ¿En que momento tienen efecto?
mysql -u pruebasclaseusuarios -p

-- A PARTIR DE AHORA, CUANDO HAYA un [1] delante de un comando significa
-- que se ejecuta desde la ventana del usuario adminclaseusuarios y cuando
-- haya un [2] se ejecuta desde la ventana del usuario pruebaclaseusuarios.

-- [2] Verificamos BD a las que tenemos acceso
SHOW databases;

-- [1] Asignamos permisos de lectura en toda la DB
GRANT SELECT on clase_usuarios.* to 'pruebasclaseusuarios'@'localhost';

-- [2] Verificamos BD a las que tenemos acceso
SHOW databases;

-- [2] Probamos insertar tres filas nuevas, ¿qué error aparece?
INSERT INTO productos VALUES ('Pepsi'), ('Coca Cola'), ('Manaos');

-- [1] Asignamos permisos de escritura en la tabla productos
GRANT INSERT on clase_usuarios.productos to 'pruebasclaseusuarios'@'localhost';

-- [2] Probamos insertar tres filas nuevas, ¿ahora funciona?
INSERT INTO productos VALUES ('Pepsi'), ('Coca Cola'), ('Manaos');

-- [1] Le permitimos al usuario insertar solo la razon_social de los clientes. 
-- ¿Se puede? ¿Tiene sentido? ¿En que casos sería útil si se pudiese?
GRANT INSERT(razon_social) on clase_usuarios.clientes to 'pruebasclaseusuarios'@'localhost';

-- [1] Revocamos permisos generales de lectura
REVOKE SELECT on clase_usuarios.* to 'pruebasclaseusuarios'@'localhost';

-- [1] Asignamos permisos mezclados
GRANT SELECT(nombre, sucursal_id), INSERT(nombre) on clase_usuarios.empleados to 'pruebasclaseusuarios'@'localhost';