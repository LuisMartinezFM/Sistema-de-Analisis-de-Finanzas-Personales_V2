# Módulo 7 – Iteración y mantenimiento del sistema

## Objetivo

Definir un proceso estructurado para evolucionar el sistema sin romper la coherencia del modelo ni degradar la confiabilidad de los KPIs.

## Orden de modificación

1. Cambios estructurales en SQL.
2. Ajustes en medidas DAX.
3. Actualización de visuales.

## Reglas de evolución

- Nunca corregir errores de modelo desde visualización.
- Todo KPI nuevo debe justificarse.
- Validar siempre SQL vs Power BI.
- Eliminar métricas obsoletas en lugar de ocultarlas.

## Principio estructural

La consistencia es más valiosa que la novedad.

