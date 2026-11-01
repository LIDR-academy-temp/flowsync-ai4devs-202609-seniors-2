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
Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.
```

**Qué salió:**
● DELETE /api/v1/tasks/:id ya existe: borra la tarea y responde 204 sin cuerpo. Está commiteado en feat/delete-task (86066b0).

  Lo hice así:
  - Controlador y ruta: añadí TasksController.destroy, con sus decoradores OpenAPI, y su ruta DELETE :id junto a las demás de tasks. Va bajo el middleware.auth() del grupo, así que sin token  
    da 401. Si la tarea no existe, da 404.
  - Permisos: cualquier cuenta con sesión puede borrar cualquier tarea, igual que ya pasa con el cambio de estado. La spec no dice nada sobre borrar, así que lo decidí yo y quedó documentado  
    en el comentario del método.
  - Tests: añadí tests/functional/tasks/delete.spec.ts con tres casos: 204 sin cuerpo y tarea borrada, 404 y 401. Con ellos pasa toda la suite functional (26/26). typecheck y lint también     
    salen limpios.
  - README: actualicé docs/capabilities/tasks/README.md con el nuevo endpoint.
  - Rama: estaba en s8/start, que es una rama sN/*, así que creé feat/delete-task.

  Dos cosas que no hice:
  - Spec: openspec/specs/tasks/spec.md no tiene ningún requisito de borrado. Si quieres que el endpoint quede cubierto por la spec, habría que proponerlo con /opsx:propose.
  - PR y revisión: no he abierto el PR ni pasado el adversarial-reviewer, porque tus reglas los dejan para cuando termine la unidad de trabajo. Dime cuándo la das por terminada y lo hago.   

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.
```

**Qué salió:**
DELETE /api/v1/tasks/:id ya está implementado en la rama feat/delete-task, que ya existía con ese trabajo. Seguí en ella en vez de crear otra. Los 26 tests functional pasan, y typecheck y   
  lint quedan limpios.

  - Controlador: destroy en TasksController busca la tarea y la borra. Responde 204 sin cuerpo, 404 si no existe y 401 sin token. Lleva las anotaciones OpenAPI como el resto.
  - Ruta: router.delete(':id', [controllers.Tasks, 'destroy']) está en el grupo de tasks de start/routes.ts, bajo la autenticación.
  - README: docs/capabilities/tasks/README.md tiene la fila nueva y el recuento actualizado a seis operaciones.
  - Tests: delete.spec.ts cubre el 204 (comprobando que la tarea desaparece), el 404 y el 401 (comprobando que la tarea sigue ahí).

  El typecheck fallaba en ese test porque data es una unión de tipos, así que lo corregí y lo commiteé como 872ead1. Cualquier cuenta con sesión puede borrar cualquier tarea, igual que ocurre 
  ya con el cambio de estado.

  Todavía no he abierto el PR ni pasado el adversarial-reviewer. Según las reglas del repo van una sola vez al terminar la unidad de trabajo. ¿Quieres que lo haga ahora?

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.
```

**Qué salió:**
● DELETE /api/v1/tasks/:id ya funciona: borra la tarea y devuelve 204 sin cuerpo. Está commiteado en la rama feat/delete-task (09576b2). Esa rama la creé porque estabas en s8/start, donde     
  CLAUDE.md prohíbe commitear.

  - Código: el método destroy está en TasksController, con sus anotaciones OpenAPI. La ruta está en backend/start/routes.ts, dentro del grupo de tasks, así que lleva la autenticación del      
    grupo. Si el id no existe devuelve 404, y sin token devuelve 401.
  - Permisos: no comprueba quién es el responsable, igual que el cambio de estado. Cualquier cuenta con sesión puede borrar cualquier tarea.
  - Tests: añadí backend/tests/functional/tasks/delete.spec.ts con tres casos: borrado con 204, 404 y 401. Los tres pasan. El typecheck y el lint también pasan.
  - README: actualicé el de la capability con la nueva fila y el recuento de operaciones.
  - Spec sin requisito de borrado: openspec/specs/tasks/spec.md no tiene ningún requisito sobre borrar tareas. El borrado es definitivo, sin papelera ni confirmación. Si quieres que la spec lo    recoja, habría que abrir un cambio de OpenSpec.
  - openapi:check: falla al arrancar, porque ese comando ya no existe. Por eso no pude comparar el documento OpenAPI. No hubo diff en .adonisjs/ que commitear.
  - git status: muestra unos 37 ficheros como modificados que no toqué. git diff no enseña cambios en ellos, así que parece un efecto de WSL sobre /mnt/c. Intenté revertirlos con git checkout 
    y el sistema lo bloqueó. No hacía falta, y no los incluí en el commit.

  No he abierto el PR ni pasado el adversarial-reviewer: según CLAUDE.md van una sola vez, al terminar la unidad de trabajo.

## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.

```

