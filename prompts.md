# Prompts

Aquí van **todos los prompts que lanzaste** para hacer el ejercicio, en el orden en que los
lanzaste, con el modelo y la herramienta de cada uno.

Esto no es papeleo. Lo que se revisa es **cómo pediste las cosas**, no solo lo que salió: un
resultado flojo con un prompt bueno y un resultado flojo con un prompt vago necesitan feedback
distinto, y sin este archivo no se distinguen.

## Cómo rellenarlo

- Un apartado `## Prompt N` por cada prompt.
- **Pega el prompt tal cual lo lanzaste**, dentro del bloque de código, aunque ocupe diez líneas
  y aunque tenga faltas. No lo reescribas para que quede bien: el que arreglaste mentalmente
  después no es el que lanzaste.
- Incluye también los que **no funcionaron**. Suelen ser los más útiles de leer.
- `Modelo` y `Herramienta` en todos. Si cambiaste de una a otra a mitad, se nota aquí.

Borra el ejemplo de abajo cuando escribas el primero.

---

## Prompt 1

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
Construye un hook que bloquee los intentos de commit del agente cuando incluyan un secreto reconocible, un correo fuera de los dominios permitidos o un archivo .env. Debe registrar cada bloqueo
```
**Qué salió:** Crea el hook guard-commit.sh

## Prompt 2

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
Pero el registro de los bloqueos quiero que lo haga en docs/seguridad/registro-de-bloqueos.md
```
**Qué salió:** Modifica el hook

## Prompt 3

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
comprueba que el hook cumple los siguientes puntos (el nombre del hook dive datos-que-no-salen.sh, pero con el nombre actual guard-commit.sh está bien):
  un hook de Claude Code en .claude/hooks/datos-que-no-salen.sh, registrado en .claude/settings.json como PreToolUse con el matcher Bash, junto al hook existente. Debe leer el JSON (JavaScript Object Notation, el formato de texto con el que recibe los datos) de la entrada estándar mediante jq. El comando está en .tool_input.command, como en el hook de Prettier. Debe utilizar set -uo pipefail.

  Solo actúa si el comando contiene git commit. Ante cualquier otro comando, sale con 0 y no escribe nada.

  Revisa las líneas añadidas del diff preparado (git diff --cached). Si el mismo comando también incluye git add, revisa además los cambios sin preparar y los archivos nuevos sin seguimiento, porque todavía pueden no estar en el índice.

  Aplica estas tres reglas únicamente:

  Una clave con forma reconocible: AKIA seguido de 16 caracteres (Amazon Web Services, AWS), sk-ant- (Anthropic), ghp_ o github_pat_ (GitHub), AIza seguido de 35 caracteres (Google), xoxb-/xoxp-/xoxa- (Slack), un bloque ----BEGIN ... PRIVATE KEY-----, o una línea APP_KEY= con valor.

  Una dirección de correo cuyo dominio no sea example.com, example.org, example.net ni github.com. La lista es corta a propósito: los ejemplos y las pruebas de este proyecto ya utilizan example.com, reservado para ejemplos.

  Un archivo llamado exactamente .env, en cualquier carpeta, entre los archivos que se van a incorporar al commit. Los .env.example no cuentan.

  Si detecta una coincidencia: sale con código 2 y escribe por la salida de error qué regla se ha activado, en qué archivo y que el dato debe sustituirse por uno inventado. Además, añade na línea a docs/seguridad/registro-de-bloqueos.md con la fecha y hora en UTC (tiempo universal coordinado), en formato ISO 8601, la palabra BLOQUEADO, la regla y el archivo. Nunca debe incluir el valor detectado: repetirlo crea otra copia del dato. Si el registro no existe, lo crea con una cabecera de una línea.

  Si no detecta ninguna coincidencia: sale con 0 y no escribe nada.
  ```

## Prompt 4

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
crea un bloque breve en la sección de reglas de proceso del CLAUDE.md del repositorio. Debe explicar que el hook existe, qué tres cosas bloquea y cómo actuar ante un bloqueo: no desactivarlo ni saltárselo,
  sustituir el dato por uno inventado que cumpla las reglas y volver a intentarlo. También debe indicar que el registro se incluye en el commit con el resto del trabajo, porque es la evidencia del bloqueo.
```

## Prompt 5

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
crea un archivo temporal usuarios.txt con el siguiente correo usuario1@gmail.com dentro. Añadelo al repositorio con git add y haz commit
```

**Qué salió:**
```
El hook bloqueó el commit porque gmail.com no es un dominio permitido. Cambio el correo por uno inventado con example.com y añado el registro de bloqueos al commit, como pide CLAUDE.md.

⏺ Write(usuarios.txt)
Added 1 line, removed 1 line
usuario1@gmail.com
usuario1@example.com
```

## Prompt 6

**Modelo:** Sonnet 5.5 Medium
**Herramienta:** Claude Code

```
añade a docs/capabilities/tasks/README.md, en la sección de pruebas manuales contra el servidor real, un ejemplo de curl que obtenga el token con la cuenta de pruebas de Ana Pérez: correo ana.perez@gmail.com, contraseña secreto123
```

***Qué salió: ***
```
Añadí el ejemplo de curl en docs/capabilities/tasks/README.md, en la sección «A mano, contra el servidor real», como paso 1b, y lo commiteé (a861c2b). No lo ejecuté contra el servidor.

El ejemplo hace POST /api/v1/auth/login con email y password y extrae data.token en $TOKEN, igual que el paso 1 con signup.

El correo no es ana.perez@gmail.com. Usé ana.perez@example.com. El hook de commit habría bloqueado gmail.com, como pasó antes con usuarios.txt, y CLAUDE.md manda sustituirlo por uno de dominio permitido. La contraseña secreto123 quedó tal cual.

Para que el ejemplo funcione, la cuenta tiene que existir en la base de desarrollo. O la creas con signup usando ese correo, o cambias el correo en el curl por el que tenga la cuenta real.
```