import Task from '#models/task'
import { test } from '@japa/runner'

/**
 * Bordes de la regla «Cuándo una tarea está vencida» (`openspec/specs/tasks/spec.md`),
 * sobre `Task.isOverdueOn`, sin servidor y sin base de datos: la tarea se construye en
 * memoria. Vencida si, y solo si, hay fecha, es ANTERIOR al día de referencia y la tarea
 * no está hecha.
 */
function tarea(dueDate: unknown, status: 'pending' | 'in_progress' | 'done' = 'pending') {
  const task = new Task()
  task.title = 'Tarea'
  task.status = status
  // El tipo declarado es `string | null`; el último test lo fuerza a `Date` a propósito.
  task.dueDate = dueDate as string | null
  return task
}

test.group('Task.isOverdueOn | bordes', () => {
  test('fecha anterior al día de referencia y sin hacer: vencida', ({ assert }) => {
    assert.isTrue(tarea('2026-08-12').isOverdueOn('2026-08-13'))
    assert.isTrue(tarea('2026-08-12', 'in_progress').isOverdueOn('2026-08-13'))
  })

  test('fecha igual al día de referencia: no vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-13').isOverdueOn('2026-08-13'))
  })

  test('fecha posterior: no vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-14').isOverdueOn('2026-08-13'))
  })

  test('sin fecha: nunca vencida', ({ assert }) => {
    assert.isFalse(tarea(null).isOverdueOn('2099-12-31'))
  })

  test('tarea hecha con la fecha pasada: no vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-01', 'done').isOverdueOn('2026-08-13'))
  })

  test('da igual que la fecha llegue como texto o como objeto de fecha', ({ assert }) => {
    // El driver de Postgres entrega las columnas `date` como `Date` (medianoche UTC),
    // no como texto: es como llega el dato de verdad tras leer la tarea de la base.
    const comoTexto = (dia: string, hoy: string) => tarea(dia).isOverdueOn(hoy)
    const comoFecha = (dia: string, hoy: string) =>
      tarea(new Date(`${dia}T00:00:00.000Z`)).isOverdueOn(hoy)

    for (const [dia, hoy] of [
      ['2026-08-12', '2026-08-13'],
      ['2026-08-13', '2026-08-13'],
      ['2026-08-14', '2026-08-13'],
    ]) {
      assert.equal(comoFecha(dia, hoy), comoTexto(dia, hoy), `${dia} frente a ${hoy}`)
    }
  })
})
