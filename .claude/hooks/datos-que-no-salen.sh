#!/usr/bin/env bash
# Hook PreToolUse (matcher Bash) de Claude Code: datos-que-no-salen.
#
# Antes de un `git commit`, revisa las líneas añadidas que van a entrar en el
# commit y lo bloquea (exit 2) si encuentra:
#   1) una clave con forma reconocible (AWS, Anthropic, GitHub, Google, Slack,
#      clave privada PEM) o una línea APP_KEY con valor;
#   2) un correo cuyo dominio no sea example.com/.org/.net ni github.com;
#   3) un archivo llamado exactamente .env (en cualquier carpeta).
#
# Cada bloqueo deja UNA línea en docs/seguridad/registro-de-bloqueos.md con la
# fecha, la regla y el archivo. Nunca el valor detectado.
#
# Ojo: los patrones de abajo están escritos de forma que el propio script no
# los cumpla (tras cada prefijo viene un `[`), para poder commitearlo.

set -uo pipefail

input=$(cat)

# El comando está en .tool_input.command. Si jq no está instalado (pasa en Git
# Bash de Windows), se usa el JSON en crudo: solo sirve para decidir si actuar,
# y mirar de más nunca deja pasar un commit que debía revisarse.
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  cmd=$input
fi

# `git commit`, admitiendo opciones globales entre medias (`git -c x=y commit`).
git_sub() {
  printf '%s\n' "$cmd" | grep -qE "git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+$1([^-[:alnum:]_]|\$)"
}
git_sub commit || exit 0

# safe.directory: en Windows el repo vive en WSL con otro propietario y git se
# niega a leerlo sin esto. Las llamadas de aquí son todas de solo lectura.
g() { git -c safe.directory='*' -c core.quotePath=false "$@"; }

# En Windows llega como ruta UNC (\\wsl.localhost\...), que Git Bash solo
# entiende con barras normales.
if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then cd "${CLAUDE_PROJECT_DIR//\\//}" 2>/dev/null || true; fi
root=$(g rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

tmp=$(mktemp -d) || exit 0
trap 'rm -rf "$tmp"' EXIT
lines="$tmp/lines"   # "archivo<TAB>línea añadida"
names="$tmp/names"   # archivos que van al commit
: >"$lines"
: >"$names"

added_lines() {
  awk '/^\+\+\+ /{ f = substr($0, 5); sub(/^b\//, "", f); next }
       /^\+/   { print f "\t" substr($0, 2) }'
}

g diff --cached --no-color --no-ext-diff -U0 2>/dev/null | added_lines >>"$lines"
g diff --cached --name-only --diff-filter=d 2>/dev/null >>"$names"

if git_sub add; then
  # El `git add` del mismo comando aún no se ha ejecutado: se mira también lo
  # que todavía no está preparado y lo que git aún no sigue.
  g diff --no-color --no-ext-diff -U0 2>/dev/null | added_lines >>"$lines"
  g diff --name-only --diff-filter=d 2>/dev/null >>"$names"
  while IFS= read -r f; do
    printf '%s\n' "$f" >>"$names"
    [ -f "$f" ] && grep -Iq . "$f" 2>/dev/null &&
      awk -v f="$f" '{ print f "\t" $0 }' "$f" >>"$lines"
  done < <(g ls-files --others --exclude-standard 2>/dev/null)
  # Un `.env` ignorado solo entra forzado (`git add -f ruta/.env`): se busca
  # también en las palabras del propio comando.
  printf '%s\n' "$cmd" | tr -s ' \t;&|()"\\' '\n' | sed "s/'//g" >>"$names"
fi

hits="$tmp/hits"
: >"$hits"

# Regla 1: clave reconocible.
r1='AKIA[[:alnum:]]{16}|sk-ant-[[:alnum:]_-]+|ghp_[[:alnum:]]+|github_pat_[[:alnum:]_]+|AIza[[:alnum:]_-]{35}|xox[bpa]-[[:alnum:]-]+|-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY-----'
r1_app=$'\t''[[:space:]]*(export[[:space:]]+)?APP_KEY[[:space:]]*=[[:space:]]*["'\'']?[^[:space:]"'\''#]'
grep -E $'\t.*('"$r1"')|'"$r1_app" "$lines" | cut -f1 | sort -u |
  sed 's/^/regla 1 (clave reconocible)\t/' >>"$hits"

# Regla 2: correo con dominio que no es de ejemplo.
awk '{
  f = $0; sub(/\t.*/, "", f); line = substr($0, index($0, "\t") + 1)
  while (match(line, /[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z][A-Za-z]+/)) {
    e = substr(line, RSTART, RLENGTH); d = tolower(substr(e, index(e, "@") + 1))
    if (d != "example.com" && d != "example.org" && d != "example.net" && d != "github.com") { print f; break }
    line = substr(line, RSTART + RLENGTH)
  }
}' "$lines" | sort -u | sed 's/^/regla 2 (correo con dominio real)\t/' >>"$hits"

# Regla 3: archivo llamado exactamente .env.
grep -E '(^|/)\.env$' "$names" | sort -u | sed 's/^/regla 3 (archivo .env)\t/' >>"$hits"

[ -s "$hits" ] || exit 0

{
  echo "datos-que-no-salen: commit BLOQUEADO."
  while IFS=$'\t' read -r regla archivo; do
    echo "  - $regla en $archivo"
  done <"$hits"
  echo "Sustituye el dato por uno inventado (correos @example.com, claves de mentira;"
  echo "un .env no se commitea: usa .env.example) y vuelve a intentar el commit."
  echo "No desactives ni te saltes este hook."
} >&2

log=docs/seguridad/registro-de-bloqueos.md
mkdir -p "$(dirname "$log")"
[ -f "$log" ] || echo '# Registro de bloqueos del hook datos-que-no-salen' >"$log"
detalle=$(awk -F'\t' '{ printf "%s%s · archivo: %s", (NR > 1 ? "; " : ""), $1, $2 }' "$hits")
echo "- $(date -u +%Y-%m-%dT%H:%M:%SZ) BLOQUEADO · $detalle" >>"$log"

exit 2
