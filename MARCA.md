# Guía de marca AEZ: aprobada

> Aprobada por el usuario el 7 de noviembre de 2026. **Seguirla en cada video que se edite para AEZ.**
> Hoja visual: https://claude.ai/artifact/RerKSj19Dum9ifeeTzXhqH

**Canal:** AEZ (TikTok @ithnoir). Curiosidades de tecnología, internet e historia, contadas por **Nyxar**.
**Estilo visual base:** el video de las células (`videos/celulas.mp4`): noche azul, burbujas, brillo neón y fluidez total.
**Fórmula de formato** (estudiada en reels de @gooldeoroo_ e @inframundo3d): gancho inmediato, un objeto por frase, subtítulos palabra a palabra, cifras que cuentan y un cierre que invita a compartir. Se toma la fórmula, **no** su estética. No usar recuadros azules de "selección", cifras doradas con brillo ni el logo de Instagram como firma.

## Kit de marca (código)
- `src/marca/tema.ts`: colores, fuentes y 60 fps. `src/marca/kit.tsx`: `Fondo` con burbujas, `Titulo` de escena, `Subtitulos` en caja con subrayado menta en las palabras clave, `Contador`, `Brillo`, `Respira`, `Plano` (zoom lento y golpes de zoom), `Rafaga`, `Pop` y `Sfx`. `src/marca/linea.ts`: línea de tiempo a partir de la narración (`marcas` para sincronizar con palabras y `aperturaBoca` para la boca de Nyxar).
- Ejemplo completo: `src/gta/` (composición `GtaVI`).

## Nyxar (personaje original del usuario)
- Gato morado con pelo de punta y rayas, un rizo a la derecha, orejas con interior rosa, ojos grandes y afilados con pupila azul, nariz azul, boca `:3`, pañuelo rojo y cascabel dorado.
- Componente: `src/personajes/Nyxar.tsx`, en vector. **No usar el PNG recortado del dibujo.** Recibe `pose`, `boca` (0-1) y `frame`. Parpadea, mueve las orejas, respira y mueve la cola solo.
- La boca se sincroniza con las marcas de tiempo por letra de ElevenLabs (ver `aperturaBoca` en `src/pirateria/linea.ts`).
- **Inmersivo: Nyxar cambia de sitio en cada escena** con `src/personajes/Escenario.tsx`. Sitios: `izquierda`, `derecha` (girado hacia el centro), `centro`, `asomadoIzquierda` (grande, asomándose por el borde) y `asomadoDerecha` (arriba a la derecha). Entra deslizándose desde fuera de la pantalla (muelle de ~0,5 s) y sale por su lado justo antes del cambio de escena. **Nunca repite el mismo sitio dos escenas seguidas**, y todos los sitios dejan libres las zonas que tapa TikTok.
- **Objetos del tema, solo a veces:** el objeto aparece **solo cuando la escena trata de ese tema** (como guía, 1 de cada 3 escenas como mucho; nunca en todas). Entra con un pop justo cuando el narrador lo nombra y se va cuando cambia el tema. Cuando la escena habla de algo concreto, Nyxar lo sostiene: portátil (cómputo, programación, internet), móvil (redes, apps), mando (videojuegos), libro (historia, leyes), lupa (investigar, descubrir) y bombilla (ideas, inventos). Están en `src/personajes/objetos.tsx`; si un tema necesita un objeto nuevo, se dibuja en el mismo estilo y se añade ahí. Se activan con la prop `objeto` y `pose.objeto` (0-1) para que aparezca con un pop.
- **Siempre sujetado con sentido** (`AGARRES` en `objetos.tsx`): portátil con las dos patas en las esquinas de la base y la pantalla visible; libro abierto sujeto por abajo mientras lee; mando con una pata en cada empuñadura; móvil en una pata junto a la cara, mirándolo; lupa por el mango, con el cristal frente al ojo; bombilla flotando sobre la cabeza mientras la señala. Los brazos, la mirada y la cabeza van solos a la postura de agarre. **Un objeto nuevo necesita su agarre definido y comprobado en una imagen antes de usarlo.** También tiene sombrero pirata, cascos y carta (`pose.sombrero`, `pose.cascos`, `pose.carta`).
- Aparece en el gancho y reacciona en los momentos clave.
- Pasa de una pose a otra con un muelle (`mezclarPoses`). Nyxar y el fondo viven **fuera** de las transiciones para no cortarse.
- Retrato transparente: `public/marca/nyxar.png` (composición `RetratoNyxar`).
- **Expresiones** (`expresion` en `Nyxar`): `normal`, `feliz`, `sorprendido`, `enfadado`, `pensativo`, `guino` y `triste`. **Nyxar es un gato: no tiene cejas.** Las emociones se muestran como en un gato real: orejas (hacia atrás al enfadarse, caídas de tristeza, levantadas de sorpresa), pupilas (finas de enfado, grandes y redondas de sorpresa o tristeza), párpados y boca.
- **Expresiones en los videos:** cada escena elige la que encaja con lo que se cuenta. Como guía: `sorprendido` en el gancho, `pensativo` en el giro ("lo curioso es…"), `enfadado` o `triste` cuando se habla de algo malo (errores, riesgos, pérdidas), `feliz` en el remate y en la firma, y `guino` para un chiste o un truco. La expresión cambia a la vez que la pose.
- **Sprites** en `public/marca/sprites/` (paquete: `public/marca/sprites-nyxar.zip`): PNGTuber (7 expresiones × boca cerrada/abierta × ojos abiertos/cerrados, alineados), caras, 12 poses, hoja de personaje, stickers 512×512 (PNG y WebP) y pixel art (caras, poses y 5 animaciones en tiras con JSON y GIF). Se regeneran con la composición `SpritesNyxar` (lista en `src/personajes/sprites.json`) y `scripts/sprites-nyxar.py`.

