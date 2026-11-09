# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Qué regla saltó en tu prueba, y la línea literal que dejó el registro.

- Se activo el hook con la regla (2) y dejo la siguiente linea en el registro: 2026-11-09T08:45:04Z BLOQUEADO regla 2 (correo de una persona, dominio no reservado) en `docs/capabilities/tasks/README.md`

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

- No se puede cazar el correo o secreto si incluye en el dialogo con agente y se guarda en su propia memoria, porque el hook solo revisa los archivos del proyecto y no la memoria del agente.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- No he probado las otras reglas 1. las claves y 3. el archivo .env, por lo que no puedo comprobar si el hook las detecta correctamente. No he podido comprobar si el agente sigue las reglas del proyecto en todos los casos posibles, ya que depende de su comportamiento y decisiones durante la ejecución de los comandos.
