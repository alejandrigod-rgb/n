--!strict
-- Combate por turnos de Crónicas de Vael (todo se decide en el servidor; el cliente solo elige y anima).
--  · Equipo de hasta 4 jugadores contra un grupo de enemigos.
--  · Cada ronda actúan todos por orden de velocidad. Cada jugador tiene DATOS.TIEMPO_TURNO segundos para elegir;
--    si no elige, su héroe ataca solo.
--  · Otros jugadores pueden unirse a mitad de combate pulsando el anillo de la batalla (entran en la ronda siguiente).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Datos = require(ReplicatedStorage.Vael.Datos)
local DatosJugador = require(script.Parent.DatosJugador)

local Combate = {}

type Estados = { veneno: number, defensa: number, furia: number, defendiendo: boolean }
export type Entidad = {
	id: string,
	nombre: string,
	lado: "aliado" | "enemigo",
	jugador: Player?,
	claseId: string?,
	enemigoId: string?,
	nivel: number,
	max: Datos.Stats,
	hp: number,
	mp: number,
	estados: Estados,
	vivo: boolean,
	modelo: Model?,
	casa: CFrame, -- dónde está en el campo de batalla
}
type Accion = { tipo: string, id: string?, objetivo: string? }
export type Batalla = {
	id: number,
	zona: any,
	centro: Vector3,
	aliados: { Entidad },
	enemigos: { Entidad },
	pendientes: { Player },
	ronda: number,
	terminada: boolean,
	respuestas: { [string]: Accion },
	anillo: BasePart?,
	huida: boolean,
}

local Remotos: Folder
local rng = Random.new()
local siguienteId = 0
local batallaDe: { [Player]: Batalla } = {}
-- vida y maná actuales de cada jugador (se conservan entre combates hasta la fuente)
local vida: { [Player]: { hp: number, mp: number } } = {}

Combate.alTerminar = nil :: ((Batalla) -> ())?
Combate.alCambiarJugador = nil :: ((Player) -> ())?

local function remoto(nombre: string): RemoteEvent
	return Remotos:WaitForChild(nombre) :: RemoteEvent
end

function Combate.iniciar(remotos: Folder)
	Remotos = remotos
	remoto("EnviarAccion").OnServerEvent:Connect(function(jugador: Player, accion: any)
		local b = batallaDe[jugador]
		if not b or type(accion) ~= "table" then
			return
		end
		for _, e in b.aliados do
			if e.jugador == jugador then
				b.respuestas[e.id] = { tipo = tostring(accion.tipo), id = accion.id and tostring(accion.id) or nil, objetivo = accion.objetivo and tostring(accion.objetivo) or nil }
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(j)
		local b = batallaDe[j]
		if b then
			for _, e in b.aliados do
				if e.jugador == j then
					e.vivo = false
					e.hp = 0
					e.jugador = nil
				end
			end
		end
		batallaDe[j] = nil
		vida[j] = nil
	end)
end

function Combate.enBatalla(j: Player): boolean
	return batallaDe[j] ~= nil
end

--- Vida y maná actuales del jugador (con sus máximos según clase y nivel).
function Combate.vidaDe(j: Player): (number, number, number, number)
	local perfil = DatosJugador.obtener(j)
	if not perfil or not perfil.clase then
		return 0, 0, 0, 0
	end
	local s = Datos.statsDe(perfil.clase, perfil.nivel)
	local v = vida[j]
	if not v then
		v = { hp = s.hp, mp = s.mp }
		vida[j] = v
	end
	v.hp = math.min(v.hp, s.hp)
	v.mp = math.min(v.mp, s.mp)
	return v.hp, s.hp, v.mp, s.mp
end

function Combate.curarDelTodo(j: Player)
	local perfil = DatosJugador.obtener(j)
	if perfil and perfil.clase then
		local s = Datos.statsDe(perfil.clase, perfil.nivel)
		vida[j] = { hp = s.hp, mp = s.mp }
	end
end

