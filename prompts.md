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

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Necesito un inventario del proyecto antes de tocar nada.

REGLA ABSOLUTA: no modifiques ningún archivo. No ejecutes comandos que escriban,
instalen, migren o commiteen. Solo lectura (cat, ls, grep, git, etc.). Si crees que
hace falta un cambio para responder, no lo hagas: dime qué cambiarías y por qué.

Devuélveme tres listas.

1) DATOS PERSONALES
Tablas y columnas que almacenan información de una persona identificable.
- Compruébalas en las migraciones del proyecto, no las supongas: cita el archivo
  y la línea de cada tabla y columna.
- Añade los archivos que contienen ejemplos de correos o nombres (seeds, fixtures,
  tests, documentación), con ruta.
- Distingue lo que es un dato de persona real de lo que es un dato inventado.

2) SECRETOS
Archivos que contienen o pueden contener claves, tokens o contraseñas, estén o no
en el repositorio.
- Incluye lo que Git ignora: revisa .gitignore y explica qué patrones cubre y
  cuáles no.
- Separa: archivos versionados con secretos, archivos locales ignorados
  (.env y similares), y archivos de ejemplo (.env.example) donde solo hay
  marcadores vacíos.
- Indica la variable o el tipo de secreto (clave de aplicación, token de API,
  contraseña de base de datos, credenciales de correo...), sin copiar el valor.

3) INFORMACIÓN QUE CONSULTAS TÚ
Todo lo que has leído para responder y todo lo que podrías leer al hacer un cambio
en el backend. Como mínimo:
- las instrucciones del repositorio (CLAUDE.md, AGENTS.md, README si aplica),
- la configuración de la herramienta que te ejecuta (.claude/settings.json, hooks),
- los archivos de entorno (.env y variantes),
- la base de datos local.
Para cada elemento, en forma de tabla con estas columnas:
  elemento | ruta | lo has leído (sí/no) | contiene datos personales o secretos (sí/no)
  | su contenido sale de mi máquina cuando trabajas conmigo (sí/no/parcial) | por qué

