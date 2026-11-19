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

**Modelo:** Sonnet 5.5 with xhigh effort
**Herramienta:** Claude Code

```
Requerimos migrar las bases de datos de SQLite a **PostgreSQL corriendo en Docker**, con **dos** bases de datos: una de desarrollo y otra de pruebas. Tenemos ciertas restricciones que no son negociables y debes respertar.

**Las restricciones son estas, y no son negociables**:

- El fichero de Compose se llama **`compose.yaml`** y los dos servicios se llaman **`db`** y **`db-test`**.
- La imagen es **`pgvector/pgvector:pg17`**. Es la imagen oficial de PostgreSQL con la extensión de vectores ya dentro.
- Los puertos son **54410** para desarrollo y **54411** para pruebas. **No el 5432**: quien tenga un PostgreSQL suyo levantado se lo encontraría ocupado, y el error que vería no menciona a Docker por ningún lado.
- **La base de pruebas va en memoria, sin volumen.** Es efímera a propósito: una batería de pruebas que depende de lo que dejó la anterior no es una batería de pruebas.
- **Los dos servicios llevan comprobación de salud**, y el arranque espera a que estén sanos. La propia imagen avisa de que, la primera vez, crea la base y **no acepta conexiones mientras tanto**, y de que eso rompe a quien levanta varios contenedores a la vez.
- **Sin la clave `version:`** en el fichero de Compose: está obsoleta y Docker imprime un aviso.
- La batería de pruebas apunta a la otra base por su propio fichero de entorno, que el framework carga solo cuando el entorno es de pruebas.
- Y deja **atajos en el Makefile** para levantar las bases, pararlas, migrar **las dos** y correr las pruebas.

**Ninguna migración existente se toca.** S
```

**Qué salió:** (opcional, una línea) funcionó a la primera / tuve que insistir / me inventó una ruta que no existe.

Funciono a la primera.

Requerimos migrar las bases de datos de SQLite a PostgreSQL corriendo en Docker, con dos bases de datos: una de desarrollo y otra de pruebas. Tenemos ciertas restricciones que no son negociables y debes respertar.

  Las restricciones son estas, y no son negociables:

  - El fichero de Compose se llama compose.yaml y los dos servicios se llaman db y db-test.
  - La imagen es pgvector/pgvector:pg17. Es la imagen oficial de PostgreSQL con la extensión de vectores ya dentro.
  - Los puertos son 54410 para desarrollo y 54411 para pruebas. No el 5432: quien tenga un PostgreSQL suyo levantado se lo encontraría ocupado, y el error que vería no menciona a Docker por ningún lado.
  - La base de pruebas va en memoria, sin volumen. Es efímera a propósito: una batería de pruebas que depende de lo que dejó la anterior no es una batería de pruebas.
  - Los dos servicios llevan comprobación de salud, y el arranque espera a que estén sanos. La propia imagen avisa de que, la primera vez, crea la base y no acepta conexiones mientras tanto, y de que eso rompe a quien levanta varios contenedores a la vez.
  - Sin la clave version: en el fichero de Compose: está obsoleta y Docker imprime un aviso.
  - La batería de pruebas apunta a la otra base por su propio fichero de entorno, que el framework carga solo cuando el entorno es de pruebas.
  - Y deja atajos en el Makefile para levantar las bases, pararlas, migrar las dos y correr las pruebas.

  Ninguna migración existente se toca. S

Estoy en motor-cedl, que es una rama de trabajo, así que sigo en ella. Tu mensaje termina cortado en "Ninguna migración existente se toca. S". Sigo con lo que sí está claro y reviso al final si falta algo. Empiezo mirando el estado actual.

  Listed 1 directory, ran 4 shell commands

Antes de tocar nada, saco la línea de partida de la batería. También miro el hook de commits, el orden en que Adonis carga los ficheros de entorno y las opciones de env:add.

  Ran 3 shell commands

Línea de partida: 23 pruebas en verde sobre SQLite. La shell se quedó en backend/, así que uso rutas absolutas. Ahora leo el hook y el cargador de entorno.

  Ran 1 shell command

El hook solo bloquea un fichero llamado exactamente .env, así que .env.test (que ya está versionado) pasa. Confirmo la precedencia del cargador y cómo fija NODE_ENV el entrypoint de tests.

  Ran 1 shell command

