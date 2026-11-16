--!strict
-- Piezas de interfaz de Crónicas de Vael, en estilo CARTULINA RECORTADA: cartón marrón, papel crema, colores
-- planos y apagados (sin degradados ni brillos), chinchetas en las esquinas, letra de rotulador e iconos dibujados.
-- TODO lo que se mueve usa TweenService (interpolado por el motor en cada fotograma, a 60 fps).

local TweenService = game:GetService("TweenService")

local Ui = {}

Ui.Colores = {
	fondo = Color3.fromRGB(92, 74, 60),
	panel = Color3.fromRGB(150, 118, 88), -- cartón
	borde = Color3.fromRGB(236, 222, 190), -- papel
	texto = Color3.fromRGB(250, 244, 230),
	suave = Color3.fromRGB(232, 218, 190),
	vida = Color3.fromRGB(200, 80, 75),
	mana = Color3.fromRGB(85, 130, 190),
	xp = Color3.fromRGB(135, 175, 90),
	oro = Color3.fromRGB(240, 200, 100),
	peligro = Color3.fromRGB(200, 75, 70),
	tinta = Color3.fromRGB(48, 38, 34),
}

-- letra de rotulador (como escrita a mano sobre cartulina)
Ui.Fuente = Enum.Font.PermanentMarker
Ui.FuenteTexto = Enum.Font.PermanentMarker

local CARTON = Color3.fromRGB(150, 138, 122)
--- Apaga un color (estilo cartulina, nada chillón).
function Ui.apagar(c: Color3): Color3
	return c:Lerp(CARTON, 0.12)
end

-- claves propias que no son propiedades de Roblox
local PROPIAS = { Contorno = true, BorderColor = true, Icono = true, ColorIcono = true }

--- Tween de una instancia (por defecto 0,35 s con curva suave).
function Ui.tween(obj: Instance, props: { [string]: any }, tiempo: number?, estilo: Enum.EasingStyle?, dir: Enum.EasingDirection?): Tween
	local t = TweenService:Create(obj, TweenInfo.new(tiempo or 0.35, estilo or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

--- Crea una instancia con propiedades e hijos.
local Idioma: any = nil
--- Traduce un texto escrito en español al idioma elegido (ver Idioma.luau).
function Ui.t(texto: string): string
	if not Idioma then
		local ok, m = pcall(function()
			return require(script.Parent:WaitForChild("Idioma")) :: any
		end)
		Idioma = ok and m or { t = function(x) return x end }
	end
	return Idioma.t(texto)
end

function Ui.crear(clase: string, props: { [string]: any }, hijos: { Instance }?): any
	local o = Instance.new(clase)
	for k, v in props do
		if k ~= "Parent" and not PROPIAS[k] then
			(o :: any)[k] = v
		end
	end
	-- los textos fijos se traducen solos al crearlos (y se guardan para volver a traducir si cambia el idioma)
	if (clase == "TextLabel" or clase == "TextButton") and type(props.Text) == "string" and props.Text ~= "" then
		o:SetAttribute("TextoOriginal", props.Text)
		o.Text = Ui.t(props.Text)
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
	Ui.crear("UIStroke", { Color = color or Ui.Colores.tinta, Thickness = grosor or 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
end

local function degradado(_o: GuiObject, _oscuro: number?)
	-- en cartulina no hay degradados ni brillos: color plano
end

--- Panel de cartulina: cartón plano con contorno marrón, una hoja de papel algo torcida dentro y chinchetas.
function Ui.panel(props: { [string]: any }): Frame
	local f = Ui.crear("Frame", props)
	f.BackgroundColor3 = props.BackgroundColor3 and Ui.apagar(props.BackgroundColor3) or Ui.Colores.panel
	f.BorderSizePixel = 0
	Ui.esquinas(f, 6)
	Ui.borde(f, Ui.Colores.tinta, 3)
	local z = f.ZIndex
	-- borde de papel recortado (un poco torcido, como pegado a mano)
	local filete = Ui.crear("Frame", { Size = UDim2.new(1, -12, 1, -12), Position = UDim2.fromOffset(6, 6), Rotation = (math.random() - 0.5) * 0.8, BackgroundTransparency = 1, ZIndex = z, Parent = f })
	Ui.esquinas(filete, 4)
	Ui.borde(filete, Ui.Colores.borde, 1.5)
	for _, p in { { 0, 0 }, { 1, 0 } } do
		local chincheta = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(p[1], p[1] == 0 and 12 or -12, 0, 10), Size = UDim2.fromOffset(11, 11), BackgroundColor3 = Color3.fromRGB(190, 70, 65), BorderSizePixel = 0, ZIndex = z, Parent = f })
		Ui.esquinas(chincheta, 6)
		Ui.borde(chincheta, Ui.Colores.tinta, 1.5)
	end
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
	if props.Contorno ~= false then
		local trazo = Ui.crear("UIStroke", { Thickness = 2, Color = Ui.Colores.tinta, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Transparency = t.TextTransparency, Parent = t })
		-- el contorno se apaga con el texto (si no, queda un "fantasma" negro al desvanecer)
		t:GetPropertyChangedSignal("TextTransparency"):Connect(function()
			trazo.Transparency = t.TextTransparency
		end)
	end
	return t
end

-- ===================== ICONOS DIBUJADOS =====================
local function pz(padre: Instance, x: number, y: number, w: number, h: number, color: Color3, radio: number?, rot: number?, z: number?, borde: boolean?): Frame
	local f = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, h), Rotation = rot or 0, BackgroundColor3 = Ui.apagar(color), BorderSizePixel = 0, ZIndex = z or 1, Parent = padre })
	if radio then
		Ui.crear("UICorner", { CornerRadius = UDim.new(radio, 0), Parent = f })
	end
	if borde ~= false then
		Ui.crear("UIStroke", { Thickness = 2, Color = Ui.Colores.tinta, Parent = f })
	end
	return f
