# Prompts

Aquí van **todos los prompts que lanzaste** para hacer el ejercicio, en el orden en que los
lanzaste, con el modelo y la herramienta de cada uno.

Cómo se trabajó: un Claude Code orquestador (desktop, en Windows) recibe mi encargo, prepara el
entorno en WSL y lanza **un subagente con contexto limpio por parte**. La Parte A y la Parte B no
comparten conversación: el que escribe los tests unitarios no vio la sesión del que escribió los de
contrato, y ninguno de los dos tenía permiso para tocar la implementación. La Parte C la redactó el
orquestador a partir de las salidas guardadas, sin prompt aparte. Todos los prompts están pegados
enteros, tal cual se lanzaron.

---

## Prompt 1: Encargo al orquestador

**Modelo:** Opus 5.5  
**Herramienta:** Claude Code v2.1.328 (app de escritorio, Windows → WSL `/root/proyectos/flowsync-ai4devs`)

```
vengo haciendo un curso y tenes el @AGENTS.md como contexto tiens la docue d elso modulos 8 al 11 aca tenes las corereciones del 9 y 10 https://github.com/LIDR-academy-temp/flowsync-ai4devs-202609-seniors-2/pull/33#pullrequestreview-6065721646 y https://github.com/LIDR-academy-temp/flowsync-ai4devs-202609-seniors-2/pull/32 la idea es q lea sel modulo 11 el ejercicos y lso hagas si hay alguna duda me dices @modulo11/ el contendo hacer , si neceistas ejecutar una power sehell wsl o loq haga flata hazlo
```

**Qué salió:** leyó el módulo y las correcciones y preparó `s11/start` → `tests-PC`. Línea de partida: `Tests 40 passed (40)`; unit `NO TESTS EXECUTED` con exit 0. Me preguntó cómo lanzar las partes y elegí «subagentes».

---

## Prompt 2: Seguimiento al orquestador

**Modelo:** Opus 5.5  
**Herramienta:** Claude Code v2.1.328 (app de escritorio)

```
revisa el agenst.md con toros prs q genere si te ayuda
```

```
| # | Título | Repo | Base | Estado | URL |
|---|---|---|---|---|---|
| 5 | auditoria: comentarios + prompts | blog-legacy-…-seniors-2 | `s6/start` | open | https://github.com/LIDR-academy-temp/blog-legacy-ai4devs-202609-seniors-2/pull/5 |
| 5 | frontera: dos frases + prompts | blog-api-…-seniors-2 | (polyrepo) | open | https://github.com/LIDR-academy-temp/blog-api-ai4devs-202609-seniors-2/pull/5 |
| 11 | evals: medicion de la regla + prompts | flowsync-…-seniors-2 | `s8/start` | open | https://github.com/LIDR-academy-temp/flowsync-ai4devs-202609-seniors-2/pull/11 |
| 32 | Bloqueo PC | flowsync-…-seniors-2 | `s9/start` | open | https://github.com/LIDR-academy-temp/flowsync-ai4devs-202609-seniors-2/pull/32 |
| 33 | Motor PC | flowsync-…-seniors-2 | `s10/start` | open | https://github.com/LIDR-academy-temp/flowsync-ai4devs-202609-seniors-2/pull/33 |

 esos prs me referiaa
```

**Qué salió:** tomó como formato el `prompts.md` y el `HALLAZGOS.md` de `motor-PC` y `bloqueo-PC`, y aplicó las correcciones: prompts enteros, uno por parte y «Modelo» sin el plan.

---

## Prompt 3: Parte A, el contrato primero

**Modelo:** Opus 5.5 (subagente con contexto limpio)  
**Herramienta:** Claude Code v2.1.328 (subagente, ejecutando en WSL)

