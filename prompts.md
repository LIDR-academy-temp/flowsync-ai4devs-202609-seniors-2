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

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
lista en una tabla los ultimos 15 commits
```

**Qué salió:** funcionó a la primera.

## Prompt 2

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Contrasta las reglas de proceso de AGENTS.md con los últimos 15 commits del repositorio y el estado actual de los archivos del proyecto. Guarda el resultado en docs/auditoria/mvl.md, no en el chat.

Usa una fila por regla y completa estas cinco columnas:

1. Qué pide la regla. Resúmela en una frase y con mis propias palabras. 
2. Qué se revisó para comprobarla. Indica el comando ejecutado o el archivo consultado. Sin esta información no hay forma de saber en qué se apoya el veredicto.

3. Veredicto. Solo puede ser se cumple, no se cumple o no se puede comprobar con la información disponible. Este último caso también es un resultado válido. Significa que la regla no deja suficiente evidencia para verificarla.

4. Evidencia. Escríbela en una línea. Si la regla no se cumple, indica dónde se incumple. Si no se puede comprobar, explica qué información falta.

5. Qué harías con ella. Elige una opción: dejarla, borrarla o convertirla en una comprobación automática.

Restricciones:
No toques el resto de codigo y docs y no crees un PR ni hagas un commit ni cambies de rama. Solo guarda el resultado en el archivo indicado.

Estas son las reglas según mis notas:
1. rama por unidad de trabajo
2. formato de rama feat/slug y no usar main o ramas sN/*
3. Commit skill: por petición al cerrarse
4. Documentación actualizada si se toca los archivos involucrados en la api
5. PR y adversarial review agent: Se debe abrir un Pull Request al finalizar unidad de trabajo y realizar una revisión adversarial del código

6. no devolver la descripcion del PR en el chat se crea directamente
```

**Qué salió:** generó la tabla, pero dio la regla 1 por cumplida apoyándose en el PR #84, cuyos commits no son los 15 auditados (lo corregí en el prompt 5).

## Prompt 3

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
a que te refieres con comprobación automatica, uso de pipeline de ci o hook en cada caso?
```

**Qué salió:** explicó caso por caso si iría con hook, CI o protección de rama; en el documento no lo había concretado.

## Prompt 4

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
si mejor
```

**Qué salió:** concretó el mecanismo en la última columna de las filas 2 a 5.

## Prompt 5

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
creo que la regla 1 no se cumple lo que has visto en la PR#84 no coresponde a un de los ultimos 15 commits en esta rama
```

**Qué salió:** reconoció el error y cambió la regla 1 a «no se cumple»; avisó de que las filas 5 y 6 también se apoyaban en el PR #84.

## Prompt 6

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
deja las ultimas como que no se puede saber
```

**Qué salió:** mantuvo «no se puede comprobar» en las filas 5 y 6 y quitó el PR #84 de su evidencia.

## Prompt 7

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
quita la referencia al pr si
```

**Qué salió:** quitó las menciones al PR #84 que quedaban (la nota del principio y la fila 2).

## Prompt 8

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
Añade una nueva seccion "Parte B: las tres líneas"

1. La regla en la que más te equivocaste:  La regla de commit skill pensaba que se podía comprobar por los mensajes pero si realmente no hay garantía de que se usara.
2. Una rengla que no se puede comprobar con la información disponible: No se puede comprobar la regla ultima de devolver la descripcion del PR en el chat, ya que no hay evidencia de que se haya seguido o no.
3. La regla que eliminarías y por qué: La última regla solo ahorra unos pocos tokens se podía borrar ya que tampoco esta mal que haya feedback en el chat de lo que se ha hecho en el pr y no necesitas abrilo para comprobar la descripción.
```

**Qué salió:** añadió la sección y avisó de que contradecía el «Dejarla» de la fila 6.

## Prompt 9

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
ok borrala
```

**Qué salió:** cambió la fila 6 a «Borrarla».

## Prompt 10

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
escribe tambien mi expectativa antes de la tabla 

1. branch workflow al crear una tarea: creo que no 
2. commit skill: creo que si se cumple
3. documentacion actualizada: no se ha cumplido siempre
4. PR y adversarial review agent: tampoco
5. PR formato de la respuesta al abrir pr supongo aunque va ser dificil de comprobar
```

**Qué salió:** añadió la sección de expectativa antes de la tabla y la comparó con el resultado en el chat.

## Prompt 11

**Modelo:** Opus 5.5 Medium
**Herramienta:** Claude Code

```
ahora añade los prompts de la sesion al @../../prompts.md con el formato que se indica sin hacer commit y pr aun
```

**Qué salió:** este archivo.
