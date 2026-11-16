--!strict
-- Mapa y objetivos de Crónicas de Vael.
--  · Arriba: una tira de mapa con las zonas, dónde estás (tu cara), los caminos cerrados (candado) y el objetivo (estrella).
--  · Debajo: el objetivo actual («Qué hacer ahora») con una flecha hacia donde hay que ir.
--  · Tecla Tab o botón «Mapa»: el mapa grande con todos los sitios.
-- Va en su propio script para que funcione aunque otra parte de la interfaz falle.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local jugador = Players.LocalPlayer
local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael:WaitForChild("Datos")) :: any
local Ui = require(script.Parent:WaitForChild("Ui"))
local C = Ui.Colores

local gui = Ui.crear("ScreenGui", { Name = "VaelMapa", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = jugador:WaitForChild("PlayerGui") })

local X0, X1 = -445, 605
local REGIONES = {
	{ nombre = "Aldea de Brezo", desde = -445, hasta = -205, color = Color3.fromRGB(170, 200, 120) },
	{ nombre = "Ciudad de Vael", desde = -205, hasta = 45, color = Color3.fromRGB(220, 190, 140) },
	{ nombre = "Pradera", desde = 45, hasta = 163, color = Color3.fromRGB(140, 200, 110) },
	{ nombre = "Pantano", desde = 163, hasta = 263, color = Color3.fromRGB(110, 150, 130), llave = "cuerda" },
	{ nombre = "Bosque", desde = 263, hasta = 363, color = Color3.fromRGB(80, 140, 85), llave = "hacha" },
	{ nombre = "Ruinas", desde = 363, hasta = 463, color = Color3.fromRGB(170, 155, 135), llave = "llave" },
	{ nombre = "Cueva", desde = 463, hasta = 605, color = Color3.fromRGB(110, 100, 105), llave = "farol" },
}
local SITIOS = {
	{ nombre = "Tu casa", x = -415, icono = "corazon" },
	{ nombre = "Huerto invadido", x = -262, icono = "espada" },
	{ nombre = "Herrería", x = -168, icono = "escudo" },
	{ nombre = "Taberna", x = -102, icono = "moneda" },
	{ nombre = "Fuente", x = -46, icono = "gota" },
	{ nombre = "Mercader", x = -26, icono = "pocion" },
	{ nombre = "Posada", x = -23, icono = "estrella" },
	{ nombre = "Guarida", x = 110, icono = "espada" },
	{ nombre = "Guarida", x = 215, icono = "espada" },
	{ nombre = "Ermitaño", x = 329, icono = "magia" },
	{ nombre = "Guarida", x = 315, icono = "espada" },
	{ nombre = "Guarida", x = 415, icono = "espada" },
	{ nombre = "Rey Hongo", x = 540, icono = "espada" },
}

local function aFraccion(x: number): number
	return math.clamp((x - X0) / (X1 - X0), 0, 1)
end

--- Dibuja la tira del mapa dentro de un marco. Devuelve el marcador del jugador y el del objetivo.
local function tira(padre: Instance, alto: number, conNombres: boolean, z: number): (Frame, Frame, { [string]: Frame })
	local candados: { [string]: Frame } = {}
	for _, r in REGIONES do
		local f = Ui.crear("Frame", { Position = UDim2.fromScale(aFraccion(r.desde), 0), Size = UDim2.fromScale(aFraccion(r.hasta) - aFraccion(r.desde), 1), BackgroundColor3 = Ui.apagar(r.color), BorderSizePixel = 0, ZIndex = z, Parent = padre })
		Ui.borde(f, C.tinta, 1.5)
		if conNombres then
			Ui.texto({ Position = UDim2.fromScale(0, 0.05), Size = UDim2.fromScale(1, 0.35), Text = r.nombre, TextColor3 = C.texto, ZIndex = z + 1, Parent = f })
		end
		if r.llave then
			local candado = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(alto * 0.45, alto * 0.45), BackgroundColor3 = Color3.fromRGB(80, 70, 65), BorderSizePixel = 0, ZIndex = z + 2, Parent = f })
			Ui.esquinas(candado, 4)
			Ui.borde(candado, C.tinta, 1.5)
			Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.15), Size = UDim2.fromScale(0.6, 0.5), BackgroundTransparency = 1, ZIndex = z + 2, Parent = candado }, {
				Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
				Ui.crear("UIStroke", { Thickness = 2, Color = Color3.fromRGB(80, 70, 65) }),
			})
			candados[r.llave] = candado
		end
	end
	if conNombres then
		for _, s in SITIOS do
			local ic = Ui.icono(s.icono, padre, UDim2.new(aFraccion(s.x), -11, 0.62, -11), UDim2.fromOffset(22, 22), z + 3)
			local _ = ic
		end
	end
	local objetivo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(alto * 0.6, alto * 0.6), BackgroundTransparency = 1, ZIndex = z + 4, Parent = padre })
	Ui.icono("estrella", objetivo, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), z + 4)
	local yo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(alto * 0.55, alto * 0.55), BackgroundColor3 = Color3.fromRGB(250, 236, 200), BorderSizePixel = 0, ZIndex = z + 5, Parent = padre })
	Ui.esquinas(yo, 999)
	Ui.borde(yo, Color3.fromRGB(200, 70, 60), 3)
	return yo, objetivo, candados
