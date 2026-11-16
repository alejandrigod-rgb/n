# Crónicas de Vael · RPG por turnos para Roblox

Juego original: un mundo de fantasía con combates por turnos en equipo. Tu grupo (tú y hasta 3 amigos) contra grupos de enemigos.

## Teclas
| Tecla | Qué hace |
|---|---|
| A / D (W / S) | Andar (hacia el fondo o hacia delante) · **Mayús** para correr |
| Espacio | Saltar |
| **E** | Hablar, abrir, entrar… (sale un aviso de cartulina propio encima de la persona o el objeto) |
| **M** | Abrir y cerrar el mapa |
| **B** | Abrir y cerrar la mochila |
| **P** | Pausa (también el botón pequeño de arriba a la derecha) |
| C · Q/E · rueda | En combate: cambiar de vista, girar la cámara y acercarla |

## Idiomas (localización oficial de Roblox)
- La tabla de traducciones es `src/localizacion/Textos.csv`. Rojo la convierte en un **LocalizationTable** dentro de **LocalizationService**. Se genera con `python3 herramientas/textos.py`: para añadir un texto, se añade una fila en ese archivo y se vuelve a ejecutar.
- Idiomas: español, inglés, portugués, francés y alemán. Al empezar se usa el idioma de la cuenta de Roblox (si es uno de los cinco); se cambia en **Configuración → Idioma** y se guarda con la partida.
- Funciona con `Translator:Translate` (por el texto original en español) y `FormatByKey` (`src/client/Idioma.luau`). Los textos fijos de la interfaz se traducen solos al crearse (`Ui.crear`). Los nombres propios (Bruno, Rosa, Vael…) no se traducen.
- Lo que aún no está en la tabla se ve en español. Para que Roblox complete el resto: Creator Hub → tu experiencia → **Localización** → activa la **traducción automática** y la captura de textos.

## Qué tiene
- **Menú de inicio** (script propio, `src/client/Menu.client.luau`) con Jugar, Mi personaje, Cómo se juega, Ajustes (volumen) y Créditos. **Menú de pausa** durante la partida: botón «Menú» arriba a la derecha o tecla **M** (Continuar, Mi personaje, Ajustes, Cómo se juega, Volver al inicio).
- **Cuadro de errores y versión** (`src/client/Diagnostico.client.luau`): abajo a la derecha sale la versión (por ejemplo "v0.7"); si algo falla, un cuadro rojo abajo a la izquierda enseña el error (en Studio, también los del servidor). Con una captura basta para arreglarlo.
- **Mapa de papel dibujado** (`src/client/MapaVael.luau`, tecla **M**): zonas, caminos, el río, las calles de la ciudad, sitios importantes, candados en los caminos cerrados, paraderos (!), la misión (estrella) y tú. No ocupa la pantalla: se abre y se cierra con M.
- **Misión actual**: una franja pequeña debajo del HUD con lo que toca hacer.
- **Mochila** (`src/client/Mochila.luau`, tecla **B**): mochila de cartón con tu héroe, casillas de objetos (se pueden usar), objetos clave y mejoras; al elegir una casilla salen su nombre y descripción.
- **Diálogos de cine**: franja abajo, retrato grande, nombre en una pestaña, texto grande que se escribe solo (clic para terminarlo) y flecha para continuar. Mientras se habla, el HUD y los botones se esconden.
- **Indicador de interacción propio** (`src/client/Interaccion.luau`): tarjeta de cartulina con la tecla E y la acción; sustituye al aviso gris de Roblox (los ProximityPrompt van con `Style = Custom`).
- **Calles con cruces**: desde la ciudad, los arcos llevan a la **Calle del Mercado** (frutero, sastre que cambia tu look, el niño Lucas y su misión, un cofre escondido) y al **Callejón del Gato** (gatos, la adivina Madame Zoé y la pelota de Lucas).
- **Aldea de Brezo** (nueva, a la izquierda de la ciudad): aquí se empieza. Tu casa, la abuela Rosa (cuenta la historia y da pistas), el granjero Tomás y el **Huerto invadido** (primera guarida, muy fácil).
- **Interiores:** taberna (con clientes) y **posada** (camas y la posadera Lola, que te deja dormir).
- **Emboscadas:** andando por las zonas salvajes, a veces saltan monstruos y atacan primero. **Carro asaltado:** un comerciante pide ayuda y paga si lo defiendes.
- **Cámara del combate:** botón «Cámara» o tecla C (lateral, desde arriba, cerca), girar con Q/E o arrastrando con el botón derecho, acercar con la rueda.
- **Animaciones del personaje:** se inclina al correr y mueve los brazos, se estira al saltar, encoge las piernas al caer y se aplasta al aterrizar. Lleva **mochila**.
- **Más charla:** los vecinos se paran a hablar entre ellos, los monstruos sueltan frases y los héroes celebran al ganar.
- **Crea a tu héroe** (`src/client/Editor.luau`): piel, pelo (7 peinados) y su color, ojos (5 estilos) y su color, color de la ropa, gorro (7: el de tu clase, de lana, vaquero, corona de cartón, gorra, chistera…), accesorio gracioso (gafas, bigote, tirita, parche, pato en la cabeza, pajarita…) y nombre del héroe (pasa por el filtro de texto de Roblox). Se abre al elegir clase y se cambia cuando quieras desde el menú.
- **Estilo cartulina recortada** (propio): colores apagados, textura de cartón (material Cardboard), sin neón, sin resplandores ni degradados, contornos marrón oscuro, letra de rotulador y chinchetas en los paneles.
- **Estilo 2D de recortes** (personajes y mundo propios):
  - Cámara de lado, como un juego 2D con un poco de fondo. Sube contigo cuando saltas a las plataformas.
  - El mundo está hecho de piezas planas con contorno negro.
  - Los personajes y monstruos son muñecos dibujados con la interfaz (`src/client/Munecos.luau`), sin imágenes. Respiran, dan saltitos al andar, parpadean, se ponen rojos al recibir un golpe y caen al morir.
