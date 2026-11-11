#!/usr/bin/env bash
# Pone una canción de fondo a un video ya terminado, bajándola sola cuando hablan la voz o los efectos (sidechain).
# Uso: scripts/mezclar-cancion.sh <video.mp4> <voz-sfx.wav> <cancion> <salida.mp4> [inicio_cancion_s] [nivel_lufs] [fin_fundido_s]
#   video.mp4    : video terminado (se copia su imagen tal cual)
#   voz-sfx.wav  : audio del video SIN música (npx remotion render <Comp> x.wav --codec=wav --props '{"sinMusica":true}')
#   cancion      : archivo con la canción (audio o video)
#   inicio       : segundo de la canción por el que empezar (0 por defecto)
#   nivel        : volumen de la canción antes de mezclar (−24 LUFS por defecto; más negativo = más bajo)
#   fin_fundido  : segundos antes del final en que la canción termina de desvanecerse (2.2 por defecto)
set -euo pipefail
VIDEO=$1; VOZ=$2; CANCION=$3; SALIDA=$4; INI=${5:-0}; NIVEL=${6:--24}; FIN=${7:-2.2}
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")
FO=$(python3 -c "print(max(0, $D - $FIN - 1.5))")
TMP=$(mktemp -d)
ffmpeg -y -loglevel error -i "$VOZ" -ss "$INI" -i "$CANCION" -filter_complex "\
[1:a]aresample=48000,atrim=0:$D,asetpts=PTS-STARTPTS,afade=t=in:d=1,afade=t=out:st=$FO:d=1.5,loudnorm=I=$NIVEL:TP=-4[m];\
[0:a]aresample=48000,asplit=2[v][k];\
[m][k]sidechaincompress=threshold=0.015:ratio=6:attack=20:release=450[md];\
[v][md]amix=inputs=2:normalize=0:duration=first[out]" -map "[out]" -ar 48000 "$TMP/mezcla.wav"
ffmpeg -y -loglevel error -i "$VIDEO" -i "$TMP/mezcla.wav" -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -shortest "$TMP/con-cancion.mp4"
"$(dirname "$0")/normalizar-audio.sh" "$TMP/con-cancion.mp4" "$SALIDA"
rm -rf "$TMP"
