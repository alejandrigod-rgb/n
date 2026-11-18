-- Prueba del cliente: monta el árbol como Rojo, arranca los LocalScripts y simula una partida.
local RT = BASE.RT
local E = BASE.E
local I = E.Instance
RT.esCliente = true

local RS = RT.servicio("ReplicatedStorage")
local vael = I.new("Folder")
vael.Name = "Vael"
vael.Parent = RS
BASE.modulo("Datos", vael, FUENTES["shared/Datos.luau"])
BASE.modulo("Sonidos", vael, FUENTES["shared/Sonidos.luau"])
local remotos = I.new("Folder")
remotos.Name = "Remotos"
for _, n in { "ElegirClase", "EstadoJugador", "BatallaInicio", "BatallaEstado", "BatallaEvento", "BatallaTurno", "PedirAccion", "EnviarAccion", "BatallaFin", "Notificar", "AbrirTienda", "Comprar", "OfrecerMejoras", "ElegirMejora", "AbrirVendedor", "ComprarMejora", "Dialogo", "ElegirOpcion", "Vasos", "ElegirVaso", "Teletransporte", "Sonido", "GuardarApariencia", "ErrorServidor", "Emboscada", "AbrirEditor", "UsarObjeto", "GuardarAjustes", "Epilogo", "ElegirCompanero", "Final2", "Despertar", "AbrirTablon", "AceptarEncargo", "EntregarEncargo", "AbrirArmeria", "ComprarEquipo", "MejorarEquipo", "Equipar" } do
	local r = I.new("RemoteEvent")
	r.Name = n
	r.Parent = remotos
end
remotos.Parent = vael

local cam = I.new("Camera")
E.workspace.CurrentCamera = cam
cam.Parent = E.workspace

local Players = RT.servicio("Players")
local jugador = I.new("Player")
jugador.Name = "kilonil"
jugador.DisplayName = "kilonil"
jugador.UserId = 1
jugador.Parent = Players
rawset(Players.__props, "LocalPlayer", jugador)
local pg = I.new("PlayerGui")
pg.Parent = jugador
local ps = I.new("PlayerScripts")
ps.Parent = jugador
BASE.modulo("PlayerModule", ps, "local c = {} function c:Enable() end function c:Disable() end return { GetControls = function() return c end }")

-- scripts del cliente (como en Rojo: StarterPlayerScripts.VaelCliente)
local carpeta = I.new("Folder")
carpeta.Name = "VaelCliente"
carpeta.Parent = ps
local locales = {}
for ruta, fuente in FUENTES do
	local nombre = string.match(ruta, "^client/(.+)%.luau$")
	if nombre then
		local esLocal = string.match(nombre, "%.client$") ~= nil
		local limpio = string.gsub(nombre, "%.client$", "")
		local s = BASE.modulo(limpio, carpeta, fuente, esLocal and "LocalScript" or "ModuleScript")
		if esLocal then table.insert(locales, s) end
	end
end
-- personaje con cuerpo (como en Roblox)
local ch = I.new("Model")
ch.Name = "kilonil"
local hrp = I.new("Part")
hrp.Name = "HumanoidRootPart"
hrp.Position = E.Vector3.new(-395, 3, 2)
hrp.Parent = ch
local hum = I.new("Humanoid")
hum.Parent = ch
local cabeza = I.new("Part")
cabeza.Name = "Head"
cabeza.Parent = ch
local cara = I.new("Decal")
cara.Name = "face"
cara.Parent = cabeza
ch.PrimaryPart = hrp
ch.Parent = E.workspace
jugador.Character = ch
-- mundo mínimo para la escena
local mundo = I.new("Folder")
mundo.Name = "MundoVael"
local pasto = I.new("Folder")
pasto.Name = "Pasto"
pasto.Parent = mundo
local barrera = I.new("Model")
barrera:SetAttribute("Llave", "cuerda")
barrera:SetAttribute("Estado", "cerrado")
barrera:SetAttribute("MuroX", 163)
barrera.Parent = mundo
local npc = I.new("Part")
npc:SetAttribute("Punto", "tabernero")
npc:SetAttribute("Npc", "vecino:1984")
npc:SetAttribute("Frases", "Hola|Adiós")
npc.Position = E.Vector3.new(-100, 202.8, -9)
npc.Parent = mundo
mundo.Parent = E.workspace
for _, s in locales do
	BASE.ejecutar(s)
