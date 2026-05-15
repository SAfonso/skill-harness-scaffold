# Convenciones — public-data-pipeline

Cualquier agente debe consultar este fichero antes de crear o modificar ficheros en el proyecto.

---

## Naming

- **Variables y funciones:** `snake_case`
- **Clases:** `PascalCase`
- **Constantes y configuración:** `UPPER_SNAKE_CASE`
- **Ficheros Python:** `snake_case.py`
- **Directorios:** `snake_case`
- **Columnas de datos:** `snake_case` (en CSV, SQLite y JSON)

### Naming específico para datos

- Variables que contienen DataFrames o listas de registros: sufijo `_df` o `_records` según el tipo. Ejemplo: `raw_df`, `clean_records`.
- Rutas de ficheros: sufijo `_path`. Ejemplo: `input_path`, `db_path`, `output_dir`.
- Conteos de registros: prefijo `n_`. Ejemplo: `n_raw`, `n_clean`, `n_discarded`.

---

## Estructura de ficheros

```
src/              módulos del pipeline (uno por fase)
tests/            tests con pytest (espejo de src/)
data/
  raw/            datos originales descargados — NUNCA modificar
  clean/          datos limpios tras el parser
  export/         ficheros de salida (CSV, JSON)
  pipeline.db     base de datos SQLite
docs/             documentación del proyecto
progress/         estado y bitácoras del harness
agents/           outputs de agentes
```

---

## Estilo de código

- Seguir **PEP 8** en todo el código. Verificar con `flake8 src/ tests/`.
- Máximo **88 caracteres** por línea.
- Indentación: **4 espacios**, nunca tabs.
- Sin trailing whitespace. Ficheros terminan en newline.
- Docstrings en todas las funciones públicas. Formato:

```python
def parse(input_path: str, output_path: str) -> int:
    """Lee el CSV raw, lo limpia y guarda el resultado en output_path.

    Returns:
        Número de registros escritos en output_path.

    Raises:
        FileNotFoundError: si input_path no existe.
        ValueError: si el CSV no tiene las columnas esperadas.
    """
```

---

## Manejo de errores en pipelines

- Cada fase captura sus propias excepciones y las relanza con contexto. Nunca silenciar errores con `except: pass`.
- Si una fase falla, no debe dejar ficheros de salida parciales. Usar escritura atómica (escribir en temporal y renombrar) o limpiar en el bloque `except`.
- Los errores de datos (registros descartados, valores nulos) no son excepciones — se cuentan, se documentan y se reportan al final de la fase.
- Nunca usar `print()` para reportar errores. Usar `logging` con nivel apropiado (`WARNING` para datos descartados, `ERROR` para fallos de fase).

---

## Logging

- Usar el módulo `logging` de la biblioteca estándar.
- Nivel mínimo de producción: `INFO`.
- Formato: `%(asctime)s [%(levelname)s] %(name)s: %(message)s`
- Cada módulo crea su propio logger: `logger = logging.getLogger(__name__)`
- Loguear al inicio y al final de cada fase con el recuento de registros procesados.

---

## Commits — Conventional Commits

Formato obligatorio:

```
<tipo>(<scope>): <descripción en imperativo, minúsculas, en inglés>
```

Tipos válidos:

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat` | Nueva fase o funcionalidad del pipeline |
| `fix` | Corrección de bug o error de datos |
| `docs` | Solo documentación |
| `test` | Añadir o corregir tests |
| `refactor` | Refactor sin cambio de comportamiento |
| `chore` | Tareas de mantenimiento (deps, config) |

Ejemplos:

```
feat(downloader): download municipios dataset from datos.gob.es
fix(parser): handle missing provincia field with empty string
test(storage): add idempotency test for load()
```

---

## Idioma

- **Código fuente** (variables, funciones, clases, comentarios inline): inglés.
- **Documentación** (`docs/`, `progress/`, ficheros `.md`): español.
- **Mensajes de commit:** inglés.
- **Mensajes de log:** inglés.
- **Nombres de columnas en datos:** español (para mantener coherencia con el dataset fuente de datos.gob.es).
