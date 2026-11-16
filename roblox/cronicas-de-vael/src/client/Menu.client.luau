--!strict
-- Crónicas de Vael · menús y ventanas (un único script para todo lo que se abre encima del juego):
--  · Pantalla de inicio: Continuar / Nueva partida, Mi personaje, Configuración, Cómo se juega y Créditos.
--  · Teclas: M = mapa · B = mochila · P = pausa (y botones pequeños arriba a la derecha).
--  · Menú de pausa: Continuar, Mochila, Mapa, Mi personaje, Configuración, Cómo se juega, Volver al inicio.
--  · Configuración: volumen de música y efectos, e idioma (español, inglés, portugués, francés y alemán).
--  · Solo hay una ventana abierta a la vez, y nada de esto sale durante un diálogo o un combate.
-- Avisa al resto con atributos locales del jugador: "EnMenu" (pantalla de inicio) y "VentanaAbierta".

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer
-- marca de por dónde va el script (la enseña Diagnostico abajo a la derecha si algo se queda parado)
local function paso(nombre: string)
	jugador:SetAttribute("PasoMenu", nombre)
end
paso("inicio")
local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael:WaitForChild("Datos")) :: any
paso("datos")
local Ui = require(script.Parent:WaitForChild("Ui"))
paso("ui")
local C = Ui.Colores

local gui = Ui.crear("ScreenGui", { Name = "VaelMenu", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 20, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = jugador:WaitForChild("PlayerGui") })
paso("gui")

-- módulos: se cargan DESPUÉS de enseñar la pantalla de inicio (si alguno fallara o tardara, el menú ya está)
local function cargar(nombre: string): any
	paso("cargando " .. nombre)
	local ok, m = pcall(function()
		local modulo = script.Parent:WaitForChild(nombre, 10)
		if not modulo then
			error("no encuentro el módulo " .. nombre)
		end
		return require(modulo :: ModuleScript)
	end)
	if not ok then
		warn("Menú: no se pudo cargar " .. nombre .. ": " .. tostring(m))
		return nil
	end
	return m
end
local Munecos: any = nil
local Escena: any = nil
local Audio: any = nil
local Editor: any = nil
local Mapa: any = nil
local Mochila: any = nil
local Idioma: any = nil
local Interaccion: any = nil

local function remoto(nombre: string): RemoteEvent
	return Vael:WaitForChild("Remotos"):WaitForChild(nombre) :: RemoteEvent
end

local controles: any = nil

local function sonido(nombre: string)
	if Audio then
		Audio.sfx(nombre, 0.7)
	end
end

local estado: any = nil
local enCombate = false
local ajustesAplicados = false

local function apariencia(): any
	local texto = jugador:GetAttribute("Apariencia") :: string?
	if texto then
		local ok, t = pcall(function()
			return HttpService:JSONDecode(texto)
		end)
		if ok then
			return t
		end
	end
	return Datos.aparienciaInicial()
end

local function cerrarPanel(p: GuiObject)
	local e = p:FindFirstChildOfClass("UIScale")
	if e then
		Ui.tween(e, { Scale = 0 }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
	end
	p:Destroy()
end

local function panelInfo(padre: Instance, titulo: string, cuerpo: string)
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(680, 460), Parent = padre, ZIndex = 140 })
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 40), Text = titulo, TextColor3 = C.oro, ZIndex = 141, Parent = p })
	Ui.texto({ Position = UDim2.fromOffset(30, 66), Size = UDim2.new(1, -60, 1, -140), Text = cuerpo, TextScaled = false, TextSize = 20, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 141, Parent = p })
	Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromOffset(200, 46), Text = "Vale", Icono = "volver", BackgroundColor3 = C.fondo, ZIndex = 141, Parent = p }, function()
		cerrarPanel(p)
	end)
end

local COMO_SE_JUEGA = "• Muévete con A y D (W y S: al fondo y hacia delante). Mantén Mayús para correr. Salta con Espacio.\n• E: hablar, abrir, entrar. M: mapa. B: mochila. P: pausa.\n• Explora: hay calles a los lados de la ciudad y caminos cerrados. Busca la cuerda, el hacha, la llave y el farol.\n• Combate: muévete por las casillas verdes y luego ataca. Empuja a los monstruos contra rocas. C cambia la cámara y Q/E la giran.\n• Gana cofres con mejoras: se suman y algunas se combinan."

