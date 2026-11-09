# Proyecto de videos AEZ (Remotion): memoria del proyecto

Léelo entero al empezar. Aquí está todo lo que hay que saber para seguir trabajando con este usuario sin que tenga que repetirlo.

## Quién es y cómo trabajar con él
- Creador del canal **AEZ** en TikTok (**@ithnoir**). Escribe en español informal ("bro", "porfa"). Responde siempre en español, de forma cercana y directa.
- Quiere que las cosas se hagan completas y bien. Revisa los videos con atención y pide arreglos concretos (por ejemplo: la cabeza mal recortada, las cejas de Nyxar).
- Hacer commit y push de todo en la rama de desarrollo indicada en la sesión. El hook del repositorio lo exige al terminar.
- Antes de entregar un video: revisar fotogramas, transcribir el audio con Whisper, medir el volumen (−14 LUFS) y enviar el MP4 con `SendUserFile`, junto con el título, la descripción y los hashtags para TikTok.

## Regla principal
**Todo video sigue `MARCA.md`** (guía de marca aprobada): colores, tipografía, subtítulos, ritmo, fluidez, motion graphics, sonido y el personaje **Nyxar**. Si algo de la guía no encaja con un pedido, preguntar antes de saltársela.
- Hoja de marca visual: https://claude.ai/artifact/RerKSj19Dum9ifeeTzXhqH (se actualiza a la vez que `MARCA.md`).

## Nyxar (el personaje del usuario)
- Gato morado original del usuario. Está en vector en `src/personajes/Nyxar.tsx`, con expresiones, objetos con agarre (`objetos.tsx`) y cambio de sitio por escena (`Escenario.tsx`).
- **No tiene cejas**: las emociones se muestran con orejas, pupilas, párpados y boca. Nunca usar el PNG recortado del dibujo original.
- Sprites en `public/marca/sprites/` y `public/marca/sprites-nyxar.zip` (PNGTuber, stickers, hoja de personaje, pixel art). Se regeneran con la composición `SpritesNyxar` y `scripts/sprites-nyxar.py`.

## Cómo hacer un video nuevo (receta)
1. **Tema:** buscar tendencias con WebSearch y comprobar los datos clave en fuentes fiables. El canal habla de "un poco de todo", explicado por Nyxar ("el porqué de las cosas").
2. **Guion** en `src/<tema>/guion.json`: 35–50 s, frases cortas y estructura gancho → contexto → giro → remate → pregunta. El gancho son 5–6 palabras, sin saludo.
3. **Audio:** `NODE_USE_ENV_PROXY=1 node scripts/generar-audio.mjs <tema>`, luego `scripts/igualar-sfx.sh public/<tema>`. Comprobar el pico de cada efecto: si alguno sale casi mudo (por ejemplo, el "pop" a −40 dB), regenerarlo o reutilizar uno bueno de otro video.
4. **Código:** copiar la estructura de `src/gta/` (el ejemplo completo con el kit de `src/marca/`), a **60 fps**. Registrar la composición en `src/Root.tsx`.
5. **Revisión:** stills de cada escena (`npx remotion still ... --scale=0.3`), corregir y volver a revisar.
6. **Render:** `npx remotion render <Comp> out/x.mp4 --browser-executable=/opt/pw-browsers/chromium --concurrency=4`, luego `scripts/normalizar-audio.sh out/x.mp4 videos/<nombre>.mp4`.
7. **Entrega:** Whisper, LUFS, `SendUserFile`, y el texto para publicar: portada, descripción, 8–10 hashtags del tema y hora recomendada (7–10 de la noche).

