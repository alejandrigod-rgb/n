--!strict
-- La escena 2D en el cliente: cámara de lado, muñecos de recortes sobre cada jugador y cada enemigo,
-- y la vida del mapa (pasto y flores que se mecen, nubes, molino, niebla, vecinos que pasean y hablan,
-- monstruos que asoman junto a su guarida, mariposas y luciérnagas). Todo se mueve en RenderStepped (60 fps).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Datos = require(ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Datos")) :: any
local Munecos = require(script.Parent:WaitForChild("Munecos"))

local Escena = {}
Escena.enBatalla = false

local jugador = Players.LocalPlayer
local camara = workspace.CurrentCamera
local NEGRO = Color3.fromRGB(48, 38, 34)

local porEntidad: { [string]: Munecos.Muneco } = {}
local anclaDe: { [string]: BasePart } = {}
local munecoDeModelo: { [Model]: Munecos.Muneco } = {}

--- El muñeco de una entidad del combate ("j123" para jugadores, "e1"... para enemigos).
function Escena.muneco(id: string): Munecos.Muneco?
	local m = porEntidad[id]
	if m and m.raiz:IsDescendantOf(game) then
		return m
	end
	return nil
end

--- Dónde está (en el mundo) el centro de una entidad del combate.
function Escena.posicion(id: string): Vector3?
	local a = anclaDe[id]
	if a and a:IsDescendantOf(workspace) then
		return a.Position
	end
	return nil
end

local function billboard(adornee: BasePart, ancho: number, alto: number, desplazamientoY: number): BillboardGui
	local b = Instance.new("BillboardGui")
	b.Name = "Recorte"
	b.Size = UDim2.fromScale(ancho, alto)
	b.StudsOffset = Vector3.new(0, desplazamientoY, 0)
	b.LightInfluence = 0
	b.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	b.MaxDistance = 220
	b.Adornee = adornee
	b.Parent = adornee
	return b
end

--- Etiqueta con el nombre: texto blanco sobre una pastilla oscura, de tamaño fijo en pantalla (siempre se lee).
--- Con conVida, añade una barra de vida debajo (para los monstruos).
local function nombreFlotante(adornee: BasePart, texto: string, color: Color3, altura: number, conVida: boolean?): Frame?
	local b = Instance.new("BillboardGui")
	b.Name = "Nombre"
	b.Size = UDim2.fromOffset(170, conVida and 44 or 28)
	b.StudsOffset = Vector3.new(0, altura, 0)
	b.LightInfluence = 0
	b.AlwaysOnTop = true
	b.MaxDistance = 120
	b.Adornee = adornee
	local fondo = Instance.new("Frame")
	fondo.AnchorPoint = Vector2.new(0.5, 0)
	fondo.Position = UDim2.fromScale(0.5, 0)
	fondo.Size = UDim2.new(0, 0, 0, 26)
	fondo.AutomaticSize = Enum.AutomaticSize.X
	fondo.BackgroundColor3 = Color3.fromRGB(30, 24, 44)
	fondo.BackgroundTransparency = 0.15
	fondo.BorderSizePixel = 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = fondo
	local s = Instance.new("UIStroke")
	s.Thickness = 2
	s.Color = color
	s.Parent = fondo
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = fondo
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0, 0, 1, 0)
	t.AutomaticSize = Enum.AutomaticSize.X
	t.BackgroundTransparency = 1
	t.Text = texto
	t.Font = Enum.Font.FredokaOne
	t.TextSize = 18
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Parent = fondo
	fondo.Parent = b
	local relleno: Frame? = nil
	if conVida then
		local barra = Instance.new("Frame")
		barra.AnchorPoint = Vector2.new(0.5, 0)
		barra.Position = UDim2.new(0.5, 0, 0, 30)
		barra.Size = UDim2.fromOffset(110, 11)
		barra.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
		barra.BorderSizePixel = 0
		local c2 = Instance.new("UICorner")
		c2.CornerRadius = UDim.new(0.5, 0)
		c2.Parent = barra
		local s2 = Instance.new("UIStroke")
		s2.Thickness = 2
		s2.Color = NEGRO
		s2.Parent = barra
		local r = Instance.new("Frame")
		r.Size = UDim2.fromScale(1, 1)
		r.BackgroundColor3 = Color3.fromRGB(240, 70, 70)
		r.BorderSizePixel = 0
		local c3 = Instance.new("UICorner")
		c3.CornerRadius = UDim.new(0.5, 0)
		c3.Parent = r
		r.Parent = barra
		barra.Parent = b
		relleno = r
	end
	b.Parent = adornee
	return relleno
end

-- ===================== JUGADORES =====================
type Heroe = { m: Munecos.Muneco, b: BillboardGui, raiz: BasePart, clase: string }
local heroes: { [Player]: Heroe } = {}

local function esconderAvatar(ch: Model)
	local function esconder(d: Instance)
		if d:IsA("BasePart") then
			d.Transparency = 1
		elseif d:IsA("Decal") then
			d.Transparency = 1
		end
	end
	for _, d in ch:GetDescendants() do
		esconder(d)
	end
	ch.DescendantAdded:Connect(esconder)
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

local function montarHeroe(p: Player)
	local ch = p.Character
	if not ch then
		return
	end
	local raiz = ch:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	if not raiz then
		return
	end
	local anterior = heroes[p]
	if anterior then
		anterior.b:Destroy()
		local viejo = anterior.raiz:FindFirstChild("Nombre")
		if viejo then
			viejo:Destroy()
		end
	end
	esconderAvatar(ch)
	local clase = (p:GetAttribute("Clase") :: string?) or "guerrero"
	local ap = nil
	local texto = p:GetAttribute("Apariencia") :: string?
	if texto then
		local ok, t = pcall(function()
			return game:GetService("HttpService"):JSONDecode(texto)
		end)
		ap = ok and t or nil
	end
	local b = billboard(raiz, 4.6, 6, 0.05)
	-- tres vistas del mismo héroe (de frente, de lado y de espaldas); se enseña una según hacia dónde camina
	local vistas = {}
	for _, v in { "frente", "lado", "espalda" } do
		local marco = Instance.new("Frame")
		marco.Name = "Vista_" .. v
		marco.Size = UDim2.fromScale(1, 1)
		marco.BackgroundTransparency = 1
		marco.Visible = v == "lado"
		marco.Parent = b
		local apV = table.clone(ap or {})
		apV.vista = v
		vistas[v] = { m = Munecos.crear(marco, "clase", clase, 3, apV), marco = marco }
	end
	local m = vistas.lado.m
	nombreFlotante(raiz, (p:GetAttribute("NombreHeroe") :: string?) or p.DisplayName, p == jugador and Color3.fromRGB(255, 205, 90) or Color3.fromRGB(150, 200, 255), 3.9)
	heroes[p] = { m = m, b = b, raiz = raiz, clase = clase, vistas = vistas, vista = "lado", quieto = 0 }
	porEntidad["j" .. p.UserId] = m
	anclaDe["j" .. p.UserId] = raiz