end

--- Icono dibujado: espada, magia, pocion, escudo, huir, corazon, gota, moneda, estrella, volver, eter.
function Ui.icono(tipo: string, padre: Instance, pos: UDim2, tam: UDim2, z: number?): Frame
	local c = Ui.crear("Frame", { Position = pos, Size = tam, BackgroundTransparency = 1, ZIndex = z or 1, Parent = padre })
	Ui.crear("UIAspectRatioConstraint", { AspectRatio = 1, Parent = c })
	local zi = (z or 1)
	if tipo == "espada" then
		pz(c, 0.55, 0.42, 0.16, 0.62, Color3.fromRGB(225, 232, 245), 0.3, 45, zi)
		pz(c, 0.3, 0.68, 0.38, 0.1, Color3.fromRGB(250, 200, 70), 0.3, 45, zi + 1)
		pz(c, 0.2, 0.8, 0.1, 0.2, Color3.fromRGB(130, 85, 50), 0.3, 45, zi)
	elseif tipo == "magia" or tipo == "estrella" then
		local col = tipo == "magia" and Color3.fromRGB(190, 140, 255) or Color3.fromRGB(255, 215, 80)
		pz(c, 0.5, 0.5, 0.56, 0.56, col, 0.15, 45, zi)
		pz(c, 0.5, 0.5, 0.56, 0.56, col, 0.15, 0, zi)
		pz(c, 0.42, 0.42, 0.14, 0.14, Color3.new(1, 1, 1), 0.5, 0, zi + 1, false)
	elseif tipo == "pocion" or tipo == "eter" then
		local col = tipo == "pocion" and Color3.fromRGB(240, 70, 90) or Color3.fromRGB(80, 160, 255)
		pz(c, 0.5, 0.62, 0.62, 0.56, col, 0.5, 0, zi)
		pz(c, 0.5, 0.26, 0.24, 0.22, Color3.fromRGB(200, 230, 245), 0.2, 0, zi)
		pz(c, 0.5, 0.13, 0.3, 0.1, Color3.fromRGB(150, 100, 60), 0.3, 0, zi + 1)
		pz(c, 0.38, 0.55, 0.12, 0.16, Color3.new(1, 1, 1), 0.5, 0, zi + 1, false).BackgroundTransparency = 0.3
	elseif tipo == "escudo" then
		pz(c, 0.5, 0.45, 0.66, 0.6, Color3.fromRGB(90, 150, 230), 0.25, 0, zi)
		pz(c, 0.5, 0.7, 0.36, 0.36, Color3.fromRGB(90, 150, 230), 0.15, 45, zi)
		pz(c, 0.5, 0.5, 0.1, 0.5, Color3.fromRGB(255, 210, 80), 0, 0, zi + 1, false)
	elseif tipo == "huir" or tipo == "volver" then
		local col = tipo == "huir" and Color3.fromRGB(200, 200, 215) or Color3.fromRGB(255, 205, 90)
		local dir = tipo == "huir" and 1 or -1
		pz(c, 0.45 - dir * 0.05, 0.5, 0.56, 0.2, col, 0.3, 0, zi)
		pz(c, 0.5 + dir * 0.18, 0.5, 0.36, 0.36, col, 0.15, 45, zi)
	elseif tipo == "corazon" then
		pz(c, 0.5, 0.58, 0.5, 0.5, Color3.fromRGB(240, 72, 84), 0.1, 45, zi)
		pz(c, 0.33, 0.38, 0.4, 0.4, Color3.fromRGB(240, 72, 84), 0.5, 0, zi)
		pz(c, 0.67, 0.38, 0.4, 0.4, Color3.fromRGB(240, 72, 84), 0.5, 0, zi)
		pz(c, 0.32, 0.36, 0.12, 0.12, Color3.new(1, 1, 1), 0.5, 0, zi + 1, false)
	elseif tipo == "gota" then
		pz(c, 0.5, 0.42, 0.4, 0.4, Color3.fromRGB(70, 150, 250), 0.15, 45, zi)
		pz(c, 0.5, 0.6, 0.56, 0.56, Color3.fromRGB(70, 150, 250), 0.5, 0, zi)
		pz(c, 0.4, 0.58, 0.12, 0.16, Color3.new(1, 1, 1), 0.5, 0, zi + 1, false)
	elseif tipo == "moneda" then
		pz(c, 0.5, 0.5, 0.78, 0.78, Color3.fromRGB(255, 205, 80), 0.5, 0, zi)
		pz(c, 0.5, 0.5, 0.48, 0.48, Color3.fromRGB(240, 170, 50), 0.5, 0, zi + 1)
		pz(c, 0.5, 0.5, 0.1, 0.3, Color3.fromRGB(255, 230, 140), 0.3, 0, zi + 2, false)
	end
	return c
