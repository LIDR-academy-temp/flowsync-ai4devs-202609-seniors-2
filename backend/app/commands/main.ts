import type { CommandMetaData } from '@adonisjs/core/types/ace'
import DbImportSqlite from './db_import_sqlite.js'

/**
 * Cargador de comandos que se registra en `adonisrc.ts`, igual que los de los
 * paquetes (`@adonisjs/lucid/commands`).
 *
 * Existe porque los comandos del directorio `commands/` no arrancan en este
 * entorno: ace valida sus metadatos con `jsonschema` 1.5.0 (la última versión),
 * que resuelve sus `$ref` con `new URL('/undefined#/…', 'thismessage::/')`, y
 * Node 24.20 rechaza esa URL con «Invalid URL». Los cargadores registrados así
 * no pasan por esa validación. El fallo afecta también a `openapi:check` y
 * `openapi:generate`, que siguen en `commands/`.
 *
 * Cuando esté arreglado, este comando puede volver a `commands/` y este fichero
 * desaparecer.
 */
const commands = [DbImportSqlite]

export async function getMetaData(): Promise<CommandMetaData[]> {
  return commands.map((command) => command.serialize())
}

export async function getCommand(metaData: CommandMetaData) {
  return commands.find((command) => command.commandName === metaData.commandName) ?? null
}
