# CHECKPOINTS.md — todo-cli

Este fichero define los criterios que el reviewer debe verificar antes de aprobar cualquier tarea. Si algún criterio no se cumple, la tarea no se cierra.

---

## Criterios generales

Aplican a cualquier tarea, sin excepción:

- [ ] El código ejecuta sin errores (`python src/main.py --help` no lanza excepción).
- [ ] Los tests pasan en su totalidad (`pytest tests/ -v` termina con 0 fallos).
- [ ] En `feature_list.json` hay exactamente un item con `"status": "in_progress"` (el de la tarea actual).
- [ ] El resultado hace exactamente lo que describía la feature, ni más ni menos. No se han añadido comportamientos no solicitados.
- [ ] Si ocurrieron errores durante la implementación, están documentados en `progress/errors.md` con el formato establecido.

---

## Criterios de documentación

- [ ] Existe el fichero `progress/impl_<feature>.md` y describe qué se hizo y cómo.
- [ ] Si se tomaron decisiones de diseño relevantes (alternativas descartadas, compromisos asumidos, limitaciones conocidas), están explicadas en ese mismo fichero.

---

## Criterios de buenas prácticas

- [ ] El código sigue PEP 8 (`flake8 src/ tests/` no reporta errores).
- [ ] Las funciones nuevas tienen docstring si su propósito no es evidente.
- [ ] La implementación sigue las convenciones definidas en `docs/conventions.md`.
- [ ] La implementación sigue las buenas prácticas definidas en `docs/best-practices.md`.

---

## Criterios específicos de todo-cli

- [ ] Los comandos de la CLI tienen el nombre y los argumentos exactos descritos en la feature.
- [ ] Los mensajes de salida al usuario son en español y tienen el formato definido en `docs/conventions.md`.
- [ ] Las tareas se persisten correctamente en `tasks.json` tras cada operación.
- [ ] El comando no modifica datos cuando se invoca con `--help` o con argumentos inválidos.

---

## Qué hace el reviewer si algún criterio falla

El reviewer **no aprueba** la tarea. En su lugar:

1. Documenta en `progress/review_<feature>.md` qué criterio o criterios no se cumplen, con el detalle exacto de qué falló y qué se esperaba.
2. Devuelve el control al leader con referencia a ese fichero.
3. No modifica el estado de la tarea en `feature_list.json`.

El leader relanzará el implementer con el contexto del fallo. El ciclo se repite hasta que todos los criterios estén marcados.
