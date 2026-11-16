# FlowSync — atajos de desarrollo.
#
# Requisitos: Node.js + npm, GNU Make y Docker (con `docker compose`).
#   - macOS:        make viene con las Command Line Tools de Xcode.
#   - Linux / WSL:  sudo apt install make   (o el equivalente de tu distro)
#
# Windows sin WSL no está soportado: estas recetas usan sintaxis POSIX.
# Desde WSL, trabaja sobre el repo clonado dentro del sistema de ficheros
# de Linux (~/...), no en /mnt/c, o npm install irá muy lento.

SHELL := /bin/bash

BACKEND  := backend
FRONTEND := frontend

.DEFAULT_GOAL := help
.PHONY: help setup start install env migrate migrate-dev migrate-test \
	db-up db-down db-ps test clean

# Las bases de datos están en compose.yaml (raíz del repo):
#   db       → desarrollo, puerto 54410, persistida en backend/database/pgsqlStorage
#   db-test  → pruebas,     puerto 54411, sin volumen (vacía en cada arranque)
COMPOSE := docker compose -f compose.yaml

# La ayuda se genera a partir de los comentarios `## ...` de cada target, para
# que no haya un segundo listado que mantener a mano y que pueda divergir.
help: ## Muestra esta ayuda
	@echo "FlowSync — targets disponibles:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN { FS = ":.*## " }; { printf "  make %-13s %s\n", $$1, $$2 }'
	@echo ""

# ---------------------------------------------------------------------------
# setup
# ---------------------------------------------------------------------------

setup: install env db-up migrate ## Deja el proyecto listo para arrancar
	@echo ""
	@echo "✅ Setup completado. Arranca todo con: make start"

install:
	@command -v node >/dev/null 2>&1 || { echo "❌ Node.js no está instalado."; exit 1; }
	@command -v npm  >/dev/null 2>&1 || { echo "❌ npm no está instalado."; exit 1; }
	@echo "📦 Instalando dependencias del backend..."
	@cd $(BACKEND) && npm install
	@echo "📦 Instalando dependencias del frontend..."
	@cd $(FRONTEND) && npm install

env:
	@if [ ! -f $(BACKEND)/.env ]; then \
		echo "📝 Creando $(BACKEND)/.env desde .env.example..."; \
		cp $(BACKEND)/.env.example $(BACKEND)/.env; \
	else \
		echo "📝 $(BACKEND)/.env ya existe, no se toca."; \
	fi
	@if [ ! -f $(FRONTEND)/.env ]; then \
		echo "📝 Creando $(FRONTEND)/.env desde .env.example..."; \
		cp $(FRONTEND)/.env.example $(FRONTEND)/.env; \
	else \
		echo "📝 $(FRONTEND)/.env ya existe, no se toca."; \
	fi
	@if grep -Eq '^APP_KEY=.+' $(BACKEND)/.env; then \
		echo "🔑 APP_KEY ya definida, no se regenera."; \
	else \
		echo "🔑 Generando APP_KEY..."; \
		cd $(BACKEND) && node ace generate:key; \
	fi

migrate: migrate-dev migrate-test ## Migra las dos bases (desarrollo y pruebas)

# Cada base se elige por entorno: con NODE_ENV=test Adonis carga además
# backend/.env.test, que apunta al puerto y la base de `db-test`.
migrate-dev: ## Migra la base de desarrollo (db, 54410)
	@echo "🗃️  Migrando la base de desarrollo (db)..."
	@cd $(BACKEND) && node ace migration:run

migrate-test: ## Migra la base de pruebas (db-test, 54411)
	@echo "🗃️  Migrando la base de pruebas (db-test)..."
	@cd $(BACKEND) && NODE_ENV=test node ace migration:run

# ---------------------------------------------------------------------------
# bases de datos (Docker)
# ---------------------------------------------------------------------------

# `--wait` no vuelve hasta que las dos pasan su healthcheck: la primera vez la
# imagen inicializa la base y rechaza conexiones mientras tanto, y una migración
# lanzada justo después fallaría con "connection refused".
db-up: ## Levanta las dos bases y espera a que estén sanas
	@command -v docker >/dev/null 2>&1 || { echo "❌ Docker no está instalado."; exit 1; }
	@echo "🐘 Levantando db (54410) y db-test (54411)..."
	@$(COMPOSE) up -d --wait

