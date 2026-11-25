import Task, { type TaskStatus } from '#models/task'
import { test } from '@japa/runner'

/**
 * La regla de «vencida» en sí, `Task.isOverdueOn`, sin servidor ni base de datos:
 * se construye un `Task` en memoria, nunca se guarda, y se le pregunta.
 *
 * La regla (requisito «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`):
 * vencida si, y solo si, tiene fecha, esa fecha es ANTERIOR al día de referencia y su
 * estado no es `done`. Un test por cada borde, y uno más para la forma en que llega la
 * fecha.
 *
 * El día de referencia es fijo y se pasa al método: ningún test lee el reloj.
 */
test.group('Task.isOverdueOn', () => {
  const HOY = '2026-08-20'
  const AYER = '2026-08-19'
  const MANANA = '2026-08-21'

  /** Una tarea en memoria con el estado y la fecha pedidos. No toca la base. */
  function tarea(status: TaskStatus, dueDate: string | Date | null): Task {
    const task = new Task()
    task.status = status
    // El esquema generado tipa `dueDate` como texto, pero el driver de PostgreSQL la
    // entrega como `Date` al leerla: el cast permite probar las dos formas reales.
    task.dueDate = dueDate as string | null
    return task
  }

  /**
   * El mismo día como objeto de fecha, construido como lo hace el driver de
   * PostgreSQL con una columna `date`: medianoche en la hora local del proceso.
   */
  function comoDate(dia: string): Date {
    const [anio, mes, d] = dia.split('-').map(Number)
    return new Date(anio, mes - 1, d)
  }

  test('fecha anterior al día de referencia y sin hacer: vencida', ({ assert }) => {
    // «Sin hacer» son los dos estados que no son `done`.
    assert.isTrue(tarea('pending', AYER).isOverdueOn(HOY))
    assert.isTrue(tarea('in_progress', AYER).isOverdueOn(HOY))
  })

  test('fecha exactamente igual al día de referencia: no vencida', ({ assert }) => {
    // La regla exige ANTERIOR: vencer hoy todavía no es estar vencida.
    assert.isFalse(tarea('pending', HOY).isOverdueOn(HOY))
    assert.isFalse(tarea('in_progress', HOY).isOverdueOn(HOY))
  })

  test('fecha posterior al día de referencia: no vencida', ({ assert }) => {
    assert.isFalse(tarea('pending', MANANA).isOverdueOn(HOY))
    assert.isFalse(tarea('in_progress', MANANA).isOverdueOn(HOY))
  })

  test('sin fecha: no vencida, por lejano que sea el día de referencia', ({ assert }) => {
    assert.isFalse(tarea('pending', null).isOverdueOn(HOY))
    assert.isFalse(tarea('in_progress', null).isOverdueOn('2099-12-31'))
  })

  test('ya hecha con la fecha pasada: no vencida', ({ assert }) => {
    assert.isFalse(tarea('done', AYER).isOverdueOn(HOY))
    // Por pasada que esté.
    assert.isFalse(tarea('done', '2020-01-01').isOverdueOn(HOY))
  })

  test('la regla responde lo mismo con la fecha como texto que como objeto de fecha', ({
    assert,
  }) => {
    // Cada borde de arriba, con la respuesta que exige la regla. Se compara cada forma
    // contra lo esperado y no solo una contra la otra: si las dos se equivocaran igual,
    // compararlas entre sí no lo vería.
    const bordes: Array<{ caso: string; status: TaskStatus; dia: string; vencida: boolean }> = [
      { caso: 'anterior, pendiente', status: 'pending', dia: AYER, vencida: true },
      { caso: 'anterior, en curso', status: 'in_progress', dia: AYER, vencida: true },
      { caso: 'igual', status: 'pending', dia: HOY, vencida: false },
      { caso: 'posterior', status: 'pending', dia: MANANA, vencida: false },
      { caso: 'hecha con la fecha pasada', status: 'done', dia: AYER, vencida: false },
    ]

    for (const { caso, status, dia, vencida } of bordes) {
      const comoTexto = tarea(status, dia).isOverdueOn(HOY)
      const comoObjeto = tarea(status, comoDate(dia)).isOverdueOn(HOY)

      assert.strictEqual(comoTexto, vencida, `${caso}, con la fecha como texto`)
      assert.strictEqual(comoObjeto, vencida, `${caso}, con la fecha como objeto Date`)
    }
  })
})
