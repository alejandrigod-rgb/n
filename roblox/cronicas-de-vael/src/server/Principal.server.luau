--!strict
-- Crónicas de Vael · servidor. Arranca el mundo, las partidas guardadas, las zonas de combate, la fuente y el mercader.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael.Datos)
local DatosJugador = require(script.Parent.DatosJugador)
local Combate = require(script.Parent.Combate)
local Mundo = require(script.Parent.Mundo)

-- remotos (servidor ↔ cliente)
local Remotos = Instance.new("Folder")
Remotos.Name = "Remotos"
for _, nombre in { "ElegirClase", "EstadoJugador", "BatallaInicio", "BatallaEstado", "BatallaEvento", "BatallaTurno", "PedirAccion", "EnviarAccion", "BatallaFin", "Notificar", "AbrirTienda", "Comprar" } do
	local r = Instance.new("RemoteEvent")
	r.Name = nombre
	r.Parent = Remotos
end
Remotos.Parent = Vael

local function remoto(nombre: string): RemoteEvent
	return Remotos:FindFirstChild(nombre) :: RemoteEvent
end

Combate.iniciar(Remotos)

--- Manda al cliente su estado (para el HUD).
local function enviarEstado(j: Player)
	local perfil = DatosJugador.obtener(j)
	if not perfil then
		return
	end
	local hp, maxHp, mp, maxMp = Combate.vidaDe(j)
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
	})
end
Combate.alCambiarJugador = enviarEstado

local function notificar(j: Player, texto: string)
	remoto("Notificar"):FireClient(j, texto)
end

-- jugadores
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

-- mundo y zonas de combate
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
		disco.Transparency = 0.9
		local b = Combate.empezar(zona, disco.Position - Vector3.new(0, disco.Position.Y, 0), equipo)
		if not b then
			ocupada[disco] = false
			disco.Transparency = 0.55
		end
	end)
end

Combate.alTerminar = function(b)
	for disco, zona in zonas do
		if zona == b.zona and ocupada[disco] then
			ocupada[disco] = false
			enfriamiento[disco] = os.clock() + 4
			disco.Transparency = 0.55
		end
	end
end

-- la fuente: cura vida y maná
local mundo = workspace:WaitForChild("MundoVael")
local ultimaFuente: { [Player]: number } = {}
for _, d in mundo:GetDescendants() do
	if d:IsA("BasePart") and d:GetAttribute("Fuente") then
		d.Touched:Connect(function(toca)
			local j = jugadorDe(toca)
			if j and not Combate.enBatalla(j) and os.clock() > (ultimaFuente[j] or 0) then
				ultimaFuente[j] = os.clock() + 3
				Combate.curarDelTodo(j)
				enviarEstado(j)
				notificar(j, "La fuente te cura del todo")
			end
		end)
	end
	if d:IsA("BasePart") and d:GetAttribute("Mercader") then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Comprar"
		prompt.ObjectText = "Mercader"
		prompt.MaxActivationDistance = 12
		prompt.Parent = d
		prompt.Triggered:Connect(function(j)
			local lista = {}
			for _, oid in Datos.OrdenObjetos do
				local o = Datos.Objetos[oid]
				table.insert(lista, { id = oid, nombre = o.nombre, descripcion = o.descripcion, precio = o.precio })
			end
			remoto("AbrirTienda"):FireClient(j, lista)
		end)
	end
end

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

-- autoguardado cada 2 minutos
task.spawn(function()
	while true do
		task.wait(120)
		for _, j in Players:GetPlayers() do
			DatosJugador.guardar(j)
		end
	end
end)
