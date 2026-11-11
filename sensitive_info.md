# Información sensible en FlowSync

Inventario hecho sobre la rama `bloqueo-gc`. Los valores de secretos **no** se copian aquí: solo rutas y nombres de variable.

## 1. Datos personales

### Tablas y columnas (comprobadas en `backend/database/migrations/`)

| Tabla | Columna | Migración | Por qué es personal |
|---|---|---|---|
| `users` | `full_name` (nullable) | `1761885935168_create_users_table.ts` | Nombre de una persona |
| `users` | `email` (único, 254) | `1761885935168_create_users_table.ts` | Identifica a una persona |
| `users` | `password` | `1761885935168_create_users_table.ts` | Credencial (guardada con hash por `withAuthFinder(hash)`); ver también la lista 2 |
| `users` | `id`, `created_at`, `updated_at` | `1761885935168_create_users_table.ts` | Identificador y metadatos ligados a la persona |
| `tasks` | `assignee_id` → `users.id` | `1786642030284_create_tasks_table.ts` | Vincula a una persona con su trabajo; no es un dato personal por sí sola, pero con `users` sí |
| `tasks` | `title`, `status`, `due_date` | `1786642030284_*` y `1786644500000_add_due_date_to_tasks_table.ts` | Texto libre escrito por el usuario: puede contener datos personales, aunque la columna no lo exija |
| `auth_access_tokens` | `tokenable_id` → `users.id`, `last_used_at`, `created_at`, `expires_at` | `1768620764696_create_access_tokens_table.ts` | Actividad de sesión de una persona concreta |

`database/schema.ts` (autogenerado) coincide con las migraciones: `users` expone `email`, `fullName`, `password`.

### Archivos con ejemplos de correos o nombres

Todos usan el dominio reservado `example.com`, salvo donde se indica.

- `backend/tests/functional/auth/signup.spec.ts`, `login.spec.ts`, `session.spec.ts`, `initials.spec.ts`: `ada@example.com`, `alan@example.com`, `nadie@example.com`, `sin-nombre@example.com`.
- `backend/tests/functional/tasks/assignee.spec.ts`: `ada@example.com`, `sin-nombre@example.com`.
- `frontend/src/pages/login-page.tsx`, `register-page.tsx`: marcador `tu@email.com`.
- `openspec/specs/auth/spec.md`, `docs/capabilities/tasks/README.md`: `ada@example.com`.
- `eval-harness/evals/commit-skill/fixture.sh`: `alumno@example.com` y el nombre `Alumno`.
- `README.md` (líneas ~143 y ~227): **`ana.perez@gmail.com`** con el nombre "Ana Pérez" y una contraseña de ejemplo. Es un caso inventado para el ejercicio del hook, pero es el único con un dominio real (`gmail.com`) y por tanto parece una persona.
- Referencias a `fullName` / `full_name` (código, no datos): `backend/app/models/user.ts`, `validators/user.ts`, `transformers/user_transformer.ts` y `task_assignee_transformer.ts`, `controllers/new_account_controller.ts`, `app/openapi/schemas.ts`, `docs/api/openapi.json`, `frontend/src/lib/{api,types}.ts` y las páginas de perfil/registro/tareas.

### Base de datos local con datos reales

`backend/tmp/db.sqlite3` puede contener usuarios reales o de prueba (correo, nombre, hash). No he podido contar filas (no hay `sqlite3` instalado) ni la he abierto. Los tests functional escriben en este mismo fichero (ver `CLAUDE.md`).

## 2. Secrets

| Archivo | Qué contiene o puede contener | ¿En Git? |
|---|---|---|
| `backend/.env` | `APP_KEY` (clave de cifrado de la app, `Env.schema.secret()`); también `PORT`, `HOST`, `APP_URL`, etc. | **No**: ignorado por `.gitignore` raíz y `backend/.gitignore` |
| `frontend/.env` | Solo `VITE_API_URL`. Todo lo que lleva el prefijo `VITE_` acaba en el bundle público, así que aquí **nunca** deben ir secretos | **No**: ignorado |
| `backend/.env.example` | Plantilla con `APP_KEY=` y el resto de nombres; debe tener el valor vacío o de relleno | Sí (excepción `!**/.env.example`). Conviene confirmar que `APP_KEY` no lleva un valor real |
| `backend/.env.test` | Solo `SESSION_DRIVER` | Sí. Sin secretos hoy |
| `frontend/.env.example` | Solo `VITE_API_URL` | Sí |
| `backend/tmp/db.sqlite3` | Hashes de contraseña (`users.password`) y hashes de access tokens (`auth_access_tokens.hash`) | **No**: ignorado (`tmp/*`) |
| `backend/app/controllers/access_tokens_controller.ts` | No guarda secretos, pero **devuelve** el token en claro (`token.value!.release()`) en la respuesta de login. Aparece en logs o capturas si se registra la respuesta | Sí |
| `backend/config/database.ts` (comentado), `config/session.ts` | Variables previstas pero no activas: `DB_PASSWORD`, `DB_USER`, `LIBSQL_AUTH_TOKEN`. Si alguien las activa, irán a `.env` | Sí (solo nombres) |
| `.github/workflows/revisor.yml` | Referencia `secrets.CLAUDE_CODE_OAUTH_TOKEN` y `secrets.GITHUB_TOKEN`; los valores viven en GitHub, no en el repo | Sí (solo nombres) |
| `.mcp.json` | URL del servidor MCP de Atlassian; sin credenciales (usa OAuth) | Sí |
| `.claude/settings.local.json` | Solo `enabledMcpjsonServers`. Sin secretos hoy, pero es el sitio donde se suelen guardar permisos y variables locales | **No**: ignorado por la regla global `~/.config/git/ignore`, no por el repo |
| `~/.claude/` (fuera del repo) | `history.jsonl`, `projects/`, `sessions/`, `file-history/`, `shell-snapshots/`, `mcp-needs-auth-cache.json`, `settings.json`, y las credenciales OAuth de la herramienta y del MCP de Atlassian | Fuera del repo |
| `README.md` (~línea 227) | Contraseña de ejemplo dentro de una URL de conexión inventada (`S3cr3t@bd.miempresa.com`) y `secreto123` | Sí. Son ficticias, pero tienen forma de secreto real y dispararían un escáner |

