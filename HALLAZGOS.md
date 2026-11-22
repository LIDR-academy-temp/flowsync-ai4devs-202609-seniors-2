# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: un cambio de motor a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Las filas que cambian y la rama

1.  make test-e2e: 44 passed, 3 failed (47) → de mis 7 casos funcionales nuevos fallan 3 y pasan 4; los 40 que ya había siguen en verde. make test-unit: 4 passed, 2 failed (6) (antes: NO TESTS EXECUTED).

-

## 2. Lo que la batería de pruebas no podía ver

1.  Pasaron los 4 funcionales que esperan isOverdue: false (hoy, futura, sin fecha, hecha con fecha pasada) o que leen isOverdue de la respuesta del PUT (aplazar); los 4 que fallan esperan true en un GET, es decir, sobre una tarea leída de PostgreSQL: ahí dueDate llega como Date, Date < 'AAAA-MM-DD' siempre es false, y una regla que siempre dice «no» satisface gratis todos los casos negativos.

-

## 3. Tu duda

1.  Dudé si «Una tarea hecha con la fecha pasada» (verde) cubre de verdad la condición status !== 'done': por HTTP no la distingue del bug del Date y solo el unitario la pone en rojo; tampoco pude envejecer una tarea sin tocar la base (lo expresé con un today lejano), y «darla por hecha» seguirá en rojo tras arreglar la regla porque dueDate sale como instante.

-
