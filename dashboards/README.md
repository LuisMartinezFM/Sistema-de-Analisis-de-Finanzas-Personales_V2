## Dashboards

### Liquidez vs Uso
Este dashboard es recursivo, la liquidez final de un mes es la liquidez inicial del proximo mes, la liquidez total es la suma, de esta mas el saldo mensual, y es un indicar de lqiuidez neta, el objetivo es que esta se igual o mayor al sueldo del mes pasado.

Métricas clave:
- Liquidez Inicial
- Saldo Mensual
- Liquidez Total = Liquidez Inicial + Saldo Mensual
- Sueldo Mes Anterior
### ![Liquidez vs Uso](/dashboards/Liquidez_vs_Uso.png)

## Tarjetas de crédito
Este dashboard evalúa el nivel de exposición de la línea de crédito en relación con la liquidez disponible.
La línea usada se analiza tanto como porcentaje del límite total como contra la liquidez real del mes, permitiendo medir riesgo operativo antes del cierre.
Métricas clave:
- Línea de Crédito Total
- Línea Usada
- Línea Disponible
- % Crédito Usado
- Uso vs Liquidez

![Tarjetas](/dashboards/tarjetas.png)

### MSI
Dashboard orientado a medir la utilización de la línea de crédito en relación con la liquidez mensual disponible.
Métricas principales:
- Línea de Crédito Total
- Línea Usada
- Línea Disponible = Línea Total − Línea Usada
- % Crédito Usado = Línea Usada / Línea Total
- Uso vs Liquidez = Línea Usada / Liquidez Disponible

Reglas aplicadas:
- Todos los montos se almacenan como positivos.
- El impacto financiero depende del tipo de movimiento.
- Los pagos de tarjeta se modelan como movimientos neutros.
- Las medidas DAX fueron validadas contra consultas SQL en PostgreSQL.

El análisis se realiza bajo contexto de filtro temporal y por tarjeta, permitiendo evaluar exposición financiera dentro del período contable activo
## ![Liquidez vs Uso](/dashboards/MSI.png)


