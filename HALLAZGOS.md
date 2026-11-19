# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: un cambio de motor a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Las filas que cambian y la rama

Cuántas filas cambian de valor en tu cambio de esquema, medido con una consulta, y en qué rama del
árbol de reversibilidad cae. Si tu migración no toca datos, dilo tal cual: también es una respuesta.

- Ninguna fila cambia de valor, porque mi cambio no toca datos.

## 2. Lo que la batería de pruebas no podía ver

Una cosa que la batería de pruebas no podía ver. Si no encontraste ninguna, escribe qué buscaste y dónde.

- Lo que la batería no ve es `due_date`: `pg` devuelve las columnas `DATE` como `Date` y SQLite las devolvía como texto, pero `schema_rules.ts` la declara `string`. Solo hay tests de `auth`, ninguno de `tasks`, y no lo he comprobado con una tarea vencida contra la base real.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- Dudé de si el diff vacío de `schema.ts` significaba que no se había perdido nada.
