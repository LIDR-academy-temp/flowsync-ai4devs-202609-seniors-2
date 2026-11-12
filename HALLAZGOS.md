# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Qué regla saltó en tu prueba, y la línea literal que dejó el registro.

- Saltó la regla del correo (actuó el hook, no el CLAUDE.md) y el registro dejó: `- 2026-11-12T16:02:02Z BLOQUEADO regla=correo archivo=docs/capabilities/tasks/README.md`

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

- El nombre de la persona de la cuenta de pruebas entró en `a62ab43` (en el README y en el mensaje del commit) aunque su correo se bloqueó: ninguna regla busca nombres y el hook no lee el mensaje del commit.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- Dudé de si el hook vigila todos los commits, y no: solo los comandos que lanza el agente (mi amend y mi rebase desde la terminal no pasaron por él), y un `git -C <dir> commit` del agente tampoco lo dispara.
