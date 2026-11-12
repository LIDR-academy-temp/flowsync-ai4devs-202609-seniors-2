# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Qué regla saltó en tu prueba, y la línea literal que dejó el registro.

- Saltó la regla 2 en las pruebas realizadas, ambos con el mensaje "BLOQUEADO regla 2 (correo con un dominio que no es de ejemplo) archivo: `ruta del archivo`"

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

- Lo que se le haya pasado al agente vía prompt o lo que esté en el historial de git, ya que el hook solo revisa el diff de archivos modificados.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- Cómo se hubiera comportado el laboratorio si este repositorio no tuviera en el README las pruebas y comportamiento esperado, noté luego de realizarlas que el agente da una respuesta sesgada puesto que lee en qué consiste los ejercicios que se están realizando.