Ya tengo lo necesario: la carga lee .env.test antes que .env, y bin/test.ts fija NODE_ENV=test. Voy a escribir el Compose con la comprobación de salud por TCP (-h 127.0.0.1), porque el servidor temporal de la primera inicialización solo escucha por socket Unix. · summary

● Write(~/lidr/session-10/flowsync-ai4devs-202609-seniors-2/compose.yaml)
Wrote 58 lines to ~/lidr/session-10/flowsync-ai4devs-202609-seniors-2/compose.yaml
# Bases de datos de FlowSync: PostgreSQL en Docker, una de desarrollo y otra de pruebas.
#
# Se manejan con los atajos del Makefile (`make db-up`, `make db-down`, `make migrate`,
# `make test`). Las credenciales son de mentira y solo valen en local: los puertos escuchan
# únicamente en 127.0.0.1.
#
# Sin la clave `version:` a propósito: está obsoleta y Docker imprime un aviso.

name: flowsync
… +49 lines

  Ran 1 shell command

El diff del lockfile es grande. Compruebo que solo sale better-sqlite3 con sus dependencias de compilación, y que no se han movido otras versiones por el camino.

  Ran 2 shell commands

El lockfile ya está limpio, con las dependencias de pg dentro y las de better-sqlite3 fuera. Ahora me ocupo de las variables de entorno con env:add, como indica CLAUDE.md. · summary

  Ran 1 shell command

env:add deja .env.example con valores vacíos, así que le pongo los de desarrollo para que make env genere un .env funcional. También ordeno start/env.ts y marco la contraseña como secret, como APP_KEY. · summary

● Update(start/env.ts)
Added 5 lines, removed 7 lines
  // Session
  SESSION_DRIVER: Env.schema.enum(['cookie', 'memory', 'database'] as const),

  DB_HOST: Env.schema.string(),

  // Database (PostgreSQL). Desarrollo y pruebas apuntan a bases distintas: las pruebas
  // sobrescriben estos valores en `.env.test`, que Adonis carga solo con NODE_ENV=test.
  DB_HOST: Env.schema.string({ format: 'host' }),
  DB_PORT: Env.schema.number(),

  DB_USER: Env.schema.string(),

  DB_PASSWORD: Env.schema.string(),

  DB_DATABASE: Env.schema.string()
  DB_PASSWORD: Env.schema.secret(),
  DB_DATABASE: Env.schema.string(),
})

  Ran 1 shell command

Ahora la conexión de Lucid. Sustituyo la de SQLite por la de pg, conservando tal cual la configuración de migraciones y de generación del esquema.

  Ran 1 shell command

Typecheck sin salida. Antes del Makefile compruebo que ace respeta un NODE_ENV=test puesto desde fuera, porque dependo de eso para migrar la base de pruebas.

  Searched for 1 pattern

ace no toca NODE_ENV, así que NODE_ENV=test node ace migration:run cargará .env.test. Ahora el Makefile.

  Ran 1 shell command

La ayuda sale bien. Valido el Compose y levanto las bases. Mido cuánto tarda en estar sano, para comprobar que --wait espera de verdad a la primera inicialización.

  Ran 1 shell command

Ambos servicios están sanos. Voy a comprobar con inspect que la base de pruebas no tiene volúmenes, y luego migraré desde cero. · summary

  Ran 1 shell command

Ambas migraron a la primera sobre una base nueva, así que el chequeo de salud pasó. Ahora reviso que el tmpfs exista en db-test, corro make test y comparo contra cuál base usa la batería. · summary

  Ran 1 shell command

La batería apunta a db-test, donde suben 53 transacciones frente a las 5 de mis consultas en dev. Ahora bajo la base con make db-down para comprobar que dev conserva sus migraciones y que test arranca vacía y se migra sola con make test. · summary

  Ran 1 shell command

El ciclo funciona: dev mantiene sus 4 migraciones, test vuelve a 0 tablas y make test lo reconstruye y pasa las 23. Ahora reviso qué ha cambiado en el árbol, sobre todo schema.ts, que se regenera al migrar. · summary

  Ran 1 shell command

