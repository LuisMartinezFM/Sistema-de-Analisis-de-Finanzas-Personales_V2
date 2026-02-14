CREATE TABLE movimientos_liquidez (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL, -- INGRESO | EGRESO | NEUTRO
    concepto VARCHAR(100) NOT NULL,
    monto NUMERIC(12,2) NOT NULL CHECK (monto > 0),
    metodo_pago VARCHAR(30),
    presupuesto_id INTEGER,
    tarjeta_id INTEGER,
    fondo_id INTEGER,
    prestamo_id INTEGER
);

