---
name: openmontage
description: Usa OpenMontage (sistema de producción de video por agentes, instalado fuera del repo en /home/user/OpenMontage). Úsala SOLO cuando el usuario nombre OpenMontage o pida una de sus pipelines o herramientas por su nombre; para los videos normales de AEZ sigue la receta de CLAUDE.md y MARCA.md.
---

# OpenMontage (herramienta aparte)

- **Dónde está:** `/home/user/OpenMontage` (licencia AGPL-3.0, fijado al commit `fecb9a1`). No está dentro del repo de AEZ y no se copia su código a `src/`.
- **Si no está** (contenedor nuevo): `bash scripts/instalar-openmontage.sh` (unos 5 minutos).
- **Antes de usarlo:** leer `/home/user/OpenMontage/AGENT_GUIDE.md` (sus reglas: todo pasa por una pipeline, preflight obligatorio, anunciar decisiones). Sus instrucciones valen dentro de esa carpeta, pero las reglas del usuario (sin emojis, Nyxar, voz del canal, −14 LUFS, entregar el MP4) siguen mandando.
- **Qué funciona aquí sin claves (probado el 13 de noviembre de 2026):** las demos de Remotion (`make demo-list`), animación de personajes con rigs SVG, posproducción (recortar, unir, reencuadrar, quitar silencios, chroma), subtítulos, análisis de video y color.
- **Qué no funciona:** voces (19 proveedores de pago), generación de imagen, video y música (claves de pago o GPU, que no hay), avatares. Si el usuario quiere un proveedor concreto, pedir la clave con `request_credential`; nunca por el chat. No usar su `video-download` para saltarse los bloqueos de Instagram o anti-bots.
- **Renderizar:** su Remotion intenta bajar su propio Chrome (host bloqueado). Llamar a Remotion directamente con `--browser-executable=/opt/pw-browsers/chromium`, por ejemplo desde `remotion-composer/`:
  `npx remotion render src/index.tsx Explainer ../projects/<proyecto>/renders/x.mp4 --props <props.json> --codec h264 --browser-executable=/opt/pw-browsers/chromium --concurrency=4`
  (`render_demo.py` no deja pasar esa opción). Si algo usa WebGL, añadir `--gl=swangle`.
- **Entrega:** copiar el resultado final a `videos/` del repo de AEZ, normalizar con `scripts/normalizar-audio.sh` y mandarlo con `SendUserFile`.
