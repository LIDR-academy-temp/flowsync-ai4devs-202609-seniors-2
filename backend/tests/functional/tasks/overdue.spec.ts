import { test } from '@japa/runner'
import testUtils from '@adonisjs/core/services/test_utils'
import { DateTime } from 'luxon'

/**
 * Cuándo una tarea está vencida. Un test por cada scenario del requisito
 * «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`: vencida si,
 * y solo si, tiene fecha, esa fecha es ANTERIOR al día de referencia y su estado
 * no es `done`.
 *
 * Todo se hace por HTTP, como lo haría un cliente: la cuenta se registra, la tarea
 * se crea, se le pone la fecha y se le cambia el estado por la API, y lo que se
 * comprueba es el `isOverdue` que viaja en el cuerpo de la respuesta. Ningún test
 * llama a un método del modelo ni escribe en la base por su cuenta.
 *
 * El día de referencia va siempre en la petición (`today`). Ningún test lee el
 * reloj: la única fecha que no se fija aquí es la de creación, y esa se toma de la
 * propia respuesta del servidor.
 *
 * El aislamiento es el de las demás suites de `tests/functional/`: una transacción
 * global por test, que se deshace al terminar y se lleva todo lo creado.
 */
test.group('Tasks | vencimiento', (group) => {
  group.each.setup(() => testUtils.db().withGlobalTransaction())

  // El día desde el que se mira, y sus vecinos. Fijos: la frontera entre «vencida»
  // y «no vencida» es exactamente un día, y es lo que estos tests comprueban.
  const HOY = '2026-08-20'
  const AYER = '2026-08-19'
  const MANANA = '2026-08-21'

  // Los dos estados que no son «hecha»: «no hecha» son los dos, no solo `pending`.
  const NO_HECHAS = ['pending', 'in_progress'] as const

  const con = (token: string) => ({ Authorization: `Bearer ${token}` })

  /** Registra una cuenta por la API y devuelve el token que da el propio registro. */
  async function cuenta(client: any) {
    const response = await client.post('/api/v1/auth/signup').json({
      fullName: 'Ada Lovelace',
      email: 'ada@example.com',
      password: 'secreto123',
      passwordConfirmation: 'secreto123',
    })
    response.assertStatus(200)

    return response.body().data.token as string
  }

  /** Crea una tarea por la API y devuelve lo que contestó la creación (con su `id`). */
  async function crearTarea(client: any, token: string, title = 'Revisar el informe') {
    const response = await client.post('/api/v1/tasks').headers(con(token)).json({ title })
    response.assertStatus(201)

    return response.body().data as { id: number; createdAt: string; status: string }
  }

  /** Pone la fecha de vencimiento y devuelve la tarea tal y como la devuelve el cambio. */
  async function fijarFecha(
    client: any,
    token: string,
    id: number,
    dueDate: string,
    today: string
  ) {
    const response = await client
      .put(`/api/v1/tasks/${id}/due-date`)
      .headers(con(token))
      .json({ dueDate, today })
    response.assertStatus(200)

    return response.body().data
  }

  async function cambiarEstado(client: any, token: string, id: number, status: string) {
    const response = await client
      .patch(`/api/v1/tasks/${id}/status`)
      .headers(con(token))
      .json({ status })
    response.assertStatus(200)
  }

  /** La tarea suelta vista desde `today`: la lectura que informa del vencimiento. */
  async function consultar(client: any, assert: any, token: string, id: number, today: string) {
    const response = await client.get(`/api/v1/tasks/${id}`).qs({ today }).headers(con(token))
    response.assertStatus(200)

    const tarea = response.body().data
    // Que es la que se pidió y que la condición viaja como dato propio de la tarea.
    // Después, `isTrue`/`isFalse` son estrictos: un `null` o un `1` no pasarían.
    assert.equal(tarea.id, id)
    assert.property(tarea, 'isOverdue')

    return tarea
  }

  /**
   * El día de calendario de un `dueDate` tal y como llega. Aquí no se prueba el
   * formato de la fecha —eso es otro requisito, «La fecha es un día, no un
   * instante»—, sino que la tarea tiene el día que se le puso. Leerlo así evita que
   * un fallo de formato tape el resultado de `isOverdue`, que es lo que se prueba.
   */
  const dia = (valor: string) => DateTime.fromISO(valor, { zone: 'utc' }).toFormat('yyyy-MM-dd')

  /**
   * Una tarea no hecha, en el estado pedido y con la fecha pedida. Devuelve su `id`
   * y lo que contestó el cambio de fecha, que también informa del vencimiento.
   */
  async function tareaNoHecha(
    client: any,
    token: string,
    status: (typeof NO_HECHAS)[number],
    dueDate: string
  ) {
    const { id } = await crearTarea(client, token, `Tarea ${status}`)
    if (status !== 'pending') await cambiarEstado(client, token, id, status)
    const alFijar = await fijarFecha(client, token, id, dueDate, HOY)

    return { id, alFijar }
  }

  /*
   * Dos respuestas informan del vencimiento: la tarea suelta (`GET /tasks/:id`) y
   * el cambio de fecha (`PUT /tasks/:id/due-date`). Cada scenario mira las dos
   * cuando ambas aparecen, porque son caminos distintos y comprobar solo uno
   * dejaría el otro sin red.
   */

  test('fecha del día anterior: la tarea llega marcada como vencida', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)

    for (const status of NO_HECHAS) {
      const { id, alFijar } = await tareaNoHecha(client, token, status, AYER)
      const suelta = await consultar(client, assert, token, id, HOY)

      for (const tarea of [alFijar, suelta]) {
        assert.equal(tarea.status, status)
        assert.equal(dia(tarea.dueDate), AYER)
        assert.isTrue(tarea.isOverdue, `una tarea ${status} con fecha de ayer está vencida`)
      }
    }
  })

  test('vencer hoy todavía no es estar vencida', async ({ client, assert }) => {
    const token = await cuenta(client)

    for (const status of NO_HECHAS) {
      const { id, alFijar } = await tareaNoHecha(client, token, status, HOY)
      const suelta = await consultar(client, assert, token, id, HOY)

      for (const tarea of [alFijar, suelta]) {
        assert.equal(tarea.status, status)
        assert.equal(dia(tarea.dueDate), HOY)
        // La regla exige que la fecha sea ANTERIOR: igual al día de referencia no basta.
        assert.isFalse(tarea.isOverdue, `una tarea ${status} que vence hoy no está vencida`)
      }
    }
  })

  test('fecha futura: la tarea no llega marcada como vencida', async ({ client, assert }) => {
    const token = await cuenta(client)
    const { id } = await crearTarea(client, token)

    const alFijar = await fijarFecha(client, token, id, MANANA, HOY)
    const suelta = await consultar(client, assert, token, id, HOY)

    for (const tarea of [alFijar, suelta]) {
      assert.equal(dia(tarea.dueDate), MANANA)
      assert.isFalse(tarea.isOverdue)
    }
  })

  test('sin fecha no se vence nunca, por antigua que sea la tarea', async ({ client, assert }) => {
    const token = await cuenta(client)
    const creada = await crearTarea(client, token)

    // «Creada hace semanas» se construye desde el día de referencia y no tocando la
    // fecha de creación: se mira la tarea seis semanas después del día que el propio
    // servidor dice que se creó. Ese día sale de la respuesta, no de un reloj.
    const creadaEl = DateTime.fromISO(creada.createdAt)
    assert.isTrue(creadaEl.isValid, `createdAt no es una fecha: ${creada.createdAt}`)
    const seisSemanasDespues = creadaEl.plus({ weeks: 6 }).toFormat('yyyy-MM-dd')

    const tarea = await consultar(client, assert, token, creada.id, seisSemanasDespues)

    assert.equal(tarea.status, 'pending')
    assert.isNull(tarea.dueDate)
    assert.isFalse(tarea.isOverdue)
  })

  test('darla por hecha la deja de vencer y no le cambia la fecha', async ({ client, assert }) => {
    const token = await cuenta(client)
    const { id } = await crearTarea(client, token)
    const alFijar = await fijarFecha(client, token, id, AYER, HOY)

    // El punto de partida del scenario: una tarea vencida.
    const antes = await consultar(client, assert, token, id, HOY)
    assert.isTrue(alFijar.isOverdue)
    assert.isTrue(antes.isOverdue)

    // El cambio de estado responde con la forma de lista, que no informa del
    // vencimiento: lo que pasa después se lee en la tarea suelta.
    await cambiarEstado(client, token, id, 'done')
    const despues = await consultar(client, assert, token, id, HOY)

    assert.equal(despues.status, 'done')
    assert.isFalse(despues.isOverdue, 'una tarea hecha no está vencida')
    // Deja de vencer por estar hecha, no porque se le haya quitado o movido la fecha.
    // Se compara contra la lectura de antes, por el mismo camino.
    assert.equal(despues.dueDate, antes.dueDate)
    assert.equal(dia(despues.dueDate), AYER)
  })

  test('una tarea hecha con la fecha pasada no llega marcada como vencida', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)
    const { id } = await crearTarea(client, token)
    // Primero se termina y después se le pone una fecha ya pasada: así el scenario no
    // depende de que funcione el anterior.
    await cambiarEstado(client, token, id, 'done')
    const alFijar = await fijarFecha(client, token, id, AYER, HOY)
    const suelta = await consultar(client, assert, token, id, HOY)

    for (const tarea of [alFijar, suelta]) {
      assert.equal(tarea.status, 'done')
      assert.equal(dia(tarea.dueDate), AYER)
      assert.isFalse(tarea.isOverdue, 'una tarea hecha no está vencida')
    }
  })

  test('aplazar resuelve el vencimiento en la misma respuesta del cambio', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)
    const { id } = await crearTarea(client, token)

    // El punto de partida del scenario: una tarea vencida, dicho por la propia API.
    const vencida = await fijarFecha(client, token, id, AYER, HOY)
    assert.equal(vencida.id, id)
    assert.isTrue(vencida.isOverdue)

    const aplazada = await fijarFecha(client, token, id, MANANA, HOY)

    // En la respuesta del PUT, sin necesidad de volver a consultar.
    assert.equal(aplazada.id, id)
    assert.equal(dia(aplazada.dueDate), MANANA)
    assert.isFalse(aplazada.isOverdue)
  })
})
