--!nonstrict
-- Armería de Olga: comprar y mejorar armas, armaduras y amuletos.
-- Armeria.abrir(gui, datos, comprar, mejorar): datos = { oro, nivel, clase, armas = { [id] = mejora }, equipo, novedad }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ui = require(script.Parent:WaitForChild("Ui"))
local Datos = require(ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Datos")) :: any
local C = Ui.Colores

local Armeria = {}
local abierto: Frame? = nil
local pestana = "comprar"

function Armeria.estaAbierto(): boolean
	return abierto ~= nil and abierto.Parent ~= nil
end

function Armeria.cerrar()
	if abierto then
		abierto:Destroy()
		abierto = nil
	end
end

local ICONO_HUECO = { arma = "espada", armadura = "escudo", amuleto = "estrella" }
local NOMBRE_HUECO = { arma = "Arma", armadura = "Armadura", amuleto = "Amuleto" }

function Armeria.abrir(gui: Instance, datos: any, comprar: (string) -> (), mejorar: (string) -> ())
	Armeria.cerrar()
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(880, 560), BackgroundColor3 = Color3.fromRGB(120, 95, 80), Parent = gui, ZIndex = 120 })
	abierto = p
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(20, 12), Size = UDim2.new(0.6, 0, 0, 40), Text = "Herrería de Olga", TextColor3 = C.oro, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 121, Parent = p })
	Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 16), Size = UDim2.fromOffset(260, 30), Text = tostring(datos.oro or 0) .. " " .. Ui.t("oro") .. "  ·  " .. Ui.t("Nivel") .. " " .. tostring(datos.nivel or 1), TextColor3 = C.texto, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 121, Parent = p })
	-- pestañas
	local barra = Ui.crear("Frame", { Position = UDim2.fromOffset(20, 58), Size = UDim2.fromOffset(420, 40), BackgroundTransparency = 1, ZIndex = 121, Parent = p })
	Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = barra })
	for i, t in { { "comprar", "Comprar" }, { "mejorar", "Mejorar lo mío" } } do
		Ui.boton({ Size = UDim2.fromOffset(200, 40), Text = t[2], LayoutOrder = i, BackgroundColor3 = pestana == t[1] and Color3.fromRGB(220, 170, 60) or Color3.fromRGB(110, 100, 95), ZIndex = 122, Parent = barra }, function()
			pestana = t[1]
			Armeria.abrir(gui, datos, comprar, mejorar)
		end)
	end
	local zona = Ui.crear("ScrollingFrame", { Position = UDim2.fromOffset(20, 108), Size = UDim2.new(1, -40, 1, -180), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 6, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 121, Parent = p })
	Ui.crear("UIGridLayout", { CellSize = UDim2.fromOffset(266, 168), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = zona })
	local armas = datos.armas or {}
	local equipo = datos.equipo or {}
	local n = 0
	for i, id in Datos.OrdenEquipo do
		local pz = Datos.Equipo[id]
		local tengo = armas[id] ~= nil
		local mostrar = Datos.puedeLlevar(id, datos.clase) and ((pestana == "comprar" and not tengo) or (pestana == "mejorar" and tengo))
		if mostrar then
			n += 1
			local mejora = armas[id] or 0
			local carta = Ui.crear("Frame", { BackgroundColor3 = Color3.fromRGB(236, 222, 190), BorderSizePixel = 0, LayoutOrder = i, ZIndex = 122, Parent = zona })
			Ui.esquinas(carta, 6)
			Ui.borde(carta, datos.novedad == id and C.oro or C.tinta, datos.novedad == id and 4 or 2)
			local muestra = Ui.crear("Frame", { Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(52, 52), BackgroundColor3 = pz.color, BorderSizePixel = 0, ZIndex = 123, Parent = carta })
			Ui.esquinas(muestra, 10)
			Ui.borde(muestra, C.tinta, 2)
			Ui.icono(pz.forma == "baston" and "magia" or ICONO_HUECO[pz.hueco], muestra, UDim2.fromOffset(8, 8), UDim2.fromOffset(36, 36), 124)
			local tinta = Color3.fromRGB(60, 45, 35)
			Ui.crear("TextLabel", { Position = UDim2.fromOffset(70, 8), Size = UDim2.new(1, -78, 0, 24), BackgroundTransparency = 1, Text = pz.nombre .. (mejora > 0 and (" +" .. mejora) or ""), Font = Ui.Fuente, TextScaled = true, TextColor3 = tinta, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 123, Parent = carta })
			Ui.crear("TextLabel", { Position = UDim2.fromOffset(70, 32), Size = UDim2.new(1, -78, 0, 16), BackgroundTransparency = 1, Text = NOMBRE_HUECO[pz.hueco] .. (equipo[pz.hueco] == id and " · (puesto)" or ""), Font = Ui.FuenteDialogo, TextSize = 16, TextColor3 = Color3.fromRGB(130, 100, 80), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 123, Parent = carta })
			Ui.crear("TextLabel", { Position = UDim2.fromOffset(10, 66), Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, Text = pz.descripcion, Font = Ui.FuenteDialogo, TextSize = 16, TextWrapped = true, TextColor3 = tinta, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 123, Parent = carta })
			local stats = Ui.crear("TextLabel", { Position = UDim2.fromOffset(10, 102), Size = UDim2.new(1, -20, 0, 18), BackgroundTransparency = 1, Text = "", Font = Ui.FuenteDialogo, TextSize = 17, TextColor3 = Color3.fromRGB(70, 120, 60), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 123, Parent = carta })
			local abajo = UDim2.new(0, 10, 1, -40)
			if pestana == "comprar" then
				stats.Text = Datos.textoStats(Datos.statsPieza(id, 0))
				local falta = (datos.nivel or 1) < pz.nivel
				local caro = (datos.oro or 0) < pz.precio
				local texto = falta and (Ui.t("Nivel") .. " " .. pz.nivel) or (pz.precio .. " " .. Ui.t("oro"))
				local b = Ui.boton({ Position = abajo, Size = UDim2.new(1, -20, 0, 32), Text = texto, Icono = "moneda", BackgroundColor3 = (falta or caro) and Color3.fromRGB(130, 120, 110) or Color3.fromRGB(100, 160, 90), ZIndex = 124, Parent = carta }, function()
					if not falta and not caro then
						comprar(id)
					end
				end)
				if falta or caro then
					b.TextTransparency = 0.4
				end
			else
				local actual = Datos.statsPieza(id, mejora)
				if mejora >= Datos.MAX_MEJORA_EQUIPO then
					stats.Text = Datos.textoStats(actual)
					Ui.crear("TextLabel", { Position = abajo, Size = UDim2.new(1, -20, 0, 32), BackgroundTransparency = 1, Text = "¡Al máximo!", Font = Ui.Fuente, TextScaled = true, TextColor3 = Color3.fromRGB(180, 130, 40), ZIndex = 124, Parent = carta })
				else
					stats.Text = Datos.textoStats(actual) .. "  →  " .. Datos.textoStats(Datos.statsPieza(id, mejora + 1))
					stats.TextScaled = true
					local precio = Datos.precioMejora(id, mejora)
					local caro = (datos.oro or 0) < precio
					local b = Ui.boton({ Position = abajo, Size = UDim2.new(1, -20, 0, 32), Text = Ui.t("Mejorar") .. " +" .. (mejora + 1) .. " · " .. precio, Icono = "estrella", BackgroundColor3 = caro and Color3.fromRGB(130, 120, 110) or Color3.fromRGB(220, 170, 60), ZIndex = 124, Parent = carta }, function()
						if not caro then
							mejorar(id)
						end
					end)
					if caro then
						b.TextTransparency = 0.4
					end
				end
			end
			if datos.novedad == id then
				local esc = Ui.crear("UIScale", { Scale = 1.15, Parent = carta })
				Ui.tween(esc, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
			end
		end
	end
	if n == 0 then
		Ui.texto({ Size = UDim2.fromOffset(600, 40), Text = pestana == "comprar" and "¡Ya tienes todo lo que puedes llevar!" or "Aún no tienes equipo. Compra algo primero.", TextColor3 = C.suave, ZIndex = 122, Parent = zona })
	end
	Ui.texto({ Position = UDim2.new(0, 20, 1, -64), Size = UDim2.new(1, -260, 0, 22), Text = "Para cambiarte de equipo, abre la mochila (B).", TextColor3 = C.suave, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 121, Parent = p })
	Ui.boton({ AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -14), Size = UDim2.fromOffset(200, 46), Text = "Cerrar", BackgroundColor3 = Color3.fromRGB(120, 110, 100), Icono = "volver", ZIndex = 122, Parent = p }, Armeria.cerrar)
end

return Armeria
