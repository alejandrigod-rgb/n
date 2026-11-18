--!nonstrict
-- Tablón de encargos (misiones secundarias): un corcho con notas de papel clavadas con chinchetas.
-- Cada nota dice quién lo pide, qué hay que hacer, cómo vas y qué te dan. Se aceptan hasta 3 a la vez.
-- Encargos.abrir(gui, datos, aceptar, entregar): datos = { lista = { {id, estado, n} }, entregado = id? }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ui = require(script.Parent:WaitForChild("Ui"))
local Datos = require(ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Datos")) :: any
local C = Ui.Colores

local Encargos = {}
local abierto: Frame? = nil

function Encargos.estaAbierto(): boolean
	return abierto ~= nil and abierto.Parent ~= nil
end

function Encargos.cerrar()
	if abierto then
		abierto:Destroy()
		abierto = nil
	end
end

local COLOR_NOTA = { disponible = Color3.fromRGB(250, 244, 222), activa = Color3.fromRGB(250, 236, 170), lista = Color3.fromRGB(200, 235, 170), hecha = Color3.fromRGB(205, 200, 190), bloqueado = Color3.fromRGB(170, 160, 150) }

local function premioDe(e: any): string
	local partes = { "+" .. e.oro .. " " .. Ui.t("oro"), "+" .. e.xp .. " EXP" }
	if e.objeto and Datos.Objetos[e.objeto] then
		table.insert(partes, Ui.t(Datos.Objetos[e.objeto].nombre))
	end
	if e.mejora and Datos.Mejoras[e.mejora] then
		table.insert(partes, Ui.t(Datos.Mejoras[e.mejora].nombre))
	end
	return table.concat(partes, " · ")
end

function Encargos.abrir(gui: Instance, datos: any, aceptar: (string) -> (), entregar: (string) -> ())
	local posicionScroll = 0
	if Encargos.estaAbierto() then
		local viejo = (abierto :: Frame):FindFirstChild("Notas", true)
		if viejo then
			posicionScroll = (viejo :: ScrollingFrame).CanvasPosition.Y
		end
		Encargos.cerrar()
	end
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(900, 560), BackgroundColor3 = Color3.fromRGB(175, 130, 85), Parent = gui, ZIndex = 120 })
	abierto = p
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(20, 12), Size = UDim2.new(1, -40, 0, 40), Text = "Tablón de encargos", TextColor3 = C.oro, ZIndex = 121, Parent = p })
	local activos = 0
	for _, it in datos.lista or {} do
		if it.estado == "activa" or it.estado == "lista" then
			activos += 1
		end
	end
	Ui.texto({ Position = UDim2.fromOffset(24, 52), Size = UDim2.new(0.6, 0, 0, 24), Text = Ui.t("Encargos aceptados") .. ": " .. activos .. "/" .. Datos.MAX_ENCARGOS, TextColor3 = C.texto, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 121, Parent = p })
	-- corcho
	local corcho = Ui.crear("Frame", { Position = UDim2.fromOffset(20, 84), Size = UDim2.new(1, -40, 1, -150), BackgroundColor3 = Color3.fromRGB(190, 150, 105), BorderSizePixel = 0, ZIndex = 121, Parent = p })
	Ui.esquinas(corcho, 8)
	Ui.borde(corcho, C.tinta, 3)
	local zona = Ui.crear("ScrollingFrame", { Name = "Notas", Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 1, -20), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 6, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 122, Parent = corcho })
	Ui.crear("UIGridLayout", { CellSize = UDim2.fromOffset(266, 170), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = zona })
	Ui.crear("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 4), Parent = zona })
	-- orden: primero las listas para entregar, luego las activas, las disponibles, las bloqueadas y al final las hechas
	local PESO = { lista = 1, activa = 2, disponible = 3, bloqueado = 4, hecha = 5 }
	for i, it in datos.lista or {} do
		local e = Datos.Encargos[it.id]
		if e then
			local nota = Ui.crear("Frame", { BackgroundTransparency = 1, LayoutOrder = (PESO[it.estado] or 3) * 100 + i, ZIndex = 123, Parent = zona })
			local papel = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -8, 1, -8), BackgroundColor3 = COLOR_NOTA[it.estado] or COLOR_NOTA.disponible, BorderSizePixel = 0, Rotation = ((i % 3) - 1) * 1.5, ZIndex = 123, Parent = nota })
			Ui.esquinas(papel, 4)
			Ui.borde(papel, C.tinta, 2)
			local chincheta = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 2), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(200, 60, 60), BorderSizePixel = 0, ZIndex = 125, Parent = papel })
			Ui.esquinas(chincheta, 8)
			Ui.borde(chincheta, C.tinta, 2)
			local tinta = Color3.fromRGB(60, 45, 35)
			Ui.crear("TextLabel", { Position = UDim2.fromOffset(10, 12), Size = UDim2.new(1, -20, 0, 24), BackgroundTransparency = 1, Text = e.titulo, Font = Ui.Fuente, TextScaled = true, TextColor3 = tinta, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 124, Parent = papel })
			Ui.crear("TextLabel", { Position = UDim2.fromOffset(10, 36), Size = UDim2.new(1, -20, 0, 16), BackgroundTransparency = 1, Text = e.de, Font = Ui.FuenteDialogo, TextSize = 16, TextColor3 = Color3.fromRGB(130, 100, 80), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 124, Parent = papel })
			Ui.crear("TextLabel", { Position = UDim2.fromOffset(10, 54), Size = UDim2.new(1, -20, 0, 48), BackgroundTransparency = 1, Text = e.texto, Font = Ui.FuenteDialogo, TextSize = 18, TextWrapped = true, TextColor3 = tinta, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 124, Parent = papel })
			local premio = Ui.crear("TextLabel", { Position = UDim2.fromOffset(10, 104), Size = UDim2.new(1, -20, 0, 18), BackgroundTransparency = 1, Text = "", Font = Ui.FuenteDialogo, TextSize = 16, TextColor3 = Color3.fromRGB(150, 110, 40), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 124, Parent = papel })
			premio.Text = premioDe(e)
			-- progreso o botón
			local abajo = UDim2.new(0, 10, 1, -40)
			if it.estado == "disponible" then
				Ui.boton({ Position = abajo, Size = UDim2.new(1, -20, 0, 32), Text = "Aceptar", BackgroundColor3 = Color3.fromRGB(100, 160, 90), ZIndex = 125, Parent = papel }, function()
					aceptar(it.id)
				end)
			elseif it.estado == "lista" then
				Ui.boton({ Position = abajo, Size = UDim2.new(1, -20, 0, 32), Text = "Entregar", Icono = "estrella", BackgroundColor3 = Color3.fromRGB(220, 170, 60), ZIndex = 125, Parent = papel }, function()
					entregar(it.id)
				end)
			elseif it.estado == "activa" then
				local barra = Ui.barra(papel, abajo, UDim2.new(1, -20, 0, 26), Color3.fromRGB(110, 170, 90), true)
				barra.set(it.n, e.cantidad)
			elseif it.estado == "hecha" then
				Ui.crear("TextLabel", { Position = abajo, Size = UDim2.new(1, -20, 0, 32), BackgroundTransparency = 1, Text = "¡Hecho!", Font = Ui.Fuente, TextScaled = true, TextColor3 = Color3.fromRGB(90, 140, 70), Rotation = -6, ZIndex = 125, Parent = papel })
			else
				Ui.crear("TextLabel", { Position = abajo, Size = UDim2.new(1, -20, 0, 32), BackgroundTransparency = 1, Text = "Tras la primera historia", Font = Ui.FuenteDialogo, TextScaled = true, TextColor3 = Color3.fromRGB(110, 100, 95), ZIndex = 125, Parent = papel })
			end
			-- la nota recién entregada da un saltito
			if datos.entregado == it.id then
				local esc = Ui.crear("UIScale", { Scale = 1.25, Parent = papel })
				Ui.tween(esc, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
			end
		end
	end
	zona.CanvasPosition = Vector2.new(0, posicionScroll)
	Ui.boton({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.fromOffset(200, 46), Text = "Cerrar", BackgroundColor3 = Color3.fromRGB(120, 110, 100), Icono = "volver", ZIndex = 122, Parent = p }, Encargos.cerrar)
end

return Encargos
