#!/usr/bin/env bash
# init.sh — todo-cli
# Punto de entrada del harness. Verifica que el entorno está en buen estado.
# El leader ejecuta este script al inicio de cada sesión y no continúa si sale con código 1.

set -euo pipefail

PROJECT="todo-cli"
ERRORS=()

# ─── Colores ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# ─── Helpers ────────────────────────────────────────────────────────────────
fail()  { ERRORS+=("$1"); }
warn()  { echo -e "${YELLOW}⚠️  $1${NC}"; }

# ─── 1. VERIFICACIONES DE EXISTENCIA ────────────────────────────────────────

# feature_list.json existe y es JSON válido
if [[ ! -f "feature_list.json" ]]; then
  fail "feature_list.json no existe."
elif ! python3 -c "import json,sys; json.load(open('feature_list.json'))" 2>/dev/null; then
  fail "feature_list.json existe pero no es JSON válido."
else
  # No más de un item con status "in_progress"
  IN_PROGRESS=$(python3 -c "
import json
data = json.load(open('feature_list.json'))
count = sum(1 for f in data.get('features', []) if f.get('status') == 'in_progress')
print(count)
")
  if [[ "$IN_PROGRESS" -gt 1 ]]; then
    fail "feature_list.json tiene $IN_PROGRESS tareas en 'in_progress'. Solo puede haber una."
  fi
fi

# Ficheros críticos
CRITICAL_FILES=(
  "CLAUDE.md"
  "AGENTS.md"
  "CHECKPOINTS.md"
  "docs/best-practices.md"
  "docs/conventions.md"
  "docs/architecture.md"
  "docs/verification.md"
  "progress/current.md"
  "progress/history.md"
  "progress/errors.md"
)

for f in "${CRITICAL_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    fail "Fichero crítico no encontrado: $f"
  fi
done

# Agentes en .claude/agents/
AGENT_FILES=(
  ".claude/agents/leader.md"
  ".claude/agents/implementer.md"
  ".claude/agents/reviewer.md"
)

for f in "${AGENT_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    fail "Fichero de agente no encontrado: $f"
  fi
done

# ─── 2. VERIFICACIONES DE CONTENIDO MÍNIMO ──────────────────────────────────

check_content() {
  local file="$1"
  local label="$2"

  if [[ ! -f "$file" ]]; then
    return
  fi

  if [[ ! -s "$file" ]]; then
    fail "$label ($file) está vacío. Complétalo antes de empezar."
    return
  fi

  if grep -q '{{PROJECT_NAME}}' "$file" 2>/dev/null; then
    fail "$label ($file) todavía contiene el placeholder '{{PROJECT_NAME}}' sin sustituir. Complétalo antes de empezar."
    return
  fi

  if grep -qE '^\*Por definir\.\*$|^_Por definir\._$' "$file" 2>/dev/null; then
    fail "$label ($file) contiene secciones sin completar ('Por definir'). Revísalo antes de empezar."
  fi
}

check_content "docs/architecture.md"    "Arquitectura"
check_content "docs/conventions.md"     "Convenciones"
check_content "docs/best-practices.md"  "Buenas prácticas"

# ─── RESULTADO ──────────────────────────────────────────────────────────────

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo -e "${RED}❌ Harness KO — ${PROJECT}${NC}"
  echo ""
  echo "Se encontraron ${#ERRORS[@]} problema(s) que deben resolverse antes de continuar:"
  echo ""
  for err in "${ERRORS[@]}"; do
    echo -e "  ${RED}•${NC} $err"
  done
  echo ""
  echo "El leader no debe continuar hasta que init.sh salga sin errores."
  exit 1
fi

echo -e "${GREEN}✅ Harness OK — listo para trabajar [${PROJECT}]${NC}"
exit 0
