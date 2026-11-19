# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Qué regla saltó en tu prueba, y la línea literal que dejó el registro.

- En la Parte C saltó la regla 2 (correo de un dominio no permitido): Claude Code intentó commitear el correo solicitado, el hook bloqueó el commit y el agente sustituyó después el dominio por example.com; primer bloqueo en el registro: `- 2026-11-19T20:24:46Z BLOQUEADO regla 2 (correo de un dominio no reservado) en docs/capabilities/tasks/README.md`

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

- La contraseña ficticia de la cuenta de pruebas pasó sin detectar: las tres reglas solo reconocen ciertas formas de clave, correos de dominios no permitidos y ficheros `.env`, así que una contraseña genérica sin esos patrones pasa inadvertida.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- El segundo bloqueo de la Parte C ocurrió porque Claude ejecutó `git add` y `git commit` en el mismo comando: el hook examinó el staging antes de que `git add` lo actualizara y aún detectó el correo anterior, lo que muestra una limitación importante al interpretar comandos compuestos.
