import { test } from '@japa/runner'
import testUtils from '@adonisjs/core/services/test_utils'

/**
 * Cuándo una tarea está vencida. Un test por cada uno de los siete scenarios
 * del requisito «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`.
 *
 * Todo entra por HTTP, como lo haría el frontend: la cuenta se registra con
 * `POST /auth/signup`, la tarea se crea con `POST /tasks` (y su id sale de esa
 * respuesta), la fecha se fija con `PUT /tasks/:id/due-date` y el estado con
 * `PATCH /tasks/:id/status`. Lo que se comprueba es el campo `isOverdue` del
 * cuerpo de la respuesta.
 *
 * Según el contrato (`docs/capabilities/tasks/README.md`), solo la tarea suelta
 * lleva `isOverdue`: la devuelven `GET /tasks/:id?today=...` y
 * `PUT /tasks/:id/due-date` (con `today` en el cuerpo). `POST /tasks` y
 * `PATCH .../status` devuelven la tarea de lista, sin vencimiento, así que
 * después de cambiar el estado se vuelve a consultar la tarea suelta.
 *
 * El día de referencia se le pasa siempre a la petición: ninguna fecha de este
 * fichero sale del reloj.
 */
test.group('Tasks | cuándo una tarea está vencida', (group) => {
  group.each.setup(() => testUtils.db().withGlobalTransaction())

  // El día de quien mira, y sus vecinos.
  const HOY = '2026-08-20'
  const AYER = '2026-08-19'
  const MANANA = '2026-08-21'
  const HACE_UN_MES = '2026-07-20'

  const con = (token: string) => ({ Authorization: `Bearer ${token}` })

  /** Registra una cuenta por la API y devuelve su token. */
  async function entrar(client: any) {
    const response = await client.post('/api/v1/auth/signup').json({
      fullName: 'Ada Lovelace',
      email: 'ada@example.com',
      password: 'secreto123',
      passwordConfirmation: 'secreto123',
    })
    response.assertStatus(200)

    return response.body().data.token as string
  }

  /** Crea una tarea por la API y devuelve lo que contesta la creación. */
  async function crear(client: any, token: string) {
    const response = await client
      .post('/api/v1/tasks')
      .headers(con(token))
      .json({ title: 'Revisar el informe' })
    response.assertStatus(201)

    return response.body().data as { id: number; status: string; createdAt: string }
  }

  /** `PUT /tasks/:id/due-date`: devuelve la tarea suelta, ya con la fecha nueva. */
  async function fijarFecha(
    client: any,
    token: string,
    id: number,
    dueDate: string | null,
    today: string
  ) {
    const response = await client
      .put(`/api/v1/tasks/${id}/due-date`)
      .headers(con(token))
      .json({ dueDate, today })
    response.assertStatus(200)

    return response.body().data
  }

  /** `PATCH /tasks/:id/status`. */
  async function cambiarEstado(client: any, token: string, id: number, status: string) {
    const response = await client
      .patch(`/api/v1/tasks/${id}/status`)
      .headers(con(token))
      .json({ status })
    response.assertStatus(200)

    return response.body().data
  }

  /** `GET /tasks/:id?today=...`: la tarea suelta, vista desde ese día. */
  async function consultar(client: any, token: string, id: number, today: string) {
    const response = await client
      .get(`/api/v1/tasks/${id}`)
      .qs({ today })
      .headers(con(token))
    response.assertStatus(200)

    return response.body().data
  }

  /** Suma días a un `AAAA-MM-DD` en UTC, sin mirar el reloj. */
  function sumarDias(dia: string, dias: number) {
    const fecha = new Date(`${dia}T00:00:00Z`)
    fecha.setUTCDate(fecha.getUTCDate() + dias)
    return fecha.toISOString().slice(0, 10)
  }

  test('Fecha del día anterior: una tarea no hecha llega vencida', async ({ client, assert }) => {
    const token = await entrar(client)
    const { id } = await crear(client, token)
    await fijarFecha(client, token, id, AYER, HOY)

    const tarea = await consultar(client, token, id, HOY)

    assert.equal(tarea.id, id)
    assert.notEqual(tarea.status, 'done')
    assert.isTrue(tarea.isOverdue)
    assert.equal(tarea.dueDate, AYER)
  })

  test('Vencer hoy todavía no es estar vencida', async ({ client, assert }) => {
    const token = await entrar(client)
    const { id } = await crear(client, token)
    await fijarFecha(client, token, id, HOY, HOY)

    const tarea = await consultar(client, token, id, HOY)

    assert.notEqual(tarea.status, 'done')
    assert.isFalse(tarea.isOverdue)
    assert.equal(tarea.dueDate, HOY)
  })

  test('Fecha futura: no llega vencida', async ({ client, assert }) => {
    const token = await entrar(client)
    const { id } = await crear(client, token)
    await fijarFecha(client, token, id, MANANA, HOY)

    const tarea = await consultar(client, token, id, HOY)

    // Pendiente a propósito: así lo único que la salva de vencer es la fecha.
    assert.notEqual(tarea.status, 'done')
    assert.isFalse(tarea.isOverdue)
    assert.equal(tarea.dueDate, MANANA)
  })

  test('Sin fecha no se vence nunca, por antigua que sea', async ({ client, assert }) => {
    const token = await entrar(client)
    const creada = await crear(client, token)

    // «Creada hace semanas» respecto del día de referencia: se mira la tarea
    // seis semanas después del día en que la creación dice que nació.
    const diaDeCreacion = creada.createdAt.slice(0, 10)
    const seisSemanasDespues = sumarDias(diaDeCreacion, 42)

    const tarea = await consultar(client, token, creada.id, seisSemanasDespues)

    assert.equal(tarea.status, 'pending')
    assert.isNull(tarea.dueDate)
    assert.isFalse(tarea.isOverdue)
  })

  test('Darla por hecha la deja de vencer, con la misma fecha', async ({ client, assert }) => {
    const token = await entrar(client)
    const { id } = await crear(client, token)
    await fijarFecha(client, token, id, AYER, HOY)

    // Punto de partida: la tarea está vencida.
    const antes = await consultar(client, token, id, HOY)
    assert.isTrue(antes.isOverdue)

    const hecha = await cambiarEstado(client, token, id, 'done')
    assert.equal(hecha.status, 'done')

    const despues = await consultar(client, token, id, HOY)

    assert.equal(despues.status, 'done')
    assert.isFalse(despues.isOverdue)
    assert.equal(despues.dueDate, antes.dueDate)
    assert.equal(despues.dueDate, AYER)
  })

  test('Una tarea hecha con la fecha pasada no llega vencida', async ({ client, assert }) => {
    const token = await entrar(client)
    const { id } = await crear(client, token)
    await cambiarEstado(client, token, id, 'done')
    await fijarFecha(client, token, id, HACE_UN_MES, HOY)

    const tarea = await consultar(client, token, id, HOY)

    assert.equal(tarea.status, 'done')
    assert.isFalse(tarea.isOverdue)
    assert.equal(tarea.dueDate, HACE_UN_MES)
  })

  test('Aplazar resuelve el vencimiento en la misma respuesta del cambio', async ({
    client,
    assert,
  }) => {
    const token = await entrar(client)
    const { id } = await crear(client, token)

    // Punto de partida: la tarea está vencida.
    const vencida = await fijarFecha(client, token, id, AYER, HOY)
    assert.isTrue(vencida.isOverdue)

    // Lo que se comprueba es la respuesta del propio PUT, no una consulta posterior.
    const aplazada = await fijarFecha(client, token, id, MANANA, HOY)

    assert.equal(aplazada.id, id)
    assert.notEqual(aplazada.status, 'done')
    assert.equal(aplazada.dueDate, MANANA)
    assert.isFalse(aplazada.isOverdue)
  })
})
