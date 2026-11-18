--!strict
-- Crónicas de Vael · cliente: HUD, misión, elegir clase, tiendas, diálogos,
-- el juego de los vasos, cartas de mejoras, avisos y la interfaz del combate por turnos con casillas.
-- Fluidez: la interfaz se anima con TweenService y la cámara de combate se mueve en RenderStepped
-- (una vez por fotograma, a los 60 fps del cliente), con suavizado exponencial para que nunca dé tirones.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer
-- marca de por dónde va el script (la enseña Diagnostico si algo se queda parado)
local function paso(nombre: string)
	jugador:SetAttribute("PasoPrincipal", nombre)
end
paso("inicio")
local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael:WaitForChild("Datos"))
paso("datos")
local Remotos = Vael:WaitForChild("Remotos")
paso("remotos")
local Ui = require(script.Parent:WaitForChild("Ui"))
paso("ui")
local Munecos = require(script.Parent:WaitForChild("Munecos"))
paso("munecos")
local Escena = require(script.Parent:WaitForChild("Escena"))
paso("escena")
local Efectos = require(script.Parent:WaitForChild("Efectos"))
paso("efectos")
local Audio = require(script.Parent:WaitForChild("Audio"))
paso("audio")
Escena.alPaso = Audio.paso
Escena.alHablar = Audio.hablar
local C = Ui.Colores

local function remoto(nombre: string): RemoteEvent
	return Remotos:WaitForChild(nombre) :: RemoteEvent
end

local gui = Ui.crear("ScreenGui", { Name = "Vael", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = jugador:WaitForChild("PlayerGui") })

--- Retrato animado (el muñeco 2D vivo, recortado en un círculo). tipo: "clase" o "enemigo".
local HttpService = game:GetService("HttpService")

--- Apariencia de un jugador (la guarda el servidor en el atributo "Apariencia").
local function aparienciaDe(p: Player?): any
	local texto = p and (p:GetAttribute("Apariencia") :: string?)
	if texto then
		local ok, t = pcall(function()
			return HttpService:JSONDecode(texto)
		end)
		if ok then
			return t
		end
	end
	return nil
end

local function jugadorDeEntidad(id: string): Player?
	local uid = tonumber(string.match(id, "^j(%d+)$"))
	return uid and Players:GetPlayerByUserId(uid) or nil
end

local function retrato(padre: Instance, tipo: string, id: string, pos: UDim2, tam: UDim2, fondo: Color3?, z: number?, ap: any?): CanvasGroup
	local marco = Ui.crear("CanvasGroup", { Position = pos, Size = tam, BackgroundColor3 = fondo or Color3.fromRGB(255, 240, 200), BorderSizePixel = 0, ZIndex = z or 1, Parent = padre })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = marco })
	Ui.crear("UIStroke", { Thickness = 3, Color = C.tinta, Parent = marco })
	local lienzo = Ui.crear("Frame", { BackgroundTransparency = 1, Parent = marco })
	if tipo == "enemigo" then
		lienzo.Size = UDim2.fromScale(1.15, 1.15)
		lienzo.Position = UDim2.fromScale(-0.08, 0.02)
	else
		lienzo.Size = UDim2.fromScale(1.7, 2.21)
		lienzo.Position = UDim2.fromScale(-0.35, -0.42)
	end
	Munecos.crear(lienzo, tipo, id, 2, ap)
	return marco
end

-- ===================== AVISOS =====================
local function notificar(texto: string)
	local aviso = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -90), Size = UDim2.fromOffset(420, 58), Parent = gui, ZIndex = 50 })
	Ui.texto({ Size = UDim2.new(1, -24, 1, -14), Position = UDim2.fromOffset(12, 7), Text = texto, Parent = aviso, ZIndex = 51 })
	Ui.tween(aviso, { Position = UDim2.new(0.5, 0, 0, 70) }, 0.5, Enum.EasingStyle.Back)
	task.delay(2.6, function()
		Ui.tween(aviso, { Position = UDim2.new(0.5, 0, 0, -90) }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
		aviso:Destroy()
	end)
end
remoto("Notificar").OnClientEvent:Connect(function(texto: string)
	Audio.sfx("aviso", 0.5)
	notificar(texto)
end)
remoto("Sonido").OnClientEvent:Connect(function(nombre: string)
	Audio.sfx(nombre)
end)

-- el menú de inicio (otro script) avisa con el atributo local "EnMenu"; mientras esté, no se abre nada encima
local function enMenu(): boolean
	-- solo si el menú existe de verdad (si fallara, el HUD se ve igual)
	local pg = jugador:FindFirstChild("PlayerGui")
	return jugador:GetAttribute("EnMenu") == true and pg ~= nil and pg:FindFirstChild("VaelMenu") ~= nil
end

-- ===================== HUD =====================
paso('HUD compacto')
-- HUD compacto: retrato, nombre, nivel, vida, maná, experiencia y oro en un panel pequeño arriba a la izquierda
local hud = Ui.panel({ Position = UDim2.fromOffset(12, 58), Size = UDim2.fromOffset(300, 100), Parent = gui, Visible = false })
local hudRetrato: CanvasGroup? = nil
local hudClase: string? = nil
local hudNombre = Ui.texto({ Position = UDim2.fromOffset(92, 9), Size = UDim2.new(1, -160, 0, 20), Text = "", TextXAlignment = Enum.TextXAlignment.Left, Parent = hud })
local hudNivel = Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 9), Size = UDim2.fromOffset(60, 20), Text = "", TextColor3 = C.oro, TextXAlignment = Enum.TextXAlignment.Right, Parent = hud, ZIndex = 3 })
Ui.icono("corazon", hud, UDim2.fromOffset(90, 33), UDim2.fromOffset(16, 16))
local hudVida = Ui.barra(hud, UDim2.fromOffset(110, 34), UDim2.new(1, -122, 0, 14), C.vida, true)
Ui.icono("gota", hud, UDim2.fromOffset(90, 52), UDim2.fromOffset(16, 16))
local hudMana = Ui.barra(hud, UDim2.fromOffset(110, 53), UDim2.new(1, -122, 0, 12), C.mana, true)
local hudXp = Ui.barra(hud, UDim2.fromOffset(92, 71), UDim2.new(1, -104, 0, 5), C.xp, false)
local hudInfo = Ui.texto({ Position = UDim2.fromOffset(92, 79), Size = UDim2.new(1, -104, 0, 15), Text = "", TextColor3 = C.oro, TextXAlignment = Enum.TextXAlignment.Left, Parent = hud })
-- misión actual: discreta, debajo del HUD
local Mapa = require(script.Parent:WaitForChild("MapaVael"))
local mision = Ui.panel({ Position = UDim2.fromOffset(12, 164), Size = UDim2.fromOffset(300, 40), BackgroundColor3 = Color3.fromRGB(120, 95, 70), Parent = gui, Visible = false })
Ui.icono("estrella", mision, UDim2.fromOffset(10, 9), UDim2.fromOffset(22, 22), 2)
local misionTexto = Ui.texto({ Position = UDim2.fromOffset(38, 6), Size = UDim2.new(1, -48, 1, -12), Text = "", TextXAlignment = Enum.TextXAlignment.Left, Parent = mision, ZIndex = 2 })

-- mochila: mejoras (como en los roguelikes, se ven todas) y objetos clave
local mochila = Ui.crear("Frame", { Position = UDim2.fromOffset(18, 248), Size = UDim2.fromOffset(410, 40), BackgroundTransparency = 1, Parent = gui, Visible = false })
Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = mochila })
local consejo = Ui.panel({ Size = UDim2.fromOffset(260, 74), Parent = gui, Visible = false, ZIndex = 60 })
local consejoTexto = Ui.texto({ Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 1, -16), Text = "", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = consejo, ZIndex = 61 })
local function casillaMochila(icono: string, color: Color3, borde: Color3, titulo: string, texto: string, apagada: boolean?, cuenta: number?)
	local f = Ui.crear("Frame", { Size = UDim2.fromOffset(36, 36), BackgroundColor3 = apagada and Color3.fromRGB(50, 45, 60) or Color3.fromRGB(255, 248, 230), BackgroundTransparency = apagada and 0.4 or 0, BorderSizePixel = 0, Parent = mochila })
	Ui.esquinas(f, 9)
	Ui.borde(f, apagada and Color3.fromRGB(90, 85, 100) or borde, 3)
	local ic = Ui.icono(icono, f, UDim2.fromOffset(5, 5), UDim2.fromOffset(26, 26), 2)
	if apagada then
		for _, d in ic:GetDescendants() do
			if d:IsA("Frame") then
				d.BackgroundTransparency = 0.7
			end
		end
	else
		-- un toque del color de la mejora
		Ui.crear("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -3, 1, -3), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 3, Parent = f })
	end
	if cuenta and cuenta > 1 then
		Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 4, 0, -6), Size = UDim2.fromOffset(24, 16), Text = "×" .. cuenta, ZIndex = 4, Parent = f })
	end
	f.MouseEnter:Connect(function()
		consejoTexto.Text = titulo .. "\n" .. texto
		consejo.Position = UDim2.fromOffset(f.AbsolutePosition.X, f.AbsolutePosition.Y + 44)
		consejo.Visible = true
	end)
	f.MouseLeave:Connect(function()
		consejo.Visible = false
	end)
