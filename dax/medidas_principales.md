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

## Liquidez Total
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

## Liquidez Final
Liquidez Final = 
COALESCE(
    [Liquidez_Total] - [Monto_Usado],
    0
)


Presupuesto Usado

Deuda Activa
