# AGENTS.md — todo-cli

Este fichero es el mapa de agentes del proyecto. Describe quién hace qué y cuándo. Los detalles completos de cada agente están en `.claude/agents/`.

---

## Agentes

### Leader
Orquesta el trabajo. Lee el estado del proyecto, decide qué tarea abordar, **SOLO UNA**, lanza subagentes y sintetiza sus resultados. No toca código ni tests directamente.

Instrucciones detalladas: `.claude/agents/leader.md`

### Implementer
Ejecuta cambios en el código. Recibe un objetivo acotado, los archivos afectados y las restricciones aplicables. Escribe el resultado en `agents/output/`.

Instrucciones detalladas: `.claude/agents/implementer.md`

### Reviewer
Valida el trabajo del implementer. Comprueba que el resultado cumple los criterios de aceptación y no introduce regresiones. Escribe su veredicto en `agents/output/`.

Instrucciones detalladas: `.claude/agents/reviewer.md`

---

## Flujo de trabajo

```
Usuario
  └─► Leader
        └─► Implementer  →  agents/output/implementer_<tarea>.md
                 ↓
             Reviewer    →  agents/output/reviewer_<tarea>.md
                 │
          ¿Valida? ──No──► progress/review_<feature>.md
                 │                      ↓
                Yes               Leader relanza Implementer
                 ↓                (loop hasta validación)
          Marca "done" en feature_list.json
                 ↓
           Leader reporta al usuario
```

1. El **leader** lee el estado del proyecto y determina la siguiente tarea.
2. Lanza el **implementer** con el objetivo, contexto y restricciones necesarias.
3. El implementer escribe su resultado en `agents/output/implementer_<tarea>.md`.
4. El leader lanza el **reviewer** con el objetivo original, los criterios de `CHECKPOINTS.md` y el resultado del implementer.
5. El reviewer evalúa el resultado:
   - **Si valida:** marca la tarea como `"done"` en `feature_list.json` y escribe el veredicto en `agents/output/reviewer_<tarea>.md`.
   - **Si no valida:** documenta exactamente qué falló en `progress/review_<feature>.md`, devuelve el control al leader con referencia a ese fichero, y **no** cierra la tarea.
6. Si el reviewer no validó, el leader relanza el **implementer** con el contexto del fallo documentado. El ciclo leader → implementer → reviewer se repite hasta que el reviewer valide.
7. Solo el reviewer puede marcar una tarea como `"done"`. El leader nunca lo hace directamente.

Los agentes nunca se comunican entre sí por el chat. Todo intercambio pasa por archivos.

---

## Cuándo lanzar cada agente

| Situación | Agente |
|---|---|
| Hay que escribir, modificar o borrar código | Implementer |
| Hay que crear o actualizar archivos de configuración del sistema | Implementer |
| El implementer ha terminado y hay que validar el resultado | Reviewer |
| Se sospecha una regresión o comportamiento inesperado | Reviewer |
| Hay que decidir qué hacer a continuación o gestionar el estado | Leader (sin subagentes) |

---

## Ficheros de estado

Todos los agentes deben conocer estos ficheros antes de actuar:

| Fichero | Contenido |
|---|---|
| `feature_list.json` | Lista de tareas con estado: `pending`, `in_progress`, `done` |
| `progress/current.md` | Descripción de la tarea actualmente en curso y su contexto |
| `progress/errors.md` | Bitácora de errores encontrados y sus soluciones |
| `docs/best-practices.md` | Convenciones y patrones obligatorios del proyecto |
