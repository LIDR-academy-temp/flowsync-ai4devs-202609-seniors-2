#!/usr/bin/env bash
# PreToolUse(Bash): antes de un `git commit`, bloquea (exit 2) si lo que entra
# lleva una clave reconocible, un correo real o un fichero .env.
# Los prefijos de las claves se parten en el código ('AK''IA'...) para que este
# script no se dispare a sí mismo al commitearse.
set -uo pipefail

input=$(cat)
# Sin jq (no está en todos los entornos) se cae a escanear el JSON crudo.
cmd=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null) || cmd=$input
[[ $cmd == *"git commit"* ]] || exit 0

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}" 2>/dev/null || exit 0

export LC_ALL=C
tab=$'\t'
con_add=0
[[ $cmd == *"git add"* ]] && con_add=1

tmp=$(mktemp) && nombres=$(mktemp) || exit 0
trap 'rm -f "$tmp" "$nombres"' EXIT

# diff -> "ruta<TAB>línea añadida". Las cabeceras +++ solo cuentan fuera de un hunk.
anadidas() {
  awk '/^diff --git/{h=0; next} /^@@/{h=1; next} !h && /^\+\+\+ /{f=substr($0,7); next} h && /^\+/{print f "\t" substr($0,2)}'
}

g() { git -c core.quotepath=off "$@"; }

{
  g diff --cached -U0 --no-color --diff-filter=d | anadidas
  if ((con_add)); then
    g diff -U0 --no-color --diff-filter=d | anadidas
    g ls-files --others --exclude-standard | while IFS= read -r f; do
      [[ -f $f ]] && grep -Iq . "$f" 2>/dev/null && awk -v f="$f" '{print f "\t" $0}' "$f"
    done
  fi
} >"$tmp"

{
  g diff --cached --name-only --diff-filter=d
  if ((con_add)); then
    g diff --name-only --diff-filter=d
    g ls-files --others --exclude-standard
  fi
} >"$nombres"

# Regla 1: clave reconocible
aws='AK''IA[0-9A-Z]{16}'
ant='sk-an''t-[A-Za-z0-9_-]'
gh1='gh''p_[A-Za-z0-9]'
gh2='github_''pat_[A-Za-z0-9_]'
goo='AI''za[0-9A-Za-z_-]{35}'
slk='xox[bpa]-[A-Za-z0-9]'
pem='-----BEG''IN [A-Z ]*PRIVATE KEY-----'
app='(.*[^A-Za-z0-9_])?APP_''KEY=["'\'']?[^[:space:]"'\'']'
re_clave="^[^$tab]*$tab(.*($aws|$ant|$gh1|$gh2|$goo|$slk|$pem)|$app)"

# Regla 2: correo (el dominio se filtra después, no en la regex)
re_mail='[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}'

hallazgos=$(
  grep -aE "$re_clave" "$tmp" | cut -f1 | sort -u | sed 's/^/1\t/'
  grep -aE "^[^$tab]*$tab.*@" "$tmp" | while IFS=$tab read -r f linea; do
    while IFS= read -r e; do
      case "$(tr '[:upper:]' '[:lower:]' <<<"${e##*@}")" in
        example.com | example.org | example.net | github.com) ;;
        *) printf '2\t%s\n' "$f"; break ;;
      esac
    done < <(grep -aoE "$re_mail" <<<"$linea")
  done | sort -u
  # Regla 3: fichero llamado exactamente .env
  while IFS= read -r n; do [[ ${n##*/} == .env ]] && printf '3\t%s\n' "$n"; done <"$nombres" | sort -u
)

[[ -n $hallazgos ]] || exit 0

log=docs/seguridad/registro-de-bloqueos.md
mkdir -p "$(dirname "$log")"
[[ -f $log ]] || echo '# Registro de bloqueos del hook datos-que-no-salen' >"$log"

while IFS=$tab read -r regla archivo; do
  case $regla in
    1) que='clave reconocible'; id='1-clave' ;;
    2) que='correo con dominio real'; id='2-correo' ;;
    3) que='fichero .env'; id='3-env' ;;
  esac
  echo "BLOQUEADO (datos-que-no-salen): regla $regla, $que, en $archivo. Sustituye ese dato por uno inventado que cumpla las reglas y reintenta el commit." >&2
  printf '%s BLOQUEADO regla=%s archivo=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$id" "$archivo" >>"$log"
done <<<"$hallazgos"
exit 2
