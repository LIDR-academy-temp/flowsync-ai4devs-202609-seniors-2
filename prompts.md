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
 escribe una Test para el Requirement: Cuándo una tarea está vencida  en @openspec/specs/tasks/spec.md  los test deben ser funcionales entrando por http , cre un test por cada scenario ,No toques ni una línea fuera de backend/tests/. El campo se llama isOverdue y viaja en el cuerpo. El día de referencia se le pasa a la petición. Sigue la forma de aislamiento que ya usan los tests de backend/tests/functional/, no des por hecho ningun identificador : usa los que devuelve la creación
```

**Qué salió:** 
Esto rompe dos reglas de la spec. Una es «Fecha del día anterior», y la otra es que la fecha sea un día AAAA-MM-DD, sin hora.

Los fallos son estos tres tests:
- «fecha del día anterior: llega vencida».
- «darla por hecha la deja de vencer y conserva su fecha».
- «aplazar resuelve el vencimiento en la misma respuesta del cambio».

Estos dos pasan por casualidad:
- «una tarea hecha con la fecha pasada no llega vencida» pasa porque isOverdueOn siempre devuelve false.
- «vencer hoy todavía no es estar vencida» pasa por el mismo motivo.

isOverdueOn tampoco comprueba status !== 'done', que es la tercera condición de la spec. Cuando se arregle la fecha, el test de la tarea hecha debería fallar hasta que se añada esa condición.

Dos cosas más
- El diagnóstico del IDE marca withGlobalTransaction() como deprecado. Es el mismo uso que ya hacen los demás tests, así que lo dejé igual.
- node ace test regenera .adonisjs/, que ya estaba modificado antes de que empezara. No lo he tocado a mano

---

## Prompt 2

**Modelo:** Opus 1M xHigh
**Herramienta:** Claude Code

```
 Crea backend/tests/unit/, que hoy no existe, y escribe ahí sus bordes, sin servidor y sin base de datos:

  Fecha anterior al día de referencia, y la tarea sin hacer.

  Fecha exactamente igual al día de referencia.

  Fecha posterior.

  Sin fecha.

  Tarea ya hecha, con la fecha pasada.
  Y añade un caso más que no sale de la spec: que la regla se comporte igual reciba la fecha como texto o como objeto de fecha. Ese no lo pide ningún requisito de producto. Sale de preguntarse cómo llega el dato de verdad, que es justo donde tu criterio no lo pone nadie por ti.

  Ran 1 shell command

He creado backend/tests/unit/tasks/is_overdue.spec.ts, con 6 tests sobre Task.isOverdueOn que construyen la tarea en memoria, sin servidor ni base de datos. De los 6, 4 pasan y 2 fallan, y los 2 fallos son bugs reales del código.

Los 4 que pasan:
- Fecha anterior y sin hacer: vencida.
- Fecha igual al día de referencia: no vencida.
- Fecha posterior: no vencida.
- Sin fecha: no vencida.