Las migraciones no salen en el diff y el typecheck pasa, pero due_date figura como string en schema_rules.ts mientras pg devuelve objetos Date, así que reviso cómo se usa la fecha. · summary

  Ran 2 shell commands

Hay un fallo real: isOverdueOn compara dueDate con referenceDay como si ambos fueran texto, pero si pg devuelve un Date, la comparación siempre da false. Voy a comprobarlo con una prueba temporal en la base de pruebas, dentro de una transacción que borraré después. · summary

  Ran 1 shell command

Confirmado: el driver devuelve un Date donde el tipo declara string, así que una tarea vencida el 1 de enero sale como no vencida. Lo dejo sin arreglar a propósito, lo cuento al final, y sigo con los textos que ahora mienten sobre SQLite. · summary

  Ran 1 shell command

Cinco sitios del repo tienen información que ya no es cierta: CLAUDE.md, tres puntos de docs/architecture.md, docs/capabilities/tasks/README.md y un comentario en signup.spec.ts. Voy a corregir solo esas partes, dejando sin tocar el README.md raíz porque está marcado como generado. · summary

  Ran 1 shell command

Esa notificación de CLAUDE.md es cosa mía: añado una sección corta de atajos de bases de datos y después formateo y paso las comprobaciones finales. · summary

  Ran 1 shell command

Última pasada completa antes de cerrar. Corro make test otra vez, compruebo que openapi:check sigue limpio (no he tocado rutas, pero es barato) y que el árbol solo contiene lo esperado.

  Ran 1 shell command

openapi:check sale con código 1 y no sé todavía por qué. Si lo provoca mi cambio, tengo que saberlo. Miro el error completo y lo comparo con la rama de partida.

  Ran 1 shell command

El error es de validación de metadatos del propio comando (Invalid URL), antes de llegar a tocar la base. Leo el comando para ver si tiene algo que ver con mi cambio.

  Ran 1 shell command

El error aparece al cargar el comando, antes de leer cualquier configuración de base de datos, así que mi cambio no parece ser la causa. Voy a comprobarlo en el commit de partida, en un worktree temporal fuera del repo. · summary

  Ran 1 shell command

El mismo fallo aparece en el commit de partida, sin mis cambios, así que openapi:check ya estaba roto; lo dejo anotado y ahora preparo los ficheros concretos para el commit con /commit. · summary

  Ran 1 shell command

● Skill(commit)
Successfully loaded skill

  Ran 2 shell commands

La migración a PostgreSQL en Docker está hecha y commiteada en motor-cedl (30ec10f). La batería pasa con las 23 pruebas en verde, igual que antes sobre SQLite, ahora contra db-test. Ninguna migración ni schema.ts aparecen en el diff, y el typecheck también está en verde.

Tu mensaje llegó cortado en "Ninguna migración existente se toca. S". Ninguna migración se ha tocado, y no tuve que cambiar ninguna. Si la frase seguía con algo más, dímelo.

Qué ha quedado

- compose.yaml: tiene los servicios db (54410, con volumen) y db-test (54411), la imagen pgvector/pgvector:pg17 y no lleva version:. db-test usa tmpfs y no tiene ningún volumen.
- Comprobación de salud: los dos servicios la llevan, y la hago por TCP (-h 127.0.0.1). Durante la primera inicialización la imagen escucha solo por socket, y sin -h la comprobación daría "sano" antes de tiempo.
- Atajos del Makefile: make db-up, db-down, migrate (las dos bases) y test. Comprobé que db-up espera a que estén sanas, porque la primera migración sobre bases recién creadas funcionó a la primera.
- Entorno de pruebas: backend/.env.test apunta a la base de pruebas y Adonis lo carga solo con NODE_ENV=test. Repite los cinco DB_* para que un olvido no mande la batería a la base de desarrollo.
- Ciclo completo: con make db-down la de desarrollo conserva sus migraciones y la de pruebas vuelve vacía. make test la reconstruye sola.
- Dependencias: añadí pg y quité better-sqlite3.
- Documentación: corregí CLAUDE.md, docs/architecture.md, el README de tasks y un comentario de signup.spec.ts. No toqué el README.md de la raíz porque está marcado como generado.

Hice tres cosas que no pediste:
- Puertos en loopback: van a 127.0.0.1, para no exponer una base con contraseña de mentira en toda la red.
- make start: depende de db-up, para que no arranque sin base.
- make clean: ahora baja los contenedores y borra el volumen, en lugar de borrar el fichero SQLite.

