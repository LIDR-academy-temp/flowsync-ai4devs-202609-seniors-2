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

**Modelo:** Sonnet 5.5 (high effort)
**Herramienta:** Claude Code

```
Eres un ingeniero backend trabajando en FlowSync. Tu tarea es escribir tests funcionales y nada más.

**Tarea:** cubre con tests el Requirement «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`, que hoy no tiene ninguno.

**Pasos:**
1. Lee en `openspec/specs/tasks/spec.md` el Requirement «Cuándo una tarea está vencida» (línea 390) en su totalidad, con sus 7 Scenarios. Lee también el Requirement vecino «El día de referencia lo pone quien mira» (línea 429) para entender cómo viaja el día de referencia en las peticiones (parámetro `today`).
2. Estudia los tests existentes en `backend/tests/functional/` y replica exactamente su forma de aislamiento (helpers, arranque de la app, base de datos, limpieza entre tests). No inventes otra.
3. Escribe UN archivo de tests funcionales en `backend/tests/functional/` que ejerce la exigencia entrando por HTTP, igual que el cliente que consume este backend: peticiones reales a la aplicación, UN test por Scenario.
4. Ejecuta `make test-e2e` y muéstrame la salida completa, no solo el resumen final. Esa salida íntegra la necesito para el entregable.

**Restricciones, y ninguna es decorativa:**
1. NO toques ni una línea fuera de `backend/tests/`. Ni el modelo, ni el transformer, ni el controller. Si mientras escribes un test sientes que necesitas cambiar la implementación para que pase, detente y avísame: los tests deben nacer rojos.
2. Los tests verifican lo que sale en la respuesta HTTP, no lo que devuelve un método interno. El campo se llama `isOverdue` y viaja en el cuerpo.
3. El día de referencia se pasa en la petición, en el parámetro `today` con formato AAAA-MM-DD. Ningún test usa la fecha del día ni ninguna otra hora del sistema.
4. Sigue la forma de aislamiento que ya usan los tests de `backend/tests/functional/`, sin crear una nueva.
5. No supongas ningún identificador: usa el que devuelve la creación de la tarea.

**Resultado esperado:** la mayoría de tus nuevos tests deben quedar en ROJO, porque la exigencia no está implementada. Un archivo de tests completamente verde sobre una exigencia sin implementar es señal de que los tests miran otra cosa.

Cuando termines, dame tres cosas: el diff completo de lo creado, la salida íntegra de `make test-e2e`, y la lista de qué casos quedaron en rojo y cuáles en verde.
```

**Qué salió:** a la primera. 5 rojos / 2 verdes sobre 47, solo un archivo nuevo en `backend/tests/`. El agente añadió dos controles (precondiciones) a los Scenarios «Vencer hoy» y «hecha con fecha pasada», y avisó de que la exigencia no está sin implementar sino rota, con dos fallos concretos.

---

## Prompt 2

**Modelo:** Sonnet 5.5 (high effort)
**Herramienta:** Claude Code

```
Eres un ingeniero backend trabajando en FlowSync. Tu tarea es escribir tests unitarios y nada más.

**Tarea:** baja la regla del Requirement «Cuándo una tarea está vencida» hacia tests que la llaman directamente. La regla vive en `isOverdueOn`, en `backend/app/models/task.ts`. El directorio `backend/tests/unit/` no existe todavía: créalo y escribe ahí sus bornes.

**Pasos:**
1. Lee en `openspec/specs/tasks/spec.md` el Requirement «Cuándo una tarea está vencida» (línea 390) y sus Scenarios. Los Scenarios son el enunciado: no inventas los casos, están escritos desde antes de que el código existiera.
2. Lee `isOverdueOn` en `backend/app/models/task.ts` SOLO para saber cómo se le llama: qué recibe y qué devuelve. No la modifiques ni la juzgues al escribirlas.
3. Mira el estilo de los tests existentes en `backend/tests/` (framework, nombres, estructura) para que los tuyos sean consistentes, pero sin servidor y sin base de datos: nada de HTTP, nada de `testUtils.db()`, ningún contenedor.
4. Escribe en `backend/tests/unit/` los bornes de la regla, un test por caso:
   - fecha ANTERIOR al día de referencia, tarea no hecha → vencida
   - fecha EXACTAMENTE igual al día de referencia → NO vencida (la regla exige anterior)
   - fecha posterior al día de referencia → NO vencida
   - sin fecha de vencimiento → NO vencida
   - tarea ya hecha (`done`), con la fecha pasada → NO vencida
   - y UN caso más que no sale de la spec: que la regla se comporte igual si recibe la fecha como texto (`'2026-08-12'`) que como objeto Date. Ninguna exigencia de producto lo pide: sale de preguntarse cómo llega de verdad la dato, y lo que hace falta es que las dos entradas produzcan la misma respuesta.
5. Ejecuta `make test-unit` y muéstrame la salida completa, no solo el resumen. Esa salida íntegra la necesito para el entregable. Contexto: antes de hoy esta suite respondía `NO TESTS EXECUTED` con código 0, y eran 40 los tests totales del proyecto; compara con eso.

**Restricciones, y ninguna es decorativa:**
1. NO toques ni una línea fuera de `backend/tests/`. Ni el modelo, ni el transformer, ni el controller, ni la configuración de conexión. Si mientras escribes un test descubres que la regla está mal, NO la corrijas: detente, apúntalo y avísame.
2. Los tests llaman a la función directamente y verifican lo que devuelve. Nada de peticiones HTTP en este nivel.
3. El día de referencia entra como parámetro. Ningún test usa la fecha del día ni ninguna otra hora del sistema.
4. No inventes otra forma de escribir tests: la misma estructura que el resto del proyecto.

**Resultado esperado:** puede que no todo quede verde, y está bien. Aquí no buscas que pase: buscas saber la verdad de la regla. Un test que falla es un hallazgo, no un problema que arreglar en este ejercicio.

Cuando termines, dame tres cosas: el diff completo de lo creado, la salida íntegra de `make test-unit`, y la lista de qué casos quedaron en rojo y cuáles en verde, con tu hipótesis de por qué en una línea por rojo.
```

**Qué salió:** a la primera. 4 verdes / 2 rojos (6 tests, salida con código 2). Los rojos confirman los dos hallazgos de la parte A a nivel de regla: `isOverdueOn` nunca mira `status`, y con la fecha como objeto Date la comparación da siempre false (Date vs texto → NaN).
