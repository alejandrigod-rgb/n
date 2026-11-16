--!strict
-- Crónicas de Vael · servidor. Arranca el mundo, las partidas guardadas, las guaridas de combate, la fuente,
-- el mercader, los personajes con los que se habla (taberna, posada, herrería, ermitaño), los secretos que
-- abren el camino (cuerda, hacha, llave y farol) y los paraderos aleatorios.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael.Datos)
local DatosJugador = require(script.Parent.DatosJugador)
local Combate = require(script.Parent.Combate)
local Mundo = require(script.Parent.Mundo)
local Eventos = require(script.Parent.Eventos)

-- remotos (servidor ↔ cliente)
local Remotos = Instance.new("Folder")
Remotos.Name = "Remotos"
for _, nombre in {
	"ElegirClase", "EstadoJugador", "BatallaInicio", "BatallaEstado", "BatallaEvento", "BatallaTurno", "PedirAccion", "EnviarAccion", "BatallaFin",
	"Notificar", "AbrirTienda", "Comprar", "OfrecerMejoras", "ElegirMejora", "AbrirVendedor", "ComprarMejora", "Dialogo", "ElegirOpcion",
	"Vasos", "ElegirVaso", "Teletransporte", "Sonido", "GuardarApariencia", "ErrorServidor", "Emboscada",
} do
	local r = Instance.new("RemoteEvent")
	r.Name = nombre
	r.Parent = Remotos
end
Remotos.Parent = Vael

local function remoto(nombre: string): RemoteEvent
	return Remotos:FindFirstChild(nombre) :: RemoteEvent
end

-- en Studio, los errores del servidor salen también en la pantalla del jugador (cuadro rojo abajo a la izquierda)
if game:GetService("RunService"):IsStudio() then
	game:GetService("LogService").MessageOut:Connect(function(mensaje, tipo)
		if tipo == Enum.MessageType.MessageError then
			remoto("ErrorServidor"):FireAllClients(mensaje)
		end
	end)
end

Combate.iniciar(Remotos)

--- Manda al cliente su estado (para el HUD, las barreras y los secretos).
local function enviarEstado(j: Player)
	local perfil = DatosJugador.obtener(j)
	if not perfil then
		return
	end
	local hp, maxHp, mp, maxMp = Combate.vidaDe(j)
	-- los clientes dibujan el muñeco 2D de cada jugador según su clase
	j:SetAttribute("Creado", perfil.creado)
	j:SetAttribute("Clase", perfil.clase)
	j:SetAttribute("Apariencia", HttpService:JSONEncode(perfil.apariencia))
	j:SetAttribute("NombreHeroe", perfil.nombreHeroe ~= "" and perfil.nombreHeroe or j.DisplayName)
	local _, sinergias = Datos.efectosDe(perfil.mejoras)
	remoto("EstadoJugador"):FireClient(j, {
		clase = perfil.clase,
		nivel = perfil.nivel,
		xp = perfil.xp,
		xpSiguiente = Datos.xpParaNivel(perfil.nivel),
		oro = perfil.oro,
		objetos = perfil.objetos,
		hp = hp,
		maxHp = maxHp,
		mp = mp,
		maxMp = maxMp,
		enBatalla = Combate.enBatalla(j),
		mejoras = perfil.mejoras,
		sinergias = sinergias,
		llaves = perfil.llaves,
		setas = perfil.progreso.setas,
		palancas = perfil.progreso.palancas,
		apariencia = perfil.apariencia,
		creado = perfil.creado,
		nombreHeroe = perfil.nombreHeroe,
	})
end
Combate.alCambiarJugador = enviarEstado

local function notificar(j: Player, texto: string)
	remoto("Notificar"):FireClient(j, texto)
end

local pista: (any) -> string

-- ===================== DIÁLOGOS =====================
-- dialogo(j, { titulo, texto, quien = { tipo, id }, opciones = { { texto, accion = function() return "respuesta" end } } })
type Opcion = { texto: string, accion: (() -> string?)? }
local pendientes: { [Player]: { id: number, opciones: { Opcion } } } = {}
local siguienteDialogo = 0

