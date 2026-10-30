-- ============================================================
-- BASE DE DATOS: GOLDEN THREAD
--
-- ============================================================

DROP DATABASE IF EXISTS goldenthread;
CREATE DATABASE goldenthread CHARACTER SET utf8mb4;
USE goldenthread;

-- ============================================================
-- USUARIO
-- Esta tabla almacena todos los datos comunes de Cliente, Administrador y Vendedor.
-- ============================================================

CREATE TABLE USUARIO (
    id_user        BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(30) NOT NULL,
    apellido       VARCHAR(30) NOT NULL,
    email          VARCHAR(255) NOT NULL UNIQUE,
    password       VARCHAR(255) NOT NULL,
    telefono       VARCHAR(15),
    estado_usuario BOOLEAN NOT NULL DEFAULT TRUE,
    rol            VARCHAR(30) NOT NULL
);


-- ============================================================
-- 2. CLIENTE
--
-- ============================================================

CREATE TABLE CLIENTE (
    id_cliente BIGINT PRIMARY KEY,

    direccion1 VARCHAR(255) NOT NULL,
    direccion2 VARCHAR(255),
    cp         VARCHAR(10) NOT NULL,
    pais       VARCHAR(50) NOT NULL,
    ciudad     VARCHAR(50) NOT NULL,
    provincia  VARCHAR(50) NOT NULL,

    puntos   INT DEFAULT 0,
    monedero DECIMAL(10,2) DEFAULT 0.00,

    CONSTRAINT fk_cliente_usuario
        FOREIGN KEY (id_cliente)
        REFERENCES USUARIO(id_user)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Se encarga de impedir que los puntos puedan llegar a ser negativos.
    CONSTRAINT chk_cliente_puntos
        CHECK (puntos >= 0),

    -- Se encarga de impedir que el saldo del monedero puedan llegar a ser negativos.
    CONSTRAINT chk_cliente_monedero
        CHECK (monedero >= 0)
);


-- ============================================================
-- 3. ADMINISTRADOR
-- 
-- ============================================================

