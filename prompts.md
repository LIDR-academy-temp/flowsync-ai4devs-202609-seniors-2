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

**Modelo:** Opus 5.5 1M, effort high
**Herramienta:** Claude Code

```
Dado el requirimiento "Cuándo una tarea está vencida" de `openspec/specs/tasks/spec.md` con sus 7 escenarios, escribe un test funcional que los ejecute todos, entrando por HTTP igual que la aplicación que consume este backend. El test debe estar en `backend/tests/functional/`, y debe ser ejecutable con `make test-e2e`. No toques ni una línea fuera de `backend/tests/`.

Córrelo con `make test-e2e` y quédate con la salida entera, no solo con si pasó o no. No te fijes en la implementación para crear los test, solo en el contrato y los escenarios.

Restricciones:

- **No toques ni una línea fuera de** `backend/tests/`. Ni el modelo, ni el transformer, ni el controlador. No se debe cambiar la implementación mientras al escribir los test.

- Los tests comprueban lo que sale en la respuesta, no lo que devuelve un método interno. El campo se llama `isOverdue` y viaja en el cuerpo.

- **El día de referencia se le pasa a la petición**. Nada de la fecha de hoy ni de ningún reloj.

- Sigue **la forma de aislamiento que ya usan** los tests de `backend/tests/functional/`, sin inventar otra.

- **No des por hecho ningún identificador**: usa el que te devuelva la creación.
```

**Qué salió:** 7 tests en `tests/functional/tasks/overdue.spec.ts`, 5 en rojo; hubo que correrlo dos veces, reordenando las comprobaciones para que `isOverdue` se comprobara antes que el formato de `dueDate`.

## Prompt 2

**Modelo:** Opus 5.5 1M, effort high
**Herramienta:** Claude Code

```
Crea test unitarios para la función `isOverdueOn` que vive en `backend/app/models/task.ts`. Este va ser el primer test unitario del proyecto. El test debe estar en `backend/tests/unit/`, y debe ser ejecutable con `make test-unit`. No toques ni una línea fuera de `backend/tests/unit/`. Escribe sus bordes, sin servidor y sin base de datos:

- Fecha anterior al día de referencia, y la tarea sin hacer.

- Fecha exactamente igual al día de referencia.

- Fecha posterior.

- Sin fecha.

- Tarea ya hecha, con la fecha pasada.

Y añade **un caso más que no sale de la spec**: que la regla se comporte igual reciba la fecha como texto o como objeto de fecha.

Sigue sin tocar implementación y los tests pueden salir rojos no tienen que estar adaptados a la implementación, solo al contrato.
```

**Qué salió:** 6 tests en `tests/unit/models/task_is_overdue_on.spec.ts`, 2 en rojo (tarea hecha con fecha pasada, y la fecha como `Date`); funcionó a la primera.

## Prompt 3

**Modelo:** Opus 5.5 1M, effort high
**Herramienta:** Claude Code

```
revisa mis  @HALLAZGOS.md
```

**Qué salió:** revisión sin tocar el fichero; el punto 2 tenía una cifra al revés y faltaba el porqué.

## Prompt 4

**Modelo:** Opus 5.5 1M, effort high
**Herramienta:** Claude Code

```
revisa de nuevo
```

**Qué salió:** la cifra ya estaba corregida, pero el porqué del punto 2 seguía sin cuadrar con lo medido.

## Prompt 5

**Modelo:** Opus 5.5 1M, effort high
**Herramienta:** Claude Code

```
vale aplica tus correcciones
```

**Qué salió:** aplicadas las tres líneas en `HALLAZGOS.md` y commiteadas.

## Prompt 6

**Modelo:** Opus 5.5 1M, effort high
**Herramienta:** Claude Code

```
añade los prompts de la sesión teniendo en cuenta effort high context 1.0M usado a @prompts.md
```

**Qué salió:** este fichero.