```
Trabajas en el repo FlowSync clonado DENTRO de WSL en /root/proyectos/flowsync-ai4devs, rama tests-PC (ya creada, no cambies de rama ni commitees). Desde Windows llegas a él así: escribe un script .sh en C:\Users\caste\proyectos\ai4devs\modulo11\scripts\ y ejecútalo con PowerShell: `wsl -e bash /mnt/c/Users/caste/proyectos/ai4devs/modulo11/scripts/<script>.sh`. Los ficheros del repo los lees/escribes desde dentro de WSL (cat, heredoc) en esos scripts, o vía \\wsl$\Ubuntu\root\proyectos\flowsync-ai4devs si te funciona. Para cargar node 24 y entrar al repo, empieza cada script con `. /mnt/c/Users/caste/proyectos/ai4devs/modulo11/scripts/env.sh`.

Tarea (Parte A del ejercicio del módulo 11, "el contrato primero"):

1. Lee el Requirement entero "Cuándo una tarea está vencida" de openspec/specs/tasks/spec.md y sus 7 Scenarios. Lee también el Requirement siguiente "El día de referencia lo pone quien mira" (parámetro `today`). Esos Scenarios son el enunciado: no inventes casos.
2. Escribe UN archivo de tests funcionales nuevo en backend/tests/functional/tasks/ (por ejemplo `vencimiento.spec.ts`) con UN test por Scenario (7 tests), que entren por HTTP como entra el cliente: crear cuenta/sesión, crear la tarea, fijar su fecha con PUT /api/v1/tasks/:id/due-date, cambiar estado si el Scenario lo pide, y consultar.
3. Ejecútalo con `bash /mnt/c/Users/caste/proyectos/ai4devs/modulo11/scripts/mk.sh test-e2e /mnt/c/Users/caste/proyectos/ai4devs/modulo11/salidas/10-parteA-make-test-e2e.txt` (es `make test-e2e` con un workaround de red de Podman en WSL; no lo cambies). Guarda la salida ENTERA en ese fichero, no solo si pasó.

Restricciones, todas obligatorias:
- No toques ni una línea fuera de backend/tests/. Ni modelo, ni transformer, ni controlador, ni validador, ni rutas, ni .adonisjs/. Si un test falla, NO lo arregles cambiando la implementación: el ejercicio termina con los tests en rojo. Tampoco "ajustes" la aserción para que pase: la expectativa sale de la spec, no del código.
- Las expectativas salen de los Scenarios, no de leer cómo está implementado isOverdueOn. Puedes leer rutas, controladores y los tests existentes solo para saber CÓMO llamar a la API (paths, payloads, forma de la respuesta), no para decidir QUÉ esperar.
- Comprueba lo que sale en la respuesta HTTP: el campo se llama `isOverdue` y viaja en el cuerpo (dentro del envoltorio `data`). Nada de llamar métodos del modelo.
- El día de referencia se pasa en la petición (`today=AAAA-MM-DD`), con fechas fijas escritas en el test. Prohibido `new Date()`, `Date.now()`, DateTime.now() o cualquier reloj.
- Sigue la forma de aislamiento que ya usan los tests de backend/tests/functional/ (mira qué hooks de testUtils.db() usan los de tasks y auth y copia esa forma), sin inventar otra.
- No des por hecho ningún id: usa el que te devuelva la creación.

Al terminar devuélveme: la ruta del archivo creado y su contenido completo; la salida de `git status --short` y `git diff --stat`; y del fichero de salida, la lista de tests con ✔/✖, el resumen final (Tests N passed, M failed) y el mensaje de error de cada test rojo (Expected/Received). No resumas los errores: cópialos.
```

**Qué salió:** 7 tests con `withGlobalTransaction()` y el id tomado de la creación. `Tests 44 passed, 3 failed (47)`: los 3 rojos esperan `isOverdue: true`. El primer intento falló en `migrate` porque los contenedores estaban parados; los levantó y relanzó sin cambiar nada.

---

## Prompt 4: Parte B, bajar la regla, y solo la regla

**Modelo:** Opus 5.5 (subagente con contexto limpio)  
**Herramienta:** Claude Code v2.1.328 (subagente, ejecutando en WSL)

