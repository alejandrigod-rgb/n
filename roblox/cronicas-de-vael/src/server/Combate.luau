--!strict
-- Combate por turnos con casillas (táctico) de Crónicas de Vael. Todo se decide en el servidor; el cliente elige y anima.
--  · Campo de batalla de 10 × 4 casillas: tu equipo empieza a la izquierda y los monstruos a la derecha.
--  · En tu turno puedes MOVERTE (hasta tu movimiento) y luego hacer UNA acción: atacar, habilidad, objeto, defender o huir.
--  · Alcance: cuerpo a cuerpo (1 casilla) o a distancia. Detrás de una roca en tu misma fila, los disparos hacen la mitad.
--  · Empujones: algunos golpes empujan. Si el empujado choca con una roca, el borde u otro, se lleva un golpe extra.
--  · Trampas: pinchos (daño), barro (te para) y setas (curan).
--  · Mejoras (Datos.Mejoras): se suman y algunas se combinan entre sí.
--  · Otros jugadores se unen a mitad de combate con el aviso "Unirse al combate" (entran en la ronda siguiente).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Datos = require(ReplicatedStorage.Vael.Datos)
local DatosJugador = require(script.Parent.DatosJugador)

local Combate = {}

local R = Datos.Rejilla

type Estados = { veneno: number, defensa: number, furia: number, defendiendo: boolean, revivido: boolean }
export type Entidad = {
	id: string,
	nombre: string,
	lado: "aliado" | "enemigo",
	jugador: Player?,
	claseId: string?,
	enemigoId: string?,
	companeroId: string?,
	nivel: number,
	max: Datos.Stats,
	hp: number,
	mp: number,
	estados: Estados,
	vivo: boolean,
	modelo: Model?,
	col: number,
	fila: number,
	mov: number,
	alcance: number,
	vuela: boolean,
	mods: { [string]: any },
}
type Accion = { tipo: string, id: string?, objetivo: string?, col: number?, fila: number? }
type Golpe = { id: string, cantidad: number, tipo: string, critico: boolean?, choque: boolean?, cubierto: boolean? }
export type Batalla = {
	id: number,
	zona: any,
	centro: Vector3,
	origen: Vector3,
	aliados: { Entidad },
	enemigos: { Entidad },
	pendientes: { Player },
	ronda: number,
	terminada: boolean,
	respuestas: { [string]: Accion },
	anillo: BasePart?,
	huida: boolean,
	jefe: boolean,
	casillas: { [string]: string },
	decorados: { [string]: Instance },
	carpeta: Folder,
	emboscada: boolean,
	alGanar: ((Player) -> ())?,
	victoria: boolean?,
	jefeId: string?,
}

local Remotos: Folder
local rng = Random.new()
local siguienteId = 0
local batallaDe: { [Player]: Batalla } = {}
-- vida y maná actuales de cada jugador (se conservan entre combates hasta la fuente)
local vida: { [Player]: { hp: number, mp: number } } = {}
-- mejoras ofrecidas y aún sin elegir
local ofertas: { [Player]: { string } } = {}

Combate.alTerminar = nil :: ((Batalla) -> ())?
Combate.alCambiarJugador = nil :: ((Player) -> ())?

local function remoto(nombre: string): RemoteEvent
	return Remotos:WaitForChild(nombre) :: RemoteEvent
end

local function notificar(j: Player, texto: string)
	remoto("Notificar"):FireClient(j, texto)
end

-- ===================== MEJORAS =====================
--- Ofrece 3 mejoras a un jugador (cofre, jefe). Elige con el remoto "ElegirMejora".
function Combate.ofrecerMejoras(j: Player, origen: string)
	local opciones = Datos.ofertaMejoras(rng, origen == "jefe")
	ofertas[j] = opciones
	remoto("OfrecerMejoras"):FireClient(j, { origen = origen, opciones = opciones })
end

--- Da una mejora al jugador y avisa si activa una combinación.
function Combate.darMejora(j: Player, id: string)
	local perfil = DatosJugador.obtener(j)
	if not perfil or not Datos.Mejoras[id] then
		return
	end
	local _, antes = Datos.efectosDe(perfil.mejoras)
	table.insert(perfil.mejoras, id)
	local _, despues = Datos.efectosDe(perfil.mejoras)
	notificar(j, "Mejora: " .. Datos.Mejoras[id].nombre)
	for _, nombre in despues do
		if not table.find(antes, nombre) then
			task.delay(1.2, function()
				notificar(j, "¡COMBINACIÓN! " .. nombre)
			end)
		end
	end
	DatosJugador.guardar(j)
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
				b.respuestas[e.id] = {
					tipo = tostring(accion.tipo),
					id = accion.id and tostring(accion.id) or nil,
					objetivo = accion.objetivo and tostring(accion.objetivo) or nil,
					col = tonumber(accion.col),
					fila = tonumber(accion.fila),
				}
			end
		end
	end)
	remoto("ElegirMejora").OnServerEvent:Connect(function(jugador: Player, id: any)
		local lista = ofertas[jugador]
		if lista and type(id) == "string" and table.find(lista, id) then
			ofertas[jugador] = nil
			Combate.darMejora(jugador, id)
			if Combate.alCambiarJugador then
				Combate.alCambiarJugador(jugador)
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
		ofertas[j] = nil
	end)
end

function Combate.enBatalla(j: Player): boolean
	return batallaDe[j] ~= nil
end

--- Vida y maná actuales del jugador (con sus máximos según clase, nivel y mejoras).
function Combate.vidaDe(j: Player): (number, number, number, number)
	local perfil = DatosJugador.obtener(j)
	if not perfil or not perfil.clase then
		return 0, 0, 0, 0
	end
	local s = Datos.statsDe(perfil.clase, perfil.nivel, perfil.mejoras)
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
		local s = Datos.statsDe(perfil.clase, perfil.nivel, perfil.mejoras)
		vida[j] = { hp = s.hp, mp = s.mp }
	end
end

--- Pone la vida y el maná (fuera de combate: hogueras, posada, comida).
function Combate.ponerVida(j: Player, hp: number, mp: number)
	vida[j] = { hp = hp, mp = mp }
end

-- ===================== CASILLAS =====================
local function clave(c: number, f: number): string
	return c .. "," .. f
end

local function dentro(c: number, f: number): boolean
	return c >= 1 and c <= R.columnas and f >= 1 and f <= R.filas
end

local function posCasilla(b: Batalla, c: number, f: number): Vector3
	return b.origen + Vector3.new((c - 0.5) * R.ancho, 0, (f - 0.5) * R.fondo)
end

local function distancia(a: Entidad, c: number, f: number): number
	return math.abs(a.col - c) + math.abs(a.fila - f)
end

local function todos(b: Batalla): { Entidad }
	local r = {}
	for _, e in b.aliados do
		table.insert(r, e)
	end
	for _, e in b.enemigos do
		table.insert(r, e)
	end
	return r
end

local function ocupante(b: Batalla, c: number, f: number): Entidad?
	for _, e in todos(b) do
		if e.vivo and e.col == c and e.fila == f then
			return e
		end
	end
	return nil
end

local function bloqueada(b: Batalla, c: number, f: number): boolean
	local t = b.casillas[clave(c, f)]
	return t ~= nil and Datos.Casillas[t].bloquea == true
end

local function libre(b: Batalla, c: number, f: number): boolean
	return dentro(c, f) and not bloqueada(b, c, f) and ocupante(b, c, f) == nil
end

