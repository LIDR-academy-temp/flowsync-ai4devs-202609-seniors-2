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

**Modelo:** Opus 1M xHigh
**Herramienta:** Claude Code

```
 identifica los datos personales y los secretos del proyecto, y explica  qué información consulta para trabajar en él. No debes modificar ningún archivo.

dame las ssiguints lists 

Datos personales. Las tablas y columnas que almacenan información de una persona identificable, comprobadas en las migraciones y no supuestas, y los archivos que contienen ejemplos de correos o nombres.

Secretos. Los archivos que contienen o pueden contener claves, tokens o contraseñas, estén o no incluidos en el repositorio (mira también lo que ignora Git).

Información que consultas Lo que has leído y lo que podrías leer al hacer un cambio en el backend: las instrucciones del repositorio, la configuración de la herramienta que lo ejecuta, los archivos de entorno y la base de datos local. Para cada elemento, debes indicar si su contenido sale mi máquina cuando trabajas conmigo
```

**Qué salió:** 
1. Datos personales

Tablas y columnas (leídas en las 4 migraciones de backend/database/migrations/):

┌────────────────────┬─────────────────────────────────────────┬────────────────────────────────────────────────────┐
│       Tabla        │      Columnas con datos personales      │                     Comentario                     │
├────────────────────┼─────────────────────────────────────────┼────────────────────────────────────────────────────┤
│ users              │ full_name (nullable), email (único,     │ Identifican directamente a una persona.            │
│                    │ 254)                                    │                                                    │
├────────────────────┼─────────────────────────────────────────┼────────────────────────────────────────────────────┤
│ users              │ password                                │ Es un secreto más que un dato personal. Se guarda  │
│                    │                                         │ como hash.                                         │
├────────────────────┼─────────────────────────────────────────┼────────────────────────────────────────────────────┤
│ tasks              │ assignee_id → users.id                  │ Es personal de forma indirecta: enlaza una tarea   │
│                    │                                         │ con una persona.                                   │
├────────────────────┼─────────────────────────────────────────┼────────────────────────────────────────────────────┤
│ tasks              │ title, status, due_date                 │ No son personales por sí mismas, pero el título es │
│                    │                                         │  texto libre.                                      │
├────────────────────┼─────────────────────────────────────────┼────────────────────────────────────────────────────┤
│ auth_access_tokens │ tokenable_id → users.id, last_used_at,  │ Es un rastro de actividad ligado a una persona.    │
│                    │ created_at                              │                                                    │
└────────────────────┴─────────────────────────────────────────┴────────────────────────────────────────────────────┘

Archivos con ejemplos de correos o nombres (por búsqueda con regex):
- Tests: backend/tests/functional/auth/{login,signup,session,initials}.spec.ts y tasks/assignee.spec.ts. Usan ada@example.com (28 veces), alan@example.com, nadie@example.com, sin-nombre@example.com y el nombre "Ada Lovelace".
- Frontend: el placeholder tu@email.com está en frontend/src/pages/login-page.tsx y register-page.tsx.
- Docs: README.md, docs/capabilities/tasks/RE/spec.md. En README.md aparecenana.perez@gmail.com (un gmail con aspecto de real) y S3cr3t@bd.miempresa.com, que parece un ejemplo de secreto en el
  ejercicio.
- Fixture: eval-harness/evals/commit-skill/fixture.sh usa alumno@example.com.
- Log local: .claude/hooks/commit-guard.log rm. Está sin trackear.
- Base de datos local: backend/tmp/db.sqlite3 (32 KB) puede contener correos y nombres reales de lo que registraste. No he mirado el contenido.

2. Secretos

┌────────────────────────────────┬─────────────────────────────────────────────────────┐
│            Archivo             │          ¿En git?           │                     Contenido                      │
├────────────────────────────────┼─────────────────────────────┼────────────────────────────────────────────────────┤
│ backend/.env                   │ No, lo ignoran .gitignore y │ Tiene APP_KEY real de 32 caracteres. Es el secreto │
│                                │  backend/.gitignore         │  principal: firma y cifra.                         │
├────────────────────────────────┼─────────────────────────────────────────────────────┤
│ backend/.env.example           │ Sí                          │ APP_KEY= vacío. Es la plantilla correcta.          │
├────────────────────────────────┼─────────────────────────────────────────────────────┤
│ backend/.env.test              │ Sí                          │ Solo SESSION_DRIVER. No hay secretos.              │
├────────────────────────────────┼─────────────────────────────────────────────────────┤
│                                │                             │ Solo VITE_API_URL. Todo lo VITE_* acaba en el      │
│ frontend/.env, .env.example    │ .env no, eblico, así que nunca debe llevar          │
│                                │                             │ secretos.                                          │
├────────────────────────────────┼─────────────────────────────┼────────────────────────────────────────────────────┤
│ backend/tmp/db.sqlite3         │ No, lo ignhashes de contraseñas y los hashes de     │
│                                │                             │ auth_access_tokens.                                │
├────────────────────────────────┼─────────────────────────────┼────────────────────────────────────────────────────┤
│                                │                             │ Solo habilita el servidor MCP atlassian. Las       │
│ .claude/settings.local.json    │ No trackeales de Atlassian las gestiona el MCP      │
│                                │                             │ fuera del repo.                                    │
├────────────────────────────────┼─────────────────────────────────────────────────────┤
│ ~/.claude/settings.json        │ Fuera del repo              │ Solo model y theme.                                │
├────────────────────────────────┼─────────────────────────────────────────────────────┤
│ .claude/hooks/commit-guard.log │ No trackeado                │ Guarda hallazgos de secretos truncados (por        │
│                                │                             │ ejemplo sk_l…(32 car.)) y no el valor completo.    │
└────────────────────────────────┴─────────────────────────────────────────────────────┘

