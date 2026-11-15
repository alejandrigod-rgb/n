--!strict
-- Piezas de interfaz de Crónicas de Vael. TODO lo que se mueve usa TweenService (interpolado por el motor en cada
-- fotograma, a los 60 fps del cliente), nunca bucles con task.wait: así los menús van fluidos.

local TweenService = game:GetService("TweenService")

local Ui = {}

Ui.Colores = {
	fondo = Color3.fromRGB(22, 20, 34),
	panel = Color3.fromRGB(34, 31, 52),
	borde = Color3.fromRGB(232, 190, 92),
	texto = Color3.fromRGB(245, 240, 228),
	suave = Color3.fromRGB(170, 162, 190),
	vida = Color3.fromRGB(226, 72, 84),
	mana = Color3.fromRGB(70, 140, 236),
	xp = Color3.fromRGB(150, 220, 100),
	oro = Color3.fromRGB(255, 205, 80),
	peligro = Color3.fromRGB(230, 70, 70),
}

Ui.Fuente = Enum.Font.FredokaOne
Ui.FuenteTexto = Enum.Font.GothamBold

--- Tween de una instancia (por defecto 0,35 s con curva suave de entrada y salida).
function Ui.tween(obj: Instance, props: { [string]: any }, tiempo: number?, estilo: Enum.EasingStyle?, dir: Enum.EasingDirection?): Tween
	local t = TweenService:Create(obj, TweenInfo.new(tiempo or 0.35, estilo or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

--- Crea una instancia con propiedades e hijos.
function Ui.crear(clase: string, props: { [string]: any }, hijos: { Instance }?): any
	local o = Instance.new(clase)
	for k, v in props do
		if k ~= "Parent" then
			(o :: any)[k] = v
		end
	end
	if hijos then
		for _, h in hijos do
			h.Parent = o
		end
	end
	if props.Parent then
		o.Parent = props.Parent
	end
	return o
end

function Ui.esquinas(o: GuiObject, radio: number?)
	Ui.crear("UICorner", { CornerRadius = UDim.new(0, radio or 14), Parent = o })
end

function Ui.borde(o: GuiObject, color: Color3?, grosor: number?)
	Ui.crear("UIStroke", { Color = color or Ui.Colores.borde, Thickness = grosor or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
end

--- Panel oscuro con borde dorado y esquinas redondeadas.
function Ui.panel(props: { [string]: any }): Frame
	local f = Ui.crear("Frame", props)
	f.BackgroundColor3 = props.BackgroundColor3 or Ui.Colores.panel
	f.BorderSizePixel = 0
	Ui.esquinas(f, 16)
	Ui.borde(f)
	Ui.crear("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 185, 210)), Parent = f })
	return f
end

function Ui.texto(props: { [string]: any }): TextLabel
	local t = Ui.crear("TextLabel", props)
	t.BackgroundTransparency = 1
	t.Font = props.Font or Ui.Fuente
	t.TextColor3 = props.TextColor3 or Ui.Colores.texto
	if props.TextScaled == nil then
		t.TextScaled = true
	end
	return t
end

--- Botón con animación: crece al pasar el ratón, se hunde al pulsar.
function Ui.boton(props: { [string]: any }, alPulsar: () -> ()): TextButton
	local b = Ui.crear("TextButton", props)
	b.AutoButtonColor = false
	b.Font = props.Font or Ui.Fuente
	b.TextColor3 = props.TextColor3 or Ui.Colores.texto
	b.TextScaled = true
	b.BorderSizePixel = 0
	b.BackgroundColor3 = props.BackgroundColor3 or Ui.Colores.panel
	Ui.esquinas(b, 12)
	Ui.borde(b, props.BorderColor or Ui.Colores.borde, 2)
	Ui.crear("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = b })
	local escala = Ui.crear("UIScale", { Scale = 1, Parent = b })
	b.MouseEnter:Connect(function()
		Ui.tween(escala, { Scale = 1.06 }, 0.15)
	end)
	b.MouseLeave:Connect(function()
		Ui.tween(escala, { Scale = 1 }, 0.2)
	end)
	b.MouseButton1Down:Connect(function()
		Ui.tween(escala, { Scale = 0.94 }, 0.08)
	end)
	b.MouseButton1Up:Connect(function()
		Ui.tween(escala, { Scale = 1.06 }, 0.15, Enum.EasingStyle.Back)
	end)
	b.Activated:Connect(alPulsar)
	return b
end

--- Barra con relleno que se desliza suave (y una "estela" que baja más despacio, como en los RPG).
export type Barra = { marco: Frame, set: (actual: number, maximo: number, instantaneo: boolean?) -> () }
function Ui.barra(padre: Instance, pos: UDim2, tam: UDim2, color: Color3, conTexto: boolean?): Barra
	local marco = Ui.crear("Frame", { Position = pos, Size = tam, BackgroundColor3 = Color3.fromRGB(16, 14, 24), BorderSizePixel = 0, Parent = padre, ClipsDescendants = true })
	Ui.esquinas(marco, 999)
	local estela = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.35, BorderSizePixel = 0, Parent = marco })
	Ui.esquinas(estela, 999)
	local relleno = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = color, BorderSizePixel = 0, Parent = marco })
	Ui.esquinas(relleno, 999)
	Ui.crear("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(170, 170, 170)), Parent = relleno })
	local etiqueta: TextLabel? = nil
	if conTexto then
		etiqueta = Ui.texto({ Size = UDim2.fromScale(1, 1), Text = "", TextColor3 = Color3.new(1, 1, 1), Font = Ui.FuenteTexto, Parent = marco, ZIndex = 3 })
		Ui.crear("UIStroke", { Thickness = 1.2, Color = Color3.new(0, 0, 0), Parent = etiqueta })
	end
	local function set(actual: number, maximo: number, instantaneo: boolean?)
		local k = maximo > 0 and math.clamp(actual / maximo, 0, 1) or 0
		if instantaneo then
			relleno.Size = UDim2.fromScale(k, 1)
			estela.Size = UDim2.fromScale(k, 1)
		else
			Ui.tween(relleno, { Size = UDim2.fromScale(k, 1) }, 0.35)
			Ui.tween(estela, { Size = UDim2.fromScale(k, 1) }, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		end
		if etiqueta then
			etiqueta.Text = string.format("%d / %d", actual, maximo)
		end
	end
	return { marco = marco, set = set }
end

--- Hace aparecer un elemento con un pequeño rebote (escala 0,6 → 1 y transparencia).
function Ui.aparecer(o: GuiObject, retraso: number?)
	local escala = o:FindFirstChildOfClass("UIScale") or Ui.crear("UIScale", { Parent = o })
	escala.Scale = 0.6
	o.Visible = true
	task.delay(retraso or 0, function()
		Ui.tween(escala, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
	end)
end

return Ui