-- ===================== MODELOS DE LOS ENEMIGOS =====================
-- El servidor solo pone un "ancla" invisible por enemigo. Cada cliente le pega encima su muñeco 2D de recortes
-- (src/client/Munecos.luau), animado a 60 fps en el propio cliente. Así el servidor mueve el ancla (embestida)
-- y el muñeco la sigue sin tirones.
local function crearModelo(def: Datos.Enemigo, cf: CFrame, entidadId: string): Model
	local m = Instance.new("Model")
	m.Name = def.nombre
	local t = def.tamano
	local ancla = Instance.new("Part")
	ancla.Name = "Ancla"
	ancla.Size = Vector3.new(t, t, 0.5)
	ancla.CFrame = cf * CFrame.new(0, t / 2, 0)
	ancla.Transparency = 1
	ancla.Anchored = true
	ancla.CanCollide = false
	ancla.CanQuery = false
	ancla.Parent = m
	m.PrimaryPart = ancla
	m:SetAttribute("EnemigoId", def.id)
	m:SetAttribute("EntidadId", entidadId)
	-- cartel con nombre y barra de vida (estilo dibujo: contorno negro grueso)
	local b = Instance.new("BillboardGui")
	b.Name = "Vida"
	b.Size = UDim2.fromOffset(170, 44)
	b.StudsOffsetWorldSpace = Vector3.new(0, t * 0.62 + 1.6, 0)
	b.AlwaysOnTop = true
	b.MaxDistance = 150
	b.Adornee = ancla
	local nombre = Instance.new("TextLabel")
	nombre.Size = UDim2.new(1, 0, 0.55, 0)
	nombre.BackgroundTransparency = 1
	nombre.Text = def.nombre
	nombre.Font = Enum.Font.FredokaOne
	nombre.TextScaled = true
	nombre.TextColor3 = Color3.new(1, 1, 1)
	nombre.TextStrokeTransparency = 0
	nombre.Parent = b
	local fondo = Instance.new("Frame")
	fondo.Size = UDim2.new(1, -8, 0.3, 0)
	fondo.Position = UDim2.new(0, 4, 0.62, 0)
	fondo.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
	fondo.BorderSizePixel = 0
	Instance.new("UICorner", fondo).CornerRadius = UDim.new(1, 0)
	local borde = Instance.new("UIStroke")
	borde.Thickness = 2.5
	borde.Color = Color3.new(0, 0, 0)
	borde.Parent = fondo
	fondo.Parent = b
	local barra = Instance.new("Frame")
	barra.Name = "Barra"
	barra.Size = UDim2.fromScale(1, 1)
	barra.BackgroundColor3 = Color3.fromRGB(240, 70, 70)
	barra.BorderSizePixel = 0
	Instance.new("UICorner", barra).CornerRadius = UDim.new(1, 0)
	barra.Parent = fondo
	b.Parent = ancla
	m.Parent = workspace
	return m
end

local function actualizarBarra(e: Entidad)
	if e.modelo and e.modelo.PrimaryPart then
		local b = e.modelo.PrimaryPart:FindFirstChild("Vida")
		local barra = b and b:FindFirstChild("Barra", true) :: Frame?
		if barra then
			TweenService:Create(barra, TweenInfo.new(0.3), { Size = UDim2.fromScale(math.max(0, e.hp / e.max.hp), 1) }):Play()
		end
	end
end

-- ===================== AYUDAS =====================
local function rivales(b: Batalla, e: Entidad): { Entidad }
	local lista = e.lado == "aliado" and b.enemigos or b.aliados
	local vivos = {}
	for _, x in lista do
		if x.vivo then
			table.insert(vivos, x)
		end
	end
	return vivos
end

local function companeros(b: Batalla, e: Entidad, incluirCaidos: boolean?): { Entidad }
	local lista = e.lado == "aliado" and b.aliados or b.enemigos
	local r = {}
	for _, x in lista do
		if x.vivo or incluirCaidos then
			table.insert(r, x)
		end
	end
	return r
end

