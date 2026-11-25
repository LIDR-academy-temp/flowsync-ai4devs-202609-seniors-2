import Task from '#models/task'
import { test } from '@japa/runner'

/**
 * La regla «Cuándo una tarea está vencida» (`openspec/specs/tasks/spec.md`), bajada a
 * la unidad que la decide: `Task#isOverdueOn`. Sin servidor y sin base de datos: el
 * modelo se instancia en memoria, se le asignan las propiedades y no se guarda nunca.
 *
 * Vencida si, y solo si, se cumplen las tres a la vez: tiene fecha, esa fecha es
 * ANTERIOR al día de referencia y su estado no es `done`. Las expectativas salen de la
 * spec, no del código.
 *
 * El día de referencia es un parámetro con una fecha fija escrita aquí. Ningún test
 * mira el reloj.
 */
test.group('Task | isOverdueOn (regla de vencimiento)', () => {
  const HOY = '2026-08-20'
  const AYER = '2026-08-19'
  const MANANA = '2026-08-21'

  /** Tarea en memoria, nunca persistida. */
  function tarea(dueDate: string | null, status: 'pending' | 'in_progress' | 'done' = 'pending') {
    const task = new Task()
    task.title = 'Revisar el informe'
    task.status = status
    task.dueDate = dueDate
    return task
  }

  test('fecha anterior al día de referencia, sin hacer: vencida', ({ assert }) => {
    assert.isTrue(tarea(AYER).isOverdueOn(HOY))
  })

  test('fecha exactamente igual al día de referencia: no vencida', ({ assert }) => {
    assert.isFalse(tarea(HOY).isOverdueOn(HOY))
  })

  test('fecha posterior al día de referencia: no vencida', ({ assert }) => {
    assert.isFalse(tarea(MANANA).isOverdueOn(HOY))
  })

  test('sin fecha: no vencida', ({ assert }) => {
    assert.isFalse(tarea(null).isOverdueOn(HOY))
  })

  test('tarea hecha con la fecha pasada: no vencida', ({ assert }) => {
    assert.isFalse(tarea(AYER, 'done').isOverdueOn(HOY))
  })

  /**
   * No sale de la spec: sale de lo que de verdad le llega al modelo. La columna
   * `due_date` es `date` en PostgreSQL y no hay ningún type parser configurado, así que
   * el driver `pg` la entrega como un `Date` de JavaScript a medianoche local (no como
   * texto, aunque `schema.ts` la declare `string`, ni como `DateTime` de luxon, porque
   * la columna lleva `@column` y no `@column.date`). Se construye igual que lo hace el
   * driver: `new Date(año, mes - 1, día)`, una fecha fija, sin reloj.
   *
   * Para la misma fecha anterior al día de referencia, las dos formas tienen que dar el
   * mismo resultado: vencida.
   */
  test('misma fecha como texto AAAA-MM-DD o como Date: las dos vencidas', ({ assert }) => {
    const comoTexto = tarea(AYER)

    const comoFecha = tarea(null)
    comoFecha.dueDate = new Date(2026, 7, 19) as unknown as string

    assert.deepEqual(
      { texto: comoTexto.isOverdueOn(HOY), fecha: comoFecha.isOverdueOn(HOY) },
      { texto: true, fecha: true }
    )
  })
})
