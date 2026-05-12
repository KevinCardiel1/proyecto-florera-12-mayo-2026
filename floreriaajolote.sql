-- Script de creación de base de datos: Florería Ajolote
-- Generado basándose en el diagrama y diccionario de datos proporcionados.

CREATE DATABASE IF NOT EXISTS bdfloreriaajolote;
USE bdfloreriaajolote;

-- 1. CATEGORIA (Independiente)
CREATE TABLE CATEGORIA (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB; --

-- 2. PRODUCTO (Depende de CATEGORIA)
CREATE TABLE PRODUCTO (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    id_categoria INT NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    tipo ENUM('Flor', 'Arreglo', 'Planta', 'Accesorio') NOT NULL, -- Ejemplos de tipos
    precio_venta DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    descripcion TEXT,
    imagen_url VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
) ENGINE=InnoDB; --

-- 3. PROVEEDOR (Independiente)
CREATE TABLE PROVEEDOR (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(120) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(200),
    tiempo_entrega_dias INT
) ENGINE=InnoDB; --

-- 4. LOTE (Depende de PRODUCTO y PROVEEDOR)
CREATE TABLE LOTE (
    id_lote INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_vencimiento DATE,
    costo_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_lote_producto FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto),
    CONSTRAINT fk_lote_proveedor FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id_proveedor)
) ENGINE=InnoDB; --

-- 5. CLIENTE (Independiente)
CREATE TABLE CLIENTE (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(200),
    fecha_registro DATE NOT NULL,
    notas TEXT
) ENGINE=InnoDB; --

-- 6. PEDIDO (Depende de CLIENTE)
CREATE TABLE PEDIDO (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    fecha_pedido DATETIME NOT NULL,
    fecha_entrega DATE,
    estado ENUM('Pendiente', 'Pagado', 'Enviado', 'Entregado', 'Cancelado') NOT NULL,
    tipo ENUM('Local', 'Domicilio', 'Evento') NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    notas TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
) ENGINE=InnoDB; --

-- 7. DETALLE_PEDIDO (Depende de PEDIDO y PRODUCTO)
CREATE TABLE DETALLE_PEDIDO (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    personalizacion TEXT,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido),
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
) ENGINE=InnoDB; --

-- 8. PAGO (Depende de PEDIDO)
CREATE TABLE PAGO (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    metodo ENUM('Efectivo', 'Tarjeta', 'Transferencia') NOT NULL,
    fecha DATETIME NOT NULL,
    referencia VARCHAR(100),
    CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido)
) ENGINE=InnoDB; --

-- 9. EMPLEADO (Independiente)
CREATE TABLE EMPLEADO (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    rol ENUM('Admin', 'Florista', 'Repartidor', 'Ventas') NOT NULL,
    telefono VARCHAR(20),
    turno ENUM('Matutino', 'Vespertino', 'Completo'),
    fecha_contrato DATE
) ENGINE=InnoDB; --

-- 10. ENVIO (Depende de PEDIDO y EMPLEADO)
CREATE TABLE ENVIO (
    id_envio INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_empleado INT, -- Puede ser nulo si aún no se asigna repartidor
    direccion_destino VARCHAR(200) NOT NULL,
    fecha_programada DATETIME NOT NULL,
    hora_entrega TIME,
    estado ENUM('Programado', 'En Camino', 'Entregado', 'Fallido') NOT NULL,
    costo DECIMAL(8,2),
    CONSTRAINT fk_envio_pedido FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido),
    CONSTRAINT fk_envio_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
) ENGINE=InnoDB; --

-- 11. EVENTO (Depende de CLIENTE)
CREATE TABLE EVENTO (
    id_evento INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    nombre_evento VARCHAR(120) NOT NULL,
    tipo ENUM('Boda', 'XV Años', 'Graduación', 'Corporativo', 'Otro') NOT NULL,
    fecha DATE NOT NULL,
    presupuesto DECIMAL(12,2),
    descripcion TEXT,
    CONSTRAINT fk_evento_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
) ENGINE=InnoDB; --

-- 12. OCASION (Depende de CLIENTE)
CREATE TABLE OCASION (
    id_ocasion INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    descripcion VARCHAR(120) NOT NULL,
    fecha DATE NOT NULL,
    recordatorio_dias INT,
    CONSTRAINT fk_ocasion_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
) ENGINE=InnoDB; --
