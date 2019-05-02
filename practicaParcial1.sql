create database practica_parcial1_bd2;

use practica_parcial1_bd2;

create table clientes(
    id_cliente int auto_increment,
    razon_social varchar(75),
    cuit int,
    CONSTRAINT pk_id_cliente PRIMARY KEY(id_cliente),
    CONSTRAINT unique_razon_social UNIQUE(razon_social)
);

create table liquidaciones(
    id_liquidacion int auto_increment,
    id_cliente int,
    fecha date,
    cantidad_facturas int,
    total float,
    CONSTRAINT pk_id_liquidacion PRIMARY KEY(id_liquidacion),
    CONSTRAINT fk_id_cliente_liq FOREIGN KEY(id_cliente) REFERENCES clientes(id_cliente)
);

create table facturas(
    id_factura int auto_increment, 
    numero varchar(50),
    fecha date ,
    tipo char(1),
    id_cliente int,
    id_liquidacion int DEFAULT,
    CONSTRAINT pk_id_factura PRIMARY KEY(id_factura),
    CONSTRAINT fk_id_cliente_factura FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
    CONSTRAINT fk_id_liquidacion_factura FOREIGN KEY (id_liquidacion) REFERENCES liquidaciones (id_liquidacion)
);

create table productos (
    id_producto int auto_increment,
    descripcion varchar(50),
    stock int,
    stock_minimo int,
    CONSTRAINT pk_id_producto PRIMARY KEY (id_producto)
);

create table items(

  id_item int auto_increment,
  cantidad int,
  precio_total float,
  id_factura int,
  id_producto int,
  CONSTRAINT pk_id_item PRIMARY KEY(id_item),
  CONSTRAINT fk_id_factura_item FOREIGN KEY(id_factura) REFERENCES facturas(id_factura),
  CONSTRAINT fk_id_producto_item FOREIGN KEY(id_producto) REFERENCES productos(id_producto)

);

create table alertas (
    id_alerta int auto_increment,
    descripcion text,
    fecha date,
    CONSTRAINT pk_id_alerta PRIMARY KEY (id_alerta)
);

/*1)Crear un Stored Procedure que dado un cliente, se genere una liquidación con todas las facturas 
no liquidadas para el mismo.​​Una factura no está liquidada cuando no tiene un id_liquidacion asociado.
Tener en cuenta que se pueden insertar nuevas facturas mientras se está generando una liquidación.
Escriba también las instrucciones necesarias para garantizarla atomicidad de la operación. ​(3 puntos) */

DELIMITER $$ 

CREATE PROCEDURE pGenerarLiquidacion (IN pId_Cliente int)
BEGIN
DECLARE vFinished int default 0;
DECLARE vCantidadFacturas int;
DECLARE vPrecio_Total float default 0;
DECLARE vId_Factura int;
DECLARE vId_liquidacion int;
DECLARE cFacturas CURSOR FOR SELECT id_factura FROM facturas where f.id_cliente = pId_Cliente AND f.id_liquidacion = null;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;

SELECT count(*) from facturas f where f.id_cliente = pId_Cliente AND f.id_liquidacion = null into vCantidadFacturas;
SELECT sum(i.precio_total) FROM items i inner join facturas f on i.id_factura = f.id_factura WHERE f.id_cliente = pId_Cliente into vPrecio_Total;

INSERT INTO liquidaciones (id_cliente, fecha, cantidad_facturas, total) values (pId_Cliente, now(), vCantidadFacturas, vPrecio_Total);
SELECT LAST_INSERT_ID() into vId_liquidacion;

OPEN cFacturas;

listar: loop
  FETCH cFacturas into vId_Factura;
  if vFinished = 1 THEN
  LEAVE listar;
  END IF;
  
  --SET vPrecio_Total = vPrecio_Total + (SELECT i.precio_total from items i where i.id_factura = vId_Factura); // creo que esto no va

  UPDATE facturas SET id_liquidacion = vId_liquidacion;
  WHERE id_factura = vId_Factura;

end loop listar;
CLOSE cFacturas;
END;
$$

call pGenerarLiquidacion (1);


-- cursor para recorrer las facturas y sumar el total ????

-- hay que hacer update de facturas

-- que pasa si el cliente no tiene facturas ??? 

-- hacer lo de atomicidad // tiene q ver con los aislamientos ?

-- ingresar datos a la bd para probar 