end
local function actualizarMochila(e: any)
	for _, h in mochila:GetChildren() do
		if h:IsA("Frame") then
			h:Destroy()
		end
	end
	for _, id in Datos.OrdenLlaves do
		local l = Datos.Llaves[id]
		local tengo = e.llaves and e.llaves[id]
		casillaMochila(l.icono, l.color, Color3.fromRGB(255, 205, 90), tengo and l.nombre or "¿?", tengo and l.descripcion or "Aún no lo tienes. Explora.", not tengo)
	end
	local cuenta: { [string]: number } = {}
	local orden: { string } = {}
	for _, id in e.mejoras or {} do
		if not cuenta[id] then
			table.insert(orden, id)
		end
		cuenta[id] = (cuenta[id] or 0) + 1
	end
	for _, id in orden do
		local m = Datos.Mejoras[id]
		if m then
			casillaMochila(m.icono, m.color, Datos.ColorRareza[m.rareza], m.nombre, m.descripcion, false, cuenta[id])
		end
	end
	mochila.Visible = false
	local textoMision = Mapa.objetivo(e)
	misionTexto.Text = Ui.t(textoMision)
	mision.Visible = hud.Visible
end

local estadoActual: any = nil
local selector: Frame? = nil

paso('ELEGIR CLASE')
-- ===================== ELEGIR CLASE =====================
local function abrirSelector()
	if selector then
		return
	end
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.fondo, BackgroundTransparency = 1, Parent = gui, ZIndex = 20 })
	selector = capa
	Ui.tween(capa, { BackgroundTransparency = 0.15 }, 0.5)
	local titulo = Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 30), Size = UDim2.fromOffset(760, 84), Text = "Crónicas de Vael", TextColor3 = C.borde, Parent = capa, ZIndex = 21 })
	local trazoTitulo = titulo:FindFirstChildOfClass("UIStroke")
	if trazoTitulo then
		trazoTitulo.Thickness = 5
	end
	Ui.aparecer(titulo)
	-- el título se balancea como un cartel colgado
	task.spawn(function()
		local lado = 1
		while titulo.Parent do
			Ui.tween(titulo, { Rotation = 2.5 * lado }, 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			lado = -lado
			task.wait(1.4)
		end
	end)
	Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 112), Size = UDim2.fromOffset(700, 30), Text = "Elige tu clase. Juega solo o con amigos.", Font = Ui.FuenteTexto, TextColor3 = C.suave, Parent = capa, ZIndex = 21 })
	local fila = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.58), Size = UDim2.fromOffset(1040, 430), BackgroundTransparency = 1, Parent = capa, ZIndex = 21 })
	Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 18), Parent = fila })
	for i, cid in Datos.OrdenClases do
		local cl = Datos.Clases[cid]
		local tarjeta = Ui.panel({ Size = UDim2.fromOffset(240, 420), Parent = fila, ZIndex = 22, Visible = false })
		local cab = Ui.crear("Frame", { Size = UDim2.new(1, -16, 0, 200), Position = UDim2.fromOffset(8, 8), BackgroundColor3 = cl.color:Lerp(Color3.new(1, 1, 1), 0.45), BorderSizePixel = 0, Parent = tarjeta, ZIndex = 23 })
		Ui.esquinas(cab, 14)
		Ui.borde(cab, C.tinta, 3)
		-- rayos de fondo que giran despacio
		for k = 0, 1 do
			local rayos = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.55), Size = UDim2.fromOffset(130, 130), Rotation = k * 45, BackgroundColor3 = cl.color, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 23, Parent = cab })
			Ui.esquinas(rayos, 12)
			TweenService:Create(rayos, TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = k * 45 + 360 }):Play()
		end
		local lienzo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -4), Size = UDim2.fromOffset(120, 156), BackgroundTransparency = 1, ZIndex = 24, Parent = cab })
		local mu = Munecos.crear(lienzo, "clase", cid, 3)
		tarjeta.MouseEnter:Connect(function()
			Munecos.atacar(mu, 1)
		end)
		Ui.texto({ Size = UDim2.new(1, -20, 0, 40), Position = UDim2.fromOffset(10, 212), Text = cl.nombre, TextColor3 = cl.color:Lerp(Color3.new(1, 1, 1), 0.3), Parent = tarjeta, ZIndex = 24 })
		Ui.texto({ Size = UDim2.new(1, -24, 0, 46), Position = UDim2.fromOffset(12, 252), Text = cl.descripcion, TextWrapped = true, TextColor3 = C.suave, Parent = tarjeta, ZIndex = 23 })
		local s = cl.base
		Ui.texto({ Size = UDim2.new(1, -24, 0, 44), Position = UDim2.fromOffset(12, 300), Text = string.format("Vida %d · Maná %d · Ataque %d\nMagia %d · Defensa %d · Velocidad %d", s.hp, s.mp, s.atk, s.mag, s.def, s.spd), TextWrapped = true, Parent = tarjeta, ZIndex = 23 })
		Ui.boton({ Size = UDim2.new(1, -30, 0, 50), Position = UDim2.new(0, 15, 1, -64), Text = "¡Elegir!", BackgroundColor3 = cl.color, Icono = "estrella", Parent = tarjeta, ZIndex = 24 }, function()
			remoto("ElegirClase"):FireServer(cid)
			Ui.tween(capa, { BackgroundTransparency = 1 }, 0.4)
			for _, d in capa:GetDescendants() do
				if d:IsA("GuiObject") then
					Ui.tween(d, { BackgroundTransparency = 1 }, 0.3)
				end
				if d:IsA("TextLabel") or d:IsA("TextButton") then
					Ui.tween(d, { TextTransparency = 1 }, 0.3)
				end
			end
			task.delay(0.45, function()
				capa:Destroy()
				selector = nil
			end)
		end)
		Ui.aparecer(tarjeta, 0.15 + i * 0.09)
	end
end

local function actualizarHud(e: any)
	estadoActual = e
	Escena.estado(e)
	if enMenu() then
		hud.Visible = false
		mochila.Visible = false
		mision.Visible = false
		return
	end
	if not e.clase then
		hud.Visible = false
		abrirSelector()
		return
	end
	if estadoActual and e.oro and hudInfo.Text ~= "" then
		local antes = tonumber(string.match(hudInfo.Text, "^(%d+)"))
		if antes and e.oro > antes then
			Audio.sfx("moneda", 0.6)
		end
	end
	if not hud.Visible then
		Ui.aparecer(hud)
	end
	local cl = Datos.Clases[e.clase]
	local firma = e.clase .. HttpService:JSONEncode(e.apariencia or {})
	if hudClase ~= firma then
		hudClase = firma
		if hudRetrato then
			hudRetrato:Destroy()
		end
		hudRetrato = retrato(hud, "clase", e.clase, UDim2.fromOffset(12, 12), UDim2.fromOffset(72, 72), Color3.fromRGB(236, 222, 190), 2, e.apariencia)
	end
	hudNivel.Text = Ui.t("Nv.") .. " " .. e.nivel
	hudNombre.Text = ((e.nombreHeroe and e.nombreHeroe ~= "") and e.nombreHeroe or jugador.DisplayName) .. " · " .. cl.nombre
	hudNombre.TextColor3 = cl.color:Lerp(Color3.new(1, 1, 1), 0.35)
	hudVida.set(e.hp, e.maxHp)
	hudMana.set(e.mp, e.maxMp)
	hudXp.set(e.xp, e.xpSiguiente)
	hudInfo.Text = string.format("%d %s  ·  %d %s", e.oro, Ui.t("oro"), e.objetos.pocion or 0, Ui.t("pociones"))
	actualizarMochila(e)
end
remoto("EstadoJugador").OnClientEvent:Connect(actualizarHud)

