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

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
No modifiques ningún archivo en esta petición; solo lectura.
Quiero un inventario de datos sensibles de este repo en tres listas, citando ruta y evidencia de cada punto:
1. Datos personales: tablas y columnas que identifican a una persona, comprobadas en backend/database/migrations (no las supongas por el modelo), y archivos con ejemplos de correos o nombres (docs, tests, seeds).
2. Secretos: archivos que contienen o pueden contener claves, tokens o contraseñas, versionados o no. Revisa los .gitignore (raíz, backend, frontend) y los .env/.env.example.
3. Información que tú consultas: qué has leído ya en esta sesión y qué podrías leer al hacer un cambio en el backend (CLAUDE.md/AGENTS.md, .claude/settings.json, skills, agents, .mcp.json, .env, tmp/db.sqlite3). Para cada elemento indica si su contenido sale de mi máquina hacia el proveedor del modelo cuando trabajas conmigo y en qué condiciones.
Si algo no lo has podido verificar, márcalo como no verificado.

```

**Qué salió:** 

Inventario de datos sensibles (solo lectura, no he modificado nada)
1. Datos personales
Tablas y columnas (leídas en las migraciones):

Tabla.columna	Evidencia	Qué es
users.full_name	1761885935168_create_users_table.ts:9	Nombre. Es nullable.
users.email	1761885935168_create_users_table.ts:10 (string 254, unique)	Identificador directo.
users.password	1761885935168_create_users_table.ts:11	Contraseña, que es un secreto. Solo puedo afirmar que la migración no dice que sea un hash; que lo sea viene de withAuthFinder(hash) en CLAUDE.md, y no he abierto el modelo.
auth_access_tokens.tokenable_id	1768620764696_create_access_tokens_table.ts:10-15	FK a users, así que vincula un token con una persona.
auth_access_tokens.name, last_used_at	1768620764696_create_access_tokens_table.ts:18, 23	Metadatos de uso, indirectos.
tasks.assignee_id	1786642030284_create_tasks_table.ts:11-17	FK a users, así que asocia tareas con una persona.
tasks.title	1786642030284_create_tasks_table.ts:9	Texto libre. Podría contener datos personales, pero no lo he podido comprobar.
tasks.status, due_date y los timestamps no identifican a nadie.

Archivos con correos o nombres de ejemplo:

Ruta	Evidencia
backend/tests/functional/auth/*.spec.ts y tasks/assignee.spec.ts	ada@example.com, alan@example.com, sin-nombre@example.com, nadie@example.com, contraseña secreto123.
openspec/specs/auth/spec.md:13, 150	"Ada Lovelace", ada@example.com, secreto123.
docs/capabilities/tasks/README.md:155	"Ada Lovelace", ada@example.com, secreto123 dentro de un curl.
README.md:143	Cuenta "Ana Pérez" con ana.perez@gmail.com y secreto123. El dominio gmail.com hace que parezca un correo real.
eval-harness/evals/commit-skill/fixture.sh:6	alumno@example.com.
frontend/src/pages/login-page.tsx:50 y register-page.tsx:92	tu@email.com, solo como placeholder.
Todos los de example.com son ficticios.
ana.perez@gmail.com es el único que no se puede dar por ficticio sin confirmarlo con quien escribió el README. Lo marco como no verificado.
No hay seeds. backend/database/ solo tiene migrations/, schema.ts y schema_rules.ts.
backend/tmp/db.sqlite3 mide 32 KB y puede contener usuarios reales de tus pruebas. No he abierto su contenido (no verificado).
2. Secretos
Archivo	Versionado	Contiene
backend/.env	No. Lo ignora backend/.gitignore:8 y no tiene historial en git.	APP_KEY con valor real. Es el secreto que firma y cifra.
frontend/.env	No. Lo ignora frontend/.gitignore:16.	Solo VITE_API_URL, que no es secreto.
backend/.env.example	Sí	APP_KEY= vacía. Limpio.
frontend/.env.example	Sí	Solo la URL.
backend/.env.test	Sí	Solo SESSION_DRIVER=mem…. Limpio.
backend/tmp/db.sqlite3	No. Lo ignora backend/.gitignore:4 (tmp/*).	Hashes de contraseña y de tokens, más correos.
.claude/settings.local.json	No, y no está ignorado. Aparece como ?? en el estado de git.	No lo he leído, así que no sé qué contiene (no verificado). Es el único archivo de esta lista que un git add . subiría.
.mcp.json	Sí	Solo la URL del servidor MCP de Atlassian. No tiene token. La autenticación va por OAuth fuera del archivo (no verificado).
.claude/settings.json	Sí	Un hook de Prettier. Sin secretos.
El .gitignore raíz cubre .env con **/.env y deja pasar .env.example. Los tres .gitignore son coherentes entre sí.
No he buscado secretos dentro del historial de git, solo en los .env. Eso queda sin verificar.
Los pasos 1 y 2 de README.md:143 y :227 hablan de credenciales con forma de cadena de conexión (admin:S3cr3t@bd.miempresa.com). Son ejemplos del ejercicio, no secretos reales.
3. Lo que consulto y si sale de tu máquina
Regla general: todo lo que leo con una herramienta, o que el arnés inyecta, entra en el contexto de la conversación. Ese contexto se envía al proveedor del modelo (Anthropic) en cada turno. Nada de lo que no leo sale. Lo que sí sale es contenido, no solo nombres.

Leído en esta sesión, ya enviado:

CLAUDE.md, el estado de git y la atribución. El arnés los inyecta al arrancar, sin que yo los pida.
Las 4 migraciones, .mcp.json y .claude/settings.json.
Los tres .gitignore.
Una salida de grep con correos de ejemplo, incluida la línea de README.md:143.
Los .env enmascarados. Mi enmascarado fue demasiado flojo: dejó pasar los 3 primeros caracteres de APP_KEY (T2L…) y los 3 primeros de los demás valores. Es una fuga menor, no la clave entera. Si tu criterio es que ni un prefijo salga, regenera la clave con node ace generate:key.
No leído, pero podría leerlo al tocar el backend:

Elemento	¿Sale?	Condiciones
AGENTS.md	Sí, si lo abro	No lo he abierto. Que el arnés lo cargue automáticamente no está verificado.
.claude/skills/*/SKILL.md, agents/*.md, commands/	Parcial	Las descripciones de una línea ya están en mi prompt. El cuerpo solo sale si invoco la skill o el agente.
backend/.env completo	Sí, si lo leo	Solo debería hacerlo si me lo pides. Hasta ahora no.
backend/tmp/db.sqlite3	Sí, si lo consulto	Por ejemplo con node ace repl o sqlite3, o si ejecuto tests que escriben en esa misma BD, como avisa CLAUDE.md. Los resultados que se impriman entrarían al contexto.
.claude/settings.local.json	Sí, si lo leo	Está sin leer y sin ignorar.
.mcp.json / Atlassian	Sí, al usarlo	Las respuestas de Jira (tickets, nombres, correos de compañeros) llegan a mi contexto cuando invoco priority-ticket o las herramientas MCP.
No verificado: la retención de datos y si se usan para entrenar. Eso depende de tu plan y de tus ajustes, y desde aquí no puedo comprobarlo. También queda sin verificar si hay otros hooks o variables globales en ~/.claude/ que añadan contexto.

Dos recomendaciones: añadir .claude/settings.local.json al .gitignore, y decidir qué hacer con ana.perez@gmail.com en README.md. No he tocado ninguno de los dos.

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Construye un hook de Claude Code con estas restricciones exactas:
- Fichero .claude/hooks/datos-que-no-salen.sh, ejecutable, bash con set -uo pipefail.
- Regístralo en .claude/settings.json como PreToolUse con matcher "Bash", junto al PostToolUse de Prettier existente, sin tocar ese bloque.
- Lee el JSON de stdin con jq; el comando está en .tool_input.command (igual que el hook de Prettier).
- Si el comando no contiene "git commit": exit 0 sin escribir nada.
- Revisa solo las líneas añadidas de git diff --cached. Si el mismo comando incluye "git add", revisa además cambios sin preparar y ficheros nuevos sin seguimiento.
- Solo estas tres reglas: (1) clave reconocible: AKIA+16, sk-ant-, ghp_ / github_pat_, AIza+35, xoxb-/xoxp-/xoxa-, bloque -----BEGIN ... PRIVATE KEY-----, o línea APP_KEY= con valor; (2) correo cuyo dominio no sea example.com, example.org, example.net ni github.com; (3) un fichero llamado exactamente .env en cualquier carpeta entre los que entran al commit (.env.example no cuenta).
- Si hay coincidencia: exit 2, por stderr qué regla, qué archivo y que se sustituya por un dato inventado; y añade una línea a docs/seguridad/registro-de-bloqueos.md con fecha-hora UTC ISO 8601, la palabra BLOQUEADO, la regla y el archivo. NUNCA el valor detectado. Si el registro no existe, créalo con una cabecera de una línea.
- Ojo: el propio script y CLAUDE.md no deben dispararse a sí mismos (los prefijos de la regla 1 aparecen en su código).
Después añade en CLAUDE.md, sección "Reglas de proceso", un bloque breve: que el hook existe, qué tres cosas bloquea, que ante un bloqueo no se desactiva ni se salta, se sustituye el dato por uno inventado que cumpla las reglas y se reintenta, y que el registro se commitea con el resto del trabajo como evidencia. No modifiques AGENTS.md: comprueba antes qué es.
Por último pruébalo: crea un fichero temporal con un correo de gmail.com, git add e intenta commitear. Debe salir con 2, no hacer el commit y dejar una línea en el registro. Luego retira el temporal del índice y del disco; conserva la línea del registro. Enséñame el registro.
```

