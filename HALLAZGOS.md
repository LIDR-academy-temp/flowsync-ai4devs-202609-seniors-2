# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Se activó la regla email-externo:

- 2026-11-11T14:51:12Z BLOQUEADO email-externo docs/capabilities/tasks/README.md

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

- No estoy muy seguro, pero creo que los nombres (Ada Lovelace). En primer lugar, el hook no está hecho para detectarlos. En segundo, tampoco parecen tan sencillos de identificar a menos que se busquen coincidencias en un diccionario. Si no, habría que buscar strings a continuación de palabras clave como fullName. Incluso así, habría que adoptar alguna convención de nombres admitidos para ejemplos, para poder distinguirlos como en el caso de los dominios de correo.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- Precisamente, de la respuesta anterior.