type Nodo = { c: number, f: number, d: number, previo: string? }
--- Casillas a las que puede llegar una entidad este turno (búsqueda en anchura).
local function alcanzables(b: Batalla, e: Entidad): { [string]: Nodo }
	local inicio = clave(e.col, e.fila)
	local vistos: { [string]: Nodo } = { [inicio] = { c = e.col, f = e.fila, d = 0, previo = nil } }
	local cola = { vistos[inicio] }
	local inmune = e.mods.inmuneTrampas == true
	while #cola > 0 do
		local n = table.remove(cola, 1) :: Nodo
		if n.d < e.mov and not (n.d > 0 and b.casillas[clave(n.c, n.f)] == "barro" and not inmune and not e.vuela) then
			for _, dir in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
				local c, f = n.c + dir[1], n.f + dir[2]
				local k = clave(c, f)
				if dentro(c, f) and not vistos[k] and ocupante(b, c, f) == nil and (e.vuela or not bloqueada(b, c, f)) then
					local nodo = { c = c, f = f, d = n.d + 1, previo = clave(n.c, n.f) }
					vistos[k] = nodo
					table.insert(cola, nodo)
				end
			end
		end
	end
	vistos[inicio] = nil
	-- no se puede acabar encima de un obstáculo
	for k, n in vistos do
		if bloqueada(b, n.c, n.f) then
			vistos[k] = nil
		end
	end
	return vistos
end

local function camino(mapa: { [string]: Nodo }, todosNodos: { [string]: Nodo }, destino: string): { Nodo }
	local pasos = {}
	local k: string? = destino
	while k and todosNodos[k] do
		table.insert(pasos, 1, todosNodos[k])
		k = todosNodos[k].previo
	end
	return pasos
end

-- igual que alcanzables, pero sin quitar nada: para reconstruir caminos que pasan por encima de rocas (los que vuelan)
local function mapaCompleto(b: Batalla, e: Entidad): { [string]: Nodo }
	local inicio = clave(e.col, e.fila)
	local vistos: { [string]: Nodo } = { [inicio] = { c = e.col, f = e.fila, d = 0, previo = nil } }
	local cola = { vistos[inicio] }
	local inmune = e.mods.inmuneTrampas == true
	while #cola > 0 do
		local n = table.remove(cola, 1) :: Nodo
		if n.d < e.mov and not (n.d > 0 and b.casillas[clave(n.c, n.f)] == "barro" and not inmune and not e.vuela) then
			for _, dir in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
				local c, f = n.c + dir[1], n.f + dir[2]
				local k = clave(c, f)
				if dentro(c, f) and not vistos[k] and ocupante(b, c, f) == nil and (e.vuela or not bloqueada(b, c, f)) then
					local nodo = { c = c, f = f, d = n.d + 1, previo = clave(n.c, n.f) }
					vistos[k] = nodo
					table.insert(cola, nodo)
				end
			end
		end
	end
	return vistos
end

-- ===================== MODELOS Y MOVIMIENTO =====================
-- El servidor solo pone un "ancla" invisible por enemigo. Cada cliente le pega encima su muñeco 2D
-- (src/client/Munecos.luau), animado a 60 fps en el propio cliente.
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
	ancla.CanTouch = false
	ancla.Parent = m
	m.PrimaryPart = ancla
	m:SetAttribute("EnemigoId", def.id)
	m:SetAttribute("EntidadId", entidadId)
	m:SetAttribute("VidaMax", def.stats.hp)
	m.Parent = workspace
	return m
end

--- Ancla del compañero: el cliente le pone encima el muñeco del vecino (atributo "Companero" = su semilla).
local function crearModeloCompanero(cid: string, cf: CFrame, entidadId: string, vidaMax: number): Model
	local def = Datos.Companeros[cid]
	local m = Instance.new("Model")
	m.Name = def.nombre
	local ancla = Instance.new("Part")
	ancla.Name = "Ancla"
	ancla.Size = Vector3.new(3, 3, 0.5)
	ancla.CFrame = cf * CFrame.new(0, 1.5, 0)
	ancla.Transparency = 1
	ancla.Anchored = true
	ancla.CanCollide = false
	ancla.CanQuery = false
	ancla.CanTouch = false
	ancla.Parent = m
	m.PrimaryPart = ancla
	m:SetAttribute("Companero", def.vecino)
	m:SetAttribute("CompaneroNombre", def.nombre)
	m:SetAttribute("EntidadId", entidadId)
	m:SetAttribute("VidaMax", vidaMax)
	m.Parent = workspace
	return m
end

local function anclaDe(e: Entidad): BasePart?
	if e.modelo then
		return e.modelo.PrimaryPart
	elseif e.jugador and e.jugador.Character then
		return e.jugador.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	end
	return nil
end

local function cframeEn(b: Batalla, e: Entidad, c: number, f: number): CFrame
	local p = posCasilla(b, c, f)
	if e.modelo then
		local def = e.enemigoId and Datos.Enemigos[e.enemigoId]
		local t = def and def.tamano or 3
		return CFrame.new(p + Vector3.new(0, t / 2, 0))
	end
	return CFrame.lookAt(p + Vector3.new(0, 3, 0), p + Vector3.new(1, 3, 0))
end

--- Lleva el muñeco a una casilla (con un tween corto). Espera a que llegue.
local function deslizar(b: Batalla, e: Entidad, c: number, f: number, tiempo: number)
	local destino = cframeEn(b, e, c, f)
	e.col, e.fila = c, f
	local a = anclaDe(e)
	if not a then
		return
	end
	local t = TweenService:Create(a, TweenInfo.new(tiempo, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = destino })
	t:Play()
	t.Completed:Wait()
end

--- Pequeño salto hacia el objetivo y vuelta (ataque cuerpo a cuerpo).
local function embestida(b: Batalla, actor: Entidad, objetivo: Entidad)
	local a = anclaDe(actor)
	if not a then
		return
	end
	local origen = cframeEn(b, actor, actor.col, actor.fila)
	local dir = posCasilla(b, objetivo.col, objetivo.fila) - posCasilla(b, actor.col, actor.fila)
	local paso = dir.Magnitude > 0.1 and dir.Unit * math.min(1.6, dir.Magnitude * 0.45) or Vector3.zero
	local ida = TweenService:Create(a, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = origen + paso })
	ida:Play()
	ida.Completed:Wait()
	local vuelta = TweenService:Create(a, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { CFrame = origen })
	vuelta:Play()
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
	for _, e in todos(b) do
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

local function aTodos(b: Batalla, nombre: string, datos: any)
	local ev = Remotos:FindFirstChild(nombre) :: RemoteEvent
	for _, j in jugadoresDe(b) do
		ev:FireClient(j, datos)
	end
end

local function resumen(e: Entidad, paraJugador: Player?): any
	local a = anclaDe(e)
	return {
		id = e.id,
		nombre = e.nombre,
		lado = e.lado,
		clase = e.claseId,
		enemigo = e.enemigoId,
		vecino = e.companeroId and Datos.Companeros[e.companeroId].vecino or nil,
		nivel = e.nivel,
		hp = e.hp,
		maxHp = e.max.hp,
		mp = e.mp,
		maxMp = e.max.mp,
		vivo = e.vivo,
		esMio = paraJugador ~= nil and e.jugador == paraJugador,
		pos = a and a.Position or Vector3.zero,
		col = e.col,
		fila = e.fila,
		mov = e.mov,
		alcance = e.alcance,
		veneno = e.estados.veneno > 0,
		defensa = e.estados.defensa > 0 or e.estados.defendiendo,
		furia = e.estados.furia > 0,
	}
end

local function emitirEstado(b: Batalla, orden: { Entidad }?)
	local ev = Remotos:FindFirstChild("BatallaEstado") :: RemoteEvent
	local casillas = {}
	for k, t in b.casillas do
		casillas[k] = t
	end
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
		ev:FireClient(j, { id = b.id, zona = b.zona.nombre, ronda = b.ronda, aliados = aliados, enemigos = enemigos, orden = orden and ids or nil, centro = b.centro, casillas = casillas })
	end
end

local function guardarVida(e: Entidad)
	if e.jugador then
		vida[e.jugador] = { hp = e.hp, mp = e.mp }
	end
end

local function actualizarVidaModelo(e: Entidad)
	if e.modelo then
		e.modelo:SetAttribute("Vida", e.hp)
		e.modelo:SetAttribute("VidaMax", e.max.hp)
	end
end

local function caer(e: Entidad)
	if e.modelo then
		e.modelo:SetAttribute("Caido", true)
	end
end

