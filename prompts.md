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
Crea una suite de tests funcionales que se ejecuten dentro del comando `make test-e2e`.
  Debes escribir tests para comprobar todos los scenarios del requirement "Cuándo una tarea está vencida". Crea un
  test por scenario que ejecute una peticion HTTP al servicio.
  Utiliza la base de datos de test para hacer las pruebas. Cada escenario parte con la BD vacía y las tareas también
  se crean por peticion HTTP, al finalizar el escenario borra lo generado.

  Ten en cuenta estas 5 restricciones:
  - No toques ni una línea fuera de backend/tests/. Ni el modelo, ni el transformer, ni el controlador. Si tu agente
  cambia implementación mientras escribe el test, el test nacerá verde y no comprobará nada.
  - Los tests comprueban lo que sale en la respuesta, no lo que devuelve un método interno. El campo se llama
  isOverdue y viaja en el cuerpo.
  - El día de referencia se le pasa a la petición. Nada de la fecha de hoy ni de ningún reloj.
  - Sigue la forma de aislamiento que ya usan los tests de backend/tests/functional/, sin inventar otra.
  - No des por hecho ningún identificador: usa el que te devuelva la creación.
```

**Qué salió:** 

┌─────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────┐
│              Escenario              │                                Resultado                                │
├─────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Fecha del día anterior              │ ❌ El GET responde isOverdue: false (el PUT sí responde true)           │
├─────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Vencer hoy todavía no es estar      │ ✅                                                                      │
│ vencida                             │                                                                         │
├─────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Fecha futura                        │ ✅                                                                      │
├─────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Sin fecha no se vence nunca         │ ✅                                                                      │
├─────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Darla por hecha la deja de vencer   │ ❌ Falla antes de llegar a marcarla como hecha: el GET ya no la da por  │
│                                     │ vencida                                                                 │
├─────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Una tarea hecha con la fecha pasada │ ❌ El PUT responde isOverdue: true para una tarea en done               │
├─────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Aplazar resuelve el vencimiento     │ ✅                                                                      │
└─────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────┘

Por lo que he visto en isOverdueOn (app/models/task.ts:74), los fallos tienen dos causas:
- No mira el estado. Una tarea en done con la fecha pasada sale como vencida.
- No funciona en la consulta. En el GET, dueDate llega de la base como fecha y no como texto, y al compararla con today el resultado siempre es false. En el PUT sí funciona porque la fecha todavía es texto. Que la consulta salga bien en el escenario de la tarea hecha es casualidad, y por eso ese test mira también el PUT.

Hay además otro fallo, de un requisito distinto: el GET devuelve dueDate como 2026-08-19T00:00:00.000Z y no como 2026-08-19, lo que incumple «La fecha es un día, no un instante». En esta suite comparo solo el día para que ese formato no tape el resultado de isOverdue. Si quieres que quede cubierto, lo suyo es un test aparte para ese requisito.

## Prompt 2

**Modelo:** Opus 5.5 xHigh
**Herramienta:** Claude Code

```
Realiza test unitario para la regla isOverDueOnen @backend/app/models/task.ts. Crea backend/tests/unit/ y crea los tests unitarios para comprobar isOverDueOn. Será tes unitario del método, sin servidor ni base de datos.
  Estos son los bordes:
  - Fecha anterior al día de referencia, y la tarea sin hacer.
  - Fecha exactamente igual al día de referencia.
  - Fecha posterior.
  - Sin fecha.
  - Tarea ya hecha, con la fecha pasada.

  Añade un caso de tests más para comprobar que la regla se comporte igual reciba la fecha como texto o como objeto de fecha.

  NO MODIFIQUES CÓDIGO SOLO CREA EL TEST
  ```

  **Qué salió:** 

  ┌─────────────────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│                      Test                       │                          Resultado                          │
├─────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Fecha anterior y sin hacer (pending e           │ ✅ vencida                                                  │
│ in_progress)                                    │                                                             │
├─────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Fecha igual al día de referencia                │ ✅ no vencida                                               │
├─────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Fecha posterior                                 │ ✅ no vencida                                               │
├─────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Sin fecha                                       │ ✅ no vencida                                               │
├─────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Hecha con la fecha pasada                       │ ❌ devuelve true: la regla no mira el estado done           │
├─────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Misma respuesta con la fecha como texto o como  │ ❌ con un objeto de fecha nunca da vencida (falla ya en     │
│ objeto de fecha                                 │ «anterior, pendiente»)                                      │
└─────────────────────────────────────────────────┴─────────────────────────────────────────────────────────────┘

En el último test, el objeto de fecha se crea igual que lo hace el driver de PostgreSQL con una columna date: a medianoche, en la hora local. Cada forma de la fecha se compara con el resultado correcto, no solo una con la otra. Si no, dos formas equivocadas en lo mismo pasarían el test.

Como el esquema generado declara dueDate como texto, en ese caso hace falta un cast para poder pasarle un objeto de fecha.

Estos dos fallos explican los 3 rojos de la suite e2e:
- No mira el estado: por eso el PUT marca como vencida una tarea en done.
- No funciona con el objeto de fecha: el GET lee la fecha de la base como objeto, así que nunca la da por vencida.