#!/usr/bin/env bash
# Normaliza el volumen de un video al estándar de YouTube/redes (-14 LUFS, pico -1.5 dB).
# Uso: scripts/normalizar-audio.sh entrada.mp4 salida.mp4
set -euo pipefail
ffmpeg -y -loglevel error -i "$1" -c:v copy -af loudnorm=I=-14:TP=-1.5:LRA=11 -ar 48000 -c:a aac -b:a 192k "$2"