```
Trabajas en el repo FlowSync clonado DENTRO de WSL en /root/proyectos/flowsync-ai4devs, rama tests-PC (no cambies de rama ni commitees). Desde Windows llegas a él así: escribe un script .sh en C:\Users\caste\proyectos\ai4devs\modulo11\scripts\ (con prefijo b-) y ejecútalo con PowerShell: `wsl -e bash /mnt/c/Users/caste/proyectos/ai4devs/modulo11/scripts/<script>.sh`. Empieza cada script con `. /mnt/c/Users/caste/proyectos/ai4devs/modulo11/scripts/env.sh` (carga node 24 y entra al repo). Si los contenedores de Postgres están parados, levántalos con `docker compose up -d db db-test` y espera a que estén healthy.

Tarea (Parte B del ejercicio del módulo 11, "bajar la regla, y solo la regla"):

La regla de "Cuándo una tarea está vencida" (Requirement de openspec/specs/tasks/spec.md, léelo entero) vive en el método `isOverdueOn` de backend/app/models/task.ts. Crea la carpeta backend/tests/unit/, que hoy no existe, y escribe ahí un archivo (por ejemplo backend/tests/unit/task_overdue.spec.ts) con los bordes de esa regla, SIN servidor y SIN base de datos (instancia el modelo en memoria y asigna sus propiedades, no lo guardes; comprueba primero cómo está registrada la suite unit en adonisrc.ts y backend/tests/bootstrap.ts para no arrancar nada que no toca):

1. Fecha anterior al día de referencia, tarea sin hacer → vencida.
2. Fecha exactamente igual al día de referencia → no vencida.
3. Fecha posterior → no vencida.
4. Sin fecha → no vencida.
5. Tarea ya hecha (`done`), con la fecha pasada → no vencida.
6. Un caso más que no sale de la spec: la regla tiene que comportarse igual reciba la fecha de vencimiento como texto 'AAAA-MM-DD' o como objeto de fecha (Date / DateTime, según lo que de verdad le llega al modelo cuando lee de PostgreSQL; averígualo mirando database/schema.ts, schema_rules.ts y, si hace falta, leyendo una tarea real de la base de pruebas en un script aparte, no en el test). Para la misma fecha anterior al día de referencia, las dos formas deben dar el mismo resultado: vencida.

Restricciones, todas obligatorias:
- No toques ni una línea fuera de backend/tests/. Ni el modelo, ni schema, ni adonisrc.ts, ni bootstrap.ts. Si un test falla, NO lo arregles cambiando la implementación ni suavizando la aserción: el ejercicio termina con los tests en rojo. Las expectativas salen de la spec, no del código.
- El día de referencia es un parámetro con una fecha fija escrita en el test. Prohibido new Date() sin argumentos, Date.now(), DateTime.now() o cualquier reloj.
- No modifiques el archivo de tests funcionales que ya existe en backend/tests/functional/tasks/vencimiento.spec.ts.

Ejecuta: `bash /mnt/c/Users/caste/proyectos/ai4devs/modulo11/scripts/mk.sh test-unit /mnt/c/Users/caste/proyectos/ai4devs/modulo11/salidas/20-parteB-make-test-unit.txt` y después `bash /mnt/c/Users/caste/proyectos/ai4devs/modulo11/scripts/mk.sh test /mnt/c/Users/caste/proyectos/ai4devs/modulo11/salidas/21-parteB-make-test.txt` (son `make test-unit` y `make test` con un workaround de red de Podman en WSL; no los cambies). Guarda las salidas enteras.

Al terminar devuélveme: el contenido completo del archivo creado; qué tipo le llega de verdad a dueDate desde PostgreSQL y cómo lo comprobaste; `git status --short` y `git diff --stat`; y de cada salida, la lista de tests con ✔/✖, el resumen final y el mensaje de error de cada rojo (Expected/Received) copiado tal cual, no resumido.
```

**Qué salió:** `Tests 4 passed, 2 failed (6)` en unit y `48 passed, 5 failed (53)` en total. Rojos: «hecha con la fecha pasada» (la regla no mira `status`) y «texto vs `Date`» (`{ texto: true, fecha: false }`). Con una sonda fuera del test confirmó que `pg` entrega `due_date` como `Date`.
