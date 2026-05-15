# Convenciones — todo-cli

Cualquier agente debe consultar este fichero antes de crear o modificar ficheros en el proyecto.

---

## Naming

- **Variables y funciones:** `snake_case`
- **Clases:** `PascalCase`
- **Constantes:** `UPPER_SNAKE_CASE`
- **Ficheros Python:** `snake_case.py`
- **Directorios:** `snake_case`

---

## Estructura de ficheros

```
src/          código fuente Python
tests/        tests con pytest
docs/         documentación del proyecto
progress/     estado y bitácoras del harness
agents/       definiciones de agentes y outputs
tasks.json    datos de tareas (generado en tiempo de ejecución)
```

---

## Estilo de código

- Seguir **PEP 8** en todo el código. Verificar con `flake8 src/ tests/`.
- Máximo **88 caracteres** por línea (compatible con Black si se adopta en el futuro).
- Indentación: **4 espacios**, nunca tabs.
- Sin trailing whitespace. Ficheros terminan en newline.
- No dejar código comentado sin un comentario explicando por qué está ahí.
- Docstrings en funciones públicas si su propósito no es evidente por el nombre.

---

## Mensajes de salida al usuario

- Todos los mensajes visibles al usuario se escriben en **español**.
- Formato de éxito: `Tarea añadida: [<id>] <texto>`
- Formato de listado: `[<id>] [<status>] <texto>`
- Formato de error: `Error: <descripción en minúsculas>.` — salir con código 1.
- Sin colores en la salida estándar (la herramienta puede usarse en pipes).

---

## Commits — Conventional Commits

Formato obligatorio:

```
<tipo>(<scope>): <descripción en imperativo, minúsculas, en inglés>
```

Tipos válidos:

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Solo documentación |
| `test` | Añadir o corregir tests |
| `refactor` | Refactor sin cambio de comportamiento |
| `chore` | Tareas de mantenimiento (deps, config) |

Ejemplos:

```
feat(cli): add 'add' command to create new tasks
fix(storage): handle missing tasks.json on first run
test(tasks): add unit tests for mark_done with invalid id
```

---

## Idioma

- **Código fuente** (variables, funciones, clases, comentarios inline): inglés.
- **Documentación** (`docs/`, `progress/`, ficheros `.md`): español.
- **Mensajes de commit:** inglés.
- **Mensajes de salida al usuario final:** español.