local function buscar(b: Batalla, id: string?): Entidad?
	if not id then
		return nil
	end
	for _, e in b.aliados do
		if e.id == id then
			return e
		end
	end
	for _, e in b.enemigos do
		if e.id == id then
			return e
		end
	end
	return nil
end

local function jugadoresDe(b: Batalla): { Player }
	local r = {}
	for _, e in b.aliados do
		if e.jugador and e.jugador.Parent then
			table.insert(r, e.jugador)
		end
	end
	return r
end

local function aTodos(b: Batalla, remoto: string, datos: any)
	local ev = Remotos:FindFirstChild(remoto) :: RemoteEvent
	for _, j in jugadoresDe(b) do
		ev:FireClient(j, datos)
	end
end

local function resumen(e: Entidad, paraJugador: Player?): any
	local pos = e.modelo and e.modelo.PrimaryPart and e.modelo.PrimaryPart.Position or e.casa.Position
	if e.jugador and e.jugador.Character and e.jugador.Character.PrimaryPart then
		pos = e.jugador.Character.PrimaryPart.Position
	end
	return {
		id = e.id,
		nombre = e.nombre,
		lado = e.lado,
		clase = e.claseId,
		enemigo = e.enemigoId,
		nivel = e.nivel,
		hp = e.hp,
		maxHp = e.max.hp,
		mp = e.mp,
		maxMp = e.max.mp,
		vivo = e.vivo,
		esMio = paraJugador ~= nil and e.jugador == paraJugador,
		pos = pos,
		veneno = e.estados.veneno > 0,
		defensa = e.estados.defensa > 0 or e.estados.defendiendo,
		furia = e.estados.furia > 0,
	}
end

local function emitirEstado(b: Batalla, orden: { Entidad }?)
	local ev = Remotos:FindFirstChild("BatallaEstado") :: RemoteEvent
	for _, j in jugadoresDe(b) do
		local aliados, enemigos, ids = {}, {}, {}
		for _, e in b.aliados do
			table.insert(aliados, resumen(e, j))
		end
		for _, e in b.enemigos do
			table.insert(enemigos, resumen(e, j))
		end
		if orden then
			for _, e in orden do
				table.insert(ids, e.id)
			end
		end
		ev:FireClient(j, { id = b.id, zona = b.zona.nombre, ronda = b.ronda, aliados = aliados, enemigos = enemigos, orden = orden and ids or nil, centro = b.centro })
	end
end

local function guardarVida(e: Entidad)
	if e.jugador then
		vida[e.jugador] = { hp = e.hp, mp = e.mp }
	end
end

-- ===================== ANIMACIONES EN EL MUNDO =====================
local function embestida(actor: Entidad, objetivo: Entidad?)
	local destino = objetivo and objetivo.casa.Position or actor.casa.Position
	local dir = (destino - actor.casa.Position)
	local paso = dir.Magnitude > 0.1 and dir.Unit * math.min(6, dir.Magnitude * 0.4) or Vector3.zero
	if actor.modelo then
		local m = actor.modelo
		local origen = m:GetPivot()
		local valor = Instance.new("CFrameValue")
		valor.Value = origen
		valor.Changed:Connect(function(v)
			m:PivotTo(v)
		end)
		local ida = TweenService:Create(valor, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = origen + paso })
		ida:Play()
		ida.Completed:Wait()
		local vuelta = TweenService:Create(valor, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Value = origen })
		vuelta:Play()
		vuelta.Completed:Wait()
		valor:Destroy()
	elseif actor.jugador and actor.jugador.Character then
		local raiz = actor.jugador.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if raiz then
			local origen = raiz.CFrame
			local ida = TweenService:Create(raiz, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = origen + paso })
			ida:Play()
			ida.Completed:Wait()
			local vuelta = TweenService:Create(raiz, TweenInfo.new(0.25), { CFrame = origen })
			vuelta:Play()
			vuelta.Completed:Wait()
		end
	end
end