# `down` borra los contenedores: db conserva sus datos en el bind mount y
# db-test, que vive en tmpfs, los pierde. Es lo que se quiere.
db-down: ## Para las dos bases (db-test pierde sus datos)
	@echo "🛑 Parando las bases de datos..."
	@$(COMPOSE) down

db-ps: ## Muestra el estado de las dos bases
	@$(COMPOSE) ps

# ---------------------------------------------------------------------------
# test
# ---------------------------------------------------------------------------

# No hace falta migrar antes: tests/bootstrap.ts migra db-test al empezar y la
# deja sin tablas al acabar.
test: db-up ## Corre la batería del backend contra db-test
	@echo "🧪 Corriendo las pruebas contra db-test..."
	@cd $(BACKEND) && npm test

# ---------------------------------------------------------------------------
# start
# ---------------------------------------------------------------------------

# Lanza los dos servidores en paralelo dentro de la misma receta.
#
# `kill -INT 0` manda un SIGINT a todo el grupo de procesos — exactamente lo
# mismo que hace un Ctrl-C real — y así se lleva por delante ambos servidores y
# sus hijos, sin dejar nodos huérfanos ocupando los puertos. Tiene que ser
# SIGINT y no el SIGTERM por defecto de `kill 0`: con SIGTERM, el wrapper de
# `npm run dev` y el `node ace serve --hmr` sobreviven a la señal y quedan
# colgados. Se dispara desde dos sitios:
#
#   - el trap, cuando llega un Ctrl-C (SIGINT al grupo) o un SIGTERM;
#   - el final de cada subshell, cuando *ese* servidor termina por su cuenta.
#
# Lo segundo es necesario porque `wait` a secas espera a que acaben TODOS los
# jobs: si el backend crashea al arrancar, el frontend seguiría vivo para
# siempre y el usuario no se enteraría. No se usa `wait -n` (que sería lo
# natural) porque llegó en bash 4.3 y macOS trae bash 3.2.
# Ojo: `start` está pensado para uso interactivo, desde una terminal. No lo
# llames desde un script ni desde CI: sin control de trabajos, el grupo de
# procesos incluye al proceso que invocó a make, y el SIGINT se lo llevaría por
# delante a él también. Aislar los servidores en su propio grupo con `set -m`
# no vale: los dejaría en segundo plano y el primer `read` de stdin les
# provocaría un SIGTTIN, colgando el "Press h" de Adonis y los atajos de Vite.
start: db-up ## Levanta las bases, el backend y el frontend
	@if [ ! -d $(BACKEND)/node_modules ] || [ ! -d $(FRONTEND)/node_modules ]; then \
		echo "❌ Faltan dependencias. Ejecuta primero: make setup"; exit 1; \
	fi
	@if [ ! -f $(BACKEND)/.env ]; then \
		echo "❌ Falta $(BACKEND)/.env. Ejecuta primero: make setup"; exit 1; \
	fi
	@echo "🚀 Arrancando backend (http://localhost:3333) y frontend (http://localhost:5173)..."
	@echo "   Ctrl-C para parar los dos. Si uno se cae, el otro se cierra también."
	@echo ""
	@trap 'trap - INT TERM EXIT; kill -INT 0' INT TERM EXIT; \
	( cd $(BACKEND)  && npm run dev; \
	  echo ""; echo "⚠️  El backend se ha parado. Cerrando el frontend."; kill -INT 0 ) & \
	( cd $(FRONTEND) && npm run dev; \
	  echo ""; echo "⚠️  El frontend se ha parado. Cerrando el backend."; kill -INT 0 ) & \
	wait

# ---------------------------------------------------------------------------
# clean
# ---------------------------------------------------------------------------

# No toca backend/database/pgsqlStorage: los datos de desarrollo no se borran
# con un atajo. Si de verdad quieres empezar de cero, para las bases y bórralo
# a mano.
clean: ## Para las bases y borra node_modules
	@echo "🧹 Limpiando..."
	@$(COMPOSE) down
	@rm -rf $(BACKEND)/node_modules $(FRONTEND)/node_modules
	@echo "✅ Listo. Vuelve a ejecutar: make setup"
