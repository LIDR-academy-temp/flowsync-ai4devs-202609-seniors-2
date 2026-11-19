#!/usr/bin/env bash
# Hook PreToolUse (matcher Bash): datos-que-no-salen
#
# Impide que entren al repositorio, en un commit, tres cosas:
#   1. una clave con forma reconocible (AWS, Anthropic, GitHub, Google, Slack,
#      bloque de clave privada PEM o una línea APP_KEY con valor);
#   2. un correo cuyo dominio no sea uno reservado para ejemplos
#      (example.com, example.org, example.net) ni github.com;
#   3. un fichero llamado exactamente .env, en cualquier carpeta.
#
# Solo actúa si el comando contiene "git commit". Mira las líneas añadidas del
# diff preparado y, si el mismo comando hace "git add", también los cambios sin
# preparar y los archivos nuevos sin seguimiento.
#
# Si encuentra algo: sale con 2, explica por stderr qué regla y en qué archivo,
# y añade una línea a docs/seguridad/registro-de-bloqueos.md (fecha UTC ISO 8601,
# BLOQUEADO, regla y archivo). Nunca escribe el valor encontrado.
# Si no encuentra nada: sale con 0 y no escribe nada.
#
# Los patrones de la regla 1 llevan un carácter entre corchetes a propósito
# (p. ej. "gh[p]_"): así el propio texto de este script no casa consigo mismo
# y el hook puede commitearse sin bloquearse.

set -uo pipefail

entrada=$(cat)
comando=$(printf '%s' "$entrada" | jq -r '.tool_input.command // empty' 2>/dev/null)

case "$comando" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

raiz="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$raiz" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

con_add=0
case "$comando" in
  *"git add"*) con_add=1 ;;
esac

registro_rel="docs/seguridad/registro-de-bloqueos.md"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# --- Líneas añadidas, como "archivo<TAB>línea" -------------------------------
lineas_anadidas() {
  # $@: argumentos extra para git diff (--cached o nada)
  git -c core.quotepath=off diff "$@" --no-color --no-ext-diff -U0 --diff-filter=ACMR 2>/dev/null |
    awk '
      /^diff --git / { en_hunk = 0; archivo = ""; next }
      /^\+\+\+ /     { if (!en_hunk) { archivo = substr($0, 5); sub(/^b\//, "", archivo); next } }
      /^@@/          { en_hunk = 1; next }
      en_hunk && /^\+/ && archivo != "" && archivo != "/dev/null" { print archivo "\t" substr($0, 2) }
    '
}

lineas_anadidas --cached >"$tmp/lineas"
git -c core.quotepath=off diff --cached --name-only --diff-filter=ACMR 2>/dev/null >"$tmp/nombres"

if [ "$con_add" -eq 1 ]; then
  lineas_anadidas >>"$tmp/lineas"
  git -c core.quotepath=off diff --name-only --diff-filter=ACMR 2>/dev/null >>"$tmp/nombres"
  git -c core.quotepath=off ls-files --others --exclude-standard 2>/dev/null >"$tmp/nuevos"
  cat "$tmp/nuevos" >>"$tmp/nombres"
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    grep -Iq . "$f" 2>/dev/null || continue   # binarios y vacíos fuera
    awk -v f="$f" '{ print f "\t" $0 }' "$f" >>"$tmp/lineas"
  done <"$tmp/nuevos"
  # Un .env ignorado por git solo entra si se nombra en el propio comando (git add -f ...).
  set -f   # sin expansión de comodines al trocear el comando
  for palabra in $comando; do
    palabra=${palabra%\"}; palabra=${palabra#\"}; palabra=${palabra%\'}; palabra=${palabra#\'}
    palabra=${palabra%;}
    case "$palabra" in
      .env | */.env) [ -f "$palabra" ] && printf '%s\n' "${palabra#./}" >>"$tmp/nombres" ;;
    esac
  done
  set +f
fi

: >"$tmp/hallazgos"

# --- Regla 1: clave con forma reconocible ------------------------------------
regla1='AKI[A][0-9A-Z]{16}|sk-an[t]-|gh[p]_|github_pa[t]_|AIz[a][0-9A-Za-z_-]{35}|xo[x][bpa]-|-----BEGI[N][A-Z ]*PRIVATE KEY-----|APP_KE[Y]=[[:space:]]*["'"'"']?[^[:space:]#"'"'"']'
grep -E "^[^	]*	.*($regla1)" "$tmp/lineas" | cut -f1 | sort -u |
  while IFS= read -r f; do printf '1\tclave con forma reconocible\t%s\n' "$f"; done >>"$tmp/hallazgos"

# --- Regla 2: correo de un dominio no reservado -------------------------------
awk -F'\t' '
  {
    archivo = $1; l = $0; sub(/^[^\t]*\t/, "", l)
    while (match(l, /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z][A-Za-z]+/)) {
      correo = substr(l, RSTART, RLENGTH); l = substr(l, RSTART + RLENGTH)
      dominio = tolower(substr(correo, index(correo, "@") + 1))
      if (dominio != "example.com" && dominio != "example.org" && dominio != "example.net" && dominio != "github.com")
        print archivo
    }
  }' "$tmp/lineas" | sort -u |
  while IFS= read -r f; do printf '2\tcorreo de un dominio no reservado\t%s\n' "$f"; done >>"$tmp/hallazgos"

# --- Regla 3: fichero .env ----------------------------------------------------
sort -u "$tmp/nombres" | grep -E '(^|/)\.env$' |
  while IFS= read -r f; do printf '3\tfichero .env\t%s\n' "$f"; done >>"$tmp/hallazgos"

[ -s "$tmp/hallazgos" ] || exit 0

# --- Bloqueo: registro y mensaje ----------------------------------------------
sort -u "$tmp/hallazgos" -o "$tmp/hallazgos"
mkdir -p "$(dirname "$registro_rel")"
[ -f "$registro_rel" ] || printf '# Registro de bloqueos del hook datos-que-no-salen (fecha UTC · BLOQUEADO · regla · archivo)\n' >"$registro_rel"
fecha=$(date -u +%Y-%m-%dT%H:%M:%SZ)

{
  echo "datos-que-no-salen: commit BLOQUEADO."
  while IFS=$'\t' read -r n desc f; do
    printf -- '- %s BLOQUEADO regla %s (%s) en %s\n' "$fecha" "$n" "$desc" "$f" >>"$registro_rel"
    printf '  - regla %s (%s) en %s\n' "$n" "$desc" "$f"
  done <"$tmp/hallazgos"
  echo "Sustituye el dato por uno inventado (un correo de example.com, una clave ficticia sin forma real, o saca el .env del commit) y vuelve a intentarlo."
  echo "No desactives ni te saltes este hook. El bloqueo queda anotado en $registro_rel; commitéalo con el resto."
} >&2

exit 2
