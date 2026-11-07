# n

Proyecto de video hecho con [Remotion](https://www.remotion.dev).

## Comandos

```bash
npm install       # instalar dependencias
npm run dev       # abrir Remotion Studio para previsualizar
npm run build     # renderizar la composición HelloWorld a out/video.mp4
```

Las composiciones se registran en `src/Root.tsx`.

## Video: ¿Cómo funcionan las células?

Composición `Celulas` (66 s, 1920×1080) en `src/celulas/`. Escenas: introducción,
la célula como unidad de la vida, membrana, núcleo y ADN, ribosomas,
mitocondrias, división celular y resumen. El video renderizado está en
`videos/celulas.mp4`.

## Video: Alimentación y Equilibrio

Video promocional vertical (1080×1920, ~57 s) en `src/nutricion/`, con narración
y efectos de sonido generados con ElevenLabs.

```bash
npm run audio:nutricion   # genera voz y efectos en public/nutricion/ (usa ELEVENLABS_API_KEY)
npm run build:nutricion   # renderiza out/alimentacion-equilibrio.mp4
```

El guion, la voz y los efectos se editan en `src/nutricion/guion.json`. Para
regenerar un audio, borra su archivo en `public/nutricion/` (o usa `--forzar`).
Las duraciones de la voz ajustan automáticamente la duración de cada escena.

## Herramientas

- **FFmpeg**: del sistema (`ffmpeg`, `ffprobe`).
- **Hyperframes** (HeyGen): `npx hyperframes --help`; `npx hyperframes doctor` revisa dependencias.
- **Whisper** (whisper.cpp, CPU): `whisper-cli`, con el modelo multilingüe `small`.
  Transcribir a subtítulos:

  ```bash
  npm run transcribir -- public/nutricion/voz-marca.mp3 --to srt -o marca.srt
  ```

  `@remotion/install-whisper-cpp` y `@remotion/captions` están instalados para
  usar las transcripciones como subtítulos en Remotion.

## Video: ¿Cómo funciona la programación?

Video explicativo horizontal (1920×1080, ~93 s) en `src/programacion/`: narrador,
efectos de sonido, música y subtítulos palabra por palabra.

```bash
npm run audio:programacion   # genera voz (con marcas de tiempo) y efectos
npm run build:programacion   # renderiza y normaliza el audio a -14 LUFS
```

Las animaciones se sincronizan con las palabras del narrador (`marcas("escena")("palabra")`),
así que si cambias el guion en `guion.json` y regeneras el audio, todo se reacomoda.
`scripts/normalizar-audio.sh` deja cualquier video al volumen estándar de YouTube y redes.

## Video: ¿Qué es la piratería? (con el gato)

Video vertical para TikTok (1080×1920, ~110 s) en `src/pirateria/`, presentado por el gato morado.

- **Personaje** (`Gato.tsx`): la cabeza es el dibujo original (`public/pirateria/cabeza.png`,
  preparado con `scripts/preparar-gato.py`, que quita el fondo y borra la boca). El cuerpo,
  brazos, cola, pañuelo y accesorios (sombrero pirata, cascos, carta) son vectoriales.
- **Boca**: se abre según la letra que suena en cada momento (marcas de tiempo por letra de
  ElevenLabs): vocales abiertas, labiales cerradas. Parpadea solo y cabecea al hablar.
- **Poses**: cada escena define una postura (`POSES` en `Gato.tsx`) y el gato pasa de una a
  otra con suavidad.
- **Voz**: modelo `eleven_v3` con etiqueta de acento castellano (ver `prefijo` en `guion.json`).

```bash
npm run audio:pirateria   # voz + efectos (y sube el volumen de los efectos flojos)
npm run build:pirateria   # renderiza y normaliza a -14 LUFS
```
