# Módulo 8 — Evaluación de la regla del README de `tasks`

## Parte A — Medición

**Regla evaluada:** un cambio en rutas/controladores/validadores/transformers de una capability debe actualizar su README en el mismo commit.

**Apuesta anotada antes de medir:** **3 de 5** intentos actualizarán el README.
**Base idéntica de cada intento:** `s8/start` (`49eecdcb3c70b0b2fa6fa6cbaee29425dd30ba1d`), restaurada mediante checkout, reset, clean y copia de la base SQLite cuando existía.
**Modelo y herramienta:** Claude Code CLI, `--model sonnet`, una invocación nueva `claude -p` por intento y sin reanudar sesiones.

**Prompt exacto** (idéntico en todos los intentos):

> Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`.

**Control:** la ruta `router.delete(':id', ...)` está declarada en el grupo `tasks` de `backend/start/routes.ts`. **Resultado:** el README menciona `DELETE /tasks/:id` o `DELETE /api/v1/tasks/:id`. La tasa usa solo intentos con control positivo y sesión sin error.

| Intento | Reinicio limpio | Control: ruta DELETE | README menciona endpoint | Válido |
|---|---|---|---|---|
| 1 | Sí | Sí | Sí | Sí |
| 2 | Sí | Sí | Sí | Sí |
| 3 | Sí | Sí | Sí | Sí |
| 4 | Sí | Sí | Sí | Sí |
| 5 | Sí | Sí | Sí | Sí |

**Resultado:** 5 de 5 intentos válidos. Se iniciaron 5 de los 5 intentos solicitados; los intentos sin ruta o con error de ejecución no entran en el denominador.

## Parte B — tres líneas

1. **Apuesta y resultado:** aposté **3 de 5** y observé **5 de 5 intentos válidos** tras iniciar 5/5 ejecuciones.
2. **Qué haría:** convertiría el requisito en un control de CI que detecte cambios de endpoints y exija actualizar la documentación; un recordatorio en `CLAUDE.md` puede mejorar la probabilidad, pero por sí solo no la garantiza.
3. **Qué no mide:** esta comprobación no confirma que el DELETE borre realmente, respete autenticación ni responda exactamente `204` sin cuerpo, y tampoco valida que OpenAPI esté actualizado.

**Trazabilidad:** resultados detallados, salidas JSON de Claude y diffs están guardados en la carpeta local `evidencia/`, fuera de la entrega del PR.