**Qué salió:**
● DELETE /api/v1/tasks/:id ya existe, devuelve 204 sin cuerpo y está commiteado (3f64405) en la rama nueva feat/delete-task. Typecheck, lint y la suite completa pasan (26 tests).

  - Controlador: TasksController.destroy en backend/app/controllers/tasks_controller.ts. Devuelve 404 si la tarea no existe. Lleva anotaciones OpenAPI para 204, 401 y 404.
  - Ruta: declarada junto a las demás de tasks en backend/start/routes.ts, dentro del grupo con auth, así que sin token da 401.
  - Tests: backend/tests/functional/tasks/destroy.spec.ts cubre el 204 sin cuerpo con la tarea borrada, el 404 y el 401 sin borrar nada.
  - Registro generado: regeneré .adonisjs/ y va en el mismo commit.
  - README: actualicé docs/capabilities/tasks/README.md con la nueva ruta.
  - Spec: openspec/specs/tasks/spec.md no tiene ningún requisito de borrado, así que no toqué la spec. Si quieres que el borrado quede cubierto por ella, habría que proponerlo con OpenSpec.   
  - openapi:check: npm run openapi:check falla al arrancar porque el comando no existe en ace. No pude usarlo para comprobar el documento OpenAPI.

  No he abierto el PR ni lanzado el adversarial-reviewer, porque tu CLAUDE.md pide hacerlo una sola vez al terminar la unidad de trabajo.

## Prompt 5

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.

```

**Qué salió:**
● DELETE /api/v1/tasks/:id ya existe y devuelve 204 sin cuerpo. Typecheck y lint pasan, y los tests también (26 de 26, incluidos los 3 nuevos).

  Está en TasksController.destroy, con la ruta declarada junto a las demás de tasks en backend/start/routes.ts. Cualquier cuenta con sesión puede borrar cualquier tarea, como ya ocurre con el 
  estado y la fecha. Un id que no existe da 404 y sin token da 401.

  También he actualizado docs/capabilities/tasks/README.md (tabla de endpoints y el recuento de operaciones del contrato) y el diff regenerado de .adonisjs/. No encontré fichero OpenAPI que   
  generar. Los decoradores @ApiOperation y @ApiResponse del método recogen el 204, el 401 y el 404, pero no he abierto /api.json para comprobar que salen.

  Añadí backend/tests/functional/tasks/delete.spec.ts con el 204 y que la tarea ya no se puede leer, el 404 y el 401. Usa la transacción global para no dejar datos en la base de desarrollo, y 
  es el único test de tasks además del de responsable.

  Estoy en la rama feat/delete-task, creada desde s8/start. No he hecho commit, PR ni pase del adversarial-reviewer. Si cierras la petición con /commit, lo lanzo; el PR y la revisión
  adversarial irían al terminar la unidad de trabajo.

## Prompt 6

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.

```

**Qué salió:**
 DELETE /api/v1/tasks/:id ya existe y está commiteado en la rama feat/delete-task (6018146). Antes estaba en s8/start, así que creé la rama. Typecheck, lint y los 26 tests functional pasan.  

  - Comportamiento: borra la tarea y devuelve 204 sin cuerpo. Si el id no existe devuelve 404, y sin token 401. No comprueba quién es el responsable, igual que el cambio de estado.
  - Código: el método destroy está en TasksController, con sus anotaciones OpenAPI. La ruta está en el grupo tasks de start/routes.ts.
  - Tests: añadí backend/tests/functional/tasks/delete.spec.ts con tres casos: 204 y la tarea desaparece, 404 y 401 con la tarea intacta.
  - Documentación: actualicé el README de la capability y docs/architecture.md. Los ficheros de .adonisjs/ se regeneraron con la ruta nueva y van en el commit.

  Dos cosas que no pude hacer:
  - npm run openapi:generate y openapi:check fallan en este entorno con Invalid URL al cargar el comando. No toqué docs/api/openapi.json, así que puede quedar desactualizado.
  - No creé el PR ni pasé el adversarial-reviewer, porque tu CLAUDE.md los reserva para el final de la unidad de trabajo. Si esta ya es la última petición, dímelo y los hago.

