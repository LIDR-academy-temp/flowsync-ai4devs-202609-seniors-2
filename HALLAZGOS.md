# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Qué regla saltó en tu prueba, y la línea literal que dejó el registro.

- Regla 2 (correo con dominio real); registro: `- 2026-11-19T12:55:14Z BLOQUEADO · regla 2 (correo con dominio real) · archivo: docs/capabilities/tasks/README.md`

## 2. Lo que el hook no puede cazar

Un dato personal o un secreto de este proyecto que el hook NO puede cazar, y por qué.

- `APP_KEY` / secretos ya en `backend/.env` (gitignored): el hook solo mira el diff del commit, no el disco ignorado ni pegar el valor en un chat.

## 3. Tu duda

De qué dudaste, o qué no pudiste comprobar.

- Si el hook se carga a mitad de sesión en Windows/UNC sin reiniciar Claude (`/hooks`); al principio falló con exit 127 por la ruta `${CLAUDE_PROJECT_DIR//\\//}`.
