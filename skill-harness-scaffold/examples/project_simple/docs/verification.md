# Verificación — todo-cli

Guía de verificación para el implementer y el reviewer. Define cómo demostrar que una feature funciona correctamente y cómo documentar ese resultado.

---

## Cómo ejecutar los tests

```bash
# Todos los tests
pytest tests/ -v

# Tests de un módulo específico
pytest tests/test_tasks.py -v

# Con reporte de cobertura
pytest tests/ -v --cov=src --cov-report=term-missing
```

El implementer ejecuta los tests al terminar la implementación y antes de escribir `progress/impl_<feature>.md`. El reviewer los ejecuta de forma independiente durante la validación.

Verificar también que el código pasa el linter:

```bash
flake8 src/ tests/
```

---

## Verificación manual de la CLI

Además de los tests automatizados, verificar el comportamiento real de la CLI:

```bash
# feat-001: añadir tarea
python src/main.py add "Comprar leche"
# Salida esperada: Tarea añadida: [1] Comprar leche

# feat-002: listar tareas
python src/main.py list
# Salida esperada: [1] [pending] Comprar leche

# feat-003: marcar como completada
python src/main.py done 1
# Salida esperada: Tarea completada: [1] Comprar leche

# Caso de error: id inexistente
python src/main.py done 99
# Salida esperada: Error: tarea 99 no encontrada.
# Código de salida: 1 (verificar con echo $?)
```

---

## Qué constituye un test válido

Un test es válido si cumple todas estas condiciones:

- **Prueba comportamiento, no implementación.** El test verifica qué hace el código, no cómo lo hace internamente.
- **Es determinista.** Produce el mismo resultado en cada ejecución. Los tests no dependen de `tasks.json` del directorio de trabajo — usan fixtures o directorios temporales.
- **Es independiente.** No depende del orden de ejecución ni del estado dejado por otro test.
- **Tiene un solo motivo de fallo.** Si puede fallar por dos razones, dividirlo en dos tests.
- **El nombre describe qué falla si el test falla.** Por ejemplo: `test_add_task_creates_entry_in_storage`, `test_done_with_invalid_id_exits_with_code_1`.

---

## Cómo documentar el resultado en progress/impl_<feature>.md

Al terminar la implementación, añadir una sección de verificación al final del fichero:

```
## Verificación

**Tests ejecutados:**
pytest tests/ -v

**Output:**
<output completo de pytest>

**Resultado:** PASS | FAIL

**Linter:**
flake8 src/ tests/
<output — vacío si no hay errores>

**Verificación manual:**
<comandos ejecutados y salida obtenida>

**Tests añadidos:**
- test_<nombre> — <qué verifica>

**Casos no cubiertos:**
- <qué no se pudo cubrir y por qué>
```

Si el resultado es `FAIL`, el implementer documenta qué falló y devuelve el control al leader antes de intentar corregirlo.
