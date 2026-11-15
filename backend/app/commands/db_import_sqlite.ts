import { BaseCommand, flags } from '@adonisjs/core/ace'
import type { CommandOptions } from '@adonisjs/core/types/ace'
import { existsSync } from 'node:fs'
import { relative } from 'node:path'
import { DatabaseSync } from 'node:sqlite'
import { DateTime } from 'luxon'
import type { Database as LucidDatabase } from '@adonisjs/lucid/database'
import type { TransactionClientContract } from '@adonisjs/lucid/types/database'

/**
 * Tablas de datos que se copian, en orden de dependencia (las referenciadas
 * antes que las que las referencian). `adonis_schema*` no se copia: la base de
 * destino ya tiene su propio registro de migraciones, de `migration:run`.
 */
const TABLES = ['users', 'auth_access_tokens', 'tasks'] as const

type Row = Record<string, unknown>

/**
 * Copia los datos de la antigua base SQLite (`tmp/db.sqlite3`) a la base
 * PostgreSQL de desarrollo.
 *
 * - Solo corre fuera del entorno de pruebas: la base `db-test` tiene que
 *   quedarse vacía.
 * - Exige que las dos bases tengan aplicadas exactamente las mismas
 *   migraciones, para que las columnas coincidan sin tener que adivinar.
 * - **Vacía** las tablas de destino (TRUNCATE ... RESTART IDENTITY) y vuelve a
 *   copiar, todo en una transacción: o entra todo o no entra nada.
 * - Recoloca las secuencias de los ids donde las dejó SQLite, para que la
 *   siguiente alta no choque con un id ya usado.
 *
 * Conversión de valores, decidida por el tipo de la columna en PostgreSQL:
 * - `timestamp with time zone`: SQLite tiene dos formatos para lo mismo. Lucid
 *   escribe texto `yyyy-MM-dd HH:mm:ss` (en UTC, el TZ del proceso) y el
 *   paquete de auth escribe milisegundos epoch. Los dos se leen como instantes
 *   UTC. Cualquier otro formato aborta la importación en vez de adivinarlo.
 * - `date`: se exige texto `yyyy-MM-dd` y se copia tal cual.
 * - El resto se copia sin tocar.
 */
export default class DbImportSqlite extends BaseCommand {
  static commandName = 'db:import-sqlite'
  static description =
    'Vacía la base PostgreSQL de desarrollo y copia en ella los datos de tmp/db.sqlite3'

  static options: CommandOptions = {
    startApp: true,
  }

  @flags.string({ description: 'Ruta del fichero SQLite de origen (por defecto tmp/db.sqlite3)' })
  declare source?: string

  async run() {
    if (this.app.inTest) {
      this.exitCode = 1
      this.logger.error('no se importa en el entorno de pruebas: la base db-test debe quedar vacía')
      return
    }

    const sourcePath = this.source ?? this.app.tmpPath('db.sqlite3')

    if (!existsSync(sourcePath)) {
      this.exitCode = 1
      this.logger.error(`no existe ${relative(process.cwd(), sourcePath)}`)
      return
    }

    // `node:sqlite` viene con Node 24: no hace falta ningún paquete para leer
    // el fichero antiguo.
    const sqlite = new DatabaseSync(sourcePath, { readOnly: true })

    // El servicio de BD se resuelve aquí y no en un import de cabecera: ace
    // carga los ficheros de comandos antes de arrancar la app.
    const db: LucidDatabase = await this.app.container.make('lucid.db')

    try {
      await this.#import(sqlite, db)
    } catch (error) {
      this.exitCode = 1
      this.logger.error(error instanceof Error ? error.message : String(error))
    } finally {
      sqlite.close()
    }
  }

  async #import(sqlite: DatabaseSync, db: LucidDatabase) {
    await this.#assertSameMigrations(sqlite, db)

    const connection = db.connection()
    const { database } = connection.getWriteClient().client.config.connection as {
      database: string
    }
    this.logger.info(`origen: SQLite · destino: PostgreSQL "${database}"`)

    const copied: Record<string, number> = {}

    await connection.transaction(async (trx) => {
      await trx.rawQuery(`TRUNCATE ${TABLES.join(', ')} RESTART IDENTITY CASCADE`)

      for (const table of TABLES) {
        const columnTypes = await this.#columnTypes(trx, table)
        this.#assertSameColumns(sqlite, table, columnTypes)

        const rows = sqlite.prepare(`SELECT * FROM "${table}" ORDER BY id`).all() as Row[]
        const converted = rows.map((row) => this.#convertRow(table, row, columnTypes))

        if (converted.length > 0) {
          await trx.table(table).multiInsert(converted)
        }

        await this.#syncSequence(sqlite, trx, table)
        copied[table] = converted.length
      }
    })

    for (const table of TABLES) {
      const [{ count }] = await db.from(table).count('* as count')
      const expected = copied[table]

      if (Number(count) !== expected) {
        throw new Error(`${table}: se copiaron ${expected} filas pero el destino tiene ${count}`)
      }

      this.logger.success(`${table}: ${expected} fila(s)`)
    }
  }

