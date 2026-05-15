# Arquitectura — public-data-pipeline

El leader actualiza este fichero cada vez que se toma una decisión de diseño relevante.

---

## Visión general

`public-data-pipeline` es un pipeline de datos local en Python que descarga datasets públicos de datos.gob.es, los limpia y normaliza, los persiste en SQLite y los exporta en formatos reutilizables (CSV y JSON). No hay servidor, no hay cloud, no hay dependencias externas más allá de la biblioteca estándar de Python.

El pipeline sigue una arquitectura medallion simplificada con tres capas:

```
datos.gob.es
     ↓
[Downloader]  →  data/raw/        (datos originales, nunca modificados)
     ↓
[Parser]      →  data/clean/      (datos limpios y normalizados)
     ↓
[Storage]     →  data/pipeline.db (SQLite, capa de consulta)
     ↓
[Exporter]    →  data/export/     (CSV y JSON para consumo externo)
```

---

## Componentes principales

| Componente | Fichero | Responsabilidad |
|------------|---------|-----------------|
| Downloader | `src/downloader.py` | Descarga el dataset desde la URL pública y lo guarda en `data/raw/`. |
| Parser | `src/parser.py` | Lee raw, limpia y normaliza, escribe en `data/clean/`. |
| Storage | `src/storage.py` | Carga el CSV limpio en la tabla `municipios` de SQLite. |
| Exporter | `src/exporter.py` | Lee SQLite y genera `data/export/municipios.csv` y `.json`. |
| Main | `src/main.py` | Punto de entrada. Permite ejecutar fases individuales o el pipeline completo. |

---

## Schema de datos

### data/raw/municipios.csv
Fichero original tal como viene de datos.gob.es. No se transforma. Puede tener columnas extra, encoding variable, campos vacíos.

### data/clean/municipios.csv
Schema canónico del pipeline:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `codigo_ine` | str (5 chars) | Código INE del municipio, con cero a la izquierda |
| `nombre` | str | Nombre del municipio en title case |
| `provincia` | str | Nombre de la provincia en title case |
| `comunidad_autonoma` | str | Nombre de la comunidad autónoma en title case |

### data/pipeline.db — tabla municipios
Mismos campos que el CSV limpio. `codigo_ine` es PRIMARY KEY.

---

## Decisiones de diseño

### [2026-05-15] SQLite como capa de storage en lugar de CSV directo
- **Decisión:** usar SQLite como capa intermedia entre parser y exporter.
- **Alternativas consideradas:** leer el CSV limpio directamente en el exporter.
- **Motivo:** SQLite permite consultas, índices y validación de tipos sin dependencias externas. Facilita añadir filtros o agregaciones en el futuro sin cambiar la interfaz del exporter.
- **Consecuencias conocidas:** añade una fase (storage) al pipeline, pero cada fase es más cohesiva y testeable de forma aislada.

### [2026-05-15] Idempotencia por truncate+insert en lugar de upsert
- **Decisión:** al cargar en SQLite, vaciar la tabla y reinsertarla completa.
- **Alternativas consideradas:** upsert por `codigo_ine` (INSERT OR REPLACE).
- **Motivo:** el dataset completo cabe en memoria. Truncate+insert es más simple, más rápido y garantiza que no quedan registros huérfanos de ejecuciones anteriores.
- **Consecuencias conocidas:** si el pipeline falla a mitad del insert, la tabla queda vacía. Aceptable en un pipeline local sin usuarios concurrentes.

### [2026-05-15] Datos raw nunca modificados
- **Decisión:** `data/raw/` es inmutable una vez descargada. Ninguna fase posterior escribe en ese directorio.
- **Alternativas consideradas:** modificar el raw in-place para ahorrar espacio.
- **Motivo:** reproducibilidad. Si el parser produce resultados inesperados, se puede re-ejecutar contra el mismo raw sin volver a descargar.
- **Consecuencias conocidas:** doble uso de disco (raw + clean). Aceptable para datasets de tamaño razonable.

---

## Lo que este proyecto NO hace

- No descarga múltiples datasets ni gestiona múltiples fuentes.
- No tiene scheduler ni ejecución automática periódica.
- No expone los datos como API ni como servidor web.
- No gestiona credenciales ni datasets con autenticación.
- No hace deduplicación avanzada ni reconciliación entre versiones del dataset.