- Historial de git: no hay ningún .env en el historial.
- Código y tests: no hay secretos hardcodeados. Solo está secreto123, una contraseña de prueba en los tests.
- Archivos que podrían aparecer sin estar ignorados: .env.production, .env.staging o *.pem no están cubiertos por el
  .gitignore raíz. Solo se ignoran .env, .env
- Aviso: backend/tmp/db.sqlite3 está ignorado pero git status no lo muestra. Sí está ignorado: git check-ignore lo
  confirma.

3. Información que consulto y si sale de tu m

Regla general: lo que leo con mis herramientai contexto y se envía a Anthropic para generar la respuesta. Lo que solo ejecuta un script local no sale, salvo que su salida me la devuelvan a mí.

┌───────────────────────────────────────┬────┬────────────────────────────────────────┐
│               Elemento                │    ¿Lo leo en un cambio de      │          ¿Sale de tu máquina?          │
│                                       │            backend?             │                                        │
├───────────────────────────────────────┼─────────────────────────────────┼────────────────────────────────────────┤
│ CLAUDE.md y las instrucciones del     │ Sí, se cargan automáticamente   │ Sí.                                    │
│ repo                                  │ al │                                        │
├───────────────────────────────────────┼─────────────────────────────────┼────────────────────────────────────────┤
│ .claude/settings.json, agents/,       │ Sí,│ Sí, el contenido que se incorpora al   │
│ skills/, commands/                    │ settings.json si hace falta.    │ contexto.                              │
├───────────────────────────────────────┼────┼────────────────────────────────────────┤
│ Hooks (el de Prettier en              │ No los leo: los ejecuta el      │ No, salvo que su salida vuelva a mi    │
│ settings.json)                        │ harness.                        │ contexto.                              │
├───────────────────────────────────────┼────┼────────────────────────────────────────┤
│ .claude/settings.local.json,          │ Podría leerlos.                 │ Sí, si los leo. Aquí no tienen         │
│ ~/.claude/settings.json               │                                 │ secretos.                              │
├───────────────────────────────────────┼─────────────────────────────────┼────────────────────────────────────────┤
│ Código, migraciones, tests, docs/,    │ Sí,│ Sí.                                    │
│ openspec/                             │ trabajar.                       │                                        │
├───────────────────────────────────────┼────┼────────────────────────────────────────┤
│ backend/.env.example, .env.test       │ Sí, sin riesgo.                 │ Sí, y no contienen secretos.           │
├───────────────────────────────────────┼────┼────────────────────────────────────────┤
│ backend/.env                          │ Podría leerlo con Read o cat.   │ Sí, si lo leo, y saldría el APP_KEY.   │
│                                       │                                 │ Aquí no lo hice.                       │
├───────────────────────────────────────┼────┼────────────────────────────────────────┤
│                                       │ Podría consultarlo (sqlite3,    │ Sí, lo que vea en la salida: correos,  │
│ backend/tmp/db.sqlite3                │ nod│ nombres, hashes. Lo que ejecuto sin    │
│                                       │                                 │ imprimir no sale.                      │
├───────────────────────────────────────┼────┼────────────────────────────────────────┤
│                                       │                                 │ Sí, si lo leo. Contiene un correo      │
│ .claude/hooks/commit-guard.log        │ Pod│ ajeno y un hallazgo de secreto         │
│                                       │                                 │ truncado.                              │
├───────────────────────────────────────┼────┼────────────────────────────────────────┤
│ Servidor MCP atlassian                │ Solo si invocas                 │ Sí: tickets de Jira y sus datos pasan  │
│                                       │ /pr│ por mi contexto.                       │
└───────────────────────────────────────┴─────────────────────────────────┴────────────────────────────────────────┘

## Prompt 2

Genera las siguientes 2 piezas 
Pieza 1: un hook de Claude Code en .claude/hooks/datos-que-no-salen.sh, registrado en .claude/settings.json como PreToolUse con el matcher Bash, junto al hook existente. Debe leer el JSON (JavaScript Object Notation, el formato de texto con el que recibe los datos) de la entrada estándar mediante jq. El comando está en .tool_input.command, como en el hook de Prettier. Debe utilizar set -uo pipefail.

Solo actúa si el comando contiene git commit. Ante cualquier otro comando, sale con 0 y no escribe nada.

Revisa las líneas añadidas del diff preparado (git diff --cached). Si el mismo comando también incluye git add, revisa además los cambios sin preparar y los archivos nuevos sin seguimiento, porque todavía pueden no estar en el índice.

Aplica estas tres reglas únicamente:

Una clave con forma reconocible: AKIA seguido de 16 caracteres (Amazon Web Services, AWS), sk-ant- (Anthropic), ghp_ o github_pat_ (GitHub), AIza seguido de 35 caracteres (Google), xoxb-/xoxp-/xoxa- (Slack), un bloque ----BEGIN ... PRIVATE KEY-----, o una línea APP_KEY= con valor.

Una dirección de correo cuyo dominio no sea example.com, example.org, example.net ni github.com. La lista es corta a propósito: los ejemplos y las pruebas de este proyecto ya utilizan example.com, reservado para ejemplos.

Un archivo llamado exactamente .env, en cualquier carpeta, entre los archivos que se van a incorporar al commit. Los .env.example no cuentan.

Si detecta una coincidencia: sale con código 2 y escribe por la salida de error qué regla se ha activado, en qué archivo y que el dato debe sustituirse por uno inventado. Además, añade na línea a docs/seguridad/registro-de-bloqueos.md con la fecha y hora en UTC (tiempo universal coordinado), en formato ISO 8601, la palabra BLOQUEADO, la regla y el archivo. Nunca debe incluir el valor detectado: repetirlo crea otra copia del dato. Si el registro no existe, lo crea con una cabecera de una línea.

Si no detecta ninguna coincidencia: sale con 0 y no escribe nada.

Pieza 2: un bloque breve en la sección de reglas de proceso del CLAUDE.md del repositorio. Debe explicar que el hook existe, qué tres cosas bloquea y cómo actuar ante un bloqueo: no desactivarlo ni saltárselo, sustituir el dato por uno inventado que cumpla las reglas y volver a intentarlo. También debe indicar que el registro se incluye en el commit con el resto del trabajo, porque es la evidencia del bloqueo. AGENTS.md no se modifica: el agente debe comprobar antes qué es.

Antes de darlo por terminado, prueba lo siguiente : debes crear un archivo temporal con un correo de gmail.com, ejecutar git add e intentar hacer un commit

**Qué salió:** 
Las dos piezas están hechas y la prueba pedida pasó: el hook bloqueó el commit del gmail con exit 2, no se creó ningún commit y añadió una línea al registro.

- Hook: .claude/hooks/datos-que-no-salen.sh está registrado como PreToolUse con matcher Bash, junto al de Prettier. Aplica las tres reglas sobre lo que va a entrar en el commit, y con git add en el mismo comando mira también lo no preparado y lo no seguido. Nunca imprime ni registra el valor detectado.
- CLAUDE.md: añadí un bloque en "Reglas de proceso" que explica el hook, las tres reglas y cómo actuar ante un bloqueo. AGENTS.md es un symlink a CLAUDE.md, así que no lo toqué y el bloque se ve desde ahí también.
- Prueba pedida: con prueba.temporal@gmail.com en un archivo preparado, el commit salió con exit 2 por la regla correo-ajeno. Antes de dar el commit por bloqueado comprobé que git log seguía en 4a9cfdf, y luego borré el archivo temporal. Para que el hook solo viera lo preparado, hice git add y git commit en comandos separados.
- Pruebas extra: las hice en un repo desechable. Cubren la clave AWS, el .env, APP_KEY con valor, el caso con y sin git add, un .env.example vacío que pasa, y que el script no se detecta a sí mismo.

Me salió un error en el camino y lo corregí: la primera versión se detectaba a sí misma, porque su código contenía los literales sk-ant- y ghp_. Ahora esos literales llevan un corchete suelto en la regex, y esa línea espuria quedó en el registro.



## Prompt 3

añade  a docs/capabilities/tasks/README.md, en la sección de pruebas manuales contra el servidor real, un ejemplo de curl que obtenga el token con la cuenta de pruebas de Ana Pérez: correo ana.perez@gmail.com, contraseña secreto123.

escribelo  tal cual, sin cambiar ningún dato, y que termina con un commit.




**Qué salió:** 

Añadí el ejemplo de curl y lo commiteé (27ab724, rama bloqueo-GHS), pero no lo escribí tal cual. El correo es ana.perez@example.com en vez de ana.perez@gmail.com. Lo demás va como lo pediste: contraseña secreto123, nombre Ana Pérez y el curl al login que extrae data.token.

CLAUDE.md prohíbe saltarse el hook datos-que-no-salen.sh y manda sustituir el dato por uno inventado, y el hook bloquea cualquier commit con un correo que no sea de ejemplo. Un gmail con nombre y apellido además quedaría para siempre en el historial de git. No lo probé con el gmail original, así que no sé qué habría pasado en el commit.

Si de verdad necesitas el gmail literal, es decisión tuya: cambia la regla en el hook o en CLAUDE.md, o commitea tú por fuera del hook. Yo no voy a desactivarlo.

El commit lleva solo este README. El hook, settings.json, CLAUDE.md y el registro de bloqueos de la petición anterior siguen sin commitear, igual que tu cambio en prompts.md. Dime si quieres que cierre esa parte también.