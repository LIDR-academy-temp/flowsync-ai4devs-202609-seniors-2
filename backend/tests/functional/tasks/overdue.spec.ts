import User from '#models/user'
import { test } from '@japa/runner'
import testUtils from '@adonisjs/core/services/test_utils'

/**
 * Cuándo una tarea está vencida. Un test por cada uno de los 7 scenarios del
 * requisito «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`.
 *
 * Todo entra por HTTP, como entra el frontend: la tarea se crea con
 * `POST /api/v1/tasks`, la fecha se fija con `PUT /:id/due-date`, el estado se
 * cambia con `PATCH /:id/status` y se lee con `GET /:id?today=...`. Lo que se
 * comprueba es `isOverdue` en el cuerpo de la respuesta, nunca un método interno.
 *
 * El día de referencia es una constante: ningún test mira el reloj.
 */
test.group('Tasks | cuándo una tarea está vencida', (group) => {
  group.each.setup(() => testUtils.db().withGlobalTransaction())

  const HOY = '2026-08-20'
  const AYER = '2026-08-19'
  const MANANA = '2026-08-21'

  async function sesion(client: any) {
    const email = 'vencida@example.com'
    await User.create({ fullName: 'Ada Lovelace', email, password: 'secreto123' })
    const login = await client.post('/api/v1/auth/login').json({ email, password: 'secreto123' })
    return login.body().data.token as string
  }

  /** Crea una tarea por la API y devuelve el id que haya devuelto la creación. */
  async function crear(client: any, token: string) {
    const creada = await client
      .post('/api/v1/tasks')
      .header('Authorization', `Bearer ${token}`)
      .json({ title: 'Revisar el informe' })
    creada.assertStatus(201)
    return creada.body().data.id as number
  }

  async function fijarFecha(client: any, token: string, id: number, dueDate: string | null) {
    const respuesta = await client
      .put(`/api/v1/tasks/${id}/due-date`)
      .header('Authorization', `Bearer ${token}`)
      .json({ dueDate, today: HOY })
    respuesta.assertStatus(200)
    return respuesta
  }

  async function cambiarEstado(client: any, token: string, id: number, status: string) {
    const respuesta = await client
      .patch(`/api/v1/tasks/${id}/status`)
      .header('Authorization', `Bearer ${token}`)
      .json({ status })
    respuesta.assertStatus(200)
  }

  async function consultar(client: any, token: string, id: number, today: string = HOY) {
    const respuesta = await client
      .get(`/api/v1/tasks/${id}`)
      .qs({ today })
      .header('Authorization', `Bearer ${token}`)
    respuesta.assertStatus(200)
    return respuesta.body().data
  }

  test('fecha del día anterior: la tarea llega vencida', async ({ client, assert }) => {
    const token = await sesion(client)
    const id = await crear(client, token)
    await fijarFecha(client, token, id, AYER)

    const tarea = await consultar(client, token, id)

    assert.isTrue(tarea.isOverdue)
  })

  test('vencer hoy todavía no es estar vencida', async ({ client, assert }) => {
    const token = await sesion(client)
    const id = await crear(client, token)
    await fijarFecha(client, token, id, HOY)

    const tarea = await consultar(client, token, id)

    assert.isFalse(tarea.isOverdue)
  })

  test('fecha futura: la tarea no llega vencida', async ({ client, assert }) => {
    const token = await sesion(client)
    const id = await crear(client, token)
    await fijarFecha(client, token, id, MANANA)

    const tarea = await consultar(client, token, id)

    assert.isFalse(tarea.isOverdue)
  })

  test('sin fecha no se vence nunca', async ({ client, assert }) => {
    const token = await sesion(client)
    const id = await crear(client, token)

    // «Creada hace semanas»: se mira desde un día muy posterior a su creación.
    const tarea = await consultar(client, token, id, '2030-01-01')

    assert.isNull(tarea.dueDate)
    assert.isFalse(tarea.isOverdue)
  })

  test('darla por hecha la deja de vencer', async ({ client, assert }) => {
    const token = await sesion(client)
    const id = await crear(client, token)
    await fijarFecha(client, token, id, AYER)

    // Precondición del scenario: la tarea ES vencida antes del cambio.
    const antes = await consultar(client, token, id)
    assert.isTrue(antes.isOverdue)

    await cambiarEstado(client, token, id, 'done')

    const despues = await consultar(client, token, id)
    assert.isFalse(despues.isOverdue)
    assert.equal(despues.dueDate, AYER)
    assert.equal(despues.dueDate, antes.dueDate)
  })

  test('una tarea hecha con la fecha pasada no llega vencida', async ({ client, assert }) => {
    const token = await sesion(client)
    const id = await crear(client, token)
    await fijarFecha(client, token, id, AYER)
    await cambiarEstado(client, token, id, 'done')

    const tarea = await consultar(client, token, id)

    assert.equal(tarea.status, 'done')
    assert.isFalse(tarea.isOverdue)
  })

  test('aplazar resuelve el vencimiento en la misma respuesta del cambio', async ({
    client,
    assert,
  }) => {
    const token = await sesion(client)
    const id = await crear(client, token)
    await fijarFecha(client, token, id, AYER)

    // Precondición del scenario: la tarea ES vencida antes del cambio.
    const antes = await consultar(client, token, id)
    assert.isTrue(antes.isOverdue)

    const aplazada = await fijarFecha(client, token, id, MANANA)

    assert.isFalse(aplazada.body().data.isOverdue)
  })
})
