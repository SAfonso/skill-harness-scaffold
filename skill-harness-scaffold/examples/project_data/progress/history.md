# progress/history.md — public-data-pipeline

Bitácora append-only de todas las sesiones del proyecto. Cada entrada documenta lo ocurrido en una sesión de trabajo.

**Regla:** nunca se edita ni elimina una entrada pasada. Solo se añaden entradas nuevas al final del fichero.

---

## Sesión 2026-05-15

_Primera sesión. Harness inicializado con skill-harness-scaffold. Estructura de ficheros creada. Sin código todavía._

**Tareas completadas:**
- Ninguna.

**Tareas bloqueadas:**
- `feat-002`, `feat-003`, `feat-004` bloqueadas en cadena hasta que `feat-001` esté done.

**Decisiones relevantes:**
- Arquitectura medallion simplificada: raw → clean → export, con SQLite como capa de storage intermedia.
- Dataset elegido: municipios de España desde datos.gob.es (open data, sin autenticación).
- Persistencia de datos raw en `data/raw/`, datos limpios en `data/clean/`, base de datos en `data/pipeline.db`, exportaciones en `data/export/`.

**Notas:**
- Empezar necesariamente por `feat-001` — es el único punto de entrada del pipeline.