local function dialogo(j: Player, d: any)
	siguienteDialogo += 1
	local textos = {}
	for _, o in d.opciones do
		table.insert(textos, o.texto)
	end
	pendientes[j] = { id = siguienteDialogo, opciones = d.opciones }
	remoto("Dialogo"):FireClient(j, { id = siguienteDialogo, titulo = d.titulo, texto = d.texto, quien = d.quien, opciones = textos })
end

remoto("ElegirOpcion").OnServerEvent:Connect(function(j, id, indice)
	local p = pendientes[j]
	if not p or p.id ~= id or type(indice) ~= "number" then
		return
	end
	pendientes[j] = nil
	local o = p.opciones[indice]
	if o and o.accion then
		local respuesta = o.accion()
		if respuesta then
			notificar(j, respuesta)
		end
	end
	enviarEstado(j)
end)

--- Qué toca hacer ahora (lo dicen la abuela y la lista de objetivos).
pista = function(perfil: any): string
	if not perfil.llaves.cuerda then
		return "Para cruzar el río necesitas una cuerda. Ve a la ciudad (a la derecha), entra en la taberna y gánale a Bruno a los vasos dos veces seguidas."
	elseif not perfil.llaves.hacha then
		return "Ya tienes la cuerda. Cruza el río hasta el Pantano y sube por las tablas: arriba hay un cofre con un hacha."
	elseif not perfil.llaves.llave then
		return "Con el hacha cortas las zarzas del Bosque. El ermitaño Fermín busca 3 setas que brillan: llévaselas y te dará una llave."
	elseif not perfil.llaves.farol then
		return "La llave abre las Ruinas. Tira de las 3 palancas (¡una está arriba!) y abre el cofre de la cripta: dentro hay un farol."
	end
	return "¡Ya lo tienes todo! Entra en la Cueva y dale su merecido al Rey Hongo."
end

local function darLlave(j: Player, llave: string)
	local perfil = DatosJugador.obtener(j)
	if perfil and not perfil.llaves[llave] then
		perfil.llaves[llave] = true
		DatosJugador.guardar(j)
		remoto("Sonido"):FireClient(j, "llave")
		task.delay(0.4, function()
			notificar(j, "¡Conseguido: " .. Datos.Llaves[llave].nombre .. "! " .. Datos.Llaves[llave].descripcion)
		end)
		enviarEstado(j)
	end
end

-- ===================== JUGADORES =====================
Players.PlayerAdded:Connect(function(j)
	DatosJugador.cargar(j)
	j.CharacterAdded:Connect(function()
		task.wait(0.5)
		enviarEstado(j)
	end)
	task.wait(1)
	enviarEstado(j)
end)
Players.PlayerRemoving:Connect(function(j)
	DatosJugador.soltar(j)
	pendientes[j] = nil
end)

remoto("ElegirClase").OnServerEvent:Connect(function(j, claseId)
	local perfil = DatosJugador.obtener(j)
	if perfil and perfil.clase == nil and type(claseId) == "string" and Datos.Clases[claseId] then
		perfil.clase = claseId
		Combate.curarDelTodo(j)
		DatosJugador.guardar(j)
		enviarEstado(j)
		notificar(j, "¡Bienvenido a Vael, " .. Datos.Clases[claseId].nombre .. "!")
	end
end)

-- personalizar el personaje (el nombre pasa por el filtro de texto de Roblox, obligatorio para que lo vean otros)
remoto("GuardarApariencia").OnServerEvent:Connect(function(j, datos)
	local perfil = DatosJugador.obtener(j)
	if not perfil then
		return
	end
	local ap = Datos.validarApariencia(datos)
	local nombre = ""
	if ap.nombre ~= "" then
		local ok, filtrado = pcall(function()
			return TextService:FilterStringAsync(ap.nombre, j.UserId):GetNonChatStringForBroadcastAsync()
		end)
		nombre = ok and filtrado or ""
	end
	ap.nombre = nombre
	local primeraVez = not perfil.creado
	perfil.apariencia = ap
	perfil.nombreHeroe = nombre
	perfil.creado = true
	if primeraVez then
		task.delay(1.5, function()
			if j.Parent then
				dialogo(j, {
					titulo = "Abuela Rosa",
					texto = "¡" .. (nombre ~= "" and nombre or j.DisplayName) .. ", por fin despiertas! El Rey Hongo ha llenado Vael de monstruos. Empieza echando las babosas del huerto de Tomás y luego ve a la ciudad. Y llévate la mochila, que hace frío.",
					quien = { "vecino", "1955" },
					opciones = { { texto = "¡Allá voy!" }, { texto = "¿Puedo dormir cinco minutos más?", accion = function()
						return "«¡NO!»"
					end } },
				})
			end
		end)
	end
	DatosJugador.guardar(j)
	enviarEstado(j)
	notificar(j, "¡Qué buena pinta!")
end)