- **Exploración (estilo metroidvania):** hay cuatro caminos cerrados y cada uno se abre con un objeto clave que se consigue sin pelear.

  | Paso cerrado | Objeto que lo abre | Cómo se consigue |
  |---|---|---|
  | Puente roto del río (hacia el Pantano) | Cuerda | Gana dos veces seguidas al **juego de los vasos** en la taberna |
  | Zarzas (hacia el Bosque) | Hacha | Sube por las **tablas del Pantano** hasta el cofre de arriba |
  | Puerta de piedra (hacia las Ruinas) | Llave de piedra | Lleva al **ermitaño** las 3 setas brillantes escondidas en el Bosque |
  | Oscuridad (hacia la Cueva) | Farol | Tira de las **3 palancas** de las Ruinas (una está arriba) y abre el cofre de la cripta |

- **Ciudad con vida:**
  - **Taberna El Hongo Feliz** (se entra por la puerta): Bruno, el tabernero, el juego de los vasos, guiso que cura y rumores con pistas.
  - **Posada:** duermes por 10 de oro, te curas del todo y se guarda la partida.
  - **Herrería de Olga:** vende mejoras de hierro.
  - **Mercader:** pociones y éteres. **Fuente:** cura gratis.
  - Vecinos que pasean y hablan con bocadillos y "voz" de pitiditos.
- **Paraderos aleatorios por el camino** (cada minuto y pico aparece algo en una zona): hoguera de viajeros, cofre sospechoso (a veces es un **cofre mímico** que muerde), pozo de los deseos, viajero perdido y, muy de vez en cuando, el **vendedor sospechoso**, que vende mejoras raras.
- **Combate táctico por casillas** (en todas las peleas), en un campo de 10 × 4:
  - En tu turno **te mueves** por las casillas verdes y luego haces una acción: atacar, habilidad, objeto, defender o huir.
  - **Alcance:** cuerpo a cuerpo o a distancia (las casillas a tiro se pintan de rojo). Detrás de una roca en tu misma fila, los disparos hacen la mitad.
  - **Empujones:** algunos golpes empujan. Si el monstruo choca con una roca, el borde u otro: ¡CATAPLÁN! y daño extra.
  - **Trampas:** pinchos (daño), barro (te para) y setas (curan). Los obstáculos cambian según la zona.
  - Los monstruos se mueven, van a por el más débil o el más cercano, evitan las trampas y sueltan frases.