local function caer(e: Entidad)
	if e.modelo then
		e.modelo:SetAttribute("Caido", true)
		local vidaGui = e.modelo.PrimaryPart and e.modelo.PrimaryPart:FindFirstChild("Vida")
		if vidaGui then
			(vidaGui :: BillboardGui).Enabled = false
		end
	end
end

-- ===================== ACCIONES =====================
type Golpe = { id: string, cantidad: number, tipo: string, critico: boolean? }

local function aplicarDano(b: Batalla, actor: Entidad, objetivo: Entidad, atributo: number, poder: number, critExtra: number): Golpe
	local mult = actor.estados.furia > 0 and 1.3 or 1
	local d = Datos.dano(atributo * mult, poder, objetivo.max.def, rng)
	local critico = rng:NextNumber() < 0.08 + critExtra
	if critico then
		d = math.floor(d * 1.6)
	end
	if objetivo.estados.defendiendo or objetivo.estados.defensa > 0 then
		d = math.max(1, math.floor(d * 0.5))
	end
	objetivo.hp = math.max(0, objetivo.hp - d)
	if objetivo.hp <= 0 then
		objetivo.vivo = false
		objetivo.estados = { veneno = 0, defensa = 0, furia = 0, defendiendo = false }
		caer(objetivo)
	end
	actualizarBarra(objetivo)
	guardarVida(objetivo)
	return { id = objetivo.id, cantidad = d, tipo = "dano", critico = critico }
end

local function curar(objetivo: Entidad, cantidad: number): Golpe
	local antes = objetivo.hp
	objetivo.hp = math.min(objetivo.max.hp, objetivo.hp + cantidad)
	actualizarBarra(objetivo)
	guardarVida(objetivo)
	return { id = objetivo.id, cantidad = objetivo.hp - antes, tipo = "cura" }
end

local function elegirUno(lista: { Entidad }, preferido: string?): Entidad?
	for _, e in lista do
		if e.id == preferido then
			return e
		end
	end
	return lista[1]
end

