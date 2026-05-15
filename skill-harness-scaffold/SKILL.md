---
name: skill-harness-scaffold
description: >
  Genera automáticamente la estructura completa de un harness multi-agente para
  proyectos en Claude Code. TRIGGEAR cuando el usuario mencione: "crear proyecto
  nuevo", "inicializar harness", "setup proyecto con Claude Code", "nuevo repo",
  "iniciar proyecto", "crear estructura de proyecto", o cuando abra un directorio
  sin estructura de harness y quiera empezar a trabajar con agentes. Produce todos
  los ficheros de configuración, definición de roles (leader/implementer/reviewer),
  sistema de estado en disco (progress/), bitácora de errores, criterios de
  validación y script de arranque. Triggear antes que después ante cualquier duda.
---

## Qué hace esta Skill

Genera de una sola vez toda la estructura base necesaria para trabajar con un harness multi-agente en Claude Code. A partir de las plantillas en `references/templates/`, crea el conjunto completo de ficheros con el nombre del proyecto sustituido.

Lo que genera: ficheros de configuración de Claude Code (`CLAUDE.md`, `AGENTS.md`, `CHECKPOINTS.md`), definiciones detalladas de los tres agentes (`leader`, `implementer`, `reviewer`), sistema de estado en disco (`progress/`), documentación base (`docs/`), backlog de features (`feature_list.json`) y script de verificación del entorno (`init.sh`).

Lo que NO hace: no personaliza el contenido según el dominio del proyecto. La estructura generada es genérica e idéntica para cualquier proyecto. Los ficheros que requieren personalización manual (`docs/architecture.md`, `docs/conventions.md`, `docs/best-practices.md`) se generan con secciones marcadas como pendientes — completarlos es responsabilidad del usuario.

---

## Cuándo usar esta Skill

Triggear ante cualquiera de estas situaciones:

- El usuario dice "crear proyecto nuevo", "nuevo proyecto", "iniciar proyecto".
- El usuario dice "inicializar harness", "setup harness", "setup proyecto con Claude Code".
- El usuario dice "nuevo repo", "crear estructura de proyecto", "preparar proyecto".
- El usuario abre un directorio en Claude Code que no tiene `CLAUDE.md`, `AGENTS.md` o `feature_list.json`.
- El usuario menciona que quiere trabajar con agentes (leader, implementer, reviewer) y el directorio no tiene estructura de harness.
- Hay duda sobre si triggear: triggear. Es más fácil ignorar ficheros generados de más que crearlos manualmente uno a uno.

---

## Workflow

**Paso 1 — Obtener el nombre del proyecto**

Si el usuario no ha proporcionado el nombre del proyecto, pedírselo antes de continuar:

> "¿Cuál es el nombre del proyecto? Lo usaré como identificador en todos los ficheros generados."

Esperar respuesta. No inferir el nombre del directorio sin confirmación explícita.

---

**Paso 2 — Crear la estructura de carpetas**

Crear los siguientes directorios si no existen:

```
.claude/agents/
docs/
progress/
agents/output/
```

---

**Paso 3 — Generar los ficheros desde las plantillas**

Para cada plantilla en `references/templates/`, leer su contenido y escribir el fichero final en la raíz del proyecto sustituyendo todas las ocurrencias de `{{PROJECT_NAME}}` por el nombre real del proyecto.

Las plantillas se cargan en este orden:

1. `CLAUDE.md.tmpl` → `CLAUDE.md`
2. `AGENTS.md.tmpl` → `AGENTS.md`
3. `CHECKPOINTS.md.tmpl` → `CHECKPOINTS.md`
4. `feature_list.json.tmpl` → `feature_list.json`
5. `init.sh.tmpl` → `init.sh` (marcar como ejecutable con `chmod +x`)
6. `agents/leader.md.tmpl` → `.claude/agents/leader.md`
7. `agents/implementer.md.tmpl` → `.claude/agents/implementer.md`
8. `agents/reviewer.md.tmpl` → `.claude/agents/reviewer.md`
9. `docs/architecture.md.tmpl` → `docs/architecture.md`
10. `docs/conventions.md.tmpl` → `docs/conventions.md`
11. `docs/best-practices.md.tmpl` → `docs/best-practices.md`
12. `docs/verification.md.tmpl` → `docs/verification.md`
13. `progress/current.md.tmpl` → `progress/current.md`
14. `progress/history.md.tmpl` → `progress/history.md`
15. `progress/errors.md.tmpl` → `progress/errors.md`

---

**Paso 4 — Verificar que todos los ficheros fueron creados**

Comprobar que los 15 ficheros del paso anterior existen y no están vacíos. Si alguno falta o está vacío, reportar exactamente cuál y regenerarlo.

---

**Paso 5 — Informar al usuario de qué editar antes de empezar**

Una vez generada la estructura, comunicar al usuario los tres ficheros que requieren edición manual antes de que `init.sh` pase sin errores:

| Fichero | Por qué editarlo |
|---------|-----------------|
| `docs/architecture.md` | Define la visión del sistema y sus componentes. Sin esto, los agentes no tienen contexto de qué están construyendo. |
| `docs/conventions.md` | Define naming, estructura y estilo. El implementer lo lee antes de escribir cualquier código. |
| `docs/best-practices.md` | Define las reglas que aplican a todas las tareas. El leader las consulta en cada sesión. |

---

**Paso 6 — Sugerir ejecutar init.sh**

Indicar al usuario que puede verificar el estado del harness en cualquier momento ejecutando:

```bash
bash init.sh
```

`init.sh` comprueba que todos los ficheros críticos existen, que `feature_list.json` es JSON válido, que no hay más de una tarea en `in_progress`, y que los ficheros de contenido mínimo han sido editados. El leader lo ejecuta automáticamente al inicio de cada sesión.

---

## Estructura generada

```
./
├── CLAUDE.md                        # Rol y reglas del leader en este proyecto
├── AGENTS.md                        # Mapa de agentes: roles, flujo y ficheros de estado
├── CHECKPOINTS.md                   # Criterios de validación que usa el reviewer
├── feature_list.json                # Backlog de features con estado, priority y dependencias
├── init.sh                          # Script de verificación del entorno (ejecutar al inicio)
│
├── .claude/
│   └── agents/
│       ├── leader.md                # Instrucciones detalladas del agente leader
│       ├── implementer.md           # Instrucciones detalladas del agente implementer
│       └── reviewer.md              # Instrucciones detalladas del agente reviewer
│
├── docs/
│   ├── architecture.md              # Visión, componentes y decisiones de diseño ⚠️ editar
│   ├── conventions.md               # Naming, estructura, estilo y formato de commits ⚠️ editar
│   ├── best-practices.md            # Buenas prácticas obligatorias en todas las tareas ⚠️ editar
│   └── verification.md              # Cómo ejecutar tests y documentar verificaciones
│
├── progress/
│   ├── current.md                   # Estado vivo de la sesión activa
│   ├── history.md                   # Bitácora append-only de todas las sesiones
│   └── errors.md                    # Bitácora de errores y soluciones documentadas
│
└── agents/
    └── output/                      # Outputs de implementer y reviewer por tarea
```

Los ficheros marcados con ⚠️ requieren edición manual antes de ejecutar `init.sh`.

---

## Referencias

Las plantillas fuente de todos los ficheros generados están en:

```
references/templates/
```

La Skill las carga bajo demanda durante el Paso 3, una a una, en el orden listado. No se cargan todas en memoria de antemano. Si una plantilla no existe o no puede leerse, la Skill reporta el error y detiene la generación en ese punto.