Si prefieres otra cosa en alguno, es un cambio pequeño.

Un fallo que la batería no ve

Con PostgreSQL, isOverdueOn devuelve false siempre. El driver pg devuelve las columnas date como objeto Date, mientras que SQLite devolvía texto. schema_rules.ts las declara como string, por eso el typecheck sigue en verde. Lo comprobé con una prueba temporal, que ya borré: una tarea con dueDate de 2026-01-01, consultada con día de referencia 2026-11-18, salió como no vencida. La comparación this.dueDate < referenceDay ya no compara texto con texto, y el comentario del modelo que lo afirma ha dejado de ser cierto. Como tasks no tiene tests, nada falla.

No lo he corregido, porque eso ya es la parte B del ejercicio y los números de HALLAZGOS.md los tienes que medir tú. El arreglo habitual es un parser de tipos de pg que deje las fechas como texto, más un test que lo cubra. Dime si lo hago.

Otras cosas a tener en cuenta

- npm test a secas: sobre una base de pruebas recién levantada falla por tablas que no existen. Usa make test, que la migra antes. Lo dejé documentado en CLAUDE.md.
- npm run openapi:check: sale con código 1 por un Invalid URL al cargar el comando. Falla igual en el commit de partida, así que no es de este cambio, y no he investigado la causa.
- Datos antiguos: el fichero backend/tmp/db.sqlite3 sigue en disco, sin versionar. No migré sus datos a PostgreSQL.
- Pendiente: gh pr create y la pasada de adversarial-reviewer quedan para cuando cierres la unidad de trabajo, como indica CLAUDE.md. No he abierto ningún PR.

---

## Prompt 2

**Modelo:** Sonnet 5.5 with xhigh effort
**Herramienta:** Claude Code

```
me puedes explicar la parte B del README

La parte B pide averiguar qué ha cambiado sin avisar al cambiar de motor. Es la mitad que se revisa, y se hace aunque la A haya quedado a medias. Son tres comprobaciones y, después, las tres líneas de HALLAZGOS.md.

Las tres comprobaciones

1. Typecheck. Se corre (cd backend && npm run typecheck) y se anota si sale en verde o en rojo. El README dice que las dos respuestas son normales y que las dos enseñan algo. La idea de fondo es qué puede y qué no puede detectar el compilador tras un cambio de motor.

2. Diff de backend/database/schema.ts. Es el fichero de tipos que Lucid genera al migrar, y se compara entre la rama de partida y tu estado actual.
- Si hay cambios, se dice qué declaraciones cambiaron y de qué tipo a qué.
- Si sale vacío, hay que buscar qué fija esos tipos para que no cambien. Vacío no significa que no haya cambiado nada. Significa que lo que cambió no está en lo que el proyecto declara. Aquí la pista está en database/schema_rules.ts.

3. Cómo decide el proyecto si una tarea está vencida. Se busca ese código (Task.isOverdueOn, en app/models/task.ts) y se lee con lo del punto 2 delante. Su comentario afirma que la comparación funciona porque se comparan textos ISO. Hay que decir si eso sigue siendo cierto y comprobarlo con una tarea que ya debería estar vencida, no solo leyéndolo.

Las tres líneas (HALLAZGOS.md)

1. Filas que cambian de valor, medidas con una consulta, y en qué rama del «árbol de reversibilidad» caen. Si tu cambio no toca datos, se dice tal cual, porque también es una respuesta. Ese árbol viene de una lección del curso que no tengo, así que no voy a inventar sus ramas.
2. Una cosa que la batería no podía ver. Si no encuentras ninguna, se escribe qué buscaste y dónde.
3. De qué dudaste o qué no pudiste comprobar. El README dice que es la que más sirve en el directo.

Cada línea debe ser concreta y medida, no una estimación. «Pocas filas» no vale: falta la consulta.

Lo que ya vi mientras hacía la parte A

Es material para tus líneas, pero las mediciones tienen que ser tuyas:
- Typecheck: salió en verde.
- Diff de schema.ts: salió vacío contra HEAD. No lo comparé contra s10/start, que es lo que pide el README, así que habría que repetirlo ahí.
- Tarea vencida: el comentario de isOverdueOn ya no es cierto. Con PostgreSQL, dueDate llega como objeto Date y no como texto, y isOverdueOn devuelve false para una tarea vencida. Los tipos dicen string y nada convierte el valor en tiempo de ejecución.

Los tres puntos están conectados: el compilador y schema.ts solo ven lo declarado, y lo que cambió está en cómo el driver entrega los valores.

Si quieres, repito contigo las comprobaciones paso a paso, por ejemplo el diff contra s10/start o la consulta para el punto 1. Las tres líneas las escribes tú, porque el README insiste en que sean lo que mediste.
```

