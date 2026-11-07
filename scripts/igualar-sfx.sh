#!/usr/bin/env bash
# Sube cada efecto para que su pico quede en -3 dB (los efectos generados salen a volúmenes muy distintos).
# Uso: scripts/igualar-sfx.sh public/<carpeta>
set -euo pipefail
for f in "$1"/sfx-*.mp3; do
  pico=$(ffmpeg -hide_banner -i "$f" -af volumedetect -f null - 2>&1 | grep -o "max_volume: [-0-9.]*" | awk '{print $2}')
  ganancia=$(awk -v p="$pico" 'BEGIN { g = -3 - p; if (g < 0.5 && g > -0.5) g = 0; printf "%.1f", g }')
  if [ "$ganancia" != "0.0" ]; then
    ffmpeg -y -loglevel error -i "$f" -af "volume=${ganancia}dB" -c:a libmp3lame -b:a 128k "$f.tmp.mp3" && mv "$f.tmp.mp3" "$f"
    echo "$(basename "$f"): ${pico} dB -> -3 dB"
  fi
done
