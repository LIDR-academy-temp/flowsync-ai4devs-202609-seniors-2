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
Vamos a migrar el backend de SQLite a PostgreSQL. Todavía no escribas código.
Lee backend/config/database.ts, backend/start/env.ts, backend/.env.example,
backend/.env.test, backend/package.json, el Makefile y las migraciones de
backend/database/migrations. Dime:
1. Qué opciones del bloque de SQLite hay que conservar al pasar a PostgreSQL.
2. Qué variables de entorno faltan y dónde se validan.
3. Qué dependencias hay que instalar o retirar.
4. Cómo se conectan hoy las pruebas a la base de datos.
Cita fichero y línea en cada respuesta.
```

**Qué salió:** 
```
1. Qué conservar del bloque SQLite
De database.ts:

Se conserva migrations: { naturalSort: true, paths: ['database/migrations'] } (líneas 26-36). Es idéntico al bloque pg comentado (64-67).
Se conserva schemaGeneration con enabled: true y rulesPaths (38-48). El bloque pg comentado no lo trae, así que hay que copiarlo. Sin él, database/schema.ts deja de regenerarse y los modelos, que extienden esa clase, se rompen.
Se descarta client: 'better-sqlite3' y connection.filename (15-19). Los sustituye client: 'pg' con host, port, user, password y database.
Se descarta useNullAsDefault: true (24). Es solo para SQLite.
Cambia connection: 'sqlite' (línea 8) por el nombre nuevo. Si la conexión se llama pg, hay que descomentar el bloque de las líneas 55-69.
El bloque pg comentado usa env.get(...) (58-62), pero database.ts no importa env. Hay que añadir import env from '#start/env'.
debug: app.inDev (68) es opcional.
Las migraciones son compatibles con PostgreSQL sin cambios:

Solo usan increments, string, text, timestamp, date, references y onDelete('CASCADE') (users, tasks, access_tokens, due_date).
Con pg, increments pasa a ser serial.
Con pg, timestamp pasa a timestamptz. Conviene confirmar cómo lo trata el schema_rules.
2. Variables de entorno que faltan
Faltan DB_HOST, DB_PORT, DB_USER, DB_PASSWORD y DB_DATABASE.
No están en el schema de env.ts, que solo valida NODE_ENV, PORT, HOST, LOG_LEVEL, APP_KEY, APP_URL y SESSION_DRIVER.
Tampoco están en .env.example.
Se validan en env.ts, añadiéndolas al schema, por ejemplo DB_PORT: Env.schema.number() y DB_PASSWORD: Env.schema.string.optional().
El CLAUDE.md indica hacerlo con node ace env:add, que las añade a .env, .env.example y env.ts de una vez.
Hoy database.ts no lee ninguna variable. Es una ruta fija, app.tmpPath('db.sqlite3') (línea 18).
3. Dependencias
Instalar: pg, con npm install pg según el comentario de database.ts:53. Falta además @types/pg si TypeScript lo exige.
Retirar: better-sqlite3 (package.json:72).
Makefile:
clean borra tmp/db.sqlite3 y sus -wal y -shm (Makefile:115-118). Pasa a ser código muerto, y su texto "base de datos SQLite" queda desfasado.
setup ejecuta migrate (Makefile:32, 64-66). Hará falta un PostgreSQL levantado antes, y el repo no tiene docker-compose ni nada equivalente. Habrá que decidir cómo se levanta, por ejemplo con un target db.
.env.example se copia tal cual en make env, así que los valores por defecto de DB_* tienen que funcionar en local.
4. Cómo se conectan las pruebas hoy
Misma BD que desarrollo. .env.test solo fija SESSION_DRIVER=memory. No hay override de conexión ni de base de datos, y database.ts apunta siempre a tmp/db.sqlite3.
Aislamiento por transacción global. Cada grupo hace group.each.setup(() => testUtils.db().withGlobalTransaction()):
signup.spec.ts:16
login.spec.ts:11
session.spec.ts:11
initials.spec.ts:11
assignee.spec.ts:18
Servidor HTTP de prueba: bootstrap.ts:54.
Con PostgreSQL: las pruebas apuntarían a la BD de desarrollo salvo que .env.test defina DB_DATABASE propia, con las migraciones ya aplicadas. No hay ningún testUtils.db().migrate().
Discrepancia con el CLAUDE.md: dice que la capability tasks no tiene tests, pero existe assignee.spec.ts. Conviene corregirlo.
Antes de implementar hay una decisión abierta: ¿PostgreSQL local, o con Docker y un target nuevo en el Makefile?
```
## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Crea compose.yaml en la raíz del repositorio con estas restricciones exactas:
- Dos servicios: db (desarrollo) y db-test (pruebas).
- Imagen pgvector/pgvector:pg17 en los dos.
- Puertos 54410 para db y 54411 para db-test.
- db guarda los datos en un volumen con nombre; db-test va en memoria, sin
  volumen (usa tmpfs para el directorio de datos).
- Healthcheck en los dos servicios que solo dé "sano" cuando la base acepte
  conexiones TCP.
- Sin la clave version:.
No toques nada más. Enséñame el fichero y explícame el healthcheck.
```

**Qué salió:** 
```
He creado compose.yaml con esto:


services:
  db:
    image: pgvector/pgvector:pg17
    environment:
      POSTGRES_USER: flowsync
      POSTGRES_PASSWORD: flowsync
      POSTGRES_DB: flowsync
    ports:
      - "54410:5432"
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h 127.0.0.1 -p 5432 -U flowsync -d flowsync"]
      interval: 5s
      timeout: 3s
      retries: 10

  db-test:
    image: pgvector/pgvector:pg17
    environment:
      POSTGRES_USER: flowsync
      POSTGRES_PASSWORD: flowsync
      POSTGRES_DB: flowsync_test
    ports:
      - "54411:5432"
    tmpfs:
      - /var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h 127.0.0.1 -p 5432 -U flowsync -d flowsync_test"]
      interval: 5s
      timeout: 3s
      retries: 10

volumes:
  db-data:
El healthcheck

pg_isready pregunta a Postgres si acepta conexiones. Sale con 0 si las acepta y con otro código si no.
-h 127.0.0.1 es lo que hace que la comprobación sea por TCP. Sin -h, pg_isready usa el socket Unix local.
Esto importa en el primer arranque. El entrypoint de la imagen levanta un servidor temporal que escucha solo en el socket Unix, para ejecutar la inicialización. Después lo apaga y arranca el definitivo, que sí escucha en TCP. Sin -h, el contenedor se marcaría "sano" durante esa fase temporal, y un cliente que se conectara por el puerto publicado fallaría.
-U y -d evitan que pg_isready pruebe con un usuario o una base que no existen. Esa prueba no causa un fallo, pero sí deja líneas de error en el log.
Con interval: 5s, timeout: 3s y retries: 10 se dan unos 50 s de margen antes de marcar el contenedor como unhealthy.
Cosas que decidí yo (el enunciado no las fijaba):

Usuario, contraseña y nombres de base son valores de desarrollo inventados: flowsync para el usuario y la contraseña, flowsync para db y flowsync_test para db-test. Cámbialos si ya tienes otros en el .env.
Los dos servicios mapean al puerto interno 5432.
No he levantado los contenedores, así que el fichero no está probado.
```

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```

```

**Qué salió:** 