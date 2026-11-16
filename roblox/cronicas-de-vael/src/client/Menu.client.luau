--!strict
-- Crónicas de Vael · menús: la pantalla de inicio (Jugar, Personaje, Cómo se juega, Ajustes, Créditos) y el
-- menú de pausa durante la partida (botón «Menú» arriba a la derecha o tecla M).
-- Va en su propio script para que salga siempre, aunque otra parte de la interfaz falle.
-- Avisa al resto con el atributo local del jugador "EnMenu" (true mientras está en la pantalla de inicio).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer

local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael:WaitForChild("Datos")) :: any
local Ui = require(script.Parent:WaitForChild("Ui"))
local C = Ui.Colores

local gui = Ui.crear("ScreenGui", { Name = "VaelMenu", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 20, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = jugador:WaitForChild("PlayerGui") })

-- módulos que podrían fallar: si alguno falla, el menú sigue funcionando sin él
local function cargar(nombre: string): any
	local ok, m = pcall(function()
		return require(script.Parent:WaitForChild(nombre))
	end)
	if not ok then
		warn("Menú: no se pudo cargar " .. nombre .. ": " .. tostring(m))
		return nil
	end
	return m
end
local Munecos = cargar("Munecos")
local Escena = cargar("Escena")
local Audio = cargar("Audio")
local Editor = cargar("Editor")

local controles: any = nil
pcall(function()
	local modulo = require(jugador:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule") :: ModuleScript) :: any
	controles = modulo:GetControls()
end)

local function sonido(nombre: string)
	if Audio then
		Audio.sfx(nombre, 0.7)
	end
end

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
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(680, 440), Parent = padre, ZIndex = 120 })
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 40), Text = titulo, TextColor3 = C.oro, ZIndex = 121, Parent = p })
	Ui.texto({ Position = UDim2.fromOffset(30, 66), Size = UDim2.new(1, -60, 1, -140), Text = cuerpo, TextScaled = false, TextSize = 21, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 121, Parent = p })
	Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromOffset(200, 46), Text = "Vale", Icono = "volver", BackgroundColor3 = C.fondo, ZIndex = 121, Parent = p }, function()
		cerrarPanel(p)
	end)
end

local COMO_SE_JUEGA = "• Muévete con A y D (W y S: al fondo y hacia delante). Salta con Espacio. Habla y usa cosas con E.\n"
	.. "• Explora: hay caminos cerrados. Busca la cuerda, el hacha, la llave y el farol.\n"
	.. "• Entra en las guaridas del fondo para luchar. En tu turno, muévete por las casillas verdes y luego ataca. Empuja a los monstruos contra rocas: ¡CATAPLÁN!\n"
	.. "• Gana cofres con mejoras: se suman y algunas se combinan.\n"
	.. "• Atento a los paraderos: hogueras, pozos, cofres… y un vendedor muy raro.\n"
	.. "• Menú de pausa: botón «Menú» o tecla M."

local function panelAjustes(padre: Instance)
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(480, 300), Parent = padre, ZIndex = 120 })
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 40), Text = "Ajustes", TextColor3 = C.oro, ZIndex = 121, Parent = p })
	local function fila(y: number, nombre: string, leer: () -> number, poner: (number) -> ())
		local etiqueta = Ui.texto({ Position = UDim2.fromOffset(30, y), Size = UDim2.fromOffset(190, 40), Text = "", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 121, Parent = p })
		local function refrescar()
			etiqueta.Text = nombre .. ": " .. math.floor(leer() * 100 + 0.5) .. " %"
		end
		refrescar()
		Ui.boton({ Position = UDim2.fromOffset(240, y), Size = UDim2.fromOffset(80, 40), Text = "-", BackgroundColor3 = C.fondo, ZIndex = 121, Parent = p }, function()
			poner(math.max(0, leer() - 0.1))
			refrescar()
		end)
		Ui.boton({ Position = UDim2.fromOffset(340, y), Size = UDim2.fromOffset(80, 40), Text = "+", BackgroundColor3 = C.fondo, ZIndex = 121, Parent = p }, function()
			poner(math.min(1, leer() + 0.1))
			refrescar()
		end)
	end
	if Audio then
		fila(80, "Música", function()
			return Audio.volMusica
		end, function(v)
			Audio.volumen(v, nil)
		end)
		fila(140, "Efectos", function()
			return Audio.volEfectos
		end, function(v)
			Audio.volumen(nil, v)
		end)
	end
	Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromOffset(200, 46), Text = "Listo", Icono = "volver", BackgroundColor3 = C.fondo, ZIndex = 121, Parent = p }, function()
		cerrarPanel(p)
	end)
end

local function abrirEditor()
	local clase = jugador:GetAttribute("Clase") :: string?
	if not Editor or not clase then
		return
	end
	Editor.abrir(gui, clase, apariencia(), function(ap)
		Vael:WaitForChild("Remotos"):WaitForChild("GuardarApariencia"):FireServer(ap)
	end, false)