Los 2 que fallan:
 Crea backend/tests/unit/, que hoy no existe, y escribe ahí sus bordes, sin servidor y sin base de datos:

  Fecha anterior al día de referencia, y la tarea sin hacer.

  Fecha exactamente igual al día de referencia.

  Fecha posterior.

  Sin fecha.

  Tarea ya hecha, con la fecha pasada.
  Y añade un caso más que no sale de la spec: que la regla se comporte igual reciba la fecha como texto o como objeto de fecha. Ese no lo pide ningún requisito de producto. Sale de preguntarse cómo llega el dato de verdad, que es justo donde tu criterio no lo pone nadie por ti.

  ```

**Qué salió:** 

He creado backend/tests/unit/tasks/is_overdue.spec.ts, con 6 tests sobre Task.isOverdueOn que construyen la tarea en memoria, sin servidor ni base de datos. De los 6, 4 pasan y 2 fallan, y los 2 fallos son bugs reales del código.

Los 4 que pasan:
- Fecha anterior y sin hacer: vencida.
- Fecha igual al día de referencia: no vencida.
- Fecha posterior: no vencida.
- Sin fecha: no vencida.

Los 2 que fallan:
1. Tarea hecha con la fecha pasada devuelve true y debería devolver false. En app/models/task.ts:74 isOverdueOn no comprueba el estado, así que falta la tercera condición de la spec. En los tests HTTP anteriores esto quedaba tapado por el otro bug.
2. Texto frente a objeto de fecha da resultados distintos, por ejemplo con 2026-08-12 frente a 2026-08-13. Es el caso extra que pediste, y es el mismo bug que vi por HTTP. Postgres entrega las columnas date como Date, y this.dueDate < referenceDay compara un Date con un texto, así que da false siempre.

Con estos dos fallos y los 3 de tasks.spec.ts ya tienes 5 tests que fallan. Los 5 se pondrán en verde cuando se arreglen estas dos cosas en app/models/task.ts. Además de añadir status !== 'done', hay que normalizar la fecha a AAAA-MM-DD; el modelo debería hacerlo al cargarla para que la API también devuelva el formato correcto. No lo he tocado porque pediste quedarme dentro de backend/tests/. ¿Lo arreglo?

Churned for 15s · done 1:26 PM

recap: Estamos escribiendo tests del requisito «Cuándo una tarea está vencida»: 7 funcionales por HTTP y 6 unitarios, de los que 5 fallan por bugs reales en `app/models/task.ts`. Siguiente paso: que me autorices a arreglar ese modelo, que está fuera de `backend/tests/`. (turn off recaps in /config)

❯ Cuántos de los casos nuevos fallaron y cuántos de los que ya había siguieron en verde,

  Ran 1 shell command

De los 6 casos nuevos de tests/unit/, fallaron 2 y 4 pasaron.

Con las dos suites completas (53 tests en total) hay 48 en verde y 5 en rojo. Los 5 en rojo son los mismos de antes: 2 de los casos nuevos de tests/unit/ y 3 de los 7 de tasks.spec.ts. Esos 7 los escribí antes y 4 siguen en verde.

Los demás tests que ya existían (auth, assignee y trash, 41 en total) siguen todos en verde. Los avisos «Row not found» del log son de los tests de borrado y restaurado de trash y salen aunque pasen.

Sautéed for 14s · done 1:39 PM

recap: Estamos cubriendo con tests el requisito «Cuándo una tarea está vencida»; hay 53 tests, 48 en verde y 5 en rojo por un bug en `app/models/task.ts`. Lo siguiente es que decidas si lo arreglo, algo que está fuera de `backend/tests/`. (turn off recaps in /config)

❯ cuales fueron los 4 que pasaron

Hay dos grupos de 4, uno por cada suite.

Unit (tests/unit/tasks/is_overdue.spec.ts), 4 de 6:
1. Fecha anterior al día de referencia y sin hacer: vencida.
2. Fecha igual al día de referencia: no vencida.
3. Fecha posterior: no vencida.
4. Sin fecha: nunca vencida.

Functional (tests/functional/tasks/tasks.spec.ts), 4 de 7:
1. Vencer hoy todavía no es estar vencida.
2. Fecha futura: no llega vencida.
3. Sin fecha no se vence nunca, por antigua que sea.
4. Una tarea hecha con la fecha pasada no llega vencida.

Los tests 1, 2 y 4 de la suite functional (vencer hoy, fecha futura y tarea hecha) pasan por casualidad, no porque el código sea correcto. El bug de la fecha hace que isOverdueOn devuelva siempre false cuando la tarea llega de la base, y esos tres tests esperan false. Lo mismo vale para «tarea hecha» y «vencer hoy» si se leen por HTTP. Se volverán a poner a prueba de verdad cuando se arregle el modelo.

En la suite unit, el test de la tarea hecha sí falla, porque ahí la fecha es texto y la regla no mira el estado.

Churned for 4s · done 1:44 PM

❯ De los 6 casos nuevos de tests/unit/, fallaron 2 y 4 pasaron. cuales son esos 4

Los 4 que pasaron de tests/unit/tasks/is_overdue.spec.ts son:

1. Fecha anterior al día de referencia y sin hacer: vencida. El test comprueba dos casos, pending e in_progress.
2. Fecha igual al día de referencia: no vencida.
3. Fecha posterior: no vencida.
4. Sin fecha: nunca vencida.

Los 2 que fallaron son «tarea hecha con la fecha pasada» y «da igual que la fecha llegue como texto o como objeto de fecha».

Cogitated for 1s · done 1:55 PM

recap: Estamos escribiendo tests del requisito «Cuándo una tarea está vencida»: 7 funcionales y 6 unitarios están creados, con 5 en rojo por bugs reales en el modelo Task. Lo siguiente es que decidas si arreglo `app/models/task.ts`, fuera de `backend/tests/`.

❯ la validacion de  el estatus  se hace dentro del codigo

  Searched for 1 pattern

Sí y no, según a qué validación te refieras.

Que el estado sea válido se comprueba en dos sitios:
- En el código: updateTaskStatusValidator (app/validators/task.ts:38) usa vine.enum(TASK_STATUSES), así que un estado inventado da 422.
- En la base: la migración add_status_check_to_tasks_table añade el CHECK (status IN ('pending', 'in_progress', 'done')) (tasks_status_check), como pide la convención 2 de docs/convenciones/base-de-datos.md. Un INSERT directo con un estado inventado también falla.

Que una tarea hecha no esté vencida no se comprueba en ninguna parte. isOverdueOn (app/models/task.ts:74) solo mira la fecha y no consulta this.status. El test unitario «tarea hecha con la fecha pasada» falla por eso, y el CHECK y el validador no lo cubren porque solo dicen qué estados existen, no qué significan para el vencimiento.

Si preguntabas por otra cosa, dime cuál.

Churned for 7s · done 3:17 PM

❯ me refiero si existe la validacion si la tarea  esta en done se valida para revisar isOverdueOn

No, esa validación no existe. isOverdueOn en app/models/task.ts:74-78 solo hace esto:

if (this.dueDate === null) return false
return this.dueDate < referenceDay

No consulta this.status, así que una tarea en done con la fecha pasada se marca como vencida si la fecha le llega como texto. Por eso falla el test unitario «tarea hecha con la fecha pasada».

Nada más en el código lo suple. El transformer (task_detail_transformer.ts:29) solo llama a isOverdueOn con el día de referencia, y el validador y el CHECK solo controlan qué estados existen.


En la suite unit, el test de la tarea hecha sí falla, porque ahí la fecha es texto y la regla no mira el estado.
