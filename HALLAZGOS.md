# Hallazgos

Las tres líneas del ejercicio, una por punto. (La plantilla que traía el repo era la del
ejercicio de esquema del módulo anterior; la sustituyo por las tres preguntas de este.)

## 1. Cuántos de tus casos nuevos fallaron y cuántos de los que ya había siguieron en verde

- 7 de mis 13 casos nuevos quedaron en rojo y 6 en verde, y los 40 tests que ya existían siguieron todos en verde: parte A (funcional, HTTP) 5 rojos / 2 verdes, suite entera 42 pasados y 5 fallidos de 47; parte B (unitaria) 2 rojos / 4 verdes, la suite unitaria pasó de `NO TESTS EXECUTED` con código 0 a 6 ejecutados con código 2.

## 2. Cuál de tus casos nuevos PASÓ, si alguno pasó, y por qué crees que pasó

- Los 6 verdes son verdes por accidente: todos los casos que pasaron esperaban `false` y todos los que fallaron esperaban `true`. En HTTP la regla devuelve `isOverdue: false` para cualquier caso porque node-pg entrega `due_date` como objeto Date y `Date < '2026-08-13'` es siempre false, así que un test que espera false pasa con la regla completamente rota; la parte B muestra el mismo patrón dentro de la función: falla el caso `done` (devuelve true porque `isOverdueOn` nunca mira el estado) y falla el caso Date (devuelve false siempre por la misma coerción), y pasan solo los tres que esperaban false o true con comparación de textos.

## 3. De qué dudaste

- Mi primera duda era si en producción `dueDate` llega alguna vez como texto, porque `database/schema_rules.ts` lo declara `string`; la levé con el método que el propio proyecto documenta (regla 1 de `docs/convenciones/base-de-datos.md`: el código dice cómo se llaman las columnas, no qué hay dentro, se mira la base real): la migración crea la columna como `date` de PostgreSQL y la base real lo confirma (`data_type = date`), así que node-pg la entrega como objeto Date también en producción y la declaración `tsType: 'string'` del esquema nunca se cumple en el fil. Quedan abiertas dos cosas: no ejecuté la suite completa tras añadir los unitarios, y el agente añadió dos precontroles fuera del Scenario literal en «Vencer hoy» y «hecha con fecha pasada», que acepté porque convierten un verde por accidente en un rojo que informa, pero son una desviación de la letra de la spec.
