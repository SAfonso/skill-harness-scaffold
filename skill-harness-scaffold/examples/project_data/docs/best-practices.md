# Buenas prácticas — public-data-pipeline

Estas prácticas aplican a todas las tareas sin excepción. El leader las tiene en cuenta al planificar; el implementer, al ejecutar; el reviewer, al validar.

---

## Una tarea a la vez

Solo puede haber una tarea en `"in_progress"` en `feature_list.json` en cualquier momento. Si durante una implementación surge trabajo adicional fuera del scope, se documenta y se devuelve el control al leader.

## Documentar antes de implementar

Antes de escribir código, el implementer debe leer `progress/impl_<feature>.md` si existe y tener clara la solución que va a aplicar. En pipelines de datos, implementar sin entender el estado previo puede introducir transformaciones silenciosamente incorrectas.

## Tests antes de marcar done

Ninguna tarea puede marcarse como `"done"` sin que `pytest tests/ -v` pase sin errores. Los tests de pipeline deben incluir al menos: un test de happy path con datos de muestra reales, un test de idempotencia, y un test del caso de error más probable (fichero no encontrado, campo vacío, encoding incorrecto).

## No asumir — preguntar si hay ambigüedad

Si el enunciado de una tarea es ambiguo (¿qué hacer con registros duplicados? ¿qué encoding tiene el CSV?), el implementer para, documenta la ambigüedad en `progress/impl_<feature>.md` y devuelve el control al leader. Una decisión implícita incorrecta en un pipeline puede propagarse silenciosamente a todas las fases posteriores.

## No mutar datos raw

`data/raw/` es inmutable. Ninguna fase del pipeline escribe, modifica ni elimina ficheros en ese directorio. Si se necesita transformar un fichero raw, el resultado va a `data/clean/`. Esta regla no tiene excepciones.

## Idempotencia en cada fase

Cada fase del pipeline debe producir el mismo resultado si se ejecuta una o diez veces con los mismos datos de entrada. Antes de marcar una tarea como terminada, verificar ejecutando la fase dos veces y comprobando que el output es idéntico.

## Validar el recuento de registros entre fases

En cada fase que transforma datos, documentar en `progress/impl_<feature>.md`:
- Cuántos registros entraron.
- Cuántos registros salieron.
- Cuántos se descartaron y por qué.

Si el recuento no cuadra y no hay una razón documentada, es un bug.

## Consultar progress/errors.md antes de resolver cualquier error

Antes de investigar un error, verificar si ya está documentado en `progress/errors.md`. Los errores de datos (encodings inesperados, campos mal formateados) tienden a repetirse entre fases — consultar el histórico evita investigar dos veces el mismo problema.

## Dejar el código mejor de como se encontró

Cualquier fichero que se modifique debe quedar en mejor estado: sin imports sin usar, sin funciones muertas, sin comentarios obsoletos. El scope de la mejora es el fichero tocado, no el proyecto entero.

## El reviewer es la única fuente de verdad sobre si una tarea está done

El implementer no decide que su trabajo está correcto. Solo el reviewer, tras verificar cada criterio de `CHECKPOINTS.md` incluyendo los de integridad de datos, puede cerrar una tarea.
