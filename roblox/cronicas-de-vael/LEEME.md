# Crónicas de Vael · RPG por turnos para Roblox

Juego original: un mundo de fantasía con combates por turnos en equipo. Tu grupo (tú y hasta 3 amigos) contra grupos de enemigos.

## La historia

Cada otoño, Vael celebra la **Fiesta del Gran Guiso**, que se remueve con el **Cucharón de Vael**. El ingrediente secreto son setas… y a las setas nadie les preguntó. Este año el **Rey Hongo** se hartó: robó el Cucharón y se lo puso de corona. Sin él, el guiso se pudre y sus esporas ponen rabiosos a los bichos del valle: por eso hay peleas por todas partes. Tú eres el nuevo de la Aldea de Brezo, y Vael no tiene a nadie más.

- **Prólogo animado** (`src/client/Portada.luau`): libro de cuentos de 6 láminas dibujadas y animadas. Sale al empezar una partida nueva (se puede saltar) y desde el botón **La historia** del menú.
- **Portada:** teatrillo de papel cuyo telón se abre; detrás, el valle animado (sol, nubes, montañas, el castillo-seta del Rey Hongo con el Cucharón de bandera, casas con humo, molino, globo, pájaros, banderines y la olla del Gran Guiso "¡APLAZADA!").
- **En el mundo:** la olla gigante fría en la plaza, el castillo-seta al fondo de la Cueva, la abuela y los vecinos hablan del Cucharón, y al ganar al Rey Hongo hay final.
- **Fondo vivo** (`fondoVivo` en `Mundo.luau`): barrio alto y castillo del alcalde detrás de la muralla, campos y vacas, granjas con humo, globos, pájaros, árboles muertos y cabaña en el pantano, filas de pinos, columnas y cabeza de estatua en las ruinas. El cliente anima los atributos `Nube`, `Gira`, `Flota` y `Humo`.
- **Epílogo animado:** 5 láminas (el Rey Hongo cae, la fiesta con fuegos artificiales, las setas también comen, el brindis y un "FIN… ¿o no?"). Sale la primera vez que ganas al Rey Hongo y luego desde el botón **Epílogo** del menú.
- **Compañeros** (`Datos.Companeros`): Tomás (guerrero, al limpiar el Huerto), Lucas (arquero, al devolverle la pelota) y Fermín (sanador, al darle las 3 setas). Pelean a tu lado con su propia IA (Fermín cura al más herido). Se elige uno en la mochila (B) o **Ir solo**.
- **Repetir pelea:** si pisas otra vez una guarida que ya limpiaste, te pregunta "¿Quieres repetir la pelea?" (Sí / No).
- **Ambiente por zona** (`Escena.luau`, local): el Callejón se oscurece con viñeta y luces que fallan, el Pantano se pone verdoso, el Bosque y la Cueva más fríos, y la taberna y la posada cálidas.
- **Callejón con miedo de verdad:** edificios altos al fondo con ventanas que parpadean, luna, cables, tendederos, ojos amarillos en los huecos oscuros, carteles de "se busca", charcos, cajas, una rata y niebla oscura.
- **Más detalle:** el Mercado tiene tiendas detrás, torre del reloj, globo, banderines y farolillos; la taberna, trofeo de babosa, diana, lámpara que se balancea, jamones y un gato junto al fuego; la posada, cuadro del Gran Guiso, reloj, estantería y velas.
- **8 secretos** (`SECRETOS` en `Principal.server.luau`): el gato morado del Callejón, la puerta del NO, la olla del Gran Guiso, la puertecita del Bosque, el pato de goma del Pantano, la piedra con cara de las Ruinas y los dos bordes del mundo. Cada uno da 5 de oro; todos juntos, la Corona de cartón.
- **Menú:** solo suenan la música y los botones.
- **Peleas obligatorias** (`guardianes` en `Principal.server.luau`): cada objeto clave tiene guardianes. Las babosas del almacén de Bruno (cuerda), el sapo del cofre del Pantano (hacha), los duendes que persiguen las setas de Fermín (llave) y los esqueletos de la cripta (farol). Si pierdes, se puede repetir.
- **Rocas rompibles:** en combate, "Atacar" y las habilidades de daño pueden apuntar a una roca a tu alcance y romperla (¡CRAC!). Las habilidades en cruz rompen también las de al lado, y el torbellino las que tienes pegadas. A veces dentro hay una poción o 5 monedas.
- **Letra de los diálogos:** Patrick Hand (`Ui.FuenteDialogo`), más fácil de leer que la de rotulador.

### Historia 2: «La Olla Congelada» (tres años después)

