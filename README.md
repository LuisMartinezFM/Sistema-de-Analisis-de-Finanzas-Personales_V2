# Sistema de Análisis de Finanzas Personales V2

Sistema end-to-end de finanzas personales construido sobre reglas explícitas, modelado relacional en PostgreSQL y análisis en Power BI. Cubre liquidez, tarjetas de crédito, presupuestos, ahorros y préstamos.

> **Nota:** los datos del sistema son ficticios. Se diseñó una narrativa financiera de un personaje ficticio e insertó via SQL para validar el modelo sin exponer información personal real.

---

## Stack

| Capa | Tecnología |
|---|---|
| Base de datos | PostgreSQL |
| Análisis y visualización | Power BI |
| Métricas | DAX |
| Modelado conceptual | dbdiagram.io |
| Diseño de interfaces | Figma |

---

## Arquitectura

```
Reglas financieras (conceptos y tipos de movimiento)
        ↓
Modelo relacional (PostgreSQL)
        ↓
Modelo semántico (Power BI)
        ↓
Medidas DAX
        ↓
Dashboards orientados a decisión
```

---

## Principios del sistema

- Los montos siempre se registran como positivos — el impacto depende del tipo de movimiento
- Tres tipos de movimiento: **INGRESO**, **EGRESO**, **NEUTRO**
- Los pagos de tarjeta son movimientos NEUTROS — el gasto ocurrió al momento de la compra
- El 100% de la liquidez se presupuesta — los porcentajes deben sumar exactamente 100% por mes
- Separación estricta entre liquidez, deuda y patrimonio
- Ninguna visualización corrige errores de modelo — el orden es SQL → DAX → visual

---

## Dashboards

### Liquidez vs Uso
Muestra la liquidez real del mes y cómo se consume. La liquidez final de un mes es la liquidez inicial del siguiente — el sistema es recursivo por diseño.

```
Liquidez_Total  = Sueldo_Mensual + Ingresos_Extras + Liquidez_Inicial
Liquidez_Final  = Liquidez_Total - Monto_Usado
Liquidez_Final(N) = Liquidez_Inicial(N+1)
```

![Liquidez vs Uso](/dashboards/Liquidez_vs_Uso.png)

---

### Tarjetas de Crédito
Evalúa el nivel de exposición de cada tarjeta en relación con la liquidez disponible.

```
Linea_Disponible      = Linea_Credito_Total - Linea_Usada
% Credito_Usado       = Linea_Usada / Linea_Credito_Total
% Tarjeta_vs_Liquidez = Linea_Usada / Liquidez_Total
```

![Tarjetas de Crédito](/dashboards/tarjetas.png)

---

### MSI — Meses Sin Intereses
Seguimiento de compras a meses sin intereses activas: mensualidad, saldo pagado, saldo pendiente y fechas clave.

![MSI](/dashboards/msi.png)

---

### Presupuestos
El dashboard más complejo del sistema. Implementa un modelo recursivo donde el saldo no usado de un mes se acumula al siguiente.

```
Presupuesto_Real      = Liquidez_Total × (porcentaje / 100)
Presupuesto_Ideal     = Sueldo_Mensual × (porcentaje / 100)
Acumulado_Historico   = Presupuesto_Real + Saldo_Anterior
Saldo_del_Presupuesto = Acumulado_Historico - Presupuesto_Usado
Saldo_Anterior(N)     = Saldo_del_Presupuesto(N-1)
```
![Presupuestos](/dashboards/Presupuestos.png)
---

### Ahorros
Progreso de cada fondo de ahorro: abonos, retiros y avance hacia la meta.

```
Ahorro_Acumulado = Monto_Abonado - Monto_Retirado
Ahorro_Restante  = Meta_del_Fondo - Ahorro_Acumulado
```
![Ahorros](/dashboards/Ahorros.png)
---

### Lista de Presupuestos
Tabla de referencia visual que muestra qué categorías tienen presupuesto asignado en el mes seleccionado. Sirve como guía antes de revisar el dashboard de Presupuestos.
![Lista](/dashboards/Lista.png)
---

### Préstamos
Estado de préstamos otorgados (LEND) y recibidos (BORROW): monto, fecha, contraparte y estado activo/inactivo.
![Prestamos](/dashboards/Prestamos.png)
---

## Estructura del repositorio

```
📁 sql/          — esquema de base de datos y queries de validación
📁 dax/          — medidas DAX organizadas por dashboard
📁 dashboards/   — capturas de los dashboards finales
📁 docs/         — documentación técnica de decisiones clave
```

---

## Decisiones técnicas destacadas

**Patrón de limpieza de contexto de fecha en DAX**  
En lugar de `DATEADD` sobre granularidad diaria, se usa `ALL()` sobre el calendario y se filtra directamente por `inicio_mes` en la tabla de hechos. Evita resultados impredecibles cuando el contexto tiene múltiples días.

**Patrón de preservación de filtro de categoría**  
Al limpiar el contexto de fecha con `ALL()`, el filtro de categoría se pierde. Se resuelve capturando los conceptos filtrados con `VALUES` y reinyectándolos con `TREATAS` dentro del `CALCULATE`.

**Recursividad en DAX expandida manualmente**  
DAX no permite medidas recursivas directas. `Saldo_Anterior(N)` se expande dos niveles — mes anterior y mes anteprevio — porque cada mes ya arrastra el historial acumulado previo.

**Columna `inicio_mes` en PostgreSQL**  
`DATE_TRUNC` no es inmutable en PostgreSQL y no puede usarse en columnas generadas. Se resolvió con `ALTER TABLE` + `UPDATE` manual. Pendiente: automatizar via trigger.

---

## Aprendizajes clave

1. Las reglas van antes que el modelo — definir conceptos antes de tocar SQL o Power BI evita semanas de retrabajo
2. DAX es un lenguaje de contexto, no de fórmulas — los problemas más difíciles se resuelven entendiendo cómo maneja filtros
3. Un modelo bien diseñado absorbe cambios sin romperse — el parche de noviembre 2024 resolvió tres problemas estructurales sin afectar los dashboards existentes
4. Documentar es parte del trabajo — sin documentación el sistema existe solo en tu cabeza

---

## Próximos pasos

- [ ] Trigger en PostgreSQL para automatizar `inicio_mes`
- [ ] Visual bipolar de préstamos BORROW/LEND
- [ ] Indicador de deudas fijas recurrentes por préstamos activos
- [ ] Migración a centavos como unidad entera
