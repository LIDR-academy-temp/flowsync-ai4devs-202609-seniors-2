#!/usr/bin/env bash
# Hook PreToolUse (matcher Bash) de Claude Code: datos-que-no-salen.
#
# Antes de un `git commit`, mira las líneas añadidas de lo que va a entrar y
# bloquea (código 2) si encuentra:
#   1. una clave con forma reconocible (AWS, Anthropic, GitHub, Google, Slack,
#      bloque de clave privada PEM, o una línea APP_KEY con valor);
#   2. un correo cuyo dominio no sea uno reservado para ejemplos (o github.com);
#   3. un fichero llamado exactamente `.env`, en cualquier carpeta.
#
# Cada bloqueo deja una línea en docs/seguridad/registro-de-bloqueos.md con la
# fecha UTC, la regla y el archivo. Nunca el valor encontrado: repetirlo en el
# registro sería otra copia del dato.
#
# Con cualquier otro comando, o si no encuentra nada, sale con 0 sin escribir.

set -uo pipefail

entrada=$(cat)
comando=$(jq -r '.tool_input.command // empty' <<<"$entrada" 2>/dev/null) || exit 0
cwd=$(jq -r '.cwd // empty' <<<"$entrada" 2>/dev/null) || cwd=''
[[ -n "$cwd" && -d "$cwd" ]] || cwd=$PWD

[[ "$comando" == *"git commit"* ]] || exit 0

raiz=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || exit 0
g() { git -C "$raiz" -c core.quotePath=false "$@" 2>/dev/null; }

hace_add=0
[[ "$comando" == *"git add"* ]] && hace_add=1

trabajo=$(mktemp -d) || exit 0
trap 'rm -rf "$trabajo"' EXIT
lineas="$trabajo/lineas"   # registros "archivo<US>contenido" de cada línea añadida
ficheros="$trabajo/ficheros"
hallazgos="$trabajo/hallazgos"
: >"$lineas" >"$ficheros" >"$hallazgos"
US=$'\037'

# Extrae las líneas añadidas de un diff unificado, prefijadas con su archivo.
lineas_anadidas() {
  awk '
    /^diff --git /            { cab = 1; f = ""; next }
    cab && /^\+\+\+ /         { f = substr($0, 5); sub(/^b\//, "", f); next }
    cab && /^@@/              { cab = 0; next }
    cab                       { next }
    /^@@/                     { next }
    /^\+/                     { print f "\037" substr($0, 2) }
  '
}

diff_opts=(--no-color --no-ext-diff -U0)

g diff --cached "${diff_opts[@]}" | lineas_anadidas >>"$lineas"
g diff --cached --name-only --diff-filter=ACMR >>"$ficheros"

if ((hace_add)); then
  g diff "${diff_opts[@]}" | lineas_anadidas >>"$lineas"
  g diff --name-only --diff-filter=ACMR >>"$ficheros"
  while IFS= read -r -d '' nuevo; do
    printf '%s\n' "$nuevo" >>"$ficheros"
    [[ -f "$raiz/$nuevo" ]] || continue
    grep -Iq . "$raiz/$nuevo" 2>/dev/null || continue # binario o vacío
    F="$nuevo" awk '{ print ENVIRON["F"] "\037" $0 }' "$raiz/$nuevo" >>"$lineas"
  done < <(g ls-files --others --exclude-standard -z)

  # Un `git add -f` puede preparar un fichero ignorado, que ls-files no lista:
  # se miran también los argumentos de cada `git add` del comando.
  printf '%s\n' "$comando" |
    awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }' |
    grep 'git add' | sed -E 's/.*git add//' | tr -s ' \t' '\n' |
    sed -E "s/^[\"']//; s/[\"')]+\$//" >>"$ficheros"
fi

anota() { printf '%s\t%s\n' "$1" "$2" >>"$hallazgos"; }

# Regla 1: claves con forma reconocible.
R1='(AKIA[0-9A-Z]{16}|sk-ant-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AIza[0-9A-Za-z_-]{35}|xox[bpa]-[A-Za-z0-9-]{8,}|-----BEGIN[A-Z0-9 ]*PRIVATE KEY-----)'
R1_APP="^[[:space:]]*(export[[:space:]]+)?APP_KEY[[:space:]]*=[[:space:]]*[\"']?[^[:space:]\"'#]"

while IFS= read -r registro; do
  anota 1 "${registro%%"$US"*}"
done < <(grep -E "${US}.*${R1}" "$lineas")

while IFS= read -r registro; do
  contenido=${registro#*"$US"}
  grep -Eq "$R1_APP" <<<"$contenido" && anota 1 "${registro%%"$US"*}"
done < <(grep -E "${US}[[:space:]]*(export[[:space:]]+)?APP_KEY" "$lineas")

# Regla 2: correos con un dominio que no está reservado para ejemplos.
R2='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
while IFS= read -r registro; do
  archivo=${registro%%"$US"*}
  contenido=${registro#*"$US"}
  while IFS= read -r correo; do
    dominio=$(tr '[:upper:]' '[:lower:]' <<<"${correo##*@}")
    case "$dominio" in
      example.com | example.org | example.net | github.com) ;;
      *) anota 2 "$archivo" ;;
    esac
  done < <(grep -oE "$R2" <<<"$contenido")
done < <(grep -E "${US}.*${R2}" "$lineas")

# Regla 3: un fichero llamado exactamente `.env`.
while IFS= read -r ruta; do
  [[ "${ruta##*/}" == ".env" ]] && anota 3 "$ruta"
done <"$ficheros"

[[ -s "$hallazgos" ]] || exit 0

# Hay bloqueo: avisa por stderr y deja una línea por hallazgo en el registro.
nombre() {
  case "$1" in
    1) echo 'regla 1 (clave con forma reconocible)' ;;
    2) echo 'regla 2 (correo de una persona, dominio no reservado)' ;;
    3) echo 'regla 3 (fichero .env)' ;;
  esac
}
registro_md="$raiz/docs/seguridad/registro-de-bloqueos.md"
mkdir -p "${registro_md%/*}"
[[ -f "$registro_md" ]] ||
  printf '# Registro de bloqueos del hook datos-que-no-salen\n\n' >"$registro_md"
ahora=$(date -u +%Y-%m-%dT%H:%M:%SZ)

{
  echo "datos-que-no-salen: commit BLOQUEADO."
  sort -u "$hallazgos" | while IFS=$'\t' read -r regla archivo; do
    echo "  - $(nombre "$regla") en ${archivo}"
    printf -- '- %s BLOQUEADO %s en `%s`\n' "$ahora" "$(nombre "$regla")" "$archivo" >>"$registro_md"
  done
  echo "Sustituye el dato por uno inventado (un correo de example.com, una clave falsa"
  echo "sin forma real, o saca el .env del commit) y vuelve a intentarlo."
  echo "No desactives ni te saltes este hook. El bloqueo ha quedado anotado en"
  echo "docs/seguridad/registro-de-bloqueos.md, que se commitea con el resto."
} >&2

exit 2
