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

---

## Prompt 1

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Analiza este proyecto sin modificar ningún archivo y devuélveme tres listas:

1. Datos personales
   - Tablas y columnas que guardan información de una persona identificable. Verifícalo en las migraciones; no lo supongas por los nombres.
   - Archivos que contienen ejemplos de correos o nombres.

2. Secretos
   - Archivos que contienen o podrían contener claves, tokens o contraseñas, estén o no en el repositorio. Revisa también lo que ignora Git (.gitignore).

3. Información que consultas
   - Lo que ya has leído y lo que podrías leer al hacer un cambio en el backend: instrucciones del repositorio, configuración de la herramienta que te ejecuta, archivos de entorno y base de datos local.
   - Para cada elemento, indica si su contenido sale de mi máquina cuando trabajas conmigo.

Para cada elemento, incluye la ruta del archivo (y la tabla/columna cuando aplique).
```

**Qué salió:** funcionó a la primera: tres listas con rutas, sin leer `.env` ni la base de datos.

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Crea un hook de Claude Code en `.claude/hooks/datos-que-no-salen.sh` y regístralo en `.claude/settings.json` como `PreToolUse` con matcher `Bash`, junto al hook existente.

Implementación:
- Usa `set -uo pipefail`.
- Lee el JSON de la entrada estándar con `jq`; el comando está en `.tool_input.command` (igual que en el hook de Prettier).

Comportamiento:
- Si el comando no contiene `git commit`, sale con 0 sin escribir nada.
- Revisa las líneas añadidas de `git diff --cached`. Si el comando también incluye `git add`, revisa además los cambios sin preparar y los archivos nuevos sin seguimiento.

Aplica solo estas tres reglas:
1. Claves reconocibles: `AKIA` + 16 caracteres (AWS), `sk-ant-` (Anthropic), `ghp_` o `github_pat_` (GitHub), `AIza` + 35 caracteres (Google), `xoxb-`/`xoxp-`/`xoxa-` (Slack), un bloque `-----BEGIN ... PRIVATE KEY-----`, o una línea `APP_KEY=` con valor.
2. Correos cuyo dominio no sea `example.com`, `example.org`, `example.net` ni `github.com`.
3. Un archivo llamado exactamente `.env`, en cualquier carpeta, entre los que entran al commit (`.env.example` no cuenta).

Si hay coincidencia:
- Sale con código 2 y escribe en stderr la regla activada, el archivo y que el dato debe sustituirse por uno inventado.
- Añade una línea a `docs/seguridad/registro-de-bloqueos.md` con: fecha y hora UTC en ISO 8601, `BLOQUEADO`, la regla y el archivo. Si el registro no existe, créalo con una cabecera de una línea.
- Nunca incluyas el valor detectado, ni en stderr ni en el registro.

Si no hay coincidencia, sale con 0 sin escribir nada.
```

**Qué salió:** funcionó a la primera; lo probé en un repo temporal y se commiteó.

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
prueba el hook con un caso de cada regla y uno limpio, y muéstrame los resultados.
```

**Qué salió:** funcionó a la primera: caso limpio con salida 0 y una salida 2 por cada regla.

## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Ahora agrega un bloque breve en la sección de reglas de proceso del CLAUDE.md del repositorio. Debe explicar que el hook existe, qué tres cosas bloquea y cómo actuar ante un bloqueo: no desactivarlo ni saltárselo, sustituir el dato por uno inventado que cumpla las reglas y volver a intentarlo. También debe indicar que el registro se incluye en el commit con el resto del trabajo, porque es la evidencia del bloqueo. AGENTS.md no se modifica: el agente debe comprobar antes qué es.
```

**Qué salió:** funcionó a la primera; comprobó que `AGENTS.md` es un enlace simbólico a `CLAUDE.md` y editó solo `CLAUDE.md`.

## Prompt 5

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Pueba lo que acabamos de agregar, debes crear un archivo temporal con un correo de gmail.com, ejecutar git add e intentar hacer un commit. El hook debe salir con código 2, impedir el commit y añadir una línea al registro.

Después, debe retirar el archivo temporal tanto del área de preparación como del directorio de trabajo. La línea del registro se conserva: es la primera evidencia de que el hook ha actuado.
Muestra los resultados y si algo no sale como se espera explica porque
```

**Qué salió:** funcionó a la primera: el hook bloqueó el commit y el registro quedó commiteado.

## Prompt 6

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
En `docs/capabilities/tasks/README.md`, dentro de la sección de pruebas manuales contra el servidor real, añade un ejemplo de `curl` que obtenga el token con la cuenta de pruebas de Ana Pérez:

- Correo: ana.perez@gmail.com
- Contraseña: secreto123

Escríbelo tal cual, sin cambiar ningún dato. No ejecutes el `curl` ni envíes ninguna petición al servidor. Cuando termines, haz un commit con el cambio.
```

**Qué salió:** el hook bloqueó el commit (regla 2, correo de `gmail.com`) y se paró para preguntar, porque "sin cambiar ningún dato" choca con la regla del proyecto de sustituir el dato por uno inventado. Tras confirmarlo, se sustituyó el correo por `ana.perez@example.com` en el README. El prompt de este archivo está tal cual, con el correo original, porque `prompts.md` se excluyó del hook.

## Prompt 7

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
git status
```
