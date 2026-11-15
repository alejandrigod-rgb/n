# Crónicas de Vael · RPG por turnos para Roblox

Juego original: un mundo de fantasía con combates por turnos en equipo. Tu grupo (tú y hasta 3 amigos) contra grupos de enemigos.

## Qué tiene
- **4 clases:** Guerrero, Maga, Arquero y Sanador. Cada una tiene 3 habilidades que se desbloquean por nivel.
- **Combate por turnos** en el servidor:
  - Orden de turnos según la velocidad. Tienes 20 s para elegir; si no eliges, tu héroe ataca solo.
  - Acciones: atacar, habilidades, objetos, defender y huir (del jefe no se puede).
  - Estados: veneno, escudo y furia.
  - Críticos y IA de los enemigos (a veces van a por el más débil).
- **Jugar con amigos:** al pisar una zona entran contigo los jugadores que estén cerca. Los que lleguen después pulsan el anillo dorado de la batalla ("Unirse al combate") y entran en la ronda siguiente. Los enemigos se hacen más fuertes con cada jugador.
- **Mundo:** se construye solo si el mapa está vacío.
  - Aldea con fuente curativa y mercader.
  - Pradera de Vael (nivel 1), Bosque Susurrante (nivel 3), Ruinas de Ceniza (nivel 5) y la Cueva del Rey Hongo (jefe, nivel 7).
- **Progresión:** experiencia, niveles, oro, botín y tienda. La partida se guarda con DataStore.
- **Interfaz fluida a 60 fps:**
  - Todo se anima con TweenService: menús con rebote, barras de vida con estela y números de daño flotantes.
  - La cámara de combate es cinematográfica (con franjas negras) y se mueve en RenderStepped, con suavizado y temblor en los críticos.

## Cómo montarlo en Roblox Studio

### Opción A: con Rojo (recomendada, se actualiza sola)
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

## Cómo se juega
1. Al entrar eliges clase.
2. **Fuente** (en la aldea): te cura del todo. **Mercader**: pociones (15 de oro) y éteres (25 de oro).
3. Pisa el círculo de color de una zona y empieza el combate.
4. Si pierdes, vuelves a la aldea con la vida llena y pierdes el 10 % del oro.

## Cambiar el juego
Todos los números están en `src/shared/Datos.luau`: clases, habilidades, enemigos, objetos, zonas, daño y experiencia.

Para tu propio mapa, crea una carpeta **MundoVael** en Workspace y pon partes con:
- el atributo `Zona` (pradera, bosque, ruinas o cueva),
- `Fuente = true`,
- `Mercader = true`.

Si existe esa carpeta, el juego no construye el mapa automático.
