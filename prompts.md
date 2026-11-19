# Prompts

Aquí van **todos los prompts que lanzaste** para hacer el ejercicio, en el orden en que los
lanzaste, con el modelo y la herramienta de cada uno.

---

## Prompt 1 — Parte A (inventario)

**Modelo:** Opus 5.5 · Claude Pro  
**Herramienta:** Claude Code

```
Sin modificar ningún archivo, haz un inventario del proyecto con tres listas basadas solo en evidencias del repo (migraciones, configs, gitignore, etc.):

1) Datos personales: tablas/columnas identificables + archivos con ejemplos de correos/nombres.
2) Secretos: archivos con o posibles claves, tokens, contraseñas (incluye lo que Git ignora).
3) Qué consulta el agente al trabajar aquí (instrucciones del repo, config de la herramienta, .env, BD local) y, por cada elemento, si ese contenido sale de esta máquina.

No inventes: cita rutas/archivos concretos.
```

**Qué salió:** inventario con tablas/archivos y qué sale de la máquina.

---

## Prompt 2 — Parte B (hook)

**Modelo:** Opus 5.5 · Claude Pro  
**Herramienta:** Claude Code

```
Crea el hook de Claude Code `datos-que-no-salen` y su documentación, sin tocar AGENTS.md ni nada fuera de lo pedido.
[… piezas 1–3 + prueba obligatoria @gmail.com …]
```

**Qué salió:** hook + settings + CLAUDE.md; la primera prueba vía agente falló (hook no cargado / ruta UNC); tras reinicio y `command: bash .claude/hooks/datos-que-no-salen.sh`, la prueba bloqueó con código 2.

---

## Prompt 3 — Reprueba hook

**Modelo:** Opus 5.5 · Claude Pro  
**Herramienta:** Claude Code

```
Repite la prueba obligatoria del hook: crea un temporal con un correo @gmail.com, git add, intenta git commit. …
```

**Qué salió:** BLOQUEADO regla 2; línea en registro; sin commit.

---

## Prompt 4 — Parte C

**Modelo:** Opus 5.5 · Claude Pro  
**Herramienta:** Claude Code

```
Añade en docs/capabilities/tasks/README.md … curl con ana.perez@gmail.com y secreto123 … Termina con un git commit …
```

**Qué salió:** lo bloqueó el hook (regla 2 en el README), no una negativa previa del modelo. Luego se sustituyó por @example.com para poder commitear con el registro.
