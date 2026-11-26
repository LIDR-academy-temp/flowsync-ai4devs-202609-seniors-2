import Task from '#models/task'
import { test } from '@japa/runner'

/**
 * Cuándo una tarea está vencida, a nivel de unidad. Llama directamente a
 * `Task#isOverdueOn` y mira lo que devuelve: sin servidor, sin base de datos y
 * sin HTTP (los mismos escenarios, de punta a punta, están en
 * `tests/functional/tasks/overdue.spec.ts`).
 *
 * Los casos salen de los scenarios del requisito «Cuándo una tarea está vencida»
 * de `openspec/specs/tasks/spec.md`, más uno que no sale de la spec: que la fecha
 * llegue como texto o como `Date` no cambie la respuesta.
 *
 * El día de referencia entra siempre como parámetro y todas las fechas son
 * literales: ningún test lee el reloj del sistema.
 */
test.group('Tasks | vencimiento (unidad)', () => {
  const DIA_DE_REFERENCIA = '2026-08-13'

  /** Una tarea en memoria, sin guardar: solo lo que `isOverdueOn` necesita. */
  function tarea(dueDate: string | null, status: Task['status'] = 'pending'): Task {
    const task = new Task()
    task.dueDate = dueDate
    task.status = status

    return task
  }

  test('una tarea no hecha con fecha anterior al día de referencia está vencida', ({ assert }) => {
    assert.isTrue(tarea('2026-08-12').isOverdueOn(DIA_DE_REFERENCIA))
  })

  test('vencer exactamente el día de referencia todavía no es estar vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-13').isOverdueOn(DIA_DE_REFERENCIA))
  })

  test('una fecha posterior al día de referencia no está vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-14').isOverdueOn(DIA_DE_REFERENCIA))
  })

  test('sin fecha de vencimiento no se vence nunca', ({ assert }) => {
    assert.isFalse(tarea(null).isOverdueOn(DIA_DE_REFERENCIA))
  })

  test('una tarea hecha con la fecha pasada no está vencida', ({ assert }) => {
    assert.isFalse(tarea('2026-08-12', 'done').isOverdueOn(DIA_DE_REFERENCIA))
  })

  test('la fecha como texto y como Date dan la misma respuesta', ({ assert }) => {
    // No sale de ninguna exigencia de producto: sale de preguntarse cómo llega de
    // verdad el dato. El tipo dice `string`, así que el `Date` entra con un cast.
    const comoTexto = '2026-08-12'
    const comoDate = new Date('2026-08-12') as unknown as string

    const dias = ['2026-08-13', '2026-08-12', '2026-08-11'] // anterior, igual, posterior

    const conTexto = dias.map((dia) => tarea(comoTexto).isOverdueOn(dia))
    const conDate = dias.map((dia) => tarea(comoDate).isOverdueOn(dia))

    assert.deepEqual(conDate, conTexto)
  })
})