-- ===================== TIENDA =====================
remoto("AbrirTienda").OnClientEvent:Connect(function(lista: any)
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(420, 120 + #lista * 74), Parent = gui, ZIndex = 30 })
	Ui.aparecer(p)
	Ui.texto({ Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 10), Text = "Mercader", TextColor3 = C.borde, Parent = p, ZIndex = 31 })
	for i, o in lista do
		Ui.boton({ Size = UDim2.new(1, -40, 0, 60), Position = UDim2.fromOffset(20, 60 + (i - 1) * 70), Text = string.format("%s  ·  %d oro", o.nombre, o.precio), Icono = o.id, BackgroundColor3 = o.id == "pocion" and Color3.fromRGB(150, 50, 70) or Color3.fromRGB(50, 90, 160), Parent = p, ZIndex = 31 }, function()
			remoto("Comprar"):FireServer(o.id)
		end)
	end
	Ui.boton({ Size = UDim2.new(1, -40, 0, 44), Position = UDim2.new(0, 20, 1, -56), Text = "Cerrar", Icono = "volver", BackgroundColor3 = C.fondo, Parent = p, ZIndex = 31 }, function()
		Ui.tween(p:FindFirstChildOfClass("UIScale") :: UIScale, { Scale = 0 }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
		p:Destroy()
	end)
end)

paso('COMBATE')
-- ===================== COMBATE =====================
local camara = workspace.CurrentCamera
local enBatalla = false
local centro = Vector3.zero
local sacudida = 0
local miTurno = false
local estadoBatalla: any = nil
local posiciones: { [string]: Vector3 } = {}

local capaBatalla = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = gui, Visible = false })
local barraArriba = Ui.crear("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = capaBatalla })
local barraAbajo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = capaBatalla })
local tituloBatalla = Ui.texto({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(700, 110), Text = "", TextColor3 = C.borde, Parent = capaBatalla, ZIndex = 10, Visible = false })
local trazoBatalla = tituloBatalla:FindFirstChildOfClass("UIStroke")
if trazoBatalla then
	trazoBatalla.Thickness = 5
end

-- orden de turnos (arriba)
local tira = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 92), Size = UDim2.fromOffset(760, 72), BackgroundTransparency = 1, Parent = capaBatalla })
Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 8), Parent = tira })
local fichasTira: { [string]: Frame } = {}
local turnoTexto = Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 166), Size = UDim2.fromOffset(500, 34), Text = "", Parent = capaBatalla })

-- tarjetas del equipo (abajo a la izquierda)
local equipo = Ui.crear("Frame", { Position = UDim2.new(0, 18, 1, -300), Size = UDim2.fromOffset(400, 290), BackgroundTransparency = 1, Parent = capaBatalla })
Ui.crear("UIListLayout", { Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = equipo })
local tarjetas: { [string]: { marco: Frame, vida: Ui.Barra, mana: Ui.Barra, nombre: TextLabel } } = {}

-- registro de lo que pasa (centro)
local registro = Ui.texto({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -112), Size = UDim2.fromOffset(640, 38), Text = "", Font = Ui.FuenteTexto, Parent = capaBatalla, TextTransparency = 1 })