local function decir(b: Batalla, e: Entidad, prob: number)
	if e.vivo and rng:NextNumber() < prob then
		local def: any = e.enemigoId and Datos.Enemigos[e.enemigoId] or e.companeroId and Datos.Companeros[e.companeroId]
		local frases = def and def.frases
		if frases and #frases > 0 then
			aTodos(b, "BatallaEvento", { texto = "", actor = e.id, golpes = {}, dice = { id = e.id, texto = frases[rng:NextInteger(1, #frases)] } })
		end
	end
end

local FRASES_HEROE = { "¡Toma ya!", "¡Ni lo vi venir!", "¡Eso ha dolido hasta aquí!", "¿Alguien lo ha grabado?", "¡Para tu colección!" }

-- ===================== DAÑO, MUERTE Y EXPLOSIONES =====================
local aplicarDano: (b: Batalla, actor: Entidad, objetivo: Entidad, atributo: number, poder: number, critExtra: number, golpes: { Golpe }, textos: { string }, sinExplosion: boolean?) -> ()

local function morir(b: Batalla, objetivo: Entidad, actor: Entidad?, golpes: { Golpe }, textos: { string }, sinExplosion: boolean?)
	if objetivo.mods.revivir and not objetivo.estados.revivido then
		objetivo.estados.revivido = true
		objetivo.hp = math.max(1, math.floor(objetivo.max.hp * 0.3))
		table.insert(golpes, { id = objetivo.id, cantidad = objetivo.hp, tipo = "cura" })
		table.insert(textos, "¡La calavera de goma devuelve a " .. objetivo.nombre .. " a la vida!")
		return
	end
	objetivo.vivo = false
	objetivo.estados.veneno, objetivo.estados.defensa, objetivo.estados.furia, objetivo.estados.defendiendo = 0, 0, 0, false
	caer(objetivo)
	-- petardo: el que mata hace explotar al caído
	if actor and actor.mods.explota and not sinExplosion then
		local radio = actor.mods.explotaDoble and 2 or 1
		local fuerza = actor.mods.explota * (actor.mods.explotaDoble and 2 or 1)
		table.insert(textos, "¡PUM! " .. objetivo.nombre .. " explota como un petardo")
		for _, x in rivales(b, actor) do
			if math.max(math.abs(x.col - objetivo.col), math.abs(x.fila - objetivo.fila)) <= radio then
				x.hp = math.max(0, x.hp - fuerza)
				table.insert(golpes, { id = x.id, cantidad = fuerza, tipo = "dano" })
				actualizarVidaModelo(x)
				guardarVida(x)
				if x.hp <= 0 and x.vivo then
					morir(b, x, actor, golpes, textos, true)
				end
			end
		end
	end
end

local function herir(b: Batalla, objetivo: Entidad, cantidad: number, actor: Entidad?, golpes: { Golpe }, textos: { string }, extra: { [string]: any }?)
	objetivo.hp = math.max(0, objetivo.hp - cantidad)
	local g: Golpe = { id = objetivo.id, cantidad = cantidad, tipo = "dano" }
	if extra then
		for k, v in extra do
			(g :: any)[k] = v
		end
	end
	table.insert(golpes, g)
	actualizarVidaModelo(objetivo)
	guardarVida(objetivo)
	if objetivo.hp <= 0 and objetivo.vivo then
		morir(b, objetivo, actor, golpes, textos)
	end
end

local function cubierto(b: Batalla, actor: Entidad, objetivo: Entidad): boolean
	if actor.fila ~= objetivo.fila or math.abs(actor.col - objetivo.col) <= 1 then
		return false
	end
	local paso = objetivo.col > actor.col and 1 or -1
	local c = actor.col + paso
	while c ~= objetivo.col do
		if bloqueada(b, c, actor.fila) then
			return true
		end
		c += paso
	end
	return false
end

aplicarDano = function(b, actor, objetivo, atributo, poder, critExtra, golpes, textos, sinExplosion)
	local m = actor.mods
	local dist = distancia(actor, objetivo.col, objetivo.fila)
	-- esquivar
	if objetivo.mods.esquiva and rng:NextNumber() < objetivo.mods.esquiva then
		table.insert(golpes, { id = objetivo.id, cantidad = 0, tipo = "esquiva" })
		table.insert(textos, objetivo.nombre .. " lo esquiva con estilo")
		return
	end
	local mult = actor.estados.furia > 0 and 1.3 or 1
	if dist > 1 and m.distancia then
		mult *= 1 + m.distancia
	end
	local cubre = dist > 1 and cubierto(b, actor, objetivo)
	if cubre then
		mult *= 0.5
	end
	local d = Datos.dano(atributo * mult, poder, objetivo.max.def, rng)
	if m.dado then
		d = math.max(1, math.floor(d * rng:NextNumber(0.5, 2.5)))
	end
	local critico = rng:NextNumber() < 0.08 + critExtra + (m.crit or 0)
	if critico then
		d = math.floor(d * 1.6)
	end
	if objetivo.estados.defendiendo and objetivo.mods.defensaTotal then
		d = 0
		table.insert(textos, objetivo.nombre .. " para el golpe con la sartén. ¡CLONK!")
	elseif objetivo.estados.defendiendo or objetivo.estados.defensa > 0 then
		d = math.max(1, math.floor(d * 0.5))
	end
	herir(b, objetivo, d, actor, golpes, textos, { critico = critico, cubierto = cubre })
	if cubre then
		table.insert(textos, objetivo.nombre .. " se cubre tras la roca")
	end
	if critico and actor.jugador and rng:NextNumber() < 0.6 then
		aTodos(b, "BatallaEvento", { texto = "", actor = actor.id, golpes = {}, dice = { id = actor.id, texto = FRASES_HEROE[rng:NextInteger(1, #FRASES_HEROE)] } })
	end
	-- robar vida
	if m.robo and d > 0 and actor.vivo then
		local cura = math.max(1, math.floor(d * m.robo))
		local antes = actor.hp
		actor.hp = math.min(actor.max.hp, actor.hp + cura)
		if actor.hp > antes then
			table.insert(golpes, { id = actor.id, cantidad = actor.hp - antes, tipo = "cura" })
		end
		guardarVida(actor)
	end
	-- espejo roto
	if objetivo.mods.reflejo and d > 1 and rng:NextNumber() < objetivo.mods.reflejo then
		table.insert(textos, "¡El espejo roto devuelve el golpe!")
		herir(b, actor, math.floor(d / 2), objetivo, golpes, textos)
	end
	-- huevo podrido
	if m.venenoGolpe and objetivo.vivo and rng:NextNumber() < m.venenoGolpe then
		objetivo.estados.veneno = 3
		table.insert(golpes, { id = objetivo.id, cantidad = 0, tipo = "envenenado" })
	end
end

local function curar(objetivo: Entidad, cantidad: number, golpes: { Golpe })
	local antes = objetivo.hp
	objetivo.hp = math.min(objetivo.max.hp, objetivo.hp + cantidad)
	actualizarVidaModelo(objetivo)
	guardarVida(objetivo)
	table.insert(golpes, { id = objetivo.id, cantidad = objetivo.hp - antes, tipo = "cura" })
end

-- ===================== TRAMPAS Y EMPUJONES =====================
local function quitarCasilla(b: Batalla, k: string)
	b.casillas[k] = nil
	local d = b.decorados[k]
	if d then
		d:Destroy()
		b.decorados[k] = nil
	end
end

local function pisar(b: Batalla, e: Entidad, golpes: { Golpe }, textos: { string })
	if not e.vivo or e.vuela or e.mods.inmuneTrampas then
		return
	end
	local k = clave(e.col, e.fila)
	local t = b.casillas[k]
	local def = t and Datos.Casillas[t]
	if not def or not def.trampa then
		return
	end
	if t == "pinchos" then
		table.insert(textos, e.nombre .. " " .. def.texto)
		herir(b, e, math.max(1, math.floor(e.max.hp * def.dano)), nil, golpes, textos, { trampa = "pinchos" })
	elseif t == "seta" then
		table.insert(textos, e.nombre .. " " .. def.texto)
		curar(e, math.floor(e.max.hp * def.cura), golpes)
		quitarCasilla(b, k)
	elseif t == "barro" then
		table.insert(textos, e.nombre .. " " .. def.texto)
	end
end

--- Empuja (n > 0) o atrae (n < 0) al objetivo. Si choca, golpe extra.
local function empujar(b: Batalla, actor: Entidad, objetivo: Entidad, n: number, golpes: { Golpe }, textos: { string })
	if not objetivo.vivo or n == 0 or objetivo.enemigoId ~= nil and Datos.Enemigos[objetivo.enemigoId] ~= nil and Datos.Enemigos[objetivo.enemigoId].jefe == true and n > 0 and actor.lado == "aliado" and rng:NextNumber() < 0.5 then
		return
	end
	local dc, df = objetivo.col - actor.col, objetivo.fila - actor.fila
	local dx, dy = 0, 0
	if math.abs(dc) >= math.abs(df) then
		dx = dc > 0 and 1 or -1
	else
		dy = df > 0 and 1 or -1
	end
	if n < 0 then
		dx, dy = -dx, -dy
	end
	local movido = false
	for _ = 1, math.abs(n) do
		if n < 0 and distancia(actor, objetivo.col, objetivo.fila) <= 1 then
			break
		end
		local c, f = objetivo.col + dx, objetivo.fila + dy
		local otro = dentro(c, f) and ocupante(b, c, f) or nil
		if not dentro(c, f) or bloqueada(b, c, f) or otro then
			local fuerza = 8 + (actor.mods.choque or 0)
			if actor.mods.choqueDoble then
				fuerza *= 2
			end
			local contra = not dentro(c, f) and "el borde" or (otro and otro.nombre or Datos.Casillas[b.casillas[clave(c, f)]].nombre:lower())
			table.insert(textos, "¡CATAPLÁN! " .. objetivo.nombre .. " se estampa contra " .. contra)
			herir(b, objetivo, fuerza, actor, golpes, textos, { choque = true })
			if otro then
				herir(b, otro, math.floor(fuerza / 2), actor, golpes, textos, { choque = true })
			end
			break
		end
		deslizar(b, objetivo, c, f, 0.12)
		movido = true
	end
	if movido then
		pisar(b, objetivo, golpes, textos)
	end
end

-- ===================== ÁREAS =====================
local function enArea(b: Batalla, actor: Entidad, h: Datos.Habilidad, centroC: number, centroF: number, lista: { Entidad }): { Entidad }
	local area = h.area or "uno"
	local r = {}
	for _, x in lista do
		local ok = false
		if area == "todos" then
			ok = true
		elseif area == "alrededor" then
			ok = x ~= actor and math.max(math.abs(x.col - actor.col), math.abs(x.fila - actor.fila)) <= 1
		elseif area == "alrededor2" then
			ok = x ~= actor and distancia(actor, x.col, x.fila) <= 2
		elseif area == "cruz" then
			ok = math.abs(x.col - centroC) + math.abs(x.fila - centroF) <= 1
		else
			ok = x.col == centroC and x.fila == centroF
		end
		if ok then
			table.insert(r, x)
		end
	end
	return r
end

local function alcanceDe(actor: Entidad, h: Datos.Habilidad?): number
	if not h then
		return actor.alcance
	end
	local a = h.alcance or 1
	if a > 1 then
		a += actor.mods.alcance or 0
	end
	return a
end

-- ===================== ACCIONES =====================
--- Rompe una roca del campo (deja la casilla libre). A veces dentro hay algo.
local function romperRoca(b: Batalla, actor: Entidad, k: string, textos: { string })
	quitarCasilla(b, k)
	local perfil = actor.jugador and DatosJugador.obtener(actor.jugador)
	local suerte = rng:NextNumber()
	if perfil and suerte < 0.25 then
		perfil.objetos.pocion = (perfil.objetos.pocion or 0) + 1
		table.insert(textos, "¡Dentro de la roca había una poción!")
	elseif perfil and suerte < 0.45 then
		perfil.oro += 5
		table.insert(textos, "¡Entre los trozos brillan 5 monedas!")
	end
end

local function ejecutar(b: Batalla, actor: Entidad, accion: Accion)
	local golpes: { Golpe } = {}
	local textos: { string } = {}
	local texto = ""
	local habilidadId: string? = nil
	local perfil = actor.jugador and DatosJugador.obtener(actor.jugador)

	-- romper una roca con un ataque o una habilidad de daño (objetivo "roca:col,fila")
	local rk = accion.objetivo and string.match(accion.objetivo, "^roca:(%d+,%d+)$")
	if rk and (accion.tipo == "atacar" or accion.tipo == "habilidad") then
		local c, f = string.match(rk, "(%d+),(%d+)")
		local col, fila = tonumber(c) :: number, tonumber(f) :: number
		local h = accion.tipo == "habilidad" and accion.id and Datos.Habilidades[accion.id] or nil
		local valida = b.casillas[rk] == "roca" and distancia(actor, col, fila) <= alcanceDe(actor, h)
		if h then
			local clase = actor.claseId and Datos.Clases[actor.claseId]
			valida = valida and h.tipo == "dano" and actor.mp >= h.coste and clase ~= nil and table.find(clase.habilidades, h.id) ~= nil and actor.nivel >= h.nivelMinimo
		end
		if valida then
			if h then
				actor.mp -= h.coste
				guardarVida(actor)
			end
			local rocas = { rk }
			-- las habilidades en cruz rompen también las rocas de alrededor
			if h and h.area == "cruz" then
				for _, d in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
					local k2 = clave(col + d[1], fila + d[2])
					if b.casillas[k2] == "roca" then
						table.insert(rocas, k2)
					end
				end
			end
			for _, k2 in rocas do
				romperRoca(b, actor, k2, textos)
			end
			texto = actor.nombre .. (h and (" usa " .. h.nombre .. " y") or "") .. " rompe " .. (#rocas > 1 and "las rocas" or "la roca") .. ". ¡CRAC!"
			for _, t in textos do
				texto ..= " " .. t
			end
			aTodos(b, "BatallaEvento", { texto = texto, actor = actor.id, habilidad = h and h.id or nil, golpes = {}, rocas = rocas })
			return
		end
		accion = { tipo = accion.tipo, id = accion.id }
	end

	if accion.tipo == "habilidad" and accion.id then
		local h = Datos.Habilidades[accion.id]
		local permitida = h ~= nil and actor.mp >= h.coste
		if permitida and actor.lado == "aliado" then
			local clase = actor.claseId and Datos.Clases[actor.claseId]
			permitida = clase ~= nil and table.find(clase.habilidades, h.id) ~= nil and actor.nivel >= h.nivelMinimo
		end
		local objetivo = buscar(b, accion.objetivo)
		local area = h and (h.area or "uno") or "uno"
		local necesitaObjetivo = area == "uno" or area == "cruz"
		if permitida and necesitaObjetivo then
			permitida = objetivo ~= nil and distancia(actor, objetivo.col, objetivo.fila) <= alcanceDe(actor, h)
			if permitida and h.tipo == "revivir" then
				permitida = objetivo ~= nil and not objetivo.vivo and objetivo.lado == actor.lado
			elseif permitida then
				permitida = objetivo ~= nil and objetivo.vivo
			end
		end
		if not permitida then
			accion = { tipo = "atacar", objetivo = accion.objetivo }
		else
			actor.mp -= h.coste
			habilidadId = h.id
			texto = actor.nombre .. " usa " .. h.nombre
			local atributo = h.base == "mag" and actor.max.mag or actor.max.atk
			local deEnemigo = h.tipo == "dano"
			local lista = deEnemigo and rivales(b, actor) or companeros(b, actor, h.tipo == "revivir")
			local cc, cf = actor.col, actor.fila
			if objetivo then
				cc, cf = objetivo.col, objetivo.fila
			end
			local objetivos = enArea(b, actor, h, cc, cf, lista)
			if h.objetivo == "yo" then
				objetivos = { actor }
			end
			if #objetivos > 0 and deEnemigo and (h.alcance or 1) <= 1 and area == "uno" then
				embestida(b, actor, objetivos[1])
			end
			for _, o in objetivos do
				if h.tipo == "dano" then
					aplicarDano(b, actor, o, atributo, h.poder, h.critExtra or 0, golpes, textos)
					if h.efecto == "veneno" and o.vivo then
						o.estados.veneno = 3
					end
					if h.empuje and o.vivo then
						local n = h.empuje
						if n > 0 then
							n += actor.mods.empuje or 0
						end
						empujar(b, actor, o, n, golpes, textos)
					end
				elseif h.tipo == "cura" then
					curar(o, math.floor(atributo * h.poder * rng:NextNumber(0.95, 1.05)), golpes)
				elseif h.tipo == "revivir" then
					o.vivo = true
					o.hp = 0
					o.estados.revivido = false
					if o.modelo then
						o.modelo:SetAttribute("Caido", false)
					end
					curar(o, math.floor(o.max.hp * h.poder), golpes)
				elseif h.tipo == "mejora" then
					if h.efecto == "furia" then
						o.estados.furia = 3
					elseif h.efecto == "defensa" then
						o.estados.defensa = 3
					end
					table.insert(golpes, { id = o.id, cantidad = 0, tipo = h.efecto or "mejora" })
				end
			end
			-- los golpes alrededor (torbellino) también rompen las rocas pegadas
			local rotas = {}
			if h.tipo == "dano" and h.area == "alrededor" then
				for dc = -1, 1 do
					for df = -1, 1 do
						local k2 = clave(actor.col + dc, actor.fila + df)
						if (dc ~= 0 or df ~= 0) and b.casillas[k2] == "roca" then
							romperRoca(b, actor, k2, textos)
							table.insert(rotas, k2)
						end
					end
				end
			end
			if #rotas > 0 then
				table.insert(textos, "¡CRAC! Las rocas de alrededor saltan en pedazos")
				aTodos(b, "BatallaEvento", { texto = "", actor = actor.id, golpes = {}, rocas = rotas })
			elseif #objetivos == 0 then
				texto ..= "… y no le da a nadie. Qué vergüenza."
			end
		end
	end

	if accion.tipo == "objeto" and perfil and accion.id and Datos.Objetos[accion.id] and (perfil.objetos[accion.id] or 0) > 0 then
		local o = Datos.Objetos[accion.id]
		perfil.objetos[accion.id] -= 1
		local destino = buscar(b, accion.objetivo)
		if not destino or not destino.vivo or destino.lado ~= actor.lado then
			destino = actor
		end
		local d = destino :: Entidad
		texto = actor.nombre .. " usa " .. o.nombre .. (d ~= actor and (" con " .. d.nombre) or "")
		if o.cura > 0 then
			curar(d, o.cura, golpes)
		end
		if o.mana > 0 then
			d.mp = math.min(d.max.mp, d.mp + o.mana)
			guardarVida(d)
			table.insert(golpes, { id = d.id, cantidad = o.mana, tipo = "mana" })
		end
	elseif accion.tipo == "objeto" then
		accion = { tipo = "defender" }
	end

	if accion.tipo == "atacar" then
		local o = buscar(b, accion.objetivo)
		if not o or not o.vivo or o.lado == actor.lado or distancia(actor, o.col, o.fila) > actor.alcance then
			-- el más cercano que esté a su alcance
			o = nil
			local mejor = math.huge
			for _, x in rivales(b, actor) do
				local d = distancia(actor, x.col, x.fila)
				if d <= actor.alcance and d < mejor then
					o, mejor = x, d
				end
			end
		end
		if o then
			if actor.alcance <= 1 or distancia(actor, o.col, o.fila) <= 1 then
				embestida(b, actor, o)
			end
			texto = actor.nombre .. " ataca a " .. o.nombre
			aplicarDano(b, actor, o, actor.alcance > 1 and actor.lado == "aliado" and actor.claseId == "maga" and actor.max.mag * 0.8 or actor.max.atk, 1, 0, golpes, textos)
		else
			accion = { tipo = "defender" }
			texto = actor.nombre .. " no llega a nadie y se pone en guardia"
		end
	end

	if accion.tipo == "defender" then
		actor.estados.defendiendo = true
		if texto == "" then
			texto = actor.nombre .. " se defiende"
		end
		table.insert(golpes, { id = actor.id, cantidad = 0, tipo = "defensa" })
		if actor.mods.defensaCura then
			curar(actor, math.floor(actor.max.hp * actor.mods.defensaCura), golpes)
		end
	elseif accion.tipo == "huir" then
		if not b.jefe and rng:NextNumber() < 0.6 then
			texto = actor.nombre .. " grita «¡corred!» y el equipo escapa"
			b.huida = true
		else
			texto = b.jefe and "¡No se puede huir de un jefe!" or (actor.nombre .. " intenta huir… y se tropieza")
		end
	end

	for _, t in textos do
		texto ..= (texto ~= "" and ". " or "") .. t
	end
	aTodos(b, "BatallaEvento", { texto = texto, actor = actor.id, habilidad = habilidadId, golpes = golpes })
end

--- Mueve una entidad paso a paso por un camino de casillas.
local function recorrer(b: Batalla, e: Entidad, pasos: { Nodo })
	local golpes: { Golpe } = {}
	local textos: { string } = {}
	aTodos(b, "BatallaEvento", { texto = "", actor = e.id, golpes = {}, mover = true })
	for _, n in pasos do
		deslizar(b, e, n.c, n.f, 0.17)
	end
	pisar(b, e, golpes, textos)
	if #golpes > 0 or #textos > 0 then
		aTodos(b, "BatallaEvento", { texto = table.concat(textos, ". "), actor = e.id, golpes = golpes })
		task.wait(0.4)
	end
end

-- ===================== TURNOS =====================
local function opciones(b: Batalla, e: Entidad, puedeMover: boolean, tiempo: number): any
	local perfil = e.jugador and DatosJugador.obtener(e.jugador)
	local clase = e.claseId and Datos.Clases[e.claseId]
	local habilidades = {}
	if clase then
		for _, hid in clase.habilidades do
			local h = Datos.Habilidades[hid]
			table.insert(habilidades, {
				id = h.id,
				nombre = h.nombre,
				descripcion = h.descripcion,
				coste = h.coste,
				objetivo = h.objetivo,
				tipo = h.tipo,
				area = h.area or "uno",
				alcance = alcanceDe(e, h),
				bloqueada = e.nivel < h.nivelMinimo,
				nivelMinimo = h.nivelMinimo,
				sinMana = e.mp < h.coste,
			})
		end
	end
	local objetos = {}
	for _, oid in Datos.OrdenObjetos do
		table.insert(objetos, { id = oid, nombre = Datos.Objetos[oid].nombre, cantidad = perfil and perfil.objetos[oid] or 0, descripcion = Datos.Objetos[oid].descripcion })
	end
	local casillas = {}
	if puedeMover then
		for _, n in alcanzables(b, e) do
			table.insert(casillas, { n.c, n.f })
		end
	end
	return { entidad = e.id, tiempo = tiempo, habilidades = habilidades, objetos = objetos, puedeMover = puedeMover, alcanzables = casillas, alcance = e.alcance, col = e.col, fila = e.fila }
end

local function turnoJugador(b: Batalla, e: Entidad)
	local j = e.jugador
	if not j or not j.Parent then
		e.vivo = false
		return
	end
	local limite = os.clock() + Datos.TIEMPO_TURNO
	local movido = false
	b.respuestas[e.id] = nil
	aTodos(b, "BatallaTurno", { id = e.id, nombre = e.nombre, tiempo = Datos.TIEMPO_TURNO })
	remoto("PedirAccion"):FireClient(j, opciones(b, e, true, Datos.TIEMPO_TURNO))
	while true do
		while os.clock() < limite and not b.respuestas[e.id] and j.Parent do
			task.wait(0.05)
		end
		local r = b.respuestas[e.id]
		b.respuestas[e.id] = nil
		if r and r.tipo == "mover" then
			if not movido and r.col and r.fila then
				local mapa = alcanzables(b, e)
				local k = clave(r.col, r.fila)
				if mapa[k] then
					movido = true
					recorrer(b, e, camino(mapa, mapaCompleto(b, e), k))
					emitirEstado(b)
					if not e.vivo then
						return
					end
				end
			end
			remoto("PedirAccion"):FireClient(j, opciones(b, e, not movido, math.max(1, limite - os.clock())))
		elseif r then
			ejecutar(b, e, r)
			return
		else
			-- se acabó el tiempo: ataca si llega, si no, se defiende
			ejecutar(b, e, { tipo = "atacar" })
			return
		end
	end
end

local function turnoEnemigo(b: Batalla, e: Entidad)
	local def = e.enemigoId and Datos.Enemigos[e.enemigoId]
	local objetivos = rivales(b, e)
	if #objetivos == 0 then
		return
	end
	aTodos(b, "BatallaTurno", { id = e.id, nombre = e.nombre, tiempo = 0 })
	decir(b, e, 0.22)
	task.wait(0.35)
	-- a veces va a por el más débil; si no, a por el más cercano
	local objetivo: Entidad
	if rng:NextNumber() < 0.35 then
		table.sort(objetivos, function(a, c)
			return a.hp < c.hp
		end)
	else
		table.sort(objetivos, function(a, c)
			return distancia(e, a.col, a.fila) < distancia(e, c.col, c.fila)
		end)
	end
	objetivo = objetivos[1]
	-- qué va a hacer
	local hid: string? = nil
	if def and #def.habilidades > 0 and rng:NextNumber() < def.probHabilidad then
		hid = def.habilidades[rng:NextInteger(1, #def.habilidades)]
	end
	-- los compañeros usan su habilidad de ataque a veces (si les llega el maná)
	local cdef = e.companeroId and Datos.Companeros[e.companeroId]
	if cdef and cdef.habilidad ~= "curar" and rng:NextNumber() < 0.4 then
		local hc = Datos.Habilidades[cdef.habilidad]
		if hc and e.mp >= hc.coste then
			hid = cdef.habilidad
		end
	end
	local h = hid and Datos.Habilidades[hid]
	local area = h and (h.area or "uno") or "uno"
	local rango = area == "todos" and 99 or area == "alrededor" and 1 or area == "alrededor2" and 2 or alcanceDe(e, h)
	-- moverse si no llega
	if distancia(e, objetivo.col, objetivo.fila) > rango and e.mov > 0 then
		local mapa = alcanzables(b, e)
		local mejorK: string? = nil
		local mejorPuntos = math.huge
		for k, n in mapa do
			local d = math.abs(n.c - objetivo.col) + math.abs(n.f - objetivo.fila)
			local puntos = (d <= rango and 0 or 100) + d * 2 + n.d * 0.1
			-- las trampas se evitan (menos las setas)
			local t = b.casillas[k]
			if t == "pinchos" or t == "barro" then
				puntos += 6
			elseif t == "seta" then
				puntos -= 3
			end
			if puntos < mejorPuntos then
				mejorK, mejorPuntos = k, puntos
			end
		end
		if mejorK then
			recorrer(b, e, camino(mapa, mapaCompleto(b, e), mejorK))
			if not e.vivo then
				return
			end
		end
	end
	if distancia(e, objetivo.col, objetivo.fila) > rango then
		-- ¿hay otro a tiro?
		local otro: Entidad? = nil
		for _, x in rivales(b, e) do
			if distancia(e, x.col, x.fila) <= rango then
				otro = x
			end
		end
		if not otro then
			aTodos(b, "BatallaEvento", { texto = e.nombre .. " se acerca…", actor = e.id, golpes = {} })
			return
		end
		objetivo = otro
	end
	task.wait(0.15)
	if hid then
		ejecutar(b, e, { tipo = "habilidad", id = hid, objetivo = objetivo.id })
	else
		ejecutar(b, e, { tipo = "atacar", objetivo = objetivo.id })
	end
end

--- Turno de un compañero: el sanador cura al más herido si hace falta; si no, pelea como un monstruo listo.
local function turnoCompanero(b: Batalla, e: Entidad)
	local cdef = e.companeroId and Datos.Companeros[e.companeroId]
	if cdef and cdef.habilidad == "curar" then
		local h = Datos.Habilidades.curar
		local peor: Entidad? = nil
		for _, a in companeros(b, e) do
			if a.hp < a.max.hp * 0.55 and (not peor or a.hp / a.max.hp < peor.hp / peor.max.hp) then
				peor = a
			end
		end
		if peor and e.mp >= h.coste then
			local herido = peor :: Entidad
			aTodos(b, "BatallaTurno", { id = e.id, nombre = e.nombre, tiempo = 0 })
			task.wait(0.3)
			local rango = alcanceDe(e, h)
			if distancia(e, herido.col, herido.fila) > rango and e.mov > 0 then
				local mapa = alcanzables(b, e)
				local mejorK, mejorD = nil, math.huge
				for k, n in mapa do
					local d = math.abs(n.c - herido.col) + math.abs(n.f - herido.fila)
					if d < mejorD then
						mejorK, mejorD = k, d
					end
				end
				if mejorK then
					recorrer(b, e, camino(mapa, mapaCompleto(b, e), mejorK))
					if not e.vivo then
						return
					end
				end
			end
			if distancia(e, herido.col, herido.fila) <= rango then
				ejecutar(b, e, { tipo = "habilidad", id = "curar", objetivo = herido.id })
				return
			end
		end
	end
	turnoEnemigo(b, e)
end

-- Veneno, curación por turno, aura y duración de las mejoras al empezar el turno de cada uno.
local function inicioTurno(b: Batalla, e: Entidad)
	e.estados.defendiendo = false
	local golpes: { Golpe } = {}
	local textos: { string } = {}
	if e.mods.regen and e.hp < e.max.hp then
		curar(e, math.max(1, math.floor(e.max.hp * e.mods.regen)), golpes)
	end
	if e.mods.auraVeneno then
		for _, x in rivales(b, e) do
			if math.max(math.abs(x.col - e.col), math.abs(x.fila - e.fila)) <= 1 then
				x.estados.veneno = 3
				table.insert(golpes, { id = x.id, cantidad = 0, tipo = "envenenado" })
				table.insert(textos, x.nombre .. " huele el calcetín y se marea")
			end
		end
	end
	if e.estados.veneno > 0 then
		e.estados.veneno -= 1
		local d = math.max(1, math.floor(e.max.hp * 0.07))
		table.insert(textos, e.nombre .. " sufre el veneno")
		herir(b, e, d, nil, golpes, textos)
		golpes[#golpes].tipo = "veneno"
	end
	if #golpes > 0 then
		aTodos(b, "BatallaEvento", { texto = table.concat(textos, ". "), actor = e.id, golpes = golpes })
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

local function casillaLibreEn(b: Batalla, columnas: { number }): (number, number)
	for _ = 1, 60 do
		local c = columnas[rng:NextInteger(1, #columnas)]
		local f = rng:NextInteger(1, R.filas)
		if libre(b, c, f) and not b.casillas[clave(c, f)] then
			return c, f
		end
	end
	for c = 1, R.columnas do
		for f = 1, R.filas do
			if libre(b, c, f) then
				return c, f
			end
		end
	end
	return 1, 1
end

local function entidadJugador(b: Batalla, j: Player): Entidad?
	local perfil = DatosJugador.obtener(j)
	if not perfil or not perfil.clase then
		return nil
	end
	local hp, maxHp, mp = Combate.vidaDe(j)
	local stats = Datos.statsDe(perfil.clase, perfil.nivel, perfil.mejoras)
	local mods = Datos.efectosDe(perfil.mejoras)
	local clase = Datos.Clases[perfil.clase]
	local c, f = casillaLibreEn(b, { 1, 2 })
	local e: Entidad = {
		id = "j" .. j.UserId,
		nombre = (j:GetAttribute("NombreHeroe") :: string?) or j.DisplayName,
		lado = "aliado",
		jugador = j,
		claseId = perfil.clase,
		nivel = perfil.nivel,
		max = stats,
		hp = hp > 0 and hp or math.max(1, math.floor(maxHp * 0.3)),
		mp = mp,
		estados = { veneno = 0, defensa = 0, furia = 0, defendiendo = false, revivido = false },
		vivo = true,
		col = c,
		fila = f,
		mov = clase.mov + (mods.mov or 0),
		alcance = clase.alcance + (clase.alcance > 1 and (mods.alcance or 0) or 0),
		vuela = mods.vuela == true,
		mods = mods,
	}
	congelar(j, cframeEn(b, e, c, f))
	batallaDe[j] = b
	return e
end

local COLOR_CASILLA = { Color3.fromRGB(250, 240, 200), Color3.fromRGB(225, 210, 165) }

--- Dibuja el campo: casillas (se pueden pulsar) y lo que hay encima, en estilo recorte.
local function construirCampo(b: Batalla)
	local carpeta = b.carpeta
	for c = 1, R.columnas do
		for f = 1, R.filas do
			local p = Instance.new("Part")
			p.Name = "Casilla"
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = true
			p.CastShadow = false
			p.Material = Enum.Material.SmoothPlastic
			p.Size = Vector3.new(R.ancho - 0.18, 0.12, R.fondo - 0.18)
			p.Position = posCasilla(b, c, f) + Vector3.new(0, 0.1, 0)
			p.Color = COLOR_CASILLA[(c + f) % 2 + 1]
			p.Transparency = 0.35
			p:SetAttribute("Col", c)
			p:SetAttribute("Fila", f)
			p.Parent = carpeta
		end
	end
	local function pieza(m: Instance, forma: Enum.PartType, tam: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Shape = forma
		p.Size = tam
		p.CFrame = cf
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.Parent = m
		return p
	end
	local frente = CFrame.Angles(0, math.rad(90), 0)
	for k, t in b.casillas do
		local c, f = string.match(k, "(%d+),(%d+)")
		local pos = posCasilla(b, tonumber(c) :: number, tonumber(f) :: number)
		local m = Instance.new("Model")
		m.Name = t
		if t == "roca" then
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.2, 3.3, 3.3), CFrame.new(pos + Vector3.new(0, 1.3, -0.25)) * frente, Color3.fromRGB(25, 20, 30))
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.4, 2.9, 2.9), CFrame.new(pos + Vector3.new(0, 1.3, 0)) * frente, Color3.fromRGB(150, 145, 155))
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.4, 0.9, 0.9), CFrame.new(pos + Vector3.new(-0.6, 1.9, 0.15)) * frente, Color3.fromRGB(190, 185, 195))
		elseif t == "arbusto" then
			for i, o in { { -0.7, 1.1 }, { 0.7, 1.2 }, { 0, 1.9 } } do
				pieza(m, Enum.PartType.Cylinder, Vector3.new(0.2, 2.5, 2.5), CFrame.new(pos + Vector3.new(o[1], o[2], -0.25 + i * 0.02)) * frente, Color3.fromRGB(25, 20, 30))
				pieza(m, Enum.PartType.Cylinder, Vector3.new(0.4, 2.1, 2.1), CFrame.new(pos + Vector3.new(o[1], o[2], i * 0.05)) * frente, Color3.fromRGB(80, 160, 70))
			end
		elseif t == "pinchos" then
			pieza(m, Enum.PartType.Block, Vector3.new(R.ancho - 0.6, 0.15, R.fondo - 0.6), CFrame.new(pos + Vector3.new(0, 0.18, 0)), Color3.fromRGB(90, 80, 90))
			for i = -1, 1 do
				local w = Instance.new("WedgePart")
				w.Anchored, w.CanCollide, w.CanQuery, w.CanTouch, w.CastShadow = true, false, false, false, false
				w.Size = Vector3.new(0.3, 0.9, 0.5)
				w.CFrame = CFrame.new(pos + Vector3.new(i * 0.8, 0.6, 0.2)) * CFrame.Angles(0, math.rad(90), 0)
				w.Color = Color3.fromRGB(210, 210, 220)
				w.Material = Enum.Material.SmoothPlastic
				w.Parent = m
			end
		elseif t == "barro" then
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.14, R.fondo - 0.5, R.ancho - 0.4), CFrame.new(pos + Vector3.new(0, 0.17, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(110, 75, 45))
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.4, 0.5, 0.5), CFrame.new(pos + Vector3.new(0.5, 0.35, 0.4)) * frente, Color3.fromRGB(140, 100, 65))
		elseif t == "seta" then
			pieza(m, Enum.PartType.Block, Vector3.new(0.5, 0.9, 0.3), CFrame.new(pos + Vector3.new(0, 0.55, 0)), Color3.fromRGB(245, 235, 210))
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.2, 1.8, 1.8), CFrame.new(pos + Vector3.new(0, 1.15, -0.2)) * frente, Color3.fromRGB(25, 20, 30))
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.4, 1.5, 1.5), CFrame.new(pos + Vector3.new(0, 1.15, 0)) * frente, Color3.fromRGB(230, 70, 70))
			pieza(m, Enum.PartType.Cylinder, Vector3.new(0.4, 0.35, 0.35), CFrame.new(pos + Vector3.new(-0.3, 1.35, 0.15)) * frente, Color3.new(1, 1, 1))
		end
		m.Parent = carpeta
		b.decorados[k] = m
	end
end

local PREFERENCIAS: { [string]: { string } } = {
	pradera = { "arbusto", "arbusto", "roca", "seta", "pinchos" },
	pantano = { "barro", "barro", "arbusto", "seta", "pinchos" },
	bosque = { "arbusto", "roca", "barro", "seta", "pinchos" },
	ruinas = { "roca", "roca", "pinchos", "pinchos", "seta" },
	cueva = { "roca", "pinchos", "seta", "seta", "barro" },
}

local function sembrarCasillas(b: Batalla)
	local prefs = PREFERENCIAS[b.zona.id] or PREFERENCIAS.pradera
	local n = rng:NextInteger(4, 6)
	for _ = 1, n * 4 do
		if n <= 0 then
			break
		end
		local c = rng:NextInteger(3, R.columnas - 2)
		local f = rng:NextInteger(1, R.filas)
		local k = clave(c, f)
		if not b.casillas[k] then
			local t = prefs[rng:NextInteger(1, #prefs)]
			-- que no se tapen filas enteras
			local enColumna = 0
			for ff = 1, R.filas do
				local x = b.casillas[clave(c, ff)]
				if x and Datos.Casillas[x].bloquea then
					enColumna += 1
				end
			end
			if not (Datos.Casillas[t].bloquea and enColumna >= 2) then
				b.casillas[k] = t
				n -= 1
			end
		end
	end
end

local function incorporarPendientes(b: Batalla)
	for _, j in b.pendientes do
		if j.Parent and not batallaDe[j] and #b.aliados < Datos.MAX_EQUIPO then
			local e = entidadJugador(b, j)
			if e then
				table.insert(b.aliados, e)
				aTodos(b, "BatallaEvento", { texto = j.DisplayName .. " se une al combate", actor = e.id, golpes = {} })
				remoto("BatallaInicio"):FireClient(j, { centro = b.centro, zona = b.zona.nombre, zonaId = b.zona.id, carpeta = b.carpeta, jefe = b.jefe })
			end
		end
	end
	b.pendientes = {}
end

local function terminar(b: Batalla, victoria: boolean)
	b.terminada = true
	b.victoria = victoria
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
			local mejora = false
			if perfil then
				if victoria then
					local oroMio = math.floor(oro * (1 + (e.mods.oro or 0)))
					perfil.xp += xp
					perfil.oro += oroMio
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
					resultado.xp, resultado.oro, resultado.subio, resultado.nivel = xp, oroMio, subio, perfil.nivel
					resultado.botin = botin and Datos.Objetos[botin].nombre or nil
					if subio then
						Combate.curarDelTodo(j)
					elseif not e.vivo then
						vida[j] = { hp = math.max(1, math.floor(e.max.hp * 0.3)), mp = e.mp }
					end
					-- cofre con mejoras: siempre con el jefe, a veces en los demás
					mejora = b.jefe or rng:NextNumber() < 0.4
					resultado.cofre = mejora
				elseif not b.huida then
					-- derrota: vuelve a la ciudad con la vida llena y pierde un 10 % del oro
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
			if victoria and b.alGanar then
				task.spawn(function()
					pcall(b.alGanar :: any, j)
				end)
			end
			if victoria and b.jefe and Combate.alVencerJefe then
				task.delay(6, function()
					if j.Parent then
						pcall(Combate.alVencerJefe :: any, j, b.jefeId)
					end
				end)
			end
			if mejora then
				task.delay(2.6, function()
					if j.Parent then
						Combate.ofrecerMejoras(j, b.jefe and "jefe" or "cofre")
					end
				end)
			end
		end
	end
	for _, lista in { b.enemigos, b.aliados } do
		for _, e in lista do
			if e.modelo then
				e.modelo:Destroy()
			end
		end
	end
	b.carpeta:Destroy()
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
		-- un héroe vivo suelta una frase de victoria
		local vivos = {}
		for _, e in b.aliados do
			if e.vivo and e.jugador then
				table.insert(vivos, e)
			end
		end
		if #vivos > 0 then
			local FRASES = { "¡Ni sudé!", "¿Ya está? Quiero más.", "Eso ha sido trabajo en equipo… mío.", "¡A la taberna a celebrarlo!", "Que alguien me quite esta baba de la bota." }
			local e = vivos[rng:NextInteger(1, #vivos)]
			aTodos(b, "BatallaEvento", { texto = "", actor = e.id, golpes = {}, dice = { id = e.id, texto = FRASES[rng:NextInteger(1, #FRASES)] } })
			task.wait(0.8)
		end
		terminar(b, true)
		return true
	elseif aliadosVivos == 0 then
		terminar(b, false)
		return true
	end
	return false
end

--- Empieza un combate en una zona con los jugadores dados (hasta 4).
--- opciones: { emboscada = true } (los monstruos actúan primero) y { alGanar = function(jugador) end } (premio extra).
function Combate.empezar(zona: any, centro: Vector3, jugadores: { Player }, opciones: any?): Batalla?
	centro = Vector3.new(centro.X, 0, 0)
	siguienteId += 1
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Batalla_" .. siguienteId
	local b: Batalla = {
		id = siguienteId,
		zona = zona,
		centro = centro,
		origen = Vector3.new(centro.X - R.columnas * R.ancho / 2, 0, -R.filas * R.fondo / 2),
		aliados = {},
		enemigos = {},
		pendientes = {},
		ronda = 0,
		terminada = false,
		respuestas = {},
		huida = false,
		jefe = false,
		casillas = {},
		decorados = {},
		emboscada = opciones ~= nil and opciones.emboscada == true,
		alGanar = opciones and opciones.alGanar or nil,
		carpeta = carpeta,
	}
	sembrarCasillas(b)
	for i, j in jugadores do
		local pj = DatosJugador.obtener(j) :: any
		if pj and pj.progreso and pj.progreso.barba then
			-- tres años después, sin afeitar ni bañar: así no se puede pelear
			notificar(j, "¡Con esa barba no ves ni la espada! Primero el barbero y un baño.")
		elseif i <= Datos.MAX_EQUIPO then
			local e = entidadJugador(b, j)
			if e then
				table.insert(b.aliados, e)
			end
		end
	end
	if #b.aliados == 0 then
		return nil
	end
	-- cada héroe trae a su compañero (si no ha elegido ir solo)
	for _, heroe in table.clone(b.aliados) do
		local j = heroe.jugador :: Player
		local perfil = DatosJugador.obtener(j) :: any
		local cid = perfil and perfil.progreso.companero
		if cid and Datos.Companeros[cid] and perfil.progreso.companeros and perfil.progreso.companeros[cid] and #b.aliados < Datos.MAX_EQUIPO + 2 then
			local clase = Datos.Clases[Datos.Companeros[cid].clase]
			local stats = Datos.statsCompanero(cid, perfil.nivel)
			local c, f = casillaLibreEn(b, { 1, 2, 3 })
			local e: Entidad = {
				id = "c" .. j.UserId,
				nombre = Datos.Companeros[cid].nombre,
				lado = "aliado",
				claseId = Datos.Companeros[cid].clase,
				companeroId = cid,
				nivel = perfil.nivel,
				max = stats,
				hp = stats.hp,
				mp = stats.mp,
				estados = { veneno = 0, defensa = 0, furia = 0, defendiendo = false, revivido = false },
				vivo = true,
				col = c,
				fila = f,
				mov = clase.mov,
				alcance = clase.alcance,
				vuela = false,
				mods = {},
			}
			e.modelo = crearModeloCompanero(cid, CFrame.new(posCasilla(b, c, f)), e.id, stats.hp)
			actualizarVidaModelo(e)
			table.insert(b.aliados, e)
		end
	end
	-- enemigos: un grupo al azar de la zona, más fuertes si hay más jugadores
	local grupo = zona.grupos[rng:NextInteger(1, #zona.grupos)]
	local escala = 1 + 0.45 * (#b.aliados - 1)
	for i, eid in grupo do
		local def = Datos.Enemigos[eid]
		if def.jefe then
			b.jefe = true
			b.jefeId = eid
		end
		local c, f = casillaLibreEn(b, { R.columnas - 2, R.columnas - 1, R.columnas })
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
			estados = { veneno = 0, defensa = 0, furia = 0, defendiendo = false, revivido = false },
			vivo = true,
			col = c,
			fila = f,
			mov = def.mov or 2,
			alcance = def.alcance or 1,
			vuela = def.vuela == true,
			mods = {},
		}
		e.modelo = crearModelo(def, CFrame.new(posCasilla(b, c, f)), e.id)
		actualizarVidaModelo(e)
		table.insert(b.enemigos, e)
	end
	construirCampo(b)
	Datos.encartonar(carpeta, Color3.fromRGB(25, 20, 30))
	carpeta.Parent = workspace
	-- punto invisible para que otros se unan (el aviso solo lo ven los que NO están luchando)
	local anillo = Instance.new("Part")
	anillo.Name = "Unirse"
	anillo.Anchored = true
	anillo.CanCollide = false
	anillo.CanQuery = false
	anillo.CanTouch = false
	anillo.Transparency = 1
	anillo.Size = Vector3.new(1, 1, 1)
	anillo.Position = centro + Vector3.new(0, 3, 6)
	anillo.Parent = carpeta
	local prompt = Instance.new("ProximityPrompt")
	prompt.Style = Enum.ProximityPromptStyle.Custom -- lo dibuja el cliente (Interaccion.luau)
	prompt.ActionText = "Unirse al combate"
	prompt.ObjectText = zona.nombre
	prompt.MaxActivationDistance = 16
	prompt.RequiresLineOfSight = false
	prompt:SetAttribute("UnirseBatalla", b.id)
	prompt.Parent = anillo
	prompt.Triggered:Connect(function(j)
		local pj = DatosJugador.obtener(j) :: any
		if pj and pj.progreso and pj.progreso.barba then
			notificar(j, "¡Con esa barba no ves ni la espada! Primero el barbero y un baño.")
		elseif not batallaDe[j] and not table.find(b.pendientes, j) and #b.aliados + #b.pendientes < Datos.MAX_EQUIPO then
			local perfil = DatosJugador.obtener(j)
			if perfil and perfil.clase then
				table.insert(b.pendientes, j)
				notificar(j, "Entrarás en la próxima ronda")
			end
		end
	end)
	b.anillo = anillo

	for _, j in jugadoresDe(b) do
		remoto("BatallaInicio"):FireClient(j, { centro = centro, zona = zona.nombre, zonaId = zona.id, carpeta = carpeta, jefe = b.jefe, emboscada = b.emboscada })
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
				-- en una emboscada, la primera ronda la empiezan los monstruos
				if b.emboscada and b.ronda == 1 and a.lado ~= c.lado then
					return a.lado == "enemigo"
				end
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
						if e.jugador then
							turnoJugador(b, e)
						elseif e.companeroId then
							turnoCompanero(b, e)
						else
							turnoEnemigo(b, e)
						end
					end
					emitirEstado(b, orden)
					if comprobarFin(b) then
						break
					end
					task.wait(0.3)
				end
			end
		end
	end)
	return b
end

return Combate
