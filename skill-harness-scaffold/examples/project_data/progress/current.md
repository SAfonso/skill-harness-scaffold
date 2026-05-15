# progress/current.md — public-data-pipeline

Este fichero refleja el estado vivo de la sesión activa. El leader lo actualiza al inicio y al final de cada sesión.

---

## Fecha de sesión

2026-05-15

---

## Tarea actual en progreso

**ID:** ninguna
**Título:** —
**Estado:** Sin sesión activa

---

## Próximas tareas

| ID | Título | Priority | Bloqueada por |
|----|--------|----------|---------------|
| feat-001 | Downloader | high | — |
| feat-002 | Parser | high | feat-001 |
| feat-003 | Storage | medium | feat-002 |
| feat-004 | Exporter | low | feat-003 |

---

## Bloqueos y dependencias pendientes

- `feat-002` bloqueada por `feat-001` (pending).
- `feat-003` bloqueada por `feat-002` (pending).
- `feat-004` bloqueada por `feat-003` (pending).

El único punto de entrada del pipeline es `feat-001`. Hasta que no esté done, ninguna otra fase puede iniciarse.

---

## Decisiones tomadas en esta sesión

_Ninguna todavía._

---

## Estado al cierre de sesión

_Sesión no iniciada. Proyecto recién creado con harness vacío. Próximo paso: implementar feat-001 (Downloader), única tarea sin dependencias._