-- ===================== CONFIGURACIÓN =====================
local function guardarAjustes()
	remoto("GuardarAjustes"):FireServer({
		idioma = Idioma and Idioma.actual() or "es",
		musica = Audio and Audio.volMusica or 0.5,
		efectos = Audio and Audio.volEfectos or 0.8,
	})
end

local function panelAjustes(padre: Instance)
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(560, 400), Parent = padre, ZIndex = 140 })
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 40), Text = "Configuración", TextColor3 = C.oro, ZIndex = 141, Parent = p })
	local function fila(y: number, nombre: string, leer: () -> number, poner: (number) -> ())
		local etiqueta = Ui.texto({ Position = UDim2.fromOffset(30, y), Size = UDim2.fromOffset(240, 40), Text = "", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 141, Parent = p })
		local function refrescar()
			etiqueta.Text = Ui.t(nombre) .. ": " .. math.floor(leer() * 100 + 0.5) .. " %"
		end
		refrescar()
		Ui.boton({ Position = UDim2.fromOffset(300, y), Size = UDim2.fromOffset(90, 40), Text = "-", BackgroundColor3 = C.fondo, ZIndex = 141, Parent = p }, function()
			poner(math.max(0, leer() - 0.1))
			refrescar()
		end)
		Ui.boton({ Position = UDim2.fromOffset(410, y), Size = UDim2.fromOffset(90, 40), Text = "+", BackgroundColor3 = C.fondo, ZIndex = 141, Parent = p }, function()
			poner(math.min(1, leer() + 0.1))
			refrescar()
		end)
	end
	if Audio then
		fila(76, "Música", function()
			return Audio.volMusica
		end, function(v)
			Audio.volumen(v, nil)
		end)
		fila(126, "Efectos", function()
			return Audio.volEfectos
		end, function(v)
			Audio.volumen(nil, v)
		end)
	end
	if Idioma then
		Ui.texto({ Position = UDim2.fromOffset(30, 184), Size = UDim2.fromOffset(240, 34), Text = "Idioma", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 141, Parent = p })
		local fila2 = Ui.crear("Frame", { Position = UDim2.fromOffset(30, 222), Size = UDim2.new(1, -60, 0, 90), BackgroundTransparency = 1, ZIndex = 141, Parent = p })
		Ui.crear("UIGridLayout", { CellSize = UDim2.fromOffset(150, 40), CellPadding = UDim2.fromOffset(10, 8), Parent = fila2 })
		for _, d in Idioma.DISPONIBLES do
			local elegido = Idioma.actual() == d.codigo
			Ui.boton({ Text = d.nombre, BackgroundColor3 = elegido and Color3.fromRGB(100, 160, 90) or C.fondo, ZIndex = 142, Parent = fila2 }, function()
				Idioma.poner(d.codigo)
				guardarAjustes()
				cerrarPanel(p)
			end)
		end
	end
	Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromOffset(200, 46), Text = "Listo", Icono = "volver", BackgroundColor3 = C.fondo, ZIndex = 141, Parent = p }, function()
		guardarAjustes()
		cerrarPanel(p)
	end)
end

local function abrirEditor()
	local clase = jugador:GetAttribute("Clase") :: string?
	if not Editor or not clase then
		return
	end
	Editor.abrir(gui, clase, apariencia(), function(ap)
		remoto("GuardarApariencia"):FireServer(ap)
	end, false)
end

-- ===================== VENTANAS (solo una a la vez) =====================
local pausa: Frame? = nil
local inicio: Frame? = nil

local function cerrarPausa()
	if pausa then
		local p = pausa
		pausa = nil
		cerrarPanel(p)
	end
end

local function cerrarTodo()
	cerrarPausa()
	if Mapa then
		Mapa.cerrar()
	end
	if Mochila then
		Mochila.cerrar()
	end
end

local function sePuedeAbrir(): boolean
	return not inicio and not enCombate and jugador:GetAttribute("EnDialogo") ~= true
end

local function alternarMapa()
	if not Mapa then
		return
	end
	local abierto = Mapa.estaAbierto()
	cerrarTodo()
	if not abierto and sePuedeAbrir() then
		sonido("pop")
		Mapa.alternar(gui, estado)
	end
end

