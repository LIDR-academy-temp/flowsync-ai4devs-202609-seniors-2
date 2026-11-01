# Eval: README de la capability tasks — ipsv

Regla: CLAUDE.md, Reglas de proceso, 3.ª viñeta (solo la parte del README).
Encargo: "Añade a la capability tasks el endpoint DELETE /api/v1/tasks/:id, que borra una
tarea y devuelve 204 sin cuerpo. Impleméntalo en el controlador que ya existe y declara
su ruta junto a las demás de tasks." (texto exacto en prompts.md)
Punto de partida: s8/start @ 49eecdc, limpio en cada intento (git status -sb).
Modelo / herramienta: Sonnet 5.5 / Claude Code <versión>.
Permisos: ediciones, rama local y commit permitidos; git push y gh pr create denegados.
Grader: script bash. Control = router.delete(':id') en backend/start/routes.ts.
Resultado = "DELETE ... /tasks/:id" en docs/capabilities/tasks/README.md.
Validado: NO/NO en el estado limpio y SI/SI con ruta y fila añadidas a mano.

## Predicción (escrita antes del intento 1)

Predicción (2026-11-01 19:05): el README de tasks quedará al día en 4 de 5 intentos.
Por qué: la regla es explícita y nombra la ruta exacta del README, pero va mezclada con otras dos obligaciones.
Predicción del control: declarará la ruta en 5 de 5.

## Parte A: intentos

| Intento | Modelo | Control: ruta DELETE | Resultado: README menciona el endpoint | README en el mismo commit | ¿Cuenta? | Observaciones |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Sonnet 5.5 | Sí | Sí | Sí | Sí | |
| 2 | Sonnet 5.5 | — | — | — | No (contaminado) | Encontró feat/delete-task del intento 1 y continuó sobre ella. Interrumpido. |
| 3 | Sonnet 5.5 | Sí | Sí | Sí | Sí | |
| 4 | Sonnet 5.5 | Sí | Sí | Sí | Sí | |
| 5 | Sonnet 5.5 | Sí | Sí | — | Sí | Sin commit: cambios en disco, ningún commit tocó las rutas |
| 6 (repite el 2) | Sonnet 5.5 | Sí | Sí | Sí | Sí | Tras borrar las ramas feat/ antes de empezar |

Ejecuciones: 6. Válidas: 5 (la 2 se descarta por partir de un estado distinto).
Control: 5 / 5.
Tasa (resultado, lo que pide el enunciado): 5 / 5 = 100 %.
Tasa (regla literal, README en el mismo commit que la ruta): 4 / 5 = 80 %; el intento 5 no hizo commit.

## Parte B

1. Predije 4 de 5 y salió 5 de 5 en los intentos válidos (6 ejecuciones, una descartada por
   contaminación); si exijo lo que dice la regla literal, el README en el mismo commit que la
   ruta, baja a 4 de 5 porque en el intento 5 el agente no hizo commit.
2. La reescribiría, no la borraría ni la automatizaría todavía: el 5/5 muestra que el agente
   actualiza el README con la regla presente, pero sin línea base no sé si se debe a ella, así
   que borrarla no está justificado; y está desfasada y mezcla tres obligaciones, porque dice
   que no hay fichero OpenAPI que generar cuando docs/api/openapi.json existe y ya lo comprueba
   CI, de modo que la separaría en una regla solo para el README, que es lo que no vigila
   ninguna comprobación automática.
3. No tengo línea base: no medí qué hace el agente sin la regla, así que el 100 % no demuestra
   que la regla aporte nada; además, el grader solo comprueba que el endpoint aparezca en el
   README, no que su fila sea correcta, y descubrí que el estado inicial no es solo el árbol
   de trabajo: las ramas feat/ que quedan de un intento anterior cambian el comportamiento
   del agente, aunque el enunciado diga que no interfieren.