end

-- ===================== MINIMAPA Y OBJETIVO =====================
local mini = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(560, 92), Parent = gui, ZIndex = 10 })
local carril = Ui.crear("Frame", { Position = UDim2.fromOffset(14, 22), Size = UDim2.new(1, -28, 0, 26), BackgroundTransparency = 1, ZIndex = 11, Parent = mini })
local yo, estrella, candados = tira(carril, 26, false, 11)
local textoObjetivo = Ui.texto({ Position = UDim2.fromOffset(46, 54), Size = UDim2.new(1, -60, 0, 28), Text = "", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11, Parent = mini })
local flecha = Ui.crear("Frame", { Position = UDim2.fromOffset(14, 56), Size = UDim2.fromOffset(26, 24), BackgroundTransparency = 1, ZIndex = 11, Parent = mini })
local iconoFlecha: Frame = Ui.icono("huir", flecha, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 12)
Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 2), Size = UDim2.fromOffset(160, 18), Text = "Tab o botón: mapa", TextColor3 = C.suave, ZIndex = 11, Parent = mini })

local estado: any = nil
local objetivoX: number? = nil
local enCombate = false

local SETAS = { 272, 302.5, 352 }
local PALANCAS = { 372, 395, 452 }

local function calcularObjetivo(e: any): (string, number?)
	if not e or not e.clase then
		return "Elige tu clase y crea a tu héroe", nil
	end
	local ll = e.llaves or {}
	if not ll.cuerda then
		return "Taberna (ciudad): gana 2 veces seguidas a los vasos y consigue la cuerda", -102
	elseif not ll.hacha then
		return "Pantano: sube por las tablas hasta el cofre del hacha", 252
	elseif not ll.llave then
		local tengo = e.setas or {}
		if #tengo >= 3 then
			return "Bosque: lleva las 3 setas al ermitaño Fermín", 329
		end
		for i, x in SETAS do
			if not table.find(tengo, i) then
				return "Bosque: busca setas brillantes (" .. #tengo .. "/3)", x
			end
		end
	elseif not ll.farol then
		local tiradas = e.palancas or {}
		if #tiradas >= 3 then
			return "Ruinas: abre el cofre de la cripta y coge el farol", 440
		end
		for i, x in PALANCAS do
			if not table.find(tiradas, i) then
				return "Ruinas: tira de las palancas (" .. #tiradas .. "/3)", x
			end
		end
	end
	return "Cueva: ¡derrota al Rey Hongo!", 540
end

local function actualizar(e: any)
	estado = e
	local texto, x = calcularObjetivo(e)
	textoObjetivo.Text = texto
	objetivoX = x
	estrella.Visible = x ~= nil
	if x then
		estrella.Position = UDim2.fromScale(aFraccion(x), 0.5)
	end
	for llave, c in candados do
		c.Visible = not (e and e.llaves and e.llaves[llave])
	end
end
task.spawn(function()
	local remotos = Vael:WaitForChild("Remotos")
	local r = remotos:WaitForChild("EstadoJugador") :: RemoteEvent
	r.OnClientEvent:Connect(actualizar)
	;(remotos:WaitForChild("BatallaInicio") :: RemoteEvent).OnClientEvent:Connect(function()
		enCombate = true
	end)
	;(remotos:WaitForChild("BatallaFin") :: RemoteEvent).OnClientEvent:Connect(function()
		task.delay(2, function()
			enCombate = false
		end)
	end)
end)

