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

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Añade a la capability tasks el endpoint DELETE /api/v1/tasks/:id, que borra una tarea y devuelve 204 sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de tasks
```

**Qué salió:** aplicó cambios respetando reglas

## Prompt 2

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Revisa el cambio recién aplicado, incluiste 'Delete' en las rutas? Actualizaste 'docs/capabilities/tasks/README.md' con el nuevo endpoint?
```

**Qué salió:** Confirma cambios y rutas

## Prompt 3

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Añade a la capability tasks el endpoint DELETE /api/v1/tasks/:id, que borra una tarea y devuelve 204 sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de tasks
```

**Qué salió:** aplicó cambios utilizando OpenSpec, generó documentación asociada a OpenSpec pero nunca actualizó "docs/capabilities/tasks/README.md"

## Prompt 4

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Revisa el cambio recién aplicado, incluiste 'Delete' en las rutas? Actualizaste 'docs/capabilities/tasks/README.md' con el nuevo endpoint?
```

**Qué salió:** Si incluyo la ruta pero no actualizó el documento, ofrece actualizarlo. 

## Prompt 5

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Añade a la capability tasks el endpoint DELETE /api/v1/tasks/:id, que borra una tarea y devuelve 204 sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de tasks
```

**Qué salió:** aplicó cambios respetando reglas

## Prompt 6

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Revisa el cambio recién aplicado, incluiste 'Delete' en las rutas? Actualizaste 'docs/capabilities/tasks/README.md' con el nuevo endpoint?
```

**Qué salió:** Confirma cambios y rutas

## Prompt 7

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Añade a la capability tasks el endpoint DELETE /api/v1/tasks/:id, que borra una tarea y devuelve 204 sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de tasks
```

**Qué salió:** aplicó cambios respetando reglas

## Prompt 8

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Revisa el cambio recién aplicado, incluiste 'Delete' en las rutas? Actualizaste 'docs/capabilities/tasks/README.md' con el nuevo endpoint?
```

**Qué salió:** Confirma cambios y rutas

## Prompt 9

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Añade a la capability tasks el endpoint DELETE /api/v1/tasks/:id, que borra una tarea y devuelve 204 sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de tasks
```

**Qué salió:** aplicó cambios respetando reglas

## Prompt 10

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Revisa el cambio recién aplicado, incluiste 'Delete' en las rutas? Actualizaste 'docs/capabilities/tasks/README.md' con el nuevo endpoint?
```

**Qué salió:** Confirma cambios y rutas

## Prompt 11

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Lee la sección "La tarea" del readme del repositorio, genera el documento "docs/evals/mgs.md" con la plantilla de las respuesta de las partes A y B para yo completarlas
```

**Qué salió:** generó documento listo para ser completado de mi parte con los resultados

## Prompt 12  

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
actualiza la tabla de la sección "2. Intentos" con la siguiente info: todos los arranques fueron en limpios, todos declararon la ruta DELETE, solo el intento 2 no actualizó el README, el resto si, todos cuentan y en notas del segundo intento, el modelo optó por resolver la tarea usando openspec y omitió actualizar el README
```

**Qué salió:** actualiza documento con los resultados que indico

