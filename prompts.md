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

 migra el proyecto de SQLite a PostgreSQL en Docker, con una base de datos para desarrollo y otra para pruebas.
 
 El archivo de Compose se llama compose.yaml y define dos servicios, db y db-test.

Usa pgvector/pgvector:pg17, que incluye PostgreSQL 17 con la extensión pgvector.

Usa los puertos 54410 para desarrollo y 54411 para pruebas.

La base de pruebas va en memoria, sin volumen. Así, los datos de una ejecución no quedan guardados para la siguiente.

Configura una comprobación de salud en ambos servicios. El arranque debe esperar a que las dos bases acepten conexiones. En el primer arranque, PostgreSQL todavía está inicializando la base cuando otros procesos pueden intentar conectarse.

Omite la clave version: de compose.yaml. Está obsoleta y Docker muestra un aviso si la incluyes.

Haz que la batería de pruebas se conecte a la base de pruebas mediante su propio archivo de entorno. El framework lo carga solo en ese entorno.

Añade atajos en el Makefile para arrancar y detener las bases, ejecutar las migraciones en ambas y lanzar las pruebas.
```

**Qué salió:** (opcional, una línea) funcionó a la primera / tuve que insistir / me inventó una La migración a PostgreSQL está hecha y verificada: make test pasa los 23 tests, y typecheck y lint salen limpios. No he hecho commit. Por las reglas del proyecto queda para /commit, y al tocar solo la BD no cambian rutas, controladores ni transformers.

- compose.yaml (raíz, sin version:) define db en el puerto 54410 y db-test en el 54411, ambos con pgvector/pgvector:pg17.
  - db usa un volumen. db-test usa tmpfs, sin volumen.
  - El healthcheck de ambos es pg_isready -h 127.0.0.1. Fuerza TCP porque, en el primer arranque, el servidor temporal de inicialización solo escucha en el socket unix, y sin -h daría "listo" demasiado pronto.
  - make db-up usa docker compose up -d --wait, así que espera a que las dos bases estén healthy.
  - Los puertos solo se publican en 127.0.0.1.
- Backend: instalé pg y quité better-sqlite3. config/database.ts usa la conexión pg con variables DB_*, que start/env.ts valida y .env.example documenta.
- Entorno de pruebas: backend/.env.test apunta a DB_PORT=54411 y DB_DATABASE=flowsync_test. Adonis lo carga solo con NODE_ENV=test. Los tests ya no tocan los datos de desarrollo: comprobé que la BD de desarrollo sigue con 0 usuarios tras la batería.
- Makefile:
  - db-up y db-down arrancan y paran las bases.
  - migrate-all migra desarrollo y pruebas.
  - test migra la base de pruebas y lanza la batería.
  - setup ahora incluye db-up.

Cosas que debes saber:

1. Regresión corregida con date. pg devuelve las columnas date como objetos Date, y Task.isOverdue compara dueDate como texto ISO. Con SQLite funcionaba, y con Postgres habría fallado en silencio. Añadí en config/database.ts un parser de tipos que devuelve YYYY-MM-DD como texto. No hay tests de tasks, así que esto no está cubierto por ninguna prueba.
2. database/schema.ts no cambió al regenerarse sobre Postgres.
3. Pendiente de tu decisión: no migré los datos del SQLite antiguo. Las bases nuevas empiezan vacías.
4. Documentación: actualicé CLAUDE.md y el comentario de signup.spec.ts. El target clean del Makefile solo borra el SQLite antiguo y no toca las bases Docker.

Cuando termines la unidad de trabajo, quedan el PR y la pasada de adversarial-reviewer.


