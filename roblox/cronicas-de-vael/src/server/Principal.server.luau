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
	"Vasos", "ElegirVaso", "Teletransporte", "Sonido", "GuardarApariencia", "ErrorServidor", "Emboscada", "AbrirEditor", "UsarObjeto", "GuardarAjustes", "Epilogo", "ElegirCompanero",
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

--- Compañeros que ya te tocan por lo que llevas hecho (para partidas de antes de que existieran).
local function asegurarCompaneros(perfil: any)
	local pr = perfil.progreso
	pr.companeros = pr.companeros or {}
	if (pr.vencidas and pr.vencidas.huerto) or perfil.llaves.cuerda or perfil.nivel >= 3 then
		pr.companeros.tomas = true
	end
	if pr.pelotaEntregada then
		pr.companeros.lucas = true
	end
	if perfil.llaves.llave then
		pr.companeros.fermin = true
	end
	if pr.companero == nil then
		for _, cid in Datos.OrdenCompaneros do
			if pr.companeros[cid] then
				pr.companero = cid
			end
		end
	end
end

--- Manda al cliente su estado (para el HUD, las barreras y los secretos).
local function enviarEstado(j: Player)
	local perfil = DatosJugador.obtener(j)
	if not perfil then
		return
	end
	asegurarCompaneros(perfil)
	j:SetAttribute("FinalVisto", perfil.progreso.final == true)
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
		ajustes = (perfil :: any).ajustes,
		creado = perfil.creado,
		nombreHeroe = perfil.nombreHeroe,
		companeros = perfil.progreso.companeros,
		companero = perfil.progreso.companero,
	})
end
Combate.alCambiarJugador = enviarEstado

local function notificar(j: Player, texto: string)
	remoto("Notificar"):FireClient(j, texto)
end

local pista: (any) -> string
local SECRETOS: { [string]: any } = {}
local TOTAL_SECRETOS = 0

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

--- Un vecino se une a tu equipo (y pasa a ser tu compañero si ibas sin nadie o con uno anterior).
local function reclutar(j: Player, cid: string)
	local perfil = DatosJugador.obtener(j) :: any
	local def = Datos.Companeros[cid]
	if not perfil or not def then
		return
	end
	local pr = perfil.progreso
	pr.companeros = pr.companeros or {}
	if pr.companeros[cid] then
		return
	end
	pr.companeros[cid] = true
	pr.companero = cid
	DatosJugador.guardar(j)
	task.delay(0.8, function()
		if not j.Parent then
			return
		end
		local textos = {
			tomas = "¡Me has salvado las coles! Mira, yo me apunto: si vas a por el Rey Hongo, mi horca va contigo.",
			lucas = "¡Quiero ir contigo! Tengo tirachinas y no me da miedo nada. Bueno, los gatos del callejón un poco.",
			fermin = "Hace años que no salgo de casa… pero alguien tendrá que curarte. Iré contigo, joven.",
		}
		dialogo(j, {
			titulo = def.nombre .. " se une",
			texto = textos[cid] or def.descripcion,
			quien = { "vecino", def.vecino },
			opciones = { { texto = "¡Bienvenido al equipo!" }, { texto = "Prefiero ir solo", accion = function()
				pr.companero = "solo"
				return "Puedes llevarlo cuando quieras desde la mochila (B)."
			end } },
		})
	end)
end

remoto("ElegirCompanero").OnServerEvent:Connect(function(j, cid)
	local perfil = DatosJugador.obtener(j) :: any
	if not perfil or type(cid) ~= "string" or Combate.enBatalla(j) then
		return
	end
	local pr = perfil.progreso
	if cid == "solo" then
		pr.companero = "solo"
		notificar(j, "Irás solo a las peleas")
	elseif Datos.Companeros[cid] and pr.companeros and pr.companeros[cid] then
		pr.companero = cid
		notificar(j, Datos.Companeros[cid].nombre .. " irá contigo")
	else
		return
	end
	DatosJugador.guardar(j)
	enviarEstado(j)
end)

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
	return "¡Ya lo tienes todo! Entra en la Cueva, dale su merecido al Rey Hongo y recupera el Cucharón."
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