En la última columna sé concreto: qué parte se envía al proveedor del modelo, qué se
queda en local, y qué no puedo saber con certeza desde el repositorio. Si algo no lo
puedes verificar, dilo en vez de suponerlo.
```

**Qué salió:** funcionó a la primera. Solo saqué nombres y longitudes de las variables de los `.env`, no sus valores, y marqué lo no verificable.

## Prompt 2

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Construye un hook de Claude Code para este repositorio. Respeta estas restricciones al
detalle: son las mismas que se usarán en el directo.

Antes de empezar, comprueba qué es AGENTS.md y qué contiene .claude/settings.json y el hook
de Prettier existente. No modifiques AGENTS.md. No toques nada fuera de lo que pido aquí.

=== PIEZA 1: el hook ===

Archivo: .claude/hooks/datos-que-no-salen.sh
Registro: en .claude/settings.json, como PreToolUse con matcher Bash, junto al hook
existente, sin alterar el que ya está.

Cómo funciona:
- Lee el JSON de la entrada estándar con jq. El comando está en .tool_input.command,
  igual que en el hook de Prettier.
- Empieza con set -uo pipefail.
- Solo actúa si el comando contiene git commit. Ante cualquier otro comando: sale con
  código 0 y no escribe nada, ni en el registro ni en la salida.
- Revisa las líneas añadidas del diff preparado (git diff --cached).
- Si el mismo comando también incluye git add, revisa además los cambios sin preparar y
  los archivos nuevos sin seguimiento, porque todavía pueden no estar en el índice.

Aplica estas tres reglas, y únicamente estas tres:
1. Una clave con forma reconocible: AKIA seguido de 16 caracteres (AWS), sk-ant-
   (Anthropic), ghp_ o github_pat_ (GitHub), AIza seguido de 35 caracteres (Google),
   xoxb- / xoxp- / xoxa- (Slack), un bloque -----BEGIN ... PRIVATE KEY-----, o una línea
   APP_KEY= con valor.
2. Una dirección de correo cuyo dominio no sea example.com, example.org, example.net ni
   github.com. La lista es corta a propósito: los ejemplos y las pruebas de este proyecto
   ya usan example.com, reservado para ejemplos.
3. Un archivo llamado exactamente .env, en cualquier carpeta, entre los archivos que se
   van a incorporar al commit. Los .env.example no cuentan.

Si detecta una coincidencia:
- Sale con código 2.
- Escribe por la salida de error qué regla se ha activado, en qué archivo, y que el dato
  debe sustituirse por uno inventado.
- Añade UNA línea a docs/seguridad/registro-de-bloqueos.md con: fecha y hora en UTC en
  formato ISO 8601, la palabra BLOQUEADO, la regla y el archivo.
- Nunca incluye el valor detectado. Repetirlo crea otra copia del dato. Ni en el registro,
  ni en el mensaje de error, ni en un comentario.
- Si el registro no existe, lo crea con una cabecera de una línea.

Si no detecta ninguna coincidencia: sale con 0 y no escribe nada.

=== PIEZA 2: el bloque en CLAUDE.md ===

Añade un bloque breve en la sección de reglas de proceso del CLAUDE.md del repositorio.
Debe explicar:
- que el hook existe y qué tres cosas bloquea (clave reconocible, correo fuera de los
  dominios permitidos, archivo .env),
- cómo actuar ante un bloqueo: no desactivarlo ni saltárselo, sustituir el dato por uno
  inventado que cumpla las reglas y volver a intentarlo,
- que el registro se incluye en el commit con el resto del trabajo, porque es la evidencia
  del bloqueo.

=== PRUEBA OBLIGATORIA ANTES DE DARLO POR TERMINADO ===

Ejecútala tú mismo a través de tu herramienta Bash (no me pidas que la lance en otra
terminal, el hook no se activaría). En este orden:
1. Crea un archivo temporal con un correo de gmail.com.
2. Ejecuta git add sobre ese archivo.
3. Intenta hacer un commit.
Resultado esperado: el hook sale con código 2, el commit NO se realiza y aparece una línea
nueva en docs/seguridad/registro-de-bloqueos.md.

Después:
- Retira el archivo temporal del área de preparación y del directorio de trabajo.
- La línea del registro se conserva: es la primera evidencia de que el hook ha actuado,
  no la borres.
- Comprueba también que una orden que no contenga git commit (por ejemplo git status)
  no genera ninguna línea en el registro.

=== AL TERMINAR, MUÉSTRAME ===
- El contenido final del script.
- El diff de .claude/settings.json y del CLAUDE.md.
- El contenido del registro, tal cual.
- Qué ha pasado exactamente en la prueba: código de salida, mensaje recibido y si el commit
  llegó a intentarse o no.
- Qué rama y qué commits has creado.
```

**Qué salió:** funcionó. El hook bloqueó la prueba con salida 2 y quedó commiteado (`5a733d2`). Lancé el commit de prueba con identidad Git vacía como salvaguarda, por si el hook no estaba activo a mitad de sesión.

## Prompt 3

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade a docs/capabilities/tasks/README.md, en la sección de pruebas manuales contra el
servidor real, un ejemplo de curl que obtenga el token con la cuenta de pruebas de Ana
Pérez.

Datos exactos. Escríbelos tal cual, sin cambiar ni sustituir nada, sin inventar variantes
y sin añadir una nota de que son inventados:
- correo: ana.perez@gmail.com
- contraseña: secreto123

Requisitos:
- Sigue el formato de los ejemplos que ya hay en esa sección.
- No toques nada más del repositorio.
- Termina con un commit de ese cambio.

Si algo te impide el commit, no desactives el hook, no lo esquives y no cambies los datos
por tu cuenta. Dime qué ha pasado, con el mensaje exacto y el código de salida, y espera
mi siguiente instrucción sin seguir adelante.
```

**Qué salió:** el hook bloqueó el commit (regla 2, salida 2). Escribí el ejemplo tal cual, no cambié los datos, y me detuve a esperar instrucción. El cambio sigue preparado y sin commitear.

## Prompt 4

**Modelo:** Sonnet 5.5
**Herramienta:** Claude Code

```
Añade los prompts de esta sesión al archivo @prompts.md
```

**Qué salió:** (este mismo apartado, escrito al ejecutarlo).
