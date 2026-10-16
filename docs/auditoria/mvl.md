# Auditoría de las reglas de proceso (mvl)

Contraste de las reglas de proceso de `AGENTS.md` (idénticas a las de `CLAUDE.md`, comprobado con `diff`) con los últimos 15 commits (`b955a72`..`eff1686`) y el estado del repo a 2026-10-12, en la rama `auditoria-mvl`.

Contexto que condiciona varios veredictos:

- Los 15 commits forman una **historia lineal sin merges** (`git log -15 --pretty='%h %p'`). Solo los contienen `s5/start` y `auditoria-mvl`, que apuntan al mismo HEAD (`git branch -a --contains <sha>`).
- Hoy el repo no tiene ninguna de las comprobaciones automáticas que se proponen en la tabla: no existe `.github/workflows/` ni hay hooks de git. El único hook es el de Claude Code que pasa Prettier por el frontend.
- Git no registra en qué rama se creó un commit, ni qué petición lo originó, ni qué se dijo en el chat. Por eso hay reglas que solo pueden comprobarse en parte.

## Expectativa antes de auditar

Lo que esperaba encontrar antes de mirar los commits:

1. **Rama de trabajo al empezar una tarea:** creo que no se cumple.
2. **Skill `/commit`:** creo que sí se cumple.
3. **Documentación actualizada:** no se ha cumplido siempre.
4. **PR y revisión adversarial:** tampoco se cumple.
5. **Respuesta al abrir el PR (solo la URL):** supongo que se cumple, aunque va a ser difícil de comprobar.

## Resultado

| # | Qué pide la regla | Qué se revisó | Veredicto | Evidencia | Qué haría con ella |
|---|---|---|---|---|---|
| 1 | Una rama agrupa toda una unidad de trabajo, aunque esta incluya varias peticiones. No se abre una rama por petición. | `git log -15 --pretty='%h %p'`; `git branch -a --contains <sha>` para cada commit | No se cumple | Ninguna rama de trabajo contiene los 15 commits: solo están en `s5/start` (y en `auditoria-mvl`, que apunta al mismo HEAD), en historia lineal sin merges. Ahí se mezclan varias unidades de trabajo: material del curso (`b955a72`, `afc4b74`, `21ce54d`, `eff1686`) y el trabajo sobre `tasks` (`4427afc`..`cbe9617`). | Convertirla en comprobación automática: la misma **protección de rama en GitHub** de la regla 2 obliga a que el trabajo pase por una rama propia. Que cada rama corresponda a una sola unidad de trabajo sigue dependiendo de revisarlo a mano en el PR. |
| 2 | Las ramas de trabajo nuevas se crean como `feat/<slug>` a partir de `main` o de una `sN/*`. Nunca se commitea directamente en `main` ni en una `sN/*`. | `git branch -a --contains <sha>` para cada commit; `git log -15 --merges`; `git reflog` | No se cumple | `afc4b74`, `21ce54d` y `eff1686` solo están en `s5/start` y ninguna rama `feat/*` los contiene. Lo mismo pasa con `4427afc`..`cbe9617`: ninguna rama de trabajo los contiene. | Convertirla en comprobación automática: **protección de rama en GitHub** sobre `main` y `sN/*` (control principal, no se puede saltar), más un **hook local `pre-commit`** como aviso temprano (se salta con `--no-verify`). Requiere una excepción para quien mantiene el curso. |
| 3 | Al terminar cada petición, se commitea con la skill `/commit`, que genera un mensaje convencional `tipo(scope): descripción`. | `.claude/skills/commit/SKILL.md`; `git log -15 --format='%s'` | No se puede comprobar | Git no registra si se usó la skill ni qué petición originó cada commit. 14 de los 15 mensajes siguen el formato. `eff1686` («docs: …») no lleva scope. | Convertirla en comprobación automática: **hook local `commit-msg`** con commitlint para el formato, más un **job de CI** que valide los mensajes de los commits del PR (cubre a quien se salta el hook). El «un commit por petición» no se puede automatizar. |
| 4 | Si un commit toca rutas, controladores, validadores o transformers de una capability, ese mismo commit actualiza el documento OpenAPI (el diff regenerado de `.adonisjs/`) y `docs/capabilities/<nombre>/README.md`. | `git show --stat <sha>` filtrado por `start/routes`, `app/controllers`, `app/validators`, `app/transformers`, `.adonisjs`, `docs/capabilities`; `ls docs/capabilities` | Se cumple | Desde que existe la regla (`160fbc7`), solo `cbe9617` toca controladores, y actualiza a la vez el README de `tasks` y los esquemas OpenAPI. `4e03d1f` es anterior a la regla y no la cumplía. `auth` sigue sin README. | Convertirla en comprobación automática: **job de CI** que falle si el diff del PR toca esas rutas sin `docs/capabilities/<cap>/README.md`, o si al regenerar `.adonisjs/` queda diff. En un hook de cada commit sería lento y fácil de saltar. |
| 5 | Cuando termina la unidad de trabajo, se abre un PR con `gh pr create` y una descripción completa. Después, como último paso, pasa el subagente `adversarial-reviewer`. | `git log -15 --merges`; `gh pr list --state all`; `.claude/agents/adversarial-reviewer.md` | No se puede comprobar | Ningún PR ha llevado estos 15 commits a la rama (no hay merges en la historia), y el subagente es de solo lectura y no deja rastro, así que no hay forma de saber si hubo PR ni revisión adversarial para ellos. | Convertirla en comprobación automática: **regla de merge en GitHub** con un check obligatorio que exija el comentario del revisor en el PR. El agente principal lo publica con `gh pr comment`, porque el subagente es de solo lectura. Otra opción: ejecutar la revisión directamente en CI. |
| 6 | Al abrir el PR, en el chat solo se responde con su URL. La descripción no se repite, porque queda en el PR. | Repo completo; las sesiones de chat no están versionadas | No se puede comprobar | La regla trata sobre la respuesta en el chat, y esa sesión no queda guardada ni en el repo ni en GitHub. | Borrarla: solo ahorra unos pocos tokens, y el resumen en el chat también es útil (ver Parte B). |

## Parte B: las tres líneas

1. **La regla en la que más me equivoqué:** la de la skill `/commit`. Pensaba que se podía comprobar por los mensajes de commit, pero en realidad no hay garantía de que se usara.
2. **Una regla que no se puede comprobar con la información disponible:** la última, la de no devolver la descripción del PR en el chat, porque no hay evidencia de que se haya seguido o no.
3. **La regla que eliminaría y por qué:** la última. Solo ahorra unos pocos tokens, y no está mal que el chat dé feedback de lo que se ha hecho en el PR: así no hace falta abrirlo para comprobar la descripción.
