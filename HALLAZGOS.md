# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: un cambio de motor a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Las filas que cambian y la rama
...
- 0 filas cambian de valor guardado: las 4 migraciones originales (git diff vacío) crean las tablas vacías en PostgreSQL y no se copia ningún dato desde SQLite; rama 1, reversible (volver a SQLite es revertir la configuración). Lo que cambia es cómo entrega el driver pg la columna date al código: en la prueba, dueDate llegó como [VALOR dueDate] e isOverdue como [VALOR isOverdue] para una tarea con fecha 2026-11-10 consultada con today=2026-11-16.

## 2. Lo que la batería de pruebas no podía ver
...
- Ninguna prueba cubre el vencimiento (grep de isOverdue|dueDate|due_date en backend/tests: [N] resultados), así que las 23 pasan igual en PostgreSQL; typecheck pasa y el diff de schema.ts sale vacío porque schema_rules.ts fuerza due_date a string, pero la comparación this.dueDate < referenceDay de app/models/task.ts:55 recibe ahora [Date/texto] en vez de texto.

## 3. Tu duda
...
- No sé cuál es el arreglo correcto (parser del tipo date en pg, prepare/consume en la columna o cambiar la regla a DateTime) y no comprobé si createdAt/updatedAt cambian de formato entre motores; además, isOverdueOn no excluye las tareas done como exige la spec (preexistente, no causado por el motor). Las