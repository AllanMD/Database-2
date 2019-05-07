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
    id_liquidacion int DEFAULT null,
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

INSERT INTO clientes (razon_social, cuit) values ("Allan", 12345), ("Federico rompe huevos",000);

INSERT INTO facturas (numero, fecha, tipo, id_cliente) VALUES (1, now(), "A", 1), (2, now(), "B", 2), (3, now(), "C", 1);

INSERT INTO productos (descripcion, stock, stock_minimo) VALUES ("Manzana", 1000, 50), ("Pera", 2500, 10);

INSERT INTO items(cantidad, precio_total, id_factura, id_producto) values (10, 500, 1, 1 ), (20, 200, 3, 2);


/*1)Crear un Stored Procedure que dado un cliente, se genere una liquidación con todas las facturas 
no liquidadas para el mismo.​​Una factura no está liquidada cuando no tiene un id_liquidacion asociado.
Tener en cuenta que se pueden insertar nuevas facturas mientras se está generando una liquidación.
Escriba también las instrucciones necesarias para garantizarla atomicidad de la operación. ​(3 puntos) */

DELIMITER $$ 

CREATE PROCEDURE pGenerarLiquidacion (IN pId_Cliente int)
BEGIN
DECLARE vFinished int default 0;
DECLARE vCantidadFacturas int default 0;
DECLARE vPrecio_Total float default 0;
DECLARE vId_Factura int;
DECLARE vId_liquidacion int;
DECLARE cFacturas CURSOR FOR SELECT f.id_factura FROM facturas f where f.id_cliente = pId_Cliente AND f.id_liquidacion is null;
-- hace la consulta y almacena los resultados en el cursor, esto sirve por si ingresan nuevas facturas mientras
DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;

--SELECT count(*) from facturas f where f.id_cliente = pId_Cliente AND f.id_liquidacion is null into vCantidadFacturas;
--SELECT sum(i.precio_total) FROM items i inner join facturas f on i.id_factura = f.id_factura WHERE f.id_cliente = pId_Cliente into vPrecio_Total;
IF (SELECT f.id_factura FROM facturas f where f.id_cliente = pId_Cliente AND f.id_liquidacion is null limit 1) THEN 
-- para no generar liquidacion si un cliente no tiene facturas
INSERT INTO liquidaciones (id_cliente, fecha, cantidad_facturas, total) values (pId_Cliente, now(), vCantidadFacturas, vPrecio_Total);
SELECT LAST_INSERT_ID() into vId_liquidacion;

OPEN cFacturas;

listar: loop
  FETCH cFacturas into vId_Factura;
  if vFinished = 1 THEN
  LEAVE listar;
  END IF;
  
  SET vCantidadFacturas = vCantidadFacturas + 1;
  SET vPrecio_Total = vPrecio_Total + (SELECT i.precio_total from items i where i.id_factura = vId_Factura);

  UPDATE facturas SET id_liquidacion = vId_liquidacion
  WHERE id_factura = vId_Factura;

end loop listar;
CLOSE cFacturas;

UPDATE liquidaciones SET cantidad_facturas = vCantidadFacturas, total = vPrecio_Total WHERE id_liquidacion = vId_liquidacion;
END IF;
END;
$$

call pGenerarLiquidacion (1);


-- que pasa si el cliente no tiene facturas ??? 

-- hacer lo de atomicidad // tiene q ver con los aislamientos ? no. es lo de start transaction y commit;

/*2) Crear los triggers necesarios para garantizar las siguientes operaciones :*/

/*Restar el stock de los productos cuando se ingresa un item.*/
DELIMITER $$
CREATE TRIGGER TIB_RESTAR_STOCK_PRODUCTOS AFTER INSERT ON items FOR EACH ROW
BEGIN 

UPDATE productos SET stock = stock - new.cantidad WHERE id_producto = new.id_producto;

END
$$

insert into items (cantidad, precio_total, id_factura, id_producto) values (100, 2000, 1, 1);

/*No insertar un item si no hay stock del producto seleccionado, además generar un error para identificar el problema.*/
DELIMITER $$
CREATE TRIGGER TIB_EVITAR_INSERT_NO_HAY_STOCK BEFORE INSERT ON items FOR EACH ROW
BEGIN

DECLARE vStock int;
SELECT stock FROM productos where id_producto = new.id_producto INTO vStock;

IF (vStock < new.cantidad) THEN 
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'NO SE PUEDE INGRESAR ITEM, NO HAY STOCK DEL PRODUCTO';
END IF;

END
$$

insert into items (cantidad, precio_total, id_factura, id_producto) values (1000, 2000, 1, 1);

/*Generar un registro en la tabla Alertas, cada vez que un producto quede con menos stock que el stock mínimo.*/
DELIMITER $$

CREATE TRIGGER TIB_GENERAR_ALERTA_STOCK_MINIMO AFTER UPDATE ON productos FOR EACH ROW
BEGIN

DECLARE vStock int;
DECLARE vStock_Minimo int;
DECLARE vId_Producto int;
SELECT new.stock INTO vStock;
SELECT new.stock_minimo INTO vStock_Minimo;
SELECT new.id_producto INTO vId_Producto;

IF (vStock < vStock_Minimo) THEN
INSERT INTO alertas (descripcion, fecha) values (CONCAT("El producto con id ", vId_Producto, "tiene stock por debajo del minimo"), now());
END IF;

END;
$$

insert into items (cantidad, precio_total, id_factura, id_producto) values (90, 2000, 1, 1);

insert into items (cantidad, precio_total, id_factura, id_producto) values (100, 200, 2, 2);


/*3) Crear una vista que liste el total liquidado para cada cliente. En caso de
que el cliente no tenga liquidaciones asociadas, se debe mostrar 0.*/

CREATE VIEW listar_total_liquidado AS SELECT c.razon_social, IFNULL(sum(l.total),0) as total_liquidado FROM clientes c LEFT OUTER JOIN
liquidaciones l ON c.id_cliente = l.id_cliente GROUP BY c.razon_social; 

SELECT * FROM listar_total_liquidado;

INSERT INTO liquidaciones (id_cliente, fecha, cantidad_facturas, total) values (1, now(), 1, 200); -- para probar que funciona