local function ejecutar(b: Batalla, actor: Entidad, accion: Accion)
	local golpes: { Golpe } = {}
	local texto = ""
	local habilidadId: string? = nil
	local perfil = actor.jugador and DatosJugador.obtener(actor.jugador)

	if accion.tipo == "habilidad" and accion.id then
		local h = Datos.Habilidades[accion.id]
		local permitida = h ~= nil and actor.mp >= h.coste
		if permitida and actor.lado == "aliado" then
			local clase = actor.claseId and Datos.Clases[actor.claseId]
			permitida = clase ~= nil and table.find(clase.habilidades, h.id) ~= nil and actor.nivel >= h.nivelMinimo
		end
		if not permitida then
			accion = { tipo = "atacar", objetivo = accion.objetivo }
		else
			actor.mp -= h.coste
			habilidadId = h.id
			texto = actor.nombre .. " usa " .. h.nombre
			local atributo = h.base == "mag" and actor.max.mag or actor.max.atk
			local objetivos: { Entidad } = {}
			if h.objetivo == "enemigo" then
				local o = elegirUno(rivales(b, actor), accion.objetivo)
				if o then
					objetivos = { o }
				end
			elseif h.objetivo == "enemigos" then
				objetivos = rivales(b, actor)
			elseif h.objetivo == "aliado" then
				local lista = companeros(b, actor, h.tipo == "revivir")
				if h.tipo == "revivir" then
					local caidos = {}
					for _, x in lista do
						if not x.vivo then
							table.insert(caidos, x)
						end
					end
					lista = caidos
				end
				local o = elegirUno(lista, accion.objetivo)
				if o then
					objetivos = { o }
				end
			elseif h.objetivo == "aliados" then
				objetivos = companeros(b, actor)
			else
				objetivos = { actor }
			end
			if #objetivos > 0 and (h.tipo == "dano") then
				embestida(actor, objetivos[1])
			end
			for _, o in objetivos do
				if h.tipo == "dano" then
					table.insert(golpes, aplicarDano(b, actor, o, atributo, h.poder, h.critExtra or 0))
					if h.efecto == "veneno" and o.vivo then
						o.estados.veneno = 3
					end
				elseif h.tipo == "cura" then
					table.insert(golpes, curar(o, math.floor(atributo * h.poder * rng:NextNumber(0.95, 1.05))))
				elseif h.tipo == "revivir" then
					o.vivo = true
					o.hp = 0
					table.insert(golpes, curar(o, math.floor(o.max.hp * h.poder)))
				elseif h.tipo == "mejora" then
					if h.efecto == "furia" then
						o.estados.furia = 3
					elseif h.efecto == "defensa" then
						o.estados.defensa = 3
					end
					table.insert(golpes, { id = o.id, cantidad = 0, tipo = h.efecto or "mejora" })
				end
			end
			if #objetivos == 0 then
				texto ..= "… pero no hay a quién"
			end
		end
	end

	if accion.tipo == "objeto" and perfil and accion.id and Datos.Objetos[accion.id] and (perfil.objetos[accion.id] or 0) > 0 then
		local o = Datos.Objetos[accion.id]
		perfil.objetos[accion.id] -= 1
		local destino = elegirUno(companeros(b, actor), accion.objetivo) or actor
		texto = actor.nombre .. " usa " .. o.nombre .. (destino ~= actor and (" con " .. destino.nombre) or "")
		if o.cura > 0 then
			table.insert(golpes, curar(destino, o.cura))
		end
		if o.mana > 0 then
			destino.mp = math.min(destino.max.mp, destino.mp + o.mana)
			guardarVida(destino)
			table.insert(golpes, { id = destino.id, cantidad = o.mana, tipo = "mana" })
		end
	elseif accion.tipo == "objeto" then
		accion = { tipo = "defender" }
	end

	if accion.tipo == "defender" then
		actor.estados.defendiendo = true
		texto = actor.nombre .. " se defiende"
		table.insert(golpes, { id = actor.id, cantidad = 0, tipo = "defensa" })
	elseif accion.tipo == "huir" then
		local hayJefe = false
		for _, e in b.enemigos do
			if e.enemigoId == "reyHongo" then
				hayJefe = true
			end
		end
		if not hayJefe and rng:NextNumber() < 0.6 then
			texto = actor.nombre .. " grita «¡corred!» y el equipo escapa"
			b.huida = true
		else
			texto = hayJefe and "¡No se puede huir del Rey Hongo!" or (actor.nombre .. " intenta huir… pero no puede")
		end
	elseif accion.tipo == "atacar" then
		local o = elegirUno(rivales(b, actor), accion.objetivo)
		if o then
			embestida(actor, o)
			texto = actor.nombre .. " ataca a " .. o.nombre
			table.insert(golpes, aplicarDano(b, actor, o, actor.max.atk, 1, 0))
		end
	end

	aTodos(b, "BatallaEvento", { texto = texto, actor = actor.id, habilidad = habilidadId, golpes = golpes })
end

-- ===================== TURNOS =====================
local function turnoJugador(b: Batalla, e: Entidad)
	local j = e.jugador
	if not j or not j.Parent then
		e.vivo = false
		return
	end
	local perfil = DatosJugador.obtener(j)
	local clase = e.claseId and Datos.Clases[e.claseId]
	local habilidades = {}
	if clase then
		for _, hid in clase.habilidades do
			local h = Datos.Habilidades[hid]
			table.insert(habilidades, { id = h.id, nombre = h.nombre, descripcion = h.descripcion, coste = h.coste, objetivo = h.objetivo, tipo = h.tipo, bloqueada = e.nivel < h.nivelMinimo, nivelMinimo = h.nivelMinimo, sinMana = e.mp < h.coste })
		end
	end
	local objetos = {}
	for _, oid in Datos.OrdenObjetos do
		table.insert(objetos, { id = oid, nombre = Datos.Objetos[oid].nombre, cantidad = perfil and perfil.objetos[oid] or 0, descripcion = Datos.Objetos[oid].descripcion })
	end
	b.respuestas[e.id] = nil
	aTodos(b, "BatallaTurno", { id = e.id, nombre = e.nombre, tiempo = Datos.TIEMPO_TURNO })
	remoto("PedirAccion"):FireClient(j, { entidad = e.id, tiempo = Datos.TIEMPO_TURNO, habilidades = habilidades, objetos = objetos })
	local limite = os.clock() + Datos.TIEMPO_TURNO
	while os.clock() < limite and not b.respuestas[e.id] and j.Parent do
		task.wait(0.1)
	end
	local accion = b.respuestas[e.id] or { tipo = "atacar" }
	b.respuestas[e.id] = nil
	ejecutar(b, e, accion)
