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

**Modelo:** Opus 5.5 xHigh
**Herramienta:** Claude Code

```
En vez de usar sqlite quiero que el proyecto use PostgreSQL.

Habrá dos contenedores docker para la base de datos, que se levantarán con docker compose, utilizando un fichero compos.yaml.
Un contenedor será "db" (para desarrollo) y el otro "db-test" (para pruebas).
Los puertos serán 54410 para desarrollo y 54411 para pruebas.
La imagen de los contenedores será "pgvector/pgvector:pg17"
El contenedor "db-test" no tiene ningún volumen asociado. Cada vez que arranque arrancará vacía.
Al contenedor "db" si que hay que asociarle un volumen. QUe será un directorio "pgsqlStorage" dentro del directorio "database".
Omite la clave version: de compose.yaml.
Cuando se generen tests de integración, se conectará al contenedor "db-test"
Añade atajos en el Makefile para arrancar y detener las bases, ejecutar las migraciones en ambas y lanzar las pruebas en la de "db-test"

No modifiques ninguna de las migraciones existentes.

```

**Qué salió:**
```
El proyecto ya funciona con PostgreSQL. Las 23 pruebas pasan contra db-test, y la comprobación de tipos y el lint del backend también están en verde. Está commiteado en motor-fjc (23423dd).

Qué se ha hecho
- compose.yaml (en la raíz, sin version:): dos servicios con pgvector/pgvector:pg17 y comprobación de salud.
  - db usa el puerto 54410 y guarda los datos en backend/database/pgsqlStorage. He añadido ese directorio al .gitignore para que no entre en el repo.
  - db-test usa el puerto 54411 y no tiene volumen. La imagen crea un volumen por su cuenta si no se indica nada, y ese volumen sobreviviría a un reinicio. Por eso sus datos van en memoria (tmpfs).
- Backend: config/database.ts se conecta a PostgreSQL (driver pg, que sustituye a better-sqlite3) con cinco variables DB_* que se comprueban al arrancar. .env apunta a db y .env.test apunta a db-test.
- Makefile (lo ves con make help):

| Atajo        | Qué hace                                                           |
|--------------|--------------------------------------------------------------------|
| make db-up   | Levanta las dos bases y espera a que estén sanas                   |
| make db-down | Las para                                                           |
| make migrate | Migra las dos; también hay migrate-dev y migrate-test por separado |
| make test    | Levanta las bases, migra db-test y corre la batería                |
  setup y start ahora levantan las bases primero.
- Migraciones: no he tocado ninguna; git diff sobre esa carpeta sale vacío.

Lo que he comprobado
- Bajé y subí las bases y migré las dos sin errores de conexión, así que el arranque sí espera a que estén sanas.
- Las pruebas usan de verdad la base de pruebas: tras cada ejecución, el contador de transacciones de flowsync_test sube 23 y el de flowsync sigue en 0.
- Corrí la batería dos veces seguidas y salió verde las dos.
- Al reiniciar db-test, vuelve con 0 tablas.
- backend/database/schema.ts no ha cambiado tras regenerarlo con PostgreSQL. Eso es justo lo que pide revisar el punto 2 de la Parte B; no lo he investigado.

Para que lo tengas en cuenta
- npm test a secas falla si db-test acaba de arrancar, ara la batería usa make test, que migra antes.
- Node: en tu shell manda el Node 22 de nvm, y el proyecto pide la 24 o superior. Lo he corrido todo con el Node 26 de Homebrew (/opt/homebrew/bin). Te conviene nvm install 24.
- backend/package-lock.json ya tenía cambios de antes ( han entrado en el commit mezclados con los de pg.frontend/package-lock.json también estaba modificado antes y lo he dejado fuera.
- README: no lo he tocado porque es generado; sí he puesto al día CLAUDE.md.
- PR: no lo he abierto. Según las reglas del repo, el Pl van al final de la unidad de trabajo, después de laParte B.
```


## Prompt 2

**Modelo:** Opus 5.5 xHigh
**Herramienta:** Claude Code

```
los tests de backend me están fallando "(cd backend && npm test)", ¿por qué?
```

**Qué salió:**
```
La causa es que db-test no tiene tablas (0 en public): fallan con relation "users" does not exist. Miro cómo hacer que la suite migre sola.
```

## Prompt 23

**Modelo:** Opus 5.5 xHigh
**Herramienta:** Claude Code

````
migra los datos que había en la BD sqlite antigua al nueva bd "db" de desarrollo
```

**Qué salió:**

```
He copiado los datos de la base antigua (backend/tmp/db.sqlite3) a la base de desarrollo db. Las tablas de db estaban vacías, así que no se ha pisado nada.

┌────────────────────┬───────────────────────┐
│       Tabla        │    Filas copiadas     │
├────────────────────┼───────────────────────┤
│ users              │ 1 (tu usuario)        │
├────────────────────┼───────────────────────┤
│ auth_access_tokens │ 1 (tu sesión abierta) │
├────────────────────┼───────────────────────┤
│ tasks              │ 3                     │
└────────────────────┴───────────────────────┘

Cómo lo he hecho:
- Ids: se conservan los mismos ids. He ajustado los contadores de ids, así que la próxima tarea que crees será la 4, sin choques con las que ya hay.
- Fechas: SQLite las guardaba de dos maneras.
  - En users y tasks eran texto sin zona horaria. He comprobado que estaban en UTC: el usuario y el token se crearon a la misma hora, las 22:54:32, guardada como texto en uno y en milisegundos en el otro. Así que se han cargado como UTC.
  - En auth_access_tokens eran milisegundos y se han convertido a fecha.
  - Las 3 tareas tenían la fecha de vencimiento vacía, y así siguen.
- Una sola transacción: si algo hubiera fallado, no habría quedado nada a medias.

Comprobación: emails, hashes de contraseña, hash del token, permisos, títulos y estados son idénticos en las dos bases; he comparado una huella de todos ellos y coincide. Así que deberías poder entrar con tu contraseña de siempre, y la sesión que tengas abierta en el navegador debería seguir valiendo. No lo he probado entrando de verdad, porque no tengo tu contraseña.

Lo que no ha cambiado:
- No he tocado la base SQLite: se queda como estaba, como copia.
- No hay nada que commitear, porque solo han cambiado datos y pgsqlStorage no entra en git.
- El SQL que he usado está en /private/tmp/claude-501/-Users-fernandojimenezcarrera-repositories-Lidr-flowsync-ai4devs-temp-202609-seniors-2/90e3ea35-12dc-4654-8f2d-cfffb9379f6e/scratchpad/sqlite-a-pg.sql. Incluye tu correo y el hash de tu contraseña, así que no lo subas a ningún sitio.
```