end

--- Botón de dibujo: crece y se ladea al pasar el ratón, se hunde al pulsar. props.Icono pone un icono a la izquierda.
function Ui.boton(props: { [string]: any }, alPulsar: () -> ()): TextButton
	local b = Ui.crear("TextButton", props)
	b.AutoButtonColor = false
	b.Font = props.Font or Ui.Fuente
	b.TextColor3 = props.TextColor3 or Ui.Colores.texto
	b.TextScaled = true
	b.BorderSizePixel = 0
	b.BackgroundColor3 = props.BackgroundColor3 and Ui.apagar(props.BackgroundColor3) or Ui.Colores.panel
	Ui.esquinas(b, 6)
	Ui.borde(b, props.BorderColor or Ui.Colores.tinta, 3)
	degradado(b, 0.35)
	local izq = props.Icono and 44 or 10
	Ui.crear("UIPadding", { PaddingLeft = UDim.new(0, izq), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7), Parent = b })
	-- contorno del texto con el trazo clásico (el UIStroke ya se usa para el borde del botón)
	b.TextStrokeColor3 = Ui.Colores.tinta
	b.TextStrokeTransparency = 0
	if props.Icono then
		local ic = Ui.icono(props.Icono, b, UDim2.new(0, -38, 0.5, 0), UDim2.new(0, 32, 0, 32), b.ZIndex + 1)
		ic.AnchorPoint = Vector2.new(0, 0.5)
	end
	local escala = Ui.crear("UIScale", { Scale = 1, Parent = b })
	local okAudio, Audio = pcall(function()
		return require(script.Parent:WaitForChild("Audio")) :: any
	end)
	if okAudio then
		b.MouseEnter:Connect(function()
			Audio.sfx("hover", 0.3)
		end)
		b.Activated:Connect(function()
			Audio.sfx("click", 0.5)
		end)
	end
	b.MouseEnter:Connect(function()
		Ui.tween(escala, { Scale = 1.07 }, 0.18, Enum.EasingStyle.Back)
		Ui.tween(b, { Rotation = math.random() < 0.5 and -2 or 2 }, 0.18, Enum.EasingStyle.Back)
	end)
	b.MouseLeave:Connect(function()
		Ui.tween(escala, { Scale = 1 }, 0.2)
		Ui.tween(b, { Rotation = 0 }, 0.2)
	end)
	b.MouseButton1Down:Connect(function()
		Ui.tween(escala, { Scale = 0.92 }, 0.08)
	end)
	b.MouseButton1Up:Connect(function()
		Ui.tween(escala, { Scale = 1.07 }, 0.2, Enum.EasingStyle.Back)
	end)
	b.Activated:Connect(alPulsar)
	return b
end

--- Barra con relleno que se desliza suave (y una "estela" que baja más despacio, como en los RPG).
export type Barra = { marco: Frame, set: (actual: number, maximo: number, instantaneo: boolean?) -> () }
function Ui.barra(padre: Instance, pos: UDim2, tam: UDim2, color: Color3, conTexto: boolean?): Barra
	local marco = Ui.crear("Frame", { Position = pos, Size = tam, BackgroundColor3 = Color3.fromRGB(20, 16, 30), BorderSizePixel = 0, Parent = padre, ClipsDescendants = true })
	Ui.esquinas(marco, 999)
	Ui.borde(marco, Ui.Colores.tinta, 2.5)
	local estela = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.25, BorderSizePixel = 0, Parent = marco })
	Ui.esquinas(estela, 999)
	local relleno = Ui.crear("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Ui.apagar(color), BorderSizePixel = 0, Parent = marco })
	Ui.esquinas(relleno, 999)
	degradado(relleno, 0.3)
	-- brillo de dibujo arriba

	local etiqueta: TextLabel? = nil
	if conTexto then
		etiqueta = Ui.texto({ Size = UDim2.fromScale(1, 1), Text = "", TextColor3 = Color3.new(1, 1, 1), Parent = marco, ZIndex = 3 })
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

--- Hace aparecer un elemento con un pequeño rebote (escala 0,6 → 1).
function Ui.aparecer(o: GuiObject, retraso: number?)
	local escala = o:FindFirstChildOfClass("UIScale") or Ui.crear("UIScale", { Parent = o })
	escala.Scale = 0.6
	o.Visible = true
	task.delay(retraso or 0, function()
		Ui.tween(escala, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
	end)
end

return Ui