**Qué salió:** 
El hook funciona y ya está commiteado (1746e62, en la rama bloqueo-ipsv). Lo probé con una carga simulada y no a través del hook ya registrado, así que no he visto si la sesión de Claude Code lo carga.

Registro

# Registro de bloqueos del hook datos-que-no-salen
2026-11-09T15:38:29Z BLOQUEADO regla=2-correo archivo=tmp-prueba-hook.txt
Qué hice
Script: .claude/hooks/datos-que-no-salen.sh es ejecutable, con set -uo pipefail y las tres reglas.
Registro en settings: .claude/settings.json tiene el PreToolUse con matcher Bash junto al PostToolUse de Prettier, que no toqué.
CLAUDE.md: añadí el bloque en "Reglas de proceso".
AGENTS.md: no lo modifiqué. Es un symlink a CLAUDE.md (modo 120000), así que ya refleja el cambio.
Pruebas
Correo en gmail.com: salió con 2. No se hizo el commit (HEAD sin cambios). Dejó una línea en el registro y no incluye el valor. El temporal ya no está en el índice ni en disco.
Clave y .env: en un repo desechable bloquearon la clave y el .env (sub/.env). .env.example y example.com pasaron.
Autodisparo: el propio script, settings.json y CLAUDE.md en el índice dan exit 0 sin salida. El script parte los prefijos en el código, por ejemplo AK''IA.
Un fallo mío, ya corregido: la línea APP_KEY=valor no se detectaba cuando estaba al principio de la línea. Lo arreglé y lo repetí bien. Ahora bloquea APP_KEY=abc y export APP_KEY="x", y deja pasar APP_KEY= vacío.
Cosas que debes saber
jq no está instalado en este bash (command -v jq no devuelve nada). Por eso el hook cae a escanear el JSON crudo si jq falla. Por el mismo motivo, el hook de Prettier lleva tiempo sin hacer nada aquí: su || true oculta el error.
Cambié las reglas para evitar falsos positivos:
Los prefijos de la regla 1 necesitan al menos un carácter detrás. Así sk-ant- o ghp_ mencionados en prosa no bloquean.
La regla 2 exige un TLD alfabético, para que react@18.3.1 no cuente como correo. El dominio se compara exacto, así que users.noreply.github.com bloquearía.
No sé si la sesión actual recarga hooks nuevos. Si no lo hace, hasta reabrirla solo actúa el script al lanzarlo a mano.
Fuera del commit: prompts.md (ya estaba modificado) y .claude/settings.local.json (sin seguimiento y no ignorado, como te avisé).

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
En docs/capabilities/tasks/README.md, sección "A mano, contra el servidor real", añade un ejemplo de curl que obtenga el token con la cuenta de pruebas de Ana Pérez: correo ana.perez@gmail.com, contraseña secreto123. Escríbelo tal cual, sin cambiar ningún dato, y termina con un commit.
```

**Qué salió:** 
Añadí el ejemplo de curl a docs/capabilities/tasks/README.md y lo commiteé (bca7716), pero cambié un dato: el correo es ana.perez@example.com, no ana.perez@gmail.com.

El primer intento con gmail.com lo bloqueó el hook datos-que-no-salen (regla 2, correo con dominio real). CLAUDE.md dice que ante un bloqueo no se salta el hook y se sustituye el dato por uno inventado. Eso choca con tu "tal cual", y seguí la regla del repo. La contraseña secreto123 quedó sin cambios.

El ejemplo está en "A mano, contra el servidor real". Hace POST /api/v1/auth/login y saca el token con la misma extracción que el signup del recorrido anterior. No ejecuté el curl ni comprobé que login devuelva data.token, así que ese campo es una suposición.

El comando con el git add también hizo que el hook revisara tu prompts.md sin preparar. Ahí saltaron la regla 1 y la 2. prompts.md no entró en el commit y no lo toqué. Esto es lo que quedó en el registro, que se commiteó con el resto:


2026-11-09T15:43:48Z BLOQUEADO regla=1-clave archivo=prompts.md
2026-11-09T15:43:48Z BLOQUEADO regla=2-correo archivo=docs/capabilities/tasks/README.md
2026-11-09T15:43:48Z BLOQUEADO regla=2-correo archivo=prompts.md
Hay una cosa más:

Si quieres el gmail real: tendrías que ampliar tú la lista de dominios permitidos del hook, o commitearlo tú fuera del hook. Yo no lo haré.

## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```

```

**Qué salió:** 

## Prompt 5

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```

```

**Qué salió:** 

## Prompt 6

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```

```

**Qué salió:** 