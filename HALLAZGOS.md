# Hallazgos

Requirement «Cuándo una tarea está vencida» (`openspec/specs/tasks/spec.md`). Tests en
`backend/tests/functional/tasks/vencimiento.spec.ts` (7, uno por Scenario) y
`backend/tests/unit/task_overdue.spec.ts` (6). Implementación sin tocar: `git diff --stat` vacío.
Línea de partida: `make test` → `Tests  40 passed (40)`; `make test-unit` → `NO TESTS EXECUTED` con exit 0.

## 1. Cuántos fallaron y cuántos siguieron en verde

- Fallaron 5 de mis 13 casos nuevos: 3 de 7 por HTTP (`make test-e2e` → `Tests  44 passed, 3 failed (47)`) y 2 de 6 unitarios (`make test-unit` → `Tests  4 passed, 2 failed (6)`). Los 40 que ya había siguieron en verde (`make test` → `Tests  48 passed, 5 failed (53)`).

## 2. Cuál pasó y por qué

- Por HTTP pasaron 4 de 7, y los 4 esperan `isOverdue: false`. Los 3 rojos son justo los que esperan `true` (ayer, y las dos comprobaciones previas de «darla por hecha» y «aplazar»). La fecha sube de PostgreSQL como `Date`, y `this.dueDate < '2026-08-20'` compara un `Date` con un texto: da `false` siempre, sin error. Así que la regla contesta «no vencida» a todo. «Hecha con la fecha pasada» pasa de rebote: el unitario, que le pasa texto, la pone en rojo porque `isOverdueOn` ni siquiera mira el `status`. Cada nivel ve un defecto distinto y ninguno ve los dos.

## 3. De qué dudé o qué no pude comprobar

- No pude correr `make test-e2e` tal cual. Mi `docker-compose` 1.29 (Podman) no admite `up --wait`, y en WSL `127.0.0.1:5441x` no enruta (`route_localnet=0`). Lo corrí como `make -o db-up -o migrate test-e2e`, con `DB_HOST` apuntando a la IP del contenedor de pruebas. El caso texto/`Date` necesita `as unknown as string` porque `schema.ts` tipa `dueDate` como `string` y el tipo miente. Y el `Date` de la sonda llega a medianoche UTC con `TZ=UTC`: con otro huso del servidor no lo comprobé.
