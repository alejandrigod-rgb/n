#!/usr/bin/env bash
# Kit de efectos de sonido sintetizados con SoX (gratis, sin depender de ElevenLabs).
# Uso: scripts/sfx-sox.sh [carpeta]   (por defecto public/sfx-kit). Requiere: sox, ffmpeg.
set -euo pipefail
D="${1:-public/sfx-kit}"
mkdir -p "$D"
T=$(mktemp -d)
w() { sox -n -r 44100 -c 2 "$T/$1.wav" "${@:2}"; }

# Pop: tono que cae rápido
w pop synth 0.09 sine 950-180 fade 0 0.09 0.07
# Clic y tic de interfaz
w clic synth 0.025 square 2400 fade 0 0.025 0.02 lowpass 6000
w tic synth 0.06 sine 1600 fade 0 0.06 0.05
# Whoosh: ruido filtrado con barrido
w whoosh synth 0.9 pinknoise fade q 0.4 0.9 0.45 highpass 300 lowpass 5000 flanger 0 3 0 70 0.6 sine 25 lin gain -4
# Golpe grave
sox -n -r 44100 -c 2 "$T/g1.wav" synth 1.1 sine 95-32 fade 0 1.1 1.0 overdrive 8
sox -n -r 44100 -c 2 "$T/g2.wav" synth 0.15 brownnoise fade 0 0.15 0.14 lowpass 800
sox -m "$T/g1.wav" "$T/g2.wav" "$T/golpe.wav"
# Subida (antes de un momento clave)
sox -n -r 44100 -c 2 "$T/s1.wav" synth 1.4 sine 180-1400 fade q 1.2 1.4 0.15
sox -n -r 44100 -c 2 "$T/s2.wav" synth 1.4 pinknoise fade q 1.3 1.4 0.1 highpass 1500 gain -8
sox -m "$T/s1.wav" "$T/s2.wav" "$T/subida.wav"
# Éxito: dos notas que suben, con eco
w exito synth 0.16 sine 1046.5 fade 0 0.16 0.05 : synth 0.4 sine 1318.5 fade 0 0.4 0.35 reverb 40
# Error: zumbido grave doble
w error synth 0.18 square 210 fade 0 0.18 0.03 : synth 0.3 square 165 fade 0 0.3 0.1 lowpass 2500 gain -6
# Brillo: arpegio agudo con reverberación
w brillo synth 0.09 sine 2093 fade 0 0.09 0.06 : synth 0.09 sine 2637 fade 0 0.09 0.06 : synth 0.09 sine 3136 fade 0 0.09 0.06 : synth 0.5 sine 4186 fade 0 0.5 0.45 reverb 60
# Glitch digital
w glitch synth 0.05 square 120 : synth 0.04 whitenoise : synth 0.06 square 880 : synth 0.03 whitenoise : synth 0.08 square 60 gain -6
# Estática de TV
w estatica synth 0.7 whitenoise tremolo 28 90 highpass 500 fade 0 0.7 0.05 gain -4
# Latido: dos golpes graves
w latido synth 0.13 sine 70-38 fade 0 0.13 0.1 : synth 0.12 trapezium 0 pad 0 0 : synth 0.16 sine 60-34 fade 0 0.16 0.12 : synth 0.4 sine 0 gain -1
# Cascabel de Nyxar: parciales agudos que se apagan, agitado tres veces
for i in 1 2 3; do
  sox -n -r 44100 -c 2 "$T/c$i.wav" synth 0.35 sine $((2900 + i*90)) sine $((4400 + i*70)) sine $((6100 + i*50)) fade 0 0.35 0.33 gain -3
done
sox "$T/c1.wav" "$T/c2.wav" "$T/c3.wav" "$T/cascabel0.wav" pad 0 0.1
sox "$T/cascabel0.wav" "$T/cascabel.wav" reverb 30 speed 1.02 trim 0 0.9

for n in pop clic tic whoosh golpe subida exito error brillo glitch estatica latido cascabel; do
  sox "$T/$n.wav" "$T/${n}-n.wav" norm -3
  ffmpeg -y -loglevel error -i "$T/${n}-n.wav" -c:a libmp3lame -b:a 160k "$D/sfx-$n.mp3"
done
rm -rf "$T"
echo "Kit de efectos en $D"