-- menú de acciones (abajo a la derecha)
local menu = Ui.panel({ AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, 300), Size = UDim2.fromOffset(420, 300), Parent = capaBatalla })
local menuTitulo = Ui.texto({ Size = UDim2.new(1, -20, 0, 32), Position = UDim2.fromOffset(10, 8), Text = "¿Qué haces?", TextColor3 = C.borde, Parent = menu })
local reloj = Ui.crear("Frame", { Position = UDim2.fromOffset(14, 44), Size = UDim2.new(1, -28, 0, 8), BackgroundColor3 = C.oro, BorderSizePixel = 0, Parent = menu })
Ui.borde(reloj, C.tinta, 2)
Ui.esquinas(reloj, 999)
local opciones = Ui.crear("ScrollingFrame", { Position = UDim2.fromOffset(14, 58), Size = UDim2.new(1, -28, 1, -70), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = menu })
Ui.crear("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 0, 52), CellPadding = UDim2.fromOffset(8, 8), Parent = opciones })

local peticion: any = nil
local relojTween: Tween? = nil

-- ===================== CASILLAS DEL CAMPO =====================
local carpetaBatalla: Instance? = nil
local casillas: { [string]: { p: BasePart, color: Color3, transparencia: number } } = {}
local pintadas: { string } = {}
type Seleccion = { validos: { [string]: string }, alElegir: (id: string) -> () }
local seleccion: Seleccion? = nil
local puedoMover: { [string]: boolean } = {}

local function clave(c: number, f: number): string
	return c .. "," .. f
end

local function cargarCasillas()
	casillas = {}
	if not carpetaBatalla then
		return
	end
	for _, p in (carpetaBatalla :: Instance):GetChildren() do
		if p:IsA("BasePart") and p.Name == "Casilla" then
			casillas[clave(p:GetAttribute("Col") :: number, p:GetAttribute("Fila") :: number)] = { p = p, color = p.Color, transparencia = p.Transparency }
		end
	end
end

local function limpiarCasillas()
	for _, k in pintadas do
		local c = casillas[k]
		if c and c.p.Parent then
			c.p.Color = c.color
			c.p.Transparency = c.transparencia
		end
	end
	pintadas = {}
end

local function pintar(k: string, color: Color3)
	if not casillas[k] then
		if not carpetaBatalla and estadoBatalla then
			carpetaBatalla = workspace:FindFirstChild("Batalla_" .. tostring(estadoBatalla.id))
		end
		cargarCasillas()
	end
	local c = casillas[k]
	if c and c.p.Parent then
		c.p.Color = color
		c.p.Transparency = 0.15
		table.insert(pintadas, k)
	end
end

local VERDE = Color3.fromRGB(120, 230, 120)
local ROJO = Color3.fromRGB(255, 110, 110)
local AZUL = Color3.fromRGB(120, 190, 255)

local function pintarMovimiento()
	limpiarCasillas()
	for k in puedoMover do
		pintar(k, VERDE)
	end
end

local function cerrarMenu()
	miTurno = false
	seleccion = nil
	puedoMover = {}
	limpiarCasillas()
	Ui.tween(menu, { Position = UDim2.new(1, -18, 1, 300) }, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	if relojTween then
		relojTween:Cancel()
	end
end

local function enviar(accion: any)
	if not miTurno then
		return
	end
	remoto("EnviarAccion"):FireServer(accion)
	cerrarMenu()
end

local function limpiarOpciones()
	for _, h in opciones:GetChildren() do
		if h:IsA("GuiObject") then
			h:Destroy()
		end
	end
end

local mostrarPrincipal: () -> ()

local function opcion(texto: string, color: Color3?, activa: boolean, alPulsar: () -> (), orden: number, icono: string?)
	local b = Ui.boton({ Text = texto, BackgroundColor3 = color or C.fondo, LayoutOrder = orden, Icono = icono, Parent = opciones }, function()
		if activa then
			alPulsar()
		end
	end)
	if not activa then
		b.TextTransparency = 0.45
		b.TextStrokeTransparency = 0.7
		b.BackgroundTransparency = 0.4
	end
	Ui.aparecer(b, orden * 0.03)
end

--- Lista de objetivos a tu alcance (enemigos vivos, aliados vivos o aliados caídos). También se pueden pulsar
--- en el campo: las casillas a tiro se pintan de rojo (enemigos) o azul (aliados).
local function elegirObjetivo(lado: string, caidos: boolean, alcance: number?, alElegir: (id: string) -> ())
	limpiarOpciones()
	limpiarCasillas()
	menuTitulo.Text = Ui.t("¿A quién?")
	local lista = estadoBatalla and (lado == "enemigo" and estadoBatalla.enemigos or estadoBatalla.aliados) or {}
	local n = 0
	local validos: { [string]: string } = {}
	for _, e in lista do
		local dist = (peticion and e.col) and (math.abs(e.col - peticion.col) + math.abs(e.fila - peticion.fila)) or 0
		if ((caidos and not e.vivo) or (not caidos and e.vivo)) and (not alcance or dist <= alcance) then
			n += 1
			validos[clave(e.col, e.fila)] = e.id
			pintar(clave(e.col, e.fila), lado == "enemigo" and ROJO or AZUL)
			opcion(string.format("%s (%d)", e.nombre, e.hp), lado == "enemigo" and Color3.fromRGB(170, 60, 70) or Color3.fromRGB(60, 140, 90), true, function()
				alElegir(e.id)
			end, n)
		end
	end
	-- las rocas del campo también se pueden romper (con ataques y habilidades de daño)
	if lado == "enemigo" and not caidos and estadoBatalla and estadoBatalla.casillas then
		for k, t in estadoBatalla.casillas do
			local c, f = string.match(k, "(%d+),(%d+)")
			local col, fila = tonumber(c), tonumber(f)
			local dist = (peticion and col and fila) and (math.abs(col - peticion.col) + math.abs(fila - peticion.fila)) or 99
			if t == "roca" and (not alcance or dist <= alcance) then
				n += 1
				validos[k] = "roca:" .. k
				pintar(k, Color3.fromRGB(200, 170, 110))
				opcion("Romper roca", Color3.fromRGB(130, 110, 90), true, function()
					alElegir("roca:" .. k)
				end, n, "espada")
			end
		end
	end
	seleccion = { validos = validos, alElegir = alElegir }
	if n == 0 then
		menuTitulo.Text = Ui.t("¡Nadie a tu alcance! Muévete")
	end
	opcion("Volver", nil, true, function()
		seleccion = nil
		mostrarPrincipal()
	end, n + 1, "volver")
end

local function mostrarHabilidades()
	limpiarOpciones()
	menuTitulo.Text = Ui.t("Habilidades")
	for i, h in peticion.habilidades do
		local zona = (h.area == "todos" and "todos") or (h.area == "alrededor" and "pegados") or (h.area == "alrededor2" and "cerca") or ("alc. " .. h.alcance)
		local texto = h.bloqueada and string.format("%s (nivel %d)", h.nombre, h.nivelMinimo) or string.format("%s · %d PM · %s", h.nombre, h.coste, zona)
		local icono = (h.tipo == "cura" or h.tipo == "revivir") and "corazon" or h.tipo == "mejora" and "escudo" or "magia"
		opcion(texto, Color3.fromRGB(80, 60, 150), not h.bloqueada and not h.sinMana, function()
			local conObjetivo = h.area == "uno" or h.area == "cruz"
			if conObjetivo and (h.tipo == "dano") then
				elegirObjetivo("enemigo", false, h.alcance, function(id)
					enviar({ tipo = "habilidad", id = h.id, objetivo = id })
				end)
			elseif conObjetivo and h.objetivo == "aliado" then
				elegirObjetivo("aliado", h.tipo == "revivir", h.alcance, function(id)
					enviar({ tipo = "habilidad", id = h.id, objetivo = id })
				end)
			else
				enviar({ tipo = "habilidad", id = h.id })
			end
		end, i, icono)
	end
	opcion("Volver", nil, true, function()
		mostrarPrincipal()
	end, 10, "volver")
end

local function mostrarObjetos()
	limpiarOpciones()
	menuTitulo.Text = Ui.t("Objetos")
	for i, o in peticion.objetos do
		opcion(string.format("%s ×%d", o.nombre, o.cantidad), Color3.fromRGB(40, 70, 60), o.cantidad > 0, function()
			elegirObjetivo("aliado", false, nil, function(id)
				enviar({ tipo = "objeto", id = o.id, objetivo = id })
			end)
		end, i, o.id)
	end
	opcion("Volver", nil, true, function()
		mostrarPrincipal()
	end, 10, "volver")
end

mostrarPrincipal = function()
	limpiarOpciones()
	seleccion = nil
	pintarMovimiento()
	menuTitulo.Text = Ui.t(next(puedoMover) and "Muévete (verde) o elige" or "¿Qué haces?")
	opcion("Atacar", Color3.fromRGB(190, 60, 60), true, function()
		elegirObjetivo("enemigo", false, peticion and peticion.alcance or 1, function(id)
			enviar({ tipo = "atacar", objetivo = id })
		end)
	end, 1, "espada")
	opcion("Habilidades", Color3.fromRGB(110, 80, 200), true, mostrarHabilidades, 2, "magia")
	opcion("Objetos", Color3.fromRGB(50, 150, 100), true, mostrarObjetos, 3, "pocion")
	opcion("Defender", Color3.fromRGB(60, 110, 190), true, function()
		enviar({ tipo = "defender" })
	end, 4, "escudo")
	opcion("Huir", Color3.fromRGB(100, 100, 120), true, function()
		enviar({ tipo = "huir" })
	end, 5, "huir")
end

remoto("PedirAccion").OnClientEvent:Connect(function(p: any)
	peticion = p
	miTurno = true
	puedoMover = {}
	for _, c in p.alcanzables or {} do
		puedoMover[clave(c[1], c[2])] = true
	end
	if next(casillas) == nil then
		cargarCasillas()
	end
	mostrarPrincipal()
	Ui.tween(menu, { Position = UDim2.new(1, -18, 1, -18) }, 0.45, Enum.EasingStyle.Back)
	reloj.Size = UDim2.new(1, -28, 0, 8)
	relojTween = Ui.tween(reloj, { Size = UDim2.new(0, 0, 0, 8) }, p.tiempo, Enum.EasingStyle.Linear)
	task.delay(p.tiempo, function()
		if miTurno and peticion == p then
			cerrarMenu()
		end
	end)
end)

-- pulsar una casilla del campo: moverse o elegir objetivo
local function casillaBajo(pos: Vector2): string?
	if not carpetaBatalla and estadoBatalla then
		carpetaBatalla = workspace:FindFirstChild("Batalla_" .. tostring(estadoBatalla.id))
		cargarCasillas()
	end
	if not carpetaBatalla then
		return nil
	end
	local rayo = camara:ScreenPointToRay(pos.X, pos.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { carpetaBatalla :: Instance }
	local r = workspace:Raycast(rayo.Origin, rayo.Direction * 300, params)
	if r and r.Instance.Name == "Casilla" then
		return clave(r.Instance:GetAttribute("Col") :: number, r.Instance:GetAttribute("Fila") :: number)
	end
	return nil
end

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado or not miTurno or not enBatalla then
		return
	end
	if entrada.UserInputType ~= Enum.UserInputType.MouseButton1 and entrada.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local k = casillaBajo(Vector2.new(entrada.Position.X, entrada.Position.Y))
	if not k then
		return
	end
	if seleccion and seleccion.validos[k] then
		local id = seleccion.validos[k]
		seleccion.alElegir(id)
	elseif not seleccion and puedoMover[k] then
		local c, f = string.match(k, "(%d+),(%d+)")
		Audio.sfx("pop", 0.6)
		enviar({ tipo = "mover", col = tonumber(c), fila = tonumber(f) })
	end
end)

-- tarjetas del equipo y tira de turnos
local function tarjeta(e: any)
	local t = tarjetas[e.id]
	if not t then
		local marco = Ui.panel({ Size = UDim2.new(1, 0, 0, 66), Parent = equipo })
		local cl = e.clase and Datos.Clases[e.clase]
		retrato(marco, e.vecino and "vecino" or "clase", e.vecino or e.clase or "guerrero", UDim2.fromOffset(10, 7), UDim2.fromOffset(52, 52), Color3.fromRGB(236, 222, 190), 2, aparienciaDe(jugadorDeEntidad(e.id)))
		local nombre = Ui.texto({ Position = UDim2.fromOffset(72, 6), Size = UDim2.new(1, -84, 0, 22), Text = e.nombre, TextXAlignment = Enum.TextXAlignment.Left, Parent = marco })
		local vida = Ui.barra(marco, UDim2.fromOffset(72, 34), UDim2.new(0.6, -76, 0, 20), C.vida, true)
		local mana = Ui.barra(marco, UDim2.new(0.6, 4, 0, 34), UDim2.new(0.4, -16, 0, 20), C.mana, true)
		t = { marco = marco, vida = vida, mana = mana, nombre = nombre }
		tarjetas[e.id] = t
		Ui.aparecer(marco)
	end
	t.vida.set(e.hp, e.maxHp)
	t.mana.set(e.mp, e.maxMp)
	t.nombre.Text = (e.esMio and "Tú · " or "") .. e.nombre .. (e.vivo and "" or " (caído)") .. (e.veneno and " · veneno" or "") .. (e.defensa and " · escudo" or "") .. (e.furia and " · furia" or "")
	Ui.tween(t.marco, { BackgroundTransparency = e.vivo and 0 or 0.5 }, 0.3)
end

local function ficha(e: any): Frame
	local f = fichasTira[e.id]
	if not f then
		local cl = e.clase and Datos.Clases[e.clase]
		f = Ui.crear("Frame", { Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1, Parent = tira })
		local fondo = e.lado == "aliado" and (cl and cl.color:Lerp(Color3.new(1, 1, 1), 0.45) or C.borde) or Color3.fromRGB(240, 170, 170)
		retrato(f, e.vecino and "vecino" or e.lado == "aliado" and "clase" or "enemigo", e.vecino or e.lado == "aliado" and (e.clase or "guerrero") or (e.enemigo or "babosa"), UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), fondo, nil, e.lado == "aliado" and aparienciaDe(jugadorDeEntidad(e.id)) or nil)
		Ui.crear("UIScale", { Parent = f })
		fichasTira[e.id] = f
	end
	return f
end

remoto("BatallaEstado").OnClientEvent:Connect(function(s: any)
	estadoBatalla = s
	if s.centro then
		Escena.enemigosCerca(s.centro)
	end
	for _, lista in { s.aliados, s.enemigos } do
		for _, e in lista do
			local m = Escena.muneco(e.id)
			if m then
				Munecos.caer(m, not e.vivo)
			end
		end
	end
	for _, e in s.aliados do
		posiciones[e.id] = e.pos
		tarjeta(e)
	end
	for _, e in s.enemigos do
		posiciones[e.id] = e.pos
	end
	if s.orden then
		local todos: { [string]: any } = {}
		for _, e in s.aliados do
			todos[e.id] = e
		end
		for _, e in s.enemigos do
			todos[e.id] = e
		end
		for id, f in fichasTira do
			if not table.find(s.orden, id) then
				f:Destroy()
				fichasTira[id] = nil
			end
		end
		for i, id in s.orden do
			local e = todos[id]
			if e then
				local f = ficha(e)
				f.LayoutOrder = i
				local r = f:FindFirstChildOfClass("CanvasGroup")
				if r then
					Ui.tween(r, { GroupTransparency = e.vivo and 0 or 0.65 }, 0.3)
				end
			end
		end
	end
end)

remoto("BatallaTurno").OnClientEvent:Connect(function(t: any)
	turnoTexto.Text = "Turno de " .. t.nombre
	for id, f in fichasTira do
		Ui.tween(f:FindFirstChildOfClass("UIScale") :: UIScale, { Scale = id == t.id and 1.25 or 1 }, 0.3, Enum.EasingStyle.Back)
	end
end)

-- números flotantes en el mundo (estilo cómic: contorno grueso y un poco ladeados)
local function numero(pos: Vector3, texto: string, color: Color3, grande: boolean?)
	local ancla = Ui.crear("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2), Position = pos + Vector3.new(math.random(-10, 10) / 10, 2.5, 1), Parent = workspace })
	local bb = Ui.crear("BillboardGui", { Size = UDim2.fromOffset(220, 80), AlwaysOnTop = true, LightInfluence = 0, Parent = ancla })
	local t = Ui.texto({ Size = UDim2.fromScale(1, 1), Text = texto, TextColor3 = color, Rotation = math.random(-10, 10), Parent = bb })
	local trazo = t:FindFirstChildOfClass("UIStroke")
	if trazo then
		trazo.Thickness = 4
	end
	local escala = Ui.crear("UIScale", { Scale = 0.3, Parent = t })
	Ui.tween(escala, { Scale = grande and 1.5 or 1.1 }, 0.35, Enum.EasingStyle.Back)
	Ui.tween(bb, { StudsOffset = Vector3.new(0, 3, 0) }, 1.1, Enum.EasingStyle.Quad)
	task.delay(0.75, function()
		Ui.tween(t, { TextTransparency = 1 }, 0.4)
		if trazo then
			Ui.tween(trazo, { Transparency = 1 }, 0.4)
		end
	end)
	task.delay(1.25, function()
		ancla:Destroy()
	end)
end

local function posDe(id: string): Vector3?
	return Escena.posicion(id) or posiciones[id]
end

local function alImpacto(g: any)
	local pos = posDe(g.id)
	local m = Escena.muneco(g.id)
	if g.tipo == "dano" then
		if m then
			Munecos.golpear(m)
		end
		Audio.sfx(g.choque and "boing" or (g.critico and "critico" or "golpe"), 0.8, 0.9 + math.random() * 0.2)
		sacudida = math.max(sacudida, g.critico and 1.4 or 0.5)
		if pos then
			numero(pos, tostring(g.cantidad), g.critico and Color3.fromRGB(255, 90, 70) or Color3.new(1, 1, 1), g.critico)
		end
	elseif pos then
		if g.tipo == "cura" then
			numero(pos, "+" .. g.cantidad, Color3.fromRGB(120, 255, 140))
			Audio.sfx("cura", 0.5)
		elseif g.tipo == "mana" then
			numero(pos, "+" .. g.cantidad .. " PM", Color3.fromRGB(120, 180, 255))
		elseif g.tipo == "veneno" then
			if m then
				Munecos.golpear(m)
			end
			numero(pos, tostring(g.cantidad), Color3.fromRGB(200, 120, 255))
		elseif g.tipo == "defensa" then
			numero(pos, "ESCUDO", Color3.fromRGB(150, 200, 255))
			Audio.sfx("escudo", 0.6)
		elseif g.tipo == "esquiva" then
			numero(pos, "¡FALLO!", Color3.fromRGB(200, 220, 255))
			Audio.sfx("hover", 0.8, 0.7)
		elseif g.tipo == "envenenado" then
			numero(pos, "VENENO", Color3.fromRGB(200, 120, 255))
			Audio.sfx("veneno", 0.6)
		elseif g.tipo == "furia" then
			numero(pos, "¡FURIA!", Color3.fromRGB(255, 170, 80))
		end
	end
end

local SFX_HABILIDAD: { [string]: string } = {
	golpeFuerte = "corte", torbellino = "corte", golpeRey = "golpe", mordisco = "golpe", picadura = "golpe",
	bolaFuego = "fuego", hechizoOscuro = "fuego", tormenta = "rayo", terremoto = "explosion", raices = "golpe",
	disparoCerte = "flecha", flechaVeneno = "flecha", lluviaFlechas = "flecha", lengua = "boing",
	curar = "cura", curaGrupal = "cura", revivir = "nivel", escudoArcano = "escudo", grito = "critico", esporas = "veneno",
}

remoto("BatallaEvento").OnClientEvent:Connect(function(ev: any)
	if ev.dice then
		Escena.decir(ev.dice.id, ev.dice.texto)
		Audio.hablar(#ev.dice.id * 97, #ev.dice.texto)
	end
	if ev.habilidad and SFX_HABILIDAD[ev.habilidad] then
		Audio.sfx(SFX_HABILIDAD[ev.habilidad], 0.8)
	end
	if ev.texto and ev.texto ~= "" then
		registro.Text = ev.texto
		registro.TextTransparency = 1
		Ui.tween(registro, { TextTransparency = 0 }, 0.2)
		task.delay(2.2, function()
			if registro.Text == ev.texto then
				Ui.tween(registro, { TextTransparency = 1 }, 0.4)
			end
		end)
	end
	-- el que actúa da un salto hacia delante y abre la boca
	local actor = ev.actor and Escena.muneco(ev.actor)
	if actor and #(ev.golpes or {}) > 0 and not (#ev.golpes == 1 and ev.golpes[1].id == ev.actor and ev.golpes[1].tipo == "veneno") then
		Munecos.atacar(actor, string.sub(ev.actor, 1, 1) == "j" and 1 or -1)
	end
	Efectos.accion(ev, posDe, alImpacto)
	-- rocas rotas: ¡CRAC!, trozos que saltan y la casilla vuelve a estar libre
	for _, k in ev.rocas or {} do
		local c = casillas[k]
		if c and c.p.Parent then
			local v, visible = camara:WorldToViewportPoint(c.p.Position + Vector3.new(0, 1.5, 0))
			if visible then
				local p = Vector2.new(v.X, v.Y)
				Efectos.onomatopeya(p, "¡CRAC!", Color3.fromRGB(230, 200, 140), true)
				Efectos.estallido(p, { Color3.fromRGB(150, 145, 155), Color3.fromRGB(190, 185, 195), Color3.fromRGB(110, 105, 115) }, 10, 90)
			end
		end
		Audio.sfx("golpe", 0.9, 0.7)
		sacudida = math.max(sacudida, 0.8)
		if estadoBatalla and estadoBatalla.casillas then
			estadoBatalla.casillas[k] = nil
		end
	end
end)

-- cámara de combate: tablero de juego de mesa, que se puede girar (Q/E o arrastrar con el botón derecho),
-- acercar (rueda) y cambiar de vista (botón «Cámara» o tecla C). Se mueve con suavizado exponencial.
local VISTAS = {
	{ nombre = "Lateral", alto = 18, lejos = 30 },
	{ nombre = "Desde arriba", alto = 32, lejos = 12 },
	{ nombre = "Cerca", alto = 10, lejos = 22 },
}
local vista = 1
local giro = 0 -- grados alrededor del centro del campo
local zoom = 1
local girando = false

pcall(function()
local botonCamara = Ui.boton({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 112), Size = UDim2.fromOffset(170, 44), Text = "Cámara", Icono = "estrella", BackgroundColor3 = Color3.fromRGB(90, 110, 140), ZIndex = 20, Parent = capaBatalla }, function()
	vista = vista % #VISTAS + 1
	giro = 0
	notificar("Cámara: " .. VISTAS[vista].nombre)
end)
end)
Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 160), Size = UDim2.fromOffset(240, 20), Text = "Q/E girar · rueda acercar · C vista", TextColor3 = C.suave, ZIndex = 20, Parent = capaBatalla })

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if not enBatalla then
		return
	end
	if entrada.UserInputType == Enum.UserInputType.MouseButton2 then
		girando = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	elseif not procesado and entrada.KeyCode == Enum.KeyCode.C then
		vista = vista % #VISTAS + 1
		giro = 0
		notificar("Cámara: " .. VISTAS[vista].nombre)
	end
