# AGENTS.md — public-data-pipeline

Este fichero es el mapa de agentes del proyecto. Describe quién hace qué y cuándo. Los detalles completos de cada agente están en `.claude/agents/`.

---

## Agentes

### Leader
Orquesta el trabajo. Lee el estado del proyecto, decide qué fase del pipeline abordar, **SOLO UNA**, lanza subagentes y sintetiza sus resultados. No toca código ni tests directamente. Tiene especial responsabilidad en verificar que las fases del pipeline se implementan en orden y que no se saltan validaciones de datos entre fases.

Instrucciones detalladas: `.claude/agents/leader.md`

### Implementer
Ejecuta cambios en el código. Recibe un objetivo acotado, los archivos afectados y las restricciones aplicables. Escribe el resultado en `agents/output/`. En este proyecto, el implementer debe asegurarse de que cada fase del pipeline es idempotente y no muta los datos raw.

Instrucciones detalladas: `.claude/agents/implementer.md`

### Reviewer
Valida el trabajo del implementer. Comprueba que el resultado cumple los criterios de aceptación y no introduce pérdida de registros, corrupción de datos o ruptura del schema entre fases. Escribe su veredicto en `agents/output/`.

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

1. El **leader** lee el estado del proyecto y determina la siguiente fase del pipeline.
2. Lanza el **implementer** con el objetivo, contexto y restricciones necesarias.
3. El implementer escribe su resultado en `agents/output/implementer_<tarea>.md`.
4. El leader lanza el **reviewer** con el objetivo original, los criterios de `CHECKPOINTS.md` y el resultado del implementer.
5. El reviewer evalúa el resultado:
   - **Si valida:** marca la tarea como `"done"` en `feature_list.json` y escribe el veredicto en `agents/output/reviewer_<tarea>.md`.
   - **Si no valida:** documenta exactamente qué falló en `progress/review_<feature>.md`, devuelve el control al leader con referencia a ese fichero, y **no** cierra la tarea.
6. Si el reviewer no validó, el leader relanza el **implementer** con el contexto del fallo documentado. El ciclo se repite hasta que el reviewer valide.
7. Solo el reviewer puede marcar una tarea como `"done"`. El leader nunca lo hace directamente.

Los agentes nunca se comunican entre sí por el chat. Todo intercambio pasa por archivos.

---

## Cuándo lanzar cada agente

| Situación | Agente |
|---|---|
| Hay que implementar una fase del pipeline (downloader, parser, storage, exporter) | Implementer |
| Hay que escribir o actualizar tests de transformación | Implementer |
| El implementer ha terminado y hay que validar integridad y schema | Reviewer |
| Se sospecha pérdida de registros o corrupción entre fases | Reviewer |
| Hay que decidir el orden de implementación o gestionar el estado | Leader (sin subagentes) |

---

## Ficheros de estado

Todos los agentes deben conocer estos ficheros antes de actuar:

| Fichero | Contenido |
|---|---|
| `feature_list.json` | Lista de features del pipeline con estado y dependencias |
| `progress/current.md` | Fase del pipeline actualmente en curso y su contexto |
| `progress/errors.md` | Bitácora de errores de datos y código encontrados |
| `docs/best-practices.md` | Buenas prácticas de data engineering obligatorias |
