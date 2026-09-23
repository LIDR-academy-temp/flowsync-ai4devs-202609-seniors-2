<!-- Generado desde la lección de ejercicio del módulo: no se edita a mano. -->

# Ejercicio FlowSync: mide una regla que creías cumplida

Es lo único que hay que traer hecho. Cuenta con unos **45 minutos** de trabajo.

> 🚨 **Ve guardando cada prompt tal cual lo lanzas**, desde el primero. Al final se entregan, y reconstruirlos de memoria no vale: lo que se revisa es cómo lo pediste, no solo qué salió.

Vas a medir, sobre el proyecto del curso, si una regla que lleva meses escrita en el archivo de instrucciones del agente se cumple de verdad. Es el mismo encargo que se resuelve en el directo, con la misma regla y el mismo archivo de salida. Lo que pones tú son los prompts.

El ejercicio tiene dos partes: la medición (Parte A) y tres líneas sobre lo que has medido (Parte B).

## 🔁 Cómo funciona este módulo

Hay tres momentos, y saberlos cambia cómo aprovechas cada uno.

**1. Lo intentas tú.** Sobre el proyecto de abajo, con tu agente y con el reloj puesto. Entregas lo que te salga, **con lo que tenga**. La entrega a medias no es un problema: este paso no se puntúa por completarlo, y lo que se discute en vivo son las cosas con las que te chocaste.

**2. Lo ves resuelto en el directo.** El mentor mide esta misma regla, con este mismo encargo y sobre este mismo proyecto, y la automatiza después para poder repetirla sin contar a mano, que es el paso que tú no haces. Si a ti no te salió, ahí ves que se puede y cómo. Por eso conviene **mirar sin teclear**: lo vas a repetir con calma después.

**3. Lo replicas.** Los prompts que use el mentor te llegan por escrito. Con ellos vuelves a tu entorno y rehaces el recorrido, que es donde se asienta.

> ⚠️ **En el paso 3 no esperes salidas idénticas, y no es un fallo tuyo.** El agente no es determinista: con el mismo encargo cambian los nombres, la redacción y hasta si el README de la capability acaba al día o no. Aquí eso no es ruido de fondo, es **el objeto de estudio**: por eso el ejercicio pide cinco intentos y no uno. Lo que se repite es **la forma del recorrido**, no el texto.

---

## 🛠️ Deja el entorno listo

### 1. Comprueba lo que necesita tu máquina

Una línea por requisito, con el comando que lo verifica y el síntoma de tenerlo mal.

- **Node 24** (la versión con soporte de largo plazo): `node -v` responde `v24.x`. Con Node 20, `make setup` muere con `ERR_UNKNOWN_FILE_EXTENSION ".ts"`; con la 22 arranca entre decenas de avisos `EBADENGINE`.
- **make**: `make --version`. Si falta, verás `command not found: make`.
- **git**: `git --version`. Si falta, verás `command not found: git`.
- **Claude Code**, instalado y con sesión iniciada: `claude --version` responde algo. No hace falta ninguna versión concreta para este ejercicio.

**Dónde funciona esto:** macOS y Linux tal cual. **En Windows, dentro del Subsistema de Windows para Linux (WSL, por sus siglas en inglés)**, y con **todo** hecho dentro: el clon, Node y `make`. Lo que instales en Windows no existe dentro de WSL. No sirve PowerShell, y el motivo se puede comprobar abriendo el `Makefile` del proyecto: sus atajos usan `cp`, `test` y `rm`, que son de shell de macOS y Linux.

> 💳 **Esto consume tu plan, y conviene saberlo antes de empezar.** Cada intento es **una sesión de agente completa** contra tu cuenta de Claude, y el ejercicio pide **cinco**. Es poco, y aun así merece que lo sepas antes que después. La costumbre que lo mantiene barato, y que vas a usar siempre: **no repitas un intento "por si acaso"** sin haber anotado el anterior.

### 2. Forkea, clona e instala

```bash
# 1. Forkea https://github.com/LIDR-academy/flowsync-ai4devs-202609-seniors-2 desde la interfaz de GitHub.
#    🚨 DESMARCA la casilla que dice copiar solo la rama por defecto: viene marcada.

# 2. Clónalo desde TU fork
git clone git@github.com:<tu-usuario>/flowsync-ai4devs-202609-seniors-2.git
cd flowsync-ai4devs-202609-seniors-2

# 3. La rama de partida se trae del repositorio del curso, no del fork
git remote add upstream git@github.com:LIDR-academy/flowsync-ai4devs-202609-seniors-2.git
git fetch upstream
git checkout -b s8/start upstream/s8/start

# 4. Instala
make setup
```

### 3. Comprueba que el proyecto vive

**Comprueba que vive antes de seguir**, o vas a depurar la medición cuando lo que falla es el proyecto:

```bash
(cd backend && npm test)    # tiene que terminar en verde
```

> 📌 **Los paréntesis no sobran.** Sin ellos te quedas dentro de `backend/`, y ahí no hay `CLAUDE.md`: el siguiente comando que lances parecerá que no encuentra el proyecto. Con ellos vuelves solo a la raíz.

---

## 📋 La tarea

### 🅰️ Parte A: medir la regla del README

La regla que vas a medir está en el archivo `CLAUDE.md` del proyecto, en su sección de reglas de proceso, y dice literalmente esto:

> *"Un cambio que toque rutas, controladores, validadores o transformers de una capability se cierra en el mismo commit con el documento OpenAPI y el README de esa capability al día."*

Lo que hay que averiguar es **en qué proporción de los intentos se cumple la parte del README**, con este encargo y no otro:

> **"Añade a la capability `tasks` el endpoint `DELETE /api/v1/tasks/:id`, que borra una tarea y devuelve `204` sin cuerpo. Impleméntalo en el controlador que ya existe y declara su ruta junto a las demás de `tasks`."**

Cinco pasos, y el orden importa:

1. **Apunta tu apuesta antes de medir nada.** ¿Cuántas veces de cinco crees que el README de la capability va a quedar al día? Escríbela; es media línea y es lo que hace que el resultado te diga algo.
2. **Lanza el encargo tal cual, en una sesión nueva.** Pégalo entero y **no le recuerdes la regla**: si hay que recordársela, ya sabes la respuesta y no hace falta medir nada.
3. **Comprueba dos cosas a mano cuando termine**, en este orden:
   - **El control**: ¿quedó declarada la ruta `DELETE`? Si no, el agente no hizo el trabajo, y entonces lo otro no significa nada: ese intento no cuenta.
   - **El resultado**: ¿menciona `docs/capabilities/tasks/README.md` el endpoint nuevo?
4. **Deja el proyecto exactamente como estaba**, o el intento siguiente no mide lo mismo. Son tres comandos y van juntos:

   ```bash
   git checkout -f s8/start            # vuelve a la rama de partida, descartando cambios
   git reset --hard upstream/s8/start  # deshace lo que el agente haya commiteado
   git clean -fd                       # borra los archivos nuevos que dejó
   ```

   Comprueba que funcionó: `git status -sb` tiene que responder **solo** la línea que empieza por `## s8/start`. Si aparece cualquier otra, todavía queda algo dentro.

5. **Repite hasta cinco veces** y anota las dos casillas de cada intento.

> ⚠️ **`git restore .` no basta, y esto es lo que más gente va a pillar, porque falla en silencio.** La regla de proceso que estás midiendo no es la única del archivo: ese `CLAUDE.md` también le pide al agente **crear una rama y commitear** al cerrar el trabajo. Si lo hizo, descartar cambios no deshace nada: `git status` te dice *limpio*, y sin embargo sigues en la rama del intento anterior, con su trabajo ya dentro. El segundo intento arrancaría desde donde acabó el primero, y los cinco números que te salgan no serían cinco medidas de lo mismo.
>
> Las ramas `feat/…` que vaya dejando cada intento puedes ignorarlas: no estorban. Lo que importa es desde dónde arrancas.

> ⏱️ **Sí, es repetitivo, y esa es la mitad de la lección.** Medir una regla significa exactamente esto: el mismo encargo, otra vez, contando. Hazlo a mano ahora y el directo te va a saber distinto.

### 🅱️ Parte B: las tres líneas

Es lo que de verdad se revisa, y **no se puede fallar**: se responde igual de bien si la medición te salió redonda que si se te atascó a la mitad.

1. Tu apuesta y el resultado. Si no llegaste a las cinco ejecuciones, di cuántas hiciste.
2. **Qué harías con ese número**: borrar la regla, reescribirla, o convertirla en algo que se ejecute solo. Y por qué.
3. **Una cosa que tu medición no está midiendo.** Siempre hay una, y detectarla vale más que el propio número.

**El archivo de salida es `docs/evals/<tus-iniciales>.md`**, dentro del proyecto, con la parte A y la parte B.

> ⚠️ **La inteligencia artificial no es determinista, y aquí eso no es un aviso legal: es el objeto de estudio.** Si repites el encargo y sale distinto, no lo has hecho mal. Es exactamente lo que vienes a medir. Y cuando replique este recorrido con los prompts del mentor, tampoco te van a salir sus mismas palabras: lo que se repite es la forma del recorrido, nunca el texto.

### Cómo saber que la has hecho bien

