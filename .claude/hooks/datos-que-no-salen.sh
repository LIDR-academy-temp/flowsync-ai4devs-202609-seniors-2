#!/usr/bin/env bash
# Hook PreToolUse (matcher Bash): bloquea `git commit` si lo que va a entrar
# en el commit lleva una clave reconocible, un correo ajeno a los dominios de
# ejemplo o un archivo `.env`. Sale con 2 (bloquea) o con 0 (deja pasar).
# Nunca imprime ni registra el valor detectado: repetirlo crearía otra copia.
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

# Solo actúa sobre `git commit`; cualquier otro comando pasa sin ruido.
case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

root=${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || true)}
[ -n "$root" ] && cd "$root" || exit 0

# Si el mismo comando hace `git add`, el índice aún no refleja lo que se
# commiteará: hay que mirar también lo no preparado y lo no seguido.
with_add=0
case "$cmd" in
  *"git add"*) with_add=1 ;;
esac

tab=$'\t'

# Salida: "fichero<TAB>línea añadida" para cada línea que entra.
added_from_diff() {
  awk '
    /^\+\+\+ / { f = ($0 == "+++ /dev/null") ? "" : substr($0, 7); next }
    /^\+/ && f != "" { print f "\t" substr($0, 2) }
  '
}

untracked_files() {
  git ls-files --others --exclude-standard -z
}

lines=$(git -c core.quotepath=off diff --cached -U0 --no-color --diff-filter=d | added_from_diff)
files=$(git diff --cached --name-only -z --diff-filter=d | tr '\0' '\n')

if [ "$with_add" -eq 1 ]; then
  more=$(git -c core.quotepath=off diff -U0 --no-color --diff-filter=d | added_from_diff)
  [ -n "$more" ] && lines+=$'\n'"$more"
  more_files=$(git diff --name-only -z --diff-filter=d | tr '\0' '\n')
  [ -n "$more_files" ] && files+=$'\n'"$more_files"
  while IFS= read -r -d '' f; do
    files+=$'\n'"$f"
    # Un archivo nuevo entra entero; se saltan los binarios y los vacíos.
    if [ -f "$f" ] && grep -Iq . "$f" 2>/dev/null; then
      lines+=$'\n'"$(awk -v f="$f" '{ print f "\t" $0 }' "$f")"
    fi
  done < <(untracked_files)
fi

hits=()
add_hit() { # regla, fichero (sin duplicados)
  local h="$1|$2" x
  for x in "${hits[@]+"${hits[@]}"}"; do [ "$x" = "$h" ] && return 0; done
  hits+=("$h")
}

# Regla 1: clave con forma reconocible.
# Los corchetes sueltos evitan que este script se detecte a sí mismo.
key_re='AKIA[0-9A-Z]{16}|sk-an[t]-|gh[p]_|github_pa[t]_|AIza[0-9A-Za-z_-]{35}|xox[bpa]-|-----BEGIN [A-Z ]*PRIVATE KEY-----'
app_key_re="[[:space:]]*(export[[:space:]]+)?APP_KEY=['\"]?[^[:space:]'\"]"
while IFS= read -r f; do
  [ -n "$f" ] && add_hit clave-reconocible "$f"
done < <(
  { grep -aE "^[^$tab]*$tab.*($key_re)" <<<"$lines"
    grep -aE "^[^$tab]*$tab$app_key_re" <<<"$lines"; } | cut -f1 | sort -u
)

# Regla 2: correo cuyo dominio no sea de ejemplo.
email_re='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
while IFS="$tab" read -r f l; do
  while IFS= read -r addr; do
    dom=${addr##*@}
    dom=${dom,,}
    case "$dom" in
      example.com | example.org | example.net | github.com) ;;
      *) add_hit correo-ajeno "$f"; break ;;
    esac
  done < <(grep -oE "$email_re" <<<"$l")
done < <(grep -aE "^[^$tab]*$tab.*$email_re" <<<"$lines")

# Regla 3: archivo llamado exactamente .env (los .env.example no cuentan).
while IFS= read -r f; do
  [ -n "$f" ] && [ "${f##*/}" = ".env" ] && add_hit archivo-env "$f"
done <<<"$files"

[ "${#hits[@]}" -eq 0 ] && exit 0

registro="docs/seguridad/registro-de-bloqueos.md"
mkdir -p "$(dirname "$registro")"
[ -f "$registro" ] || printf '# Registro de bloqueos del hook datos-que-no-salen\n' >"$registro"

ahora=$(date -u +%Y-%m-%dT%H:%M:%SZ)
for h in "${hits[@]}"; do
  regla=${h%%|*}
  fichero=${h#*|}
  printf 'Bloqueado por la regla "%s" en %s: sustituye el dato por uno inventado (p. ej. ada@example.com) y reintenta.\n' \
    "$regla" "$fichero" >&2
  printf -- '- %s BLOQUEADO regla=%s archivo=%s\n' "$ahora" "$regla" "$fichero" >>"$registro"
done
exit 2
