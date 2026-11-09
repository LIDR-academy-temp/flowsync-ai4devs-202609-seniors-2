# Hallazgos

Aquí van **las tres líneas** del ejercicio, una por cada punto de abajo. Es lo único que hay que
traer hecho: una parte del hook a medias con estas tres líneas escritas vale más que lo contrario,
porque lo que se discute en el directo es dónde te chocaste.

Escribe **una sola línea por punto**, con tus palabras, y **sin el dato dentro**: si tu línea
repite el correo o el secreto, eso es otra copia del dato (y también es un hallazgo, de los buenos).

## 1. La regla que saltó

Saltó la regla 2 (correo fuera de dominios permitidos) en la Parte C; el agente reintentó con un correo de example.com. Línea del registro: - 2026-11-10T09:42:17Z BLOQUEADO regla=2-correo-no-permitido archivo=docs/capabilities/tasks/README.md

-

## 2. Lo que el hook no puede cazar

La contraseña en claro de la cuenta de pruebas del README de tasks pasa sin bloqueo: ninguna de las tres reglas busca contraseñas genéricas, solo prefijos de clave conocidos, y lo mismo ocurre con un nombre completo como valor de fullName.
• Tokens de acceso y emails reales en backend/tmp/db.sqlite3: la BD está ignorada por Git y nunca pasa por un diff, así que el hook no la ve; pero el agente sí puede leerla y enviarla al modelo.
• Una clave sin prefijo reconocible (p. ej. una variable *_API_KEY= de otro proveedor) o la contraseña dentro de una URL de conexión: no coincide con la regla 1.
• El mensaje del commit (-m "...") no se revisa: solo el diff.
• Commits hechos por ti en tu terminal: el hook PreToolUse solo intercepta las llamadas Bash del agente.
-

## 3. Tu duda

No comprobé git commit -am (sin git add): el hook no mira los cambios sin preparar en ese caso, y el dato ya había salido hacia el modelo en el propio prompt antes de que el hook actuara.

-
