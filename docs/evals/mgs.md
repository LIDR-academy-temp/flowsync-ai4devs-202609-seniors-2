## 🅰️ Parte A: la medición

### 1. Apuesta (escrita antes del primer intento)

De cinco intentos, creo que el README de la capability quedará al día en: **4 / 5**

### 2. Intentos

Antes de cada intento, `git status -sb` debe responder solo `## s8/start`.

| # | Arranque limpio (`## s8/start`) | Control: ¿ruta `DELETE` declarada? | Resultado: ¿`docs/capabilities/tasks/README.md` menciona el endpoint? | ¿Cuenta? | Notas |
|---|---|---|---|---|---|
| 1 | ☑ | ☑ sí ☐ no | ☑ sí ☐ no | ☑ sí ☐ no |  |
| 2 | ☑ | ☑ sí ☐ no | ☐ sí ☑ no | ☑ sí ☐ no | El modelo optó por resolver la tarea usando OpenSpec y omitió actualizar el README. |
| 3 | ☑ | ☑ sí ☐ no | ☑ sí ☐ no | ☑ sí ☐ no |  |
| 4 | ☑ | ☑ sí ☐ no | ☑ sí ☐ no | ☑ sí ☐ no |  |
| 5 | ☑ | ☑ sí ☐ no | ☑ sí ☐ no | ☑ sí ☐ no |  |

### 3. Resultado

- La predicción y resultado coincidieron: **4 de 5 veces aplicó la regla**

---

## 🅱️ Parte B: las tres líneas

1. **Apuesta y resultado:** Aposté 4/5 y salió 4/5. Acerté

2. **Qué haría con ese resultado:** mantener la regla pero agregarle algún tipo de comprobación automática (modificación del readme cuando hay modificación del API) + verificación humana (la revisión semántica dificilmente pueda automatizarse)

3. **Algo que mi medición no está midiendo:** Dentro del alcance de la tarea todo esta bien, en la práctica que la documentación coincida con la implementación requiere medición más profunda
