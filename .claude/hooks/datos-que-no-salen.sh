#!/usr/bin/env bash
# Hook PreToolUse (matcher Bash): impide que un commit lleve datos que no deben salir.
#
# Tres reglas, y solo estas tres:
#   1. clave con forma reconocible
#   2. correo cuyo dominio no sea example.com, example.org, example.net ni github.com
#   3. archivo llamado exactamente .env entre los que van al commit (.env.example no cuenta)
#
# Nunca escribe el valor detectado (ni en la salida, ni en el registro, ni aquí).
# Los patrones de clave están escritos con un corchete (p. ej. [t]) para que este mismo
# archivo no coincida con ellos al commitearlo.
set -uo pipefail

entrada=$(cat)
cmd=$(printf '%s' "$entrada" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Solo actúa si el comando contiene "git commit". En cualquier otro caso: silencio y 0.
[[ $cmd =~ git[[:space:]]+commit ]] || exit 0

raiz=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$raiz" || exit 0

# Si el mismo comando incluye "git add", lo que se va a commitear puede no estar aún
# en el índice: se revisan también los cambios sin preparar y los archivos sin seguimiento.
con_add=0
[[ $cmd =~ git[[:space:]]+add ]] && con_add=1

US=$'\037'
registro="docs/seguridad/registro-de-bloqueos.md"

patrones_clave=(
  'AKIA[0-9A-Z]{16}'
  'sk-an[t]-'
  'gh[p]_'
  'github_pa[t]_'
  'AIza[0-9A-Za-z_-]{35}'
  'xox[bpa]-'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
)
patron_app_key="^[[:space:]]*(export[[:space:]]+)?APP_KEY=[\"']?[^[:space:]\"']"
patron_correo='([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})'

hallazgos=()
vistos="|"

registra() { # $1 = nº de regla, $2 = archivo
  local clave="$1|$2"
  case "$vistos" in *"|$clave|"*) return ;; esac
  vistos="$vistos$clave|"
  hallazgos+=("$clave")
}

nombre_regla() {
  case "$1" in
    1) echo "clave con forma reconocible" ;;
    2) echo "correo con dominio no permitido" ;;
    3) echo "archivo .env en el commit" ;;
  esac
}

revisa_linea() { # $1 = archivo, $2 = línea añadida
  local f="$1" l="$2" p resto dominio
  for p in "${patrones_clave[@]}"; do
    if [[ $l =~ $p ]]; then registra 1 "$f"; break; fi
  done
  if [[ $l =~ $patron_app_key ]]; then registra 1 "$f"; fi

  resto="$l"
  while [[ $resto =~ $patron_correo ]]; do
    dominio=$(printf '%s' "${BASH_REMATCH[2]}" | tr 'A-Z' 'a-z')
    case "$dominio" in
      example.com | example.org | example.net | github.com) ;;
      *) registra 2 "$f"; break ;;
    esac
    resto=${resto#*"${BASH_REMATCH[0]}"}
  done
}

revisa_nombre() { # $1 = ruta
  [[ ${1##*/} == ".env" ]] && registra 3 "$1"
}

# Líneas añadidas de un diff, como "archivo<US>línea".
lineas_de_diff() {
  awk '
    /^\+\+\+ / { f = substr($0, 7); next }
    /^\+/      { printf "%s%c%s\n", f, 31, substr($0, 2) }
  '
}

# Contenido de los archivos de texto sin seguimiento, como "archivo<US>línea".
lineas_sin_seguimiento() {
  local f
  while IFS= read -r -d '' f; do
    [[ -f $f && ! -L $f ]] || continue
    grep -Iq . -- "$f" 2>/dev/null || continue
    awk -v f="$f" '{ printf "%s%c%s\n", f, 31, $0 }' "$f"
  done < <(git ls-files -z --others --exclude-standard)
}

revisa_flujo() {
  local f l
  while IFS="$US" read -r f l; do
    revisa_linea "$f" "$l"
  done
}

diff_args=(-U0 --no-color --no-ext-diff --src-prefix=a/ --dst-prefix=b/)

# Archivos que ya están preparados.
revisa_flujo < <(git diff --cached "${diff_args[@]}" | lineas_de_diff)
while IFS= read -r -d '' n; do revisa_nombre "$n"; done \
  < <(git diff --cached --name-only -z --diff-filter=ACMR)

# Con "git add" en el mismo comando: sin preparar y sin seguimiento.
if [[ $con_add -eq 1 ]]; then
  revisa_flujo < <(git diff "${diff_args[@]}" | lineas_de_diff)
  while IFS= read -r -d '' n; do revisa_nombre "$n"; done \
    < <(git diff --name-only -z --diff-filter=ACMR)
  revisa_flujo < <(lineas_sin_seguimiento)
  while IFS= read -r -d '' n; do revisa_nombre "$n"; done \
    < <(git ls-files -z --others --exclude-standard)
fi

[[ ${#hallazgos[@]} -eq 0 ]] && exit 0

# Hay coincidencia: mensaje a stderr y una línea en el registro. Sin el valor detectado.
ahora=$(date -u +%Y-%m-%dT%H:%M:%SZ)
resumen=""
{
  echo "BLOQUEADO por .claude/hooks/datos-que-no-salen.sh: el commit no se ha ejecutado."
  for h in "${hallazgos[@]}"; do
    regla=${h%%|*}
    archivo=${h#*|}
    archivo=${archivo//$'\n'/ }
    echo "  - Regla $regla ($(nombre_regla "$regla")) activada en: $archivo"
    resumen="${resumen:+$resumen; }regla $regla ($(nombre_regla "$regla")) en $archivo"
  done
  echo "Sustituye el dato por uno inventado que cumpla las reglas (correo con example.com,"
  echo "clave de mentira, sin .env en el commit) y vuelve a intentarlo."
  echo "No desactives el hook ni lo esquives."
} >&2

mkdir -p "$(dirname "$registro")"
if [[ ! -f $registro ]]; then
  echo "# Registro de bloqueos de datos-que-no-salen.sh: fecha UTC, BLOQUEADO, regla y archivo (nunca el valor)" > "$registro"
fi
echo "$ahora BLOQUEADO $resumen" >> "$registro"

exit 2
