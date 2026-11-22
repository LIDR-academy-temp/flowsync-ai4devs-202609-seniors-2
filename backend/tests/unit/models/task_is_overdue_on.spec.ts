import Task from '#models/task'
import { test } from '@japa/runner'

/**
 * `Task.isOverdueOn(referenceDay)`: la única definición de «vencida» del sistema.
 *
 * Cubre los bordes del requisito «Cuándo una tarea está vencida» de
 * `openspec/specs/tasks/spec.md` contra el método, sin servidor y sin base de
 * datos: la tarea se construye en memoria y nunca se guarda.
 *
 * Y un caso que no sale de la spec: la regla tiene que decir lo mismo reciba la
 * fecha de vencimiento como texto `AAAA-MM-DD` o como objeto `Date`. El esquema
 * declara `dueDate` como `string | null`, pero quien la carga (el driver de la
 * base, una factory, un script) puede entregarla como `Date`, y el día del
 * calendario es el mismo en los dos casos.
 *
 * El día de referencia es siempre una constante: ninguna fecha sale del reloj.
 */
test.group('Task.isOverdueOn', () => {
  const HOY = '2026-08-20'
  const AYER = '2026-08-19'
  const MANANA = '2026-08-21'
  const HACE_UN_MES = '2026-07-20'

  type Estado = 'pending' | 'in_progress' | 'done'

  /** Una tarea en memoria, sin tocar la base. */
  function tarea(dueDate: string | Date | null, status: Estado = 'pending'): Task {
    const task = new Task()
    task.title = 'Revisar el informe'
    task.status = status
    // `as any` solo para poder entregarle un `Date` en el caso que no sale de la spec.
    task.dueDate = dueDate as any
    return task
  }

  /** El mismo día del calendario, como objeto `Date` (medianoche local de ese día). */
  function comoDate(dia: string): Date {
    const [anio, mes, d] = dia.split('-').map(Number)
    return new Date(anio, mes - 1, d)
  }

  test('fecha anterior al día de referencia y tarea sin hacer: vencida', ({ assert }) => {
    assert.isTrue(tarea(AYER, 'pending').isOverdueOn(HOY))
    assert.isTrue(tarea(AYER, 'in_progress').isOverdueOn(HOY))
  })

  test('fecha exactamente igual al día de referencia: todavía no vencida', ({ assert }) => {
    assert.isFalse(tarea(HOY, 'pending').isOverdueOn(HOY))
    assert.isFalse(tarea(HOY, 'in_progress').isOverdueOn(HOY))
  })

  test('fecha posterior al día de referencia: no vencida', ({ assert }) => {
    assert.isFalse(tarea(MANANA, 'pending').isOverdueOn(HOY))
    assert.isFalse(tarea(MANANA, 'in_progress').isOverdueOn(HOY))
  })

  test('sin fecha: no vencida, por lejano que sea el día de referencia', ({ assert }) => {
    assert.isFalse(tarea(null, 'pending').isOverdueOn(HOY))
    assert.isFalse(tarea(null, 'in_progress').isOverdueOn('2099-12-31'))
  })

  test('tarea hecha con la fecha pasada: no vencida', ({ assert }) => {
    assert.isFalse(tarea(AYER, 'done').isOverdueOn(HOY))
    assert.isFalse(tarea(HACE_UN_MES, 'done').isOverdueOn(HOY))
  })

  test('fuera de la spec: la fecha como texto o como Date da el mismo resultado', ({ assert }) => {
    const casos: Array<{ dia: string; status: Estado; esperado: boolean }> = [
      { dia: AYER, status: 'pending', esperado: true },
      { dia: AYER, status: 'in_progress', esperado: true },
      { dia: HOY, status: 'pending', esperado: false },
      { dia: MANANA, status: 'pending', esperado: false },
      { dia: AYER, status: 'done', esperado: false },
    ]

    for (const { dia, status, esperado } of casos) {
      const comoTexto = tarea(dia, status).isOverdueOn(HOY)
      const comoObjeto = tarea(comoDate(dia), status).isOverdueOn(HOY)

      assert.equal(comoTexto, esperado, `texto ${dia} (${status}) con referencia ${HOY}`)
      assert.equal(comoObjeto, esperado, `Date ${dia} (${status}) con referencia ${HOY}`)
    }
  })
})
