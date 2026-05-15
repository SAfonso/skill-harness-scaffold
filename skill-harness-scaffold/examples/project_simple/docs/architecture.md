# Arquitectura — todo-cli

El leader actualiza este fichero cada vez que se toma una decisión de diseño relevante.

---

## Visión general

`todo-cli` es una herramienta de línea de comandos en Python para gestionar listas de tareas personales. El usuario interactúa con ella mediante subcomandos (`add`, `list`, `done`). Las tareas se persisten en un fichero JSON local (`tasks.json`) en el directorio de trabajo. No hay servidor, no hay base de datos externa, no hay autenticación.

Diseñada para ser simple, portable y sin dependencias externas más allá de la biblioteca estándar de Python.

---

## Componentes principales

| Componente | Responsabilidad |
|------------|-----------------|
| `src/main.py` | Punto de entrada. Parsea los argumentos de la CLI y delega en los handlers. |
| `src/storage.py` | Lectura y escritura de `tasks.json`. Encapsula toda la lógica de persistencia. |
| `src/tasks.py` | Lógica de negocio: crear tarea, listar tareas, marcar como completada. |
| `tasks.json` | Fichero de datos. Generado automáticamente en el primer uso. |
| `tests/` | Tests unitarios e integración con `pytest`. |

---

## Decisiones de diseño

### [2026-05-15] Persistencia en JSON local en lugar de SQLite
- **Decisión:** usar `tasks.json` como almacenamiento en lugar de SQLite.
- **Alternativas consideradas:** SQLite (más robusto para concurrencia y queries complejas).
- **Motivo:** la herramienta es de uso personal y monousuario. JSON es legible a mano, no requiere dependencias adicionales y es suficiente para el volumen de datos esperado.
- **Consecuencias conocidas:** no escala bien con miles de tareas. Si el proyecto crece, migrar a SQLite será un refactor no trivial.

### [2026-05-15] IDs autoincrementales en lugar de UUIDs
- **Decisión:** los IDs de tareas son enteros autoincrementales (1, 2, 3...).
- **Alternativas consideradas:** UUIDs (más robustos si se importan/exportan tareas).
- **Motivo:** los IDs numéricos son más cómodos de escribir en la CLI (`done 3` vs `done a3f2...`).
- **Consecuencias conocidas:** si se elimina una tarea, su ID no se reutiliza para evitar confusión.

---

## Lo que este proyecto NO hace

- No sincroniza tareas entre dispositivos.
- No tiene interfaz web ni API.
- No gestiona fechas límite, prioridades ni etiquetas de tareas.
- No elimina tareas (solo las marca como completadas).
- No soporta múltiples listas o proyectos.
