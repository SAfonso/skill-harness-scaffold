# Verificación — public-data-pipeline

Guía de verificación para el implementer y el reviewer. Define cómo demostrar que una fase del pipeline funciona correctamente.

---

## Cómo ejecutar los tests

```bash
# Todos los tests
pytest tests/ -v

# Tests de una fase específica
pytest tests/test_downloader.py -v
pytest tests/test_parser.py -v
pytest tests/test_storage.py -v
pytest tests/test_exporter.py -v

# Con reporte de cobertura
pytest tests/ -v --cov=src --cov-report=term-missing

# Linter
flake8 src/ tests/
```

Los tests deben usar datos de muestra locales (fixtures), no descargar datos reales durante la ejecución. El downloader puede mockearse con `unittest.mock` o con un fichero CSV de muestra en `tests/fixtures/`.

---

## Conteo de registros — verificación por fase

El reviewer verifica el recuento de registros en cada fase:

```bash
# Contar registros en raw (sin cabecera)
python3 -c "
import csv
with open('data/raw/municipios.csv') as f:
    print(f'raw: {sum(1 for _ in csv.reader(f)) - 1} registros')
"

# Contar registros en clean
python3 -c "
import csv
with open('data/clean/municipios.csv') as f:
    print(f'clean: {sum(1 for _ in csv.reader(f)) - 1} registros')
"

# Contar filas en SQLite
python3 -c "
import sqlite3
conn = sqlite3.connect('data/pipeline.db')
n = conn.execute('SELECT COUNT(*) FROM municipios').fetchone()[0]
print(f'sqlite: {n} registros')
conn.close()
"

# Contar registros en export
python3 -c "
import json
with open('data/export/municipios.json') as f:
    print(f'json export: {len(json.load(f))} registros')
"
```

Si los números no son coherentes entre fases (salvo descarte documentado), es un fallo de integridad.

---

## Validación de schema

```bash
# Verificar columnas y tipos en el CSV limpio
python3 -c "
import csv
EXPECTED = {'codigo_ine', 'nombre', 'provincia', 'comunidad_autonoma'}
with open('data/clean/municipios.csv') as f:
    reader = csv.DictReader(f)
    cols = set(reader.fieldnames or [])
    missing = EXPECTED - cols
    extra = cols - EXPECTED
    if missing: print(f'FALTA columnas: {missing}')
    if extra: print(f'COLUMNAS EXTRA: {extra}')
    if not missing and not extra: print('Schema OK')
"

# Verificar schema en SQLite
python3 -c "
import sqlite3
conn = sqlite3.connect('data/pipeline.db')
cols = {row[1]: row[2] for row in conn.execute('PRAGMA table_info(municipios)')}
print('Columnas SQLite:', cols)
conn.close()
"
```

---

## Verificación de idempotencia

```bash
# Ejecutar la fase dos veces y comparar el output
python src/parser.py  # primera ejecución
cp data/clean/municipios.csv /tmp/municipios_first.csv
python src/parser.py  # segunda ejecución
diff data/clean/municipios.csv /tmp/municipios_first.csv && echo "IDEMPOTENTE" || echo "NO IDEMPOTENTE — revisar"
```

Repetir para cada fase. Si `diff` encuentra diferencias, la fase no es idempotente.

---

## Qué constituye un test válido

- **Usa datos de muestra locales.** Nunca descarga datos reales durante los tests. Los fixtures van en `tests/fixtures/`.
- **Prueba comportamiento, no implementación.** Si se refactoriza el parser sin cambiar su comportamiento, los tests deben seguir pasando.
- **Es determinista.** El mismo input produce siempre el mismo output.
- **Cubre el caso de error más probable.** Para el downloader: fallo de red. Para el parser: campo vacío o encoding incorrecto. Para storage: tabla ya existente.
- **El nombre describe qué falla si el test falla.** Ejemplo: `test_parser_discards_rows_with_empty_codigo_ine`.

---

## Cómo documentar el resultado en progress/impl_<feature>.md

```
## Verificación

**Tests ejecutados:**
pytest tests/test_<fase>.py -v

**Output:**
<output completo de pytest>

**Resultado:** PASS | FAIL

**Linter:**
flake8 src/ tests/
<output — vacío si no hay errores>

**Conteo de registros:**
- raw:   <n> registros
- clean: <n> registros (<n> descartados — motivo: <razón>)
- sqlite: <n> filas
- export: <n> registros

**Idempotencia verificada:** SÍ | NO
<si NO, describir qué cambió entre ejecuciones>

**Tests añadidos:**
- <nombre del test> — <qué verifica>

**Casos no cubiertos:**
- <qué no se pudo cubrir y por qué>
```
