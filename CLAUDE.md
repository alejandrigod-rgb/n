# Proyecto de videos (Remotion)

Videos para el canal **AEZ** (TikTok @ithnoir), hechos con Remotion, ElevenLabs y Whisper.

## Regla principal
**Todo video que se edite para el usuario sigue `MARCA.md`** (guía de marca aprobada): colores, tipografía, subtítulos, ritmo, fluidez, motion graphics, sonido y el personaje **Nyxar** (`src/personajes/Nyxar.tsx`). Si algo de la guía no encaja con un pedido concreto, preguntar antes de saltársela.

## Herramientas
- Render: `npx remotion render <Composición> out/<archivo>.mp4 --browser-executable=/opt/pw-browsers/chromium`; luego normalizar el audio con `scripts/normalizar-audio.sh`.
- Audio: `NODE_USE_ENV_PROXY=1 node scripts/generar-audio.mjs <carpeta>` (lee `src/<carpeta>/guion.json`; la clave de ElevenLabs la inyecta el proxy).
- Transcripción y verificación: `whisper-cli` con `~/.cache/hyperframes/whisper/models/ggml-small.bin`.
- Estadísticas de TikTok: conector Windsor.ai (`tiktok_organic`).
