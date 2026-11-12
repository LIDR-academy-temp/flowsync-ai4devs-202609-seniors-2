#!/usr/bin/env bash
# Hook PreToolUse (Bash): datos-que-no-salen.
# Impide que un commit meta en el repo una clave, un correo de una persona o un
# fichero .env. Si bloquea, sale con 2, explica por stderr la regla y el archivo
# (nunca el valor) y deja una línea en docs/seguridad/registro-de-bloqueos.md.
# Los patrones exigen el cuerpo de la clave tras el prefijo, para que este
# script y el CLAUDE.md (que nombran los prefijos como texto) no se bloqueen.
set -uo pipefail

cmd=$(jq -r '.tool_input.command // empty')

hay() { printf '%s' "$cmd" | grep -qE "(^|[^[:alnum:]_-])git[[:space:]]+$1([^[:alnum:]_-]|$)"; }

hay commit || exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0
registro="$CLAUDE_PROJECT_DIR/docs/seguridad/registro-de-bloqueos.md"

# --- Qué entra: líneas añadidas por archivo ("archivo<TAB>línea") y nombres ---
lineas_diff() {
  # Convierte un diff unificado en "archivo<TAB>línea añadida".
  awk '
    /^\+\+\+ / { f = substr($0, 5); sub(/^b\//, "", f); next }
    /^\+/      { if (f != "/dev/null") print f "\t" substr($0, 2) }
  '
}

anadidas=$(git diff --cached --no-color --unified=0 | lineas_diff)
nombres=$(git diff --cached --name-only --diff-filter=ACMR)

if hay add; then
  anadidas+=$'\n'$(git diff --no-color --unified=0 | lineas_diff)
  nombres+=$'\n'$(git diff --name-only --diff-filter=ACMR)
  nuevos=$(git ls-files --others --exclude-standard)
  # Con -f/--force, git add también mete ficheros ignorados.
  if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+add[^;&|]*[[:space:]](-f|--force)([[:space:]]|$)'; then
    nuevos+=$'\n'$(git ls-files --others --ignored --exclude-standard)
  fi
  nombres+=$'\n'$nuevos
  while IFS= read -r f; do
    [ -n "$f" ] && [ -f "$f" ] || continue
    grep -Iq . "$f" 2>/dev/null || continue   # binario o vacío
    anadidas+=$'\n'$(awk -v f="$f" '{ print f "\t" $0 }' "$f")
  done <<< "$nuevos"
fi

# --- Reglas ---
clave='AKIA[0-9A-Z]{16}|sk-ant-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|AIza[0-9A-Za-z_-]{35}|xox[bpa]-[0-9A-Za-z-]{10,}|-----BEGIN( [A-Z0-9]+)* PRIVATE KEY-----|^[[:space:]]*(export[[:space:]]+)?APP_KEY=["'\'']?[^[:space:]"'\''`]'
correo='[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\.)+[A-Za-z]{2,}'

hallazgos=""   # "regla<TAB>archivo", uno por línea

while IFS=$'\t' read -r f linea; do
  [ -n "${f:-}" ] || continue
  if printf '%s\n' "$linea" | grep -qE -- "$clave"; then
    hallazgos+="clave"$'\t'"$f"$'\n'
  fi
  dominios=$(printf '%s\n' "$linea" | grep -oE -- "$correo" | sed 's/.*@//' | tr '[:upper:]' '[:lower:]')
  while IFS= read -r d; do
    case "$d" in
      ""|example.com|example.org|example.net|github.com) ;;
      *) hallazgos+="correo"$'\t'"$f"$'\n' ;;
    esac
  done <<< "$dominios"
done <<< "$anadidas"

while IFS= read -r f; do
  [ "$(basename -- "${f:-x}")" = ".env" ] && hallazgos+="env"$'\t'"$f"$'\n'
done <<< "$nombres"

hallazgos=$(printf '%s' "$hallazgos" | grep -v '^$' | sort -u)
[ -z "$hallazgos" ] && exit 0

# --- Bloqueo: stderr y registro, sin el valor ---
describe() {
  case "$1" in
    clave)  echo "una clave o secreto con forma reconocible" ;;
    correo) echo "una dirección de correo de un dominio que no es de ejemplo" ;;
    env)    echo "un fichero .env" ;;
  esac
}

mkdir -p "$(dirname "$registro")"
[ -f "$registro" ] || echo "# Registro de bloqueos del hook datos-que-no-salen" > "$registro"

ahora=$(date -u +%Y-%m-%dT%H:%M:%SZ)
{
  echo "datos-que-no-salen: commit bloqueado."
  while IFS=$'\t' read -r regla f; do
    echo "- regla '$regla' ($(describe "$regla")) en $f"
    echo "- $ahora BLOQUEADO regla=$regla archivo=$f" >> "$registro"
  done <<< "$hallazgos"
  echo "Sustituye el dato por uno inventado que cumpla las reglas (por ejemplo, un correo de example.com) o saca el archivo del commit, y vuelve a intentarlo. No desactives ni te saltes este hook."
} >&2

exit 2
