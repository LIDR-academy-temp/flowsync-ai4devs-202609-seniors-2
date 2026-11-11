#!/usr/bin/env bash
# PreToolUse (Bash): bloquea `git commit` si lo que entra lleva claves, correos
# reales o un `.env`. Sale con 2 (bloqueo) o con 0. Nunca imprime ni registra
# el valor detectado: solo la regla y el archivo.
#
# Los patrones están escritos de forma que este mismo fichero no se dispare a
# sí mismo (por eso hay literales partidos con comillas vacías).
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty') || exit 0

case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

con_add=0
case "$cmd" in
  *"git add"*) con_add=1 ;;
esac

tab=$'\t'
tmp=$(mktemp -d "${TMPDIR:-/tmp}/datos-que-no-salen.XXXXXX") || exit 0
trap 'rm -rf "$tmp"' EXIT
lineas="$tmp/lineas" # "ruta<TAB>línea añadida"
archivos="$tmp/archivos" # una ruta por línea (archivos que entran)
: >"$lineas"
: >"$archivos"

anadidas() {
  awk '/^\+\+\+ /{f=substr($0,7); next} /^\+/{print f "\t" substr($0,2)}'
}

# Staged
git -c core.quotepath=off diff --cached --no-ext-diff --no-color -U0 | anadidas >>"$lineas"
git -c core.quotepath=off diff --cached --name-only --diff-filter=d >>"$archivos"

if [ "$con_add" -eq 1 ]; then
  # Sin preparar
  git -c core.quotepath=off diff --no-ext-diff --no-color -U0 | anadidas >>"$lineas"
  git -c core.quotepath=off diff --name-only --diff-filter=d >>"$archivos"
  # Nuevos sin seguimiento (todo su contenido cuenta como añadido)
  while IFS= read -r -d '' f; do
    printf '%s\n' "$f" >>"$archivos"
    if grep -Iq . "$f" 2>/dev/null; then
      awk -v f="$f" '{print f "\t" $0}' "$f" >>"$lineas"
    fi
  done < <(git ls-files --others --exclude-standard -z)
fi

# Excepción acordada: `prompts.md` (en la raíz) transcribe prompts literales y
# puede contener claves o correos de ejemplo. Se excluye de las reglas 1 y 2.
awk -F '\t' '$1 != "prompts.md"' "$lineas" >"$lineas.filtrado" && mv "$lineas.filtrado" "$lineas"

hallazgos="$tmp/hallazgos" # "regla<TAB>ruta"
: >"$hallazgos"

# Regla 1: claves reconocibles
r1_comunes='AKIA[0-9A-Z]{16}|sk-an''t-|gh''p_|github''_pat_|AIza[0-9A-Za-z_-]{35}|xox[bpa]-|-----BEGIN [A-Z ]*PRIVATE KEY-----'
grep -E "$tab.*($r1_comunes)" "$lineas" | cut -f1 | sort -u |
  while IFS= read -r f; do printf '1\t%s\n' "$f"; done >>"$hallazgos"
grep -E "$tab[[:space:]]*(export[[:space:]]+)?APP_""KEY=[^[:space:]]" "$lineas" | cut -f1 | sort -u |
  while IFS= read -r f; do printf '1\t%s\n' "$f"; done >>"$hallazgos"

# Regla 2: correos con dominio que no sea de ejemplo
email_re='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
grep -E "$tab.*$email_re" "$lineas" |
  while IFS="$tab" read -r f l; do
    grep -oE "$email_re" <<<"$l" | while IFS= read -r correo; do
      dominio=$(printf '%s' "${correo#*@}" | tr '[:upper:]' '[:lower:]')
      case "$dominio" in
        example.com | example.org | example.net | github.com) ;;
        *) printf '2\t%s\n' "$f" ;;
      esac
    done
  done | sort -u >>"$hallazgos"

# Regla 3: archivo .env (nombre exacto, en cualquier carpeta)
sort -u "$archivos" | while IFS= read -r f; do
  [ "${f##*/}" = ".env" ] && printf '3\t%s\n' "$f"
done >>"$hallazgos"

[ -s "$hallazgos" ] || exit 0

registro="$root/docs/seguridad/registro-de-bloqueos.md"
mkdir -p "$(dirname "$registro")"
[ -f "$registro" ] || printf '# Registro de bloqueos de datos que no salen\n' >"$registro"

ahora=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sort -u "$hallazgos" | while IFS="$tab" read -r regla f; do
  case "$regla" in
    1) nombre="regla 1 (clave reconocible)" ;;
    2) nombre="regla 2 (correo con dominio real)" ;;
    3) nombre="regla 3 (archivo .env)" ;;
  esac
  printf 'BLOQUEADO: %s en %s. Sustituye el dato por uno inventado (p. ej. ada@example.com) o saca el archivo del commit.\n' "$nombre" "$f" >&2
  printf '%s BLOQUEADO %s %s\n' "$ahora" "$nombre" "$f" >>"$registro"
done

exit 2
