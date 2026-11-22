import Task from '#models/task'
import { test } from '@japa/runner'

/**
 * `Task#isOverdueOn` aislado: sin servidor, sin base de datos y sin guardar el
 * modelo. La tarea se construye en memoria y se le asignan solo los dos campos
 * que la regla mira. El día de referencia es una constante: ningún reloj.
 */
test.group('Task#isOverdueOn', () => {
  const HOY = '2026-08-20'

  /** Una tarea en memoria. `dueDate` entra como lo entrega cada caso, sin tipar. */
  function tarea(dueDate: unknown, status: 'pending' | 'in_progress' | 'done' = 'pending') {
    const task = new Task()
    task.dueDate = dueDate as never
    task.status = status
    return task
  }

  test('fecha anterior al día de referencia y tarea pending: vencida', ({ assert }) => {
    assert.isTrue(tarea('2026-08-19').isOverdueOn(HOY))
  })

  test('fecha igual al día de referencia: no vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-20').isOverdueOn(HOY))
  })

  test('fecha posterior al día de referencia: no vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-21').isOverdueOn(HOY))
  })

  test('sin fecha: no vencida', ({ assert }) => {
    assert.isFalse(tarea(null).isOverdueOn(HOY))
  })

  test('tarea done con fecha pasada: no vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-19', 'done').isOverdueOn(HOY))
  })

  test('responde lo mismo si dueDate llega como texto o como Date', ({ assert }) => {
    // El driver pg entrega una columna `date` como `Date` a medianoche LOCAL.
    const comoTexto = tarea('2026-08-19').isOverdueOn(HOY)
    const comoDate = tarea(new Date(2026, 7, 19)).isOverdueOn(HOY)

    assert.equal(comoDate, comoTexto)
    assert.isTrue(comoDate)
  })
})
