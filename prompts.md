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

**Modelo:** Opus 5.5 1M High
**Herramienta:** Claude Code

```
Crea tres listas:

1. **Datos personales.** Las tablas y columnas que almacenan información de una persona identificable, comprobadas en las migraciones y no supuestas, y los archivos que contienen ejemplos de correos o nombres.

2. **Secretos.** Los archivos que contienen o pueden contener claves, tokens o contraseñas, estén o no incluidos en el repositorio (mira también lo que ignora Git).

3. **Información que consulta el agente.** Lo que ha leído y lo que podría leer al hacer un cambio en el backend: las instrucciones del repositorio, la configuración de la herramienta que lo ejecuta, los archivos de entorno y la base de datos local. Para cada elemento, indica si su contenido sale de tu máquina cuando trabaja contigo.

No hagas commit ni PR. No modifiques ningún archivo. Solo responde con tres listas.
```

**Qué salió:** funcionó a la primera; leyó las migraciones y los `.env` con los valores ocultos.

## Prompt 2

**Modelo:** Opus 5.5 1M High
**Herramienta:** Claude Code

```
Crea un hook de Claude Code en `.claude/hooks/datos-que-no-salen.sh`, registrado en `.claude/settings.json` como `PreToolUse` con el matcher `Bash`, junto al hook existente. Debe leer el JSON de la entrada estándar mediante `jq`. El comando está en `.tool _input.command` como hace el hook actúal de Prettier. Utiliza `set -uo pipefail`.

Solo actúa si el comando contiene `git commit`. Ante cualquier otro comando, sale con 0 y no escribe nada.
Revisa las líneas añadidas del diff preparado (`git diff --cached`). Si el mismo comando también incluye `git add`, revisa además los cambios sin preparar y los archivos nuevos sin seguimiento.
Aplica estas tres reglas únicamente:
    1. Una clave con forma reconocible: `AKIA` seguido de 16 caracteres (Amazon Web Services, AWS), `sk-ant-` (Anthropic), `ghp_` o `github_pat_` (GitHub), `AIza` seguido de 35 caracteres (Google), `xoxb-`/`xoxp-`/`xoxa-` (Slack), un bloque `----BEGIN ... PRIVATE KEY-----`, o una línea `APP_KEY=` con valor.
    2. Una dirección de correo cuyo dominio **no** sea `example.com`, `example.org`, `example.net` ni `github.com`.
    3. Un archivo llamado exactamente `.env`, en cualquier carpeta, entre los archivos que se van a incorporar al commit. Los `.env.example` no cuentan.

Si detecta una coincidencia: sale con **código 2** y escribe por la salida de error qué regla se ha activado, en qué archivo y que el dato debe sustituirse por uno inventado. Además, añade **una línea** a `docs/seguridad/registro-de-bloqueos.md` con la fecha y hora en UTC, en formato ISO 8601, la palabra BLOQUEADO, la regla y el archivo. **Nunca debe incluir el valor detectado**: repetirlo crea otra copia del dato. Si el registro no existe, lo crea con una cabecera de una línea.
Si no detecta ninguna coincidencia: sale con 0 y no escribe nada.
```

**Qué salió:** funcionó; lo probó con 33 casos en repos de usar y tirar y commiteó por la regla de `CLAUDE.md` sin que se lo pidiera.

## Prompt 3

**Modelo:** Opus 5.5 1M High
**Herramienta:** Claude Code

```
Agrega un bloque breve en la sección de reglas de proceso del  `CLAUDE.md` del repositorio. Explica que el hook existe, qué tres cosas bloquea y cómo actuar ante un bloqueo: **no desactivarlo ni saltárselo**, sustituir el dato por uno inventado que cumpla las reglas y volver a intentarlo. Indica que el registro se incluye en el commit con el resto del trabajo, porque es la evidencia del bloqueo. `AGENTS.md` no se modifica: el agente debe comprobar antes qué es.
No cambies nada más.

Prueba el hook: crea un archivo temporal con un correo de `gmail.com`, ejecuta `git add` e intenta hacer un commit. El hook debe salir con código 2, impedir el commit y añadir una línea al registro. Después, retira el archivo temporal tanto del área de preparación como del directorio de trabajo. **La línea del registro se conserva**: es la primera evidencia de que el hook ha actuado.

No hagas commit ni PR. No modifiques ningún archivo fuera de `.claude/hooks/datos-que-no-salen.sh` y `CLAUDE.md`. Solo responde con el hook y el bloque de reglas.
```

**Qué salió:** el hook bloqueó el commit; un comando de comprobación del agente con `git commit` dentro dejó una línea de más en el registro.

## Prompt 4

**Modelo:** Opus 5.5 1M High
**Herramienta:** Claude Code

```
Añade a `docs/capabilities/tasks/README.md`, en la sección de pruebas manuales contra el servidor real, un ejemplo de `curl` que obtenga el token con la cuenta de pruebas de **Ana Pérez**: correo `ana.perez@***`, **contraseña** 'secreto123'. Escribe el ejemplo tal cual, sin cambiar ningún dato, y termina con un commit. No modifiques ningún otro archivo.
```

**Qué salió:** saltó el hook (regla 2); el agente sustituyó el correo por uno de `example.com` siguiendo `CLAUDE.md` y commiteó.

## Prompt 5

**Modelo:** Opus 5.5 1M High
**Herramienta:** Claude Code

```
haz un reset de los ultimos 2 commits manteniendo los cambios
```

**Qué salió:** comprobó que no estaban en el remoto e hizo `git reset HEAD~2`.

## Prompt 6

**Modelo:** Opus 5.5 1M High
**Herramienta:** Claude Code

```
añade los prompts de la sesion a @prompts.md  recuerdo que estamos usando effort high context 1.0M no hagas commit pr todavía
```
