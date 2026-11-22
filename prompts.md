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
Lee el Requirement «Cuándo una tarea está vencida» de openspec/specs/tasks/spec.md y sus 7 Scenarios. No escribas nada todavía.

Quiero un único archivo nuevo, backend/tests/functional/tasks/overdue.spec.ts, con UN test por Scenario que entre por HTTP (client de Japa), igual que entra el frontend:
- crea la tarea con POST /api/v1/tasks y usa el id que devuelva la creación; no des por hecho ningún id
- la fecha se fija con PUT /api/v1/tasks/:id/due-date {dueDate, today}; el estado con PATCH /api/v1/tasks/:id/status
- se consulta con GET /api/v1/tasks/:id?today=AAAA-MM-DD
- asserta isOverdue en el cuerpo de la respuesta, nunca un método interno
- el día de referencia es una constante en el test: prohibido new Date(), Date.now(), DateTime.now() o cualquier reloj
- aislamiento: copia el que usan los tests de backend/tests/functional/tasks/assignee.spec.ts (group.each.setup con withGlobalTransaction), no inventes otro
- si un Scenario parte de «una tarea vencida», comprueba esa precondición antes del paso que la cambia

Restricción dura: no modifiques NADA fuera de backend/tests/. Ni el modelo, ni transformers, ni controladores, aunque veas el bug. Los tests tienen que quedar en rojo donde la implementación no cumpla la spec; no los suavices para que pasen.

Cuando termines, ejecuta `make test-e2e` y enséñame la salida entera, sin resumir. No commitees.

Escribe todo el resultado como el prompt 1 de prompts.md
```

**Qué salió:** un único archivo nuevo, `backend/tests/functional/tasks/overdue.spec.ts`, con 7 tests (uno por Scenario) que entran por HTTP con el client de Japa. Aislamiento copiado de `assignee.spec.ts` (`group.each.setup(() => testUtils.db().withGlobalTransaction())`), día de referencia como constante (`2026-08-20`, sin reloj) y `isOverdue` leído del cuerpo de la respuesta. «Darla por hecha» y «Aplazar» comprueban primero, por `GET`, que la tarea está vencida antes del paso que la cambia. No se tocó nada fuera de `backend/tests/` (salvo este `prompts.md`, a petición) y no se commiteó.

`make test-e2e` (se omiten las líneas de log `Row not found` y los códigos de color):

```
Tests  44 passed, 3 failed (47)
 Time  11s
make: *** [Makefile:124: test-e2e] Error 1

❯ Tasks | cuándo una tarea está vencida / fecha del día anterior: la tarea llega vencida
  AssertionError: expected false to be true
  at tests/functional/tasks/overdue.spec.ts:73:12   assert.isTrue(tarea.isOverdue)

❯ Tasks | cuándo una tarea está vencida / darla por hecha la deja de vencer
  AssertionError: expected false to be true
  at tests/functional/tasks/overdue.spec.ts:114:12  assert.isTrue(antes.isOverdue)   (precondición)

❯ Tasks | cuándo una tarea está vencida / aplazar resuelve el vencimiento en la misma respuesta del cambio
  AssertionError: expected false to be true
  at tests/functional/tasks/overdue.spec.ts:146:12  assert.isTrue(antes.isOverdue)   (precondición)
```

Lectura: los 3 rojos tienen el mismo origen. Una tarea con fecha `2026-08-19` consultada con `today=2026-08-20` llega con `isOverdue: false` y la spec exige `true`. Los otros 4 Scenarios pasan porque esperan `false`. Causa no investigada (la implementación estaba vetada); el sitio a mirar es `Task.isOverdueOn`, que usa `TaskDetailTransformer`.


## Prompt 2

**Modelo:** Opus 1M xHigh
**Herramienta:** Claude Code

```
Sin tocar nada fuera de backend/tests/ o prompts.md, crea backend/tests/unit/task_is_overdue_on.spec.ts con tests unitarios de Task#isOverdueOn (backend/app/models/task.ts): sin servidor, sin base de datos, sin guardar el modelo (new Task() y asignar dueDate y status en memoria). Día de referencia fijo, nada de relojes.

Casos, uno por test:
1. fecha anterior al día de referencia y tarea pending -> true
2. fecha igual al día de referencia -> false
3. fecha posterior -> false
4. sin fecha (null) -> false
5. tarea done con fecha pasada -> false
6. la regla responde lo mismo si dueDate llega como texto 'AAAA-MM-DD' o como Date (como la entrega el driver pg al leer una columna date). Construye el Date como medianoche local, que es lo que hace pg.

Ejecuta `make test-unit` y dame la salida entera. No arregles la implementación aunque falle.

Escribe la salida final como el que salio del prompt 2
```

**Qué salió:** un único archivo nuevo, `backend/tests/unit/task_is_overdue_on.spec.ts`, con 6 tests (uno por caso). Construyen `new Task()` en memoria, asignan `dueDate` y `status` sin guardar, usan el día fijo `2026-08-20` y no tocan ningún reloj. El caso 6 construye el `Date` con `new Date(2026, 7, 19)` (medianoche local). No se tocó la implementación.

`make test-unit` (se omiten los códigos de color y las trazas internas de Japa):

```
✔✔✔✔✖✖