end
jugador.CharacterAdded:Fire(ch)

local function informe(titulo)
	print("==== " .. titulo .. " (t=" .. string.format("%.1f", RT.ahora()) .. ")")
	for _, e in RT.errores do print("ERROR: " .. e) end
	for _, a in RT.avisos do print("AVISO: " .. a) end
	RT.errores = {}
	RT.avisos = {}
end
local function buscarTexto(raiz, texto)
	for _, d in raiz:GetDescendants() do
		if (d:IsA("TextButton") or d:IsA("TextLabel")) and string.find(d.Text, texto, 1, true) then return d end
	end
	return nil
end
local function boton(texto)
	local b = buscarTexto(pg, texto)
	while b and not b:IsA("TextButton") do b = b.Parent end
	return b
end
local function pulsar(texto)
	local b = boton(texto)
	if not b then print("  (no encuentro el botón '" .. texto .. "')") return end
	b.Activated:Fire()
	RT.avanzar(1.5)
end

RT.avanzar(3)
hrp.AssemblyLinearVelocity = E.Vector3.new(10, 5, 0)
RT.avanzar(2)
informe("arranque")
print("ScreenGuis:")
for _, g in pg:GetChildren() do print("  " .. g.Name .. " (" .. #g:GetDescendants() .. " piezas)") end
print("Atributos:", jugador:GetAttribute("EnMenu"), jugador:GetAttribute("CargadoPrincipal"), jugador:GetAttribute("CargadoMenu"))

-- estado sin clase (jugador nuevo)
local estado = { clase = nil, nivel = 1, xp = 0, xpSiguiente = 25, oro = 20, objetos = { pocion = 3, eter = 1 }, hp = 0, maxHp = 0, mp = 0, maxMp = 0, enBatalla = false, mejoras = {}, sinergias = {}, llaves = {}, setas = {}, palancas = {}, apariencia = nil, creado = false, nombreHeroe = "" }
remotos.EstadoJugador.OnClientEvent:Fire(estado)
RT.avanzar(2)
informe("estado sin clase")
print("¿Botón Nueva partida?", boton("Nueva partida") ~= nil)
pulsar("Nueva partida")
RT.avanzar(2)
-- el prólogo (6 láminas): se pasa entero para probar todos los dibujos
print("¿Prólogo?", buscarTexto(pg, "Siguiente") ~= nil)
for _ = 1, 14 do
	if boton("Siguiente") then pulsar("Siguiente") end
end
RT.avanzar(2)
print("¿Prólogo cerrado?", boton("Siguiente") == nil)
informe("tras pulsar Jugar")
print("¿Selector de clase?", buscarTexto(pg, "Elige tu clase") ~= nil)
pulsar("¡Elegir!")
informe("tras elegir clase")

-- el servidor manda el estado con clase
jugador:SetAttribute("Clase", "guerrero")
estado.clase = "guerrero"
estado.hp, estado.maxHp, estado.mp, estado.maxMp = 120, 120, 20, 20
estado.companeros = { tomas = true }
estado.armas = { espadaMadera = 1, cotaMalla = 0, cascabel = 0 }
estado.equipo = { arma = "espadaMadera", armadura = "cotaMalla", amuleto = "cascabel" }
jugador:SetAttribute("Apariencia", RT.servicio("HttpService"):JSONEncode({ piel = 2, pelo = 3, barba = true, eq = { arma = "hachaLenador", armadura = "cotaMalla", amuleto = "cascabel" } }))
jugador:LoadCharacter()
estado.companero = "tomas"
remotos.EstadoJugador.OnClientEvent:Fire(estado)
RT.avanzar(3)
informe("estado con clase")
print("¿Editor de personaje?", buscarTexto(pg, "Crea a tu héroe") ~= nil)
pulsar("Al azar")
pulsar("¡Listo!")
informe("editor")
print("¿HUD con nombre?", buscarTexto(pg, "Guerrero") ~= nil)

-- teclas: M mapa, B mochila, P pausa
local UIS = RT.servicio("UserInputService")
local function tecla(k)
	UIS.InputBegan:Fire({ KeyCode = E.Enum.KeyCode[k], UserInputType = E.Enum.UserInputType.Keyboard, Position = E.Vector3.new() }, false)
	RT.avanzar(1)
end
tecla("M")
print("¿Mapa con M?", buscarTexto(pg, "Mapa de Vael") ~= nil)
tecla("M")
print("¿Mapa cerrado con M?", buscarTexto(pg, "Mapa de Vael") == nil)
tecla("B")
print("¿Mochila con B?", buscarTexto(pg, "Objetos clave") ~= nil)
pulsar("Poción")
print("¿Compañeros en la mochila?", buscarTexto(pg, "Compañeros") ~= nil)
tecla("B")
tecla("P")
print("¿Pausa con P?", buscarTexto(pg, "Volver al inicio") ~= nil)
pulsar("Configuración")
pulsar("English")
print("¿Traduce?", buscarTexto(pg, "[en]") ~= nil)
tecla("P")
informe("menús")
-- aviso de interacción propio
local ppsvc = RT.servicio("ProximityPromptService")
local parteAviso = I.new("Part")
parteAviso.Parent = E.workspace
local pr = I.new("ProximityPrompt")
pr.Style = E.Enum.ProximityPromptStyle.Custom
pr.ActionText = "Hablar"
pr.ObjectText = "Abuela Rosa"
pr.Parent = parteAviso
ppsvc.PromptShown:Fire(pr, E.Enum.ProximityPromptInputType.Keyboard)
RT.avanzar(1)
print("¿Aviso propio?", pg:FindFirstChild("AvisoVael") ~= nil)
ppsvc.PromptHidden:Fire(pr)
RT.avanzar(1)
informe("interacción")

-- diálogo, vasos, cofre, vendedor, tienda
remotos.Dialogo.OnClientEvent:Fire({ id = 1, titulo = "Abuela Rosa", texto = "Hola, cielo. Prueba de texto largo.", quien = { "vecino", "1955" }, opciones = { "Vale", "Adiós" } })
RT.avanzar(2)
print("¿EnDialogo?", jugador:GetAttribute("EnDialogo"))
pulsar("Vale")
RT.avanzar(1)
print("¿Diálogo cerrado?", jugador:GetAttribute("EnDialogo"))
remotos.Vasos.OnClientEvent:Fire({ ganador = 2, cambios = { { 1, 2 }, { 2, 3 } }, velocidad = 0.3 })
RT.avanzar(4)
remotos.OfrecerMejoras.OnClientEvent:Fire({ origen = "cofre", opciones = { "calcetin", "diente", "corona" } })
RT.avanzar(2)
pulsar("¡Esta!")
remotos.AbrirVendedor.OnClientEvent:Fire({ titulo = "Vendedor", frase = "Psst", lista = { { id = "lupa", nombre = "Lupa", descripcion = "x", rareza = "comun", precio = 60, vendido = false } }, origen = "vendedor" })
RT.avanzar(2)
pulsar("Cerrar")
remotos.AbrirTienda.OnClientEvent:Fire({ { id = "pocion", nombre = "Poción", descripcion = "x", precio = 15 } })
RT.avanzar(2)
remotos.Teletransporte.OnClientEvent:Fire(nil, "Zzz…")
remotos.Notificar.OnClientEvent:Fire("Hola")
RT.avanzar(3)
informe("ventanas")

-- combate
local carpetaB = I.new("Folder")
carpetaB.Name = "Batalla_1"
for c = 1, 10 do
	for f = 1, 4 do
		local p = I.new("Part")
		p.Name = "Casilla"
		p:SetAttribute("Col", c)
		p:SetAttribute("Fila", f)
		p.Parent = carpetaB
	end
end
carpetaB.Parent = E.workspace
local modelo = I.new("Model")
local ancla = I.new("Part")
ancla.Name = "Ancla"
ancla.Parent = modelo
modelo.PrimaryPart = ancla
modelo:SetAttribute("EnemigoId", "lobo")
modelo:SetAttribute("EntidadId", "e1")
modelo:SetAttribute("Vida", 50)
modelo:SetAttribute("VidaMax", 55)
modelo.Parent = E.workspace
local modeloC = I.new("Model")
local anclaC = I.new("Part")
anclaC.Name = "Ancla"
anclaC.Parent = modeloC
modeloC.PrimaryPart = anclaC
modeloC:SetAttribute("Companero", "4242")
modeloC:SetAttribute("CompaneroNombre", "Tomás")
modeloC:SetAttribute("EntidadId", "c1")
modeloC:SetAttribute("Vida", 80)
modeloC:SetAttribute("VidaMax", 90)
modeloC.Parent = E.workspace
RT.avanzar(1)
remotos.BatallaInicio.OnClientEvent:Fire({ centro = E.Vector3.new(110, 0, 0), zona = "Pradera", zonaId = "pradera", carpeta = carpetaB, jefe = false, emboscada = true })
local aliado = { id = "j1", nombre = "kilonil", lado = "aliado", clase = "guerrero", nivel = 1, hp = 100, maxHp = 120, mp = 20, maxMp = 20, vivo = true, esMio = true, pos = E.Vector3.new(), col = 1, fila = 2, mov = 3, alcance = 1, veneno = false, defensa = false, furia = false }
local enemigo = { id = "e1", nombre = "Lobo", lado = "enemigo", enemigo = "lobo", nivel = 1, hp = 50, maxHp = 55, mp = 0, maxMp = 0, vivo = true, esMio = false, pos = E.Vector3.new(), col = 2, fila = 2, mov = 4, alcance = 1, veneno = false, defensa = false, furia = false }
local companero = { id = "c1", nombre = "Tomás", lado = "aliado", clase = "guerrero", vecino = "4242", nivel = 1, hp = 80, maxHp = 90, mp = 20, maxMp = 20, vivo = true, esMio = false, pos = E.Vector3.new(), col = 1, fila = 3, mov = 3, alcance = 1, veneno = false, defensa = false, furia = false }
remotos.BatallaEstado.OnClientEvent:Fire({ id = 1, zona = "Pradera", ronda = 1, aliados = { aliado, companero }, enemigos = { enemigo }, orden = { "e1", "c1", "j1" }, centro = E.Vector3.new(110, 0, 0), casillas = {} })
remotos.BatallaTurno.OnClientEvent:Fire({ id = "j1", nombre = "kilonil", tiempo = 20 })
remotos.PedirAccion.OnClientEvent:Fire({ entidad = "j1", tiempo = 20, habilidades = { { id = "golpeFuerte", nombre = "Golpe fuerte", descripcion = "", coste = 5, objetivo = "enemigo", tipo = "dano", area = "uno", alcance = 1, bloqueada = false, nivelMinimo = 1, sinMana = false } }, objetos = { { id = "pocion", nombre = "Poción", cantidad = 2, descripcion = "" } }, puedeMover = true, alcanzables = { { 1, 1 }, { 1, 3 } }, alcance = 1, col = 1, fila = 2 })
RT.avanzar(2)
informe("turno")
pulsar("Habilidades")
pulsar("Golpe fuerte")
pulsar("Lobo")
remotos.BatallaEvento.OnClientEvent:Fire({ texto = "kilonil usa Golpe fuerte", actor = "j1", habilidad = "golpeFuerte", golpes = { { id = "e1", cantidad = 12, tipo = "dano", critico = true }, { id = "e1", cantidad = 8, tipo = "dano", choque = true } }, dice = { id = "e1", texto = "¡Auuu!" } })
RT.avanzar(3)
pulsar("Cámara")
modelo:SetAttribute("Caido", true)
remotos.BatallaFin.OnClientEvent:Fire({ victoria = true, xp = 10, oro = 5, subio = true, nivel = 2, cofre = true })
RT.avanzar(5)
informe("combate")
-- epílogo (al ganar al Rey Hongo por primera vez)
remotos.Epilogo.OnClientEvent:Fire()
RT.avanzar(2)
print("¿Victoria en pantalla grande?", buscarTexto(pg, "¡EL CUCHARÓN ES TUYO!") ~= nil)
RT.avanzar(5)
print("¿Epílogo?", buscarTexto(pg, "Siguiente") ~= nil)
for _ = 1, 26 do
	if boton("Siguiente") then pulsar("Siguiente") end
end
RT.avanzar(2)
print("¿Epílogo cerrado?", boton("Siguiente") == nil)
informe("epílogo")
-- final de la historia 2
remotos.Final2.OnClientEvent:Fire()
RT.avanzar(7)
print("¿Final 2?", buscarTexto(pg, "Siguiente") ~= nil)
for _ = 1, 12 do
	if boton("Siguiente") then pulsar("Siguiente") end
end
RT.avanzar(2)
print("¿Final 2 cerrado?", boton("Siguiente") == nil)
informe("final 2")
-- tablón de encargos
remotos.AbrirTablon.OnClientEvent:Fire({ lista = { { id = "babosas", estado = "disponible", n = 0 }, { id = "rocas", estado = "activa", n = 3 }, { id = "curioso", estado = "lista", n = 4 }, { id = "pinguinos", estado = "bloqueado", n = 0 }, { id = "setas", estado = "hecha", n = 8 } } })
RT.avanzar(1)
print("¿Tablón?", buscarTexto(pg, "Tablón de encargos") ~= nil)
pulsar("Entregar")
remotos.AbrirTablon.OnClientEvent:Fire({ lista = { { id = "curioso", estado = "hecha", n = 4 } }, entregado = "curioso" })
RT.avanzar(1)
-- el botón Cerrar del propio tablón (hay otros "Cerrar" en otras ventanas)
local tablon = buscarTexto(pg, "Tablón de encargos")
local bCerrar = tablon and buscarTexto(tablon.Parent, "Cerrar")
while bCerrar and not bCerrar:IsA("TextButton") do bCerrar = bCerrar.Parent end
if bCerrar then bCerrar.Activated:Fire() end
RT.avanzar(1)
print("¿Tablón cerrado?", buscarTexto(pg, "Tablón de encargos") == nil)
informe("encargos")
-- armería
remotos.AbrirArmeria.OnClientEvent:Fire({ oro = 500, nivel = 5, clase = "guerrero", armas = { espadaMadera = 1, cotaMalla = 3 }, equipo = { arma = "espadaMadera" }, novedad = "cotaMalla" })
RT.avanzar(1)
print("¿Armería?", buscarTexto(pg, "Herrería de Olga") ~= nil)
pulsar("Mejorar lo mío")
print("¿Pestaña mejorar?", buscarTexto(pg, "¡Al máximo!") ~= nil)
informe("armería")
-- dibujar a cada clase en sus tres vistas, con y sin equipo (para pillar errores de dibujo)
local Mu = E.require(carpeta:FindFirstChild("Munecos"))
local lienzo = I.new("Frame")
lienzo.Parent = pg
local dibujados = 0
for _, clase in { "guerrero", "maga", "arquero", "sanador" } do
	for _, vista in { "frente", "lado", "espalda" } do
		for _, eq in { {}, { arma = "cucharonCombate", armadura = "armaduraCazos", amuleto = "estrellaHielo" }, { arma = "hachaLenador" }, { arma = "arcoTejo" }, { arma = "baculoCristal" } } do
			for _, pelo in { 1, 4, 6, 7 } do
				Mu.crear(lienzo, "clase", clase, 3, { pelo = pelo, gorro = pelo == 7 and 3 or 1, barba = pelo == 4, vista = vista, eq = eq })
				dibujados += 1
			end
		end
	end
end
RT.avanzar(0.5)
print("muñecos dibujados:", dibujados)
informe("dibujos")
print("FIN")
