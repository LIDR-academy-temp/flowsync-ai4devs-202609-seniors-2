import User from '#models/user'
import { test } from '@japa/runner'
import testUtils from '@adonisjs/core/services/test_utils'

/**
 * Cuándo una tarea está vencida. Un test por cada uno de los siete scenarios del
 * requisito «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`.
 *
 * Todo entra por HTTP, como entra el cliente: se abre sesión, se crea la tarea, se le
 * fija la fecha con `PUT /api/v1/tasks/:id/due-date`, se cambia el estado si el
 * scenario lo pide y se consulta con `GET /api/v1/tasks/:id`. Lo que se comprueba es
 * el campo `isOverdue` del cuerpo de la respuesta.
 *
 * El día de referencia lo pone quien mira (requisito «El día de referencia lo pone
 * quien mira»): va en el parámetro `today`, siempre con fechas fijas escritas aquí.
 * Ningún test mira el reloj.
 */
test.group('Tasks | vencimiento', (group) => {
  group.each.setup(() => testUtils.db().withGlobalTransaction())

  const HOY = '2026-08-20'
  const AYER = '2026-08-19'
  const MANANA = '2026-08-21'

  const con = (token: string) => ({ Authorization: `Bearer ${token}` })

  async function sesion(client: any) {
    await User.create({
      fullName: 'Ada Lovelace',
      email: 'ada@example.com',
      password: 'secreto123',
    })
    const login = await client
      .post('/api/v1/auth/login')
      .json({ email: 'ada@example.com', password: 'secreto123' })
    login.assertStatus(200)

    return login.body().data.token as string
  }

  /** Crea una tarea por la API y devuelve el id que da la propia creación. */
  async function crearTarea(client: any, token: string) {
    const creada = await client
      .post('/api/v1/tasks')
      .headers(con(token))
      .json({ title: 'Revisar el informe' })
    creada.assertStatus(201)

    return creada.body().data.id as number
  }

  function fijarFecha(client: any, token: string, id: number, dueDate: string | null, today: string) {
    return client
      .put(`/api/v1/tasks/${id}/due-date`)
      .qs({ today })
      .headers(con(token))
      .json({ dueDate })
  }

  async function cambiarEstado(client: any, token: string, id: number, status: string) {
    const response = await client
      .patch(`/api/v1/tasks/${id}/status`)
      .headers(con(token))
      .json({ status })
    response.assertStatus(200)
  }

  async function consultar(client: any, token: string, id: number, today: string) {
    const response = await client.get(`/api/v1/tasks/${id}`).qs({ today }).headers(con(token))
    response.assertStatus(200)

    return response.body().data
  }

  /** Tarea no hecha con la fecha indicada, lista para consultar. */
  async function tareaConFecha(client: any, dueDate: string) {
    const token = await sesion(client)
    const id = await crearTarea(client, token)
    const fijada = await fijarFecha(client, token, id, dueDate, HOY)
    fijada.assertStatus(200)

    return { token, id }
  }

  test('fecha del día anterior: llega vencida', async ({ client, assert }) => {
    const { token, id } = await tareaConFecha(client, AYER)

    const tarea = await consultar(client, token, id, HOY)

    assert.equal(tarea.status, 'pending')
    assert.isTrue(tarea.isOverdue)
  })

  test('vencer hoy todavía no es estar vencida', async ({ client, assert }) => {
    const { token, id } = await tareaConFecha(client, HOY)

    const tarea = await consultar(client, token, id, HOY)

    assert.equal(tarea.status, 'pending')
    assert.isFalse(tarea.isOverdue)
  })

  test('fecha futura: no llega vencida', async ({ client, assert }) => {
    const { token, id } = await tareaConFecha(client, MANANA)

    const tarea = await consultar(client, token, id, HOY)

    assert.isFalse(tarea.isOverdue)
  })

  test('sin fecha no se vence nunca, por antigua que sea', async ({ client, assert }) => {
    const token = await sesion(client)
    const id = await crearTarea(client, token)

    // Se consulta con un día de referencia muy posterior a su creación: la tarea
    // lleva semanas (años) pendiente y sigue sin fecha.
    const tarea = await consultar(client, token, id, '2030-06-15')

    assert.equal(tarea.status, 'pending')
    assert.isNull(tarea.dueDate)
    assert.isFalse(tarea.isOverdue)
  })

  test('darla por hecha la deja de vencer y conserva su fecha', async ({ client, assert }) => {
    const { token, id } = await tareaConFecha(client, AYER)

    const antes = await consultar(client, token, id, HOY)
    assert.isTrue(antes.isOverdue)

    await cambiarEstado(client, token, id, 'done')

    const despues = await consultar(client, token, id, HOY)
    assert.equal(despues.status, 'done')
    assert.isFalse(despues.isOverdue)
    assert.equal(despues.dueDate, antes.dueDate)
  })

  test('una tarea hecha con la fecha pasada no llega vencida', async ({ client, assert }) => {
    const { token, id } = await tareaConFecha(client, '2026-08-01')
    await cambiarEstado(client, token, id, 'done')

    const tarea = await consultar(client, token, id, HOY)

    assert.equal(tarea.status, 'done')
    assert.isFalse(tarea.isOverdue)
  })

  test('aplazar resuelve el vencimiento en la misma respuesta del cambio', async ({
    client,
    assert,
  }) => {
    const { token, id } = await tareaConFecha(client, AYER)

    const antes = await consultar(client, token, id, HOY)
    assert.isTrue(antes.isOverdue)

    const aplazada = await fijarFecha(client, token, id, '2026-08-27', HOY)

    aplazada.assertStatus(200)
    assert.isFalse(aplazada.body().data.isOverdue)
  })
})