end)
UserInputService.InputEnded:Connect(function(entrada)
	if entrada.UserInputType == Enum.UserInputType.MouseButton2 then
		girando = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)
UserInputService.InputChanged:Connect(function(entrada, procesado)
	if not enBatalla then
		return
	end
	if entrada.UserInputType == Enum.UserInputType.MouseWheel and not procesado then
		zoom = math.clamp(zoom - entrada.Position.Z * 0.08, 0.55, 1.5)
	elseif entrada.UserInputType == Enum.UserInputType.MouseMovement and girando then
		giro = math.clamp(giro + entrada.Delta.X * 0.3, -70, 70)
	end
end)

RunService:BindToRenderStep("CamaraVael", Enum.RenderPriority.Camera.Value + 2, function(dt)
	if not enBatalla then
		return
	end
	if not UserInputService:GetFocusedTextBox() then
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			giro = math.clamp(giro - 70 * dt, -70, 70)
		elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then
			giro = math.clamp(giro + 70 * dt, -70, 70)
		end
	end
	local t = os.clock()
	camara.CameraType = Enum.CameraType.Scriptable
	camara.FieldOfView = 44
	local v = VISTAS[vista]
	local respira = math.sin(t * 0.6) * 0.4
	local brazo = CFrame.Angles(0, math.rad(giro), 0) * Vector3.new(0, (v.alto + respira) * zoom, v.lejos * zoom)
	local deseada = CFrame.lookAt(centro + brazo, centro + Vector3.new(0, 1.2, -1.5))
	local k = 1 - math.exp(-dt * 5)
	local cf = camara.CFrame:Lerp(deseada, k)
	if sacudida > 0.01 then
		cf *= CFrame.new(math.noise(t * 25, 0) * sacudida, math.noise(0, t * 25) * sacudida, 0)
		sacudida *= math.exp(-dt * 7)
	end
	camara.CFrame = cf
end)