## Color
| Nombre | Hex | Uso |
|---|---|---|
| Noche | `#071733` → `#020814` | Fondo, en degradado radial |
| Pelaje | `#6B4FB3` | Luces de ambiente, sombras de color |
| Menta neón | `#5EE7C4` | Brillos, palabra clave, cifras. Solo una cosa a la vez |
| Cascabel | `#FFB547` | Dinero, récords, premios |
| Pañuelo | `#C2334D` | Errores, peligro, "prohibido" |
| Hueso | `#F1F5FF` | Texto, palabra que suena |

Proporción aproximada: 62 % noche, 20 % pelaje, 10 % hueso, 5 % menta, 2 % cascabel y 1 % pañuelo.

## Tipografía
- **Baloo 2 ExtraBold**: gancho y títulos de escena, con una etiqueta pequeña en mayúsculas encima ("1 · LA IMPRENTA").
- **Lexend**: subtítulos. Palabras ya dichas en Light al 45 %; la que suena en SemiBold blanco.
- **JetBrains Mono Bold**: cifras y datos (`tabular-nums`), en menta o cascabel con brillo suave.
- Paquetes: `@fontsource/baloo-2`, `@fontsource/jetbrains-mono` (añadir `@fontsource/lexend`). Esperar a las fuentes con `delayRender`.

## Composición (vertical 1080×1920)
- **Subtítulos:** arriba, al 17 % de la altura, dentro de una caja oscura translúcida (`#020814` al ~72 %) con borde menta fino y esquinas de 12-16 px. Una o dos líneas, máximo 5 palabras.
- **Palabra clave:** una por frase como mucho, con un **subrayado de rotulador menta** detrás (ligeramente torcido) que entra de izquierda a derecha.
- **Objeto protagonista:** en el centro, formas planas con contorno de color que brilla y late, como la célula. Nada de fotos ni personas reconocibles.
- **Firma:** bolita morada + `@ithnoir`, arriba a la izquierda, al 55 % de opacidad.
- **Zonas prohibidas** (las tapa TikTok): el 19 % inferior y el 15 % derecho desde la mitad hacia abajo.

## Cortes y ritmo
- Duración: **35–50 s**. Si el tema da para más, se divide en Parte 1 y Parte 2.
- Estructura: **gancho** (0–2 s), **contexto** (2–14 s), **giro** (14–28 s), **remate** (28–38 s), **pregunta** (38–45 s) y **firma**.
- Gancho: pregunta o dato que choca, **nunca un saludo**. El texto está en pantalla desde el primer fotograma, sin fundido de entrada.
- Un corte por frase; planos de 2,5–5 s. Voz a ~3 palabras por segundo, con frases cortas.

