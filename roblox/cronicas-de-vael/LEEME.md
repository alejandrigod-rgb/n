# Crónicas de Vael · RPG por turnos para Roblox

Juego original: un mundo de fantasía con combates por turnos en equipo. Tu grupo (tú y hasta 3 amigos) contra grupos de enemigos.

## Qué tiene
- **Estilo 2D de recortes de papel** (personajes y mundo propios):
  - Cámara de lado que sigue al jugador, como un juego 2D con un poco de fondo.
  - Todo el mundo está hecho de piezas planas con contorno negro.
  - Los personajes y monstruos son muñecos dibujados con la interfaz (`src/client/Munecos.luau`), sin imágenes. Respiran, dan saltitos al andar, parpadean, miran hacia donde van, se ponen rojos al recibir un golpe y caen al morir.
  - Tu avatar de Roblox se esconde y en su lugar sale el muñeco de tu clase.
- **4 clases:** Guerrero, Maga, Arquero y Sanador. Cada una tiene 3 habilidades que se desbloquean por nivel.
- **14 monstruos en 5 zonas:**

  | Zona | Monstruos |
  |---|---|
  | Pradera de Vael (nivel 1) | babosa, hongo saltarín, abeja y lobo |
  | Pantano Brumoso (nivel 2) | sapo, planta carnívora y fantasma |
  | Bosque Susurrante (nivel 3) | duende, araña y tronco furioso |
  | Ruinas de Ceniza (nivel 5) | esqueleto, murciélago y gólem |
  | Cueva (nivel 7, jefe) | el Rey Hongo con sus hongos |

- **Mapa con vida:**
  - La Ciudad de Vael: torre del reloj, herrería, panadería, taberna, posada, tienda de magia, fuente que cura, mercader, farolas, banderines y muralla.
  - Vecinos que pasean y hablan con bocadillos (dan pistas), y el mercader detrás de su puesto.
  - Un molino que gira, pasto y flores que se mecen (y se apartan al pasar), nubes que se mueven, niebla en el pantano, mariposas y luciérnagas.
  - Los monstruos de cada zona asoman junto a su guarida, y el Rey Hongo vigila la entrada de la cueva.
- **Combate por turnos** en el servidor:
  - Orden de turnos según la velocidad. Tienes 20 s para elegir; si no eliges, tu héroe ataca solo.
  - Acciones: atacar, habilidades, objetos, defender y huir (del jefe no se puede).
  - Estados: veneno, escudo y furia.
  - Críticos y IA de los enemigos (a veces van a por el más débil).
  - Escenario de lado: tu equipo a la izquierda y los monstruos a la derecha.
  - Efectos de dibujo animado: bolas de fuego, flechas con estela, rayos, cortes, curas, raíces, rocas y onomatopeyas ("¡ZAS!", "¡FUUM!", "¡ÑAM!").
- **Jugar con amigos:** al entrar en una guarida entran contigo los jugadores que estén cerca. Los que lleguen después pulsan el anillo dorado de la batalla ("Unirse al combate") y entran en la ronda siguiente. Los enemigos se hacen más fuertes con cada jugador.
- **Progresión:** experiencia, niveles, oro, botín y tienda. La partida se guarda con DataStore.
- **Interfaz de dibujo animado a 60 fps:**
  - Paneles con contorno grueso y adornos dorados, iconos dibujados y retratos animados de cada personaje.
  - Todo se anima con TweenService: menús con rebote, botones que se ladean, barras de vida con estela y números de daño de cómic.
  - La cámara se mueve en RenderStepped, con suavizado y temblor en los golpes.

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

## Cómo se juega
1. Al entrar eliges clase.
2. Muévete con WASD (A y D, izquierda y derecha; W y S, hacia el fondo y hacia delante) y salta con Espacio.
3. **Fuente** (en la plaza de la ciudad): te cura del todo. **Mercader**: pociones (15 de oro) y éteres (25 de oro).
4. Ve hacia la derecha. En cada zona, entra en la guarida del fondo (la mancha de color, con el cartel "¡Monstruos!") y empieza el combate. El camino de delante queda libre para pasar sin luchar.
5. Si pierdes, vuelves a la ciudad con la vida llena y pierdes el 10 % del oro.

## Cambiar el juego
Todos los números están en `src/shared/Datos.luau`: clases, habilidades, enemigos, objetos, zonas, daño y experiencia.

Para tu propio mapa, crea una carpeta **MundoVael** en Workspace y pon partes con:
- el atributo `Zona` (pradera, pantano, bosque, ruinas o cueva),
- `Fuente = true`,
- `Mercader = true`.

Si existe esa carpeta, el juego no construye el mapa automático.