**Qué salió:** (opcional, una línea) funcionó a la primera / tuve que insistir / me inventó una ruta que no existe.

funciono a la primera

---

## Prompt 3

**Modelo:** Sonnet 5.5 with xhigh effort
**Herramienta:** Claude Code

```
 y la parte C

Leo la plantilla de prompts.md para no describir de memoria cómo se entrega. HALLAZGOS.md ya lo leí al empezar.

  Read 1 file

La parte C es el entregable real. El README lo dice con todas las letras: «El entregable no es que la migración funcione: son las tres líneas». Van en HALLAZGOS.md, en la raíz, que ya trae los tres puntos puestos. Escribes una sola línea debajo de cada uno, con tus palabras y con lo que mediste, no con lo que suponías.

Qué pide cada línea

1. Filas que cambian de valor. Es un número que sales a buscar con una consulta, más la rama del «árbol de reversibilidad» en la que cae tu cambio. Si tu cambio no toca datos, se dice tal cual, porque también es una respuesta válida. Falta el número si pones «pocas filas». Lo que te toca decidir es qué cuenta como «tu cambio de esquema» y qué consulta lo mide. Las ramas del árbol vienen de una lección del curso que no tengo, así que no te las voy a inventar. Si no tienes claro cuál es la tuya, eso mismo es material para la línea 3.

2. Una cosa que la batería no podía ver. Basta una. Si no encuentras ninguna, la línea sigue valiendo, pero tiene que decir qué buscaste y dónde. «No encontré ninguna» a secas no sirve.

3. De qué dudaste, o qué no pudiste comprobar. El README dice que es la que más sirve en el directo, porque lo que se discute son los choques. Aquí cuenta la honestidad, no quedar bien.

Cómo saber que está bien hecha

- La primera línea es un número que mediste, no una estimación.
- Las tres están escritas y son concretas.
- Ninguna migración existente está tocada (git diff sobre esa carpeta).
- La base de pruebas no tiene volumen.
- Bajar y subir los servicios no hace fallar la primera migración por conexión rechazada.

El README insiste también en que entregar a medias vale más que no entregar. Una parte A incompleta con la B y la C escritas supera a una A perfecta sin ellas.

Dos cosas sobre tu prompts.md

Lo abrí para ver la plantilla y hay tres detalles que chocan con lo que pide el README. No lo he editado, porque es tuyo.

- El ejemplo de plantilla sigue al final. Hay un segundo ## Prompt 1 con «Este es el ejemplo. Bórralo.» y la plantilla dice que se borra.
- La transcripción pegada fuera del bloque de código. El README pide un bloque de código por prompt, con el prompt entero. Lo que hay debajo del primer bloque, la repetición del prompt y todo el recorrido, no es un prompt y no tiene delimitador.
- Faltan los prompts siguientes. «me puedes explicar la parte B del README» y «y la parte C» también los lanzaste, y el archivo pide todos, con modelo y herramienta en cada uno.
```

**Qué salió:** (opcional, una línea) funcionó a la primera / tuve que insistir / me inventó una ruta que no existe.
Funciono pero no me gusto la respuesta

---

## Prompt 1

**Modelo:** Sonnet 5.5 with xhigh effort
**Herramienta:** Claude Code

```
```

**Qué salió:** (opcional, una línea) funcionó a la primera / tuve que insistir / me inventó una ruta que no existe.

---

## Prompt 1

**Modelo:** Sonnet 5.5 with xhigh effort
**Herramienta:** Claude Code

```
```

**Qué salió:** (opcional, una línea) funcionó a la primera / tuve que insistir / me inventó una ruta que no existe.
