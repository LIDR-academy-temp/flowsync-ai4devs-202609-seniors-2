# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Qué regla saltó en tu prueba, y la línea literal que dejó el registro.

- Se activó el Hook
2026-11-11T03:09:23Z BLOQUEADO regla 2 (correo con dominio real) docs/capabilities/tasks/README.md

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

- No puede detectar que en el archivo README.md en la raíz del proyecto ya contenía previamente una dirección de correo con un dominio real. La limitación radica en que el dato ya existe previamente, y el hook solo actua con los cambios que se están introduciendo.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- No pude comprobar que el agente usara la regla definida en el archivo CLAUDE.md parece que no la seguía puesto que activaba el hook. 