  /**
   * Si las migraciones aplicadas no son las mismas, las columnas pueden no
   * casar y la copia tendría que inventarse valores. Se para antes.
   */
  async #assertSameMigrations(sqlite: DatabaseSync, db: LucidDatabase) {
    const source = (
      sqlite.prepare('SELECT name FROM adonis_schema ORDER BY name').all() as Row[]
    ).map((row) => String(row.name))
    const targetRows = await db.from('adonis_schema').select('name').orderBy('name')
    const target = targetRows.map((row) => String(row.name))

    if (source.join('\n') !== target.join('\n')) {
      throw new Error(
        'las migraciones aplicadas no coinciden entre SQLite y PostgreSQL; ' +
          'ejecuta `make migrate-dev` y revisa que el fichero SQLite es el esperado'
      )
    }
  }

  async #columnTypes(trx: TransactionClientContract, table: string) {
    const result = await trx.rawQuery(
      `SELECT column_name, data_type FROM information_schema.columns
       WHERE table_schema = current_schema() AND table_name = ?`,
      [table]
    )

    return new Map<string, string>(
      (result.rows as { column_name: string; data_type: string }[]).map((c) => [
        c.column_name,
        c.data_type,
      ])
    )
  }

  #assertSameColumns(sqlite: DatabaseSync, table: string, columnTypes: Map<string, string>) {
    const source = (sqlite.prepare(`PRAGMA table_info("${table}")`).all() as Row[])
      .map((c) => String(c.name))
      .sort()
    const target = [...columnTypes.keys()].sort()

    if (source.join(',') !== target.join(',')) {
      throw new Error(
        `${table}: las columnas no coinciden (SQLite: ${source.join(', ')} · PostgreSQL: ${target.join(', ')})`
      )
    }
  }

  #convertRow(table: string, row: Row, columnTypes: Map<string, string>): Row {
    const converted: Row = {}

    for (const [column, value] of Object.entries(row)) {
      const where = `${table}.${column} (id ${row.id})`
      const type = columnTypes.get(column)

      if (value === null) {
        converted[column] = null
      } else if (type === 'timestamp with time zone') {
        converted[column] = this.#toInstant(value, where)
      } else if (type === 'date') {
        converted[column] = this.#toDate(value, where)
      } else {
        converted[column] = value
      }
    }

    return converted
  }

  #toInstant(value: unknown, where: string): Date {
    if (typeof value === 'number' && Number.isInteger(value)) {
      return new Date(value)
    }

    if (typeof value === 'string') {
      const parsed = DateTime.fromFormat(value, 'yyyy-MM-dd HH:mm:ss', { zone: 'utc' })

      if (parsed.isValid) {
        return parsed.toJSDate()
      }
    }

    throw new Error(`${where}: formato de fecha y hora no reconocido: ${JSON.stringify(value)}`)
  }

  #toDate(value: unknown, where: string): string {
    if (
      typeof value === 'string' &&
      DateTime.fromFormat(value, 'yyyy-MM-dd', { zone: 'utc' }).isValid
    ) {
      return value
    }

    throw new Error(`${where}: formato de fecha no reconocido: ${JSON.stringify(value)}`)
  }

  /**
   * Deja la secuencia del id donde la dejó SQLite (`sqlite_sequence`), que
   * puede ir por delante del id máximo si se borraron filas: así no se
   * reutiliza un id que ya se dio.
   */
  async #syncSequence(sqlite: DatabaseSync, trx: TransactionClientContract, table: string) {
    const sequenceRow = sqlite
      .prepare('SELECT seq FROM sqlite_sequence WHERE name = ?')
      .get(table) as { seq: number } | undefined
    const maxRow = sqlite.prepare(`SELECT MAX(id) AS max FROM "${table}"`).get() as {
      max: number | null
    }
    const last = Math.max(sequenceRow?.seq ?? 0, maxRow.max ?? 0)

    if (last > 0) {
      await trx.rawQuery(`SELECT setval(pg_get_serial_sequence(?, 'id'), ?, true)`, [table, last])
    } else {
      await trx.rawQuery(`SELECT setval(pg_get_serial_sequence(?, 'id'), 1, false)`, [table])
    }
  }
}