- **Mejoras estilo roguelike** (23 y 5 combinaciones): se consiguen en **cofres** tras ganar (40 %), del **jefe** (siempre, más raras), del vendedor sospechoso, del pozo y de la herrería. Se suman y algunas se combinan: Calcetín sudado y Huevo podrido dan **¡Olor mortal!**, Chicle pegajoso y Muelle de colchón dan **¡Bola de pinball!**, etc. Se ven todas en la mochila, debajo de la vida.
- **4 clases:** Guerrero, Maga, Arquero y Sanador, cada una con su movimiento, alcance y 3 habilidades.
- **15 monstruos en 5 zonas:**

  | Zona | Monstruos |
  |---|---|
  | Pradera de Vael (nivel 1) | babosa, hongo saltarín, abeja y lobo |
  | Pantano Brumoso (nivel 2) | sapo, planta carnívora y fantasma |
  | Bosque Susurrante (nivel 3) | duende, araña y tronco furioso |
  | Ruinas de Ceniza (nivel 5) | esqueleto, murciélago y gólem |
  | Cueva (nivel 7, jefe) | el Rey Hongo con sus hongos |
  | Paraderos | el cofre mímico |

- **Jugar con amigos:** al entrar en una guarida entran contigo los jugadores que estén cerca. Los demás ven el aviso "Unirse al combate" (los que ya luchan no) y entran en la ronda siguiente.
- **Música y efectos originales** (carpeta `audio/`): 4 canciones (ciudad, aventura, combate y jefe) y 31 efectos (pasos de cartón, saltos con muelle, golpes, "¡cataplán!", fanfarria de victoria, trombón triste al perder, voz de pitiditos…). Se generan con `herramientas/generar-audio.py`.
- **Progresión:** experiencia, niveles, oro, botín, mejoras y objetos clave. Todo se guarda con DataStore.

## Poner la música y los efectos (una vez, unos 5 minutos)
Roblox solo deja usar sonidos subidos a tu cuenta:
1. En Studio: **Ventana → Gestor de recursos** (Asset Manager) → botón **Importación masiva** (Bulk Import).
2. Elige los 5 archivos de la carpeta `audio/`.
3. Cuando terminen de subirse, aparecen en la carpeta **Audio** del gestor. Clic derecho en cada uno → **Copiar ID del recurso**.
4. Pega cada número en `src/shared/Sonidos.luau`, entre las comillas: `efectos = "rbxassetid://NÚMERO"`, y lo mismo con `ciudad`, `aventura`, `combate` y `jefe`.
5. Guarda el archivo. Si tienes `rojo serve` abierto, se actualiza solo en Studio.

Las cuentas sin verificar pueden subir pocos audios al mes; por eso todos los efectos van en un solo archivo.

## Cómo montarlo en Roblox Studio

### Cómo poner una versión nueva
Cuando el código cambie en GitHub:
1. Vuelve a bajar el ZIP de la rama.
2. Sustituye tu carpeta `cronicas-de-vael` por la nueva.
3. En PowerShell, para `rojo serve` con `Ctrl + C` y arráncalo otra vez desde la carpeta nueva.
4. En Studio, Rojo → *Connect* → *Accept*.

### Opción A: con Rojo (recomendada)
1. **Instala Rokit** (gestor de herramientas):
   - Windows: abre PowerShell y pega `Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression`.
   - Mac: en Terminal, `curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash`.
2. **En la carpeta de este proyecto**, ejecuta `rokit install` (instala la versión de Rojo fijada en `rokit.toml`).
3. **En Roblox Studio**, instala el plugin de Rojo: menú *Plugins* → busca "Rojo" en la tienda, el de *rojo-rbx*.
4. **Abre un lugar nuevo** (plantilla *Baseplate*).
5. En la carpeta del proyecto, ejecuta `rojo serve`. En Studio pulsa el plugin de Rojo → *Connect*.
6. Activa el guardado: *Game Settings* → *Security* → **Enable Studio Access to API Services**.
7. Pulsa **Play**. Para probar con amigos en Studio usa *Test* → *Clients and Servers* → 2-4 jugadores.