end

local function seguirJugador(p: Player)
	p.CharacterAdded:Connect(function()
		task.wait(0.1)
		montarHeroe(p)
	end)
	for _, atributo in { "Clase", "Apariencia", "NombreHeroe" } do
		p:GetAttributeChangedSignal(atributo):Connect(function()
			montarHeroe(p)
		end)
	end
	if p.Character then
		task.spawn(montarHeroe, p)
	end
end
for _, p in Players:GetPlayers() do
	seguirJugador(p)
end
Players.PlayerAdded:Connect(seguirJugador)
Players.PlayerRemoving:Connect(function(p)
	heroes[p] = nil
end)

-- ===================== ENEMIGOS DEL COMBATE =====================
local function montarEnemigo(modelo: Model)
	local eid = modelo:GetAttribute("EnemigoId") :: string?
	local id = modelo:GetAttribute("EntidadId") :: string?
	local ancla = modelo:WaitForChild("Ancla", 5) :: BasePart?
	if not eid or not id or not ancla then
		return
	end
	local def = Datos.Enemigos[eid]
	local t = def and def.tamano or 3
	local lado = t * 1.3
	local b = billboard(ancla, lado, lado, lado / 2 - t / 2)
	local m = Munecos.crear(b, "enemigo", eid, eid == "reyHongo" and 4 or 3)
	m.mirar = -1
	munecoDeModelo[modelo] = m
	modelo.Destroying:Connect(function()
		munecoDeModelo[modelo] = nil
	end)
	porEntidad[id] = m
	anclaDe[id] = ancla
	local relleno = nombreFlotante(ancla, def and def.nombre or "?", Color3.fromRGB(240, 90, 90), lado - t / 2 + 0.6, true)
	local function vida()
		local v = (modelo:GetAttribute("Vida") :: number?) or 1
		local mx = (modelo:GetAttribute("VidaMax") :: number?) or 1
		if relleno then
			TweenService:Create(relleno, TweenInfo.new(0.3), { Size = UDim2.fromScale(math.clamp(v / math.max(1, mx), 0, 1), 1) }):Play()
		end
	end
	vida()
	modelo:GetAttributeChangedSignal("Vida"):Connect(vida)
	modelo:GetAttributeChangedSignal("Caido"):Connect(function()
		local caido = modelo:GetAttribute("Caido") == true
		Munecos.caer(m, caido)
		local n = ancla:FindFirstChild("Nombre")
		if n then
			(n :: BillboardGui).Enabled = not caido
		end
	end)
	-- entrada: aparece de un salto
	local escala = Instance.new("UIScale")
	escala.Scale = 0
	escala.Parent = m.raiz
	TweenService:Create(escala, TweenInfo.new(0.45, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

--- Compañero (vecino que pelea contigo): el servidor pone un ancla con el atributo "Companero" (su semilla).
local function montarCompanero(modelo: Model)
	local semilla = modelo:GetAttribute("Companero") :: string?
	local id = modelo:GetAttribute("EntidadId") :: string?
	local ancla = modelo:WaitForChild("Ancla", 5) :: BasePart?
	if not semilla or not id or not ancla then
		return
	end
	local b = billboard(ancla, 4.2, 5.4, 1.2)
	local m = Munecos.crear(b, "vecino", semilla, 3)
	m.mirar = 1
	munecoDeModelo[modelo] = m
	modelo.Destroying:Connect(function()
		munecoDeModelo[modelo] = nil
	end)
	porEntidad[id] = m
	anclaDe[id] = ancla
	local relleno = nombreFlotante(ancla, (modelo:GetAttribute("CompaneroNombre") :: string?) or "?", Color3.fromRGB(110, 190, 110), 4.4, true)
	local function vida()
		local v = (modelo:GetAttribute("Vida") :: number?) or 1
		local mx = (modelo:GetAttribute("VidaMax") :: number?) or 1
		if relleno then
			TweenService:Create(relleno, TweenInfo.new(0.3), { Size = UDim2.fromScale(math.clamp(v / math.max(1, mx), 0, 1), 1) }):Play()
		end
	end
	vida()
	modelo:GetAttributeChangedSignal("Vida"):Connect(vida)
	local escala = Instance.new("UIScale")
	escala.Scale = 0
	escala.Parent = m.raiz
	TweenService:Create(escala, TweenInfo.new(0.45, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

workspace.ChildAdded:Connect(function(h)
	if h:IsA("Model") then
		task.defer(function()
			if h:GetAttribute("EnemigoId") then
				montarEnemigo(h)
			elseif h:GetAttribute("Companero") then
				montarCompanero(h)
			end
		end)
	end
end)

--- Cuando hay varios combates a la vez, todos usan los ids "e1", "e2"…: esto apunta cada id a los enemigos
--- del combate de este jugador (los que están cerca del centro de su batalla).
function Escena.enemigosCerca(centro: Vector3)
	for modelo, m in munecoDeModelo do
		local id = modelo:GetAttribute("EntidadId") :: string?
		if id and modelo.PrimaryPart and (modelo.PrimaryPart.Position - centro).Magnitude < 40 then
			porEntidad[id] = m
			anclaDe[id] = modelo.PrimaryPart
		end
	end
end

-- ===================== VIDA DEL MAPA =====================
type Balanceo = { m: Model, base: CFrame, x: number }
local balanceos: { Balanceo } = {}
local nubes: { { m: Model, v: number, y0: number, f: number? } } = {}
local flotan: { { m: Model, base: CFrame, v: number, fase: number } } = {}
local humos: { { p: BasePart, base: CFrame, fase: number } } = {}
local ojosLista: { { m: Model, prox: number, abiertos: boolean } } = {}
local parpadean: { { p: BasePart, prox: number } } = {}
local giran: { { m: Model, base: CFrame, v: number } } = {}
local nieblas: { { p: BasePart, base: CFrame, v: number } } = {}
local chorros: { { p: BasePart, base: CFrame } } = {}
local vistos: { [Instance]: boolean } = {}

--- Busca lo que se anima en el mapa. Se repite cada poco porque, con StreamingEnabled, las partes lejanas
--- llegan al cliente (y se van) según dónde estés.
local function escanear(mundo: Instance)
	local pasto = mundo:FindFirstChild("Pasto")
	if pasto then
		for _, m in pasto:GetChildren() do
			if m:IsA("Model") and not vistos[m] then
				vistos[m] = true
				local piv = m:GetPivot()
				table.insert(balanceos, { m = m, base = piv, x = piv.Position.X })
			end
		end
	end
	-- lo de las calles y los interiores va dentro de carpetas "Trozo": se miran también
	local lista = mundo:GetChildren()
	for _, c in mundo:GetChildren() do
		if c:IsA("Folder") and c.Name == "Trozo" then
			for _, h in c:GetChildren() do
				table.insert(lista, h)
			end
		end
	end
	for _, d in lista do
		if d:IsA("Model") and d:GetAttribute("Ojos") and not vistos[d] then
			vistos[d] = true
			table.insert(ojosLista, { m = d, prox = os.clock() + math.random() * 5, abiertos = true })
		elseif d:IsA("BasePart") and d:GetAttribute("Parpadea") and not vistos[d] then
			vistos[d] = true
			table.insert(parpadean, { p = d, prox = os.clock() + math.random() * 3 })
		end
		if not vistos[d] then
			if d:IsA("Model") and d:GetAttribute("Nube") then
				vistos[d] = true
				table.insert(nubes, { m = d, v = d:GetAttribute("Nube") :: number, y0 = d:GetPivot().Position.Y, f = d:GetAttribute("Flota") :: number? })
			elseif d:IsA("Model") and d:GetAttribute("Flota") then
				vistos[d] = true
				table.insert(flotan, { m = d, base = d:GetPivot(), v = d:GetAttribute("Flota") :: number, fase = math.random() * 6 })
			elseif d:IsA("Model") and d:GetAttribute("Humo") then
				vistos[d] = true
				local partes = d:GetChildren()
				local origen: CFrame? = nil
				for k, p in partes do
					if p:IsA("BasePart") then
						origen = origen or p.CFrame
						table.insert(humos, { p = p, base = origen :: CFrame, fase = (k - 1) / #partes })
					end
				end
			elseif d:IsA("Model") and d:GetAttribute("Gira") then
				vistos[d] = true
				table.insert(giran, { m = d, base = d:GetPivot(), v = d:GetAttribute("Gira") :: number })
			elseif d:IsA("Model") and d:GetAttribute("Chorro") then
				vistos[d] = true
				for _, p in d:GetChildren() do
					if p:IsA("BasePart") then
						table.insert(chorros, { p = p, base = p.CFrame })
					end
				end
			elseif d:IsA("BasePart") and d:GetAttribute("Niebla") then
				vistos[d] = true
				table.insert(nieblas, { p = d, base = d.CFrame, v = d:GetAttribute("Niebla") :: number })
			end
		end
	end
	-- olvidar lo que ya no está
	for i = #balanceos, 1, -1 do
		if not balanceos[i].m.Parent then
			vistos[balanceos[i].m] = nil
			table.remove(balanceos, i)
		end
	end
	for i = #nubes, 1, -1 do
		if not nubes[i].m.Parent then
			vistos[nubes[i].m] = nil
			table.remove(nubes, i)
		end
	end
end

task.spawn(function()
	local mundo = workspace:WaitForChild("MundoVael", 60)
	while mundo and mundo.Parent do
		escanear(mundo)
		task.wait(2)
	end
end)

-- ----- personajes del mapa (solo en este cliente) -----
type Paseante = { m: Munecos.Muneco, ancla: Part, x: number, z: number, desde: number, hasta: number, vel: number, dir: number, espera: number, burbuja: BillboardGui?, frases: { string }?, proxFrase: number, vuela: boolean, fuente: BasePart? }
local paseantes: { Paseante } = {}

local carpetaVida = Instance.new("Folder")
carpetaVida.Name = "VidaDelMapa"
carpetaVida.Parent = workspace

local function anclaLocal(x: number, y: number, z: number): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Position = Vector3.new(x, y, z)
	p.Parent = carpetaVida
	return p
end

local function burbuja(pa: Paseante, texto: string)
	if pa.burbuja then
		pa.burbuja:Destroy()
	end
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.fromOffset(230, 64)
	b.StudsOffset = Vector3.new(0, 4.6, 0)
	b.LightInfluence = 0
	b.MaxDistance = 70
	b.Adornee = pa.ancla
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundColor3 = Color3.fromRGB(246, 238, 220)
	f.BorderSizePixel = 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 16)
	c.Parent = f
	local s = Instance.new("UIStroke")
	s.Thickness = 3
	s.Color = NEGRO
	s.Parent = f
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -16, 1, -10)
	t.Position = UDim2.fromOffset(8, 5)
	t.BackgroundTransparency = 1
	t.Text = texto
	t.Font = Enum.Font.PatrickHand
	t.TextScaled = true
	t.TextWrapped = true
	t.TextColor3 = NEGRO
	t.Parent = f
	f.Parent = b
	local escala = Instance.new("UIScale")
	escala.Scale = 0
	escala.Parent = f
	b.Parent = pa.ancla
	pa.burbuja = b
	TweenService:Create(escala, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	Munecos.hablar(pa.m, 1.2)
	if Escena.alHablar then
		Escena.alHablar(pa.m.semilla, #texto)
	end
	task.delay(3.4, function()
		if pa.burbuja == b then
			TweenService:Create(escala, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 }):Play()
			task.wait(0.3)
			b:Destroy()
			if pa.burbuja == b then
				pa.burbuja = nil
			end
		end
	end)
end

local FRASES_VECINOS = {
	"¡Buen día, aventurero!",
	"La fuente de la plaza cura del todo.",
	"Dicen que en la cueva vive un rey… ¡un hongo!",
	"En el pantano hay ranas que dan lengüetazos.",
	"El mercader vende pociones a 15 de oro.",
	"Con amigos se pelea mejor.",
	"¿Has visto el molino? Lo hizo mi abuelo.",
	"Cuidado con el gólem de las ruinas.",
	"Los lobos salen en la pradera.",
	"¡Qué buen tiempo hace hoy!",
}

local function crearPaseante(tipo: string, id: string, x: number, z: number, desde: number, hasta: number, ancho: number, alto: number, vel: number, frases: { string }?, y0: number?): Paseante
	local ancla = anclaLocal(x, (y0 or 0) + alto / 2, z)
	local b = billboard(ancla, ancho, alto, 0)
	b.MaxDistance = 120
	local m = Munecos.crear(b, tipo, id, 3)
	local pa: Paseante = { m = m, ancla = ancla, x = x, z = z, desde = desde, hasta = hasta, vel = vel, dir = math.random() < 0.5 and -1 or 1, espera = math.random() * 3, burbuja = nil, frases = frases, proxFrase = os.clock() + 3 + math.random() * 12, vuela = m.vuela }
	table.insert(paseantes, pa)
	return pa
end

do
	-- vecinos de la ciudad
	for k = 1, 10 do
		local x = -185 + k * 20 + math.random(-5, 5)
		local z = ({ -10.4, -9.2, -3.5, 6.5 })[math.random(1, 4)]
		local chico = math.random() < 0.25
		crearPaseante("vecino", tostring(k * 7919), x, z, x - 18, x + 18, chico and 3.4 or 4.4, chico and 4.4 or 5.7, chico and 7 or 4.5, FRASES_VECINOS)
	end
	-- el mercader, quieto tras su mostrador
	local mercader = crearPaseante("vecino", "424242", -26, -9.9, -26, -26, 4.4, 5.7, 0, { "¡Pociones frescas!", "¡Éter para tu maná!", "Pasa, pasa, mira sin compromiso." })
	mercader.espera = math.huge
	-- monstruos que asoman junto a cada guarida
	local guaridas = { huerto = -262, pradera = 110, pantano = 215, bosque = 315, ruinas = 415, cueva = 540, picos = 662, cumbre = 772 }
	for _, zona in Datos.Zonas do
		local gx = guaridas[zona.id]
		if gx then
			local vistos: { [string]: boolean } = {}
			local n = 0
			for _, grupo in zona.grupos do
				for _, eid in grupo do
					if not vistos[eid] and n < 3 and not Datos.Enemigos[eid].jefe then
						vistos[eid] = true
						n += 1
						local t = Datos.Enemigos[eid].tamano * 0.85
						local lado = n % 2 == 0 and 1 or -1
						local x = gx + lado * (8 + n * 3)
						crearPaseante("enemigo", eid, x, -11.6, x - 5, x + 5, t * 1.3, t * 1.3, 3, nil)
					end
				end
			end
		end
	end
	-- el Rey Hongo vigila en la entrada de su cueva
	local rey = crearPaseante("enemigo", "reyHongo", 548, -12.2, 548, 548, 9, 9, 0, { "¡¿Quién osa entrar en mi cueva?!", "¡Grrr… hongos, atacad!" })
	rey.espera = math.huge
	-- tres años después, el Rey Hongo es el cocinero de la fiesta
	local function reyArrepentido()
		if jugador:GetAttribute("FinalVisto") == true then
			rey.frases = { "¡Guiso de calabaza! Sin setas, prometido.", "Psst, héroe. Ven, que tengo algo para ti.", "Echo de menos mi corona… pero no la cueva." }
		end
	end
	reyArrepentido()
	jugador:GetAttributeChangedSignal("FinalVisto"):Connect(reyArrepentido)
	-- el Yeti Tragón vigila la entrada de su cueva en la Cumbre
	local yeti = crearPaseante("enemigo", "yeti", 782, -15.5, 782, 782, 10, 10, 0, { "¡TENGO HAMBREEE!", "¡Esa olla es mía!", "¿Alguien ha dicho cena?" })
	yeti.espera = math.huge
	-- mariposas en la pradera y luciérnagas en el pantano y la cueva (decoración pequeña)
end

-- ----- conversaciones entre vecinos (se paran y hablan entre ellos) -----
local CONVERSACIONES = {
	{ "¿Has visto al Rey Hongo?", "No, pero lo he olido.", "Huele a sopa de champiñones caducada." },
	{ "Mi gallina ha puesto un huevo cuadrado.", "¿Y eso es bueno?", "Para jugar a los dados, sí." },
	{ "Dicen que Bruno hace trampas con los vasos.", "¡Calla, que te oye!", "¡TE HE OÍDO!" },
	{ "Ayer vi una babosa con sombrero.", "Sería la del alcalde.", "El alcalde ES una babosa." },
	{ "¿Vas a la taberna?", "No, que el guiso de ayer aún me habla.", "¿Y qué te dice?", "«Vuelve…»" },
	{ "El puente del río sigue roto.", "Hace falta una cuerda.", "Bruno tiene una. Pero no la da gratis." },
	{ "¿Has subido al pantano?", "Hay un cofre en lo alto de unas tablas.", "Yo tengo vértigo hasta en las escaleras." },
	{ "El ermitaño busca setas que brillan.", "¿Y para qué?", "Para leer de noche, supongo." },
	{ "¡Buenos días!", "Son las dos de la tarde.", "Pues buenos días igual." },
	{ "Me ha mordido un mímico.", "¿Un qué?", "Un cofre con dientes. No preguntes." },
	{ "¿Este año no hay Gran Guiso?", "Sin el Cucharón, no.", "Pues yo ya había traído pan." },
	{ "Dicen que el Rey Hongo lleva el Cucharón de corona.", "¿Y le queda bien?", "Fatal. Pero no se lo digas." },
	{ "Mi perro le ladra a las setas desde lo del Cucharón.", "Hace bien.", "Ayer le ladró a una tortilla." },
	{ "¿Has visto la olla gigante de la plaza?", "Fría como mi suegra.", "¡Que te oye!" },
}

local enConversacion: { [any]: boolean } = {}
local function conversar(a: any, b: any, lineas: { string })
	enConversacion[a], enConversacion[b] = true, true
	a.espera, b.espera = 30, 30
	a.dir = b.x > a.x and 1 or -1
	b.dir = -a.dir
	task.spawn(function()
		for i, linea in lineas do
			local quien = i % 2 == 1 and a or b
			burbuja(quien, linea)
			task.wait(2.6)
		end
		a.espera, b.espera = 1.5, 1.5
		task.delay(20, function()
			enConversacion[a], enConversacion[b] = nil, nil
		end)
	end)
end

local proximaCharla = os.clock() + 8
local function quizaCharla(cx: number)
	if os.clock() < proximaCharla then
		return
	end
	proximaCharla = os.clock() + 12 + math.random() * 10
	local cerca = {}
	for _, pa in paseantes do
		if pa.frases and pa.m.aspecto ~= 1 and pa.espera ~= math.huge and not enConversacion[pa] and math.abs(pa.x - cx) < 35 then
			table.insert(cerca, pa)
		end
	end
	for i = 1, #cerca do
		for j = i + 1, #cerca do
			if math.abs(cerca[i].x - cerca[j].x) < 16 then
				conversar(cerca[i], cerca[j], CONVERSACIONES[math.random(1, #CONVERSACIONES)])
				return
			end
		end
	end
end
Escena.quizaCharla = quizaCharla

-- ----- personajes con los que se habla (tabernero, ermitaño, herrera, posadera, paraderos) -----
-- El servidor marca sus puntos con el atributo "Npc" ("vecino:semilla" o "vendedor") y "Frases" (separadas por |).
local npcHechos: { [BasePart]: boolean } = {}
local function montarNpc(p: BasePart)
	local npc = p:GetAttribute("Npc") :: string?
	if not npc or npcHechos[p] then
		return
	end
	npcHechos[p] = true
	local tipo, semilla = string.match(npc, "^(%a+):?(%d*)$")
	local frases = nil
	local f = p:GetAttribute("Frases") :: string?
	if f then
		frases = string.split(f, "|")
	end
	local x = (p:GetAttribute("NpcX") :: number?) or p.Position.X
	local suelo = p.Position.Y - 2.8
	local pa = crearPaseante(tipo == "vendedor" and "vendedor" or "vecino", semilla ~= "" and semilla or "1", x, p.Position.Z - 0.4, x, x, 4.4, 5.7, 0, frases, suelo)
	pa.espera = math.huge
	pa.fuente = p
	pa.proxFrase = os.clock() + 1 + math.random() * 4
end
local function vigilarPunto(d: Instance)
	if d:IsA("BasePart") then
		if d:GetAttribute("Npc") then
			montarNpc(d)
		elseif d:GetAttribute("Punto") then
			d:GetAttributeChangedSignal("Npc"):Connect(function()
				montarNpc(d)
			end)
		end
	end
end
task.spawn(function()
	local mundo = workspace:WaitForChild("MundoVael", 60)
	if mundo then
		for _, d in mundo:GetDescendants() do
			vigilarPunto(d)
		end
		mundo.DescendantAdded:Connect(function(d)
			task.defer(vigilarPunto, d)
		end)
	end
end)

-- ----- barreras (cuerda, hacha, llave, farol) y secretos ya recogidos -----
local llavesMias: { [string]: boolean } = {}
local murosLocales: { [string]: Part } = {}
local function verModelo(m: Instance, visible: boolean)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.LocalTransparencyModifier = visible and 0 or 1
		elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
			d.Enabled = visible
		elseif d:IsA("ProximityPrompt") then
			d.Enabled = visible
		end
	end
	if m:IsA("BasePart") then
		m.LocalTransparencyModifier = visible and 0 or 1
	end
end

local estadoMio: any = nil
local function aplicarEstado()
	local mundo = workspace:FindFirstChild("MundoVael")
	if not mundo or not estadoMio then
		return
	end
	llavesMias = estadoMio.llaves or {}
	for _, m in mundo:GetChildren() do
		local llave = m:GetAttribute("Llave") :: string?
		if llave then
			local abierta = llavesMias[llave] == true
			local esCerrado = m:GetAttribute("Estado") == "cerrado"
			verModelo(m, esCerrado ~= abierta)
			if esCerrado then
				local muro = murosLocales[llave]
				if not abierta and not muro then
					local x = m:GetAttribute("MuroX") :: number
					local p = Instance.new("Part")
					p.Name = "Muro_" .. llave
					p.Anchored = true
					p.CanCollide = true
					p.CanQuery = false
					p.Transparency = 1
					p.Size = Vector3.new(1.5, 80, 30)
					p.Position = Vector3.new(x, 30, 0)
					p.Parent = carpetaVida
					murosLocales[llave] = p
				elseif abierta and muro then
					muro:Destroy()
					murosLocales[llave] = nil
				end
			end
		end
		local seta = m:GetAttribute("SetaId") :: number?
		if seta then
			verModelo(m, not (table.find(estadoMio.setas or {}, seta) or llavesMias.llave))
		end
		local palanca = m:GetAttribute("PalancaId") :: number?
		if palanca then
			local brazo = m:FindFirstChild("Brazo") :: BasePart?
			if brazo and table.find(estadoMio.palancas or {}, palanca) and not brazo:GetAttribute("Tirada") then
				brazo:SetAttribute("Tirada", true)
				TweenService:Create(brazo, TweenInfo.new(0.4, Enum.EasingStyle.Back), { CFrame = brazo.CFrame * CFrame.Angles(0, 0, math.rad(60)) }):Play()
			end
		end
	end
end

--- Bocadillo encima de una entidad del combate (frases de los monstruos y de los héroes).
function Escena.decir(id: string, texto: string)
	local a = anclaDe[id]
	if not a or not a:IsDescendantOf(workspace) then
		return
	end
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.fromOffset(240, 60)
	b.StudsOffset = Vector3.new(0, 6.5, 0)
	b.LightInfluence = 0
	b.AlwaysOnTop = true
	b.Adornee = a
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundColor3 = Color3.fromRGB(246, 238, 220)
	f.BorderSizePixel = 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 16)
	c.Parent = f
	local s = Instance.new("UIStroke")
	s.Thickness = 3
	s.Color = NEGRO
	s.Parent = f
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -16, 1, -10)
	t.Position = UDim2.fromOffset(8, 5)
	t.BackgroundTransparency = 1
	t.Text = texto
	t.Font = Enum.Font.PatrickHand
	t.TextScaled = true
	t.TextColor3 = NEGRO
	t.Parent = f
	f.Parent = b
	local escala = Instance.new("UIScale")
	escala.Scale = 0
	escala.Parent = f
	b.Parent = a
	TweenService:Create(escala, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	local m = porEntidad[id]
	if m then
		Munecos.hablar(m, 1)
	end
	task.delay(2.6, function()
		b:Destroy()
	end)
end

--- Lo llama la interfaz cada vez que llega el estado del jugador.
function Escena.estado(e: any)
	estadoMio = e
	aplicarEstado()
end
task.spawn(function()
	-- con StreamingEnabled las barreras pueden llegar tarde: se repasan cada poco
	while true do
		task.wait(3)
		aplicarEstado()
	end
end)

-- ----- aviso "Unirse al combate": solo para los que NO están en ese combate -----
local avisosUnirse: { ProximityPrompt } = {}
workspace.DescendantAdded:Connect(function(d)
	if d:IsA("ProximityPrompt") then
		task.defer(function()
			if d:GetAttribute("UnirseBatalla") then
				table.insert(avisosUnirse, d)
			end
		end)
	end
end)

--- Esconde el pasto de delante en la zona del combate (para que no tape a nadie).
local pastoOculto: { BasePart } = {}
function Escena.ocultarPasto(centro: Vector3?)
	for _, p in pastoOculto do
		p.LocalTransparencyModifier = 0
	end
	pastoOculto = {}
	if not centro then
		return
	end
	for _, b in balanceos do
		if math.abs(b.x - centro.X) < 24 and b.m.Parent then
			for _, p in b.m:GetDescendants() do
				if p:IsA("BasePart") then
					p.LocalTransparencyModifier = 1
					table.insert(pastoOculto, p)
				end
			end
		end
	end
end

Escena.modoMenu = false
Escena.alHablar = nil :: ((number, number) -> ())?
Escena.alPaso = nil :: (() -> ())?

type Bicho = { f: Frame, ancla: Part, base: Vector3, fase: number, alas: { Frame }? }
local bichos: { Bicho } = {}
local function crearBicho(x: number, y: number, z: number, color: Color3, luciernaga: boolean)
	local ancla = anclaLocal(x, y, z)
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.fromScale(luciernaga and 0.5 or 1.2, luciernaga and 0.5 or 1)
	b.LightInfluence = 0
	b.MaxDistance = 90
	b.Adornee = ancla
	b.Parent = ancla
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundTransparency = 1
	f.Parent = b
	local alas: { Frame } = {}
	if luciernaga then
		local l = Instance.new("Frame")
		l.Size = UDim2.fromScale(1, 1)
		l.BackgroundColor3 = color
		l.BorderSizePixel = 0
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0.5, 0)
		c.Parent = l
		l.Parent = f
	else
		for k = 0, 1 do
			local a = Instance.new("Frame")
			a.AnchorPoint = Vector2.new(k == 0 and 1 or 0, 0.5)
			a.Position = UDim2.fromScale(0.5, 0.5)
			a.Size = UDim2.fromScale(0.45, 0.8)
			a.BackgroundColor3 = color
			a.BorderSizePixel = 0
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0.5, 0)
			c.Parent = a
			local s = Instance.new("UIStroke")
			s.Thickness = 2
			s.Color = NEGRO
			s.Parent = a
			a.Parent = f
			table.insert(alas, a)
		end
	end
	table.insert(bichos, { f = f, ancla = ancla, base = Vector3.new(x, y, z), fase = math.random() * 10, alas = alas })
end
do
	local colores = { Color3.fromRGB(255, 200, 80), Color3.fromRGB(250, 130, 180), Color3.fromRGB(140, 200, 255), Color3.new(1, 1, 1) }
	for _ = 1, 14 do
		crearBicho(math.random(-430, 165), math.random(2, 5), math.random(-10, 6), colores[math.random(1, #colores)], false)
	end
	for _ = 1, 22 do
		local x = math.random() < 0.5 and math.random(165, 262) or math.random(465, 600)
		crearBicho(x, math.random(1, 6), math.random(-11, 6), Color3.fromRGB(230, 255, 120), true)
	end
end

-- ===================== BUCLE POR FOTOGRAMA =====================
local camX: number? = nil
local camY: number? = nil
local relojPaso = 0
local tiempo = 0

RunService:BindToRenderStep("EscenaVael", Enum.RenderPriority.Camera.Value + 1, function(dt)
	tiempo += dt
	local ch = jugador.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?

	-- cámara de lado (en combate la controla la interfaz de combate)
	if not Escena.enBatalla and raiz then
		camara.CameraType = Enum.CameraType.Scriptable
		camara.FieldOfView = 42
		-- correr con Mayús (pasa de andar a correr poco a poco, sin tirones)
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum and not raiz.Anchored and hum.WalkSpeed > 0 then
			local corre = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			local deseada = corre and 26 or 16
			hum.WalkSpeed += (deseada - hum.WalkSpeed) * math.min(1, dt * 6)
		end
		-- la cámara mira un poco hacia donde vas
		local miMuneco = heroes[jugador]
		local adelanto = miMuneco and miMuneco.m.mirar * 5 or 0
		local objetivoX = raiz.Position.X + adelanto
		local k = 1 - math.exp(-dt * 5)
		camX = camX and (camX + (objetivoX - camX) * k) or objetivoX
		-- la cámara sube con el jugador (plataformas, interiores)
		local objetivoY = math.max(11.5, raiz.Position.Y + 8.5)
		camY = camY and (camY + (objetivoY - camY) * k) or objetivoY
		local x = camX :: number
		local y = camY :: number
		local deseada = CFrame.lookAt(Vector3.new(x, y, 44), Vector3.new(x, y - 7, -2))
		if math.abs(camara.CFrame.Position.Y - y) > 60 then
			camara.CFrame = deseada -- tras entrar o salir de la taberna
		else
			camara.CFrame = camara.CFrame:Lerp(deseada, 1 - math.exp(-dt * 10))
		end
	end
	if Escena.modoMenu then
		-- menú de inicio: la cámara pasea despacio por la ciudad
		camara.CameraType = Enum.CameraType.Scriptable
		camara.FieldOfView = 40
		local x = -60 + math.sin(tiempo * 0.06) * 75
		camara.CFrame = CFrame.lookAt(Vector3.new(x, 15, 50), Vector3.new(x + 4, 6, -6))
	end
	for _, a in avisosUnirse do
		if a.Parent then
			a.Enabled = not Escena.enBatalla
		end
	end
	local cx = camara.CFrame.Position.X

	-- muñecos de los jugadores: andar y mirar según cómo se mueven
	for p, h in heroes do
		if h.raiz.Parent then
			local v = h.raiz.AssemblyLinearVelocity
			local plano = Vector3.new(v.X, 0, v.Z).Magnitude
			local humH = h.raiz.Parent and h.raiz.Parent:FindFirstChildOfClass("Humanoid")
			local enSuelo = h.raiz.Anchored or not humH or humH.FloorMaterial ~= Enum.Material.Air
			h.m.enSuelo = enSuelo
			h.m.vy = h.raiz.Anchored and 0 or v.Y
			local objetivo = (plano > 1.5 and not h.raiz.Anchored and enSuelo) and 1 or 0
			h.m.andar += (objetivo - h.m.andar) * math.min(1, dt * 10)
			h.m.ritmo = math.clamp(plano / 15, 0.8, 1.7)
			-- al pararse de golpe tras correr, un pequeño frenazo (se aplasta un instante)
			if objetivo == 0 and (h.m :: any).corria and enSuelo then
				h.m.aterriza = 0.14
			end
			;(h.m :: any).corria = plano > 18
			if p == jugador and h.m.andar > 0.6 then
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				if hum and hum.FloorMaterial ~= Enum.Material.Air then
					relojPaso -= dt
					if relojPaso <= 0 then
						relojPaso = 0.3
						if Escena.alPaso then
							Escena.alPaso()
						end
					end
				end
			end
			if h.raiz.Anchored then
				h.m.mirar = 1
			elseif math.abs(v.X) > 1 then
				h.m.mirar = math.sign(v.X)
			end
			-- qué vista toca: de lado (izquierda/derecha), de frente (hacia la cámara) o de espaldas (alejándose).
			-- En combate y en el aire, siempre de lado. Si se queda quieto un rato, se gira de frente.
			local hv = h :: any
			if hv.vistas then
				local nueva = hv.vista
				if h.raiz.Anchored or not enSuelo then
					nueva = "lado"
					hv.quieto = 0
				elseif plano > 1.5 then
					hv.quieto = 0
					if math.abs(v.X) >= math.abs(v.Z) * 0.8 then
						nueva = "lado"
					elseif v.Z > 0 then
						nueva = "frente"
					else
						nueva = "espalda"
					end
				else
					hv.quieto += dt
					if hv.quieto > 2.5 then
						nueva = "frente"
					end
				end
				local activo = hv.vistas[nueva].m
				if nueva ~= hv.vista then
					local antes = h.m
					hv.vista = nueva
					for nombre, vv in hv.vistas do
						vv.marco.Visible = nombre == nueva
					end
					-- el nuevo muñeco sigue el paso del anterior (sin saltos) y hace la "media vuelta"
					activo.t, activo.andar, activo.ritmo, activo.vy, activo.enSuelo = antes.t, antes.andar, antes.ritmo, antes.vy, antes.enSuelo
					activo.mirar = antes.mirar
					activo.giro = 0.16
					h.m = activo
					porEntidad["j" .. p.UserId] = activo
				end
				-- de lado mira a donde va (el dibujo mira a la derecha: a la izquierda, se da la vuelta)
				if nueva == "lado" then
					Munecos.espejo(activo, (h.m.mirar or 1) < 0)
				end
			end
		end
	end

	-- pasto y flores que se mecen (solo lo que se ve)
	for _, b in balanceos do
		if math.abs(b.x - cx) < 75 then
			local ang = math.sin(tiempo * 2.1 + b.x * 0.35) * 0.09
			if raiz and math.abs(raiz.Position.X - b.x) < 2.2 and math.abs(raiz.Position.Z - b.base.Position.Z) < 2.5 then
				ang += (raiz.Position.X < b.x and -0.35 or 0.35)
			end
			b.m:PivotTo(b.base * CFrame.Angles(0, 0, ang))
		end
	end
	for _, n in nubes do
		local piv = n.m:GetPivot()
		local nx = piv.Position.X + n.v * dt * 2
		if nx > 820 then
			nx = -320
		end
		local ny = n.f and n.y0 + math.sin(tiempo * n.f) * 1.5 or piv.Position.Y
		n.m:PivotTo(CFrame.new(nx, ny, piv.Position.Z))
	end
	for _, f in flotan do
		f.m:PivotTo(f.base + Vector3.new(0, math.sin(tiempo * f.v + f.fase) * 1.2, 0))
	end
	-- ojos en la oscuridad: se cierran y se abren de vez en cuando (a veces desaparecen un rato)
	local reloj = os.clock()
	for _, o in ojosLista do
		if reloj > o.prox and o.m.Parent then
			o.abiertos = not o.abiertos
			o.prox = reloj + (o.abiertos and math.random(2, 6) or (math.random() < 0.3 and 4 or 0.15))
			for _, p in o.m:GetChildren() do
				if p:IsA("BasePart") then
					p.Transparency = o.abiertos and 0 or 1
				end
			end
		end
	end
	-- luces que fallan (farolas del callejón y ventanas)
	for _, l in parpadean do
		if reloj > l.prox and l.p.Parent then
			local apagada = l.p.Transparency < 0.5 and math.random() < 0.5
			l.p.Transparency = apagada and 0.85 or 0
			l.prox = reloj + (apagada and math.random() * 0.25 or math.random() * 2.5 + 0.1)
		end
	end
	for _, h in humos do
		if h.p.Parent then
			local fase = (tiempo * 0.25 + h.fase) % 1
			h.p.CFrame = h.base + Vector3.new(fase * 2.5, fase * 9, 0)
			h.p.Transparency = 0.15 + fase * 0.85
		end
	end
	for _, g in giran do
		g.m:PivotTo(g.base * CFrame.Angles(0, 0, -tiempo * g.v))
	end
	for _, n in nieblas do
		n.p.CFrame = n.base + Vector3.new(math.sin(tiempo * 0.3 * n.v) * 6, 0, 0)
	end
	for k, c in chorros do
		c.p.CFrame = c.base + Vector3.new(0, math.sin(tiempo * 6 + k) * 0.35, 0)
	end

	-- paseantes
	local ahora = os.clock()
	for i = #paseantes, 1, -1 do
		local pa = paseantes[i]
		if pa.fuente and not pa.fuente:IsDescendantOf(workspace) then
			pa.ancla:Destroy()
			npcHechos[pa.fuente] = nil
			table.remove(paseantes, i)
		end
	end
	for _, pa in paseantes do
		if pa.espera > 0 then
			pa.espera -= dt
			pa.m.andar += (0 - pa.m.andar) * math.min(1, dt * 8)
		else
			pa.x += pa.dir * pa.vel * dt
			if pa.x > pa.hasta or pa.x < pa.desde then
				pa.x = math.clamp(pa.x, pa.desde, pa.hasta)
				pa.dir = -pa.dir
				pa.espera = 1 + math.random() * 3
			end
			pa.m.andar += (1 - pa.m.andar) * math.min(1, dt * 8)
		end
		pa.m.mirar = pa.dir
		if pa.m.aspecto == 1 then
			Munecos.espejo(pa.m, pa.dir > 0) -- los monstruos están dibujados mirando a la izquierda
		end
		pa.ancla.Position = Vector3.new(pa.x, pa.ancla.Position.Y, pa.z)
		-- durante un combate se apartan de escena los que están cerca (que no haya dos Reyes Hongo)
		local bb = pa.m.raiz.Parent
		if bb and bb:IsA("BillboardGui") then
			bb.Enabled = not (Escena.enBatalla and math.abs(pa.x - cx) < 40)
		end
		if pa.frases and ahora > pa.proxFrase and math.abs(pa.x - cx) < 45 then
			pa.proxFrase = ahora + 9 + math.random() * 14
			burbuja(pa, pa.frases[math.random(1, #pa.frases)])
		end
	end

	quizaCharla(cx)

	-- bichos
	for _, b in bichos do
		if math.abs(b.base.X - cx) < 80 then
			local t = tiempo + b.fase
			b.ancla.Position = b.base + Vector3.new(math.sin(t * 0.7) * 4, math.sin(t * 1.9) * 0.8, math.cos(t * 0.5) * 1.5)
			if b.alas then
				for _, a in b.alas do
					a.Size = UDim2.fromScale(0.45, 0.2 + math.abs(math.sin(t * 14)) * 0.6)
				end
			end
		end
	end
end)

-- ===================== AMBIENTE POR ZONA =====================
-- Cada sitio tiene su luz: el Callejón se oscurece (con viñeta), el Pantano se pone verdoso, la Cueva fría,
-- y la taberna y la posada cálidas. Todo es local (solo lo ve este jugador) y con fundido suave.
local Lighting = game:GetService("Lighting")
local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "VaelAmbiente"
cc.Parent = Lighting
local guiAmbiente = Instance.new("ScreenGui")
guiAmbiente.Name = "VaelAmbiente"
guiAmbiente.IgnoreGuiInset = true
guiAmbiente.ResetOnSpawn = false
guiAmbiente.DisplayOrder = -5
guiAmbiente.AutoLocalize = false
guiAmbiente.Parent = jugador:WaitForChild("PlayerGui")
-- viñeta: cuatro bordes oscuros que se difuminan hacia el centro
local bordes: { Frame } = {}
for _, d in { { 0, 0, 1, 0.32, 90 }, { 0, 0.68, 1, 0.32, -90 }, { 0, 0, 0.24, 1, 0 }, { 0.76, 0, 0.24, 1, 180 } } do
	local f = Instance.new("Frame")
	f.Position = UDim2.fromScale(d[1], d[2])
	f.Size = UDim2.fromScale(d[3], d[4])
	f.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
	f.BorderSizePixel = 0
	f.BackgroundTransparency = 1
	f.Parent = guiAmbiente
	local g = Instance.new("UIGradient")
	g.Rotation = d[5]
	g.Transparency = NumberSequence.new(0, 1)
	g.Parent = f
	table.insert(bordes, f)
end

type Ambiente = { brillo: number, contraste: number, saturacion: number, tinte: Color3, vineta: number }
local AMBIENTES: { [string]: Ambiente } = {
	normal = { brillo = 0, contraste = 0, saturacion = 0, tinte = Color3.new(1, 1, 1), vineta = 1 },
	callejon = { brillo = -0.14, contraste = 0.08, saturacion = -0.3, tinte = Color3.fromRGB(170, 180, 235), vineta = 0.15 },
	pantano = { brillo = -0.03, contraste = 0, saturacion = -0.12, tinte = Color3.fromRGB(215, 235, 205), vineta = 0.65 },
	bosque = { brillo = -0.04, contraste = 0.02, saturacion = 0, tinte = Color3.fromRGB(220, 238, 215), vineta = 0.7 },
	ruinas = { brillo = 0, contraste = 0, saturacion = -0.12, tinte = Color3.fromRGB(240, 230, 215), vineta = 0.8 },
	cueva = { brillo = -0.1, contraste = 0.06, saturacion = -0.15, tinte = Color3.fromRGB(200, 190, 225), vineta = 0.35 },
	taberna = { brillo = 0, contraste = 0.02, saturacion = 0.05, tinte = Color3.fromRGB(255, 225, 190), vineta = 0.55 },
	posada = { brillo = -0.02, contraste = 0, saturacion = 0, tinte = Color3.fromRGB(255, 232, 205), vineta = 0.6 },
	nieve = { brillo = 0.04, contraste = -0.02, saturacion = -0.15, tinte = Color3.fromRGB(220, 232, 255), vineta = 0.75 },
}
local function ambienteDe(p: Vector3): string
	if p.Y > 650 then
		return "callejon"
	elseif p.Y > 450 then
		return "normal" -- Calle del Mercado: alegre
	elseif p.Y > 300 then
		return "posada"
	elseif p.Y > 150 then
		return "taberna"
	elseif p.X > 606 then
		return "nieve"
	elseif p.X > 462 then
		return "cueva"
	elseif p.X > 362 then
		return "ruinas"
	elseif p.X > 262 then
		return "bosque"
	elseif p.X > 165 then
		return "pantano"
	end
	return "normal"
end
local ambienteActual = ""
task.spawn(function()
	while true do
		task.wait(0.4)
		local ch = jugador.Character
		local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local nombre = raiz and ambienteDe(raiz.Position) or "normal"
		if nombre ~= ambienteActual then
			ambienteActual = nombre
			local a = AMBIENTES[nombre]
			local info = TweenInfo.new(1.4, Enum.EasingStyle.Sine)
			TweenService:Create(cc, info, { Brightness = a.brillo, Contrast = a.contraste, Saturation = a.saturacion, TintColor = a.tinte }):Play()
			for _, b in bordes do
				TweenService:Create(b, info, { BackgroundTransparency = a.vineta }):Play()
			end
		end
	end
end)

return Escena