### Los primeros 2 segundos (la regla más importante)
Datos de los tres primeros videos: entre el 40 y el 60 % de la gente se va antes del segundo 2, y quien se queda aguanta más cuando sale Nyxar. Por eso:
1. **El dato más fuerte ya está en pantalla en el fotograma 0**: grande, terminado y con color de alerta (por ejemplo, "212 GB" en rojo pañuelo). Nada de contadores que empiezan en cero, fundidos o pantallas vacías.
2. **Nyxar ya visible y reaccionando en el fotograma 0** (sorpresa, brazos arriba), en un sitio llamativo (por ejemplo, `asomadoIzquierda`). No entra deslizándose en el gancho.
3. **Movimiento y sonido fuertes en el segundo 0**: golpe de zoom (+10 %) y un golpe grave junto con el cascabel, en los primeros 6 fotogramas.
4. **Frase de gancho corta, de 5-6 palabras**, que abra curiosidad y empiece a sonar antes de 0,3 s. El resto del dato va en la segunda frase.
5. **Pregunta final que divida opiniones** ("¿Vale la pena…? Sí o no 👇"), no una pregunta genérica.

## Fluidez (como el video de las células)
- **60 fps.** Las animaciones se calculan en segundos, no en fotogramas, para que no cambien de velocidad.
- **Todo respira:** las formas laten (±3 %), flotan y sus contornos ondulan. Nunca hay un fotograma totalmente quieto.
- **Fondo vivo:** 15–25 burbujas menta y moradas que suben despacio, al 5–10 % de opacidad.
- **Brillo neón** que late en un ciclo de 1,5 s en el objeto protagonista.
- **Entradas con muelle, salidas con fundido** de 0,5 s. Nada a velocidad constante.

## Motion graphics
| Efecto | Cuándo | Cómo |
|---|---|---|
| Zoom lento | Siempre | 1,00 → 1,06 a lo largo del plano |
| Golpe de zoom | Palabra clave | +8 % en 0,2 s, con frenado suave |
| Entrada de objetos | Cuando se nombran | Muelle con un pequeño pasado |
| Contador | Dinero, años, récords | Sube durante 0,8 s sobre una píldora oscura |
| Transición | Cambio de escena | Fundido cruzado de 0,5 s; barrido con desenfoque solo si cambia el tema |
| Partículas | Remate | Una ráfaga de chispas menta, una vez por video |

## Iconos (nunca emojis)
- **Nada de emojis en los videos** (ni ✓, ✗, flechas de texto ni símbolos del sistema). El usuario prefiere iconos creados por nosotros.
- Usar los iconos propios de `src/marca/iconos.tsx` (hoja: composición `HojaIconos`): descarga, mando, candado, estrella, huella, bien, mal, bombilla, moqueta e infinito.
- Estilo: relleno con un color de la marca, contorno oscuro `#1d1530` grueso y redondeado (como Nyxar) y un brillo blanco suave arriba a la izquierda. Lienzo de 100×100.
- Escudos y logos: nunca el logo oficial de un club, federación o marca. Si hace falta identificar un país, usar su escudo o bandera nacional (de dominio público) simplificado, como `EscudoPortugal` en `IcoCamiseta escudo`.
- Si un video necesita un icono que no existe, dibujarlo con ese mismo estilo y añadirlo a `iconos.tsx` y a `ICONOS`.

## Música y sonido
- **Voz** al frente; el video final se normaliza a **−14 LUFS** con `scripts/normalizar-audio.sh`.
- **Efectos** a ~−20 dB, uno por cada cosa que aparece y nunca dos a la vez. Subir los efectos flojos con `scripts/igualar-sfx.sh`.
- **Música:** sintetizador nocturno con curiosidad, sin letra, a ~−28 dB (volumen 0,05–0,07). Sube un poco en la firma.
- **Firma sonora:** **el cascabel de Nyxar**, en el gancho y en la firma final.
- Narración y efectos con ElevenLabs (`scripts/generar-audio.mjs`). El texto de la voz y las marcas de tiempo quedan en `tiempos.json`.
- Después de renderizar, comprobar el audio con Whisper y medir el volumen.

## Cierre
- Pregunta concreta para comentar, por ejemplo: "Comenta 🐾 si no lo sabías", o "Envíaselo a ese amigo que…".
- Firma de 2 s: Nyxar saludando, `@ithnoir` y el cascabel.