Para tener un archivo ya montado: `rojo build -o CronicasDeVael.rbxlx` y ábrelo con Studio.

### Opción B: copiar a mano
En Studio, crea estas carpetas y scripts con el mismo nombre y pega el código de cada archivo:

| En Studio | Tipo | Archivo |
|---|---|---|
| ReplicatedStorage → Folder **Vael** → **Datos** | ModuleScript | `src/shared/Datos.luau` |
| ServerScriptService → Folder **VaelServidor** → **Principal** | Script | `src/server/Principal.server.luau` |
| … → **Combate** | ModuleScript | `src/server/Combate.luau` |
| … → **DatosJugador** | ModuleScript | `src/server/DatosJugador.luau` |
| … → **Mundo** | ModuleScript | `src/server/Mundo.luau` |
| StarterPlayer → StarterPlayerScripts → Folder **VaelCliente** → **Principal** | LocalScript | `src/client/Principal.client.luau` |
| … → **Ui** | ModuleScript | `src/client/Ui.luau` |
| … → **Munecos** | ModuleScript | `src/client/Munecos.luau` |
| … → **Escena** | ModuleScript | `src/client/Escena.luau` |
| … → **Efectos** | ModuleScript | `src/client/Efectos.luau` |
| … → **Audio** | ModuleScript | `src/client/Audio.luau` |
| … → **Editor** | ModuleScript | `src/client/Editor.luau` |
| … → **Menu** | LocalScript | `src/client/Menu.client.luau` |
| … → **MapaVael** | ModuleScript | `src/client/MapaVael.luau` |
| … → **Mochila** | ModuleScript | `src/client/Mochila.luau` |
| … → **Interaccion** | ModuleScript | `src/client/Interaccion.luau` |
| … → **Idioma** | ModuleScript | `src/client/Idioma.luau` |
| LocalizationService → **Textos** | LocalizationTable | `src/localizacion/Textos.csv` (en Studio: Importar CSV) |
| … → **Diagnostico** | LocalScript | `src/client/Diagnostico.client.luau` |
| ServerScriptService → VaelServidor → **Eventos** | ModuleScript | `src/server/Eventos.luau` |
| ReplicatedStorage → Vael → **Sonidos** | ModuleScript | `src/shared/Sonidos.luau` |

## Cómo se juega
1. Pulsa **¡Jugar!** en el menú y elige clase.
2. Muévete con WASD (A y D, izquierda y derecha; W y S, al fondo y hacia delante) y salta con Espacio. Habla y usa cosas con **E**.
3. **Fuente** y **Posada** (en la ciudad) te curan. **Mercader**: pociones y éteres. **Herrería**: mejoras.
4. Ve hacia la derecha. En cada zona, la guarida del fondo (mancha de color y cartel "¡Monstruos!") empieza un combate. El camino de delante está libre.
5. En combate: pulsa una **casilla verde** para moverte y luego elige una acción. Para atacar, pulsa al enemigo en rojo (o su botón).
6. Para pasar a la zona siguiente necesitas su objeto clave (mira la tabla de arriba). Los rumores de la taberna dan pistas.
7. Si pierdes, vuelves a la Aldea de Brezo con la vida llena y pierdes el 10 % del oro.

## Cambiar el juego
Todos los números están en `src/shared/Datos.luau`: clases, habilidades, enemigos, objetos, zonas, daño y experiencia.

Para tu propio mapa, crea una carpeta **MundoVael** en Workspace y pon partes con:
- el atributo `Zona` (pradera, pantano, bosque, ruinas o cueva),
- `Fuente = true`,
- `Mercader = true`.

Si existe esa carpeta, el juego no construye el mapa automático.

## Probar sin Studio (simulador)
`herramientas/simulador/probar.sh` ejecuta el cliente y el servidor en un "Roblox de mentira" hecho en Luau. Comprueba cada propiedad, evento y enum contra la API oficial de Roblox y simula una partida: menú, clase, editor, HUD, teclas M/B/P, idioma, diálogos, vasos, cofres, tiendas, todos los avisos del mapa, combates, eventos y emboscadas. Cualquier error sale como `ERROR:`. No sustituye a probar en Studio (no hay física ni dibujo), pero detecta los fallos que rompen los scripts.
