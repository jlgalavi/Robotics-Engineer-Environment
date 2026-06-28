# Robotics Development Environment

Entorno de terminal modular y versionable para desarrollo robótico con WezTerm, Bash y ROS 2.

## Objetivo

Reunir la capa visual, las herramientas de shell y futuras integraciones robóticas en un proyecto mantenible, sin automatizaciones agresivas ni responsabilidades duplicadas.

## Estado actual

La fase inicial conserva la configuración existente de WezTerm y una copia de referencia de `.bashrc`. Los módulos avanzados son placeholders para trabajo futuro.

## Estructura

- `wezterm/`: configuración visual copiada sin cambios.
- `bash/`: copia de Bash y módulos pendientes de extracción manual.
- `scripts/`: backup, enlaces e inspección del entorno.
- `docs/`: arquitectura y guías.
- `context/`, `ros2/`, `git/`, `docker/`, `ssh/`, `profiles/`: bases para integraciones futuras.

## Instalación provisional

```bash
cd ~/dev/robotics-dev-environment
./install.sh
./scripts/healthcheck.sh
```

El instalador crea un backup con timestamp antes de enlazar WezTerm. No modifica `~/.bashrc`.

> **Advertencia:** proyecto experimental. Revisa scripts y backups antes de usarlo en una máquina de trabajo.