-- ===================== MUNDO Y GUARIDAS =====================
local zonas = Mundo.construir()
local ocupada: { [BasePart]: boolean } = {}
local enfriamiento: { [BasePart]: number } = {}

local function jugadorDe(parte: BasePart): Player?
	local modelo = parte:FindFirstAncestorOfClass("Model")
	return modelo and Players:GetPlayerFromCharacter(modelo) or nil
end

for disco, zona in zonas do
	disco.Touched:Connect(function(toca)
		local j = jugadorDe(toca)
		if not j or ocupada[disco] or os.clock() < (enfriamiento[disco] or 0) or Combate.enBatalla(j) then
			return
		end
		local perfil = DatosJugador.obtener(j)
		if not perfil or not perfil.clase then
			notificar(j, "Elige tu clase primero")
			return
		end
		-- el equipo: quien lo pisa y los jugadores cercanos que no estén luchando
		local equipo = { j }
		for _, otro in Players:GetPlayers() do
			if otro ~= j and #equipo < Datos.MAX_EQUIPO and not Combate.enBatalla(otro) then
				local p = DatosJugador.obtener(otro)
				local ch = otro.Character
				if p and p.clase and ch and ch.PrimaryPart and (ch.PrimaryPart.Position - disco.Position).Magnitude < 45 then
					table.insert(equipo, otro)
				end
			end
		end
		ocupada[disco] = true
		disco:SetAttribute("Ocupada", true)
		local b = Combate.empezar(zona, disco.Position - Vector3.new(0, disco.Position.Y, 0), equipo)
		if not b then
			ocupada[disco] = false
			disco:SetAttribute("Ocupada", false)
		end
	end)
end

Combate.alTerminar = function(b)
	for disco, zona in zonas do
		if zona == b.zona and ocupada[disco] then
			ocupada[disco] = false
			enfriamiento[disco] = os.clock() + 5
			disco:SetAttribute("Ocupada", false)
		end
	end
end

-- ===================== PUNTOS CON LOS QUE SE INTERACTÚA =====================
local mundo = workspace:WaitForChild("MundoVael")
local ultimaFuente: { [Player]: number } = {}

local function aviso(parte: BasePart, accion: string, objeto: string, alPulsar: (Player) -> (), distancia: number?)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = accion
	prompt.ObjectText = objeto
	prompt.MaxActivationDistance = distancia or 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = parte
	prompt.Triggered:Connect(function(j)
		local perfil = DatosJugador.obtener(j)
		if not perfil or not perfil.clase or Combate.enBatalla(j) then
			return
		end
		alPulsar(j)
	end)
end

local function teletransportar(j: Player, pos: Vector3)
	local ch = j.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if raiz then
		remoto("Teletransporte"):FireClient(j, pos)
		-- con StreamingEnabled, que llegue el suelo antes de mover al jugador
		pcall(function()
			j:RequestStreamAroundAsync(pos, 3)
		end)
		task.wait(0.35)
		raiz.CFrame = CFrame.new(pos)
	end
end

local VASOS_FRASES = { "¡Ja! Otra vez será.", "El vaso de la izquierda… o no.", "Mis manos son más rápidas que tus ojos." }
local partidasVasos: { [Player]: { ganador: number, cambios: { { number } } } } = {}

