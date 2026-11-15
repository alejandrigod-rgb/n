--!strict
-- Crónicas de Vael · cliente: HUD, elegir clase, tienda, avisos y la interfaz del combate por turnos.
-- Fluidez: la interfaz se anima con TweenService y la cámara de combate se mueve en RenderStepped
-- (una vez por fotograma, a los 60 fps del cliente), con suavizado exponencial para que nunca dé tirones.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local jugador = Players.LocalPlayer
local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael:WaitForChild("Datos"))
local Remotos = Vael:WaitForChild("Remotos")
local Ui = require(script.Parent:WaitForChild("Ui"))
local Munecos = require(script.Parent:WaitForChild("Munecos"))
local Escena = require(script.Parent:WaitForChild("Escena"))
local Efectos = require(script.Parent:WaitForChild("Efectos"))
local C = Ui.Colores

local function remoto(nombre: string): RemoteEvent
	return Remotos:WaitForChild(nombre) :: RemoteEvent
end

local gui = Ui.crear("ScreenGui", { Name = "Vael", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = jugador:WaitForChild("PlayerGui") })

--- Retrato animado (el muñeco 2D vivo, recortado en un círculo). tipo: "clase" o "enemigo".
local function retrato(padre: Instance, tipo: string, id: string, pos: UDim2, tam: UDim2, fondo: Color3?, z: number?): CanvasGroup
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
	Munecos.crear(lienzo, tipo, id, 2)
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
remoto("Notificar").OnClientEvent:Connect(notificar)

-- ===================== HUD =====================
local hud = Ui.panel({ Position = UDim2.fromOffset(18, 18), Size = UDim2.fromOffset(410, 176), Parent = gui, Visible = false })
local hudRetrato: CanvasGroup? = nil
local hudClase: string? = nil
local hudNivel = Ui.texto({ Position = UDim2.fromOffset(18, 124), Size = UDim2.fromOffset(96, 30), Text = "", TextColor3 = C.oro, Parent = hud, ZIndex = 3 })
local hudNombre = Ui.texto({ Position = UDim2.fromOffset(128, 12), Size = UDim2.new(1, -144, 0, 30), Text = "", TextXAlignment = Enum.TextXAlignment.Left, Parent = hud })
Ui.icono("corazon", hud, UDim2.fromOffset(126, 48), UDim2.fromOffset(24, 24))
local hudVida = Ui.barra(hud, UDim2.fromOffset(156, 49), UDim2.new(1, -172, 0, 22), C.vida, true)
Ui.icono("gota", hud, UDim2.fromOffset(126, 78), UDim2.fromOffset(24, 24))
local hudMana = Ui.barra(hud, UDim2.fromOffset(156, 79), UDim2.new(1, -172, 0, 22), C.mana, true)
Ui.icono("estrella", hud, UDim2.fromOffset(126, 107), UDim2.fromOffset(22, 22))
local hudXp = Ui.barra(hud, UDim2.fromOffset(156, 110), UDim2.new(1, -172, 0, 14), C.xp, false)
Ui.icono("moneda", hud, UDim2.fromOffset(126, 136), UDim2.fromOffset(24, 24))
local hudInfo = Ui.texto({ Position = UDim2.fromOffset(156, 136), Size = UDim2.new(1, -172, 0, 24), Text = "", TextColor3 = C.oro, TextXAlignment = Enum.TextXAlignment.Left, Parent = hud })

local estadoActual: any = nil
local selector: Frame? = nil

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
	if not e.clase then
		hud.Visible = false
		abrirSelector()
		return
	end
	if not hud.Visible then
		Ui.aparecer(hud)
	end
	local cl = Datos.Clases[e.clase]
	if hudClase ~= e.clase then
		hudClase = e.clase
		if hudRetrato then
			hudRetrato:Destroy()
		end
		hudRetrato = retrato(hud, "clase", e.clase, UDim2.fromOffset(18, 16), UDim2.fromOffset(96, 96), cl.color:Lerp(Color3.new(1, 1, 1), 0.55), 2)
	end
	hudNivel.Text = "Nv. " .. e.nivel
	hudNombre.Text = jugador.DisplayName .. " · " .. cl.nombre
	hudNombre.TextColor3 = cl.color:Lerp(Color3.new(1, 1, 1), 0.35)
	hudVida.set(e.hp, e.maxHp)
	hudMana.set(e.mp, e.maxMp)
	hudXp.set(e.xp, e.xpSiguiente)
	hudInfo.Text = string.format("%d oro   ·   %d pociones   ·   %d éteres", e.oro, e.objetos.pocion or 0, e.objetos.eter or 0)
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

local function cerrarMenu()
	miTurno = false
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
		b.TextTransparency = 0.55
		b.BackgroundTransparency = 0.4
	end
	Ui.aparecer(b, orden * 0.03)
end

--- Lista de objetivos (enemigos vivos, aliados vivos o aliados caídos).
local function elegirObjetivo(lado: string, caidos: boolean, alElegir: (id: string) -> ())
	limpiarOpciones()
	menuTitulo.Text = "¿A quién?"
	local lista = estadoBatalla and (lado == "enemigo" and estadoBatalla.enemigos or estadoBatalla.aliados) or {}
	local n = 0
	for _, e in lista do
		if (caidos and not e.vivo) or (not caidos and e.vivo) then
			n += 1
			opcion(string.format("%s (%d)", e.nombre, e.hp), lado == "enemigo" and Color3.fromRGB(170, 60, 70) or Color3.fromRGB(60, 140, 90), true, function()
				alElegir(e.id)
			end, n)
		end
	end
	opcion("Volver", nil, true, function()
		mostrarPrincipal()
	end, n + 1, "volver")
