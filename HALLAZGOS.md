# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Qué regla saltó en tu prueba, y la línea literal que dejó el registro.

--

La regla 2 (correo con dominio no permitido) saltó en docs/capabilities/tasks/README.md
durante la prueba de la parte C: el hook salió con código 2, el commit no se ejecutó y dejó
en el registro `2026-11-12T14:33:59Z BLOQUEADO regla 2 (correo con dominio no permitido) en
docs/capabilities/tasks/README.md`.

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

--

- `APP_KEY` es capturado por la regla 1, pero una variable del mismo tipo con un nombre diferente no lo
  es. El hook solo reconoce formas de claves, no nombres de variables: `JWT_SECRET=...` o
  `DB_PASSWORD=...` pasan sin activar nada.
- El `.gitignore` del proyecto ignora `.env` y `.env.local`, pero la regla 3 coincide solo con el nombre
  exacto `.env`. Un `.env.local` añadido con `git add -f` atraviesa el hook si su contenido no tiene una
  clave en el formato reconocido. Los secretos existen, pero bajo un nombre de archivo que la regla no
  prevé.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

--

El hook solo lee los diffs y los nombres de archivos. No ve el mensaje del commit
(`git commit -m "...ana.perez@gmail.com..."` pasa) ni una orden git commit lanzada desde un
script intermedio.
