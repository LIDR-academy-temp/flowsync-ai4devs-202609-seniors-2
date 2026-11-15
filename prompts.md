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

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
Objetivo: Migrar el proyecto de SQLite a PostgreSQL en Docker, con una base de datos para desarrollo y otra para pruebas.

Restricciones:

- El archivo de Compose se llama `compose.yaml` y define dos servicios, `db` y `db-test`.

- Usa `pgvector/pgvector:pg17`, que incluye PostgreSQL 17 con la extensión pgvector.

- Usa los puertos **54410** para desarrollo y **54411** para pruebas.

- **La base de pruebas va en memoria, sin volumen**. Así, los datos de una ejecución no quedan guardados para la siguiente.

- **Configura una comprobación de salud en ambos servicios**. El arranque debe esperar a que las dos bases acepten conexiones. En el primer arranque, PostgreSQL todavía está inicializando la base cuando otros procesos pueden intentar conectarse.

- **Omite la clave** version: de `compose.yaml`. Está obsoleta y Docker muestra un aviso si la incluyes.

- Haz que la batería de pruebas se conecte a la base de pruebas mediante su propio archivo de entorno. El framework lo carga solo en ese entorno.

- Añade **atajos en el Makefile** para arrancar y detener las bases, ejecutar las migraciones en ambas y lanzar las pruebas.

- **Conserva intactas las migraciones existentes**. Si el agente propone modificar alguna, detente y anótalo como hallazgo.

Si tienes dudas sobre cómo hacer algo, pregúntame antes de ejecutar la acción. No hagas suposiciones. No hagas commit de los cambios y crees una rama nueva.
```

**Qué salió:** antes de tocar nada preguntó cuatro cosas: la rama, las credenciales, si quitar SQLite y el tipo de volumen. Después funcionó: 23/23 tests contra `db-test`, sin volumen (tmpfs) y sin tocar las migraciones. La última frase («no hagas commit… y crees una rama nueva») era ambigua y tuvo que preguntarla.

## Prompt 2

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
corrige la migracion en la base de datos db que no este debería migrar los datos tambien la db-test si que debe estar vacía
```

**Qué salió:** hizo un comando ace de importación desde SQLite. Al ejecutarlo descubrió que ningún comando de `backend/commands/` arranca (jsonschema 1.5.0 + Node 24.20, «Invalid URL»), un fallo previo. Se paró a preguntar.

## Prompt 3

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
@package.json restaura los paquetes sqlite no son necesarios para limigración?
```

**Qué salió:** quitó `better-sqlite3` y `@types/better-sqlite3` y pasó el comando a `node:sqlite`, que viene con Node 24.

## Prompt 4

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
vale registra el comando sin la validación
```

**Qué salió:** movió el comando a `app/commands/` y lo registró con un cargador en `adonisrc.ts`. Importó 1 usuario, 3 tokens y 5 tareas, idénticos fila a fila, y `db-test` siguió vacía.

## Prompt 5

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
se han migrado ya los datos ?
```

**Qué salió:** lo comprobó contando filas en SQLite, `db` y `db-test`.

## Prompt 6

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
no funciona la password del usuario migrado
```

**Qué salió:** el hash era idéntico byte a byte y el login respondía bien. La causa probable era el email: la cuenta está registrada con otro distinto del que se escribía.

## Prompt 7

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
migration:run donde se llama ?
```

## Prompt 8

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
puedes comparar los tipos de postgre y sqlite en las tablas y por no fue necesario el cambio de schema.ts
```

**Qué salió:** el generador traduce los tipos de los dos motores a los mismos tipos de TypeScript, y `schema_rules.ts` fija `status` y `due_date`. Al medir lo que devuelve el driver, `pg` da un `Date` para `due_date` donde SQLite daba texto.

## Prompt 9

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
Cómo se decide en el proyecto que una tarea es vencida?
```

**Qué salió:** la decisión está en `Task.isOverdueOn` (`dueDate < referenceDay`). Además, el comentario habla de tres condiciones y el código no comprueba el `status`.

## Prompt 10

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
falla en el detalle de las tareas al devolver las fechas el formato que devuelve de duedate parece no es el adecuado para el front
```

**Qué salió:** lo reprodujo: el JSON trae `…T00:00:00.000Z`, `formatDay` lanza `RangeError` e `isOverdue` sale siempre `false`. Propuso dos arreglos; quedó sin aplicar para medir antes los hallazgos.

## Prompt 11

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
vale vamos a poner los hallazgos primero, ayudame a crea una consulta para comparar si hay cambios en los datos sobre todo si se pierde precisión
```

**Qué salió:** hizo un script que vuelca SQLite a una tabla temporal de PostgreSQL y compara celda a celda. Contra `flowsync_dev` mezclaba la migración con las ediciones hechas después en la app.

## Prompt 12

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
ok creala
```

**Qué salió:** contra una importación limpia en una base temporal (`flowsync_cmp`), 0 de 9 filas cambian de valor y se conservan los milisegundos.

## Prompt 13

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
puedes listar los datos en sql lite y migrados a postrgre en una tabla para compararlos tal cual se guardan
```

**Qué salió:** tabla con las 71 celdas: 48 idénticas y 23 fechas con el mismo instante y distinta representación.

## Prompt 14

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
no hay due_date en ninguna lado orignalmente puedes insertar un valor en sqlite para ver como se migra?
```

**Qué salió:** lo probó sobre una copia de la SQLite. El valor se guarda bien en PostgreSQL, pero la app lo lee como `Date`: `isOverdue` sale `false` en una tarea vencida, y con TZ Madrid el día se corre al anterior.

## Prompt 15

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
vale ayudeme a completar los  @HALLAZGOS.md
```

## Prompt 16

**Modelo:** Opus 5.5 high 1.0M
**Herramienta:** Claude Code

```
@prompts.md rellena los prompts has usado opus 5.5 high 1.0M
```