Al ganar al Rey Hongo: **animación de victoria a pantalla completa** (el héroe salta y levanta el Cucharón), el epílogo y un **subepílogo "Tres años después"** (el Rey Hongo es ahora cocinero y el Yeti Tragón se lleva la Olla del Gran Guiso). Te despiertas en casa **con barba**: hasta pasar por el **barbero Paco** (ciudad) y darte un **baño** en la posada no puedes pelear. Después, el Rey Hongo te da las **botas de nieve**, cruzas a los **Picos Nevados** (pingüinos bandidos, muñecos de nieve, lobos de la ventisca y espíritus de escarcha), consigues el **pico de hielo** peleando contra los pingüinos y subes a la **Cumbre** a por el **Yeti Tragón**. Final con victoria, la Olla y un epílogo de 4 láminas. En el menú: botones **Epílogo** y **Final 2**.

### v1.7
- **El héroe se gira al caminar:** de lado al ir a izquierda o derecha, de frente al venir hacia la cámara y de espaldas al alejarte (se ve la mochila). Quieto un rato, se pone de frente; en combate y en el aire, de lado. Son tres muñecos (`ap.vista` = "frente", "lado" o "espalda") que `Escena` cambia según la velocidad.
- **Tablón de encargos** en la plaza (`Encargos.luau`, `Datos.Encargos`): 14 misiones secundarias (cazar monstruos, ganar peleas en una zona, romper rocas, encontrar secretos, entregar pociones), hasta 3 a la vez, con oro, EXP, objetos y mejoras. Dos se desbloquean tras la primera historia.
- **Más sonido:** fanfarria al ganar, otra más grande al vencer a un jefe, entrada dramática de los jefes ("¡JEFE FINAL!") y un cartel con música al llegar a cada zona ("¡Zona nueva!" la primera vez). `Audio.jingle` encadena los efectos que ya hay.

### v1.8: equipamiento y tienda
- **Herrería de Olga** (ciudad): al hablar con ella eliges "Armas y armaduras" o "Rarezas (mejoras)". La armería (`Armeria.luau`) tiene dos pestañas: **Comprar** (solo lo de tu clase, con nivel mínimo y precio) y **Mejorar lo mío** (+1, +2 y +3; cada una da un 35 % más).
- **19 piezas** (`Datos.Equipo`): 2–3 armas por clase, el Cucharón de combate (para todos), 4 armaduras y 5 amuletos. Cada clase empieza con su arma de madera.
- **En la mochila (B)**, sección **Equipo**: pulsas una pieza para ponértela o quitártela. Las estadísticas se suman en combate (`Datos.bonosEquipo` → `Datos.statsDe`).
- **Se ve en el muñeco** (en las tres vistas): el arma por su forma (espada, hacha, bastón, cucharón; el arco cambia de color), la armadura con su color y hombreras, y el amuleto colgado del cuello.

### v1.9: cooperativo
- **Las Bodegas del Gran Guiso** (mazmorra de oleadas): trampilla en la plaza. El primero abre una sala de espera de 10 s y los demás se apuntan pulsando la trampilla (hasta 4). Abajo, **5 oleadas** seguidas con un respiro del 35 % entre ellas; tras la primera historia, las oleadas traen bichos de los Picos. Premio: +150 de oro y un cofre de mejoras. Se guarda el **récord de oleada**.
- **Regalar** (mochila): una poción o un éter (botón "Regalar" en el objeto) o 10 de oro (botón arriba), a cualquier jugador del servidor.
- **Emotes** (tecla **G** o el botón del corazón): saludar, bailar, reír, aplaudir, enfadarse, dormir y "¡A pelear!". Todos los ven, con bocadillo y animación.
- **Clasificación** (pausa → Clasificación): los del servidor (nivel, victorias y récord de oleada) y el top 10 de todos los servidores (OrderedDataStore `VaelVictorias_v1`). La lista de jugadores de Roblox enseña **Nivel** y **Victorias** (leaderstats).

### v2.0: música por zona y vecinos con memoria
- **8 canciones nuevas** en `audio/` (`herramientas/generar-audio.py zonas`): aldea (vals tranquilo), pantano (fagot y ranas), bosque (arpa misteriosa), ruinas (tambores antiguos), picos (celesta y cascabeles), callejón (sigilosa, con maullido), taberna (giga con kazoo) y bodegas (tensa, para las oleadas). Hay que subirlas y pegar sus ids en `Sonidos.IDS`; mientras tanto, cada zona usa una de las 4 de antes con otro tempo (`RESERVA` en `Audio.luau`).
- **Los vecinos se acuerdan de lo que has hecho** (`etapa`/`segunEtapa` en el servidor, `FRASES_ETAPA` y `CONVERSACIONES_ETAPA` en `Escena`): el granjero Tomás, la abuela, Bruno, la posadera, Lucas, el guardia, el frutero y el sastre cambian lo que dicen según en qué punto de la historia vas (huerto limpio, cuerda, final, barba, Yeti…), y las charlas entre vecinos también.

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
| … → **Portada** | ModuleScript | `src/client/Portada.luau` |
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