local function franjasCine(abrir: boolean)
	Ui.tween(barraArriba, { Size = UDim2.new(1, 0, 0, abrir and 36 or 0) }, 0.6)
	Ui.tween(barraAbajo, { Size = UDim2.new(1, 0, 0, abrir and 36 or 0) }, 0.6)
end

local function mostrarTitulo(texto: string, color: Color3)
	tituloBatalla.Text = Ui.t(texto)
	tituloBatalla.TextColor3 = color
	tituloBatalla.Visible = true
	tituloBatalla.TextTransparency = 0
	Ui.aparecer(tituloBatalla)
	task.delay(1.4, function()
		Ui.tween(tituloBatalla, { TextTransparency = 1 }, 0.4)
	end)
end

remoto("BatallaInicio").OnClientEvent:Connect(function(d: any)
	enBatalla = true
	Escena.enBatalla = true
	centro = d.centro
	carpetaBatalla = d.carpeta
	cargarCasillas()
	Escena.enemigosCerca(centro)
	Escena.ocultarPasto(centro)
	Audio.forzada = d.jefe and "jefe" or "combate"
	Audio.sfx("critico", 0.7)
	mochila.Visible = false
	camara.CameraType = Enum.CameraType.Scriptable
	capaBatalla.Visible = true
	Ui.tween(hud, { Position = UDim2.fromOffset(12, -200) }, 0.5)
	mision.Visible = false
	franjasCine(true)
	mostrarTitulo(d.emboscada and "¡EMBOSCADA!" or ("¡COMBATE!  ·  " .. d.zona), d.emboscada and C.peligro or C.borde)
	sacudida = 1
end)

remoto("BatallaFin").OnClientEvent:Connect(function(r: any)
	cerrarMenu()
	local texto, color
	if r.victoria then
		texto, color = "¡VICTORIA!", C.oro
	elseif r.huida then
		texto, color = "Habéis escapado", C.suave
	else
		texto, color = "Derrota…", C.peligro
	end
	mostrarTitulo(texto, color)
	Audio.sfx(r.victoria and "victoria" or (r.huida and "boing" or "derrota"), 0.9)
	if r.subio then
		task.delay(1.2, function()
			Audio.sfx("nivel", 0.9)
		end)
	end
	if r.victoria then
		local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 20), Size = UDim2.fromOffset(380, 150), Parent = gui, ZIndex = 40 })
		Ui.aparecer(p)
		local lineas = string.format("+%d EXP   ·   +%d oro", r.xp or 0, r.oro or 0)
		if r.botin then
			lineas ..= "\nBotín: " .. r.botin
		end
		if r.subio then
			lineas ..= "\n¡SUBES AL NIVEL " .. r.nivel .. "!"
		end
		if r.cofre then
			lineas ..= "\n¡Hay un cofre!"
		end
		Ui.texto({ Size = UDim2.new(1, -30, 1, -24), Position = UDim2.fromOffset(15, 12), Text = lineas, Parent = p, ZIndex = 41 })
		task.delay(3, function()
			Ui.tween(p:FindFirstChildOfClass("UIScale") :: UIScale, { Scale = 0 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
			p:Destroy()
		end)
	elseif r.oroPerdido and r.oroPerdido > 0 then
		notificar("Has perdido " .. r.oroPerdido .. " de oro")
	end
	task.delay(2, function()
		enBatalla = false
		Escena.enBatalla = false
		Escena.ocultarPasto(nil)
		Audio.forzada = nil
		carpetaBatalla = nil
		casillas = {}
		mochila.Visible = false
		local mio = Escena.muneco("j" .. jugador.UserId)
		if mio then
			Munecos.caer(mio, false)
		end
		franjasCine(false)
		Ui.tween(hud, { Position = UDim2.fromOffset(12, 58) }, 0.5, Enum.EasingStyle.Back)
		mision.Visible = hud.Visible
		for id, f in fichasTira do
			f:Destroy()
			fichasTira[id] = nil
		end
		for id, t in tarjetas do
			t.marco:Destroy()
			tarjetas[id] = nil
		end
		turnoTexto.Text = ""
		task.delay(0.6, function()
			if not enBatalla then
				capaBatalla.Visible = false
			end
		end)
	end)
end)

paso('VENTANAS COMUNES')
-- ===================== VENTANAS COMUNES =====================
local function cerrarPanel(p: GuiObject)
	local e = p:FindFirstChildOfClass("UIScale")
	if e then
		Ui.tween(e, { Scale = 0 }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
	end
	p:Destroy()
end

--- Carta de mejora: icono grande, nombre, rareza y descripción. Gira al aparecer.
local function cartaMejora(padre: Instance, id: string, retraso: number, pie: string?, alPulsar: (() -> ())?): Frame
	local m = Datos.Mejoras[id]
	local colorR = Datos.ColorRareza[m.rareza]
	local carta = Ui.crear("Frame", { Size = UDim2.fromOffset(200, 290), BackgroundColor3 = Color3.fromRGB(255, 248, 230), BorderSizePixel = 0, Parent = padre, ZIndex = 72 })
	Ui.esquinas(carta, 16)
	Ui.borde(carta, colorR, 5)
	local fondoIcono = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(96, 96), BackgroundColor3 = m.color, BorderSizePixel = 0, ZIndex = 73, Parent = carta })
	Ui.esquinas(fondoIcono, 48)
	Ui.borde(fondoIcono, C.tinta, 3)
	Ui.icono(m.icono, fondoIcono, UDim2.fromOffset(18, 18), UDim2.fromOffset(60, 60), 74)
	Ui.texto({ Position = UDim2.fromOffset(10, 118), Size = UDim2.new(1, -20, 0, 30), Text = m.nombre, TextColor3 = C.tinta, Contorno = false, ZIndex = 73, Parent = carta })
	local etiqueta = Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 150), Size = UDim2.fromOffset(120, 20), Text = ({ comun = "COMÚN", rara = "RARA", legendaria = "LEGENDARIA" })[m.rareza] or "COMÚN", TextColor3 = Color3.new(1, 1, 1), ZIndex = 74, Parent = carta })
	Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 148), Size = UDim2.fromOffset(110, 24), BackgroundColor3 = colorR, BorderSizePixel = 0, ZIndex = 73, Parent = carta }, { Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0) }) })
	etiqueta.ZIndex = 75
	Ui.texto({ Position = UDim2.fromOffset(12, 178), Size = UDim2.new(1, -24, 0, 66), Text = m.descripcion, TextWrapped = true, TextColor3 = Color3.fromRGB(70, 60, 80), Contorno = false, ZIndex = 73, Parent = carta })
	if pie and alPulsar then
		Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.new(1, -24, 0, 38), Text = pie, BackgroundColor3 = colorR:Lerp(Color3.new(0, 0, 0), 0.25), ZIndex = 74, Parent = carta }, alPulsar)
	end
	-- giro al aparecer (la carta "se da la vuelta")
	local escala = Ui.crear("UIScale", { Scale = 1, Parent = carta })
	carta.Size = UDim2.fromOffset(0, 290)
	task.delay(retraso, function()
		Audio.sfx("pop", 0.6, 1 + retraso)
		Ui.tween(carta, { Size = UDim2.fromOffset(200, 290) }, 0.35, Enum.EasingStyle.Back)
	end)
	carta.MouseEnter:Connect(function()
		Ui.tween(escala, { Scale = 1.05 }, 0.15)
		Ui.tween(carta, { Rotation = math.random() < 0.5 and -2 or 2 }, 0.15)
	end)
	carta.MouseLeave:Connect(function()
		Ui.tween(escala, { Scale = 1 }, 0.15)
		Ui.tween(carta, { Rotation = 0 }, 0.15)
	end)
	return carta
