# Ejercicio 8

## Comprobaciones

| Prueba # | Control (generó la ruta?) | Resultado (actualizó el README?) |
| - | - | - |
| 1 | Sí | Sí |
| 2 | Sí | Sí (*) |
| 3 | Sí | Sí |
| 4 | Sí | Sí |
| 5 | Sí | Sí |

(*) Si bien no forzó la regeneración de .adonisjs (creyó que sí) como indica la regla en CLAUDE.md, el ejercicio solo pide comprobar que se actualizó el README.

## Las 3 líneas
- 5/5, 5/5
- A priori conservaría la regla como está. Convertirla en una comprobación automática podría ser un complemento, pero no es lo mismo. La regla indica qué hacer, la comprobación lo verifica. En este caso verificar el cumplimiento de la regla con un script parece posible pero no trivial, y la probabilidad de error no está clara. Reescribirla no parecería necesario ya que se cumplió prácticamente en todos los casos.
- Es obvio en función del contenido del módulo: no estamos chequeando cómo se comporta el modelo SIN la regla. Sin baseline no se puede determinar si la regla efectivamente aporta algo.