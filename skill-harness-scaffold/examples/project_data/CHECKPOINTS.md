# CHECKPOINTS.md — public-data-pipeline

Este fichero define los criterios que el reviewer debe verificar antes de aprobar cualquier tarea. Si algún criterio no se cumple, la tarea no se cierra.

---

## Criterios generales

Aplican a cualquier tarea, sin excepción:

- [ ] El código ejecuta sin errores (`python src/main.py --help` no lanza excepción).
- [ ] Los tests pasan en su totalidad (`pytest tests/ -v` termina con 0 fallos).
- [ ] En `feature_list.json` hay exactamente un item con `"status": "in_progress"` (el de la tarea actual).
- [ ] El resultado hace exactamente lo que describía la feature, ni más ni menos.
- [ ] Si ocurrieron errores durante la implementación, están documentados en `progress/errors.md`.

---

## Criterios de integridad de datos

Aplican a cualquier fase del pipeline que lea o escriba datos:

- [ ] **No pérdida de registros:** el número de registros de salida es coherente con el de entrada. Si se filtran registros, el motivo está documentado y es intencionado.
- [ ] **Schema consistente:** los campos de salida tienen los tipos esperados. No hay `None` donde se espera un valor, ni strings donde se espera un entero.
- [ ] **Datos raw intocados:** la fase raw (`data/raw/`) no ha sido modificada por ninguna fase posterior. Los datos originales descargados permanecen inalterados.
- [ ] **Idempotencia:** ejecutar la fase dos veces produce el mismo resultado que ejecutarla una vez. No hay duplicados ni efectos acumulativos.

---

## Criterios por fase del pipeline

### Downloader (feat-001)
- [ ] El fichero descargado existe en `data/raw/` tras la ejecución.
- [ ] El fichero no está vacío y tiene el formato esperado (CSV).
- [ ] Si la descarga falla (red, 404, timeout), el error se captura y se reporta sin dejar ficheros corruptos parciales en `data/raw/`.

### Parser (feat-002)
- [ ] Los datos limpios existen en `data/clean/` tras la ejecución.
- [ ] Todos los campos definidos en el schema de `docs/architecture.md` están presentes.
- [ ] Los valores nulos o mal formateados han sido tratados según la política definida (descartados o imputados con valor documentado).
- [ ] El recuento de registros limpios está documentado en `progress/impl_feat-002.md`.

### Storage (feat-003)
- [ ] La base de datos `data/pipeline.db` existe y contiene la tabla `records`.
- [ ] El número de filas en `records` coincide con el número de registros limpios del parser.
- [ ] Los tipos de columna en SQLite coinciden con el schema definido.
- [ ] Ejecutar storage dos veces no genera duplicados (operación upsert o truncate+insert documentada).

### Exporter (feat-004)
- [ ] Los ficheros `data/export/records.csv` y `data/export/records.json` existen tras la ejecución.
- [ ] El número de registros exportados coincide con el número de filas en la base de datos.
- [ ] El CSV tiene cabecera y el JSON es un array de objetos válido.

---

## Criterios de documentación

- [ ] Existe el fichero `progress/impl_<feature>.md` y describe qué se hizo y cómo.
- [ ] Si se tomaron decisiones de diseño relevantes, están explicadas en ese fichero.

---

## Criterios de buenas prácticas

- [ ] El código sigue PEP 8 (`flake8 src/ tests/` no reporta errores).
- [ ] La implementación sigue las convenciones de `docs/conventions.md`.
- [ ] La implementación sigue las buenas prácticas de `docs/best-practices.md`.

---

## Qué hace el reviewer si algún criterio falla

El reviewer **no aprueba** la tarea. En su lugar:

1. Documenta en `progress/review_<feature>.md` qué criterio o criterios no se cumplen, con el detalle exacto de qué falló y qué se esperaba.
2. Devuelve el control al leader con referencia a ese fichero.
3. No modifica el estado de la tarea en `feature_list.json`.

El leader relanzará el implementer con el contexto del fallo. El ciclo se repite hasta que todos los criterios estén marcados.
