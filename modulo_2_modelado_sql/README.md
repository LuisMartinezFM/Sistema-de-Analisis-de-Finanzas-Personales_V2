# Módulo 2 – Modelado del sistema financiero en SQL

## Objetivo

Materializar las reglas del sistema financiero en un modelo relacional normalizado, garantizando trazabilidad, integridad referencial y consistencia analítica.

## Decisiones clave

- Tabla central de movimientos de liquidez.
- Montos siempre positivos.
- Impacto determinado por tipo de movimiento.
- Separación de tarjetas, fondos y préstamos como entidades independientes.
- Presupuesto modelado como entidad propia.
- Validación posterior mediante consultas SQL.

## Principio estructural

SQL es la fuente de verdad del sistema.
Power BI solo interpreta.

