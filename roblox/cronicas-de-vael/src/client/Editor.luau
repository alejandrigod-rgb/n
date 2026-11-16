--!strict
-- Editor del personaje: piel, pelo, ojos, ropa, gorro, accesorio gracioso y nombre del héroe.
-- Se ve el muñeco en grande y cambia al momento. Lo usan la creación del personaje y el menú de pausa.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Datos = require(ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Datos")) :: any
local Ui = require(script.Parent:WaitForChild("Ui"))
local Munecos = require(script.Parent:WaitForChild("Munecos"))

local Editor = {}
local C = Ui.Colores
local A = Datos.Apariencia

local abierto: Frame? = nil

-- filas del editor: campo, título y lista de opciones (de texto o de colores)
local FILAS = {
	{ "piel", "Piel", "pieles", true },
	{ "pelo", "Pelo", "pelos", false },
	{ "colorPelo", "Color del pelo", "coloresPelo", true },
	{ "ojos", "Ojos", "ojos", false },
	{ "colorOjos", "Color de ojos", "coloresOjos", true },
	{ "ropa", "Ropa", "coloresRopa", true },
	{ "gorro", "En la cabeza", "gorros", false },
	{ "colorGorro", "Color del gorro", "coloresGorro", true },
	{ "accesorio", "Accesorio", "accesorios", false },
}

--- Abre el editor. alGuardar recibe la apariencia final (con el nombre).
function Editor.abrir(gui: Instance, clase: string, inicial: any, alGuardar: (any) -> (), primeraVez: boolean?)
	if abierto then
		abierto:Destroy()
	end
	local ap = Datos.validarApariencia(inicial or {})
	local capa = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(40, 32, 28), BackgroundTransparency = 0.3, ZIndex = 150, Parent = gui })
	abierto = capa
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(900, 600), Parent = capa, ZIndex = 151 })
	Ui.aparecer(p)
	Ui.texto({ Position = UDim2.fromOffset(0, 14), Size = UDim2.new(1, 0, 0, 44), Text = primeraVez and "¡Crea a tu héroe!" or "Tu personaje", TextColor3 = C.oro, ZIndex = 152, Parent = p })

	-- vista previa en una hoja de papel
	local hoja = Ui.crear("Frame", { Position = UDim2.fromOffset(30, 70), Size = UDim2.fromOffset(300, 430), BackgroundColor3 = C.borde, BorderSizePixel = 0, Rotation = -1.5, ZIndex = 152, Parent = p })
	Ui.esquinas(hoja, 4)
	Ui.borde(hoja, C.tinta, 2)
	local lienzo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -70), Size = UDim2.fromOffset(240, 312), BackgroundTransparency = 1, ZIndex = 153, Parent = hoja })
	local caja = Ui.crear("TextBox", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.new(1, -40, 0, 42),
		BackgroundColor3 = Color3.fromRGB(250, 246, 236),
		BorderSizePixel = 0,
		Text = ap.nombre,
		PlaceholderText = "Nombre del héroe",
		ClearTextOnFocus = false,
		Font = Ui.Fuente,
		TextScaled = true,
		TextColor3 = C.tinta,
		PlaceholderColor3 = Color3.fromRGB(150, 140, 125),
		ZIndex = 154,
		Parent = hoja,
	})
	Ui.esquinas(caja, 6)
	Ui.borde(caja, C.tinta, 2)
	caja:GetPropertyChangedSignal("Text"):Connect(function()
		if #caja.Text > 16 then
			caja.Text = string.sub(caja.Text, 1, 16)
		end
	end)

	local muneco: any = nil
	local function redibujar()
		for _, h in lienzo:GetChildren() do
			h:Destroy()
		end
		muneco = Munecos.crear(lienzo, "clase", clase, 3, ap)
		Munecos.atacar(muneco, 1)
	end
	redibujar()

	-- filas de opciones
	local lista = Ui.crear("ScrollingFrame", { Position = UDim2.fromOffset(360, 70), Size = UDim2.fromOffset(510, 440), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 6, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 152, Parent = p })
	Ui.crear("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = lista })
	local refrescos: { () -> () } = {}
	for orden, fila in FILAS do
		local campo, titulo, nombreLista, esColor = fila[1], fila[2], fila[3], fila[4]
		local opciones = A[nombreLista]
		local f = Ui.crear("Frame", { Size = UDim2.new(1, -10, 0, esColor and 44 or 40), BackgroundTransparency = 1, LayoutOrder = orden, ZIndex = 152, Parent = lista })
		Ui.texto({ Position = UDim2.fromOffset(0, 4), Size = UDim2.fromOffset(150, 32), Text = titulo, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 153, Parent = f })
		if esColor then
			local muestras: { Frame } = {}
			for i, col in opciones do
				local b = Ui.crear("TextButton", { Position = UDim2.fromOffset(160 + (i - 1) * 38, 5), Size = UDim2.fromOffset(32, 32), Text = "", AutoButtonColor = false, BackgroundColor3 = (campo == "ropa" and i == 1) and Color3.fromRGB(210, 200, 180) or Ui.apagar(col), BorderSizePixel = 0, ZIndex = 153, Parent = f })
				Ui.esquinas(b, 16)
				Ui.borde(b, C.tinta, 2)
				if campo == "ropa" and i == 1 then
					Ui.texto({ Size = UDim2.fromScale(1, 1), Text = "C", TextColor3 = C.tinta, Contorno = false, ZIndex = 154, Parent = b })
				end
				b.Activated:Connect(function()
					ap[campo] = i
					redibujar()
					for _, r in refrescos do
						r()
					end
				end)
				muestras[i] = b
			end
			table.insert(refrescos, function()
				for i, b in muestras do
					local trazo = b:FindFirstChildOfClass("UIStroke")
					if trazo then
						trazo.Thickness = ap[campo] == i and 4 or 2
						trazo.Color = ap[campo] == i and C.oro or C.tinta
					end
				end
			end)
		else
			local valor = Ui.texto({ Position = UDim2.fromOffset(210, 4), Size = UDim2.fromOffset(230, 32), Text = "", ZIndex = 153, Parent = f })
			local function cambiar(d: number)
				ap[campo] = ((ap[campo] - 1 + d) % #opciones) + 1
				redibujar()
				for _, r in refrescos do
					r()
				end
			end
			Ui.boton({ Position = UDim2.fromOffset(160, 2), Size = UDim2.fromOffset(44, 36), Text = "<", BackgroundColor3 = C.fondo, ZIndex = 153, Parent = f }, function()
				cambiar(-1)
			end)
			Ui.boton({ Position = UDim2.fromOffset(446, 2), Size = UDim2.fromOffset(44, 36), Text = ">", BackgroundColor3 = C.fondo, ZIndex = 153, Parent = f }, function()
				cambiar(1)
			end)
			table.insert(refrescos, function()
				valor.Text = opciones[ap[campo]]
			end)
		end
	end
	for _, r in refrescos do
		r()
	end

	local function cerrar()
		capa:Destroy()
		if abierto == capa then
			abierto = nil
		end
	end
	Ui.boton({ Position = UDim2.new(0, 30, 1, -74), Size = UDim2.fromOffset(200, 50), Text = "Al azar", Icono = "estrella", BackgroundColor3 = Color3.fromRGB(130, 100, 170), ZIndex = 152, Parent = p }, function()
		for _, fila in FILAS do
			ap[fila[1]] = math.random(1, #A[fila[3]])
		end
		redibujar()
		for _, r in refrescos do
			r()
		end
	end)
	if not primeraVez then
		Ui.boton({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -250, 1, -74), Size = UDim2.fromOffset(200, 50), Text = "Cancelar", Icono = "volver", BackgroundColor3 = C.fondo, ZIndex = 152, Parent = p }, cerrar)
	end
	Ui.boton({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -30, 1, -74), Size = UDim2.fromOffset(200, 50), Text = "¡Listo!", Icono = "corazon", BackgroundColor3 = Color3.fromRGB(90, 150, 90), ZIndex = 152, Parent = p }, function()
		ap.nombre = caja.Text
		alGuardar(ap)
		cerrar()
	end)
end

return Editor