- **Tu apuesta está escrita antes del primer intento**, y no la has retocado después de ver el resultado.
- **Los cinco intentos arrancan del mismo sitio.** Si alguno empezó donde acabó el anterior, ese número no mide lo mismo que los otros: `git status -sb` te lo dice antes de lanzarlo.
- **Cada intento tiene sus dos casillas anotadas**, la del control y la del resultado, y los intentos en los que el agente no declaró la ruta están marcados como no contados.
- **Las tres líneas están escritas y son concretas.** Si la tercera dice *«nada, la medición lo cubre todo»*, vuelve a mirar: siempre hay algo que el número no ve.
- **No has vuelto a lanzar un intento «por si acaso»** sin haber anotado el anterior. Eso convierte cinco medidas en cinco anécdotas, y de paso gasta tu plan.

> Entrégalo con lo que tenga.

---

## 📤 Cómo se entrega

### Tu rama

Créala **cuando terminaste los cinco intentos y vas a escribir tu archivo, no antes**: entre intento e intento vuelves a `s8/start` con los tres comandos de arriba, y eso te sacaría de una rama de entrega creada al principio. Sales de la rama de partida, ya limpia:

```bash
git checkout s8/start
git checkout -b evals-<tus-iniciales>
```

Ahí va todo lo que entregues.

### El pull request

Un pull request (PR, por sus siglas en inglés) **desde tu fork**, con dos cosas:

- **El archivo `docs/evals/<tus-iniciales>.md`** con las dos partes.
- **Un `prompts.md` en la raíz del proyecto**, con los prompts que lanzaste, cada uno en su bloque de código, indicando el modelo y la herramienta que usaste.

```bash
git add docs/evals prompts.md
git commit -m "evals: medicion de la regla + prompts"
git push -u origin evals-<tus-iniciales>
```

Con la rama empujada, GitHub te ofrece arriba el botón para abrir el pull request. Va **contra el repositorio del curso** (`github.com/LIDR-academy/flowsync-ai4devs-202609-seniors-2`), no contra tu fork: comprueba que el repositorio base que te propone es ese.

### El plazo

**Plazo: antes del directo.** Lo que llega a tiempo recibe feedback antes de la sesión, que es el único momento en que te sirve. Lo que llega tarde se marca como recibido y no se revisa.

## 📚 Si vas justo de tiempo

Prioriza la lección sobre **por qué una regla escrita no es una regla cumplida**, que es el andamiaje de todo lo demás, y la que trata **por qué un número sin línea base no significa nada**: son las dos que hacen que tu tabla de cinco intentos se pueda leer. Las otras tres se siguen bien en vivo.

Y si el reloj aprieta de verdad, la prioridad es la **parte B**: tres líneas honestas sobre dos intentos valen más que cinco intentos sin escribir.

---

## ✅ Antes de conectarte, comprueba

- [ ] Estás en la rama de partida, sobre **tu fork**, y `git push` funciona.
- [ ] `node -v` responde `v24` o más, y `make --version` responde, en la terminal donde trabajas (en Windows, la de WSL).
- [ ] `claude --version` responde, y tu sesión está iniciada.
- [ ] Sabes **dónde está la regla** que mediste dentro del `CLAUDE.md` del proyecto, y la has leído entera.
- [ ] **Traes `docs/evals/<tus-iniciales>.md`**, con su tabla de intentos (aunque esté a medias) y sus tres líneas.
- [ ] **`prompts.md` está relleno**, con modelo y herramienta en cada bloque.
- [ ] **Tu rama se llama `evals-<tus-iniciales>` y el pull request está abierto contra el repositorio del curso.**

> Trae el archivo tal como quedó, sin maquillarlo: lo que le falta es la mitad de lo interesante.

---

## 🎯 Qué te llevas del Módulo 8

**El modelo mental**: que una regla escrita en un archivo de instrucciones es una petición, no una garantía, y que se cumple en un porcentaje de los casos que nadie conoce hasta que alguien lo cuenta. Que ese porcentaje solo aparece repitiendo el mismo encargo varias veces, porque una ejecución suelta es una anécdota con cara de dato. Que no significa nada sin compararlo contra lo que ocurre sin tu configuración puesta, porque buena parte de lo que crees estar consiguiendo el modelo lo hace de todas formas. Que puntuar con código va antes que puntuar con criterio, y que un juez sin calibrar es una opinión con formato de número. Y que tu primera medición casi nunca mide lo que crees, así que lo primero que se prueba es la medición: un verde que nunca ha estado en rojo no prueba nada.

**Lo que queda en el proyecto**: una carpeta con tu medición, en `docs/evals/`: el encargo escrito, las dos comprobaciones, lo que salió en cada intento y tu decisión sobre la regla. Es la línea base de esa regla, y sirve el día que cambies de modelo o toques el archivo de instrucciones: sin un número de antes, no hay forma de saber si lo que cambiaste mejoró algo o solo lo movió de sitio.