end

-- ===================== COFRES: ELIGE 1 DE 3 MEJORAS =====================
remoto("OfrecerMejoras").OnClientEvent:Connect(function(d: any)
	Audio.sfx("cofre", 0.9)
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 70, Parent = gui })
	Ui.tween(capa, { BackgroundTransparency = 0.4 }, 0.3)
	local titulo = Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, -250), Size = UDim2.fromOffset(700, 60), Text = d.origen == "jefe" and "¡El tesoro del Rey Hongo!" or "¡Un cofre! Elige una mejora", TextColor3 = C.oro, ZIndex = 71, Parent = capa })
	Ui.aparecer(titulo)
	Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, -192), Size = UDim2.fromOffset(700, 28), Text = "Se suman y algunas se combinan entre sí", TextColor3 = C.suave, ZIndex = 71, Parent = capa })
	local fila = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 20), Size = UDim2.fromOffset(660, 300), BackgroundTransparency = 1, ZIndex = 71, Parent = capa })
	Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 20), Parent = fila })
	local elegido = false
	for i, id in d.opciones do
		cartaMejora(fila, id, 0.2 + i * 0.18, "¡Esta!", function()
			if elegido then
				return
			end
			elegido = true
			Audio.sfx("mejora", 0.9)
			remoto("ElegirMejora"):FireServer(id)
			Ui.tween(capa, { BackgroundTransparency = 1 }, 0.3)
			for _, h in capa:GetDescendants() do
				if h:IsA("GuiObject") then
					Ui.tween(h, { BackgroundTransparency = 1 }, 0.25)
				end
				if h:IsA("TextLabel") or h:IsA("TextButton") then
					Ui.tween(h, { TextTransparency = 1 }, 0.25)
				end
			end
			task.delay(0.35, function()
				capa:Destroy()
			end)
		end)
	end
end)

-- ===================== VENDEDOR SOSPECHOSO Y HERRERÍA =====================
local panelVenta: Frame? = nil
remoto("AbrirVendedor").OnClientEvent:Connect(function(d: any)
	if panelVenta then
		panelVenta:Destroy()
	end
	Audio.sfx(d.origen == "vendedor" and "psst" or "pop", 0.8)
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(math.max(500, #d.lista * 220 + 40), 470), Parent = gui, ZIndex = 70 })
	panelVenta = p
	Ui.aparecer(p)
	retrato(p, d.origen == "vendedor" and "vendedor" or "vecino", d.origen == "vendedor" and "1" or "5150", UDim2.fromOffset(18, 14), UDim2.fromOffset(70, 70), Color3.fromRGB(255, 230, 190), 72)
	Ui.texto({ Position = UDim2.fromOffset(100, 14), Size = UDim2.new(1, -120, 0, 36), Text = d.titulo, TextColor3 = C.oro, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 72, Parent = p })
	Ui.texto({ Position = UDim2.fromOffset(100, 52), Size = UDim2.new(1, -120, 0, 26), Text = "«" .. d.frase .. "»", TextColor3 = C.suave, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 72, Parent = p })
	local fila = Ui.crear("Frame", { Position = UDim2.fromOffset(20, 96), Size = UDim2.new(1, -40, 0, 300), BackgroundTransparency = 1, ZIndex = 71, Parent = p })
	Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 16), Parent = fila })
	for i, o in d.lista do
		cartaMejora(fila, o.id, 0.1 + i * 0.12, o.vendido and "Agotado" or (o.precio .. " oro"), function()
			if not o.vendido then
				remoto("ComprarMejora"):FireServer(d.origen, o.id)
				if d.origen == "vendedor" then
					cerrarPanel(p)
				end
			end
		end)
	end
	Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.fromOffset(200, 44), Text = "Cerrar", Icono = "volver", BackgroundColor3 = C.fondo, ZIndex = 72, Parent = p }, function()
		cerrarPanel(p)
	end)
end)

-- ===================== DIÁLOGOS (con elección) =====================
local panelDialogo: Frame? = nil
-- Diálogo de cine: franja oscura abajo, retrato grande que asoma por arriba, nombre en una pestaña de cartulina,
-- texto grande que se escribe letra a letra (clic para terminarlo), indicador para continuar y las respuestas.
-- Mientras dura, el HUD, la misión, los botones y los avisos se esconden (atributo local "EnDialogo").
local function terminarDialogo(p: Frame)
	if panelDialogo == p then
		panelDialogo = nil
		jugador:SetAttribute("EnDialogo", false)
	end
	cerrarPanel(p)
end

