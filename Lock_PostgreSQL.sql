-- Preparación del ambiente de pruebas

-- Eliminación previa para evitar conflictos
DROP TABLE IF EXISTS prestamos;

-- Creación de la tabla prestamos
CREATE TABLE prestamos (
    id_prestamo SERIAL PRIMARY KEY,
    cliente VARCHAR(50) NOT NULL,
    saldo NUMERIC(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL
);

-- Inserción de datos iniciales
INSERT INTO prestamos (cliente, saldo, estado) VALUES
('Juan Perez', 5000.00, 'activo'),
('Maria Lopez', 3000.00, 'activo'),
('Carlos Ruiz', 7000.00, 'activo');

------------------------------------------------------------------------------------------------------------------------------

---Ejemplo de transacción con SAVEPOINT---
--El siguiente Ejemplo serve para demostrar cómo un SAVEPOINT permite revertir parcialmente una transacción sin perder los cambios válidos previos
BEGIN; 

-- Descuento válido aplicado al préstamo
UPDATE prestamos
SET saldo = saldo - 500
WHERE cliente = 'Juan Perez';

-- Creación del punto de guardado
SAVEPOINT sp_descuento;

-- Operación incorrecta (simulada)
UPDATE prestamos
SET saldo = saldo + 2000
WHERE cliente = 'Maria Lopez';

-- Reversión parcial
ROLLBACK TO SAVEPOINT sp_descuento;

-- Confirmación de la transacción
COMMIT;

--SAVEPOINT permite un control granular dentro de una transacción.

------------------------------------------------------------------------------------------------------------------------------

--Ejemplo de LOCK con NOWAIT--
--El ejemplo siguiente tiene como fin ilustrar cómo evitar esperas prolongadas al intentar adquirir un bloqueo explícito

--Ejecutar en Sesion 1 (Terminal 1)
BEGIN;
LOCK TABLE prestamos IN EXCLUSIVE MODE;
-- No Ejecutar COMMIT aún.

-- Ejecutar en Sesion 2 (Terminal 2)
BEGIN;
LOCK TABLE prestamos IN EXCLUSIVE MODE NOWAIT;

-- Resultado de la Terminal 2
--SQL Error [55P03]: ERROR: no se pudo bloquear un candado en la relación «prestamos»
--NOWAIT nos permite detectar inmediatamente bloqueos activos sin quedar en espera.
-- Para liberar la sesion 1, Ejecutar COMMIT;

------------------------------------------------------------------------------------------------------------------------------


--Ejemplo de aislamiento con dos transacciones concurrentes
--Nivel READ COMMITTED

--Ejecutar en Sesion 1 (Terminal 1)
BEGIN ISOLATION LEVEL READ COMMITTED;

SELECT saldo
FROM prestamos
WHERE cliente = 'Carlos Ruiz';

--Ejecutar en Sesion 2 (Terminal 2)
BEGIN;
UPDATE prestamos
SET saldo = saldo + 1000
WHERE cliente = 'Carlos Ruiz';
COMMIT;

--Ejecutar en Sesion 1 (Terminal 1)
SELECT saldo
FROM prestamos
WHERE cliente = 'Carlos Ruiz';
COMMIT;

--Primera lectura 7000, segunda lectura 8000
--READ COMMITTEED cada consulta accede a la version mas reciente confirmada de lo datos.

---------------------------------------------------------------------------------------------------------------------------------

-- Nivel de aislamiento SERIALIZABLE
--Ejecutar en Sesion 1 (Terminal 1)

BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT saldo
FROM prestamos
WHERE cliente = 'Carlos Ruiz';

--Resultado 7000

--Ejecutar en Sesion 2 (Terminal 2)

BEGIN;
UPDATE prestamos
SET saldo = saldo + 1000
WHERE cliente = 'Carlos Ruiz';
COMMIT;

--Ejecutar en Sesion 1 (Terminal 1) nuevamente.

SELECT saldo
FROM prestamos
WHERE cliente = 'Carlos Ruiz';
COMMIT;

--Resultado 7000 ó ERROR: could not serialize access due to concurrent update
--Ambas devuelven 7000 o Error de Serialización.
--La SERIALIZACION garantiza un compartamiento equivalente a la ejecución de transacciones.





select * from prestamos;