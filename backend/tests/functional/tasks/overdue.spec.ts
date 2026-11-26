import User from '#models/user'
import { test } from '@japa/runner'
import testUtils from '@adonisjs/core/services/test_utils'

/**
 * Cuándo una tarea está vencida. Un test por cada uno de los siete scenarios del
 * requisito «Cuándo una tarea está vencida» de `openspec/specs/tasks/spec.md`.
 *
 * Todo entra por HTTP, como lo hace el cliente: la tarea se crea con
 * `POST /api/v1/tasks` (y se usa el identificador que devuelve), la fecha se pone con
 * `PUT /tasks/:id/due-date`, el estado se cambia con `PATCH /tasks/:id/status`, y lo que
 * se comprueba es el campo `isOverdue` del cuerpo de la respuesta, no un método interno.
 *
 * El día de referencia viaja siempre en `today` (AAAA-MM-DD), como fija el requisito
 * vecino «El día de referencia lo pone quien mira». Ningún test lee el reloj del
 * sistema: todas las fechas son literales.
 */
test.group('Tasks | vencimiento', (group) => {
  group.each.setup(() => testUtils.db().withGlobalTransaction())

  // Día de referencia con el que se prepara una tarea. Preparar no es probar: la
  // respuesta de esas peticiones no se mira, solo hace falta que el parámetro valga.
  const DIA_DE_PREPARACION = '2026-01-01'

  async function cuenta(client: any) {
    const email = 'ada@example.com'
    await User.create({ fullName: 'Ada Lovelace', email, password: 'secreto123' })

    const login = await client.post('/api/v1/auth/login').json({ email, password: 'secreto123' })

    return login.body().data.token as string
  }

  const con = (token: string) => ({ Authorization: `Bearer ${token}` })

  /** Crea una tarea por la API y devuelve el identificador que ella misma da. */
  async function crear(client: any, token: string): Promise<number> {
    const creada = await client
      .post('/api/v1/tasks')
      .headers(con(token))
      .json({ title: 'Revisar el informe' })

    creada.assertStatus(201)

    return creada.body().data.id as number
  }

  /** Fija (o retira, con `null`) la fecha de vencimiento. Devuelve la respuesta entera. */
  function fijarFecha(
    client: any,
    token: string,
    id: number,
    dueDate: string | null,
    today: string = DIA_DE_PREPARACION
  ) {
    return client.put(`/api/v1/tasks/${id}/due-date`).headers(con(token)).json({ dueDate, today })
  }

  async function ponerEstado(client: any, token: string, id: number, status: string) {
    const response = await client
      .patch(`/api/v1/tasks/${id}/status`)
      .headers(con(token))
      .json({ status })

    response.assertStatus(200)
  }

  /** La tarea suelta tal y como la ve quien mira desde `today`. */
  async function mirar(client: any, token: string, id: number, today: string) {
    const response = await client.get(`/api/v1/tasks/${id}`).qs({ today }).headers(con(token))
    response.assertStatus(200)

    return response.body().data
  }

  /** Una tarea con fecha, creada y preparada por la API. */
  async function tareaConFecha(client: any, token: string, dueDate: string) {
    const id = await crear(client, token)
    const fijada = await fijarFecha(client, token, id, dueDate)
    fijada.assertStatus(200)

    return id
  }

  test('Fecha del día anterior | la tarea llega marcada como vencida', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)
    const id = await tareaConFecha(client, token, '2026-08-12')

    const tarea = await mirar(client, token, id, '2026-08-13')

    assert.isTrue(tarea.isOverdue)
  })

  test('Vencer hoy todavía no es estar vencida | la fecha igual al día de referencia no vence', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)
    const id = await tareaConFecha(client, token, '2026-08-13')
    // Control: un día antes sí vence, mirando desde el mismo día. Sin él, este test
    // pasaría también si `isOverdue` fuese siempre `false` y no probaría el límite.
    const ayer = await tareaConFecha(client, token, '2026-08-12')
    assert.isTrue((await mirar(client, token, ayer, '2026-08-13')).isOverdue)

    const tarea = await mirar(client, token, id, '2026-08-13')

    assert.isFalse(tarea.isOverdue)
  })

  test('Fecha futura | la tarea no llega marcada como vencida', async ({ client, assert }) => {
    const token = await cuenta(client)
    const id = await tareaConFecha(client, token, '2026-08-14')

    const tarea = await mirar(client, token, id, '2026-08-13')

    assert.isFalse(tarea.isOverdue)
  })

  test('Sin fecha no se vence nunca | por antigua que sea la tarea', async ({ client, assert }) => {
    const token = await cuenta(client)
    // Creada y pendiente, sin fecha. Se mira desde un día muy posterior a su creación
    // para que «antigua» sea cierto sin leer ningún reloj.
    const id = await crear(client, token)

    const tarea = await mirar(client, token, id, '2030-01-01')

    assert.isNull(tarea.dueDate)
    assert.isFalse(tarea.isOverdue)
  })

  test('Darla por hecha la deja de vencer | y su fecha sigue siendo la misma', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)
    const id = await tareaConFecha(client, token, '2026-08-12')
    const HOY = '2026-08-13'

    // Punto de partida: sin esto el test no probaría el cambio sino una tarea que nunca
    // estuvo vencida.
    const antes = await mirar(client, token, id, HOY)
    assert.isTrue(antes.isOverdue)

    await ponerEstado(client, token, id, 'done')

    const despues = await mirar(client, token, id, HOY)
    assert.isFalse(despues.isOverdue)
    assert.equal(despues.dueDate, antes.dueDate)
  })

  test('Una tarea hecha con la fecha pasada | no llega marcada como vencida', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)
    const id = await tareaConFecha(client, token, '2026-08-12')
    // Control: la misma fecha en una tarea no hecha sí vence. Sin él, este test pasaría
    // también si `isOverdue` fuese siempre `false`, y no probaría que `done` lo impide.
    const pendiente = await tareaConFecha(client, token, '2026-08-12')
    assert.isTrue((await mirar(client, token, pendiente, '2026-08-13')).isOverdue)

    await ponerEstado(client, token, id, 'done')

    const tarea = await mirar(client, token, id, '2026-08-13')

    assert.equal(tarea.status, 'done')
    assert.isFalse(tarea.isOverdue)
  })

  test('Aplazar resuelve el vencimiento | en la misma respuesta del cambio', async ({
    client,
    assert,
  }) => {
    const token = await cuenta(client)
    const id = await tareaConFecha(client, token, '2026-08-12')
    const HOY = '2026-08-13'

    const antes = await mirar(client, token, id, HOY)
    assert.isTrue(antes.isOverdue)

    // La respuesta del propio cambio, no una lectura posterior.
    const aplazada = await fijarFecha(client, token, id, '2026-08-20', HOY)

    aplazada.assertStatus(200)
    assert.isFalse(aplazada.body().data.isOverdue)
  })
})
