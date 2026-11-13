#!/usr/bin/env bash
# Instala OpenMontage (github.com/OpenMontageInc/OpenMontage, licencia AGPL-3.0) FUERA del repositorio, en /home/user/OpenMontage,
# fijado al commit revisado el 13 de noviembre de 2026. No se copia su código al proyecto de AEZ.
# Uso: bash scripts/instalar-openmontage.sh
set -euo pipefail
DESTINO=/home/user/OpenMontage
SHA=fecb9a1e3cc23ef84de30b272059457a427f16f8
if [ ! -d "$DESTINO/.git" ]; then
  git clone https://github.com/OpenMontageInc/OpenMontage.git "$DESTINO"
fi
cd "$DESTINO"
git fetch --depth 1 origin "$SHA" 2>/dev/null || true
git checkout -q "$SHA"
# Python 3.11 (el que trae este contenedor); sin GPU ni el instalador de MiniCut; .env sin claves.
make setup PYTHON_VERSION=3.11
