create user "usuario"@"localhost" identified by "123";
create user "usuario1"@"localhost" identified by "456";
create user "usuario2"@"localhost" identified by "789";

-- Permisos otorgados

-- Usuario con todos los privilegios sobre la BD

grant all privileges on *.* to "usuario"@"localhost";

-- Usuario1 con todos los privilegios sobre la tabla Información

grant all on riesgo_global1.informacion to "usuario1"@"localhost";

-- Usuario2 con privilegio de Select sobre toda la BD

grant select on *.* to "usuario2"@"localhost"; 