local function alternarMochila()
	if not Mochila then
		return
	end
	local abierta = Mochila.estaAbierta()
	cerrarTodo()
	if not abierta and sePuedeAbrir() then
		sonido("pop")
		Mochila.alternar(gui, estado, apariencia(), function(id)
			remoto("UsarObjeto"):FireServer(id)
		end)
	end
end

local abrirInicio: () -> ()

local function abrirPausa()
	if pausa then
		cerrarPausa()
		return
	end
	cerrarTodo()
	if not sePuedeAbrir() then
		return
	end
	sonido("pop")
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(40, 32, 28), BackgroundTransparency = 0.45, ZIndex = 100, Parent = gui })
	pausa = capa
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(380, 520), Parent = capa, ZIndex = 101 })
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 44), Text = "Pausa", TextColor3 = C.oro, ZIndex = 102, Parent = p })
	local caja = Ui.crear("Frame", { Position = UDim2.fromOffset(30, 78), Size = UDim2.new(1, -60, 1, -96), BackgroundTransparency = 1, ZIndex = 102, Parent = p })
	Ui.crear("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = caja })
	local opciones = {
		{ "Continuar", Color3.fromRGB(100, 160, 90), "estrella", cerrarPausa },
		{ "Mochila (B)", Color3.fromRGB(160, 110, 70), "pocion", alternarMochila },
		{ "Mapa (M)", Color3.fromRGB(110, 140, 90), "estrella", alternarMapa },
		{ "Mi personaje", Color3.fromRGB(190, 120, 80), "corazon", function()
			cerrarPausa()
			abrirEditor()
		end },
		{ "Configuración", Color3.fromRGB(80, 120, 170), "escudo", function()
			panelAjustes(capa)
		end },
		{ "Cómo se juega", Color3.fromRGB(120, 95, 160), "magia", function()
			panelInfo(capa, "Cómo se juega", COMO_SE_JUEGA)
		end },
		{ "Volver al inicio", Color3.fromRGB(120, 110, 100), "volver", function()
			cerrarPausa()
			abrirInicio()
		end },
	}
	for i, o in opciones do
		Ui.boton({ Size = UDim2.new(1, 0, 0, 48), Text = o[1], BackgroundColor3 = o[2], Icono = o[3], ZIndex = 103, LayoutOrder = i, Parent = caja }, o[4])
	end
end

-- botones pequeños arriba a la derecha (no tapan nada)
local barra = Ui.crear("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10), Size = UDim2.fromOffset(170, 50), BackgroundTransparency = 1, Visible = false, ZIndex = 40, Parent = gui })
Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 6), Parent = barra })
local function botonPequeno(icono: string, tecla: string, alPulsar: () -> ())
	local b = Ui.crear("TextButton", { Size = UDim2.fromOffset(50, 50), Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(150, 118, 88), BorderSizePixel = 0, ZIndex = 41, Parent = barra })
	Ui.esquinas(b, 10)
	Ui.borde(b, C.tinta, 2.5)
	Ui.icono(icono, b, UDim2.fromOffset(9, 6), UDim2.fromOffset(32, 32), 42)
	Ui.crear("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 2), Size = UDim2.fromOffset(40, 16), BackgroundTransparency = 1, Text = tecla, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.texto, TextStrokeTransparency = 0.3, ZIndex = 43, Parent = b })
	b.Activated:Connect(alPulsar)
end

local function refrescarBarra()
	barra.Visible = not inicio and not enCombate and jugador:GetAttribute("EnDialogo") ~= true
end
jugador:GetAttributeChangedSignal("EnDialogo"):Connect(function()
	if jugador:GetAttribute("EnDialogo") == true then
		cerrarTodo()
	end
	if Interaccion then
		Interaccion.visibles(jugador:GetAttribute("EnDialogo") ~= true)
	end
	refrescarBarra()
end)

-- ===================== PANTALLA DE INICIO =====================
local fundido = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(30, 24, 20), BackgroundTransparency = 1, ZIndex = 300, Parent = gui })

