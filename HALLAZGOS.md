# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: un cambio de motor a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Las filas que cambian y la rama

Cuántas filas cambian de valor en tu cambio de esquema, medido con una consulta, y en qué rama del
árbol de reversibilidad cae. Si tu migración no toca datos, dilo tal cual: también es una respuesta.

- 0 filas cambian de valor (migraciones intactas, solo esquema; sin backfill). Rama: cambio de motor sin transformación de datos — no hay filas que deshacer, pero el runtime de tipos ya no es el de SQLite.

## 2. Lo que la batería de pruebas no podía ver

Una cosa que la batería de pruebas no podía ver. Si no encontraste ninguna, escribe qué buscaste y dónde.

- Ningún test cubre `dueDate`/`isOverdueOn` (busqué en `backend/tests/**`). Con PostgreSQL Lucid entrega `dueDate` como `Date`; `isOverdueOn` compara con `<` asumiendo string ISO → una tarea con `due_date=2020-01-01` da `isOverdueOn('2026-11-19') === false`. Los 23 tests siguen en verde.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- El diff de `schema.ts` vs `s10/start` está vacío (`schema_rules` fuerza `string`), así que el tipado miente respecto al runtime; no comprobé si un `prepare`/`consume` en la regla bastaría sin tocar migraciones. En Podman, `127.0.0.1:54410` da “No route to host” y hay que usar la IP del host.