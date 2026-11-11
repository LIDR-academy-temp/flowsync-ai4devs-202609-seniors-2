#!/usr/bin/env bash
# PreToolUse (Bash): bloquea un `git commit` cuyo diff lleve secretos, correos
# reales o un archivo `.env`. Exit 2 = bloqueado; exit 0 sin salida = no aplica.
set -uo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)

case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

con_add=0
case "$cmd" in *"git add"*) con_add=1 ;; esac

tmp=$(mktemp -d) || exit 0
trap 'rm -rf "$tmp"' EXIT
stream="$tmp/stream"   # "<archivo>\t<línea añadida>"
nombres="$tmp/nombres" # archivos tocados
hits="$tmp/hits"       # "<regla>\t<archivo>"
: >"$stream" && : >"$nombres" && : >"$hits"

lineas_añadidas() {
  awk '
    /^\+\+\+ / { f = $0; sub(/^\+\+\+ (b\/)?/, "", f); next }
    /^\+/      { print f "\t" substr($0, 2) }
  '
}

git_diff() { git -c core.quotepath=off diff --no-color --no-ext-diff -U0 "$@" 2>/dev/null; }

# Preparado
git_diff --cached | lineas_añadidas >>"$stream"
git diff --cached --name-only -z --diff-filter=ACMR 2>/dev/null | tr '\0' '\n' >>"$nombres"

# Sin preparar y nuevos, solo si el mismo comando hace `git add`
if [ "$con_add" -eq 1 ]; then
  git_diff | lineas_añadidas >>"$stream"
  git diff --name-only -z --diff-filter=ACMR 2>/dev/null | tr '\0' '\n' >>"$nombres"
  while IFS= read -r -d '' f; do
    printf '%s\n' "$f" >>"$nombres"
    [ -f "$f" ] || continue
    grep -I '' -- "$f" 2>/dev/null | awk -v f="$f" '{ print f "\t" $0 }' >>"$stream"
  done < <(git ls-files --others --exclude-standard -z 2>/dev/null)

  # `git add -f .env && git commit`: el archivo ignorado aún no está en ningún diff
  previo=${cmd%%git commit*}
  set -f
  for w in $previo; do
    w=${w//[\"\';&|]/}
    [ -n "$w" ] && printf '%s\n' "$w" >>"$nombres"
  done
  set +f
fi

# Regla: archivo .env (literal; .env.<algo> no cuenta)
sort -u "$nombres" | while IFS= read -r p; do
  [ "${p##*/}" = ".env" ] && printf 'archivo-env\t%s\n' "$p"
done >>"$hits"

# Reglas de contenido con formato reconocible
tab=$'\t'
reglas=(
  'aws-access-key|AKIA[0-9A-Z]{16}'
  'anthropic-key|sk-ant-[A-Za-z0-9_-]+'
  'github-token|(ghp_[A-Za-z0-9]+|github_pat_[A-Za-z0-9_]+)'
  'google-api-key|AIza[0-9A-Za-z_-]{35}'
  'slack-token|xox[bpa]-[A-Za-z0-9-]+'
  'clave-privada|-{4,}BEGIN [A-Z ]*PRIVATE KEY-{4,}'
  "app-key|^[^$tab]*$tab[[:space:]]*(export[[:space:]]+)?APP_KEY=[\"']?[^[:space:]\"'#]"
)
for r in "${reglas[@]}"; do
  nombre=${r%%|*}
  re=${r#*|}
  grep -E -- "$re" "$stream" | cut -f1 | sort -u | while IFS= read -r f; do
    printf '%s\t%s\n' "$nombre" "$f"
  done >>"$hits"
done

# Regla: correos fuera de example.com/.org/.net y github.com
email_re='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
grep -E -- "$email_re" "$stream" | while IFS=$'\t' read -r f linea; do
  while IFS= read -r correo; do
    dominio=${correo#*@}
    case "${dominio,,}" in
      example.com | example.org | example.net | github.com) ;;
      *) printf 'email-externo\t%s\n' "$f"; break ;;
    esac
  done < <(grep -oE -- "$email_re" <<<"$linea")
done >>"$hits"

[ -s "$hits" ] || exit 0

sort -u "$hits" -o "$hits"

log="docs/seguridad/registro-de-bloqueos.md"
mkdir -p "$(dirname "$log")" 2>/dev/null
[ -f "$log" ] || printf '# Registro de bloqueos\n' >"$log" 2>/dev/null
ahora=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "BLOQUEADO: el commit incluye datos que no deben salir del equipo." >&2
while IFS=$'\t' read -r regla archivo; do
  echo "  - regla '$regla' en $archivo" >&2
  printf '%s BLOQUEADO %s %s\n' "$ahora" "$regla" "$archivo" >>"$log" 2>/dev/null
done <"$hits"
echo "Sustituye el dato por uno inventado (p. ej. ada@example.com) y vuelve a intentarlo." >&2
exit 2