abrirInicio = function()
	cerrarTodo()
	jugador:SetAttribute("EnMenu", true)
	if Escena then
		Escena.modoMenu = true
	end
	if controles then
		controles:Disable()
	end
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 100, Parent = gui })
	inicio = capa
	refrescarBarra()
	Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(60, 48, 40), BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 100, Parent = capa })
	local cartel = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 30), Size = UDim2.fromOffset(760, 150), BackgroundColor3 = Color3.fromRGB(205, 175, 130), Parent = capa, ZIndex = 101 })
	cartel.Rotation = -2
	Ui.texto({ Position = UDim2.fromOffset(20, 14), Size = UDim2.new(1, -40, 0, 90), Text = "Crónicas de Vael", TextColor3 = Color3.fromRGB(250, 236, 200), ZIndex = 102, Parent = cartel })
	Ui.texto({ Position = UDim2.fromOffset(20, 104), Size = UDim2.new(1, -40, 0, 32), Text = "Un RPG de cartulina, por turnos y con amigos", TextColor3 = C.texto, ZIndex = 102, Parent = cartel })
	Ui.aparecer(cartel)
	task.spawn(function()
		local lado = 1
		while cartel.Parent do
			Ui.tween(cartel, { Rotation = -2 + lado * 1.2 }, 1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			lado = -lado
			task.wait(1.8)
		end
	end)
	task.spawn(function()
		local espera = 0
		while not Munecos and espera < 15 do
			task.wait(0.2)
			espera += 0.2
		end
		if not Munecos or not capa.Parent then
			return
		end
		local desfile = Ui.crear("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 150), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 101, Parent = capa })
		local actores = {}
		for i, cid in Datos.OrdenClases do
			local f = Ui.crear("Frame", { Size = UDim2.fromOffset(100, 130), BackgroundTransparency = 1, ZIndex = 102, Parent = desfile })
			local m = Munecos.crear(f, "clase", cid, 3, i == 1 and apariencia() or { piel = math.random(1, 5), pelo = math.random(1, 7), colorPelo = math.random(1, 8), accesorio = math.random(1, 8) })
			m.andar = 1
			m.mirar = 1
			table.insert(actores, { f = f, dx = -i * 110 })
		end
		local monstruos = { "lobo", "babosa", "abeja", "reyHongo", "fantasma", "golem", "mimico" }
		local fm = Ui.crear("Frame", { Size = UDim2.fromOffset(130, 130), BackgroundTransparency = 1, ZIndex = 102, Parent = desfile })
		local mm = Munecos.crear(fm, "enemigo", monstruos[math.random(1, #monstruos)], 3)
		mm.andar = 1
		Munecos.espejo(mm, true)
		task.spawn(function()
			local t0 = os.clock()
			while desfile.Parent do
				local ancho = desfile.AbsoluteSize.X
				local x = ((os.clock() - t0) * 150) % (ancho + 900) - 160
				for _, a in actores do
					a.f.Position = UDim2.new(0, x + a.dx + 600, 1, -135)
				end
				fm.Position = UDim2.new(0, x - 140, 1, -135)
				task.wait()
			end
		end)
	end)
	local caja = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 205), Size = UDim2.fromOffset(320, 330), BackgroundTransparency = 1, ZIndex = 101, Parent = capa })
	Ui.crear("UIListLayout", { Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = caja })
	local function jugar()
		sonido("mejora")
		Ui.tween(fundido, { BackgroundTransparency = 0 }, 0.35).Completed:Wait()
		capa:Destroy()
		inicio = nil
		if Escena then
			Escena.modoMenu = false
		end
		if controles then
			controles:Enable()
		end
		jugador:SetAttribute("EnMenu", false)
		refrescarBarra()
		Ui.tween(fundido, { BackgroundTransparency = 1 }, 0.6)
	end
	local tienePartida = jugador:GetAttribute("Clase") ~= nil
	local botones = {
		{ tienePartida and "Continuar" or "Nueva partida", Color3.fromRGB(100, 160, 90), "estrella", jugar },
		{ "Mi personaje", Color3.fromRGB(190, 120, 80), "corazon", function()
			if jugador:GetAttribute("Clase") then
				abrirEditor()
			else
				panelInfo(capa, "Mi personaje", "Primero empieza la partida y elige tu clase. Después podrás crear a tu héroe (y cambiarlo cuando quieras desde la pausa).")
			end
		end },
		{ "Configuración", Color3.fromRGB(80, 120, 170), "escudo", function()
			panelAjustes(capa)
		end },
		{ "Cómo se juega", Color3.fromRGB(120, 95, 160), "magia", function()
			panelInfo(capa, "Cómo se juega", COMO_SE_JUEGA)
		end },
		{ "Créditos", Color3.fromRGB(120, 110, 100), "moneda", function()
			panelInfo(capa, "Créditos", "Crónicas de Vael\n\nIdea y dirección: tú.\nCódigo, dibujos, música y efectos: hechos a medida para este juego.\n\nGracias por jugar. Y por no comerte las setas del suelo… o sí.")
		end },
	}
	for i, b in botones do
		local boton = Ui.boton({ Size = UDim2.fromOffset(320, 54), Text = b[1], BackgroundColor3 = b[2], Icono = b[3], ZIndex = 102, LayoutOrder = i, Parent = caja }, b[4])
		boton.Visible = false
		Ui.aparecer(boton, 0.2 + i * 0.08)
	end
end

-- ===================== TECLAS =====================
UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado or UserInputService:GetFocusedTextBox() then
		return
	end
	local k = entrada.KeyCode
	if k == Enum.KeyCode.M then
		alternarMapa()
	elseif k == Enum.KeyCode.B then
		alternarMochila()
	elseif k == Enum.KeyCode.P then
		abrirPausa()
	end
end)

-- ===================== ESTADO, COMBATE Y EDITOR =====================
task.spawn(function()
	remoto("EstadoJugador").OnClientEvent:Connect(function(e: any)
		estado = e
		if not ajustesAplicados and e.ajustes then
			ajustesAplicados = true
			if Idioma and e.ajustes.idioma then
				Idioma.poner(e.ajustes.idioma)
			end
			if Audio then
				Audio.volumen(e.ajustes.musica, e.ajustes.efectos)
			end
		end
		-- si la mochila está abierta, se actualiza (por ejemplo, después de usar una poción)
		if Mochila and Mochila.estaAbierta() then
			Mochila.cerrar()
			Mochila.alternar(gui, estado, apariencia(), function(id)
				remoto("UsarObjeto"):FireServer(id)
			end)
		end
	end)
	remoto("BatallaInicio").OnClientEvent:Connect(function()
		enCombate = true
		cerrarTodo()
		refrescarBarra()
	end)
	remoto("BatallaFin").OnClientEvent:Connect(function()
		task.delay(2.2, function()
			enCombate = false
			refrescarBarra()
		end)
	end)
	remoto("AbrirEditor").OnClientEvent:Connect(abrirEditor)
end)

-- crear al héroe: en cuanto tenga clase y no lo haya creado aún (también si ya tenía clase de antes)
local yaPedido = false
local function quizaCrear()
	if yaPedido or not Editor or jugador:GetAttribute("EnMenu") == true then
		return
	end
	local clase = jugador:GetAttribute("Clase") :: string?
	if clase and jugador:GetAttribute("Creado") ~= true then
		yaPedido = true
		Editor.abrir(gui, clase, apariencia(), function(ap)
			remoto("GuardarApariencia"):FireServer(ap)
		end, true)
	end
end
for _, atributo in { "Clase", "Creado", "EnMenu" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(function()
		task.delay(0.6, quizaCrear)
	end)
end

-- 1) la pantalla de inicio, lo primero de todo
paso("abrir inicio")
local ok, err = pcall(abrirInicio)
if not ok then
	warn("Menú de inicio: " .. tostring(err))
	jugador:SetAttribute("EnMenu", false)
	inicio = nil
end
paso("inicio visible")

-- 2) el resto de módulos, sin bloquear el menú
task.spawn(function()
	Munecos = cargar("Munecos")
	Idioma = cargar("Idioma")
	Audio = cargar("Audio")
	Escena = cargar("Escena")
	if Escena then
		Escena.modoMenu = inicio ~= nil
	end
	Editor = cargar("Editor")
	Mapa = cargar("Mapa")
	Mochila = cargar("Mochila")
	Interaccion = cargar("Interaccion")
	if Interaccion then
		pcall(Interaccion.iniciar)
	end
	paso("controles")
	pcall(function()
		local ps = jugador:WaitForChild("PlayerScripts", 10)
		local pm = ps and ps:WaitForChild("PlayerModule", 10)
		if pm then
			controles = (require(pm :: ModuleScript) :: any):GetControls()
			if inicio and controles then
				controles:Disable()
			end
		end
	end)
	paso("botones")
	pcall(function()
		botonPequeno("estrella", "M", alternarMapa)
		botonPequeno("pocion", "B", alternarMochila)
		botonPequeno("escudo", "P", abrirPausa)
	end)
	refrescarBarra()
	quizaCrear()
	paso("listo")
	jugador:SetAttribute("CargadoMenu", true)
end)
