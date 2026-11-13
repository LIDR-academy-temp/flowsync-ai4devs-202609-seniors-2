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
En el Claude.md necesito q busques las reglas de proceso y me hagas un resumen de lo q hacen.
```

**Qué salió:** funcionó a la primera; localizó las 5 reglas de la sección "Reglas de proceso" y las resumió una por una. Lo pedí antes de escribir mi expectativa, así que pudo influirla.

## Prompt 2

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Necesito q me realices un resumen de los ultimos commits para entender que se hizo y el detalle.
```

**Qué salió:** funcionó a la primera; resumió los últimos 8 commits con su detalle. Lo pedí antes de escribir mi expectativa, así que pudo influirla.

## Prompt 3

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Vamos a hacer una AUDITORÍA, no una tarea de corrección, de la sección
"Reglas de proceso" de CLAUDE.md, contrastándola con los últimos 15 commits de
la rama actual y con el estado actual de los ficheros del repo.

Restricciones:
- No modifiques, crees, muevas ni borres ningún fichero del repo. Aunque
  encuentres algo mal, no lo corrijas: solo lo registras.
- Única excepción: docs/auditoria/acr.md, y dentro de él solo la tabla de
  "Parte A". No toques "Expectativa previa" ni "Parte B".
- No apliques las reglas de proceso mientras auditas: nada de commits, /commit,
  git add, cambiar de rama, abrir PRs ni lanzar el adversarial-reviewer.
- Solo comandos de lectura (git log, git show, git branch, git status,
  gh pr list/view, leer ficheros). Si un comando escribiría algo, no lo ejecutes
  y dímelo.

Rellena la tabla que ya existe en docs/auditoria/acr.md, respetando sus
columnas, una fila por regla y en el orden del CLAUDE.md:
- Qué pide la regla: una frase con tus palabras.
- Qué se revisó: el comando exacto o el fichero consultado.
- Veredicto: solo "se cumple", "no se cumple" o "no se puede comprobar con la
  información disponible".
- Evidencia: una línea. Si no se cumple, dónde (hash o fichero). Si no se puede
  comprobar, qué información falta.
- Qué harías con ella: dejarla, borrarla o convertirla en comprobación
  automática.
Si una regla tiene partes con veredictos distintos, avísame antes de partirla.

Ve regla por regla. Empieza por la regla 1: enséñame los comandos y su salida,
propón la fila y espera mi OK antes de escribirla en el fichero
```

**Qué salió:** (opcional, una línea) funcionó a la primera / tuve que insistir / me inventó una ruta que no existe.