## Voz
- ElevenLabs en **plan gratuito**: no permite usar voces de la biblioteca (las nativas de España) por API ni da licencia comercial.
- Voz actual del canal: **Liam** (`TX3LPaxmHKxFdv7VOQHJ`), modelo `eleven_v3`, con la etiqueta `[acento de España, castellano de Madrid, ...]` en `prefijo`.
- Pronuncia "GTA" a la inglesa. Al usuario le parece bien.
- **Créditos:** el plan gratuito da 10.000 al mes. **Se agotaron el 9 de noviembre de 2026 y se renuevan el 6 de diciembre de 2026.** Hasta entonces no se puede generar voz nueva ni efectos con ElevenLabs. Opciones: guiones muy cortos con lo que quede, efectos reutilizados de `public/*/` o sintetizados con FFmpeg (ver `public/backrooms/`: zumbido, drone y criatura), o que el usuario pase a un plan de pago. Comprobar el saldo con `curl -sS https://api.elevenlabs.io/v1/user/subscription`.
- **Alternativa gratis: edge-tts** (voces neuronales de Microsoft, las mismas que usan webs como SpeechMa). Voz de España: **`es-ES-AlvaroNeural`** (también `es-ES-ElviraNeural` y `es-ES-XimenaNeural`). Script: `python3 scripts/voz-edge.py <carpeta>`. Lee `guion.json` con los campos opcionales `"vozEdge"`, `"velocidad"` (`"+12%"`) y `"tono"`, y crea las voces y `tiempos.json` con palabras y letras. No interpreta las etiquetas `[susurrando]`: las quita. Necesita `pip install edge-tts` y el host `speech.platform.bing.com`, ya permitido en el entorno `n`. Es un servicio no oficial: puede dejar de funcionar y su uso comercial no está claro.
- Si una generación se corta, `scripts/tiempos-whisper.py <carpeta>` reconstruye `tiempos.json` con Whisper. El generador ya guarda los tiempos tras cada frase.
- Etiquetas de interpretación dentro del texto (`[susurrando]`, `[nervioso]`, `[emocionado]`) funcionan con `eleven_v3`. El generador las quita de los subtítulos.
- Si el usuario pasa a un plan de pago: usar la voz "Dani" de la biblioteca (`7QQzpAyzlKTVrRzQJmTE`, joven y de España). Necesita una clave con el permiso `voices_write`.

## Lo que dicen los datos (Windsor.ai, conector `tiktok_organic`)
| Video | Duración | Vistas | Notas |
|---|---|---|---|
| ¿Cómo funciona la programación? (sin Nyxar, horizontal) | 93 s | ~762 | Primer video; impulso de cuenta nueva |
| ¿Qué es la piratería? (Nyxar antiguo) | 110 s | ~888 | Revivió (de 377 a 888) cuando funcionó el de GTA |
| ¿Por qué GTA VI pesa 212 GB? (marca completa) | 49 s | 1.028 · 31 me gusta · 2 comentarios | Tema en tendencia |
| **¿Por qué GTA VI tardó 13 años?** (marca + reglas del inicio) | 54 s | **1.056 · 48 me gusta · 2 comentarios** (<1 día) | El mejor: 5,5 % lo ve completo y 12,3 s de media |

Conclusiones:
- **Entre el 40 y el 60 % de la gente se va en los primeros 2 segundos.** El inicio es lo más importante (ver "Los primeros 2 segundos" en `MARCA.md`).
- **Nyxar ayuda a retener:** en el de GTA, el 20 % sigue al segundo 10, frente al 13 % de los otros dos.
- Los temas en tendencia (por ejemplo, GTA VI) traen visitas desde la búsqueda.
- Revisar las estadísticas 24–48 h después de publicar; antes los datos están incompletos.
- Cuando un video nuevo funciona, TikTok vuelve a empujar los anteriores.
- Comentario en GTA: "el Genshin pesa lo mismo". Genshin pide ~110 GB en PC (150 GB recomendados) y crece con las actualizaciones. Idea: responder con un video corto ("¿Genshin pesa lo mismo que GTA VI?").

## Entorno técnico
- Entorno de nube **`n`**: red con ElevenLabs (la clave la inyecta el proxy, no hay variable de entorno) y Hugging Face. Su script de arranque instala `whisper-cli` y el modelo `small`.
- Herramientas: Remotion 4, `@remotion/transitions`, Hyperframes (`npx hyperframes`), FFmpeg, Whisper (`~/.cache/hyperframes/whisper/models/ggml-small.bin`).
- Instagram no es accesible desde el entorno: para estudiar un reel, pedir que lo suban (si pesa más de 30 MB, que lo pasen por WhatsApp para comprimirlo).

## Ideas pendientes
- Próximos temas propuestos: "Cómo los juegos de móvil te sacan el dinero" (la niña que gastó 60.000 €), "El truco de los precios del Black Friday" (27 de noviembre), "13 años esperando GTA VI" (ya hecho).
- Series del canal (propuestas, pendientes de confirmar): ¿Por qué…?, La historia detrás de…, El truco de…, Esto pasó de verdad.
- Videos en `videos/`: `celulas.mp4`, `alimentacion-equilibrio.mp4` (cliente de nutrición, Perú), `como-funciona-la-programacion.mp4`, `que-es-la-pirateria.mp4` `por-que-gta-vi-pesa-tanto.mp4`, `por-que-gta-vi-tardo-13-anos.mp4` (composición `EsperaGTA`; publicar entre el 10 y el 18 de noviembre) `fasciculaciones.mp4` (no publicado; era para la familia del usuario) y `backrooms.mp4` (composición `Backrooms`: video tipo "grabación encontrada" en el cuarto de Nyxar; un solo plano de cámara, sin las escenas estándar).