--- Pelea obligatoria para conseguir un objeto clave: unos guardianes salen y hay que ganarles.
--- Si pierdes, vuelves a intentarlo cuando quieras (el objeto sigue ahí).
local function guardianes(j: Player, titulo: string, texto: string, quien: { string }, batalla: any, x: number, alGanar: (Player) -> ())
	if Combate.enBatalla(j) then
		return
	end
	dialogo(j, {
		titulo = titulo,
		texto = texto,
		quien = quien,
		opciones = {
			{ texto = "¡A pelear!", accion = function()
				if not Combate.enBatalla(j) then
					batalla.guardian = true
					Combate.empezar(batalla, Vector3.new(x, 0, 0), { j }, { emboscada = true, alGanar = alGanar })
				end
				return nil
			end },
			{ texto = "Mejor luego" },
		},
	})
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
					texto = "¡Por fin despiertas! El Rey Hongo se ha llevado el Cucharón y sus esporas tienen a todos los bichos rabiosos. Empieza echando las babosas del huerto de Tomás y luego ve a la ciudad. Y llévate la mochila, que hace frío.",
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

-- final de la historia: al ganar al Rey Hongo se recupera el Cucharón de Vael
Combate.alVencerJefe = function(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	if perfil and not perfil.progreso.final then
		-- la primera vez: el epílogo (el cliente lo cuenta como el prólogo)
		perfil.progreso.final = true
		DatosJugador.guardar(j)
		j:SetAttribute("FinalVisto", true)
		remoto("Epilogo"):FireClient(j)
		return
	end
	dialogo(j, {
		titulo = "Abuela Rosa",
		texto = "¡Has recuperado el Cucharón de Vael! Esta noche hay Gran Guiso… y este año, sin setas. El Rey Hongo está invitado, eso sí.",
		quien = { "vecino", "1955" },
		opciones = { { texto = "¡A comer!" }, { texto = "¿Y si me pide revancha?", accion = function()
			return "«Pues le ganas otra vez, cielo. La cueva sigue ahí.»"
		end } },
	})
end

-- ===================== SECRETOS (easter eggs) =====================
-- Cada uno da 5 de oro la primera vez; encontrarlos todos regala la Corona de cartón.
SECRETOS = {
	gato = { accion = "Acariciar", titulo = "¿Un gato morado?", quien = { "vecino", "4040" }, texto = "Un gato morado con pañuelo rojo te mira, hace «miau» y suena su cascabel. Juraría que no es de este mundo… Cuando parpadeas, ya no está.", respuesta = "¿Hola…?" },
	puerta = { accion = "Llamar", titulo = "La puerta del NO", quien = { "enemigo", "fantasma" }, texto = "Llamas. Silencio. Luego, una voz desde dentro: «…todavía no.» Y unos ojos amarillos se cierran despacio.", respuesta = "Me voy, me voy" },
	olla = { accion = "Remover", titulo = "La olla del Gran Guiso", quien = { "vecino", "1955" }, texto = "Remueves la olla vacía. Suena a eco… y huele a setas tristes. Sin el Cucharón no hay fiesta.", respuesta = "Lo recuperaré" },
	puertecita = { accion = "Llamar", titulo = "Una puertecita", quien = { "vecino", "999" }, texto = "Una vocecita grita: «¡NO HAY NADIE!» …y alguien desliza unas monedas por debajo de la puerta para que te vayas.", respuesta = "Gracias, nadie" },
	pato = { accion = "Apretar", titulo = "Un pato de goma", quien = { "vecino", "42" }, texto = "¡CUAC! Un pato de goma en mitad del pantano. Alguien lo perdió en la bañera… hace unos 300 años.", respuesta = "Cuac" },
	piedra = { accion = "Escuchar", titulo = "Una piedra con cara", quien = { "enemigo", "golem" }, texto = "La piedra susurra: «Aquí estuvo AEZ». Nadie en Vael sabe qué significa.", respuesta = "Qué misterio" },
	bordeOeste = { accion = "Mirar", titulo = "El fin del cartón", quien = { "vecino", "1" }, texto = "Más allá solo hay mesa, unas tijeras y una mancha de pegamento. Mejor no saltes.", respuesta = "Vuelvo" },
	bordeEste = { accion = "Mirar", titulo = "Se acabó el papel", quien = { "vecino", "2" }, texto = "Aquí el dibujante se quedó sin papel. Dejó una nota: «Continuará… cuando compre más cartulina».", respuesta = "Esperaré" },
}
for _ in SECRETOS do
	TOTAL_SECRETOS += 1
end

-- ===================== MUNDO Y GUARIDAS =====================
local zonas = Mundo.construir()
local ocupada: { [BasePart]: boolean } = {}
local enfriamiento: { [BasePart]: number } = {}

local function jugadorDe(parte: BasePart): Player?
	local modelo = parte:FindFirstAncestorOfClass("Model")
	return modelo and Players:GetPlayerFromCharacter(modelo) or nil
end

local function empezarEn(disco: BasePart, zona: any, j: Player)
	if ocupada[disco] or Combate.enBatalla(j) then
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
end

-- si ya ganaste en esa guarida, antes de repetir la pelea se pregunta (así no se repite sin querer)
local noPreguntar: { [Player]: number } = {}
Players.PlayerRemoving:Connect(function(j)
	noPreguntar[j] = nil
end)
for disco, zona in zonas do
	disco.Touched:Connect(function(toca)
		local j = jugadorDe(toca)
		if not j or ocupada[disco] or os.clock() < (enfriamiento[disco] or 0) or Combate.enBatalla(j) then
			return
		end
		local perfil = DatosJugador.obtener(j) :: any
		if not perfil or not perfil.clase then
			notificar(j, "Elige tu clase primero")
			return
		end
		local vencidas = perfil.progreso.vencidas
		if vencidas and vencidas[zona.id] then
			if os.clock() < (noPreguntar[j] or 0) or j:GetAttribute("Preguntando") then
				return
			end
			j:SetAttribute("Preguntando", true)
			noPreguntar[j] = os.clock() + 8
			local primero = zona.grupos[1] and zona.grupos[1][1] or "babosa"
			dialogo(j, {
				titulo = zona.nombre,
				texto = "Ya limpiaste esta guarida. ¿Quieres repetir la pelea?",
				quien = { "enemigo", primero },
				opciones = {
					{ texto = "Sí", accion = function()
						j:SetAttribute("Preguntando", false)
						empezarEn(disco, zona, j)
						return nil
					end },
					{ texto = "No", accion = function()
						j:SetAttribute("Preguntando", false)
						noPreguntar[j] = os.clock() + 10
						return nil
					end },
				},
			})
			-- por si cierra el diálogo sin elegir
			task.delay(20, function()
				if j.Parent then
					j:SetAttribute("Preguntando", false)
				end
			end)
			return
		end
		empezarEn(disco, zona, j)
	end)
end

Combate.alTerminar = function(b)
	if b.victoria then
		for _, e in b.aliados do
			local j = e.jugador
			local perfil = j and DatosJugador.obtener(j) :: any
			if j and perfil then
				local pr = perfil.progreso
				pr.vencidas = pr.vencidas or {}
				local primera = not pr.vencidas[b.zona.id]
				if not b.zona.guardian then
					pr.vencidas[b.zona.id] = true
				end
				-- Tomás se une al echar a las babosas de su huerto
				if primera and b.zona.id == "huerto" then
					task.delay(3, function()
						reclutar(j, "tomas")
					end)
				end
				-- ganar en tu guarida evita que te pregunte justo al acabar (sigues encima del círculo)
				noPreguntar[j] = os.clock() + 6
			end
		end
	end
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
	prompt.Style = Enum.ProximityPromptStyle.Custom -- lo dibuja el cliente (Interaccion.luau)
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
			task.delay(1.2, function()
				guardianes(j, "Tabernero Bruno", "Vale, vale… te la has ganado. La cuerda está en mi almacén de atrás… pero se ha llenado de babosas. Si las echas, es tuya.", { "vecino", "1984" },
					{ id = "pradera", nombre = "El almacén de Bruno", nivel = 2, grupos = { { "babosa", "babosa", "hongo", "babosa" } }, color = Color3.fromRGB(120, 190, 80) }, -100,
					function(g)
						notificar(g, "Bruno: «¡Mi almacén está limpio! Toma, la cuerda.»")
						darLlave(g, "cuerda")
					end)
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
			texto = "¡Mis tres setas brillantes! Gracias, joven. Con ellas te daré la llave de piedra de las Ruinas… Espera. ¿Qué es ese ruido?",
			quien = { "vecino", "60606" },
			opciones = { { texto = "¡De nada!", accion = function()
				-- unos duendes le han seguido para robar las setas: pelea antes de la llave
				task.delay(0.6, function()
					guardianes(j, "¡Duendes ladrones!", "¡Unos duendes te han seguido hasta aquí para robar las setas brillantes! Fermín se esconde detrás de ti. «¡Defiéndelas, joven!»", { "enemigo", "duende" },
						{ id = "bosque", nombre = "¡Duendes ladrones!", nivel = 4, grupos = { { "duende", "duende", "arana" } }, color = Color3.fromRGB(150, 180, 70) }, 329,
						function(g)
							notificar(g, "Fermín: «¡Gracias! Toma, la llave de piedra.»")
							darLlave(g, "llave")
							reclutar(g, "fermin")
						end)
				end)
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
	elseif nombre == "irMercado" or nombre == "irCallejon" then
		local destino = nombre == "irMercado" and "mercado" or "callejon"
		aviso(p, "Entrar", destino == "mercado" and "Calle del Mercado" or "Callejón del Gato", function(j)
			teletransportar(j, Mundo.Calles[destino].entrada)
		end)
	elseif nombre == "volverPlaza" then
		local calle = p:GetAttribute("Calle") :: string
		aviso(p, "Volver", "Plaza de Vael", function(j)
			teletransportar(j, Mundo.Calles[calle].salida)
		end)
	elseif nombre == "tendero" then
		aviso(p, "Hablar", "Frutero Paco", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Frutero Paco",
				texto = "¡Manzanas de cartón piedra, las mejores de Vael! Curan un montón. Y no engordan, porque no se pueden comer… es broma, sí se pueden.",
				quien = { "vecino", "7070" },
				opciones = {
					{ texto = "Comprar una manzana (6 oro)", accion = function()
						if perfil.oro < 6 then
							return "«Sin oro no hay manzana, colega.»"
						end
						perfil.oro -= 6
						local hp, maxHp, mp = Combate.vidaDe(j)
						Combate.ponerVida(j, math.min(maxHp, hp + math.floor(maxHp * 0.35)), mp)
						return "Crunch. Recuperas vida."
					end },
					{ texto = "Adiós" },
				},
			})
		end)
	elseif nombre == "sastre" then
		aviso(p, "Hablar", "Sastre Benito", function(j)
			dialogo(j, {
				titulo = "Sastre Benito",
				texto = "¿Ese look? Mmm… valiente. ¿Quieres que te lo arregle? Hoy cambiar de pinta sale gratis.",
				quien = { "vecino", "6262" },
				opciones = {
					{ texto = "¡Cámbiame el look!", accion = function()
						remoto("AbrirEditor"):FireClient(j)
						return nil
					end },
					{ texto = "Así estoy perfecto" },
				},
			})
		end)
	elseif nombre == "nino" then
		aviso(p, "Hablar", "Niño Lucas", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			local pr = perfil.progreso
			if pr.pelotaEntregada then
				dialogo(j, { titulo = "Niño Lucas", texto = "¡Gracias por mi pelota! Ahora juego todos los días. Bueno, cuando no hay monstruos.", quien = { "vecino", "5" }, opciones = { { texto = "De nada" } } })
			elseif pr.pelota then
				dialogo(j, {
					titulo = "Niño Lucas",
					texto = "¡MI PELOTA! ¡La encontraste en el Callejón! Toma, mi moneda de chocolate de la suerte. Y 40 de oro de mi hucha.",
					quien = { "vecino", "5" },
					opciones = { { texto = "¡Gracias, Lucas!", accion = function()
						pr.pelotaEntregada = true
						perfil.oro += 40
						Combate.darMejora(j, "chocolate")
						reclutar(j, "lucas")
						return nil
					end } },
				})
			else
				dialogo(j, { titulo = "Niño Lucas", texto = "Se me fue la pelota al Callejón del Gato y me da miedo entrar. ¿Me la traes? Está en un cofre al fondo.", quien = { "vecino", "5" }, opciones = { { texto = "¡Yo te la traigo!" } } })
			end
		end)
	elseif nombre == "adivina" then
		aviso(p, "Hablar", "Madame Zoé", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Madame Zoé",
				texto = "Acércate, acércate… Por 5 monedas leo tu destino en una bola de cristal. (Es una pecera.)",
				quien = { "vecino", "1313" },
				opciones = {
					{ texto = "Leer mi destino (5 oro)", accion = function()
						if perfil.oro < 5 then
							return "«El destino no fía, cariño.»"
						end
						perfil.oro -= 5
						local destinos = {
							"Veo… que pronto lucharás contra algo viscoso. Lleva pañuelos.",
							"Las estrellas dicen que empujar monstruos contra rocas te traerá alegría.",
							"Veo un cofre… con dientes. No lo abras con la mano buena.",
							"Tu número de la suerte es el 3. Como las palancas de las Ruinas. Qué casualidad.",
							"Veo… veo… " .. pista(perfil),
						}
						return "Madame Zoé: «" .. destinos[math.random(1, #destinos)] .. "»"
					end },
					{ texto = "No creo en estas cosas" },
				},
			})
		end)
	elseif nombre == "secreto" then
		local id = p:GetAttribute("Secreto") :: string
		local d = SECRETOS[id]
		if d then
			aviso(p, d.accion, "¿?", function(j)
				local perfil = DatosJugador.obtener(j) :: any
				local pr = perfil.progreso
				pr.secretos = pr.secretos or {}
				local nuevo = not pr.secretos[id]
				local texto = d.texto
				if id == "olla" and pr.final then
					texto = "La olla huele a Gran Guiso del bueno. Alguien ha dejado un cuenco para ti… y te cura del todo."
					Combate.curarDelTodo(j)
				end
				dialogo(j, { titulo = d.titulo, texto = texto, quien = d.quien, opciones = { { texto = d.respuesta or "Vale…" } } })
				if nuevo then
					pr.secretos[id] = true
					local n = 0
					for _ in pr.secretos do
						n += 1
					end
					perfil.oro += 5
					remoto("Sonido"):FireClient(j, "mejora")
					notificar(j, "¡Secreto encontrado! " .. n .. "/" .. TOTAL_SECRETOS .. " · +5 de oro")
					if n >= TOTAL_SECRETOS then
						task.delay(4, function()
							if j.Parent then
								Combate.darMejora(j, "corona")
								notificar(j, "¡Todos los secretos! Te ganas la Corona de cartón")
								enviarEstado(j)
							end
						end)
					end
					DatosJugador.guardar(j)
					enviarEstado(j)
				end
			end, 7)
		end
	elseif nombre == "cofreMercado" or nombre == "cofreCallejon" then
		aviso(p, "Abrir", "Cofre", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			local pr = perfil.progreso
			pr.cofres = pr.cofres or {}
			if pr.cofres[nombre] then
				notificar(j, "Está vacío. Solo hay una pelusa.")
				return
			end
			pr.cofres[nombre] = true
			remoto("Sonido"):FireClient(j, "cofre")
			if nombre == "cofreMercado" then
				perfil.oro += 30
				notificar(j, "¡30 de oro escondidos detrás de los puestos!")
			else
				pr.pelota = true
				Combate.darMejora(j, "pluma")
				notificar(j, "Dentro hay una pelota… y una pluma de gallina. Lucas estará contento.")
			end
			DatosJugador.guardar(j)
			enviarEstado(j)
		end, 6)
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
					return "«Vive en la cueva del final del camino. Lleva nuestro Cucharón de corona… y huele fatal.»"
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
				guardianes(j, "¡Un sapo enorme!", "Un sapo gordísimo está sentado encima del cofre. «Croac. Este cofre es MÍO. Y mis primos opinan igual.»", { "enemigo", "rana" },
					{ id = "pantano", nombre = "Los guardianes del cofre", nivel = 3, grupos = { { "rana", "rana", "planta" } }, color = Color3.fromRGB(90, 170, 110) }, 245,
					function(g)
						darLlave(g, "hacha")
					end)
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
				guardianes(j, "La cripta despierta", "Al tocar el cofre, la cripta tiembla. Los huesos del suelo se levantan… y no parecen contentos.", { "enemigo", "esqueleto" },
					{ id = "ruinas", nombre = "Los guardianes de la cripta", nivel = 5, grupos = { { "esqueleto", "esqueleto", "murcielago" } }, color = Color3.fromRGB(200, 190, 160) }, 432,
					function(g)
						darLlave(g, "farol")
					end)
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

-- ajustes del jugador (idioma y volumen): se guardan con la partida
remoto("GuardarAjustes").OnServerEvent:Connect(function(j, a)
	local perfil = DatosJugador.obtener(j) :: any
	if not perfil or type(a) ~= "table" then
		return
	end
	local idiomas = { es = true, en = true, pt = true, fr = true, de = true }
	perfil.ajustes = {
		idioma = idiomas[a.idioma] and a.idioma or "es",
		musica = math.clamp(tonumber(a.musica) or 0.5, 0, 1),
		efectos = math.clamp(tonumber(a.efectos) or 0.8, 0, 1),
	}
end)

-- usar pociones y éteres desde la mochila (fuera de combate)
remoto("UsarObjeto").OnServerEvent:Connect(function(j, id)
	local perfil = DatosJugador.obtener(j)
	local o = type(id) == "string" and Datos.Objetos[id] or nil
	if not perfil or not o or Combate.enBatalla(j) or (perfil.objetos[id] or 0) <= 0 then
		return
	end
	local hp, maxHp, mp, maxMp = Combate.vidaDe(j)
	if (o.cura > 0 and hp >= maxHp) and (o.mana <= 0 or mp >= maxMp) then
		notificar(j, "Ya estás como una rosa. No hace falta.")
		return
	end
	perfil.objetos[id] -= 1
	Combate.ponerVida(j, math.min(maxHp, hp + o.cura), math.min(maxMp, mp + o.mana))
	remoto("Sonido"):FireClient(j, "cura")
	notificar(j, "Usas: " .. o.nombre)
	enviarEstado(j)
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
