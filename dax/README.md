# DAX — Medidas del sistema

Este directorio contiene las medidas DAX implementadas en Power BI.

Se documentan las medidas con sufijo `_T` por ser las más representativas técnicamente — resuelven tres problemas reales de contexto, filtrado y recursividad que las medidas originales no manejaban correctamente. Las medidas originales siguen activas en el modelo en paralelo.

---

## ¿Por qué las medidas _T?

Las medidas originales tenían tres problemas estructurales detectados en noviembre 2024:

1. **Granularidad de fechas:** `DATEADD` sobre columna diaria producía resultados impredecibles al saltar meses
2. **Filtro de categoría perdido:** `ALL()` para limpiar contexto de fecha eliminaba también el filtro de categoría activo
3. **Recursividad:** DAX no permite medidas recursivas directas — `Saldo_Anterior(N) = Saldo_del_Presupuesto(N-1)` no es implementable de forma directa

Las medidas `_T` resuelven los tres problemas con patrones explícitos y documentados.

---

## Patrones clave implementados

### Patrón 1 — Limpieza de contexto de fecha
En lugar de `DATEADD`, se usa `ALL()` sobre el calendario y se filtra directamente por `inicio_mes` en la tabla de hechos:
```dax
CALCULATE(
    SUM(tabla[columna]),
    ALL('finanzas dim_calendario'),
    tabla[inicio_mes] = MesPrevio
)
```

### Patrón 2 — Preservación de filtro de categoría
Se capturan los conceptos filtrados antes del `CALCULATE` y se reinyectan con `TREATAS`:
```dax
VAR ConceptosFiltrados = VALUES('finanzas cat_conceptos_financieros'[id_concepto])
TREATAS(ConceptosFiltrados, 'finanzas fact_presupuesto_mensual'[id_concepto])
```

### Patrón 3 — Recursividad expandida dos niveles
```
Saldo_Anterior(N) = [Real(N-1) - Usado(N-1)] + [Real(N-2) - Usado(N-2)]
```
El segundo término representa el `Saldo_Anterior` de N-1, que ya incluye todo el historial previo acumulado.

---

## Medidas _T

### Sueldo_mensual_T
Sueldo del mes anterior filtrado directamente por `inicio_mes` en la tabla de hechos — evita el problema de granularidad diaria.
```dax
Sueldo_mensual_T = 
VAR MesSel     = MAX('finanzas dim_calendario'[inicio_mes])
VAR MesPrevio  = EDATE(MesSel, -1)
RETURN
COALESCE(
    CALCULATE(
        SUM('finanzas fact_movimientos_liquidez'[monto]),
        ALL('finanzas fact_movimientos_liquidez'),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "INGRESO",
        'finanzas fact_movimientos_liquidez'[id_concepto] = 1,
        'finanzas fact_movimientos_liquidez'[inicio_mes] = MesPrevio
    ),
    0
)
```

### Ingresos_Extras_T
```dax
Ingresos_Extras_T = 
COALESCE(
    CALCULATE(
        SUM('finanzas fact_movimientos_liquidez'[monto]),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "INGRESO",
        'finanzas fact_movimientos_liquidez'[id_concepto] IN { 10, 27 }
    ),
    0
)
```

### Liquidez_Total_T
```dax
Liquidez_Total_T = 
[Liquidez_Inicial] + [Sueldo_mensual_T] + [Ingresos_Extras_T]
```

### Presupuesto_Real_T
```dax
Presupuesto_Real_T = 
COALESCE(
    SUM('finanzas fact_presupuesto_mensual'[monto_base_real]),
    0
)
```

### Presupuesto_Ideal_T
```dax
Presupuesto_Ideal_T = 
VAR MesSel = MAX('finanzas dim_calendario'[inicio_mes])
RETURN
COALESCE(
    CALCULATE(
        SUM('finanzas fact_presupuesto_mensual'[monto_base_ideal]),
        TREATAS({ MesSel }, 'finanzas fact_presupuesto_mensual'[fecha_mes])
    ),
    0
)
```

### Presupuesto_Usado_T
```dax
Presupuesto_Usado_T = 
COALESCE(
    CALCULATE(
        SUM('finanzas fact_movimientos_liquidez'[monto]),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "EGRESO",
        'finanzas cat_conceptos_financieros'[presupuestable] = "S"
    ),
    0
)
```

### Neto_Mes_T
```dax
Neto_Mes_T = 
COALESCE(
    [Presupuesto_Real_T] - [Presupuesto_Usado_T],
    0
)
```

### Saldo_Anterior_T
Implementa la recursividad expandida manualmente dos niveles. Es la medida más compleja del sistema.
```dax
Saldo_Anterior_T = 
VAR MesPrevio     = EDATE(MAX('finanzas dim_calendario'[inicio_mes]), -1)
VAR MesAntePrevio = EDATE(MesPrevio, -1)
VAR ConceptosFiltrados = VALUES('finanzas cat_conceptos_financieros'[id_concepto])

VAR RealPrevio =
    CALCULATE(
        SUM('finanzas fact_presupuesto_mensual'[monto_base_real]),
        ALL('finanzas dim_calendario'),
        'finanzas fact_presupuesto_mensual'[fecha_mes] = MesPrevio,
        TREATAS(ConceptosFiltrados, 'finanzas fact_presupuesto_mensual'[id_concepto])
    )
VAR UsadoPrevio =
    CALCULATE(
        SUM('finanzas fact_movimientos_liquidez'[monto]),
        ALL('finanzas fact_movimientos_liquidez'),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "EGRESO",
        'finanzas cat_conceptos_financieros'[presupuestable] = "S",
        'finanzas fact_movimientos_liquidez'[inicio_mes] = MesPrevio,
        TREATAS(ConceptosFiltrados, 'finanzas fact_movimientos_liquidez'[id_concepto])
    )
VAR RealAntePrevio =
    CALCULATE(
        SUM('finanzas fact_presupuesto_mensual'[monto_base_real]),
        ALL('finanzas dim_calendario'),
        'finanzas fact_presupuesto_mensual'[fecha_mes] = MesAntePrevio,
        TREATAS(ConceptosFiltrados, 'finanzas fact_presupuesto_mensual'[id_concepto])
    )
VAR UsadoAntePrevio =
    CALCULATE(
        SUM('finanzas fact_movimientos_liquidez'[monto]),
        ALL('finanzas fact_movimientos_liquidez'),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "EGRESO",
        'finanzas cat_conceptos_financieros'[presupuestable] = "S",
        'finanzas fact_movimientos_liquidez'[inicio_mes] = MesAntePrevio,
        TREATAS(ConceptosFiltrados, 'finanzas fact_movimientos_liquidez'[id_concepto])
    )
VAR SaldoAntePrevio = COALESCE(RealAntePrevio, 0) - COALESCE(UsadoAntePrevio, 0)
RETURN
COALESCE(RealPrevio, 0) - COALESCE(UsadoPrevio, 0) + SaldoAntePrevio
```

### Acumulado_Historico_T
```dax
Acumulado_Historico_T = 
COALESCE(
    [Presupuesto_Real_T] + [Saldo_Anterior_T],
    0
)
```

### Saldo_del_Presupuesto_T
```dax
Saldo_del_Presupuesto_T = 
COALESCE(
    [Acumulado_Historico_T] - [Presupuesto_Usado_T],
    0
)
```

---

## Validación

Todas las medidas `_T` fueron validadas contra consultas SQL en PostgreSQL para noviembre 2024, diciembre 2024 y enero 2025.
