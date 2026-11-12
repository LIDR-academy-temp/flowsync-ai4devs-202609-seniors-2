#!/usr/bin/env bash
#
# datos-que-no-salen: hook PreToolUse (matcher Bash) de Claude Code.
#
# Antes de un `git commit` mira las líneas añadidas de lo que va a entrar y lo
# bloquea si encuentra una de estas tres cosas, y solo estas tres:
#
#   1. Una clave con forma reconocible (AWS, Anthropic, GitHub, Google, Slack,
#      un bloque de clave privada o la clave de la aplicación con valor).
#   2. Un correo cuyo dominio no sea uno de los reservados para ejemplos.
#   3. Un archivo llamado exactamente `.env`, en cualquier carpeta.
#
# Si bloquea: sale con 2, dice por la salida de error qué regla y qué archivo,
# y añade una línea al registro. NUNCA escribe el valor encontrado, ni en la
# salida ni en el registro: repetirlo sería otra copia del dato.
# Con cualquier otro comando, o si no encuentra nada: sale con 0 y en silencio.
#
# Los patrones de abajo están escritos para no coincidir consigo mismos (clases
# de un solo carácter, cuantificadores en vez de guiones repetidos): así este
# archivo puede entrar en un commit sin que el hook se bloquee a sí mismo.

set -uo pipefail

REGISTRO='docs/seguridad/registro-de-bloqueos.md'
TAB=$'\t'

# --- ¿Es un `git commit`? ----------------------------------------------------
# El comando llega en `.tool_input.command` del JSON de la entrada estándar,
# igual que lo lee el hook de Prettier.

comando=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0

es_commit='git[[:space:]]+commit'
[[ $comando =~ $es_commit ]] || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
raiz=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$raiz" || exit 0

# Si el mismo comando hace `git add`, lo que va a entrar todavía puede no estar
# en el índice: hay que mirar también lo no preparado y lo nuevo sin seguimiento.
con_add=0
es_add='git[[:space:]]+add'
[[ $comando =~ $es_add ]] && con_add=1

# --- Qué va a entrar ----------------------------------------------------------

# `--diff-filter=d`: lo que se borra no entra. Los prefijos se fijan para que la
# configuración de git de cada cual no cambie la forma de la cabecera.
diff_git() {
  git -c core.quotepath=off diff --no-color --no-ext-diff \
    --src-prefix=a/ --dst-prefix=b/ --diff-filter=d "$@"
}

sin_seguimiento() {
  git -c core.quotepath=off ls-files --others --exclude-standard "$@"
}

# De un diff, deja solo las líneas añadidas, cada una como «archivo<TAB>línea».
solo_anadidas() {
  awk '
    /^diff --git / { en_hunk = 0; next }
    !en_hunk && /^\+\+\+ / {
      archivo = substr($0, 5)
      sub(/^b\//, "", archivo)
      sub(/\t$/, "", archivo)
      next
    }
    /^@@/ { en_hunk = 1; next }
    en_hunk && /^\+/ { print archivo "\t" substr($0, 2) }
  '
}

# Un archivo nuevo entra entero: todas sus líneas son líneas añadidas.
lineas_de_los_nuevos() {
  local f
  while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    LC_ALL=C grep -Iq '' -- "$f" 2>/dev/null || continue # binarios y vacíos, fuera
    ARCHIVO="$f" awk '{ print ENVIRON["ARCHIVO"] "\t" $0 }' "$f"
  done < <(sin_seguimiento -z)
}

lineas=$(
  diff_git --cached -U0 | solo_anadidas
  if [ "$con_add" -eq 1 ]; then
    diff_git -U0 | solo_anadidas
    lineas_de_los_nuevos
  fi
)

nombres=$(
  diff_git --cached --name-only
  if [ "$con_add" -eq 1 ]; then
    diff_git --name-only
    sin_seguimiento
  fi
)

# --- Las tres reglas ----------------------------------------------------------

# Regla 1. Claves con forma reconocible.
claves='AKIA[0-9A-Z]{16}|sk-ant[-]|gh[p]_|github_pa[t]_|AIza[0-9A-Za-z_-]{35}|xox[bpa]-|-{5}BEGIN ([A-Z0-9]+ )*PRIVATE KEY-{5}'
# La clave de la aplicación, solo si la línea empieza por ella y trae valor.
clave_app="^[^${TAB}]*${TAB}[[:space:]]*(export[[:space:]]+)?APP_KEY=[[:space:]]*[\"']?[^\"'[:space:]]"

regla_1() {
  LC_ALL=C grep -E -e "$claves" -e "$clave_app" <<<"$lineas" | cut -f1
}

# Regla 2. Correos cuyo dominio no está en la lista. Se extrae cada dirección
# y se compara su dominio exacto, en minúsculas.
regla_2() {
  LC_ALL=C awk -F'\t' '
    {
      archivo = $1
      resto = substr($0, length($1) + 2)
      while (match(resto, /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z][A-Za-z]+/)) {
        correo = substr(resto, RSTART, RLENGTH)
        resto = substr(resto, RSTART + RLENGTH)
        dominio = tolower(substr(correo, index(correo, "@") + 1))
        if (dominio != "example.com" && dominio != "example.org" &&
            dominio != "example.net" && dominio != "github.com") {
          print archivo
          break
        }
      }
    }
  ' <<<"$lineas"
}

# Regla 3. Un archivo llamado exactamente `.env`. Los `.env.example` no cuentan.
regla_3() {
  grep -E '(^|/)\.env$' <<<"$nombres"
}

hallazgos=$(
  {
    regla_1 | sed "s/^/1${TAB}/"
    regla_2 | sed "s/^/2${TAB}/"
    regla_3 | sed "s/^/3${TAB}/"
  } | sort -u
)

[ -n "$hallazgos" ] || exit 0

# --- Bloqueo: aviso por la salida de error y línea en el registro -------------

nombre_de_regla() {
  case "$1" in
    1) echo 'regla 1 (clave con forma reconocible)' ;;
    2) echo 'regla 2 (correo con un dominio que no es de ejemplo)' ;;
    3) echo 'regla 3 (archivo .env)' ;;
  esac
}

fecha=$(date -u +%Y-%m-%dT%H:%M:%SZ)

mkdir -p "$(dirname "$REGISTRO")"
[ -f "$REGISTRO" ] || printf '# Registro de bloqueos del hook datos-que-no-salen\n\n' >"$REGISTRO"

{
  echo 'datos-que-no-salen: commit BLOQUEADO.'
  while IFS="$TAB" read -r regla archivo; do
    echo "  - $(nombre_de_regla "$regla"), en el archivo: $archivo"
    printf -- '- %s BLOQUEADO %s archivo: %s\n' \
      "$fecha" "$(nombre_de_regla "$regla")" "$archivo" >>"$REGISTRO"
  done <<<"$hallazgos"
  echo 'Sustituye el dato por uno inventado (o saca el archivo .env del commit) y vuelve a intentarlo.'
  echo "El bloqueo queda anotado en $REGISTRO, sin el valor."
} >&2

exit 2