end

local function mostrarHabilidades()
	limpiarOpciones()
	menuTitulo.Text = "Habilidades"
	for i, h in peticion.habilidades do
		local texto = h.bloqueada and string.format("%s (nivel %d)", h.nombre, h.nivelMinimo) or string.format("%s · %d PM", h.nombre, h.coste)
		local icono = (h.tipo == "cura" or h.tipo == "revivir") and "corazon" or h.tipo == "mejora" and "escudo" or "magia"
		opcion(texto, Color3.fromRGB(80, 60, 150), not h.bloqueada and not h.sinMana, function()
			if h.objetivo == "enemigo" then
				elegirObjetivo("enemigo", false, function(id)
					enviar({ tipo = "habilidad", id = h.id, objetivo = id })
				end)
			elseif h.objetivo == "aliado" then
				elegirObjetivo("aliado", h.tipo == "revivir", function(id)
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
	menuTitulo.Text = "Objetos"
	for i, o in peticion.objetos do
		opcion(string.format("%s ×%d", o.nombre, o.cantidad), Color3.fromRGB(40, 70, 60), o.cantidad > 0, function()
			elegirObjetivo("aliado", false, function(id)
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
	menuTitulo.Text = "¿Qué haces?"
	opcion("Atacar", Color3.fromRGB(190, 60, 60), true, function()
		elegirObjetivo("enemigo", false, function(id)
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

-- tarjetas del equipo y tira de turnos
local function tarjeta(e: any)
	local t = tarjetas[e.id]
	if not t then
		local marco = Ui.panel({ Size = UDim2.new(1, 0, 0, 66), Parent = equipo })
		local cl = e.clase and Datos.Clases[e.clase]
		retrato(marco, "clase", e.clase or "guerrero", UDim2.fromOffset(10, 7), UDim2.fromOffset(52, 52), cl and cl.color:Lerp(Color3.new(1, 1, 1), 0.5) or nil, 2)
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
		retrato(f, e.lado == "aliado" and "clase" or "enemigo", e.lado == "aliado" and (e.clase or "guerrero") or (e.enemigo or "babosa"), UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), fondo)
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
		sacudida = math.max(sacudida, g.critico and 1.4 or 0.5)
		if pos then
			numero(pos, tostring(g.cantidad), g.critico and Color3.fromRGB(255, 90, 70) or Color3.new(1, 1, 1), g.critico)
		end
	elseif pos then
		if g.tipo == "cura" then
			numero(pos, "+" .. g.cantidad, Color3.fromRGB(120, 255, 140))
		elseif g.tipo == "mana" then
			numero(pos, "+" .. g.cantidad .. " PM", Color3.fromRGB(120, 180, 255))
		elseif g.tipo == "veneno" then
			if m then
				Munecos.golpear(m)
			end
			numero(pos, tostring(g.cantidad), Color3.fromRGB(200, 120, 255))
		elseif g.tipo == "defensa" then
			numero(pos, "ESCUDO", Color3.fromRGB(150, 200, 255))
		elseif g.tipo == "furia" then
			numero(pos, "¡FURIA!", Color3.fromRGB(255, 170, 80))
		end
	end
end

remoto("BatallaEvento").OnClientEvent:Connect(function(ev: any)
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
end)

-- cámara de combate: de lado, como un escenario de teatro de papel; se acerca de forma exponencial
RunService:BindToRenderStep("CamaraVael", Enum.RenderPriority.Camera.Value + 2, function(dt)
	if not enBatalla then
		return
	end
	local t = os.clock()
	camara.CameraType = Enum.CameraType.Scriptable
	camara.FieldOfView = 40
	local respira = math.sin(t * 0.6) * 0.6
	local deseada = CFrame.lookAt(centro + Vector3.new(2, 9 + respira, 40), centro + Vector3.new(2, 4.2, 0))
	local k = 1 - math.exp(-dt * 4)
	local cf = camara.CFrame:Lerp(deseada, k)
	if sacudida > 0.01 then
		cf *= CFrame.new(math.noise(t * 25, 0) * sacudida, math.noise(0, t * 25) * sacudida, 0)
		sacudida *= math.exp(-dt * 7)
	end
	camara.CFrame = cf
end)

local function franjasCine(abrir: boolean)
	Ui.tween(barraArriba, { Size = UDim2.new(1, 0, 0, abrir and 80 or 0) }, 0.6)
	Ui.tween(barraAbajo, { Size = UDim2.new(1, 0, 0, abrir and 80 or 0) }, 0.6)
end

local function mostrarTitulo(texto: string, color: Color3)
	tituloBatalla.Text = texto
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
	Escena.enemigosCerca(centro)
	camara.CameraType = Enum.CameraType.Scriptable
	capaBatalla.Visible = true
	Ui.tween(hud, { Position = UDim2.fromOffset(18, -200) }, 0.5)
	franjasCine(true)
	mostrarTitulo("¡COMBATE!  ·  " .. d.zona, C.borde)
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
		local mio = Escena.muneco("j" .. jugador.UserId)
		if mio then
			Munecos.caer(mio, false)
		end
		franjasCine(false)
		Ui.tween(hud, { Position = UDim2.fromOffset(18, 18) }, 0.5, Enum.EasingStyle.Back)
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