-- ===================== MAPA GRANDE =====================
local grande: Frame? = nil
local function abrirGrande()
	if grande then
		grande:Destroy()
		grande = nil
		return
	end
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(1000, 420), Parent = gui, ZIndex = 60 })
	grande = p
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 14), Size = UDim2.new(1, 0, 0, 40), Text = "Mapa de Vael", TextColor3 = C.oro, ZIndex = 61, Parent = p })
	local zona = Ui.crear("Frame", { Position = UDim2.fromOffset(24, 70), Size = UDim2.new(1, -48, 0, 150), BackgroundTransparency = 1, ZIndex = 61, Parent = p })
	local yoG, estrellaG, candadosG = tira(zona, 150, true, 61)
	for _, s in SITIOS do
		Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(aFraccion(s.x), 0, 1, 4), Size = UDim2.fromOffset(110, 18), Text = s.nombre, TextColor3 = C.suave, ZIndex = 62, Parent = zona })
	end
	-- paraderos que hay ahora mismo en el mapa
	local mundo = workspace:FindFirstChild("MundoVael")
	if mundo then
		for _, m in mundo:GetChildren() do
			if m:IsA("Model") and string.sub(m.Name, 1, 9) == "Paradero_" then
				local punto = m:FindFirstChild("Punto", true) :: BasePart?
				if punto then
					local aviso = Ui.texto({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(aFraccion(punto.Position.X), 0, 0, -2), Size = UDim2.fromOffset(30, 30), Text = "!", TextColor3 = Color3.fromRGB(240, 200, 100), ZIndex = 66, Parent = zona })
					local _ = aviso
				end
			end
		end
	end
	local texto, x = calcularObjetivo(estado)
	estrellaG.Visible = x ~= nil
	if x then
		estrellaG.Position = UDim2.fromScale(aFraccion(x), 0.5)
	end
	for llave, c in candadosG do
		c.Visible = not (estado and estado.llaves and estado.llaves[llave])
	end
	local ch = jugador.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if raiz then
		yoG.Position = UDim2.fromScale(aFraccion(raiz.Position.Y > 150 and -60 or raiz.Position.X), 0.5)
	end
	Ui.texto({ Position = UDim2.fromOffset(30, 262), Size = UDim2.new(1, -60, 0, 30), Text = "Objetivo: " .. texto, TextColor3 = C.texto, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 61, Parent = p })
	Ui.texto({ Position = UDim2.fromOffset(30, 296), Size = UDim2.new(1, -60, 0, 24), Text = "Candado: camino cerrado · Estrella: objetivo · !: paradero (hoguera, cofre, vendedor…) · Tu cara: tú", TextColor3 = C.suave, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 61, Parent = p })
	Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.fromOffset(200, 44), Text = "Cerrar", Icono = "volver", BackgroundColor3 = C.fondo, ZIndex = 62, Parent = p }, function()
		if grande == p then
			grande = nil
		end
		p:Destroy()
	end)
end

Ui.boton({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 10), Size = UDim2.fromOffset(130, 44), Text = "Mapa", Icono = "estrella", BackgroundColor3 = Color3.fromRGB(110, 140, 90), ZIndex = 10, Parent = gui }, abrirGrande)
UserInputService.InputBegan:Connect(function(entrada, procesado)
	if not procesado and entrada.KeyCode == Enum.KeyCode.Tab then
		abrirGrande()
	end
end)

-- ===================== CADA FOTOGRAMA: dónde estás y hacia dónde ir =====================
RunService.RenderStepped:Connect(function()
	-- el mapa no estorba en el menú de inicio ni en los combates
	local oculto = jugador:GetAttribute("EnMenu") == true or enCombate
	mini.Visible = not oculto
	local ch = jugador.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz then
		return
	end
	local x = raiz.Position.X
	if raiz.Position.Y > 150 then
		x = -60 -- dentro de la taberna o la posada: en la ciudad
	end
	yo.Position = UDim2.fromScale(aFraccion(x), 0.5)
	if objetivoX then
		local d = objetivoX - x
		flecha.Visible = math.abs(d) > 6
		iconoFlecha.Rotation = d > 0 and 0 or 180
	else
		flecha.Visible = false
	end
end)

jugador:SetAttribute("CargadoMapa", true)
