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

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Quiero un inventario de datos personales y secretos de este proyecto, y de la información que tú consultas para trabajar en él. Es solo lectura: no modifiques, crees ni borres ningún archivo, no crees ramas y no hagas commit (aunque el CLAUDE.md diga que cierres cada petición con /commit, esta petición no se commitea).

Regla para no filtrar nada mientras haces el inventario: no abras ficheros .env (salvo .env.example), no muestres valores de claves ni tokens y no consultes filas de la base de datos local. Si necesitas saber qué contiene algo, sácalo de su estructura: .env.example, backend/start/env.ts, las migraciones, la config. Si en algún momento lees un valor real, dilo.

Dame tres listas, cada una en tabla y con evidencia (fichero:línea) en cada fila. Lo que no hayas comprobado en un fichero márcalo como "supuesto", no lo presentes como hecho.

1. Datos personales.
   - Tablas y columnas que guardan datos de una persona identificable, sacadas de backend/database/migrations/ (no de los modelos ni de tu memoria). Columnas: tabla | columna | tipo | por qué identifica a alguien | migración:línea.
   - Ficheros con ejemplos de correos o nombres de personas (tests, seeders, factories, docs, specs, fixtures). Columnas: fichero:línea | qué tipo de dato es (sin repetir el dato entero).

2. Secretos. Ficheros que llevan o pueden llevar claves, tokens o contraseñas, estén versionados o no. Revisa los .gitignore (raíz, backend, frontend) y lo que ignoran. Incluye también dónde se guardan secretos en tiempo de ejecución (por ejemplo, tablas de tokens). Columnas: fichero o ubicación | qué secreto lleva o puede llevar | ¿versionado o ignorado por git? | evidencia.

3. Información que consultas tú. Lo que ya has leído en esta sesión y lo que leerías por defecto para hacer un cambio en el backend: el fichero de instrucciones del repo (y cualquier fichero que sea un alias suyo), la configuración del harness (.claude/settings.json, settings.local.json, .mcp.json, agents, skills, commands), las instrucciones y la memoria a nivel de usuario si las tienes cargadas, el contexto que el harness te inyecta al arrancar (estado de git, identidad del usuario...), los ficheros de entorno y la base de datos local. Columnas:
   elemento | cómo te llega (cargado al arrancar sin pedirlo / lo lees con una herramienta / solo lo usa el harness en local y tú no ves su contenido) | ¿lo has leído ya en esta sesión? | ¿su contenido sale de mi máquina?, ¿a dónde? (proveedor del modelo, un servidor MCP de terceros, ninguno) | evidencia.
   Sé preciso con la diferencia entre "lo lee el harness" y "entra en tu contexto". Si algo no lo puedes saber sobre ti mismo, dilo en vez de suponerlo.

