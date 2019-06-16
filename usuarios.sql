CREATE USER "allan"@"localhost" IDENTIFIED BY "1234"
-- acceder a la consola del sistema o al "shell" en xampp para poder loguear como un usuario

mysql -u allan -p --- para acceder con el usuario allan
exit; --- para cerrar sesion

GRANT ALL PRIVILEGES ON *.* TO "allan"@"%" -- concede todos los permisos, en todas las base de datos, en todas sus tablas al usuario allan en todos los host

GRANT ALL PRIVILEGES ON *.* TO "allan"@"localhost" identified by "1234" WITH GRANT OPTION; -- concede permisos para localhost

CREATe USER "prueba"@"localhost";

SHOW GRANTS FOR CURRENT_USER();

GRANT SELECT ON guia6_indices.jugadores TO "prueba"@"localhost";

REVOKE ALL PRIVILEGES on *.* FROM 'prueba'@'localhost';
REVOKE ALL PRIVILEGES FROM prueba;

grant alter on guia6_indices.equipos TO "prueba"@"localhost";