remoto("Dialogo").OnClientEvent:Connect(function(d: any)
	if panelDialogo then
		panelDialogo:Destroy()
	end
	jugador:SetAttribute("EnDialogo", true)
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 150, Parent = gui })
	panelDialogo = capa
	-- franja de cine (oscurece la parte de abajo)
	Ui.crear("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 300), BackgroundColor3 = Color3.fromRGB(20, 15, 12), BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 150, Parent = capa }, {
		Ui.crear("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 0.4), NumberSequenceKeypoint.new(1, 0.2) }) }),
	})
	local caja = Ui.panel({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -22), Size = UDim2.new(1, -60, 0, 210), BackgroundColor3 = Color3.fromRGB(150, 118, 88), Parent = capa, ZIndex = 151 })
	Ui.crear("UISizeConstraint", { MaxSize = Vector2.new(1120, 210), Parent = caja })
	local escala = Ui.crear("UIScale", { Scale = 1, Parent = caja })
	caja.Position = UDim2.new(0.5, 0, 1, 240)
	Ui.tween(caja, { Position = UDim2.new(0.5, 0, 1, -22) }, 0.35, Enum.EasingStyle.Back)
	local _ = escala
	-- papel donde va el texto
	local papel = Ui.crear("TextButton", { Position = UDim2.fromOffset(180, 14), Size = UDim2.new(1, -196, 0, 120), BackgroundColor3 = Color3.fromRGB(240, 228, 200), BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 152, Parent = caja })
	Ui.esquinas(papel, 6)
	Ui.borde(papel, C.tinta, 2)
	-- retrato grande que asoma por arriba
	local quien = d.quien or { "vecino", "1" }
	retrato(caja, quien[1], quien[2], UDim2.fromOffset(16, -60), UDim2.fromOffset(150, 150), Color3.fromRGB(236, 222, 190), 153)
	-- nombre en una pestaña
	local pestana = Ui.crear("Frame", { Position = UDim2.fromOffset(190, -34), Size = UDim2.new(0, 0, 0, 40), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(200, 75, 65), BorderSizePixel = 0, Rotation = -2, ZIndex = 153, Parent = caja })
	Ui.esquinas(pestana, 6)
	Ui.borde(pestana, C.tinta, 2.5)
	Ui.crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = pestana })
	Ui.crear("TextLabel", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = d.titulo or "", Font = Ui.Fuente, TextSize = 24, TextColor3 = Color3.fromRGB(250, 240, 220), ZIndex = 154, Parent = pestana })
	local completo = Ui.t(d.texto or "")
	local texto = Ui.crear("TextLabel", { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 1, -20), BackgroundTransparency = 1, Text = "", Font = Ui.FuenteDialogo, TextSize = 30, LineHeight = 0.95, TextWrapped = true, TextColor3 = C.tinta, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 153, Parent = papel })
	-- indicador de «continuar»
	local indicador = Ui.crear("TextLabel", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -10, 1, -4), Size = UDim2.fromOffset(30, 26), BackgroundTransparency = 1, Text = "▼", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Color3.fromRGB(200, 75, 65), Visible = false, ZIndex = 154, Parent = papel })
	local opcionesD = Ui.crear("Frame", { Position = UDim2.fromOffset(180, 144), Size = UDim2.new(1, -196, 0, 52), BackgroundTransparency = 1, Visible = false, ZIndex = 152, Parent = caja })
	Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), Parent = opcionesD })
	local ancho = 1 / math.max(1, #d.opciones)
	for i, t in d.opciones do
		Ui.boton({ Size = UDim2.new(ancho, -10, 1, 0), Text = t, Font = Ui.FuenteDialogo, BackgroundColor3 = i == #d.opciones and C.fondo or Color3.fromRGB(110, 90, 150), ZIndex = 153, LayoutOrder = i, Parent = opcionesD }, function()
			remoto("ElegirOpcion"):FireServer(d.id, i)
			terminarDialogo(capa)
		end)
	end
	local escrito = false
	local function mostrarTodo()
		if escrito then
			return
		end
		escrito = true
		texto.Text = completo
		indicador.Visible = true
		opcionesD.Visible = true
		task.spawn(function()
			while indicador.Parent do
				Ui.tween(indicador, { Position = UDim2.new(1, -10, 1, -1) }, 0.4, Enum.EasingStyle.Sine)
				task.wait(0.4)
				Ui.tween(indicador, { Position = UDim2.new(1, -10, 1, -6) }, 0.4, Enum.EasingStyle.Sine)
				task.wait(0.4)
			end
		end)
	end
	papel.Activated:Connect(mostrarTodo)
	-- se escribe letra a letra, con pitiditos de voz
	task.spawn(function()
		Audio.hablar(tonumber(quien[2]) or 7, #completo)
		local n = utf8.len(completo) or #completo
		for i = 1, n do
			if escrito or not texto.Parent then
				return
			end
			local corte = utf8.offset(completo, i + 1)
			texto.Text = corte and string.sub(completo, 1, corte - 1) or completo
			task.wait(0.022)
		end
		mostrarTodo()
	end)
end)

-- ===================== JUEGO DE LOS VASOS (taberna) =====================
remoto("Vasos").OnClientEvent:Connect(function(d: any)
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, ZIndex = 80, Parent = gui })
	local mesa = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(620, 380), BackgroundColor3 = Color3.fromRGB(120, 80, 50), Parent = capa, ZIndex = 81 })
	Ui.aparecer(mesa)
	local titulo = Ui.texto({ Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 40), Text = "¡Sigue la bola!", TextColor3 = C.oro, ZIndex = 82, Parent = mesa })
	local X = { 150, 310, 470 }
	local Y = 220
	local bola = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(X[d.ganador], Y + 40), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = Color3.fromRGB(240, 70, 70), BorderSizePixel = 0, ZIndex = 82, Parent = mesa })
	Ui.esquinas(bola, 17)
	Ui.borde(bola, C.tinta, 3)
	local vasos: { Frame } = {}
	local enSitio: { number } = { 1, 2, 3 } -- qué vaso está en cada posición
	for i = 1, 3 do
		local v = Ui.crear("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(X[i], Y - 60), Size = UDim2.fromOffset(110, 130), BackgroundTransparency = 1, Text = "", ZIndex = 84, Parent = mesa })
		local cuerpo = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(230, 70, 70), BorderSizePixel = 0, ZIndex = 84, Parent = v })
		Ui.esquinas(cuerpo, 18)
		Ui.borde(cuerpo, C.tinta, 4)
		Ui.crear("Frame", { Position = UDim2.new(0, -8, 1, -18), Size = UDim2.new(1, 16, 0, 18), BackgroundColor3 = Color3.fromRGB(250, 240, 220), BorderSizePixel = 0, ZIndex = 85, Parent = v }, { Ui.crear("UICorner", { CornerRadius = UDim.new(0, 8) }), Ui.crear("UIStroke", { Thickness = 3, Color = C.tinta }) })
		Ui.crear("Frame", { Position = UDim2.new(0.2, 0, 0.15, 0), Size = UDim2.new(0.15, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 85, Parent = v }, { Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0) }) })
		vasos[i] = v :: any
	end
	task.spawn(function()
		-- enseña dónde está la bola y baja los vasos
		task.wait(1)
		for i = 1, 3 do
			Ui.tween(vasos[i], { Position = UDim2.fromOffset(X[i], Y + 10) }, 0.3, Enum.EasingStyle.Bounce)
		end
		task.wait(0.4)
		bola.Visible = false
		titulo.Text = Ui.t("Mira bien…")
		for _, c in d.cambios do
			local a, b = c[1], c[2]
			local va, vb = vasos[enSitio[a]], vasos[enSitio[b]]
			Audio.sfx("vasos", 0.5, 0.9 + math.random() * 0.3)
			Ui.tween(va, { Position = UDim2.fromOffset(X[b], Y + 10) }, d.velocidad, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			Ui.tween(vb, { Position = UDim2.fromOffset(X[a], Y + 10) }, d.velocidad, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			enSitio[a], enSitio[b] = enSitio[b], enSitio[a]
			task.wait(d.velocidad + 0.03)
		end
		titulo.Text = Ui.t("¿Dónde está la bola?")
		-- dónde ha acabado (para enseñarla después)
		local pos = d.ganador
		for _, c in d.cambios do
			if pos == c[1] then
				pos = c[2]
			elseif pos == c[2] then
				pos = c[1]
			end
		end
		local elegido = false
		for sitio = 1, 3 do
			local v = vasos[enSitio[sitio]] :: any
			v.Activated:Connect(function()
				if elegido then
					return
				end
				elegido = true
				remoto("ElegirVaso"):FireServer(sitio)
				bola.Position = UDim2.fromOffset(X[pos], Y + 40)
				bola.Visible = true
				Ui.tween(v, { Position = UDim2.fromOffset(X[sitio], Y - 70) }, 0.3, Enum.EasingStyle.Back)
				if sitio ~= pos then
					local bueno = vasos[enSitio[pos]]
					task.delay(0.4, function()
						Ui.tween(bueno, { Position = UDim2.fromOffset(X[pos], Y - 70) }, 0.3, Enum.EasingStyle.Back)
					end)
				end
				titulo.Text = Ui.t(sitio == pos and "¡Bien visto!" or "¡Ups!")
				Audio.sfx(sitio == pos and "moneda" or "boing", 0.8)
				task.delay(2, function()
					capa:Destroy()
				end)
			end)
		end
	end)
end)

-- ===================== FUNDIDO (taberna, posada) =====================
local fundido = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(10, 8, 16), BackgroundTransparency = 1, ZIndex = 200, Parent = gui })
local fundidoTexto = Ui.texto({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(400, 90), Text = "", TextColor3 = C.oro, TextTransparency = 1, ZIndex = 201, Parent = fundido })
remoto("Teletransporte").OnClientEvent:Connect(function(_: Vector3?, texto: string?)
	fundidoTexto.Text = texto or ""
	Ui.tween(fundido, { BackgroundTransparency = 0 }, 0.3)
	Ui.tween(fundidoTexto, { TextTransparency = texto and 0 or 1 }, 0.3)
	task.delay(texto and 1.3 or 0.6, function()
		Ui.tween(fundido, { BackgroundTransparency = 1 }, 0.45)
		Ui.tween(fundidoTexto, { TextTransparency = 1 }, 0.3)
	end)
end)

-- el menú de inicio y el de pausa están en Menu.client.luau (script aparte, para que salgan siempre)

-- al pulsar «Jugar» (o volver al inicio) se enseña u oculta el HUD
jugador:GetAttributeChangedSignal("EnMenu"):Connect(function()
	if estadoActual then
		actualizarHud(estadoActual)
	end
end)

paso("listo")
jugador:SetAttribute("CargadoPrincipal", true)

-- durante un diálogo no se ve nada del HUD (que no tape la conversación)
jugador:GetAttributeChangedSignal("EnDialogo"):Connect(function()
	local hablando = jugador:GetAttribute("EnDialogo") == true
	if hablando then
		hud.Visible = false
		mision.Visible = false
	elseif estadoActual and not enBatalla then
		actualizarHud(estadoActual)
	end
end)
