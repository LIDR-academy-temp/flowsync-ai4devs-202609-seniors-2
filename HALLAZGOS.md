# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: un cambio de motor a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Las filas que cambian y la rama

No se tocó ninguna migracion, ninguna fila cambio.

-

## 2. Lo que la batería de pruebas no podía ver

El tipo de objeto que regreso pg. El dueDate es tipo Date, pero se usa como tipo string para comparar.

-

## 3. Tu duda

Muchas, no tengo experiencia en con ts, lucid.

-

Parte B

1. Ejecuta la comprobación de tipos ((cd backend && npm run typecheck)) y anota si pasa o falla. 

Pasa aparentemente, ya que el resultado no muestra errores.

2. Compara el archivo de tipos generado (backend/database/schema.ts) con el de la rama de partida. El diff puede mostrar declaraciones cambiadas o salir vacío, y las dos salidas son normales. Si hay cambios, indica qué declaraciones cambiaron de tipo y anota, para cada una, el tipo anterior y el nuevo. Si el diff está vacío, busca qué fija esos tipos al cambiar de motor: vacío no significa que no haya cambiado nada, sino que lo que cambió no está en lo que el proyecto declara.

El cambio esta en el motor de base de datos y como regresa el valor de una fecha.

3. Busca cómo decide el proyecto si una tarea está vencida. Lee el comentario que explica por qué funciona esa comparación y contrástalo con lo que encontraste en el paso anterior. Indica si sigue siendo válido y compruébalo con una tarea que ya debería estar vencida, no solo leyendo el código.

El codigo compara dueDate con referenceDate pero los tipos de objetos son diferentes por lo que la comparacion siempre es falsa.