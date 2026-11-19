# Prompts

Aquí van **todos los prompts que lanzaste** para hacer el ejercicio, en el orden en que los
lanzaste, con el modelo y la herramienta de cada uno.

Esto no es papeleo. Lo que se revisa es **cómo pediste las cosas**, no solo lo que salió: un
resultado flojo con un prompt bueno y un resultado flojo con un prompt vago necesitan feedback
distinto, y sin este archivo no se distinguen.

## Cómo rellenarlo

- Un apartado `## Prompt N` por cada prompt.
- **Pega el prompt tal cual lo lanzaste**, dentro del bloque de código, aunque ocupe diez líneas
  y aunque tenga faltas. No lo reescribas para que quede bien: el que arreglaste mentalmente
  después no es el que lanzaste.
- Incluye también los que **no funcionaron**. Suelen ser los más útiles de leer.
- `Modelo` y `Herramienta` en todos. Si cambiaste de una a otra a mitad, se nota aquí.

---

## Prompt 1

**Modelo:** Composer
**Herramienta:** Cursor Agent (WSL `/root/proyectos/flowsync-ai4devs`, rama `motor-PC`)

```
Migra el proyecto de SQLite a PostgreSQL en Docker, con una base de datos para desarrollo y otra para pruebas.

Restricciones:
- compose.yaml con servicios db y db-test
- imagen pgvector/pgvector:pg17
- puertos 54410 (dev) y 54411 (test)
- la BD de pruebas va en memoria, sin volumen
- healthcheck en ambos; el arranque espera a que acepten conexiones
- sin clave version: en compose.yaml
- los tests usan su propio archivo de entorno apuntando a la BD de test
- atajos Makefile para arrancar/detener BDs, migrar ambas y lanzar tests
- conserva intactas las migraciones existentes; si proponés modificar alguna, pará y anotalo como hallazgo

Después Parte B: typecheck, diff de backend/database/schema.ts vs s10/start, y comprobar cómo decide el proyecto si una tarea está vencida (con una que ya debería estarlo). Parte C: tres líneas en HALLAZGOS.md.
```

**Qué salió:** 23/23 en PG. schema.ts sin diff; runtime `dueDate` pasa a `Date` y rompe `isOverdueOn` en silencio.