import User from '#models/user'
import { test } from '@japa/runner'
import testUtils from '@adonisjs/core/services/test_utils'

/**
 * Requisito «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`: un test
 * por cada scenario, entrando siempre por HTTP.
 *
 * Una tarea está vencida si, y solo si, tiene fecha, esa fecha es ANTERIOR al día de
 * referencia y su estado no es `done`. El día de referencia lo pone quien mira, con
 * `today`; el resultado viaja como `isOverdue` en el cuerpo.
 *
 * Ningún identificador se da por hecho: cada test usa el que le devuelve la creación.
 */
test.group('Tasks | cuándo una tarea está vencida', (group) => {
  group.each.setup(() => testUtils.db().withGlobalTransaction())

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

    return { Authorization: `Bearer ${login.body().data.token as string}` }
  }

  /** Crea una tarea por la API; opcionalmente le pone fecha y estado. */
  async function tarea(
    client: any,
    headers: Record<string, string>,
    { dueDate, status }: { dueDate?: string; status?: string } = {}
  ) {
    const creada = await client.post('/api/v1/tasks').headers(headers).json({ title: 'Tarea' })
    creada.assertStatus(201)
    const id = creada.body().data.id as number

    if (dueDate) {
      const response = await client
        .put(`/api/v1/tasks/${id}/due-date`)
        .headers(headers)
        .json({ dueDate, today: '2000-01-01' })
      response.assertStatus(200)
    }
    if (status) {
      const response = await client
        .patch(`/api/v1/tasks/${id}/status`)
        .headers(headers)
        .json({ status })
      response.assertStatus(200)
    }

    return id
  }

  async function leer(client: any, headers: Record<string, string>, id: number, today: string) {
    const response = await client.get(`/api/v1/tasks/${id}`).qs({ today }).headers(headers)
    response.assertStatus(200)
    return response.body().data
  }

  test('fecha del día anterior: llega vencida', async ({ client, assert }) => {
    const headers = await sesion(client)
    const id = await tarea(client, headers, { dueDate: '2026-08-12' })

    const data = await leer(client, headers, id, '2026-08-13')

    assert.isTrue(data.isOverdue)
  })

  test('vencer hoy todavía no es estar vencida', async ({ client, assert }) => {
    const headers = await sesion(client)
    const id = await tarea(client, headers, { dueDate: '2026-08-13' })

    const data = await leer(client, headers, id, '2026-08-13')

    assert.isFalse(data.isOverdue)
  })

  test('fecha futura: no llega vencida', async ({ client, assert }) => {
    const headers = await sesion(client)
    const id = await tarea(client, headers, { dueDate: '2026-08-14' })

    const data = await leer(client, headers, id, '2026-08-13')

    assert.isFalse(data.isOverdue)
  })

  test('sin fecha no se vence nunca, por antigua que sea', async ({ client, assert }) => {
    const headers = await sesion(client)
    const id = await tarea(client, headers)

    // Un día de referencia muy lejano: la tarea, pendiente y sin fecha, no vence.
    const data = await leer(client, headers, id, '2099-12-31')

    assert.isNull(data.dueDate)
    assert.isFalse(data.isOverdue)
  })

  test('darla por hecha la deja de vencer y conserva su fecha', async ({ client, assert }) => {
    const headers = await sesion(client)
    const id = await tarea(client, headers, { dueDate: '2026-08-12' })
    assert.isTrue((await leer(client, headers, id, '2026-08-13')).isOverdue)
    const antes = (await leer(client, headers, id, '2026-08-13')).dueDate

    const cambio = await client
      .patch(`/api/v1/tasks/${id}/status`)
      .headers(headers)
      .json({ status: 'done' })
    cambio.assertStatus(200)

    const despues = await leer(client, headers, id, '2026-08-13')
    assert.isFalse(despues.isOverdue)
    assert.equal(despues.dueDate, antes)
    assert.equal(despues.dueDate, '2026-08-12')
  })

  test('una tarea hecha con la fecha pasada no llega vencida', async ({ client, assert }) => {
    const headers = await sesion(client)
    const id = await tarea(client, headers, { dueDate: '2026-08-01', status: 'done' })

    const data = await leer(client, headers, id, '2026-08-13')

    assert.equal(data.status, 'done')
    assert.isFalse(data.isOverdue)
  })

  test('aplazar resuelve el vencimiento en la misma respuesta del cambio', async ({
    client,
    assert,
  }) => {
    const headers = await sesion(client)
    const id = await tarea(client, headers, { dueDate: '2026-08-12' })
    assert.isTrue((await leer(client, headers, id, '2026-08-13')).isOverdue)

    const response = await client
      .put(`/api/v1/tasks/${id}/due-date`)
      .headers(headers)
      .json({ dueDate: '2026-08-20', today: '2026-08-13' })

    response.assertStatus(200)
    assert.equal(response.body().data.dueDate, '2026-08-20')
    assert.isFalse(response.body().data.isOverdue)
  })
})
