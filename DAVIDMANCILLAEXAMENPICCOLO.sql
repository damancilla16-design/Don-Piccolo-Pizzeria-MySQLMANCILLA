-- =========================================================
-- ELIMINAR OBJETOS SI YA EXISTEN (para ejecutar limpio)
-- =========================================================
DROP VIEW IF EXISTS vista_resumen_inventario;
DROP TRIGGER IF EXISTS actualizar_stock_ingrediente;
DROP TABLE IF EXISTS movimientos_ingrediente;
DROP TABLE IF EXISTS ingredientes;

-- =========================================================
-- 1. TABLA ingredientes
-- =========================================================
CREATE TABLE ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    unidad_medida VARCHAR(20) NOT NULL,
    stock_actual DECIMAL(10,2) NOT NULL DEFAULT 0,
    stock_minimo DECIMAL(10,2) NOT NULL DEFAULT 0
);

-- =========================================================
-- 2. TABLA movimientos_ingrediente
-- =========================================================
CREATE TABLE movimientos_ingrediente (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_ingrediente INT NOT NULL,
    tipo ENUM('ENTRADA', 'SALIDA') NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    fecha_movimiento DATETIME DEFAULT NOW(),
    CONSTRAINT fk_movimiento_ingrediente
        FOREIGN KEY (id_ingrediente) REFERENCES ingredientes(id_ingrediente)
);

-- =========================================================
-- 3. INSERCIÓN DE DATOS DE PRUEBA: INGREDIENTES
-- =========================================================
INSERT INTO ingredientes (nombre, unidad_medida, stock_actual, stock_minimo)
VALUES ('Queso', 'kg', 10.00, 5.00);

INSERT INTO ingredientes (nombre, unidad_medida, stock_actual, stock_minimo)
VALUES ('Salsa', 'lts', 3.00, 5.00);

INSERT INTO ingredientes (nombre, unidad_medida, stock_actual, stock_minimo)
VALUES ('Harina', 'kg', 20.00, 10.00);

INSERT INTO ingredientes (nombre, unidad_medida, stock_actual, stock_minimo)
VALUES ('Aceitunas', 'kg', 2.00, 3.00);

INSERT INTO ingredientes (nombre, unidad_medida, stock_actual, stock_minimo)
VALUES ('Champiñones', 'kg', 8.00, 4.00);

-- =========================================================
-- 4. TRIGGER actualizar_stock_ingrediente
-- =========================================================
DELIMITER $$

CREATE TRIGGER actualizar_stock_ingrediente
AFTER INSERT ON movimientos_ingrediente
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'ENTRADA' THEN
        UPDATE ingredientes
        SET stock_actual = stock_actual + NEW.cantidad
        WHERE id_ingrediente = NEW.id_ingrediente;
    ELSEIF NEW.tipo = 'SALIDA' THEN
        UPDATE ingredientes
        SET stock_actual = stock_actual - NEW.cantidad
        WHERE id_ingrediente = NEW.id_ingrediente;
    END IF;
END$$

DELIMITER ;

-- =========================================================
-- 5. INSERCIÓN DE DATOS DE PRUEBA: MOVIMIENTOS
-- (cada INSERT dispara el trigger automáticamente)
-- =========================================================
INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (1, 'ENTRADA', 5.00, '2026-09-20 08:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (1, 'SALIDA', 3.00, '2026-09-20 12:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (2, 'ENTRADA', 2.00, '2026-09-21 09:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (2, 'SALIDA', 4.00, '2026-09-21 15:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (3, 'ENTRADA', 10.00, '2026-09-22 10:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (3, 'SALIDA', 5.00, '2026-09-22 18:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (4, 'SALIDA', 1.00, '2026-09-23 11:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (5, 'ENTRADA', 6.00, '2026-09-23 14:00:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (5, 'SALIDA', 3.00, '2026-09-24 09:30:00');

INSERT INTO movimientos_ingrediente (id_ingrediente, tipo, cantidad, fecha_movimiento)
VALUES (2, 'SALIDA', 1.00, '2026-09-24 17:45:00');

-- =========================================================
-- 6. VISTA vista_resumen_inventario
-- =========================================================
CREATE VIEW vista_resumen_inventario AS
SELECT
    nombre,
    stock_actual,
    stock_minimo,
    (stock_actual - stock_minimo) AS diferencia
FROM ingredientes
ORDER BY diferencia ASC;

-- =========================================================
-- 7. CONSULTA: INGREDIENTES CON BAJO STOCK
-- =========================================================
SELECT
    nombre,
    unidad_medida,
    stock_actual
FROM ingredientes
WHERE stock_actual < stock_minimo
ORDER BY stock_actual ASC;

-- =========================================================
-- 8. CONSULTA: ÚLTIMOS 5 MOVIMIENTOS
-- =========================================================
SELECT
    i.nombre,
    m.tipo,
    m.fecha_movimiento
FROM movimientos_ingrediente AS m
JOIN ingredientes AS i
    ON m.id_ingrediente = i.id_ingrediente
ORDER BY m.fecha_movimiento DESC
LIMIT 5;

-- =========================================================
-- 9. CONSULTA DE VERIFICACIÓN: TODOS LOS INGREDIENTES
-- =========================================================
SELECT
    id_ingrediente,
    nombre,
    unidad_medida,
    stock_actual,
    stock_minimo
FROM ingredientes;

-- =========================================================
-- 10. CONSULTA DE VERIFICACIÓN: EFECTO DEL TRIGGER SOBRE EL STOCK
-- =========================================================
SELECT
    i.nombre,
    i.stock_actual,
    m.tipo,
    m.cantidad,
    m.fecha_movimiento
FROM movimientos_ingrediente AS m
JOIN ingredientes AS i
    ON m.id_ingrediente = i.id_ingrediente
ORDER BY m.fecha_movimiento ASC;

-- =========================================================
-- 11. CONSULTA DE VERIFICACIÓN: BAJO STOCK
-- =========================================================
SELECT
    nombre,
    unidad_medida,
    stock_actual
FROM ingredientes
WHERE stock_actual < stock_minimo
ORDER BY stock_actual ASC;

-- =========================================================
-- 12. CONSULTA DE VERIFICACIÓN: ÚLTIMOS 5 MOVIMIENTOS
-- =========================================================
SELECT
    i.nombre,
    m.tipo,
    m.fecha_movimiento
FROM movimientos_ingrediente AS m
JOIN ingredientes AS i
    ON m.id_ingrediente = i.id_ingrediente
ORDER BY m.fecha_movimiento DESC
LIMIT 5;

-- =========================================================
-- 13. CONSULTA DE VERIFICACIÓN: VISTA vista_resumen_inventario
-- =========================================================
SELECT
    nombre,
    stock_actual,
    stock_minimo,
    diferencia
FROM vista_resumen_inventario;