end

local function turnoEnemigo(b: Batalla, e: Entidad)
	local def = e.enemigoId and Datos.Enemigos[e.enemigoId]
	local objetivos = rivales(b, e)
	if #objetivos == 0 then
		return
	end
	-- a veces va a por el más débil
	table.sort(objetivos, function(a, c)
		return a.hp < c.hp
	end)
	local objetivo = rng:NextNumber() < 0.35 and objetivos[1] or objetivos[rng:NextInteger(1, #objetivos)]
	aTodos(b, "BatallaTurno", { id = e.id, nombre = e.nombre, tiempo = 0 })
	task.wait(0.5)
	if def and #def.habilidades > 0 and rng:NextNumber() < def.probHabilidad then
		ejecutar(b, e, { tipo = "habilidad", id = def.habilidades[rng:NextInteger(1, #def.habilidades)], objetivo = objetivo.id })
	else
		ejecutar(b, e, { tipo = "atacar", objetivo = objetivo.id })
	end
end

-- Veneno y duración de las mejoras al empezar el turno de cada uno.
local function inicioTurno(b: Batalla, e: Entidad)
	e.estados.defendiendo = false
	if e.estados.veneno > 0 then
		e.estados.veneno -= 1
		local d = math.max(1, math.floor(e.max.hp * 0.07))
		e.hp = math.max(0, e.hp - d)
		if e.hp <= 0 then
			e.vivo = false
			caer(e)
		end
		actualizarBarra(e)
		guardarVida(e)
		aTodos(b, "BatallaEvento", { texto = e.nombre .. " sufre el veneno", actor = e.id, golpes = { { id = e.id, cantidad = d, tipo = "veneno" } } })
		task.wait(0.5)
	end
	if e.estados.defensa > 0 then
		e.estados.defensa -= 1
	end
	if e.estados.furia > 0 then
		e.estados.furia -= 1
	end
end

-- ===================== ENTRAR Y SALIR DEL COMBATE =====================
local function congelar(j: Player, cf: CFrame?)
	local ch = j.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hum and raiz then
		if cf then
			hum.WalkSpeed = 0
			hum.JumpPower = 0
			hum.UseJumpPower = true
			raiz.Anchored = true
			raiz.CFrame = cf
		else
			raiz.Anchored = false
			hum.WalkSpeed = 16
			hum.JumpPower = 50
		end
	end
end

local function entidadJugador(b: Batalla, j: Player, indice: number): Entidad?
	local perfil = DatosJugador.obtener(j)
	if not perfil or not perfil.clase then
		return nil
	end
	local hp, maxHp, mp, maxMp = Combate.vidaDe(j)
	local stats = Datos.statsDe(perfil.clase, perfil.nivel)
	-- vista de lado: el equipo a la izquierda, los enemigos a la derecha, con un poco de profundidad alterna
	local pos = b.centro + Vector3.new(-7 - (indice - 1) * 4.2, 3, indice % 2 == 0 and -2.2 or 1.6)
	local casa = CFrame.lookAt(pos, pos + Vector3.new(1, 0, 0))
	congelar(j, casa)
	batallaDe[j] = b
	return {
		id = "j" .. j.UserId,
		nombre = j.DisplayName,
		lado = "aliado",
		jugador = j,
		claseId = perfil.clase,
		nivel = perfil.nivel,
		max = stats,
		hp = hp > 0 and hp or math.max(1, math.floor(maxHp * 0.3)),
		mp = mp,
		estados = { veneno = 0, defensa = 0, furia = 0, defendiendo = false },
		vivo = true,
		casa = casa,
	} :: Entidad
end

local function incorporarPendientes(b: Batalla)
	for _, j in b.pendientes do
		if j.Parent and not batallaDe[j] and #b.aliados < Datos.MAX_EQUIPO then
			local e = entidadJugador(b, j, #b.aliados + 1)
			if e then
				table.insert(b.aliados, e)
				aTodos(b, "BatallaEvento", { texto = j.DisplayName .. " se une al combate", actor = e.id, golpes = {} })
				remoto("BatallaInicio"):FireClient(j, { centro = b.centro, zona = b.zona.nombre })
			end
		end
	end
	b.pendientes = {}
end

local function terminar(b: Batalla, victoria: boolean)
	b.terminada = true
	if b.anillo then
		b.anillo:Destroy()
	end
	local xp, oro = 0, 0
	for _, e in b.enemigos do
		local def = e.enemigoId and Datos.Enemigos[e.enemigoId]
		if def then
			xp += def.xp
			oro += def.oro
		end
	end
	task.wait(1.2)
	for _, e in b.aliados do
		local j = e.jugador
		if j and j.Parent then
			local perfil = DatosJugador.obtener(j)
			local resultado: any = { victoria = victoria, huida = b.huida }
			if perfil then
				if victoria then
					perfil.xp += xp
					perfil.oro += oro
					local subio = false
					while perfil.xp >= Datos.xpParaNivel(perfil.nivel) do
						perfil.xp -= Datos.xpParaNivel(perfil.nivel)
						perfil.nivel += 1
						subio = true
					end
					local botin = nil
					if rng:NextNumber() < 0.3 then
						botin = rng:NextNumber() < 0.7 and "pocion" or "eter"
						perfil.objetos[botin] = (perfil.objetos[botin] or 0) + 1
					end
					resultado.xp, resultado.oro, resultado.subio, resultado.nivel = xp, oro, subio, perfil.nivel
					resultado.botin = botin and Datos.Objetos[botin].nombre or nil
					if subio then
						Combate.curarDelTodo(j)
					elseif not e.vivo then
						vida[j] = { hp = math.max(1, math.floor(e.max.hp * 0.3)), mp = e.mp }
					end
				elseif not b.huida then
					-- derrota: vuelve a la aldea con la vida llena y pierde un 10 % del oro
					resultado.oroPerdido = math.floor(perfil.oro * 0.1)
					perfil.oro -= resultado.oroPerdido
					Combate.curarDelTodo(j)
				end
				DatosJugador.guardar(j)
			end
			congelar(j, nil)
			batallaDe[j] = nil
			remoto("BatallaFin"):FireClient(j, resultado)
			if not victoria and not b.huida and j.Character then
				j:LoadCharacter()
			end
			if Combate.alCambiarJugador then
				Combate.alCambiarJugador(j)
			end
		end
	end
	for _, e in b.enemigos do
		if e.modelo then
			e.modelo:Destroy()
		end
	end
	if Combate.alTerminar then
		Combate.alTerminar(b)
	end
end

local function comprobarFin(b: Batalla): boolean
	if b.huida then
		terminar(b, false)
		return true
	end
	local aliadosVivos, enemigosVivos = 0, 0
	for _, e in b.aliados do
		if e.vivo and e.jugador then
			aliadosVivos += 1
		end
	end
	for _, e in b.enemigos do
		if e.vivo then
			enemigosVivos += 1
		end
	end
	if enemigosVivos == 0 then
		terminar(b, true)
		return true
	elseif aliadosVivos == 0 then
		terminar(b, false)
		return true
	end
	return false
end

--- Empieza un combate en una zona con los jugadores dados (hasta 4).
function Combate.empezar(zona: any, centro: Vector3, jugadores: { Player }): Batalla?
	centro = Vector3.new(centro.X, 0, 0)
	siguienteId += 1
	local b: Batalla = { id = siguienteId, zona = zona, centro = centro, aliados = {}, enemigos = {}, pendientes = {}, ronda = 0, terminada = false, respuestas = {}, huida = false }
	for i, j in jugadores do
		if i <= Datos.MAX_EQUIPO then
			local e = entidadJugador(b, j, i)
			if e then
				table.insert(b.aliados, e)
			end
		end
	end
	if #b.aliados == 0 then
		return nil
	end
	-- enemigos: un grupo al azar de la zona, más fuertes si hay más jugadores
	local grupo = zona.grupos[rng:NextInteger(1, #zona.grupos)]
	local escala = 1 + 0.45 * (#b.aliados - 1)
	for i, eid in grupo do
		local def = Datos.Enemigos[eid]
		local pos = centro + Vector3.new(7 + (i - 1) * (def.tamano * 0.55 + 2.6), 0, i % 2 == 0 and -2.4 or 1.4)
		local cf = CFrame.new(pos)
		local stats = table.clone(def.stats)
		stats.hp = math.floor(stats.hp * escala)
		local e: Entidad = {
			id = "e" .. i,
			nombre = def.nombre,
			lado = "enemigo",
			enemigoId = eid,
			nivel = zona.nivel,
			max = stats,
			hp = stats.hp,
			mp = 0,
			estados = { veneno = 0, defensa = 0, furia = 0, defendiendo = false },
			vivo = true,
			casa = cf,
		}
		e.modelo = crearModelo(def, cf, e.id)
		table.insert(b.enemigos, e)
	end
	-- anillo para que otros se unan
	local anillo = Instance.new("Part")
	anillo.Anchored = true
	anillo.CanCollide = false
	anillo.Shape = Enum.PartType.Cylinder
	anillo.Size = Vector3.new(0.4, 44, 44)
	anillo.CFrame = CFrame.new(centro + Vector3.new(0, 0.7, 0)) * CFrame.Angles(0, 0, math.rad(90))
	anillo.Material = Enum.Material.ForceField
	anillo.Color = Color3.fromRGB(255, 220, 120)
	anillo.Parent = workspace
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Unirse al combate"
	prompt.ObjectText = zona.nombre
	prompt.MaxActivationDistance = 30
	prompt.RequiresLineOfSight = false
	prompt.Parent = anillo
	prompt.Triggered:Connect(function(j)
		if not batallaDe[j] and not table.find(b.pendientes, j) and #b.aliados + #b.pendientes < Datos.MAX_EQUIPO then
			local perfil = DatosJugador.obtener(j)
			if perfil and perfil.clase then
				table.insert(b.pendientes, j)
				local n = Remotos:FindFirstChild("Notificar") :: RemoteEvent
				n:FireClient(j, "Entrarás en la próxima ronda")
			end
		end
	end)
	b.anillo = anillo

	for _, j in jugadoresDe(b) do
		remoto("BatallaInicio"):FireClient(j, { centro = centro, zona = zona.nombre })
	end

	task.spawn(function()
		task.wait(1.5)
		while not b.terminada do
			b.ronda += 1
			incorporarPendientes(b)
			local orden = {}
			for _, e in b.aliados do
				if e.vivo then
					table.insert(orden, e)
				end
			end
			for _, e in b.enemigos do
				if e.vivo then
					table.insert(orden, e)
				end
			end
			local azar: { [string]: number } = {}
			for _, e in orden do
				azar[e.id] = e.max.spd + rng:NextNumber(0, 3)
			end
			table.sort(orden, function(a, c)
				return azar[a.id] > azar[c.id]
			end)
			emitirEstado(b, orden)
			for _, e in orden do
				if b.terminada then
					break
				end
				if e.vivo then
					inicioTurno(b, e)
					if e.vivo then
						if e.lado == "aliado" then
							turnoJugador(b, e)
						else
							turnoEnemigo(b, e)
						end
					end
					emitirEstado(b, orden)
					if comprobarFin(b) then
						break
					end
					task.wait(0.4)
				end
			end
		end
	end)
	return b
end

return Combate
