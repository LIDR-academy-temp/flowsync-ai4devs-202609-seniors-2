# Eval PC — medición de la regla OpenAPI + README

## Predicción (antes del 1.er intento)

5/5

## Parte A — Intentos

Encargo (idéntico en los 5; sin recordar la regla):

> Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.

| # | Control (ruta DELETE?) | Resultado (README actualizado?) | Cuenta |
|---|---|---|---|
| 1 | sí | sí | sí |
| 2 | sí | sí | sí |
| 3 | sí | sí | sí |
| 4 | sí | sí | sí |
| 5 | sí | sí | sí |

**Cumplimiento README: 5/5** (5 contados; ninguno descartado por fallo de control).

Entre intentos: `git checkout -f s8/start && git reset --hard upstream/s8/start && git clean -fd` y borrado de ramas `feat/*` locales.

## Parte B — Tres líneas

1. Predicción 5/5 y resultado 5/5: coincidieron; en todos los intentos contados el agente declaró la ruta y actualizó el README (y en la práctica también OpenAPI / `.adonisjs/` en el mismo commit).

2. Con este resultado convertiría la regla en **comprobación automática** (p. ej. fallar CI/`openapi:check` + diff del README de la capability tocada): la instrucción ya se cumple a menudo, pero el punto del módulo es no depender de “se vio cumplir”; un check hace el incumplimiento detectable.

3. La medición no comprueba, entre otras cosas: si el OpenAPI quedó correcto en *todos* los intentos (solo miramos README + ruta); si el commit único incluye ambos artefactos siempre; línea base sin la regla en `CLAUDE.md`; ni que el grader humano no introduzca sesgo al leer el README.