Tests  4 passed, 2 failed (6)
 Time  24ms
make: *** [Makefile:121: test-unit] Error 1

❯ Task#isOverdueOn / tarea done con fecha pasada: no vencida
  AssertionError: expected true to be false
  at tests/unit/task_is_overdue_on.spec.ts:37:12   assert.isFalse(tarea('2026-08-19', 'done').isOverdueOn(HOY))

❯ Task#isOverdueOn / responde lo mismo si dueDate llega como texto o como Date
  AssertionError: expected false to equal true
  at tests/unit/task_is_overdue_on.spec.ts:45:12   assert.equal(comoDate, comoTexto)
```

Lectura, contra `Task#isOverdueOn` (`app/models/task.ts`), que hoy es `if (this.dueDate === null) return false; return this.dueDate < referenceDay`:
- **Caso 5 (rojo):** la función no mira `status`, así que una tarea `done` con fecha pasada sale vencida. Incumple la tercera condición de la spec.
- **Caso 6 (rojo):** con un `Date`, la comparación `Date < 'AAAA-MM-DD'` convierte el texto a número, da `NaN` y el resultado es siempre `false`. El texto da `true` y el `Date`, `false`.
- **Casos 1 a 4 (verdes):** el `<` estricto, la fecha futura y el `null` están bien.

Relación con el Prompt 1, sin comprobar: en `overdue.spec.ts` fallaba «fecha del día anterior» con `isOverdue: false`, pero con texto la regla da `true`. Es probable que por HTTP `dueDate` llegue como `Date` desde el driver, el mismo mecanismo del caso 6. Habría que verificarlo.


## Prompt 3

**Modelo:** Opus 1M xHigh
**Herramienta:** Claude Code

```
No cambies código. Mira qué tienen en común los 2 tests funcionales que fallan frente a los 5 que pasan en overdue.spec.ts (qué valor esperan y por qué endpoint leen isOverdue) y explícame por qué pasan los que pasan. Comprueba tu hipótesis sin modificar implementación.

Pon el resultado como el que salio del prompt3
```

**Qué salió:** una corrección y una hipótesis confirmada. Sin cambiar código de la aplicación.

Corrección al enunciado: en `overdue.spec.ts` no fallan 2 y pasan 5, sino **3 rojos y 4 verdes** (7 tests).

| Test | Espera | Lee `isOverdue` por | Resultado |
|---|---|---|---|
| fecha del día anterior | `true` | `GET /tasks/:id` | rojo |
| darla por hecha (precondición) | `true` | `GET /tasks/:id` | rojo |
| aplazar (precondición) | `true` | `GET /tasks/:id` | rojo |
| vencer hoy | `false` | `GET /tasks/:id` | verde |
| fecha futura | `false` | `GET /tasks/:id` | verde |
| tarea hecha con fecha pasada | `false` | `GET /tasks/:id` | verde |
| sin fecha | `false` | `GET /tasks/:id` | verde |

Lo común: los 3 rojos esperan `true` y los 4 verdes esperan `false`. Todos leen por el mismo endpoint, el `GET`. En «aplazar» la aserción final (`false`, sobre la respuesta del `PUT`) nunca llega a ejecutarse porque falla antes la precondición.

Hipótesis: por `GET`, `isOverdue` es siempre `false`. Pasan los 4 verdes porque esperan justo ese valor, no porque la regla funcione. De ellos, solo «sin fecha» pasa por una razón legítima (`dueDate === null`). «Hoy», «futura» y «hecha con fecha pasada» pasan por casualidad.

Causa: la columna `due_date` es `date`, y el driver `pg` la entrega como `Date` (medianoche local). El modelo declara `dueDate: string | null`, pero en tiempo de ejecución es un `Date`. `Task#isOverdueOn` hace `this.dueDate < referenceDay`, y `Date < 'AAAA-MM-DD'` convierte el texto a número, da `NaN` y siempre `false`. Es el mismo fallo que el caso 6 del Prompt 2.

Comprobación (una prueba desechable con transacción global, ya borrada; no queda nada en el repo). Tarea con fecha `2026-08-19`, día de referencia `2026-08-20`:

```
PROBE PUT  {"dueDate":"2026-08-19","isOverdue":true}
PROBE GET  {"dueDate":"2026-08-19T00:00:00.000Z","isOverdue":false}
PROBE MODEL object true Wed Aug 19 2026 00:00:00 GMT+0000 (Coordinated Universal Time)
```

- **`PUT`:** devuelve `true` porque el controlador asigna la fecha como texto en memoria y no recarga la tarea.
- **`GET`:** devuelve `false` y `dueDate` sale como ISO con hora, señal de que era un `Date`.
- **Modelo leído de la base:** `typeof` es `object` e `instanceof Date` es `true`.

Consecuencia: la lectura de una tarea sana es siempre «no vencida». Además, `isOverdueOn` ignora `status` (Prompt 2, caso 5), así que al corregir lo del `Date` habría que arreglar también ese fallo.





