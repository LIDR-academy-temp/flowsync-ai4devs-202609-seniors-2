# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: un cambio de motor a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Cuántos de tus casos nuevos fallaron y cuántos de los que ya había siguieron en verde

Los que ya había siguieron todos en verde, y de los casos nuevos e2e pasaron 4 de 7, y los unitarios pasaron 4 de 6.

-

## 2. Cuál de tus casos nuevos PASÓ, si alguno pasó, y por qué crees que pasó

El GET siempre devuelve "sin vencer" si tiene fecha, entonces pasan todos los gets que tienen que dar por no vencida.

-

## 3. De qué dudaste, o qué no pudiste comprobar

Cual es el motivo real de que pasen los tests, si se hace la comprobación real de la fecha.
Por el test añadido se supone que por algo de la conversión de tipos siempre sale como no vencida.

También dudo de los tests unitarios si han tirado de BD

-
