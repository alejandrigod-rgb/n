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
