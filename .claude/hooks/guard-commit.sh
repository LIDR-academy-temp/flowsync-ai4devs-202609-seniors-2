#!/usr/bin/env bash
# PreToolUse(Bash): bloquea `git commit` si lo que entra en el commit contiene
#   1) una clave con forma reconocible, 2) un correo de dominio no permitido, 3) un archivo .env.
# Bloqueo = exit 2 + motivo por stderr + una línea en docs/seguridad/registro-de-bloqueos.md.
# El valor detectado NUNCA se imprime ni se registra.
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
LOG="$ROOT/docs/seguridad/registro-de-bloqueos.md"

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty')

# Solo actúa si el comando contiene `git commit`.
printf '%s' "$CMD" | grep -Eq 'git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+commit([[:space:]]|$)' || exit 0

cd "${CWD:-$ROOT}" 2>/dev/null || cd "$ROOT" || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# --- Qué se revisa -----------------------------------------------------------
# Siempre lo preparado. Con `commit -a` también lo tracked modificado. Si el mismo comando
# incluye `git add`, además lo no preparado y los archivos nuevos sin seguimiento.
BASE=(--cached)
printf '%s' "$CMD" | grep -Eq 'git.*commit.*([[:space:]]-[a-zA-Z]*a[a-zA-Z]*([[:space:]]|$)|--all)' && git rev-parse --verify HEAD >/dev/null 2>&1 && BASE=(HEAD)
HAS_ADD=0
printf '%s' "$CMD" | grep -Eq 'git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+add([[:space:]]|$)' && HAS_ADD=1

# Salida: "<archivo>\t<línea añadida>"
added_lines() {
  awk '/^\+\+\+ /{f=substr($0,5); if ($0=="+++ /dev/null") f=""; next} /^\+/ && f!="" {print f "\t" substr($0,2)}'
}
LINES=$(git diff "${BASE[@]}" -U0 --no-color --no-prefix | added_lines)
FILES=$(git diff "${BASE[@]}" --name-only --diff-filter=ACMR)
if [ $HAS_ADD -eq 1 ]; then
  LINES+=$'\n'$(git diff -U0 --no-color --no-prefix | added_lines)
  FILES+=$'\n'$(git diff --name-only --diff-filter=ACMR)
  UNTRACKED=$(git ls-files --others --exclude-standard)
  FILES+=$'\n'"$UNTRACKED"
  while IFS= read -r u; do
    [ -f "$u" ] && grep -Iq . "$u" 2>/dev/null && LINES+=$'\n'$(awk -v f="$u" '{print f "\t" $0}' "$u")
  done <<< "$UNTRACKED"
fi

# --- Reglas ------------------------------------------------------------------
HITS=()   # "regla<TAB>archivo", sin repetidos
add_hit() { HITS+=("$1"$'\t'"$2"); }

# 3) Archivo llamado exactamente .env
while IFS= read -r f; do
  [ "$(basename "$f")" = ".env" ] && add_hit archivo_env "$f"
done <<< "$FILES"

# 1) Claves con forma reconocible
KEY_RX='AKIA[0-9A-Z]{16}|sk-ant-|ghp_|github_pat_|AIza[0-9A-Za-z_-]{35}|xox[bpa]-|-----BEGIN [A-Z ]*PRIVATE KEY-----|APP_KEY=[^[:space:]]+'
while IFS= read -r f; do
  [ -n "$f" ] && add_hit clave_reconocible "$f"
done < <(printf '%s\n' "$LINES" | awk -F'\t' 'NF>=2 {print}' | grep -E -- "$(printf '\t').*($KEY_RX)" | cut -f1 | sort -u)

# 2) Correos con dominio distinto de example.com / .org / .net / github.com
while IFS=$'\t' read -r f dom; do
  case "$dom" in example.com|example.org|example.net|github.com) ;; *) add_hit correo_no_permitido "$f" ;; esac
done < <(printf '%s\n' "$LINES" | awk -F'\t' 'NF>=2 {
    s=$0; sub(/^[^\t]*\t/,"",s)
    while (match(s,/[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}/)) {
      m=substr(s,RSTART,RLENGTH); sub(/.*@/,"",m); print $1 "\t" tolower(m); s=substr(s,RSTART+RLENGTH)
    } }' | sort -u)

[ ${#HITS[@]} -eq 0 ] && exit 0

# --- Bloqueo -----------------------------------------------------------------
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$(dirname "$LOG")"
[ -s "$LOG" ] || echo "# Registro de bloqueos de commit (lo escribe .claude/hooks/guard-commit.sh)" > "$LOG"
{
  echo "COMMIT BLOQUEADO por guard-commit.sh:"
  printf '%s\n' "${HITS[@]}" | sort -u | while IFS=$'\t' read -r rule file; do
    echo " - regla $rule en $file"
    echo "- $TS BLOQUEADO $rule $file" >> "$LOG"
  done
  echo "Sustituye el dato por uno inventado (p. ej. user@example.com o una clave de mentira) o saca el archivo del commit."
} >&2
exit 2
