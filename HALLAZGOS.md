# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho:

Escribe **una sola línea por punto**, con tus palabras y con lo que mediste, no con lo que suponías.

## 1. Número de casos que fallaron y que siguieron en verde

Cuántos de tus casos nuevos fallaron y cuántos de los que ya había siguieron en verde, con la cifra que te dio la pantalla.

- 7 de 13 casos nuevos fallan (5 de 7 funcionales y 2 de 6 unitarios); los 40 funcionales que ya había siguen en verde, y antes no había ningún unitario.

## 2. Casos nuevos en verde y por qué

Cuál de tus casos nuevos PASÓ, si alguno pasó, y por qué crees que pasó. Es la pregunta más interesante del ejercicio, y la respuesta no está en ningún sitio: se deduce mirando qué tienen en común los que fallaron.

- Pasaron 4 unitarios y 2 funcionales («Sin fecha» y «Aplazar»): ninguno tiene la tarea en `done` ni lee la fecha como `Date` (los unitarios y la respuesta del PUT la llevan como texto y «Sin fecha» no tiene), y todos los que fallan tienen una de esas dos cosas; en los funcionales un fallo tapaba al otro: la consulta no marca nunca vencida, y por eso no se veía que la regla ignora `done`.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- Dudé de si el test de «tarea hecha» era correcto porque el método no recibe el estado; no es un parámetro sino un dato de la tarea (`this.status`), y la regla lo exige; lo que no he comprobado es la causa en el código, solo la he deducido de las respuestas.