local function tabernero(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	dialogo(j, {
		titulo = "Bruno, el tabernero",
		texto = perfil.llaves.cuerda and "¡Mi campeón de los vasos! ¿Qué te pongo?" or "Bienvenido a El Hongo Feliz. Si me ganas a los vasos dos veces seguidas, te doy mi cuerda de la suerte.",
		quien = { "vecino", "1984" },
		opciones = {
			{ texto = "Jugar a los vasos (5 oro)", accion = function()
				if perfil.oro < 5 then
					return "«Sin oro no hay vasos, amigo.»"
				end
				perfil.oro -= 5
				local r = Random.new()
				local ganador = r:NextInteger(1, 3)
				local cambios = {}
				for _ = 1, 7 + math.min(4, perfil.progreso.racha or 0) * 2 do
					local a = r:NextInteger(1, 3)
					local b = (a % 3) + 1
					table.insert(cambios, { a, b })
				end
				partidasVasos[j] = { ganador = ganador, cambios = cambios }
				remoto("Vasos"):FireClient(j, { ganador = ganador, cambios = cambios, velocidad = 0.32 - math.min(0.12, (perfil.progreso.racha or 0) * 0.05) })
				return nil
			end },
			{ texto = "Comer un guiso (8 oro, cura)", accion = function()
				if perfil.oro < 8 then
					return "«El guiso no es gratis, eh.»"
				end
				perfil.oro -= 8
				local _, maxHp, mp, maxMp = Combate.vidaDe(j)
				Combate.ponerVida(j, maxHp, math.min(maxMp, mp + math.floor(maxMp * 0.5)))
				return "Ñam. Sabe a hongo feliz. Vida al máximo."
			end },
			{ texto = "Escuchar rumores", accion = function()
				local rumores = {
					"Dicen que en el Pantano hay un cofre en lo alto de unas tablas.",
					"El ermitaño del Bosque colecciona setas que brillan. Raro, ¿eh?",
					"En las Ruinas hay tres palancas. Una está donde nadie mira: arriba.",
					"Sin farol no se entra en la cueva. Lo sé porque lo intenté.",
					"Un vendedor con gafas de sol aparece y desaparece. No le compres calcetines.",
				}
				return rumores[math.random(1, #rumores)]
			end },
			{ texto = "Adiós" },
		},
	})
end

remoto("ElegirVaso").OnServerEvent:Connect(function(j, vaso)
	local p = partidasVasos[j]
	local perfil = DatosJugador.obtener(j)
	if not p or not perfil or type(vaso) ~= "number" then
		return
	end
	partidasVasos[j] = nil
	-- dónde acaba la bola tras los cambios
	local pos = p.ganador
	for _, c in p.cambios do
		if pos == c[1] then
			pos = c[2]
		elseif pos == c[2] then
			pos = c[1]
		end
	end
	if vaso == pos then
		perfil.progreso.racha = (perfil.progreso.racha or 0) + 1
		perfil.oro += 12
		notificar(j, "¡Acertaste! +12 de oro. Racha: " .. perfil.progreso.racha)
		if perfil.progreso.racha >= 2 and not perfil.llaves.cuerda then
			task.delay(1, function()
				notificar(j, "Bruno: «Vale, vale… te la has ganado.»")
				darLlave(j, "cuerda")
			end)
		end
	else
		perfil.progreso.racha = 0
		notificar(j, "Bruno: «" .. VASOS_FRASES[math.random(1, #VASOS_FRASES)] .. "»")
	end
	enviarEstado(j)
end)

local function ermitano(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	local n = #perfil.progreso.setas
	if perfil.llaves.llave then
		dialogo(j, { titulo = "Ermitaño Fermín", texto = "Mis setas brillan de felicidad. Que la llave te sirva, joven.", quien = { "vecino", "60606" }, opciones = { { texto = "Gracias, Fermín" } } })
	elseif n >= 3 then
		dialogo(j, {
			titulo = "Ermitaño Fermín",
			texto = "¡Mis tres setas brillantes! Toma, esta llave de piedra abre la puerta de las Ruinas. Yo ya no salgo de casa.",
			quien = { "vecino", "60606" },
			opciones = { { texto = "¡Gracias!", accion = function()
				darLlave(j, "llave")
				return nil
			end } },
		})
	else
		dialogo(j, {
			titulo = "Ermitaño Fermín",
			texto = "Perdí mis 3 setas brillantes por el Bosque. Una está escondida detrás de los arbustos, otra en lo alto de las tablas… y la otra, a saber. Llevas " .. n .. " de 3.",
			quien = { "vecino", "60606" },
			opciones = { { texto = "Las buscaré" }, { texto = "¿Por qué brillan?", accion = function()
				return "«No preguntes. Simplemente brillan.»"
			end } },
		})
	end
end

local HERRERO_STOCK = { "cuerno", "pan", "botas", "muelles" }
local function herrero(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	local lista = {}
	for _, id in HERRERO_STOCK do
		local m = Datos.Mejoras[id]
		local cuantos = 0
		for _, x in perfil.mejoras do
			if x == id then
				cuantos += 1
			end
		end
		table.insert(lista, { id = id, nombre = m.nombre, descripcion = m.descripcion, rareza = m.rareza, precio = Datos.PrecioRareza[m.rareza] + cuantos * 40, vendido = cuantos >= 3 })
	end
	remoto("AbrirVendedor"):FireClient(j, { titulo = "Herrería de Olga", frase = "Lo que forjo, dura. Lo que vendo, se paga.", lista = lista, origen = "herrero" })
end

remoto("ComprarMejora").OnServerEvent:Connect(function(j, origen, id)
	if type(id) ~= "string" or not Datos.Mejoras[id] or Combate.enBatalla(j) then
		return
	end
	if origen == "herrero" then
		local perfil = DatosJugador.obtener(j)
		if not perfil or not table.find(HERRERO_STOCK, id) then
			return
		end
		local cuantos = 0
		for _, x in perfil.mejoras do
			if x == id then
				cuantos += 1
			end
		end
		local precio = Datos.PrecioRareza[Datos.Mejoras[id].rareza] + cuantos * 40
		if cuantos >= 3 then
			notificar(j, "Olga: «De eso ya no te queda sitio.»")
		elseif perfil.oro < precio then
			notificar(j, "Olga: «Vuelve cuando tengas " .. precio .. " de oro.»")
		else
			perfil.oro -= precio
			Combate.darMejora(j, id)
			herrero(j)
		end
		enviarEstado(j)
	elseif origen == "vendedor" then
		Eventos.comprar(j, id)
	end
end)

for _, d in mundo:GetDescendants() do
	if not d:IsA("BasePart") then
		continue
	end
	local p = d :: BasePart
	if p:GetAttribute("Fuente") then
		p.Touched:Connect(function(toca)
			local j = jugadorDe(toca)
			if j and not Combate.enBatalla(j) and os.clock() > (ultimaFuente[j] or 0) then
				ultimaFuente[j] = os.clock() + 3
				Combate.curarDelTodo(j)
				enviarEstado(j)
				notificar(j, "La fuente te cura del todo")
			end
		end)
	end
	if p:GetAttribute("Mercader") then
		aviso(p, "Comprar", "Mercader", function(j)
			local lista = {}
			for _, oid in Datos.OrdenObjetos do
				local o = Datos.Objetos[oid]
				table.insert(lista, { id = oid, nombre = o.nombre, descripcion = o.descripcion, precio = o.precio })
			end
			remoto("AbrirTienda"):FireClient(j, lista)
		end)
	end
	local nombre = p:GetAttribute("Punto")
	if nombre == "entrarTaberna" then
		aviso(p, "Entrar", "Taberna El Hongo Feliz", function(j)
			teletransportar(j, Mundo.Taberna.entrada)
		end)
	elseif nombre == "salirTaberna" then
		aviso(p, "Salir", "Puerta", function(j)
			teletransportar(j, Mundo.Taberna.salida)
		end)
	elseif nombre == "tabernero" then
		p:SetAttribute("Npc", "vecino:1984")
		p:SetAttribute("Frases", "¡Pasa, pasa!|¿Unos vasos?|El guiso de hoy lleva… cosas.")
		aviso(p, "Hablar", "Bruno, el tabernero", tabernero)
	elseif nombre == "ermitano" then
		p:SetAttribute("Npc", "vecino:60606")
		p:SetAttribute("Frases", "Mis setas…|¿Has visto algo que brille?")
		aviso(p, "Hablar", "Ermitaño Fermín", ermitano)
	elseif nombre == "herrero" then
		p:SetAttribute("Npc", "vecino:5150")
		p:SetAttribute("Frases", "¡CLANG! ¡CLANG!|Mejoras de hierro, a buen precio.")
		aviso(p, "Comprar", "Herrería de Olga", herrero)
	elseif nombre == "posada" then
		aviso(p, "Entrar", "Posada El Ronquido", function(j)
			teletransportar(j, Mundo.Posada.entrada)
		end)
	elseif nombre == "salirPosada" then
		aviso(p, "Salir", "Puerta", function(j)
			teletransportar(j, Mundo.Posada.salida)
		end)
	elseif nombre == "abuela" then
		p:SetAttribute("Npc", "vecino:1955")
		p:SetAttribute("Frases", "¡Ten cuidado ahí fuera, cielo!|¿Has comido? Estás muy flaco.|En mis tiempos las babosas eran más pequeñas.")
		aviso(p, "Hablar", "Abuela Rosa", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Abuela Rosa",
				texto = pista(perfil),
				quien = { "vecino", "1955" },
				opciones = { { texto = "¡Gracias, abuela!" }, { texto = "Cuéntame lo del Rey Hongo", accion = function()
					return "«Vive en la cueva del final del camino. Dicen que su corona es de verdad… y que huele fatal.»"
				end } },
			})
		end)
	elseif nombre == "granjero" then
		p:SetAttribute("Npc", "vecino:4242")
		p:SetAttribute("Frases", "¡Las babosas se comen mis coles!|Ese espantapájaros no espanta ni a una mosca.")
		aviso(p, "Hablar", "Granjero Tomás", function(j)
			dialogo(j, {
				titulo = "Granjero Tomás",
				texto = "¡Las babosas se han metido en mi huerto! Entra en la mancha verde de detrás de las coles y échalas. Es fácil, hasta mi gallina lo haría.",
				quien = { "vecino", "4242" },
				opciones = { { texto = "¡Voy!" }, { texto = "¿Y tu gallina?", accion = function()
					return "«Está de vacaciones.»"
				end } },
			})
		end)
	elseif nombre == "guardaPuente" then
		p:SetAttribute("Npc", "vecino:8080")
		p:SetAttribute("Frases", "Sin cuerda no se cruza.|El río lleva agua de verdad, eh.")
		aviso(p, "Hablar", "Guardia del puente", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Guardia del puente",
				texto = perfil.llaves.cuerda and "¡Con esa cuerda el puente queda como nuevo! Adelante, el Pantano te espera." or "El puente está roto. Necesitas una CUERDA. Bruno, el de la taberna de la ciudad, tiene una… pero solo se la da a quien le gane dos veces seguidas a los vasos.",
				quien = { "vecino", "8080" },
				opciones = { { texto = "Entendido" } },
			})
		end)
	elseif nombre == "posadera" then
		p:SetAttribute("Npc", "vecino:2468")
		p:SetAttribute("Frases", "Camas blanditas, ronquidos incluidos.|¿Una siestecita?")
		aviso(p, "Dormir (10 oro)", "Posadera Lola", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if perfil.oro < 10 then
				notificar(j, "«Sin 10 de oro no hay cama, cielo.»")
				return
			end
			perfil.oro -= 10
			remoto("Teletransporte"):FireClient(j, nil, "Zzz…")
			task.wait(1)
			Combate.curarDelTodo(j)
			DatosJugador.guardar(j)
			enviarEstado(j)
			notificar(j, "Has dormido como un tronco. Vida y maná al máximo. Partida guardada.")
		end)
	elseif nombre == "cofreHacha" then
		aviso(p, "Abrir", "Cofre", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if perfil.llaves.hacha then
				notificar(j, "El cofre está vacío. Ya cogiste el hacha.")
			else
				darLlave(j, "hacha")
			end
		end, 6)
	elseif nombre == "seta" then
		local id = p:GetAttribute("SetaId") :: number
		aviso(p, "Coger", "Seta brillante", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if table.find(perfil.progreso.setas, id) or perfil.llaves.llave then
				return
			end
			table.insert(perfil.progreso.setas, id)
			remoto("Sonido"):FireClient(j, "brillo")
			notificar(j, "Seta brillante (" .. #perfil.progreso.setas .. " de 3). Huele a menta.")
			DatosJugador.guardar(j)
			enviarEstado(j)
		end, 6)
	elseif nombre == "palanca" then
		local id = p:GetAttribute("PalancaId") :: number
		aviso(p, "Tirar", "Palanca", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if table.find(perfil.progreso.palancas, id) then
				return
			end
			table.insert(perfil.progreso.palancas, id)
			remoto("Sonido"):FireClient(j, "palanca")
			local n = #perfil.progreso.palancas
			notificar(j, n >= 3 and "¡CLONK! Se oye abrirse algo en las Ruinas…" or ("Clac. Palanca " .. n .. " de 3."))
			DatosJugador.guardar(j)
			enviarEstado(j)
		end, 6)
	elseif nombre == "cofreFarol" then
		aviso(p, "Abrir", "Cofre de la cripta", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if perfil.llaves.farol then
				notificar(j, "Vacío. Solo hay una araña que te saluda.")
			elseif #perfil.progreso.palancas < 3 then
				notificar(j, "Está cerrado con un mecanismo. Faltan palancas: " .. #perfil.progreso.palancas .. " de 3.")
			else
				darLlave(j, "farol")
			end
		end)
	end
end

-- ===================== PARADEROS ALEATORIOS =====================
Eventos.iniciar({
	dialogo = dialogo,
	notificar = notificar,
	enviarEstado = enviarEstado,
	Combate = Combate,
	DatosJugador = DatosJugador,
	remoto = remoto,
})

-- tienda del mercader (pociones y éteres)
remoto("Comprar").OnServerEvent:Connect(function(j, objetoId)
	local perfil = DatosJugador.obtener(j)
	local o = type(objetoId) == "string" and Datos.Objetos[objetoId] or nil
	if not perfil or not o or Combate.enBatalla(j) then
		return
	end
	if perfil.oro < o.precio then
		notificar(j, "No te llega el oro")
		return
	end
	perfil.oro -= o.precio
	perfil.objetos[o.id] = (perfil.objetos[o.id] or 0) + 1
	enviarEstado(j)
	notificar(j, "Has comprado: " .. o.nombre)
end)

-- ===================== EMBOSCADAS =====================
-- Al ir andando por las zonas salvajes, a veces saltan monstruos de entre los arbustos: ¡EMBOSCADA!
-- (los monstruos atacan primero). El campo de batalla se coloca dentro de la zona, sin cruzar barreras.
local TRAMOS = {
	{ id = "pradera", desde = 64, hasta = 144 },
	{ id = "pantano", desde = 183, hasta = 244 },
	{ id = "bosque", desde = 283, hasta = 344 },
	{ id = "ruinas", desde = 383, hasta = 444 },
}
local ultimaEmboscada: { [Player]: number } = {}
local ultimaPos: { [Player]: Vector3 } = {}
local rngEmb = Random.new()

local function zonaPorId(id: string): any
	for _, z in Datos.Zonas do
		if z.id == id then
			return z
		end
	end
	return nil
end

task.spawn(function()
	while true do
		task.wait(12)
		for _, j in Players:GetPlayers() do
			local ch = j.Character
			local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
			local perfil = DatosJugador.obtener(j)
			if raiz and perfil and perfil.clase and perfil.creado and not Combate.enBatalla(j) then
				local pos = raiz.Position
				local antes = ultimaPos[j]
				ultimaPos[j] = pos
				local andando = antes ~= nil and (pos - antes).Magnitude > 8 and pos.Y < 100
				if andando and os.clock() > (ultimaEmboscada[j] or 0) + 90 and rngEmb:NextNumber() < 0.3 then
					for _, t in TRAMOS do
						if pos.X > t.desde - 18 and pos.X < t.hasta + 18 then
							local zona = zonaPorId(t.id)
							if zona then
								ultimaEmboscada[j] = os.clock()
								notificar(j, "¡Algo se mueve entre los arbustos…!")
								task.wait(1)
								if not Combate.enBatalla(j) then
									local x = math.clamp(pos.X, t.desde, t.hasta)
									Combate.empezar({ id = zona.id, nombre = "¡Emboscada en " .. zona.nombre .. "!", nivel = zona.nivel, grupos = zona.grupos, color = zona.color }, Vector3.new(x, 0, 0), { j }, { emboscada = true })
								end
							end
							break
						end
					end
				end
			end
		end
	end
end)
Players.PlayerRemoving:Connect(function(j)
	ultimaEmboscada[j] = nil
	ultimaPos[j] = nil
end)

-- autoguardado cada 2 minutos
task.spawn(function()
	while true do
		task.wait(120)
		for _, j in Players:GetPlayers() do
			DatosJugador.guardar(j)
		end
	end
end)
