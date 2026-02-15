## Sueldo Mensual
Sueldo_mensual = 
VAR FechaCorte   = MAX('finanzas dim_calendario'[fecha])
VAR InicioMesSel = DATE(YEAR(FechaCorte), MONTH(FechaCorte), 1)

VAR InicioMesPrev = EDATE(InicioMesSel, -1)
VAR FinMesPrev    = EOMONTH(InicioMesSel, -1)
RETURN
COALESCE(
    CALCULATE(
        SUM('finanzas fact_movimientos_liquidez'[monto]),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "INGRESO",
        'finanzas fact_movimientos_liquidez'[id_concepto] = 1,
        FILTER(
            ALL('finanzas dim_calendario'[fecha]),
            'finanzas dim_calendario'[fecha] >= InicioMesPrev
                && 'finanzas dim_calendario'[fecha] <= FinMesPrev
        )
    ),
    0
)

## Liquidez disponible del mes
Liquidez_Total = [Liquidez_Inicial] + [Sueldo_mensual] + [Ingresos_Extras]

## Monto Usado
Monto_Usado = 
COALESCE(
    CALCULATE(
        SUM('finanzas fact_movimientos_liquidez'[monto]),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "EGRESO"
    ),
    0
)

## Liquidez a final de mes
Liquidez Final = 
COALESCE(
    [Liquidez_Total] - [Monto_Usado],
    0
)


## Presupuesto Usado
Presupuesto_Usado_v2 = 
COALESCE(
    CALCULATE(
        SUM ( 'finanzas fact_movimientos_liquidez'[monto] ),
        'finanzas fact_movimientos_liquidez'[tipo_movimiento] = "EGRESO",
        'finanzas cat_conceptos_financieros'[presupuestable] = "S"
    ),
    0
)


## Estado de los prestamos
Estado_prestamo = 
SWITCH (
    TRUE(),
    'finanzas fact_prestamos'[Monto_restante] > 0, "ACTIVO",
    'finanzas fact_prestamos'[Monto_restante] = 0, "INACTIVO",
    'finanzas fact_prestamos'[Monto_restante] < 0, "REVISION"
)

