# Buenas prácticas — todo-cli

Estas prácticas aplican a todas las tareas sin excepción. El leader las tiene en cuenta al planificar; el implementer, al ejecutar; el reviewer, al validar.

---

## Una tarea a la vez

Solo puede haber una tarea en `"in_progress"` en `feature_list.json` en cualquier momento. Si durante una implementación surge trabajo adicional fuera del scope, se documenta y se devuelve el control al leader. No se implementa nada que no esté en el scope de la tarea activa.

## Documentar antes de implementar

Antes de escribir código, el implementer debe leer `progress/impl_<feature>.md` si existe, entender el contexto previo, y tener clara la solución que va a aplicar. Implementar sin entender el estado previo está prohibido.

## Tests antes de marcar done

Ninguna tarea puede marcarse como `"done"` sin que `pytest tests/ -v` pase sin errores. Si no hay tests para la funcionalidad implementada, el implementer debe escribirlos como parte de la tarea.

## No asumir — preguntar si hay ambigüedad

Si el enunciado de una tarea es ambiguo o contradictorio, el implementer no asume una interpretación y avanza. Para, documenta la ambigüedad en `progress/impl_<feature>.md`, y devuelve el control al leader para que consulte al usuario.

## Dejar el código mejor de como se encontró

Cualquier fichero que se modifique debe quedar en mejor estado que antes: sin código muerto, sin imports sin usar, sin comentarios obsoletos. El scope de la mejora es el fichero tocado, no el proyecto entero.

## Consultar progress/errors.md antes de resolver cualquier error

Antes de investigar un error, verificar si ya está documentado en `progress/errors.md`. Si tiene solución documentada, aplicarla directamente. Si es nuevo, documentarlo antes de continuar.

## El reviewer es la única fuente de verdad sobre si una tarea está done

El implementer no decide que su trabajo está correcto. El leader no decide que el trabajo del implementer está correcto. Solo el reviewer, tras verificar cada criterio de `CHECKPOINTS.md`, puede cerrar una tarea.

## Verificar con flake8 antes de entregar

El implementer ejecuta `flake8 src/ tests/` antes de escribir `progress/impl_<feature>.md`. Si hay errores de estilo, los corrige antes de reportar el trabajo como terminado.