end

-- ===================== PANTALLA DE INICIO =====================
local fundido = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(30, 24, 20), BackgroundTransparency = 1, ZIndex = 300, Parent = gui })
local inicio: Frame? = nil
local botonMenu: TextButton

local function abrirInicio()
	jugador:SetAttribute("EnMenu", true)
	if Escena then
		Escena.modoMenu = true
	end
	if controles then
		controles:Disable()
	end
	if botonMenu then
		botonMenu.Visible = false
	end
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 100, Parent = gui })
	inicio = capa
	Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(60, 48, 40), BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 100, Parent = capa })
	-- cartel del título, como una cartulina clavada
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
	-- desfile de muñecos por abajo
	if Munecos then
		local desfile = Ui.crear("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 150), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 101, Parent = capa })
		local actores = {}
		for i, cid in Datos.OrdenClases do
			local f = Ui.crear("Frame", { Size = UDim2.fromOffset(100, 130), BackgroundTransparency = 1, ZIndex = 102, Parent = desfile })
			local m = Munecos.crear(f, "clase", cid, 3, i == 1 and apariencia() or { piel = math.random(1, 5), pelo = math.random(1, 7), colorPelo = math.random(1, 8), accesorio = math.random(1, 8) })
			m.andar = 1
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
	end
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
		botonMenu.Visible = true
		jugador:SetAttribute("EnMenu", false)
		Ui.tween(fundido, { BackgroundTransparency = 1 }, 0.6)
	end
	local botones = {
		{ "¡Jugar!", Color3.fromRGB(100, 160, 90), "estrella", jugar },
		{ "Mi personaje", Color3.fromRGB(190, 120, 80), "corazon", function()
			if jugador:GetAttribute("Clase") then
				abrirEditor()
			else
				panelInfo(capa, "Mi personaje", "Primero pulsa ¡Jugar! y elige tu clase. Después podrás crear a tu héroe (y cambiarlo cuando quieras desde el menú).")
			end
		end },
		{ "Cómo se juega", Color3.fromRGB(120, 95, 160), "magia", function()
			panelInfo(capa, "Cómo se juega", COMO_SE_JUEGA)
		end },
		{ "Ajustes", Color3.fromRGB(80, 120, 170), "escudo", function()
			panelAjustes(capa)
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

-- ===================== MENÚ DE PAUSA =====================
botonMenu = Ui.boton({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 60), Size = UDim2.fromOffset(130, 46), Text = "Menú", Icono = "escudo", BackgroundColor3 = C.fondo, ZIndex = 50, Visible = false, Parent = gui }, function() end)
local pausa: Frame? = nil

local function cerrarPausa()
	if pausa then
		local p = pausa
		pausa = nil
		cerrarPanel(p)
	end
end

local function abrirPausa()
	if inicio or pausa then
		return
	end
	sonido("pop")
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(40, 32, 28), BackgroundTransparency = 0.45, ZIndex = 100, Parent = gui })
	pausa = capa
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(380, 440), Parent = capa, ZIndex = 101 })
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 44), Text = "Pausa", TextColor3 = C.oro, ZIndex = 102, Parent = p })
	local caja = Ui.crear("Frame", { Position = UDim2.fromOffset(30, 80), Size = UDim2.new(1, -60, 1, -100), BackgroundTransparency = 1, ZIndex = 102, Parent = p })
	Ui.crear("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = caja })
	local opciones = {
		{ "Continuar", Color3.fromRGB(100, 160, 90), "estrella", cerrarPausa },
		{ "Mi personaje", Color3.fromRGB(190, 120, 80), "corazon", function()
			cerrarPausa()
			abrirEditor()
		end },
		{ "Ajustes", Color3.fromRGB(80, 120, 170), "escudo", function()
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
		Ui.boton({ Size = UDim2.new(1, 0, 0, 52), Text = o[1], BackgroundColor3 = o[2], Icono = o[3], ZIndex = 103, LayoutOrder = i, Parent = caja }, o[4])
	end
end

botonMenu.Activated:Connect(function()
	if pausa then
		cerrarPausa()
	else
		abrirPausa()
	end
end)
UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado then
		return
	end
	if entrada.KeyCode == Enum.KeyCode.M then
		if pausa then
			cerrarPausa()
		else
			abrirPausa()
		end
	end
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
			Vael:WaitForChild("Remotos"):WaitForChild("GuardarApariencia"):FireServer(ap)
		end, true)
	end
end
for _, atributo in { "Clase", "Creado", "EnMenu" } do
	jugador:GetAttributeChangedSignal(atributo):Connect(function()
		task.delay(0.6, quizaCrear)
	end)
end

local ok, err = pcall(abrirInicio)
if not ok then
	warn("Menú de inicio: " .. tostring(err))
	jugador:SetAttribute("EnMenu", false)
	if Escena then
		Escena.modoMenu = false
	end
	if controles then
		controles:Enable()
	end
	botonMenu.Visible = true
end