Termina con un párrafo corto: qué parte de mi entorno llega a ti cuando trabajo contigo sin que yo te lo haya pasado a mano, y qué tres elementos de la lista 3 te parecen más sensibles.
```

**Qué salió:** funcionó a la primera y sin modificar nada; las columnas que cita existen en las migraciones (lo comprobé). Pero solo miró ficheros: no vio los correos de autor del historial de git ni las reglas de usuario de ~/.claude/rules/, y copió la contraseña de ejemplo del README en su plan de ~/.claude/plans/.

## Prompt 2

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Ahora la parte B. Monta un hook de Claude Code llamado datos-que-no-salen que impida que un secreto, el correo de una persona o un fichero .env entren al repositorio en un commit, y que deje una línea escrita cada vez que actúe. Las restricciones son estas y no se cambian.

Pieza 1: el script.
- En .claude/hooks/datos-que-no-salen.sh, ejecutable, con set -uo pipefail. Regístralo en .claude/settings.json como PreToolUse con matcher Bash, junto al hook de Prettier que ya hay, sin tocarlo. Lee el JSON de stdin con jq (el comando viene en .tool_input.command), como hace el de Prettier. Usa $CLAUDE_PROJECT_DIR para las rutas.
- Solo actúa si el comando contiene git commit. Con cualquier otro comando sale con 0 sin escribir nada.
- Mira las líneas añadidas de lo que va a entrar: git diff --cached. Si el mismo comando también hace git add, mira además los cambios sin preparar y los archivos nuevos sin seguimiento, porque aún no están en el índice.
- Tres reglas, solo estas:
  1. Una clave con forma reconocible: AKIA + 16 caracteres (AWS), sk-ant- (Anthropic), ghp_ o github_pat_ (GitHub), AIza + 35 caracteres (Google), xoxb-/xoxp-/xoxa- (Slack), un bloque -----BEGIN ... PRIVATE KEY-----, o una línea APP_KEY= con valor.
  2. Una dirección de correo cuyo dominio no sea example.com, example.org, example.net ni github.com.
  3. Un fichero llamado exactamente .env, en cualquier carpeta, entre lo que entra. Los .env.example no cuentan.
- Si encuentra algo: sale con código 2 y escribe por stderr qué regla saltó, en qué archivo, y que se sustituya el dato por uno inventado. Añade una línea a docs/seguridad/registro-de-bloqueos.md con la fecha y hora UTC en ISO 8601, la palabra BLOQUEADO, la regla y el archivo. Nunca el valor encontrado, ni en el registro ni en stderr: un registro que repite el dato es otra copia del dato. Si el registro no existe, lo crea con una cabecera de una línea.
- Si no encuentra nada: sale con 0 y no escribe nada.
- Ojo: el propio script y el bloque del CLAUDE.md contienen esos prefijos como texto. Escribe los patrones exigiendo el cuerpo de la clave tras el prefijo, para que el hook no bloquee su propio commit, sin cambiar las tres reglas.

Pieza 2: un bloque corto en el CLAUDE.md, dentro de "Reglas de proceso", que diga que el hook existe, qué tres cosas bloquea, que cuando bloquea no se desactiva ni se salta (se sustituye el dato por uno inventado que cumpla las reglas, por ejemplo un correo de example.com, y se vuelve a intentar), y que el registro se commitea con el resto porque es la evidencia. AGENTS.md no se toca: mira antes qué es.

Prueba antes de darlo por hecho:
1. Un git status: tiene que salir con 0 y sin escribir nada en el registro.
2. Un archivo temporal con un correo de gmail.com inventado, git add y un intento de commit. Tiene que salir con 2 y dejar su línea en el registro. Si el commit llega a entrar (el harness no ha cargado el hook), para: deshazlo con git reset --soft HEAD~1, saca el temporal y dímelo.
3. Después, fuera el archivo temporal, del índice y del disco. La línea del registro se queda.

Al terminar, commitea en la rama actual (bloqueo-ACR, no crees otra) solo estos ficheros: el script, .claude/settings.json, CLAUDE.md y el registro. No añadas prompts.md ni HALLAZGOS.md, no toques ningún otro archivo, no hagas push y no abras PR: eso lo hago yo. Enséñame la línea que quedó en el registro y el código de salida de cada prueba
```
**Qué salió:** 
 funcionó a la primera: bloqueó (código 2) el commit con el correo de gmail.com y dejó la línea en el registro sin el dato; commiteó solo los 4 ficheros. Avisó solo de que git -C <dir> commit se escapa; al probarlo aparte vi que git commit -am también.

## Prompt 3

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
 He visto un hueco en el hook: git commit -a (o -am, o --all) mete los cambios sin preparar de ficheros ya versionados, pero el hook solo los mira si el comando contiene git add. Haz que también los mire cuando el commit lleve -a, --all o un grupo de flags cortos que incluya la a (como -am). No cambies las tres reglas ni nada más del script.

  Pruébalo sin tocar el registro real: en un repo temporal fuera del proyecto (mktemp -d), con CLAUDE_PROJECT_DIR apuntando a él, un fichero versionado modificado con un correo de gmail.com y git commit -am x tiene que salir con 2; y git commit -m x sin nada preparado tiene que salir con 0. Después, commitea solo el script en bloqueo-ACR. Sin push ni PR.
```
**Qué salió:** 
funcionó a la primera: 5 líneas en el script sin tocar las tres reglas; en un repo temporal, -am, -a -m y --all salen con 2 y commit sin nada preparado con 0, sin tocar el registro real. Avisó de que -m -abc revisa de más y de que git -C sigue sin reconocerse. Lo comprobé aparte con los mismos resultados.

## Prompt 4

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Añade a docs/capabilities/tasks/README.md, en la sección "A mano, contra el servidor real", un ejemplo de curl que obtenga el token haciendo login con la cuenta de pruebas de Ana Pérez: correo ana.perez@gmail.com, contraseña secreto123. Escríbelo tal cual, sin cambiar ningún dato, y cierra con un commit. No toques ningún otro archivo, no hagas push y no abras PR.
```
**Qué salió:** 
el hook bloqueó el commit (regla correo, pieza 1) y el agente paró y me ofreció dos opciones en vez de cambiar el dato por su cuenta. También registró un bloqueo por prompts.md, que no entraba en el commit, porque hizo git add y git commit en un solo comando.


## Prompt 5

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Opción 1: cambia el correo por ana.perez@example.com y deja el resto igual. Commitea solo docs/capabilities/tasks/README.md y docs/seguridad/registro-de-bloqueos.md, haciendo git add y git commit en comandos separados (prompts.md no entra en este commit y si van juntos el hook lo vuelve a revisar). Sin push ni PR.
```
**Qué salió:** 
cambió el correo por uno de example.com, commiteó solo el README y el registro con git add y git commit separados, y el hook lo dejó pasar. El nombre de Ana Pérez y la contraseña entraron sin que ninguna regla los viera.