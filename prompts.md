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

**Modelo:** Sonnet 5.5, effort high
**Herramienta:** Claude Code
**Sesiones:** lanzado en 5 sesiones independientes, con el mismo prompt cada vez.

```
Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.
```

**Qué salió:** funcionó a la primera en las 5 sesiones.

## Prompt 2

**Modelo:** Sonnet 5.5, effort high
**Herramienta:** Claude Code

```
Edita @prompts.md para añadir primero que en 5 sesiones indepedientes se lanzo  el prompt "Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`." con el modelo actual sonnet 5.5 effort high no hagas commit ni pr todavía, indica que funciono a la primera.
```

**Qué salió:** funcionó a la primera: sustituyó el ejemplo por el Prompt 1 real.

## Prompt 3

**Modelo:** Sonnet 5.5, effort high
**Herramienta:** Claude Code

```
escribe un nuevo archivo `docs/evals/mvl.md` con las 2 partes 

## 🅰 Parte A: los cinco intentos

Resumen de los 5 ensayos:

| Intento | Control | Resultado |
|----------|---------|-----------|
| 1        | Si      | Si        |
| 2        | Si      | Si        |
| 3        | Si      | Si        |
| 4        | Si      | Si        |  
| 5        | Si      | Si        |

Ha habido problemas con el entorno en algunos intentos estaba con node 22 y en otros con node 24 pero no afecto al resultado final. En algun ensayo se detecto la rama feat/* y se borro para que no afectara a los siguientes intentos.

## 🅱 Parte B: las tres líneas

1. Tu predicción y el resultado obtenido. Si no completaste los cinco intentos, indica cuántos hiciste.

Mi predicción fue que en los cinco intentos el README de la capability quedaría actualizado, y efectivamente, en los cinco intentos el README fue actualizado correctamente.

1. Qué harías con ese resultado: eliminar la regla, reescribirla o convertirla en una comprobación automática. Explica por qué tomarías esa decisión.

Pues la reescribiría o mantendría, hay que tener mas evidencia de que aporte valor.

1. Algo que tu medición no está comprobando. Identifica al menos una limitación de los resultados.

No se comprueba con la línea base , es decir quitando la regla de las instrucciones para ver si el resultado es el mismo, y si es así, entonces la regla no aporta valor.
```

**Qué salió:** funcionó a la primera: creó `docs/evals/mvl.md` con las dos partes, corrigiendo solo erratas y tildes.