CREATE TABLE ADMINISTRADOR (
    id_admin BIGINT PRIMARY KEY,

    CONSTRAINT fk_admin_usuario
        FOREIGN KEY (id_admin)
        REFERENCES USUARIO(id_user)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ============================================================
-- 4. EMPRESA
--
-- ============================================================

CREATE TABLE EMPRESA (
    id_empresa        BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa    VARCHAR(100) NOT NULL,
    cif               VARCHAR(20) NOT NULL UNIQUE,
    email_contacto    VARCHAR(255) NOT NULL,
    telefono_contacto VARCHAR(15),
    direccion_sede    VARCHAR(255) NOT NULL,
    logo_empresa      VARCHAR(255)
);


-- ============================================================
-- 5. VENDEDOR
-- Todos los Vendedores perteneceran a una Empresa EXISTENTE.
-- ============================================================

CREATE TABLE VENDEDOR (
    id_vendedor      BIGINT PRIMARY KEY,
    id_empresa       BIGINT NOT NULL,
    numero_empleado  VARCHAR(20) NOT NULL,

    CONSTRAINT fk_vendedor_usuario
        FOREIGN KEY (id_vendedor)
        REFERENCES USUARIO(id_user)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_vendedor_empresa
        FOREIGN KEY (id_empresa)
        REFERENCES EMPRESA(id_empresa)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_vendedor_empresa_numero
        UNIQUE (id_empresa, numero_empleado)
);


-- ============================================================
-- 6. MARCA
--
-- ============================================================

CREATE TABLE MARCA (
    id_marca BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(30) NOT NULL
);


-- ============================================================
-- 7. TALLA
--
-- ============================================================

CREATE TABLE TALLA (
    id_talla BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(30) NOT NULL
);


-- ============================================================
-- 8. COLOR
--
-- ============================================================

CREATE TABLE COLOR (
    id_color BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(30) NOT NULL
);


-- ============================================================
-- 9. GENERO
--
-- ============================================================

CREATE TABLE GENERO (
    id_genero BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(30) NOT NULL
);


-- ============================================================
-- 10. PRODUCTO
-- Cada producto pertenece a una Empresa y una Marca.
-- ============================================================

CREATE TABLE PRODUCTO (
    id_producto BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_empresa  BIGINT NOT NULL,
    id_marca    BIGINT NOT NULL,
    nombre      VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio      DECIMAL(10,2) NOT NULL,
    url_imagen  VARCHAR(255),

    CONSTRAINT fk_producto_empresa
        FOREIGN KEY (id_empresa)
        REFERENCES EMPRESA(id_empresa)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_producto_marca
        FOREIGN KEY (id_marca)
        REFERENCES MARCA(id_marca)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Evitara que el precio del producto sea inferior a 0.
    CONSTRAINT chk_producto_precio
        CHECK (precio >= 0)
);


-- ============================================================
-- 11. PRODUCTO_GENERO
-- Esta tabla es la encargada de resolver la relación N:M entre PRODUCTO y GENERO.
-- ============================================================

CREATE TABLE PRODUCTO_GENERO (
    id_producto BIGINT NOT NULL,
    id_genero   BIGINT NOT NULL,

    PRIMARY KEY (id_producto, id_genero),

    CONSTRAINT fk_producto_genero_producto
        FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_producto_genero_genero
        FOREIGN KEY (id_genero)
        REFERENCES GENERO(id_genero)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ============================================================
-- 12. DETALLE_PRODUCTO
-- Representa una variante concreta: producto + talla + color.
-- El stock se controla para cada variante.
-- ============================================================

CREATE TABLE DETALLE_PRODUCTO (
    id_detalle_producto BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto         BIGINT NOT NULL,
    id_talla            BIGINT NOT NULL,
    id_color            BIGINT NOT NULL,
    stock               INT NOT NULL,

    CONSTRAINT fk_detalle_producto_producto
        FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_detalle_producto_talla
        FOREIGN KEY (id_talla)
        REFERENCES TALLA(id_talla)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_detalle_producto_color
        FOREIGN KEY (id_color)
        REFERENCES COLOR(id_color)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Evitamos el posible error de Stock negativo.
    CONSTRAINT chk_detalle_producto_stock
        CHECK (stock >= 0),

    CONSTRAINT uq_producto_talla_color
        UNIQUE (id_producto, id_talla, id_color)
);


-- ============================================================
-- 13. PEDIDO
-- Esta tabla conserva los datos de envío utilizados en la compra.
-- ============================================================

CREATE TABLE PEDIDO (
    id_pedido BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cliente BIGINT NOT NULL,
    fecha_pedido DATETIME NOT NULL,
    estado_pedido VARCHAR(20) NOT NULL,
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    -- Datos de envío pertenecientes a la Tabla Cliente.
    direccion_cliente VARCHAR(255) NOT NULL,
    cp_cliente        VARCHAR(10) NOT NULL,
    ciudad_cliente    VARCHAR(50) NOT NULL,
    provincia_cliente VARCHAR(50) NOT NULL,
    pais_cliente      VARCHAR(50) NOT NULL,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_pedido_cliente
        UNIQUE (id_pedido, id_cliente),

    -- Evitamos que el coste total del pedido sea inferior a 0.
    CONSTRAINT chk_pedido_total
        CHECK (total >= 0)
);


-- ============================================================
-- 14. DETALLE_PEDIDO
-- Esta tabla guarda los productos comprados y sus precios históricos.
-- ============================================================

CREATE TABLE DETALLE_PEDIDO (
    id_detalle_pedido   BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pedido           BIGINT NOT NULL,
    id_detalle_producto BIGINT NOT NULL,
    cantidad            INT NOT NULL,
    precio_unidad       DECIMAL(10,2) NOT NULL,
    subtotal            DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_detalle_pedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_detalle_pedido_detalle_producto
        FOREIGN KEY (id_detalle_producto)
        REFERENCES DETALLE_PRODUCTO(id_detalle_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- No se permitiran cantidades inferiores o iguales a 0.
    CONSTRAINT chk_detalle_pedido_cantidad
        CHECK (cantidad > 0),

    -- Se validan los importes.
    CONSTRAINT chk_detalle_pedido_precio
        CHECK (precio_unidad >= 0),

    CONSTRAINT chk_detalle_pedido_subtotal
        CHECK (subtotal >= 0)
);


-- ============================================================
-- 15. DEVOLUCION
-- Registra la solicitud y su estado de tramitación.
-- ============================================================

CREATE TABLE DEVOLUCION (
    id_devolucion BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pedido     BIGINT NOT NULL,
    id_cliente    BIGINT NOT NULL,

    -- Sera de valor nulo hasta que un vendedor vea la solicitud.
    id_vendedor BIGINT,

    fecha_devolucion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- El estado inicial siempre sera SOLICITADA
    estado_devolucion VARCHAR(20) NOT NULL DEFAULT 'SOLICITADA',

    motivo           TEXT NOT NULL,
    total_a_devolver DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_devolucion_pedido_cliente
        FOREIGN KEY (id_pedido, id_cliente)
        REFERENCES PEDIDO(id_pedido, id_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_devolucion_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES VENDEDOR(id_vendedor)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    -- Se limitan los estados de la devolución a 4.
    CONSTRAINT chk_devolucion_estado
        CHECK (
            estado_devolucion IN (
                'SOLICITADA',
                'RECHAZADA',
                'ACEPTADA',
                'COMPLETADA'
            )
        ),

    CONSTRAINT chk_devolucion_total
        CHECK (total_a_devolver >= 0)
);


-- ============================================================
-- 16. DETALLE_DEVOLUCION
-- Indica qué líneas del pedido se devuelven y en qué cantidad.
-- ============================================================

CREATE TABLE DETALLE_DEVOLUCION (
    id_detalle_devolucion BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_devolucion         BIGINT NOT NULL,
    id_detalle_pedido     BIGINT NOT NULL,
    cantidad              INT NOT NULL,
    precio_unidad         DECIMAL(10,2) NOT NULL,
    subtotal              DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_detalle_devolucion_devolucion
        FOREIGN KEY (id_devolucion)
        REFERENCES DEVOLUCION(id_devolucion)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_detalle_devolucion_detalle_pedido
        FOREIGN KEY (id_detalle_pedido)
        REFERENCES DETALLE_PEDIDO(id_detalle_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- La cantidad a devolver debe de ser superior a 0.
    CONSTRAINT chk_detalle_devolucion_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT chk_detalle_devolucion_precio
        CHECK (precio_unidad >= 0),

    CONSTRAINT chk_detalle_devolucion_subtotal
        CHECK (subtotal >= 0)
);