Lo que Git ignora y puede esconder secretos: `.env`, `.env.local`, `.env.production.local`, `.env.development.local`, `**/tmp/*`, `*.log`, `coverage/`, `evals/results/` e `eval-harness/evals/results/`. Que estén ignorados significa que **no se commitean**, no que estén protegidos: siguen en disco y cualquier herramienta con acceso al directorio los puede leer.

## 3. Información que consulto para trabajar en el backend

Criterio para "sale de la estación": todo lo que leo con una herramienta pasa a formar parte del contexto y **se envía a la API de Anthropic** para generar la siguiente respuesta. Lo que solo ejecuto en local sin que su contenido vuelva a mí, no sale.

| Qué | Dónde | ¿Sale de la estación? |
|---|---|---|
| Instrucciones del repo | `CLAUDE.md` (y `AGENTS.md`, enlace simbólico), `README.md`, `HALLAZGOS.md`, `REVIEW.md`, `prompts.md`, `docs/` | **Sí.** `CLAUDE.md` se adjunta entero al inicio de cada sesión; el resto, cuando lo leo |
| Código y especificaciones | `backend/app/`, `start/`, `config/`, `database/migrations/`, `database/schema.ts`, `.adonisjs/`, `tests/`, `openspec/`, `docs/api/openapi.json` | **Sí**, al leerlos. Los tests contienen los correos de ejemplo de la lista 1 |
| Configuración de la herramienta (repo) | `.claude/settings.json` (hook de Prettier), `.claude/skills/`, `.claude/commands/`, `.claude/agents/` | **Sí**: los skills y agentes que invoco se cargan en el contexto. El hook se ejecuta en local y su salida no vuelve a mí salvo que falle |
| Configuración de la herramienta (usuario) | `.claude/settings.local.json`, `~/.claude/settings.json`, `.mcp.json` | **Sí**, lo que se aplica al contexto (p. ej. la lista de servidores MCP y skills disponibles). Las credenciales OAuth de `~/.claude/` no las leo ni se envían |
| Entorno | `backend/.env`, `frontend/.env` | **Sí si los abro** con Read. `start/env.ts` los lee el proceso de Node en local, y eso no sale. Para esta tarea solo mostré los nombres de variable con los valores enmascarados. Aun así, un `cat backend/.env` mandaría `APP_KEY` a Anthropic |
| Entorno de ejemplo | `backend/.env.example`, `.env.test` | **Sí**, al leerlos; sin secretos |
| Base de datos local | `backend/tmp/db.sqlite3` | **No sale por sí sola**: es un fichero binario que solo se envía si lo leo o consulto (p. ej. con `sqlite3` o `node ace repl`) y el resultado vuelve a mí. Esa consulta sí enviaría correos, nombres y hashes. Los tests la escriben pero la salida de los tests solo contiene lo que ellos imprimen |
| Jira / Atlassian | Skill `priority-ticket` y servidor MCP `atlassian` | **Sí, en dos sentidos**: la petición va a Atlassian y los tickets que traigo (título, descripción, personas asignadas) entran en el contexto y llegan a Anthropic |
| Historial y memoria de sesión | `~/.claude/history.jsonl`, `projects/…/` y su memoria | Se guarda en disco local. Se me carga lo que está en `MEMORY.md` y se envía con el contexto |
| Git | `git log`, `git status`, diffs | **Sí**, la parte que leo. Incluye nombre y correo de autores (datos personales) |
| Salida de comandos | `npm test`, `node ace list:routes`, `npm run lint`… | **Sí**: lo que imprimen vuelve al contexto. Un test que muestre la respuesta de login incluiría un token de acceso |
| Datos de la cuenta | Correo `gcanton@aluar.com.ar` (adjunto automáticamente) | Ya forma parte del contexto; no lo envío a servicios ajenos |

### Para trabajar con menos exposición

- No pedirme leer `backend/.env` ni `tmp/db.sqlite3`; si hace falta un dato, que sea la variable concreta.
- Añadir a `.claude/settings.json` reglas `permissions.deny` para `Read(./backend/.env)`, `Read(./frontend/.env)` y `Read(./backend/tmp/**)`. **No lo he hecho** porque me pediste no tocar ficheros existentes.
- Usar solo dominios `example.*` en datos de prueba; el `README.md` con `gmail.com` es la excepción.
