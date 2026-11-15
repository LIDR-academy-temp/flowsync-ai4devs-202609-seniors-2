# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: un cambio de motor a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Las filas que cambian y la rama

Cuántas filas cambian de valor en tu cambio de esquema, medido con una consulta, y en qué rama del
árbol de reversibilidad cae. Si tu migración no toca datos, dilo tal cual: también es una respuesta.

- 0 de 9 filas cambian de valor: comparé celda a celda las 71 celdas de SQLite con una importación limpia en PostgreSQL. 48 son idénticas carácter a carácter y las 23 restantes son fechas que apuntan al mismo instante con otra representación (texto o epoch en ms → `timestamptz`, milisegundos conservados). La migración no reescribe datos y cae en la rama reversible: se deshace volviendo a apuntar a SQLite.

## 2. Lo que la batería de pruebas no podía ver

Una cosa que la batería de pruebas no podía ver. Si no encontraste ninguna, escribe qué buscaste y dónde.

- Con PostgreSQL, el driver `pg` devuelve `due_date` como un `Date` y no como el texto `AAAA-MM-DD` que daba SQLite. `schema.ts` sigue declarando `string` por la regla de `schema_rules.ts`, así que el typecheck sale en verde. Pero `isOverdueOn` compara `Date < '2026-11-15'` y da siempre `false`: una tarea que vencía el 2026-11-12 no sale vencida. Además, el JSON trae `2026-11-12T00:00:00.000Z` y rompe `formatDay` en el detalle. Ningún test pide el detalle de una tarea con fecha.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- Dudé de en qué zona horaria guardaba SQLite sus fechas en texto. Las importé como UTC y solo lo pude cruzar con un dato: el `created_at` del usuario coincide con el epoch del token creado al registrarse. Si no fuera UTC, las 6 filas de `users` y `tasks` estarían desplazadas sin que la comparación lo detectara. Y el `isOverdue` roto lo medí leyendo con el driver `pg`, no con una tarea vencida pidiendo su detalle a la API.
