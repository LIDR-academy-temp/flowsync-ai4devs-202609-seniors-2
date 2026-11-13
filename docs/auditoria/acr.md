# Auditoría de las reglas de proceso — ACR

## Expectativa previa

Registrada el 2026-11-13 01:44 (-05), antes de contrastar las reglas con el historial.

| # | Regla | Expectativa |
|---|---|---|
| 1 | Una rama por unidad de trabajo; nunca commit directo en `main` ni en `sN/*` | Sí |
| 2 | Un commit por petición, usando `/commit` | Sí |
| 3 | El OpenAPI y el README de la capability se actualizan en el mismo commit | No |
| 4 | `gh pr create` y el `adversarial-reviewer` una sola vez, al final de la unidad | No |
| 5 | Al abrir el PR, en el chat solo se responde con la URL | Sí |

Contexto: antes de escribir esta expectativa ya había leído el resumen de las reglas de proceso y de los últimos 8 commits en una sesión anterior con el agente, lo que puede haberla influido.

## Parte A: tabla

| # | Qué pide la regla | Qué se revisó | Veredicto | Evidencia | Qué harías con ella |
|---|---|---|---|---|---|
| 1 | Que cada trabajo vaya en su propia rama y que nunca se haga un commit directamente en `main` ni en las ramas `sN/*` | `git branch -a`; `git log -15 --format='%h %p \| %an \| %ad \| %s'`; `git branch -a --contains <hash>`; `gh pr list --repo LIDR-academy-temp/flowsync-ai4devs-202609-seniors-2 --state all` | no se puede comprobar con la información disponible | Los 15 commits están directamente en las ramas `sN/*`, sin merges ni PRs, pero no se sabe en qué rama se trabajaron: el historial se reescribió al traerlo de otro repo (`b955a72` tiene fecha posterior a los commits que vienen después) | Convertirla en una comprobación automática: un hook que no deje hacer commit si estás en `main` o en una `sN/*` |
| 2 | Que cada petición se cierre con su propio commit, hecho con la skill `/commit` | `cat .claude/skills/commit/SKILL.md`; `git log -15 --format='--- %h %s%n%b'` | no se puede comprobar con la información disponible | Los 15 mensajes tienen el formato que pide la skill, pero `/commit` no deja ninguna marca, así que no se distingue de un commit a mano; y para saber si hay uno por petición harían falta las conversaciones, que no están en el repo | Convertirla en una comprobación automática: un hook `commit-msg` que exija el formato `tipo(scope): …` (la parte de "uno por petición" no se puede automatizar) |
| 3 | Que si un cambio toca rutas, controladores, validadores o transformers de una capability, en ese mismo commit vayan también al día el documento OpenAPI (el diff de `.adonisjs/`) y el README de esa capability | `git log -15 --name-status --format='=== %h %ad %s'`; `git show cbe9617`; `grep -n ReturnType backend/.adonisjs/client/registry/schema.d.ts` | se cumple | Desde que existe la regla, el único commit que toca una capability es `cbe9617`, y lleva el README y las anotaciones OpenAPI; no trae diff de `.adonisjs/` porque solo añade decoradores (no lo he regenerado para confirmarlo, porque eso escribe ficheros) | Convertirla en una comprobación automática: un check en CI que regenere `.adonisjs/` y falle si hay diff, y que avise si se toca `app/` de una capability sin tocar su README |
| 4 | Que el PR (con una buena descripción) y la revisión del `adversarial-reviewer` se hagan una sola vez, cuando termina todo el trabajo, y que la revisión sea lo último | `gh pr list --state all` (origin y upstream); `gh pr view 2 --json commits,body`; `cat .claude/agents/adversarial-reviewer.md`; `grep -rli adversarial --include='*.md' .` | no se puede comprobar con la información disponible | Ninguno de los 15 commits llegó por un PR de este repo, porque se trajeron de otro con el historial reescrito, y la revisión adversarial no deja rastro. Para comprobarla harían falta los PRs del repo original y las conversaciones donde se lanzó el revisor | Convertirla en una comprobación automática: que el revisor publique sus hallazgos como comentario en el PR y que un check en CI no deje mergear sin ese comentario |
| 5 | Que al abrir el PR el agente conteste en el chat solo con el enlace, sin repetir el resumen, porque la conversación se pierde y el PR se queda | `head -30 prompts.md`; `grep -n -iE 'gh pr\|pull request\|\bPR\b' prompts.md`; `gh pr list --state all` (origin y upstream) | no se puede comprobar con la información disponible | La regla habla de lo que se dice en el chat, y eso no queda en el repo: `prompts.md` solo guarda los prompts del alumno, no las respuestas, y en este repo no se ha abierto ningún PR con estos commits. Harían falta las conversaciones donde se abrió el PR | Dejarla: es barata, no se puede automatizar (va sobre lo que se dice en el chat, no sobre los ficheros) y lo importante, que la descripción esté en el PR, ya lo pide la regla 4 |

## Parte B: las tres líneas

1. **La regla en la que más me equivoqué:** la regla 3. Dije que no se cumplía y, en realidad, es la única que se cumple con evidencia.
2. **Una regla que no se puede comprobar:** la regla 5. En vez de "responde solo con la URL", pediría que la descripción completa esté en el cuerpo del PR, que es lo que importa de verdad y sí se puede revisar.
3. **La regla que eliminaría y por qué:** la regla 5 (al abrir el PR, contestar en el chat solo con la URL). Pertenece al segundo caso, una regla que no aporta valor: no protege nada que se quede en el repo. Lo único que dura es que la descripción completa esté en el PR, y eso ya lo pide la regla 4 (`gh pr create` "con una descripción completa de los cambios en el cuerpo del PR"). Si se incumple no pasa nada: que el agente repita el resumen en el chat no rompe el código, ni el historial, ni el PR. En la tabla puse "dejarla"; al escribir esta parte cambié de opinión.
