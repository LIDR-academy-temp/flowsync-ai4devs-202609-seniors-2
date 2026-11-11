# Prompts

## Prompt 1

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
Crea un archivo sensitive_info.md con 3 listas:
  1. Datos personales: tablas y columnas que almacenan información de una persona identificable, comprobadas en las migraciones y no supuestas, y los archivos que contienen ejemplos de correos o nombres.
  2. Secrets: archivos que contienen o pueden contener claves, tokens o contraseñas, estén o no incluidos en el repositorio (mira también lo que ignora Git).
  3. Información que consultas para trabajar: qué lees o podrías leer al hacer un cambio en el backend. Instrucciones del repo, configuración de la herramienta, archivos de entorno, base de datos local. En cada caso, aclara si esta información sale de mi estación de trabajo durante la sesión.
     Mira lo que necesites pero no modifiques ningún archivo preexistente.
```

## Prompt 2

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
Construye un hook en .claude/hooks/datos-que-no-salen.sh y regístralo en .claude/settings.json. Se activa en PreToolUse, matcher Bash. Debe examinar el comando input usando jq, y comenzar ejecutando 'set
  -uo pipefail'. Si el input command no contiene 'git commit', exit 0 sin output. Si el comando contiene un commit:
  - debe revisar las líneas añadidas del diff (git diff --cached)
  - si el comando incluye también un 'git add', debe revisar también los cambios sin preparar y los archivos nuevos unstaged
  - en los cambios a revisar, hay que buscar:
    - contraseñas/tokens con formato reconocible:
      - AKIA seguido de 16 caracteres (AWS)
      - sk-ant-* (Anthropic)
      - ghp_* o github_pat_* (GitHub)
      - AIza seguido de 35 caracteres (Google)
      - xoxb-/xoxp-/xoxa-* (Slack)
      - un bloque ----BEGIN ... PRIVATE KEY-----, o una línea APP_KEY= con valor.
    - emails de dominios que no sean example.com, example.org, example.net o github.com
    - archivos '.env' (literal, .env.<algo> se ignoran) en cualquier ubicación
  - en caso de que cualquiera de estos chequeos de positivo:
    - escribir por stderr cuál regla se activó, en qué archivo, y señalar que el dato debe sustituirse por uno inventado
    - generar un registro de log en docs/seguridad/registro-de-bloqueos.md, con una única línea con la fecha y hora en UTC, en formato ISO 8601, la palabra 'BLOQUEADO', la regla y el archivo (no debe
  registrar el valor sensible detectado). Si el archivo no existe, debe crearlo con un encabezado de una línea.
    - exit 2
```

**Qué salió:** generó el hook y lo probó por iniciativa propia.

## Prompt 3

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
Agrega una regla de proceso en CLAUDE.md al respecto. Debe explicar que el hook existe, qué tres cosas bloquea y cómo actuar ante un bloqueo: no desactivarlo ni saltárselo, sustituir el dato por uno inventado que cumpla las reglas y volver a intentarlo. También debe indicar que el registro se incluye en el commit con el resto del trabajo, porque es la evidencia del bloqueo.
```

## Prompt 4

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
Modifica las instrucciones en @docs/capabilities/tasks/README.md que explican cómo realizar pruebas manuales localmente, para que el ejemplo de obtención de un token use la cuenta de pruebas de Ana Pérez: correo ana.perez@gmail.com, contraseña secreto123. Haz un commit que incluya a este archivo modificado únicamente.
```

**Qué salió:** hizo el cambio, intentó hacer el commit, lo frenó el hook.