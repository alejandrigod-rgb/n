--!strict
-- Construye el mundo de Vael en estilo 2D de recortes de papel: todo son piezas planas que miran a la cámara
-- (de lado), con contorno negro detrás, colores planos y capas de fondo para dar profundidad.
-- El mundo es una franja larga de izquierda a derecha:
--   Ciudad de Vael → Pradera → Pantano → Bosque → Ruinas → Cueva del Rey Hongo.
-- Si ya existe una carpeta "MundoVael" en Workspace (hecha a mano), no construye nada: solo busca las zonas.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Datos = require(ReplicatedStorage.Vael.Datos)

local Mundo = {}

-- dónde está la guarida de cada zona (en X; todas en el fondo del camino)
Mundo.Guaridas = { huerto = -262, pradera = 110, pantano = 215, bosque = 315, ruinas = 415, cueva = 540, picos = 662, cumbre = 772 }
Mundo.Inicio = -60 -- x de la plaza de la ciudad
Mundo.Aparicion = -395 -- se empieza en la Aldea de Brezo, a las afueras
Mundo.Limites = { -445, 805 }

local raiz: Folder
local pasto: Folder
local NEGRO = Datos.TINTA

local function nueva(clase: string, props: { [string]: any }, padre: Instance?): any
	local p = Instance.new(clase)
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = padre or raiz
	return p
end

local function base(p: BasePart)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
end

--- Rectángulo plano que mira a la cámara. (x, y) es el centro.
local function plano(x: number, y: number, z: number, w: number, h: number, color: Color3, borde: boolean?, padre: Instance?, giro: number?): Part
	local cf = CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(giro or 0))
	if borde ~= false then
		local b = Instance.new("Part")
		base(b)
		b.Size = Vector3.new(w + 0.5, h + 0.5, 0.2)
		b.CFrame = cf * CFrame.new(0, 0, -0.3)
		b.Color = NEGRO
		b.Parent = padre or raiz
	end
	local p = Instance.new("Part")
	base(p)
	p.Size = Vector3.new(w, h, 0.4)
	p.CFrame = cf
	p.Color = color
	p.Parent = padre or raiz
	return p
end

--- Círculo plano que mira a la cámara.
local function disco(x: number, y: number, z: number, d: number, color: Color3, borde: boolean?, padre: Instance?): Part
	local giro = CFrame.Angles(0, math.rad(90), 0)
	if borde ~= false then
		local b = Instance.new("Part")
		base(b)
		b.Shape = Enum.PartType.Cylinder
		b.Size = Vector3.new(0.2, d + 0.5, d + 0.5)
		b.CFrame = CFrame.new(x, y, z - 0.3) * giro
		b.Color = NEGRO
		b.Parent = padre or raiz
	end
	local p = Instance.new("Part")
	base(p)
	p.Shape = Enum.PartType.Cylinder
	p.Size = Vector3.new(0.4, d, d)
	p.CFrame = CFrame.new(x, y, z) * giro
	p.Color = color
	p.Parent = padre or raiz
	return p
end

--- Triángulo plano (dos cuñas) con la base en yBase. Con h negativo, apunta hacia abajo (banderines, estalactitas).
local function tri(x: number, yBase: number, z: number, w: number, h: number, color: Color3, borde: boolean?, padre: Instance?)
	local abajo = h < 0
	local alto = math.abs(h)
	local function mitad(dx: number, ang: number, ww: number, hh: number, zz: number, col: Color3, yb: number)
		local c = Instance.new("WedgePart")
		base(c)
		c.Size = Vector3.new(zz == z and 0.4 or 0.2, hh, ww / 2)
		if abajo then
			-- girada media vuelta: la cuña de cada lado pasa al lado contrario
			c.CFrame = CFrame.new(x - dx, yb - hh / 2, zz) * CFrame.Angles(0, 0, math.pi) * CFrame.Angles(0, math.rad(ang), 0)
		else
			c.CFrame = CFrame.new(x + dx, yb + hh / 2, zz) * CFrame.Angles(0, math.rad(ang), 0)
		end
		c.Color = col
		c.Parent = padre or raiz
	end
	if borde ~= false then
		local yb = abajo and yBase + 0.25 or yBase - 0.25
		mitad(-(w + 0.8) / 4, 90, w + 0.8, alto + 0.6, z - 0.3, NEGRO, yb)
		mitad((w + 0.8) / 4, -90, w + 0.8, alto + 0.6, z - 0.3, NEGRO, yb)
	end
	mitad(-w / 4, 90, w, alto, z, color, yBase)
	mitad(w / 4, -90, w, alto, z, color, yBase)
end

--- Cartel de texto pintado sobre una tabla.
local function letrero(x: number, y: number, z: number, w: number, h: number, texto: string, fondo: Color3, colorTexto: Color3?, padre: Instance?): Part
	local p = plano(x, y, z, w, h, fondo, true, padre)
	local sg = nueva("SurfaceGui", { Face = Enum.NormalId.Back, SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud, PixelsPerStud = 40, LightInfluence = 0 }, p)
	local t = nueva("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = texto, Font = Enum.Font.FredokaOne, TextScaled = true, TextColor3 = colorTexto or Color3.new(1, 1, 1) }, sg)
	nueva("UIStroke", { Thickness = 3, Color = NEGRO }, t)
	nueva("UIPadding", { PaddingLeft = UDim.new(0.06, 0), PaddingRight = UDim.new(0.06, 0), PaddingTop = UDim.new(0.1, 0), PaddingBottom = UDim.new(0.1, 0) }, t)
	return p
end

--- Un grupo (Model) que el cliente anima: se balancea desde la base (pasto, flores) o gira.
local function grupoBalanceo(x: number, z: number): Model
	local m = Instance.new("Model")
	m.Parent = pasto
	m.WorldPivot = CFrame.new(x, 0, z)
	return m
end

local VERDES = { Color3.fromRGB(96, 178, 70), Color3.fromRGB(120, 200, 80), Color3.fromRGB(78, 150, 62) }

local function mata(x: number, z: number, escala: number, rng: Random, tono: Color3?)
	local m = grupoBalanceo(x, z)
	for k = -1, 1 do
		local alto = (1.3 + rng:NextNumber(0, 0.9)) * escala
		local color = tono or VERDES[rng:NextInteger(1, #VERDES)]
		local p = Instance.new("Part")
		base(p)
		p.Size = Vector3.new(0.38 * escala, alto, 0.15)
		p.CFrame = CFrame.new(x + k * 0.32 * escala, 0, z) * CFrame.Angles(0, 0, math.rad(-k * 18 + rng:NextNumber(-6, 6))) * CFrame.new(0, alto / 2, 0)
		p.Color = color
		p.Parent = m
	end
end

local COLORES_FLOR = { Color3.fromRGB(255, 220, 80), Color3.fromRGB(245, 120, 165), Color3.new(1, 1, 1), Color3.fromRGB(160, 130, 245), Color3.fromRGB(255, 140, 70) }

local function flor(x: number, z: number, escala: number, rng: Random)
	local m = grupoBalanceo(x, z)
	local alto = (1.4 + rng:NextNumber(0, 1)) * escala
	plano(x, alto / 2, z, 0.18 * escala, alto, Color3.fromRGB(70, 140, 60), false, m)
	plano(x + 0.35 * escala, alto * 0.45, z + 0.05, 0.6 * escala, 0.25 * escala, Color3.fromRGB(80, 160, 70), false, m, 25)
	disco(x, alto, z + 0.1, 1.1 * escala, COLORES_FLOR[rng:NextInteger(1, #COLORES_FLOR)], true, m)
	disco(x, alto, z + 0.35, 0.45 * escala, Color3.fromRGB(255, 200, 60), false, m)
end

local function arbol(x: number, z: number, escala: number, copa: Color3?)
	local s = escala
	plano(x, 3.2 * s, z, 1.4 * s, 6.4 * s, Color3.fromRGB(120, 80, 50))
	local c = copa or Color3.fromRGB(80, 160, 70)
	disco(x - 2 * s, 7 * s, z + 0.2, 5 * s, c)
	disco(x + 2 * s, 7.3 * s, z + 0.4, 5 * s, c:Lerp(Color3.new(0, 0, 0), 0.08))
	disco(x, 9 * s, z + 0.6, 5.6 * s, c:Lerp(Color3.new(1, 1, 1), 0.08))
	disco(x - 1 * s, 9.6 * s, z + 0.8, 1.2 * s, c:Lerp(Color3.new(1, 1, 1), 0.35), false)
end

local function pino(x: number, z: number, escala: number, color: Color3?)
	local s = escala
	local c = color or Color3.fromRGB(45, 110, 70)
	plano(x, 1.5 * s, z, 1.2 * s, 3 * s, Color3.fromRGB(100, 70, 45))
	tri(x, 2.5 * s, z + 0.1, 8 * s, 5 * s, c)
	tri(x, 5.2 * s, z + 0.3, 6.4 * s, 4.6 * s, c:Lerp(Color3.new(1, 1, 1), 0.06))
	tri(x, 7.8 * s, z + 0.5, 4.6 * s, 4.2 * s, c:Lerp(Color3.new(1, 1, 1), 0.12))
end

local function farola(x: number, z: number): Part
	plano(x, 4.5, z, 0.6, 9, Color3.fromRGB(50, 50, 60))
	plano(x, 9.2, z + 0.2, 1.8, 0.5, Color3.fromRGB(50, 50, 60))
	local luz = disco(x, 9.9, z + 0.3, 1.5, Color3.fromRGB(255, 225, 120))
	luz.Material = Enum.Material.Neon
	return luz
end

local function casa(x: number, z: number, w: number, h: number, pared: Color3, techo: Color3, cartel: string?, rng: Random)
	plano(x, h / 2, z, w, h, pared)
	-- vigas de madera (estilo de cuento)
	plano(x, h - 0.3, z + 0.25, w, 0.5, Color3.fromRGB(110, 70, 45), false)
	plano(x, 0.3, z + 0.25, w, 0.6, Color3.fromRGB(110, 70, 45), false)
	-- tejado y chimenea
	plano(x + w * 0.25, h + h * 0.45, z - 0.5, 1.6, 3.5, Color3.fromRGB(150, 90, 70))
	tri(x, h - 0.2, z + 0.1, w + 3, h * 0.6, techo)
	-- puerta
	plano(x - w * 0.18, 2, z + 0.3, 2.4, 4, Color3.fromRGB(120, 75, 45))
	disco(x - w * 0.18 + 0.7, 2, z + 0.6, 0.35, Color3.fromRGB(240, 200, 80), false)
	-- ventanas iluminadas con cruz
	local function ventana(vx: number, vy: number)
		plano(vx, vy, z + 0.3, 2.2, 2.2, Color3.fromRGB(255, 225, 140))
		plano(vx, vy, z + 0.6, 2.2, 0.2, Color3.fromRGB(110, 70, 45), false)
		plano(vx, vy, z + 0.6, 0.2, 2.2, Color3.fromRGB(110, 70, 45), false)
		plano(vx, vy - 1.3, z + 0.6, 2.8, 0.4, Color3.fromRGB(110, 70, 45), false)
		-- jardinera con flores
		if rng:NextNumber() < 0.6 then
			for k = -1, 1 do
				disco(vx + k * 0.7, vy - 1.15, z + 0.8, 0.55, COLORES_FLOR[rng:NextInteger(1, #COLORES_FLOR)], false)
			end
		end
	end
	ventana(x + w * 0.2, h * 0.38)
	if h > 9 then
		ventana(x - w * 0.18, h * 0.75)
		ventana(x + w * 0.2, h * 0.75)
	end
	if cartel then
		letrero(x - w * 0.18, 5.2, z + 0.7, math.max(5, #cartel * 0.75), 1.6, cartel, Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 240, 200))
	end
end

local function nube(x: number, y: number, z: number, escala: number, velocidad: number)
	local m = Instance.new("Model")
	m.Name = "Nube"
	m:SetAttribute("Nube", velocidad)
	m.Parent = raiz
	disco(x, y, z, 6 * escala, Color3.new(1, 1, 1), true, m)
	disco(x + 4 * escala, y - 0.6 * escala, z + 0.2, 4.6 * escala, Color3.new(1, 1, 1), false, m)
	disco(x - 4 * escala, y - 0.8 * escala, z + 0.2, 4 * escala, Color3.new(1, 1, 1), false, m)
	plano(x, y - 1.9 * escala, z + 0.1, 11 * escala, 2 * escala, Color3.new(1, 1, 1), false, m)
end

local function guarida(z: any)
	local x = Mundo.Guaridas[z.id]
	-- zona invisible: al entrar, empieza el combate (está al fondo, el camino de delante queda libre)
	local caja = Instance.new("Part")
	base(caja)
	caja.Name = "Zona_" .. z.id
	caja.Size = Vector3.new(10, 12, 4.5)
	caja.Position = Vector3.new(x, 6, -10.2)
	caja.Transparency = 1
	caja:SetAttribute("Zona", z.id)
	caja.Parent = raiz
	-- marca en el suelo con el color de la zona
	local marca = plano(x, 0.08, -10.2, 11, 0.12, z.color, false)
	marca.Size = Vector3.new(11, 0.12, 4.5)
	marca.Material = Enum.Material.Neon
	marca.Transparency = 0.45
	-- cartel con flecha
	plano(x - 9, 3, -10.5, 0.7, 6, Color3.fromRGB(120, 80, 50))
	letrero(x - 9, 6.4, -10.2, 9, 2.2, z.nombre, z.color:Lerp(NEGRO, 0.35))
	letrero(x - 9, 4.4, -10.2, 6, 1.4, "Nivel " .. z.nivel, Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 230, 150))
	-- aviso flotante
	local bb = nueva("BillboardGui", { Size = UDim2.fromOffset(220, 60), StudsOffset = Vector3.new(0, 7.5, 0), MaxDistance = 90, LightInfluence = 0 }, caja)
	local t = nueva("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "¡Monstruos!\nentra para luchar", Font = Enum.Font.FredokaOne, TextScaled = true, TextColor3 = Color3.fromRGB(255, 235, 120) }, bb)
	nueva("UIStroke", { Thickness = 3, Color = NEGRO }, t)
	return caja
end

-- ===================== CONSTRUCCIÓN =====================
local function luces()
	-- luz plana y suave, como un escenario de cartulina: sin resplandores ni contraste fuerte
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(200, 194, 184)
		Lighting.OutdoorAmbient = Color3.fromRGB(205, 198, 188)
		Lighting.Brightness = 1.1
		Lighting.ClockTime = 14
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0
		Lighting.ExposureCompensation = 0
	end)
	for _, e in Lighting:GetChildren() do
		pcall(function()
			if e:IsA("BloomEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("BlurEffect") then
				(e :: any).Enabled = false
			elseif e:IsA("Atmosphere") then
				e.Density = 0
				e.Haze = 0
				e.Glare = 0
			elseif e:IsA("ColorCorrectionEffect") then
				e:Destroy()
			end
		end)
	end
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "Cartulina"
	cc.Saturation = 0.08
	cc.Contrast = -0.04
	cc.Brightness = 0.02
	cc.TintColor = Color3.fromRGB(255, 246, 230)
	cc.Parent = Lighting
end

local function cielo()
	local fondo = Instance.new("Part")
	base(fondo)
	fondo.Name = "Cielo"
	fondo.Size = Vector3.new(3000, 700, 1)
	fondo.Position = Vector3.new(205, 120, -260)
	fondo.Color = Color3.fromRGB(150, 210, 250)
	fondo.Parent = raiz
	local sg = nueva("SurfaceGui", { Face = Enum.NormalId.Back, SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud, PixelsPerStud = 1, LightInfluence = 0 }, fondo)
	local f = nueva("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) }, sg)
	nueva("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 180, 200)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(190, 210, 215)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 225, 210)),
		}),
	}, f)
	local sol = disco(-20, 95, -240, 34, Color3.fromRGB(255, 220, 90))
	sol.Material = Enum.Material.Neon
	disco(-20, 95, -241, 46, Color3.fromRGB(255, 240, 170), false).Transparency = 0.5
end

local function fondoLejano(rng: Random)
	-- montañas azuladas con nieve
	local x = -580
	while x < 820 do
		local w = rng:NextNumber(130, 210)
		local h = rng:NextNumber(70, 120)
		tri(x, -5, -170, w, h, Color3.fromRGB(150, 165, 205))
		tri(x, -5 + h * 0.72, -169.4, w * 0.28, h * 0.28, Color3.new(1, 1, 1), false)
		x += w * 0.6
	end
	-- colinas lejanas y cercanas
	x = -560
	while x < 800 do
		disco(x, -30, -110, rng:NextNumber(90, 130), Color3.fromRGB(135, 200, 120))
		x += rng:NextNumber(55, 80)
	end
	x = -550
	while x < 800 do
		if x < 440 then
			disco(x, -22, -60, rng:NextNumber(55, 75), Color3.fromRGB(105, 180, 90))
		end
		x += rng:NextNumber(38, 55)
	end
	for _ = 1, 16 do
		nube(rng:NextNumber(-560, 800), rng:NextNumber(48, 80), rng:NextNumber(-140, -95), rng:NextNumber(1, 1.8), rng:NextNumber(0.6, 1.6))
	end
end

local function suelo()
	local s = Instance.new("Part")
	base(s)
	s.Name = "Suelo"
	s.CanCollide = true
	s.CanQuery = true
	s.Size = Vector3.new(1290, 4, 70)
	s.Position = Vector3.new(175, -1.95, -21)
	s.Color = Color3.fromRGB(112, 190, 82)
	s.Parent = raiz
	-- borde delantero de tierra (el corte del papel)
	plano(175, -6, 14.6, 1290, 12, Color3.fromRGB(125, 85, 55))
	plano(175, -0.3, 14.9, 1290, 1, Color3.fromRGB(85, 155, 62), false)
	for k = 0, 122 do
		disco(-460 + k * 10.6, -4 - (k % 3) * 2.5, 15, 1.2 + (k % 4) * 0.4, Color3.fromRGB(100, 68, 45), false)
	end
	-- camino de tierra
	local camino = plano(175, 0.06, 1, 1290, 0.1, Color3.fromRGB(225, 200, 140), false)
	camino.Size = Vector3.new(1290, 0.1, 6)
	-- paredes invisibles para quedarse en el carril (como en un juego 2D con algo de fondo)
	for _, datos in { { 175, -12.8, 1290, 1 }, { 175, 10.8, 1290, 1 } } do
		local muro = Instance.new("Part")
		base(muro)
		muro.CanCollide = true
		muro.Transparency = 1
		muro.Size = Vector3.new(datos[3], 40, datos[4])
		muro.Position = Vector3.new(datos[1], 20, datos[2])
		muro.Parent = raiz
	end
	for _, x in Mundo.Limites do
		local muro = Instance.new("Part")
		base(muro)
		muro.CanCollide = true
		muro.Transparency = 1
		muro.Size = Vector3.new(1, 40, 30)
		muro.Position = Vector3.new(x, 20, 0)
		muro.Parent = raiz
	end
	-- manchas de suelo por zona
	local function mancha(x0: number, x1: number, color: Color3)
		local p = plano((x0 + x1) / 2, 0.04, -21, x1 - x0, 0.08, color, false)
		p.Size = Vector3.new(x1 - x0, 0.08, 66)
	end
	mancha(165, 262, Color3.fromRGB(105, 140, 85))
	mancha(262, 362, Color3.fromRGB(80, 150, 70))
	mancha(362, 462, Color3.fromRGB(165, 155, 120))
	mancha(462, 606, Color3.fromRGB(110, 105, 100))
	mancha(606, 820, Color3.fromRGB(232, 238, 245)) -- nieve de los Picos
end

local function ciudad(rng: Random): (BasePart, BasePart)
	-- muralla del fondo con almenas
	plano(-80, 6, -27, 230, 12, Color3.fromRGB(175, 165, 150))
	for k = 0, 57 do
		plano(-193 + k * 4, 12.8, -27, 2.2, 2, Color3.fromRGB(175, 165, 150))
	end
	for k = 0, 22 do
		plano(-190 + k * 10, 3 + (k % 2) * 4, -26.5, 3, 1.4, Color3.fromRGB(150, 140, 128), false)
	end
	-- torre del reloj
	plano(-60, 14, -23, 9, 28, Color3.fromRGB(205, 185, 160))
	tri(-60, 28, -22.8, 12, 9, Color3.fromRGB(70, 90, 150))
	disco(-60, 22, -22.5, 6, Color3.fromRGB(250, 245, 230))
	plano(-60, 22.9, -22.1, 0.35, 2, NEGRO, false)
	plano(-59.4, 22, -22.1, 1.5, 0.35, NEGRO, false)
	plano(-60, 9, -22.5, 3, 5, Color3.fromRGB(120, 75, 45))
	-- casas
	local paredes = { Color3.fromRGB(245, 230, 195), Color3.fromRGB(205, 225, 240), Color3.fromRGB(240, 205, 195), Color3.fromRGB(215, 235, 200), Color3.fromRGB(240, 220, 160) }
	local techos = { Color3.fromRGB(195, 75, 60), Color3.fromRGB(70, 110, 170), Color3.fromRGB(150, 80, 140), Color3.fromRGB(80, 140, 90) }
	local carteles = { [-170] = "Herrería", [-140] = "Panadería", [-100] = "Taberna", [-20] = "Posada", [12] = "Magia" }
	for _, x in { -170, -140, -118, -100, -36, -20, 12 } do
		local w = rng:NextNumber(12, 16)
		local h = x == -100 and 13 or rng:NextNumber(8, 12)
		casa(x, -19 + rng:NextNumber(-1.5, 1), w, h, paredes[rng:NextInteger(1, #paredes)], techos[rng:NextInteger(1, #techos)], carteles[x], rng)
	end
	-- farolas y banderines
	for x = -180, 30, 21 do
		farola(x, -11.5)
	end
	for x = -178, 28, 2.2 do
		local col = COLORES_FLOR[(math.floor(x) % #COLORES_FLOR) + 1]
		tri(x, 8.2 + math.sin(x * 0.29) * 0.4, -11.2, 1.4, -1.6, col, false)
	end
	-- árboles y arbustos
	for _, x in { -186, -155, -128, -84, -45, 0, 28 } do
		arbol(x, -14 + rng:NextNumber(-1, 0.5), rng:NextNumber(0.8, 1.1))
	end
	for x = -188, 36, 7 do
		disco(x + rng:NextNumber(-2, 2), 1, -12.4, rng:NextNumber(2.2, 3.4), Color3.fromRGB(85, 160, 70))
	end
	-- barriles, cajas y bancos
	for _, x in { -162, -108, -30, 4 } do
		plano(x, 1.2, -10.5, 2, 2.4, Color3.fromRGB(150, 100, 60))
		plano(x, 1.8, -10.2, 2.1, 0.25, Color3.fromRGB(90, 90, 100), false)
		plano(x, 0.6, -10.2, 2.1, 0.25, Color3.fromRGB(90, 90, 100), false)
		plano(x + 2.4, 1, -10.4, 2, 2, Color3.fromRGB(190, 145, 90))
	end
	for _, x in { -148, -76, -44 } do
		plano(x, 1.3, -10.6, 4, 0.5, Color3.fromRGB(140, 90, 55))
		plano(x - 1.5, 0.6, -10.8, 0.4, 1.2, Color3.fromRGB(110, 70, 45))
		plano(x + 1.5, 0.6, -10.8, 0.4, 1.2, Color3.fromRGB(110, 70, 45))
	end
	-- fuente de la plaza (cura): pila de piedra, agua y chorros
	local x = Mundo.Inicio + 14
	plano(x, 1.3, -7, 13, 2.6, Color3.fromRGB(175, 175, 190))
	plano(x, 4, -7.6, 2, 6, Color3.fromRGB(175, 175, 190))
	disco(x, 7.2, -7.4, 4.2, Color3.fromRGB(175, 175, 190))
	local agua = plano(x, 2.5, -6.7, 12, 0.6, Color3.fromRGB(90, 190, 235), false)
	agua.Material = Enum.Material.Neon
	agua.Transparency = 0.2
	local m = Instance.new("Model")
	m.Name = "Chorros"
	m:SetAttribute("Chorro", true)
	m.Parent = raiz
	for k = -1, 1 do
		local c = disco(x + k * 1.6, 8.6 - math.abs(k) * 0.8, -7.2, 1.1, Color3.fromRGB(160, 225, 250), false, m)
		c.Transparency = 0.15
	end
	local fuente = Instance.new("Part")
	base(fuente)
	fuente.Name = "Fuente"
	fuente.Size = Vector3.new(13, 8, 7)
	fuente.Position = Vector3.new(x, 4, -7)
	fuente.Transparency = 1
	fuente:SetAttribute("Fuente", true)
	fuente.Parent = raiz
	letrero(x, 11.3, -7.8, 10, 1.8, "Fuente de Vael · cura", Color3.fromRGB(60, 130, 200))
	-- puesto del mercader (toldo de rayas)
	local mx = Mundo.Inicio + 34
	local mostrador = plano(mx, 1.6, -9, 9, 3.2, Color3.fromRGB(160, 105, 60))
	mostrador:SetAttribute("Mercader", true)
	mostrador.CanQuery = true
	plano(mx - 4.2, 4, -9.4, 0.5, 8, Color3.fromRGB(110, 70, 45))
	plano(mx + 4.2, 4, -9.4, 0.5, 8, Color3.fromRGB(110, 70, 45))
	for k = 0, 5 do
		plano(mx - 4.5 + k * 1.8 + 0.9, 7.6, -8.8, 1.8, 1.6, k % 2 == 0 and Color3.fromRGB(220, 60, 60) or Color3.new(1, 1, 1), false)
	end
	for k = 0, 5 do
		disco(mx - 4.5 + k * 1.8 + 0.9, 6.8, -8.7, 1.8, k % 2 == 0 and Color3.fromRGB(220, 60, 60) or Color3.new(1, 1, 1), false)
	end
	for k = -1, 1 do
		disco(mx + k * 2.4, 3.6, -8.6, 1.3, k == 0 and Color3.fromRGB(90, 160, 240) or Color3.fromRGB(230, 70, 80))
		plano(mx + k * 2.4, 4.5, -8.6, 0.5, 0.8, Color3.fromRGB(200, 200, 210))
	end
	letrero(mx, 9.4, -8.8, 8, 1.8, "Mercader", Color3.fromRGB(200, 120, 40))
	-- puerta de la ciudad
	plano(40, 9, -13, 5, 18, Color3.fromRGB(170, 160, 145))
	plano(40, 9, 9.5, 5, 18, Color3.fromRGB(170, 160, 145))
	tri(40, 18, -12.8, 7, 5, Color3.fromRGB(70, 90, 150))
	letrero(40, 15, -12.6, 6, 2, "VAEL", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 230, 150))
	return fuente, mostrador
end

local function pradera(rng: Random)
	-- molino (las aspas giran en el cliente)
	plano(78, 9, -24, 8, 18, Color3.fromRGB(240, 230, 210))
	tri(78, 18, -23.8, 10, 6, Color3.fromRGB(195, 75, 60))
	plano(78, 3, -23.5, 2.4, 4, Color3.fromRGB(120, 75, 45))
	local aspas = Instance.new("Model")
	aspas.Name = "Aspas"
	aspas:SetAttribute("Gira", 0.8)
	aspas.Parent = raiz
	for k = 0, 3 do
		local a = math.rad(k * 90)
		local p = plano(78 + math.cos(a) * 5, 15 + math.sin(a) * 5, -22.8, 10, 1.8, Color3.fromRGB(230, 220, 190), true, aspas, k * 90)
		p.Name = "Aspa"
	end
	disco(78, 15, -22.4, 1.6, Color3.fromRGB(120, 75, 45), true, aspas)
	aspas.WorldPivot = CFrame.new(78, 15, -22.6)
	-- vallas y heno
	for x = 50, 158, 4 do
		plano(x, 1.4, -11.8, 0.5, 2.8, Color3.fromRGB(200, 160, 110))
	end
	plano(104, 2, -11.6, 108, 0.4, Color3.fromRGB(200, 160, 110), false)
	plano(104, 1, -11.6, 108, 0.4, Color3.fromRGB(200, 160, 110), false)
	for _, x in { 64, 140 } do
		disco(x, 2, -15, 4, Color3.fromRGB(235, 200, 100))
		plano(x, 1, -14.6, 4, 2, Color3.fromRGB(235, 200, 100), false)
	end
	for _, x in { 55, 96, 128, 152 } do
		arbol(x, -17 + rng:NextNumber(-3, 0), rng:NextNumber(0.9, 1.3))
	end
	-- guarida: un arbusto enorme con ojos que miran
	local gx = Mundo.Guaridas.pradera
	disco(gx - 3, 3.5, -11, 7, Color3.fromRGB(70, 145, 60))
	disco(gx + 3, 3.8, -11.2, 7.5, Color3.fromRGB(80, 155, 65))
	disco(gx, 5.8, -11.4, 7, Color3.fromRGB(90, 165, 70))
	for _, o in { { -2.5, 4.8 }, { 2.2, 6.2 }, { 0.5, 3 } } do
		disco(gx + o[1] - 0.4, o[2], -10.4, 0.7, Color3.new(1, 1, 1), false)
		disco(gx + o[1] + 0.4, o[2], -10.4, 0.7, Color3.new(1, 1, 1), false)
	end
	for _ = 1, 60 do
		flor(rng:NextNumber(45, 165), rng:NextNumber(-11, -4), rng:NextNumber(0.7, 1.1), rng)
	end
end

local function pantano(rng: Random)
	for _, d in { { 185, 14 }, { 240, 18 } } do
		local p = plano(d[1], 0.1, -9, d[2], 0.1, Color3.fromRGB(70, 110, 100), false)
		p.Size = Vector3.new(d[2], 0.1, 5)
		for _ = 1, 4 do
			disco(d[1] + rng:NextNumber(-d[2] / 2.5, d[2] / 2.5), 0.4, rng:NextNumber(-10, -7), 1.6, Color3.fromRGB(110, 180, 90))
		end
	end
	-- juncos y árboles muertos
	for _ = 1, 30 do
		local x = rng:NextNumber(165, 262)
		local z = rng:NextNumber(-12, -5)
		local m = grupoBalanceo(x, z)
		local h = rng:NextNumber(3, 5)
		plano(x, h / 2, z, 0.25, h, Color3.fromRGB(110, 140, 70), false, m)
		plano(x, h - 0.5, z + 0.1, 0.5, 1.4, Color3.fromRGB(110, 70, 45), true, m)
	end
	for _, x in { 172, 200, 232, 255 } do
		local z = -16 + rng:NextNumber(-3, 1)
		plano(x, 5, z, 1.4, 10, Color3.fromRGB(90, 75, 70))
		plano(x - 1.8, 8, z + 0.1, 4, 0.7, Color3.fromRGB(90, 75, 70), true, nil, 35)
		plano(x + 1.6, 6.5, z + 0.1, 3.4, 0.6, Color3.fromRGB(90, 75, 70), true, nil, -30)
	end
	-- niebla que se mueve (cliente)
	for _ = 1, 8 do
		local n = plano(rng:NextNumber(165, 262), rng:NextNumber(1.2, 3), rng:NextNumber(-14, -6), rng:NextNumber(14, 24), rng:NextNumber(1.5, 3), Color3.fromRGB(230, 240, 240), false)
		n.Transparency = 0.55
		n:SetAttribute("Niebla", rng:NextNumber(0.5, 1.5))
	end
	-- guarida: charca oscura con burbujas
	local gx = Mundo.Guaridas.pantano
	plano(gx, 0.15, -8.5, 10, 0.1, Color3.fromRGB(45, 70, 70), false).Size = Vector3.new(10, 0.1, 5)
	plano(gx, 1.2, -11.2, 12, 2.4, Color3.fromRGB(60, 90, 85))
	for k = -2, 2 do
		disco(gx + k * 2, 2.6 + (k % 2) * 0.6, -10.8, 0.9, Color3.fromRGB(150, 200, 180))
	end
end

local function bosque(rng: Random)
	for _ = 1, 26 do
		pino(rng:NextNumber(262, 362), rng:NextNumber(-34, -14), rng:NextNumber(1.1, 1.9))
	end
	for _ = 1, 10 do
		pino(rng:NextNumber(262, 362), rng:NextNumber(-13, -12), rng:NextNumber(0.6, 0.9), Color3.fromRGB(60, 130, 80))
	end
	for _ = 1, 14 do
		local x = rng:NextNumber(262, 362)
		plano(x, 0.5, -10, 0.4, 1, Color3.fromRGB(240, 230, 210))
		disco(x, 1.1, -9.8, 1.4, Color3.fromRGB(215, 70, 60))
	end
	-- guarida: tronco hueco gigante
	local gx = Mundo.Guaridas.bosque
	plano(gx, 4, -11, 12, 8, Color3.fromRGB(120, 80, 50))
	disco(gx, 3.6, -10.6, 6, Color3.fromRGB(35, 25, 25))
	for k = -2, 2 do
		plano(gx + k * 2.4, 8.2, -10.7, 0.4, 0.9, Color3.fromRGB(90, 60, 40), false)
	end
	disco(gx - 1, 3.8, -10.2, 0.6, Color3.fromRGB(255, 220, 80), false)
	disco(gx + 1, 3.8, -10.2, 0.6, Color3.fromRGB(255, 220, 80), false)
end

local function ruinas(rng: Random)
	for _, x in { 372, 392, 438, 455 } do
		local h = rng:NextNumber(6, 15)
		local z = -15 + rng:NextNumber(-4, 2)
		plano(x, h / 2, z, 3, h, Color3.fromRGB(190, 180, 165))
		plano(x, h + 0.4, z + 0.1, 4, 1, Color3.fromRGB(170, 160, 145))
		plano(x + 0.4, h * 0.6, z + 0.3, 0.2, h * 0.3, Color3.fromRGB(120, 110, 100), false, nil, 20)
	end
	-- arco roto
	plano(404, 7, -20, 3, 14, Color3.fromRGB(185, 175, 160))
	plano(426, 5, -20, 3, 10, Color3.fromRGB(185, 175, 160))
	plano(411, 14.5, -19.8, 18, 2.4, Color3.fromRGB(175, 165, 150), true, nil, -4)
	for _ = 1, 8 do
		plano(rng:NextNumber(365, 460), 0.7, rng:NextNumber(-12, -9), rng:NextNumber(1.5, 3), 1.4, Color3.fromRGB(165, 155, 140), true, nil, rng:NextNumber(-20, 20))
	end
	for _ = 1, 6 do
		local x = rng:NextNumber(365, 460)
		local c = plano(x, 1.2, -10.4, 0.9, 2.4, Color3.fromRGB(180, 120, 240), true, nil, rng:NextNumber(-15, 15))
		c.Material = Enum.Material.Neon
	end
	-- guarida: puerta de cripta
	local gx = Mundo.Guaridas.ruinas
	plano(gx, 5, -11.4, 10, 10, Color3.fromRGB(150, 140, 130))
	plano(gx, 3.5, -11, 5, 7, Color3.fromRGB(30, 25, 35))
	tri(gx, 10, -11.2, 12, 3, Color3.fromRGB(130, 120, 110))
	disco(gx - 0.8, 4.5, -10.6, 0.5, Color3.fromRGB(255, 80, 80), false)
	disco(gx + 0.8, 4.5, -10.6, 0.5, Color3.fromRGB(255, 80, 80), false)
end

local function cueva(rng: Random)
	-- la montaña de roca donde vive el Rey Hongo
	tri(540, 0, -16, 120, 46, Color3.fromRGB(110, 100, 105))
	tri(505, 0, -15, 60, 30, Color3.fromRGB(125, 115, 118))
	tri(585, 0, -15, 70, 34, Color3.fromRGB(100, 92, 98))
	local gx = Mundo.Guaridas.cueva
	disco(gx, 2, -11.5, 13, Color3.fromRGB(25, 20, 25))
	for k = -2, 2 do
		tri(gx + k * 2.6, 8.4, -11, 1.6, -2.4, Color3.fromRGB(110, 100, 105), true)
	end
	disco(gx - 1.4, 4, -11, 0.9, Color3.fromRGB(255, 220, 70), false).Material = Enum.Material.Neon
	disco(gx + 1.4, 4, -11, 0.9, Color3.fromRGB(255, 220, 70), false).Material = Enum.Material.Neon
	letrero(gx, 16, -11, 12, 2.4, "¡Cuidado! Rey Hongo", Color3.fromRGB(160, 40, 40))
	-- hongos brillantes
	for _ = 1, 14 do
		local x = rng:NextNumber(465, 600)
		if math.abs(x - gx) > 8 then
			local s = rng:NextNumber(0.7, 1.4)
			plano(x, 0.7 * s, -10.5, 0.5 * s, 1.4 * s, Color3.fromRGB(240, 230, 210))
			local cap = disco(x, 1.5 * s, -10.3, 1.8 * s, ({ Color3.fromRGB(120, 220, 255), Color3.fromRGB(200, 120, 255), Color3.fromRGB(255, 120, 120) })[rng:NextInteger(1, 3)])
			cap.Material = Enum.Material.Neon
		end
	end
end

local function pastoPorTodas(rng: Random)
	for _ = 1, 260 do
		local x = rng:NextNumber(-440, 600)
		if not (x > 462) then
			mata(x, rng:NextNumber(-12, -3), rng:NextNumber(0.8, 1.2), rng)
		end
	end
	-- primer plano (más grande, delante del camino)
	for _ = 1, 170 do
		local x = rng:NextNumber(-440, 600)
		local tono = x > 462 and Color3.fromRGB(90, 110, 90) or nil
		mata(x, rng:NextNumber(5, 10), rng:NextNumber(1.1, 1.7), rng, tono)
	end
	for _ = 1, 50 do
		local x = rng:NextNumber(-440, 360)
		flor(x, rng:NextNumber(6, 10), rng:NextNumber(0.9, 1.3), rng)
	end
end


-- ===================== EXPLORACIÓN (barreras, plataformas, secretos e interiores) =====================
--- Punto con el que se interactúa (el servidor le pone el aviso). nombre identifica qué es.
local function punto(nombre: string, pos: Vector3, extra: { [string]: any }?): Part
	local p = Instance.new("Part")
	base(p)
	p.Name = "Punto_" .. nombre
	p.Size = Vector3.new(2, 3, 2)
	p.Position = pos
	p.Transparency = 1
	p:SetAttribute("Punto", nombre)
	if extra then
		for k, v in extra do
			p:SetAttribute(k, v)
		end
	end
	p.Parent = raiz
	return p
end

--- Tabla sólida (se puede pisar). y = altura de la parte de arriba.
local function tabla(x: number, y: number, z: number, w: number, color: Color3?)
	local col = color or Color3.fromRGB(150, 100, 60)
	local p = plano(x, y - 0.45, z, w, 0.9, col)
	p.CanCollide = true
	p.CanQuery = true
	p.Size = Vector3.new(w, 0.9, 6)
	p.CFrame = CFrame.new(x, y - 0.45, z)
	-- vetas
	plano(x - w * 0.2, y - 0.45, z + 3.05, w * 0.3, 0.12, col:Lerp(NEGRO, 0.3), false)
	plano(x + w * 0.25, y - 0.3, z + 3.05, w * 0.25, 0.12, col:Lerp(NEGRO, 0.3), false)
end

--- Barrera con dos versiones: "cerrado" (bloquea hasta tener la llave) y "abierto". Las muestra el cliente.
local function barrera(llave: string, x: number): (Model, Model)
	local cerrado = Instance.new("Model")
	cerrado.Name = "Barrera_" .. llave
	cerrado:SetAttribute("Llave", llave)
	cerrado:SetAttribute("Estado", "cerrado")
	cerrado:SetAttribute("MuroX", x)
	cerrado.Parent = raiz
	local abierto = Instance.new("Model")
	abierto.Name = "Paso_" .. llave
	abierto:SetAttribute("Llave", llave)
	abierto:SetAttribute("Estado", "abierto")
	abierto.Parent = raiz
	return cerrado, abierto
end

local function cofre(x: number, y: number, z: number, padre: Instance?)
	plano(x, y + 0.8, z, 3, 1.6, Color3.fromRGB(160, 100, 55), true, padre)
	plano(x, y + 2, z - 0.05, 3.2, 1, Color3.fromRGB(190, 120, 60), true, padre)
	plano(x, y + 1.5, z + 0.3, 3.1, 0.3, Color3.fromRGB(240, 200, 70), false, padre)
	plano(x, y + 1.2, z + 0.35, 0.6, 0.7, Color3.fromRGB(240, 200, 70), true, padre)
end

local function exploracion(rng: Random)
	-- 1) El río con el puente roto (Pradera → Pantano): hace falta la CUERDA
	local rio = plano(166, 0.1, -1, 10, 0.1, Color3.fromRGB(80, 170, 230), false)
	rio.Size = Vector3.new(10, 0.12, 26)
	rio.Material = Enum.Material.Neon
	rio.Transparency = 0.25
	for k = -1, 1 do
		disco(166 + k * 3, 0.3, 8 - k * 5, 0.8, Color3.new(1, 1, 1), false).Transparency = 0.3
	end
	local cerrado, abierto = barrera("cuerda", 163)
	plano(161, 2, -1, 0.7, 4, Color3.fromRGB(120, 80, 50), true, cerrado)
	plano(171, 2, -1, 0.7, 4, Color3.fromRGB(120, 80, 50), true, cerrado)
	plano(162.8, 0.6, -0.8, 3, 0.5, Color3.fromRGB(160, 110, 65), true, cerrado, -25)
	plano(169.2, 0.6, -0.8, 3, 0.5, Color3.fromRGB(160, 110, 65), true, cerrado, 25)
	letrero(159, 5.5, -4, 9, 2, "Puente roto: falta una cuerda", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 235, 170), cerrado)
	for k = 0, 4 do
		plano(161.2 + k * 2.4, 0.35, -0.8, 2.2, 0.5, Color3.fromRGB(170, 120, 70), true, abierto)
	end
	plano(166, 1.6, -0.6, 11, 0.15, Color3.fromRGB(220, 190, 130), false, abierto)
	plano(161, 1.3, -1, 0.6, 2.6, Color3.fromRGB(120, 80, 50), true, abierto)
	plano(171, 1.3, -1, 0.6, 2.6, Color3.fromRGB(120, 80, 50), true, abierto)

	-- 2) Las zarzas (Pantano → Bosque): hace falta el HACHA
	cerrado, abierto = barrera("hacha", 263)
	for k = 0, 8 do
		local z = -11 + k * 2.6
		disco(263 + (k % 2) * 1.2, 2.6 + (k % 3) * 0.8, z, 4.2, Color3.fromRGB(70, 90, 50), true, cerrado)
		tri(263 + (k % 2) * 1.2 - 1.6, 3.6 + (k % 3) * 0.8, z + 0.3, 0.7, 1.3, Color3.fromRGB(200, 190, 160), true, cerrado)
		tri(263 + (k % 2) * 1.2 + 1.4, 2.4, z + 0.3, 0.7, 1.2, Color3.fromRGB(200, 190, 160), true, cerrado)
	end
	letrero(256, 6, -11, 10, 2, "Zarzas: hace falta un hacha", Color3.fromRGB(90, 70, 50), Color3.fromRGB(255, 235, 170), cerrado)
	for k = 0, 3 do
		plano(263, 0.5, -10 + k * 6, 1.6, 1, Color3.fromRGB(150, 110, 70), true, abierto)
	end

	-- 3) La puerta de piedra (Bosque → Ruinas): hace falta la LLAVE DE PIEDRA
	cerrado, abierto = barrera("llave", 363)
	plano(363, 8, -12.5, 6, 16, Color3.fromRGB(150, 140, 130), true, cerrado)
	for k = 0, 4 do
		plano(363, 7, -11 + k * 5, 3, 14, Color3.fromRGB(165, 155, 145), true, cerrado)
		plano(363, 7, -10.6 + k * 5, 0.5, 14, Color3.fromRGB(120, 110, 100), false, cerrado)
	end
	disco(363, 7, 10.2, 2.4, Color3.fromRGB(240, 200, 70), true, cerrado)
	letrero(356, 6.5, -11, 10, 2, "Puerta cerrada: necesitas una llave", Color3.fromRGB(110, 100, 95), Color3.fromRGB(255, 235, 170), cerrado)
	plano(363, 14, -12.5, 8, 3, Color3.fromRGB(165, 155, 145), true, abierto)
	plano(360, 7, -12.5, 2, 14, Color3.fromRGB(150, 140, 130), true, abierto)
	plano(366, 7, -12.5, 2, 14, Color3.fromRGB(150, 140, 130), true, abierto)

	-- 4) La oscuridad (Ruinas → Cueva): hace falta el FAROL
	cerrado, abierto = barrera("farol", 463)
	for k = 0, 3 do
		local n = plano(466 + k * 1.5, 10, -12 + k * 0.4, 6, 24, Color3.fromRGB(15, 10, 20), false, cerrado)
		n.Size = Vector3.new(6, 24, 26)
		n.CFrame = CFrame.new(466 + k * 4, 10, -1)
		n.Transparency = 0.15 + k * 0.05
	end
	for k = 0, 3 do
		disco(466 + k * 3, 5 + (k % 2) * 3, 12, 0.6, Color3.fromRGB(255, 240, 120), false, cerrado).Material = Enum.Material.Neon
	end
	letrero(456, 6.5, -11, 10, 2, "Demasiado oscuro: falta un farol", Color3.fromRGB(40, 35, 50), Color3.fromRGB(255, 235, 170), cerrado)
	for k = 0, 2 do
		plano(468 + k * 30, 3, -11.8, 0.5, 6, Color3.fromRGB(90, 70, 50), true, abierto)
		local llama = disco(468 + k * 30, 6.6, -11.6, 1.4, Color3.fromRGB(255, 170, 50), true, abierto)
		llama.Material = Enum.Material.Neon
	end

	-- Plataformas del Pantano con el cofre del HACHA arriba del todo
	for _, t in { { 226, 3 }, { 232, 6 }, { 238.5, 9 }, { 245, 12 }, { 252, 12 } } do
		tabla(t[1], t[2], -7, 5)
		plano(t[1], t[2] / 2 - 0.5, -9.8, 0.6, t[2] - 1, Color3.fromRGB(110, 80, 55), true)
	end
	cofre(252, 12, -6)
	punto("cofreHacha", Vector3.new(252, 13.5, -6))

	-- El Bosque: el ermitaño y sus 3 setas brillantes escondidas
	plano(334, 4, -17, 9, 8, Color3.fromRGB(140, 100, 65))
	tri(334, 7.8, -16.8, 12, 5, Color3.fromRGB(90, 140, 70))
	plano(332, 2.2, -16.6, 2, 4.4, Color3.fromRGB(80, 55, 35))
	letrero(334, 9.6, -16.4, 8, 1.6, "Ermitaño", Color3.fromRGB(110, 80, 50))
	punto("ermitano", Vector3.new(329, 2.8, -9.5))
	for _, t in { { 292, 3.5 }, { 297, 7 }, { 302.5, 10.5 } } do
		tabla(t[1], t[2], -7, 4.5, Color3.fromRGB(120, 85, 55))
	end
	local setas = { Vector3.new(272, 0, -11.5), Vector3.new(302.5, 10.5, -7), Vector3.new(352, 0, -11.8) }
	for i, pos in setas do
		local m = Instance.new("Model")
		m.Name = "SetaBrillante_" .. i
		m:SetAttribute("SetaId", i)
		m.Parent = raiz
		plano(pos.X, pos.Y + 0.6, pos.Z, 0.5, 1.2, Color3.fromRGB(240, 235, 220), true, m)
		local cap = disco(pos.X, pos.Y + 1.4, pos.Z + 0.1, 1.8, Color3.fromRGB(120, 230, 255), true, m)
		cap.Material = Enum.Material.Neon
		punto("seta", pos + Vector3.new(0, 1.5, 0.5), { SetaId = i }).Parent = m
	end

	-- Las Ruinas: 3 palancas (una arriba de las columnas) y el cofre del FAROL
	for _, t in { { 384, 4 }, { 389.5, 8 }, { 395, 12 } } do
		tabla(t[1], t[2], -7, 4.5, Color3.fromRGB(170, 160, 145))
	end
	for i, pos in { Vector3.new(372, 0, -9.5), Vector3.new(395, 12, -7), Vector3.new(452, 0, -9.5) } do
		local m = Instance.new("Model")
		m.Name = "Palanca_" .. i
		m:SetAttribute("PalancaId", i)
		m.Parent = raiz
		plano(pos.X, pos.Y + 0.4, pos.Z, 1.6, 0.8, Color3.fromRGB(110, 100, 95), true, m)
		local brazo = plano(pos.X, pos.Y + 1.4, pos.Z + 0.2, 0.35, 2.2, Color3.fromRGB(120, 80, 50), true, m, -30)
		brazo.Name = "Brazo"
		disco(pos.X - 0.55, pos.Y + 2.35, pos.Z + 0.3, 0.7, Color3.fromRGB(230, 70, 60), true, m)
		punto("palanca", pos + Vector3.new(0, 1.5, 0.5), { PalancaId = i }).Parent = m
	end
	cofre(440, 0, -10.5)
	punto("cofreFarol", Vector3.new(440, 1.5, -10))

	-- Ciudad: posada, herrería y la puerta de la taberna
	punto("posada", Vector3.new(-23, 2.8, -11.5))
	punto("herrero", Vector3.new(-168, 2.8, -11.5))
	punto("entrarTaberna", Vector3.new(-102, 2.8, -11.5))
end


-- ===================== ALDEA DE BREZO (donde empieza la aventura) =====================
local function aldea(rng: Random)
	-- tu casa, la de la abuela y la del granjero
	casa(-415, -18, 13, 9, Color3.fromRGB(235, 215, 175), Color3.fromRGB(150, 85, 60), "Tu casa", rng)
	casa(-375, -19, 11, 8, Color3.fromRGB(215, 225, 200), Color3.fromRGB(90, 120, 150), nil, rng)
	casa(-340, -18.5, 12, 8.5, Color3.fromRGB(230, 205, 190), Color3.fromRGB(120, 95, 70), nil, rng)
	-- granero rojo
	plano(-292, 6, -21, 18, 12, Color3.fromRGB(170, 70, 55))
	tri(-292, 11.8, -20.8, 21, 7, Color3.fromRGB(110, 55, 45))
	plano(-292, 3.5, -20.5, 7, 7, Color3.fromRGB(120, 55, 45))
	plano(-292, 3.5, -20.2, 7, 0.4, Color3.fromRGB(240, 230, 210), false, nil, 45)
	plano(-292, 3.5, -20.2, 7, 0.4, Color3.fromRGB(240, 230, 210), false, nil, -45)
	-- huerto con filas de coles y un espantapájaros
	for fila = 0, 2 do
		for k = 0, 9 do
			disco(-252 + k * 3.2 - 14, 0.7, -12.2 + fila * 0.4, 1.6, Color3.fromRGB(110, 160, 80))
		end
	end
	plano(-238, 3, -11.5, 0.5, 6, Color3.fromRGB(120, 85, 55))
	plano(-238, 4.6, -11.4, 5, 0.5, Color3.fromRGB(120, 85, 55))
	disco(-238, 6.6, -11.3, 2, Color3.fromRGB(230, 190, 120))
	tri(-238, 7.3, -11.1, 3.2, 1.6, Color3.fromRGB(150, 110, 60))
	plano(-238, 4.2, -11.2, 2.6, 2.4, Color3.fromRGB(120, 140, 190))
	-- vallas, pozo y árboles
	for x = -440, -208, 4 do
		plano(x, 1.3, -12.2, 0.45, 2.6, Color3.fromRGB(190, 150, 100))
	end
	plano(-324, 2, -12, 232, 0.35, Color3.fromRGB(190, 150, 100), false)
	plano(-358, 1.3, -10, 4, 2.6, Color3.fromRGB(160, 155, 165))
	plano(-359.6, 3.6, -10.2, 0.35, 3.2, Color3.fromRGB(120, 85, 55))
	plano(-356.4, 3.6, -10.2, 0.35, 3.2, Color3.fromRGB(120, 85, 55))
	tri(-358, 5, -10, 5, 1.6, Color3.fromRGB(150, 85, 60))
	for _, x in { -432, -398, -322, -270, -222 } do
		arbol(x, -15 + rng:NextNumber(-2, 0), rng:NextNumber(0.8, 1.1))
	end
	-- carteles y puerta de la ciudad (lado oeste)
	plano(-212, 2.4, -10.5, 0.6, 4.8, Color3.fromRGB(120, 80, 50))
	letrero(-212, 5.2, -10.2, 9, 1.8, "Ciudad de Vael →", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 235, 170))
	letrero(-440 + 12, 6, -12, 10, 1.8, "Aldea de Brezo", Color3.fromRGB(110, 140, 90))
	plano(-200, 9, -13, 5, 18, Color3.fromRGB(170, 160, 145))
	plano(-200, 9, 9.5, 5, 18, Color3.fromRGB(170, 160, 145))
	tri(-200, 18, -12.8, 7, 5, Color3.fromRGB(70, 90, 150))
	-- la abuela Rosa y el granjero Tomás
	punto("abuela", Vector3.new(-386, 2.8, -9.5))
	punto("granjero", Vector3.new(-300, 2.8, -9.5))
	-- el guardia del puente roto
	punto("guardaPuente", Vector3.new(154, 2.8, -10))
end

--- Sala interior genérica: suelo, pared del fondo grande, paredes invisibles y un faldón por delante
--- (para que no se vea el vacío por debajo del suelo).
local function sala(cx: number, Y: number, pared: Color3, suelo: Color3)
	local s = plano(cx, Y - 1, 0, 44, 2, suelo)
	s.CanCollide = true
	s.CanQuery = true
	s.Size = Vector3.new(44, 2, 26)
	s.CFrame = CFrame.new(cx, Y - 1, 0)
	local ancho = plano(cx, Y - 1.25, 0, 120, 2, suelo:Lerp(NEGRO, 0.12), false)
	ancho.Size = Vector3.new(120, 2, 32)
	ancho.CFrame = CFrame.new(cx, Y - 1.25, 0)
	plano(cx, Y - 26, 15.5, 140, 50, suelo:Lerp(NEGRO, 0.35), false) -- faldón delantero
	plano(cx, Y + 19, -12.4, 120, 44, pared)
	for k = 0, 10 do
		plano(cx - 50 + k * 10, Y - 1, 13.2, 0.15, 2, suelo:Lerp(NEGRO, 0.3), false)
	end
	for _, lado in { -1, 1 } do
		plano(cx + lado * 40, Y + 19, -11.8, 30, 44, pared:Lerp(NEGRO, 0.2))
		plano(cx + lado * 25, Y + 12, -11.6, 2, 26, Color3.fromRGB(110, 70, 40))
		local m = Instance.new("Part")
		base(m)
		m.CanCollide = true
		m.Transparency = 1
		m.Size = Vector3.new(1, 30, 26)
		m.Position = Vector3.new(cx + lado * 22.5, Y + 10, 0)
		m.Parent = raiz
	end
	for _, z in { -11, 10.5 } do
		local m = Instance.new("Part")
		base(m)
		m.CanCollide = true
		m.Transparency = 1
		m.Size = Vector3.new(44, 30, 1)
		m.Position = Vector3.new(cx, Y + 10, z)
		m.Parent = raiz
	end
	plano(cx, Y + 25, -12, 120, 1.2, Color3.fromRGB(110, 70, 40), false)
end

--- Interior de la posada: camas, mostrador con la posadera, alfombra y ventana con luna.
Mundo.Posada = { entrada = Vector3.new(-35, 343.5, 2), salida = Vector3.new(-23, 3.5, -8) }
local function posada()
	local Y = 340
	local cx = -20
	sala(cx, Y, Color3.fromRGB(150, 165, 190), Color3.fromRGB(140, 100, 70))
	-- papel pintado de rayas
	for k = 0, 9 do
		plano(cx - 22 + k * 5, Y + 9, -12, 1.2, 18, Color3.fromRGB(135, 150, 178), false)
	end
	-- camas
	for i, x in { -6, 6, 16 } do
		local bx = cx + x
		plano(bx, Y + 0.9, -9.5, 7, 1.8, Color3.fromRGB(120, 80, 50))
		plano(bx - 3.2, Y + 2.2, -9.7, 0.7, 4.4, Color3.fromRGB(110, 70, 45))
		plano(bx, Y + 1.9, -9.2, 6.4, 1, ({ Color3.fromRGB(190, 80, 80), Color3.fromRGB(90, 130, 190), Color3.fromRGB(110, 160, 100) })[i])
		disco(bx - 2.2, Y + 2.4, -9, 1.3, Color3.fromRGB(240, 235, 225))
	end
	-- mostrador
	plano(cx - 14, Y + 1.6, -8, 8, 3.2, Color3.fromRGB(150, 100, 60))
	plano(cx - 14, Y + 3.3, -7.8, 8.6, 0.5, Color3.fromRGB(180, 125, 70))
	disco(cx - 12, Y + 4.1, -7.6, 1, Color3.fromRGB(230, 190, 80))
	-- alfombra, planta y ventana con luna
	local alfombra = plano(cx + 4, Y + 0.05, 2, 16, 0.1, Color3.fromRGB(170, 70, 70), false)
	alfombra.Size = Vector3.new(16, 0.1, 8)
	plano(cx + 20, Y + 1.5, -9, 2, 3, Color3.fromRGB(170, 100, 60))
	disco(cx + 20, Y + 4, -8.8, 3, Color3.fromRGB(90, 150, 80))
	plano(cx, Y + 11, -11.5, 6, 5, Color3.fromRGB(40, 55, 100))
	disco(cx + 1.4, Y + 12, -11.3, 1.4, Color3.fromRGB(245, 240, 200), false)
	letrero(cx, Y + 16.5, -11.4, 12, 2.4, "Posada El Ronquido", Color3.fromRGB(90, 110, 150), Color3.fromRGB(255, 235, 170))
	plano(cx - 19, Y + 3, -10.8, 4, 6, Color3.fromRGB(110, 70, 40))
	letrero(cx - 19, Y + 7, -10.6, 4, 1.2, "Salida", Color3.fromRGB(150, 95, 55))
	punto("salirPosada", Vector3.new(cx - 19, Y + 2.8, -8))
	punto("posadera", Vector3.new(cx - 14, Y + 2.8, -9.2))
end

-- ===================== CALLES LATERALES (cruces de la ciudad) =====================
-- Cada calle es un tramo propio, más arriba (como los interiores), con su cielo, suelo, casas y gente.
-- Se llega por los arcos de la ciudad y se vuelve por el cartel del principio.
local function calle(Y: number, x0: number, x1: number, cieloColor: Color3, sueloColor: Color3)
	local medio = (x0 + x1) / 2
	local largo = x1 - x0
	local cielo = plano(medio, Y + 40, -70, largo + 260, 150, cieloColor, false)
	cielo.Size = Vector3.new(largo + 260, 150, 1)
	for k = 0, math.floor((largo + 160) / 45) do
		disco(x0 - 80 + k * 45, Y - 18, -55, 60 + (k % 3) * 12, sueloColor:Lerp(Color3.new(0.3, 0.5, 0.3), 0.4))
	end
	local suelo = Instance.new("Part")
	base(suelo)
	suelo.CanCollide = true
	suelo.CanQuery = true
	suelo.Size = Vector3.new(largo + 120, 4, 70)
	suelo.Position = Vector3.new(medio, Y - 1.95, -21)
	suelo.Color = sueloColor
	suelo.Parent = raiz
	plano(medio, Y - 6, 14.6, largo + 120, 12, Color3.fromRGB(125, 85, 55))
	plano(medio, Y - 0.3, 14.9, largo + 120, 1, sueloColor:Lerp(NEGRO, 0.15), false)
	plano(medio, Y - 30, 15.2, largo + 260, 40, Color3.fromRGB(90, 62, 42), false)
	local camino = plano(medio, Y + 0.06, 1, largo + 120, 0.1, Color3.fromRGB(190, 180, 170), false)
	camino.Size = Vector3.new(largo + 120, 0.1, 9)
	for _, z in { -12.8, 10.8 } do
		local m = Instance.new("Part")
		base(m)
		m.CanCollide = true
		m.Transparency = 1
		m.Size = Vector3.new(largo + 40, 60, 1)
		m.Position = Vector3.new(medio, Y + 20, z)
		m.Parent = raiz
	end
	for _, x in { x0 - 6, x1 + 6 } do
		local m = Instance.new("Part")
		base(m)
		m.CanCollide = true
		m.Transparency = 1
		m.Size = Vector3.new(1, 60, 30)
		m.Position = Vector3.new(x, Y + 20, 0)
		m.Parent = raiz
	end
end

--- Construye lo que haga f a ras de suelo y luego lo sube a la altura Y (para las calles de arriba).
local function aAltura(Y: number, f: () -> ())
	local principal, pastoReal = raiz, pasto
	local temporal = Instance.new("Folder")
	temporal.Name = "Trozo"
	temporal.Parent = principal
	local tempPasto = Instance.new("Folder")
	raiz, pasto = temporal, tempPasto
	f()
	raiz, pasto = principal, pastoReal
	for _, carpeta in { temporal, tempPasto } do
		for _, d in carpeta:GetDescendants() do
			if d:IsA("BasePart") then
				d.CFrame = d.CFrame + Vector3.new(0, Y, 0)
			elseif d:IsA("Model") then
				d.WorldPivot = d.WorldPivot + Vector3.new(0, Y, 0)
			end
		end
	end
	for _, m in tempPasto:GetChildren() do
		m.Parent = pastoReal
	end
	tempPasto:Destroy()
end

--- Casa a una altura Y (las calles van más arriba): misma casa de siempre, desplazada.
local function casaEn(Y: number, x: number, w: number, h: number, pared: Color3, techo: Color3, cartel: string?, rng: Random)
	-- se construye en una carpeta aparte y luego se sube entera a la altura de la calle
	local principal = raiz
	local temporal = Instance.new("Folder")
	temporal.Name = "Casa"
	temporal.Parent = principal
	raiz = temporal
	casa(x, -19, w, h, pared, techo, cartel, rng)
	raiz = principal
	for _, h2 in temporal:GetDescendants() do
		if h2:IsA("BasePart") then
			h2.CFrame = h2.CFrame + Vector3.new(0, Y, 0)
		end
	end
end

Mundo.Calles = {
	mercado = { entrada = Vector3.new(-142, 503.5, 2), salida = Vector3.new(-130, 3.5, -6) },
	callejon = { entrada = Vector3.new(-142, 703.5, 2), salida = Vector3.new(22, 3.5, -6) },
}
local function calles(rng: Random)
	-- ---- Calle del Mercado (Y = 500): puestos, tenderos y un cofre escondido ----
	local Y = 500
	calle(Y, -150, 40, Color3.fromRGB(150, 200, 235), Color3.fromRGB(150, 175, 120))
	local fachadas = { Color3.fromRGB(205, 70, 60), Color3.fromRGB(95, 140, 95), Color3.fromRGB(175, 215, 80), Color3.fromRGB(235, 200, 110), Color3.fromRGB(110, 130, 190) }
	local nombres = { [-128] = "Frutería", [-98] = "Sastrería", [-62] = "Juguetes", [-26] = "Panadería", [8] = "Correos" }
	for _, x in { -128, -98, -62, -26, 8 } do
		casaEn(Y, x, 15, rng:NextNumber(9, 13), fachadas[rng:NextInteger(1, #fachadas)], Color3.fromRGB(90, 70, 60), nombres[x], rng)
	end
	aAltura(Y, function()
		for x = -140, 30, 24 do
			farola(x, -11.5)
		end
		for _, x in { -148, -88, -30, 30 } do
			arbol(x, -15, 0.9)
		end
		for _ = 1, 40 do
			mata(rng:NextNumber(-150, 40), rng:NextNumber(5, 10), rng:NextNumber(1, 1.4), rng)
		end
	end)
	-- puestos con toldos de colores
	for i, x in { -112, -80, -44, -8 } do
		plano(x, Y + 1.5, -9.5, 7, 3, Color3.fromRGB(160, 105, 60))
		for k = 0, 3 do
			plano(x - 2.6 + k * 1.75, Y + 6.2, -9.2, 1.75, 1.4, k % 2 == 0 and ({ Color3.fromRGB(220, 70, 60), Color3.fromRGB(70, 120, 200), Color3.fromRGB(90, 160, 80), Color3.fromRGB(240, 190, 60) })[i] or Color3.new(1, 1, 1), false)
		end
		plano(x - 3.3, Y + 3.5, -9.8, 0.4, 6, Color3.fromRGB(110, 70, 45))
		plano(x + 3.3, Y + 3.5, -9.8, 0.4, 6, Color3.fromRGB(110, 70, 45))
		for k = -1, 1 do
			disco(x + k * 1.8, Y + 3.4, -9.2, 1.4, ({ Color3.fromRGB(230, 80, 70), Color3.fromRGB(250, 200, 60), Color3.fromRGB(120, 190, 80) })[k + 2])
		end
	end
	letrero(-142, Y + 5.5, -11, 9, 1.8, "← Plaza de Vael", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 235, 170))
	punto("volverPlaza", Vector3.new(-146, Y + 2.8, -6), { Calle = "mercado" })
	punto("tendero", Vector3.new(-112, Y + 2.8, -10.2), { Npc = "vecino:7070", Frases = "¡Manzanas que curan!|¡Fruta fresca, recién recortada!" })
	punto("sastre", Vector3.new(-98, Y + 2.8, -11.5), { Npc = "vecino:6262", Frases = "Esa capa te queda… regular.|¿Unos botones nuevos?" })
	punto("nino", Vector3.new(-62, Y + 2.8, -9), { Npc = "vecino:5", Frases = "¡Mi pelota se fue al Callejón!|¡Juega conmigo!" })
	cofre(36, Y, -10.5)
	punto("cofreMercado", Vector3.new(36, Y + 1.5, -10))

	-- ---- Callejón del Gato (Y = 700): oscuro, con gatos, cubos y una adivina ----
	Y = 700
	calle(Y, -150, 40, Color3.fromRGB(70, 75, 110), Color3.fromRGB(110, 105, 100))
	for _, x in { -125, -85, -45, -5, 30 } do
		casaEn(Y, x, 16, rng:NextNumber(12, 16), Color3.fromRGB(120, 110, 130), Color3.fromRGB(60, 55, 70), nil, rng)
	end
	aAltura(Y, function()
		for x = -140, 30, 28 do
			-- en el callejón las farolas fallan (el cliente las hace parpadear)
			farola(x, -11.5):SetAttribute("Parpadea", true)
		end
	end)
	for _, x in { -118, -70, -20, 15 } do
		plano(x, Y + 1.2, -10, 2.2, 2.4, Color3.fromRGB(110, 120, 120))
		plano(x, Y + 2.5, -9.8, 2.6, 0.3, Color3.fromRGB(90, 100, 100), false)
		-- gato encima del cubo
		disco(x + 0.2, Y + 3.3, -9.6, 1.3, ({ Color3.fromRGB(240, 150, 60), Color3.fromRGB(60, 55, 60), Color3.fromRGB(230, 230, 225) })[(math.floor(x) % 3) + 1])
		tri(x - 0.2, Y + 3.8, -9.5, 0.5, 0.6, Color3.fromRGB(60, 55, 60))
		tri(x + 0.6, Y + 3.8, -9.5, 0.5, 0.6, Color3.fromRGB(60, 55, 60))
	end
	-- tienda de la adivina
	plano(-40, Y + 4, -11.5, 9, 8, Color3.fromRGB(120, 60, 130))
	tri(-40, Y + 7.8, -11.3, 11, 4, Color3.fromRGB(150, 80, 160))
	disco(-40, Y + 9.8, -11.1, 1.2, Color3.fromRGB(240, 210, 90))
	letrero(-40, Y + 6, -11, 7, 1.4, "Madame Zoé", Color3.fromRGB(90, 40, 100))
	punto("adivina", Vector3.new(-40, Y + 2.8, -9.5), { Npc = "vecino:1313", Frases = "Veo… veo… un monstruo en tu futuro.|Cruza mi mano con oro, cariño." })
	letrero(-142, Y + 5.5, -11, 9, 1.8, "← Plaza de Vael", Color3.fromRGB(80, 60, 90), Color3.fromRGB(255, 235, 170))
	punto("volverPlaza", Vector3.new(-146, Y + 2.8, -6), { Calle = "callejon" })
	cofre(36, Y, -10.5)
	punto("cofreCallejon", Vector3.new(36, Y + 1.5, -10))

	-- ---- los arcos de la ciudad que llevan a las calles ----
	for _, d in { { -130, "Calle del Mercado", "irMercado" }, { 22, "Callejón del Gato", "irCallejon" } } do
		local x = d[1]
		plano(x - 3.2, 5, -12.4, 1.2, 10, Color3.fromRGB(170, 150, 130))
		plano(x + 3.2, 5, -12.4, 1.2, 10, Color3.fromRGB(170, 150, 130))
		plano(x, 10.4, -12.3, 8, 1.6, Color3.fromRGB(150, 100, 70))
		letrero(x, 12, -12.1, 9, 1.6, d[2] .. " ↑", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 235, 170))
		punto(d[3], Vector3.new(x, 2.8, -10.5))
	end
end

--- Interior de la taberna (lejos, en lo alto: se entra y se sale con la puerta).
Mundo.Taberna = { entrada = Vector3.new(-112, 203.5, 2), salida = Vector3.new(-102, 3.5, -8) }
local function taberna()
	local Y = 200
	local suelo = plano(-100, Y - 1, 0, 44, 2, Color3.fromRGB(150, 100, 60))
	suelo.CanCollide = true
	suelo.CanQuery = true
	suelo.Size = Vector3.new(44, 2, 26)
	suelo.CFrame = CFrame.new(-100, Y - 1, 0)
	for k = 0, 10 do
		plano(-121 + k * 4.2, Y - 1, 13.1, 0.15, 2, Color3.fromRGB(110, 70, 40), false)
	end
	-- pared de atrás con ladrillo y ventanas (grande, para que llene la pantalla) y techo de vigas
	plano(-100, Y + 19, -12.4, 110, 44, Color3.fromRGB(205, 160, 110))
	plano(-100, Y + 25, -12, 110, 1.2, Color3.fromRGB(110, 70, 40), false)
	plano(-100, Y + 32, -12, 110, 1.2, Color3.fromRGB(110, 70, 40), false)
	local sueloAncho = plano(-100, Y - 1.2, 0, 110, 2, Color3.fromRGB(130, 85, 50), false)
	sueloAncho.Size = Vector3.new(110, 2, 30)
	sueloAncho.CFrame = CFrame.new(-100, Y - 1.25, 0)
	for _, lado in { -1, 1 } do
		plano(-100 + lado * 38, Y + 19, -11.8, 28, 44, Color3.fromRGB(150, 105, 70))
		plano(-100 + lado * 25, Y + 12, -11.6, 2, 26, Color3.fromRGB(110, 70, 40))
	end
	for k = 0, 12 do
		plano(-120 + (k % 7) * 6.3, Y + 3 + math.floor(k / 7) * 9, -11.6, 3, 1.2, Color3.fromRGB(185, 140, 95), false)
	end
	for _, x in { -112, -88 } do
		plano(x, Y + 10, -11.5, 5, 5, Color3.fromRGB(40, 60, 110))
		disco(x + 1, Y + 11, -11.3, 1, Color3.fromRGB(255, 250, 200), false)
		plano(x, Y + 10, -11.2, 5, 0.3, Color3.fromRGB(110, 70, 40), false)
		plano(x, Y + 10, -11.2, 0.3, 5, Color3.fromRGB(110, 70, 40), false)
	end
	-- paredes invisibles y techo
	for _, d in { { -122.5, 0, 1, 40 }, { -77.5, 0, 1, 40 } } do
		local m = Instance.new("Part")
		base(m)
		m.CanCollide = true
		m.Transparency = 1
		m.Size = Vector3.new(1, 30, 26)
		m.Position = Vector3.new(d[1], Y + 10, 0)
		m.Parent = raiz
	end
	for _, z in { -11, 10.5 } do
		local m = Instance.new("Part")
		base(m)
		m.CanCollide = true
		m.Transparency = 1
		m.Size = Vector3.new(44, 30, 1)
		m.Position = Vector3.new(-100, Y + 10, z)
		m.Parent = raiz
	end
	plano(-100, Y - 26, 15.5, 140, 50, Color3.fromRGB(90, 60, 40), false) -- faldón: que no se vea el vacío
	punto("cliente", Vector3.new(-111, Y + 2.8, 4), { Npc = "vecino:777", Frases = "¡Otra ronda de zumo de seta!|Hip.|Bruno hace trampas, lo sé." })
	punto("cliente", Vector3.new(-88, Y + 2.8, 4), { Npc = "vecino:31415", Frases = "¿Has probado el guiso? Yo tampoco.|Dicen que el ermitaño habla con setas.|¡Por la Pradera!" })
	punto("cliente", Vector3.new(-84, Y + 2.8, -6), { Npc = "vecino:2718", Frases = "Qué calorcito da la chimenea.|Zzz…" })
	plano(-122, Y + 9, -6, 1, 20, Color3.fromRGB(120, 80, 50))
	plano(-78, Y + 9, -6, 1, 20, Color3.fromRGB(120, 80, 50))
	-- barra, barriles, mesas y chimenea
	plano(-100, Y + 1.6, -8, 16, 3.2, Color3.fromRGB(130, 80, 45))
	plano(-100, Y + 3.3, -7.8, 17, 0.5, Color3.fromRGB(170, 110, 60))
	for k = -2, 2 do
		plano(-100 + k * 3.5, Y + 6.8, -11.3, 2.4, 0.4, Color3.fromRGB(110, 70, 40), false)
		disco(-100 + k * 3.5, Y + 7.6, -11.2, 1.1, ({ Color3.fromRGB(90, 200, 120), Color3.fromRGB(200, 80, 80), Color3.fromRGB(110, 140, 240) })[(k % 3) + 1])
	end
	for _, x in { -118, -115 } do
		disco(x, Y + 1.5, -9.5, 3, Color3.fromRGB(150, 100, 55))
		plano(x, Y + 1.5, -9.3, 3, 0.25, Color3.fromRGB(90, 90, 100), false)
	end
	for _, x in { -110, -90 } do
		plano(x, Y + 1.8, 2, 6, 0.6, Color3.fromRGB(150, 100, 60))
		plano(x - 2.4, Y + 0.8, 2.2, 0.5, 1.8, Color3.fromRGB(120, 80, 50))
		plano(x + 2.4, Y + 0.8, 2.2, 0.5, 1.8, Color3.fromRGB(120, 80, 50))
		disco(x - 1, Y + 2.6, 2.4, 1, Color3.fromRGB(240, 200, 90))
	end
	plano(-84, Y + 3, -11, 8, 6, Color3.fromRGB(120, 115, 120))
	plano(-84, Y + 2, -10.6, 5, 3.6, Color3.fromRGB(30, 20, 20))
	local fuego = disco(-84, Y + 1.6, -10.3, 2.2, Color3.fromRGB(255, 150, 40))
	fuego.Material = Enum.Material.Neon
	letrero(-100, Y + 15, -11.4, 12, 2.6, "Taberna El Hongo Feliz", Color3.fromRGB(150, 90, 50), Color3.fromRGB(255, 230, 150))
	-- puerta de salida
	plano(-119, Y + 3, -10.8, 4, 6, Color3.fromRGB(110, 70, 40))
	letrero(-119, Y + 7, -10.6, 4, 1.2, "Salida", Color3.fromRGB(150, 95, 55))
	punto("salirTaberna", Vector3.new(-119, Y + 2.8, -8))
	punto("tabernero", Vector3.new(-100, Y + 2.8, -9))
end

--- Construye (o encuentra) el mundo. Devuelve las partes de zona: [parte] = datos de la zona.
-- ===================== FONDO VIVO (lo que se ve detrás: que no parezca un decorado vacío) =====================
-- Todo va de z = -30 hacia atrás, así que no estorba al camino. Lo que se mueve lo anima el cliente:
-- "Nube" (se desplaza), "Gira" (rueda), "Flota" (sube y baja) y "Humo" (bocanadas que suben y se deshacen).

--- Columna de humo de una chimenea.
local function humo(x: number, y: number, z: number)
	local m = Instance.new("Model")
	m.Name = "Humo"
	m:SetAttribute("Humo", y)
	m.Parent = raiz
	for k = 0, 3 do
		local p = disco(x + k * 0.6, y + k * 2, z, 2.2 + k * 0.6, Color3.fromRGB(225, 222, 215), false, m)
		p.Transparency = 0.2 + k * 0.15
	end
end

--- Casa lejana (más sencilla): sale por encima de la muralla o de las colinas.
local function casaLejana(x: number, z: number, w: number, h: number, pared: Color3, techo: Color3, chimenea: boolean?)
	plano(x, h / 2, z, w, h, pared)
	tri(x, h - 0.2, z + 0.1, w + 2, h * 0.45, techo)
	for k = 0, 1 do
		plano(x - w * 0.22 + k * w * 0.44, h * 0.68, z + 0.3, 1.8, 2, Color3.fromRGB(255, 220, 130), false)
	end
	if chimenea then
		plano(x + w * 0.28, h + h * 0.3, z - 0.4, 1.4, 3, Color3.fromRGB(140, 90, 70))
		humo(x + w * 0.28, h + h * 0.3 + 3, z - 0.2)
	end
end

local function pajaros(x: number, y: number, z: number, n: number, velocidad: number)
	local m = Instance.new("Model")
	m.Name = "Pajaros"
	m:SetAttribute("Nube", velocidad)
	m.Parent = raiz
	for k = 1, n do
		local px, py = x + k * 3.2, y + (k % 2) * 1.6
		plano(px - 0.6, py, z, 1.5, 0.3, NEGRO, false, m, 25)
		plano(px + 0.6, py, z, 1.5, 0.3, NEGRO, false, m, -25)
	end
end

local function globo(x: number, y: number, z: number, color: Color3)
	local m = Instance.new("Model")
	m.Name = "Globo"
	m:SetAttribute("Nube", 0.5)
	m:SetAttribute("Flota", 0.6)
	m.Parent = raiz
	disco(x, y, z, 11, color, true, m)
	plano(x, y, z + 0.3, 1.6, 10.6, Color3.fromRGB(250, 235, 200), false, m)
	plano(x, y - 7.5, z, 0.2, 4, NEGRO, false, m, 18)
	plano(x, y - 7.5, z, 0.2, 4, NEGRO, false, m, -18)
	plano(x, y - 9.8, z, 3, 2, Color3.fromRGB(150, 100, 60), true, m)
end

local function vaca(x: number, z: number)
	plano(x, 2.2, z, 4.4, 2.4, Color3.fromRGB(250, 248, 240))
	disco(x - 0.8, 2.6, z + 0.3, 1.2, NEGRO, false)
	disco(x + 1.1, 1.9, z + 0.3, 0.9, NEGRO, false)
	plano(x + 2.6, 2.9, z + 0.2, 1.6, 1.4, Color3.fromRGB(250, 248, 240))
	plano(x + 3.1, 2.6, z + 0.4, 0.8, 0.7, Color3.fromRGB(240, 170, 170), false)
	for _, dx in { -1.6, -0.6, 0.9, 1.7 } do
		plano(x + dx, 0.6, z - 0.1, 0.5, 1.4, Color3.fromRGB(250, 248, 240))
	end
end

local function fondoVivo(rng: Random)
	local paredes = { Color3.fromRGB(240, 222, 190), Color3.fromRGB(205, 220, 235), Color3.fromRGB(235, 200, 190), Color3.fromRGB(215, 230, 195) }
	local techos = { Color3.fromRGB(185, 80, 65), Color3.fromRGB(80, 110, 160), Color3.fromRGB(140, 85, 130), Color3.fromRGB(90, 135, 90) }

	-- ---- ALDEA DE BREZO: campos de cultivo, almiares, granjas y un molino de agua ----
	for k = 0, 5 do
		local col = k % 2 == 0 and Color3.fromRGB(205, 185, 95) or Color3.fromRGB(130, 170, 80)
		local p = plano(-325, 2 + k * 1.6, -46 - k * 2, 240, 1.6, col, false)
		p.Size = Vector3.new(240, 1.6, 0.4)
	end
	for _, x in { -430, -395, -350, -300, -255, -225 } do
		disco(x + rng:NextNumber(-6, 6), 4, -38, 4.5, Color3.fromRGB(225, 190, 90))
		plano(x, 2, -37.8, 4.6, 2.2, Color3.fromRGB(225, 190, 90), false)
	end
	casaLejana(-405, -55, 12, 9, paredes[1], techos[1], true)
	casaLejana(-310, -58, 10, 8, paredes[3], techos[4], true)
	plano(-260, 9, -52, 6, 18, Color3.fromRGB(150, 110, 75)) -- depósito de agua
	disco(-260, 19, -51.6, 9, Color3.fromRGB(120, 150, 170))
	for _, x in { -380, -345, -270 } do
		vaca(x, -33)
	end
	pajaros(-420, 42, -60, 4, 0.9)

	-- ---- CIUDAD DE VAEL: barrio alto, castillo del alcalde, el Gran Guiso y un globo ----
	for x = -188, 30, 15 do
		local h = rng:NextNumber(17, 25)
		casaLejana(x + rng:NextNumber(-3, 3), -33 - rng:NextNumber(0, 3), rng:NextNumber(10, 14), h, paredes[rng:NextInteger(1, #paredes)], techos[rng:NextInteger(1, #techos)], rng:NextNumber() < 0.6)
	end
	-- colina con el castillo
	disco(-110, -18, -60, 110, Color3.fromRGB(120, 190, 100))
	plano(-110, 40, -58, 34, 18, Color3.fromRGB(200, 190, 175))
	for k = -1, 1 do
		local tx = -110 + k * 17
		plano(tx, 44, -57.5, 7, 28, Color3.fromRGB(210, 200, 185))
		tri(tx, 58, -57.3, 10, 9, Color3.fromRGB(70, 90, 150))
		plano(tx + 1.6, 69, -57.2, 3, 2, Color3.fromRGB(230, 190, 70), false)
		plano(tx, 67.5, -57.2, 0.3, 5, NEGRO, false)
		plano(tx, 48, -57, 2, 3, Color3.fromRGB(255, 220, 130), false)
	end
	for k = 0, 7 do
		plano(-126 + k * 4.5, 50, -57.6, 2.4, 2.4, Color3.fromRGB(200, 190, 175))
	end
	plano(-110, 36, -57, 6, 8, Color3.fromRGB(120, 75, 45))
	-- guirnalda de banderines entre las torres
	for x = -126, -94, 1.8 do
		tri(x, 56 - math.sin((x + 126) / 32 * math.pi) * 3, -57, 1.3, -1.6, COLORES_FLOR[(math.floor(x) % #COLORES_FLOR) + 1], false)
	end
	-- el Gran Guiso: la olla gigante de la fiesta, fría (sin el Cucharón no hay guiso)
	local gx = -78
	disco(gx, 6.5, -24.5, 11, Color3.fromRGB(60, 58, 66))
	plano(gx, 11, -24.2, 13, 1.2, Color3.fromRGB(85, 82, 92))
	plano(gx - 4, 1, -24.6, 1, 3, Color3.fromRGB(60, 58, 66))
	plano(gx + 4, 1, -24.6, 1, 3, Color3.fromRGB(60, 58, 66))
	for k = -2, 2 do
		plano(gx + k * 1.6, 0.7, -24.2, 1.2, 1.4, Color3.fromRGB(110, 75, 50), false, nil, k * 20)
	end
	plano(gx + 5.5, 15, -24.4, 0.4, 8, Color3.fromRGB(110, 75, 50)) -- el gancho vacío del Cucharón
	plano(gx + 4.6, 18.8, -24.4, 2.2, 0.4, Color3.fromRGB(110, 75, 50))
	letrero(gx, 15.5, -23.8, 9, 3, "Fiesta del Gran Guiso\n¡APLAZADA!", Color3.fromRGB(190, 80, 60), Color3.fromRGB(255, 240, 200))
	globo(-150, 52, -80, Color3.fromRGB(220, 110, 90))
	globo(-20, 62, -95, Color3.fromRGB(110, 150, 210))
	pajaros(-60, 46, -62, 5, 1.2)

	-- ---- PRADERA: granjas, vacas y otro molino lejano ----
	casaLejana(60, -42, 11, 8, paredes[2], techos[1], true)
	casaLejana(140, -45, 10, 8, paredes[4], techos[2], true)
	for _, x in { 95, 110, 125 } do
		vaca(x + rng:NextNumber(-3, 3), -34)
	end
	plano(150, 8, -50, 6, 16, Color3.fromRGB(235, 225, 205))
	tri(150, 16, -49.8, 8, 5, Color3.fromRGB(150, 80, 60))
	local aspas = Instance.new("Model")
	aspas.Name = "Aspas"
	aspas:SetAttribute("Gira", 0.5)
	aspas.Parent = raiz
	for k = 0, 3 do
		local a = math.rad(k * 90)
		plano(150 + math.cos(a) * 3.6, 13 + math.sin(a) * 3.6, -49.2, 7, 1.3, Color3.fromRGB(230, 220, 190), true, aspas, k * 90)
	end
	aspas.WorldPivot = CFrame.new(150, 13, -49)

	-- ---- PANTANO: árboles muertos, la cabaña de la bruja en zancos y niebla ----
	for _, x in { 172, 190, 214, 236, 255 } do
		plano(x, 7, -36, 1.2, 14, Color3.fromRGB(80, 75, 70))
		plano(x + 2, 11, -36, 4, 0.6, Color3.fromRGB(80, 75, 70), false, nil, 35)
		plano(x - 1.6, 9, -36, 3, 0.5, Color3.fromRGB(80, 75, 70), false, nil, -40)
	end
	plano(226, 14, -50, 12, 8, Color3.fromRGB(110, 120, 90))
	tri(226, 17.8, -49.8, 14, 6, Color3.fromRGB(80, 70, 90))
	for _, dx in { -4, 4 } do
		plano(226 + dx, 5, -50.4, 0.8, 10, Color3.fromRGB(90, 70, 55))
	end
	plano(226, 14, -49.6, 2, 2, Color3.fromRGB(170, 230, 120), false)
	humo(229, 21, -50)
	local niebla = plano(214, 3, -31, 100, 5, Color3.fromRGB(220, 230, 225), false)
	niebla.Transparency = 0.55
	niebla:SetAttribute("Niebla", 0.8)

	-- ---- BOSQUE: dos filas de pinos oscuros ----
	for x = 264, 360, 7 do
		pino(x + rng:NextNumber(-2, 2), -34, rng:NextNumber(1.3, 1.8), Color3.fromRGB(40, 95, 65))
	end
	for x = 268, 360, 9 do
		pino(x + rng:NextNumber(-2, 2), -46, rng:NextNumber(1.8, 2.3), Color3.fromRGB(35, 80, 60))
	end
	pajaros(280, 40, -56, 3, 0.7)

	-- ---- RUINAS: columnas rotas, un arco y una cabeza de estatua medio enterrada ----
	for _, x in { 370, 384, 398, 448 } do
		local h = rng:NextNumber(6, 14)
		plano(x, h / 2, -36, 3, h, Color3.fromRGB(200, 195, 180))
		plano(x, h + 0.4, -35.8, 4, 0.8, Color3.fromRGB(185, 180, 165))
	end
	plano(420, 9, -44, 3, 18, Color3.fromRGB(190, 185, 170))
	plano(436, 9, -44, 3, 18, Color3.fromRGB(190, 185, 170))
	plano(428, 19, -44, 22, 3, Color3.fromRGB(190, 185, 170))
	disco(405, 3, -48, 14, Color3.fromRGB(185, 180, 168))
	plano(401, 5, -47.4, 2.4, 0.6, NEGRO, false)
	plano(409, 5, -47.4, 2.4, 0.6, NEGRO, false)
	plano(405, 1.6, -47.4, 4, 0.5, NEGRO, false)

	-- ---- CUEVA: el castillo del Rey Hongo (una seta gigante) con el Cucharón de bandera ----
	disco(560, -10, -70, 120, Color3.fromRGB(110, 100, 110))
	plano(560, 40, -66, 14, 34, Color3.fromRGB(235, 225, 200))
	local copa = Instance.new("Model")
	copa.Name = "SetaReal"
	copa:SetAttribute("Flota", 0.4)
	copa.Parent = raiz
	disco(560, 60, -65, 50, Color3.fromRGB(200, 60, 60), true, copa)
	for _, d in { { -12, 66, 7 }, { 8, 70, 6 }, { 15, 60, 5 }, { -4, 76, 4 }, { -16, 58, 4 } } do
		disco(560 + d[1], d[2], -64.6, d[3], Color3.fromRGB(250, 240, 230), false, copa)
	end
	plano(560, 30, -65.6, 5, 8, Color3.fromRGB(110, 75, 50))
	plano(556, 44, -65.6, 3, 3, Color3.fromRGB(180, 240, 140), false)
	plano(564, 44, -65.6, 3, 3, Color3.fromRGB(180, 240, 140), false)
	-- la bandera: el Cucharón robado, colgado en lo alto
	plano(560, 92, -65, 0.5, 14, NEGRO, false, copa)
	plano(563.5, 96, -65, 7, 1.2, Color3.fromRGB(190, 140, 80), true, copa, -20)
	disco(567.5, 94.5, -65, 4, Color3.fromRGB(190, 140, 80), true, copa)
	-- esporas que flotan alrededor
	for k = 1, 8 do
		local m = Instance.new("Model")
		m.Name = "Espora"
		m:SetAttribute("Flota", rng:NextNumber(0.6, 1.4))
		m.Parent = raiz
		disco(520 + rng:NextNumber(0, 80), rng:NextNumber(20, 70), -60, rng:NextNumber(1, 2), Color3.fromRGB(190, 230, 140), false, m)
	end
end


-- ===================== DETALLES (fondos de las calles e interiores) Y SECRETOS =====================

--- Par de ojos que miran desde la oscuridad (el cliente los hace parpadear y aparecer de vez en cuando).
local function ojos(x: number, y: number, z: number, color: Color3?)
	local m = Instance.new("Model")
	m.Name = "Ojos"
	m:SetAttribute("Ojos", true)
	m.Parent = raiz
	for _, dx in { -0.55, 0.55 } do
		disco(x + dx, y, z, 0.55, color or Color3.fromRGB(250, 230, 90), false, m)
	end
end

--- Gato morado con pañuelo rojo y cascabel (un invitado de otro mundo).
local function gatoMorado(x: number, y: number, z: number)
	local morado = Color3.fromRGB(125, 85, 170)
	disco(x, y + 1.1, z, 2.2, morado)
	disco(x + 0.2, y + 2.6, z + 0.2, 1.9, morado)
	tri(x - 0.4, y + 3.2, z + 0.1, 0.8, 0.9, morado)
	tri(x + 0.8, y + 3.2, z + 0.1, 0.8, 0.9, morado)
	tri(x - 0.4, y + 3.25, z + 0.15, 0.4, 0.5, Color3.fromRGB(240, 150, 170), false)
	tri(x + 0.8, y + 3.25, z + 0.15, 0.4, 0.5, Color3.fromRGB(240, 150, 170), false)
	disco(x - 0.2, y + 2.7, z + 0.5, 0.45, Color3.fromRGB(250, 220, 90), false)
	disco(x + 0.6, y + 2.7, z + 0.5, 0.45, Color3.fromRGB(250, 220, 90), false)
	plano(x + 0.2, y + 1.8, z + 0.5, 1.8, 0.45, Color3.fromRGB(205, 50, 50), false)
	disco(x + 0.2, y + 1.45, z + 0.6, 0.45, Color3.fromRGB(240, 200, 60), true)
	plano(x - 1.2, y + 0.7, z - 0.1, 1.8, 0.4, morado, true, nil, 30)
end

local function extras(rng: Random)
	-- ---------- CALLEJÓN DEL GATO (Y = 700): oscuro, con cosas detrás ----------
	aAltura(700, function()
		-- luna grande con una nube delante
		disco(-60, 62, -68, 22, Color3.fromRGB(240, 236, 210))
		disco(-55, 66, -67.6, 3, Color3.fromRGB(220, 215, 190), false)
		disco(-64, 58, -67.6, 2, Color3.fromRGB(220, 215, 190), false)
		nube(-48, 56, -66, 1.2, 0.3)
		-- edificios altos y oscuros al fondo, con ventanas (algunas fallan)
		local x = -170
		while x < 60 do
			local w = rng:NextNumber(14, 20)
			local h = rng:NextNumber(28, 44)
			plano(x, h / 2, -34, w, h, rng:NextNumber() < 0.5 and Color3.fromRGB(62, 56, 82) or Color3.fromRGB(74, 66, 92))
			for fila = 0, math.floor(h / 7) - 1 do
				for col = -1, 1 do
					if rng:NextNumber() < 0.35 then
						local v = plano(x + col * w * 0.28, 6 + fila * 7, -33.6, 2, 2.6, Color3.fromRGB(255, 215, 120), false)
						if rng:NextNumber() < 0.3 then
							v:SetAttribute("Parpadea", true)
						end
					else
						plano(x + col * w * 0.28, 6 + fila * 7, -33.6, 2, 2.6, Color3.fromRGB(40, 36, 55), false)
					end
				end
			end
			-- depósito de agua o chimenea en el tejado
			if rng:NextNumber() < 0.5 then
				plano(x + w * 0.2, h + 2.5, -34.4, 4, 5, Color3.fromRGB(90, 80, 75))
				tri(x + w * 0.2, h + 5, -34.2, 5, 2, Color3.fromRGB(70, 60, 60))
			else
				plano(x - w * 0.25, h + 2, -34.4, 1.6, 4, Color3.fromRGB(80, 70, 70))
			end
			x += w + rng:NextNumber(1, 4)
		end
		-- cables entre los edificios
		for k = 0, 5 do
			plano(-150 + k * 36, 24 + (k % 2) * 3, -30, 38, 0.25, NEGRO, false, nil, (k % 2 == 0) and 4 or -4)
		end
		-- los huecos entre las casas: oscuridad, ojos que miran y tendederos
		for _, gx in { -105, -65, -25, 12 } do
			plano(gx, 9, -25, 22, 18, Color3.fromRGB(30, 26, 40), false)
			ojos(gx + rng:NextNumber(-4, 4), rng:NextNumber(2.5, 7), -24.4)
			plano(gx, 11, -21.5, 20, 0.2, NEGRO, false)
			for k = -3, 3 do
				if rng:NextNumber() < 0.7 then
					plano(gx + k * 2.6, 10, -21.3, 1.8, 2.2, COLORES_FLOR[rng:NextInteger(1, #COLORES_FLOR)]:Lerp(NEGRO, 0.3), false)
				end
			end
		end
		-- carteles de "se busca" pegados en las paredes
		for _, px in { -111, -71, -31, 8 } do
			letrero(px, 6, -18, 3.6, 4.4, "SE BUSCA\nREY HONGO", Color3.fromRGB(215, 200, 160), Color3.fromRGB(60, 40, 30))
		end
		-- charcos, cajas, una rata y niebla oscura a ras de suelo
		for _, cx in { -130, -88, -52, -10, 26 } do
			local c = plano(cx, 0.07, -2.5, 5, 0.1, Color3.fromRGB(60, 70, 110), false)
			c.Size = Vector3.new(rng:NextNumber(3, 6), 0.1, 2.4)
			c.Transparency = 0.25
		end
		for _, cx in { -96, -58, 22 } do
			plano(cx, 1.2, -10.8, 2.6, 2.4, Color3.fromRGB(130, 95, 60))
			plano(cx + 1.6, 0.8, -10.6, 1.8, 1.6, Color3.fromRGB(150, 110, 70))
		end
		disco(-33, 0.6, -9.2, 1.2, Color3.fromRGB(110, 105, 110))
		plano(-34.2, 0.4, -9.3, 1.4, 0.15, Color3.fromRGB(200, 150, 160), false, nil, -15)
		local niebla = plano(-55, 1.3, -12, 220, 2.6, Color3.fromRGB(50, 45, 70), false)
		niebla.Transparency = 0.55
		niebla:SetAttribute("Niebla", 0.5)
		-- secretos del callejón: el gato morado sobre una caja y una puerta que mejor no abrir
		gatoMorado(-96, 2.4, -10.2)
		punto("secreto", Vector3.new(-96, 2.8, -9), { Secreto = "gato" })
		plano(0, 3.5, -18.2, 3.6, 7, Color3.fromRGB(40, 32, 38))
		disco(1, 3.5, -17.9, 0.4, Color3.fromRGB(150, 140, 120), false)
		letrero(0, 7.8, -17.9, 4, 1, "NO", Color3.fromRGB(120, 40, 40))
		punto("secreto", Vector3.new(0, 2.8, -10), { Secreto = "puerta" })
	end)

	-- ---------- CALLE DEL MERCADO (Y = 500): más tiendas detrás, banderines y farolillos ----------
	aAltura(500, function()
		local paredes = { Color3.fromRGB(240, 210, 170), Color3.fromRGB(200, 225, 240), Color3.fromRGB(245, 200, 190), Color3.fromRGB(210, 235, 195), Color3.fromRGB(250, 230, 160) }
		local techos = { Color3.fromRGB(190, 80, 65), Color3.fromRGB(80, 110, 165), Color3.fromRGB(145, 85, 135), Color3.fromRGB(90, 140, 90) }
		local x = -165
		while x < 55 do
			local h = rng:NextNumber(18, 28)
			plano(x, h / 2, -33, 14, h, paredes[rng:NextInteger(1, #paredes)])
			tri(x, h - 0.2, -32.8, 16, 6, techos[rng:NextInteger(1, #techos)])
			for k = -1, 1, 2 do
				plano(x + k * 3.5, h * 0.7, -32.6, 2, 2.4, Color3.fromRGB(255, 220, 130), false)
			end
			-- banderola colgando de la fachada
			plano(x + 5, h * 0.55, -32.4, 1.6, 4, COLORES_FLOR[rng:NextInteger(1, #COLORES_FLOR)], true)
			x += rng:NextNumber(15, 19)
		end
		-- torre del reloj del mercado y un globo
		plano(-55, 20, -40, 9, 40, Color3.fromRGB(220, 200, 170))
		tri(-55, 40, -39.8, 12, 9, Color3.fromRGB(190, 80, 65))
		disco(-55, 33, -39.5, 6, Color3.fromRGB(250, 245, 230))
		plano(-55, 33.9, -39.2, 0.35, 2, NEGRO, false)
		plano(-54.3, 33, -39.2, 1.5, 0.35, NEGRO, false)
		globo(-100, 58, -80, Color3.fromRGB(240, 190, 70))
		pajaros(-140, 44, -50, 4, 0.8)
		-- banderines cruzando la calle y farolillos
		for bx = -148, 38, 2.2 do
			tri(bx, 11 + math.sin(bx * 0.18) * 0.6, -10.8, 1.4, -1.6, COLORES_FLOR[(math.floor(bx) % #COLORES_FLOR) + 1], false)
		end
		for fx = -136, 30, 12 do
			disco(fx, 9.6, -10.6, 1.3, Color3.fromRGB(240, 140, 70))
		end
		-- cajas de fruta y una carreta
		for _, cx in { -120, -70, -16, 20 } do
			plano(cx, 0.9, -11, 2.8, 1.8, Color3.fromRGB(170, 120, 70))
			for k = -1, 1 do
				disco(cx + k * 0.8, 2, -10.8, 0.9, ({ Color3.fromRGB(230, 80, 70), Color3.fromRGB(250, 170, 60), Color3.fromRGB(120, 190, 80) })[k + 2], false)
			end
		end
		plano(-34, 2, -11.5, 6, 2.2, Color3.fromRGB(150, 100, 60))
		disco(-36, 0.9, -11.2, 2, Color3.fromRGB(110, 75, 45))
		disco(-32, 0.9, -11.2, 2, Color3.fromRGB(110, 75, 45))
	end)

	-- ---------- TABERNA (Y = 200): trofeo, diana, lámpara, cartel y un gato junto al fuego ----------
	local T = 200
	-- trofeo: cabeza de babosa en una tabla
	plano(-92, T + 13, -11.3, 4, 3.4, Color3.fromRGB(120, 80, 50))
	disco(-92, T + 13, -11, 2.8, Color3.fromRGB(130, 190, 90))
	disco(-92.7, T + 13.4, -10.8, 0.6, Color3.new(1, 1, 1), false)
	disco(-91.3, T + 13.4, -10.8, 0.6, Color3.new(1, 1, 1), false)
	-- diana con un dardo (y otro fuera, en la pared)
	for k, d in { 3.2, 2.4, 1.6, 0.8 } do
		disco(-108, T + 13, -11.3 + k * 0.05, d, k % 2 == 1 and Color3.fromRGB(200, 60, 55) or Color3.fromRGB(240, 230, 210), k == 1)
	end
	plano(-107.5, T + 13.3, -10.9, 1.4, 0.2, NEGRO, false, nil, 20)
	plano(-103.5, T + 11, -11.2, 1.4, 0.2, NEGRO, false, nil, -10)
	-- cartel de se busca
	letrero(-116, T + 13.5, -11.2, 4, 4.6, "SE BUSCA\nREY HONGO\n500 oro", Color3.fromRGB(215, 200, 160), Color3.fromRGB(60, 40, 30))
	-- lámpara de velas que se balancea
	local lampara = Instance.new("Model")
	lampara.Name = "Lampara"
	lampara:SetAttribute("Flota", 0.8)
	lampara.Parent = raiz
	plano(-100, T + 22, -6, 0.2, 4, NEGRO, false, lampara)
	plano(-100, T + 19.8, -6, 7, 0.5, Color3.fromRGB(110, 70, 40), true, lampara)
	for k = -1, 1 do
		plano(-100 + k * 2.6, T + 20.6, -5.9, 0.5, 1.2, Color3.fromRGB(245, 240, 220), false, lampara)
		disco(-100 + k * 2.6, T + 21.5, -5.8, 0.6, Color3.fromRGB(255, 190, 70), false, lampara)
	end
	-- jamones colgando y un gato dormido junto a la chimenea
	for _, hx in { -95, -93.5 } do
		plano(hx, T + 18.5, -11, 0.15, 2, NEGRO, false)
		disco(hx, T + 17, -10.9, 1.3, Color3.fromRGB(190, 110, 90))
	end
	disco(-79.5, T + 0.6, -9.6, 1.6, Color3.fromRGB(140, 130, 130))
	disco(-78.6, T + 0.9, -9.5, 1, Color3.fromRGB(140, 130, 130))
	letrero(-78.4, T + 2.3, -9.4, 1.6, 0.8, "zzz", Color3.fromRGB(240, 230, 210), Color3.fromRGB(80, 70, 70))

	-- ---------- POSADA (Y = 340): cuadro del Gran Guiso, reloj, estantería y velas ----------
	local P, cx = 340, -20
	plano(cx - 8, P + 8, -11.4, 6, 4.4, Color3.fromRGB(150, 100, 55))
	plano(cx - 8, P + 8, -11.2, 5, 3.4, Color3.fromRGB(240, 210, 150), false)
	disco(cx - 8, P + 7.6, -11, 2.2, Color3.fromRGB(70, 66, 76), false)
	disco(cx - 8, P + 9.2, -10.9, 1, Color3.fromRGB(250, 248, 240), false)
	disco(cx + 8, P + 8.5, -11.3, 3, Color3.fromRGB(240, 230, 205))
	plano(cx + 8, P + 9.1, -11, 0.25, 1.4, NEGRO, false)
	plano(cx + 8.5, P + 8.5, -11, 1.1, 0.25, NEGRO, false)
	plano(cx + 14, P + 4, -11.2, 5, 8, Color3.fromRGB(120, 80, 50))
	for fila = 0, 2 do
		plano(cx + 14, P + 1.4 + fila * 2.4, -11, 5, 0.3, Color3.fromRGB(90, 60, 40), false)
		for k = -2, 2 do
			plano(cx + 14 + k * 0.9, P + 2.3 + fila * 2.4, -10.9, 0.7, 1.5, COLORES_FLOR[(k + fila) % #COLORES_FLOR + 1]:Lerp(NEGRO, 0.2), false)
		end
	end
	for _, vx in { cx - 16, cx - 12 } do
		plano(vx, P + 4, -7.4, 0.4, 1, Color3.fromRGB(245, 240, 220), false)
		disco(vx, P + 4.8, -7.3, 0.5, Color3.fromRGB(255, 190, 70), false)
	end
	disco(cx + 16.5, P + 2.6, -8.9, 1.4, Color3.fromRGB(240, 150, 60))
	disco(cx + 17.3, P + 2.9, -8.8, 0.9, Color3.fromRGB(240, 150, 60))

	-- ---------- BARBERÍA (ciudad) Y BAÑERA (posada): para quitarse la barba de tres años ----------
	plano(-152, 3.5, -11.6, 0.8, 7, Color3.fromRGB(240, 240, 235))
	for k = 0, 3 do
		plano(-152, 1 + k * 1.7, -11.4, 0.85, 0.5, Color3.fromRGB(200, 60, 60), false, nil, 30)
		plano(-152, 1.8 + k * 1.7, -11.4, 0.85, 0.5, Color3.fromRGB(70, 100, 180), false, nil, 30)
	end
	disco(-152, 7.4, -11.4, 1.2, Color3.fromRGB(240, 240, 235))
	letrero(-148, 6.2, -11.2, 6, 1.4, "Barbería", Color3.fromRGB(70, 100, 180), Color3.fromRGB(255, 245, 230))
	punto("barbero", Vector3.new(-147, 2.8, -9.5), { Npc = "vecino:8080", Frases = "¡Corte y afeitado!|Ese pelo pide tijera.|Pase, pase, que no muerdo." })
	plano(cx, P + 1.1, -9.4, 4.6, 2.2, Color3.fromRGB(235, 235, 240))
	plano(cx, P + 2.2, -9.2, 4.8, 0.4, Color3.fromRGB(200, 200, 210), false)
	disco(cx - 1.4, P + 2.4, -9, 0.9, Color3.fromRGB(250, 252, 255), false)
	disco(cx + 0.6, P + 2.5, -9, 1.1, Color3.fromRGB(250, 252, 255), false)
	disco(cx + 1.8, P + 3.3, -8.9, 0.6, Color3.fromRGB(255, 220, 90), false) -- patito
	punto("banera", Vector3.new(cx, P + 2.8, -8), {})

	-- ---------- TABLÓN DE ENCARGOS (plaza de la ciudad) ----------
	plano(-90, 2.5, -11.4, 0.6, 5, Color3.fromRGB(110, 70, 45))
	plano(-84, 2.5, -11.4, 0.6, 5, Color3.fromRGB(110, 70, 45))
	plano(-87, 5.2, -11.2, 8, 4.6, Color3.fromRGB(170, 120, 75))
	for k, d in { { -89.2, 5.8, -6 }, { -87, 4.6, 4 }, { -84.9, 5.9, 8 }, { -88.4, 4.2, -3 } } do
		plano(d[1], d[2], -10.9, 1.6, 1.8, k % 2 == 0 and Color3.fromRGB(250, 245, 225) or Color3.fromRGB(245, 225, 170), false, nil, d[3])
		disco(d[1], d[2] + 0.75, -10.7, 0.3, Color3.fromRGB(200, 60, 60), false)
	end
	letrero(-87, 8.2, -11, 6, 1.3, "Encargos", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 235, 170))
	punto("tablon", Vector3.new(-87, 2.8, -9.5))

	-- ---------- SECRETOS EN EL MUNDO ----------
	-- la olla del Gran Guiso de la plaza
	punto("secreto", Vector3.new(-78, 2.8, -11), { Secreto = "olla" })
	-- una puertecita en un árbol del Bosque
	plano(300, 1, -11.6, 1.6, 2, Color3.fromRGB(120, 75, 45))
	disco(300.5, 1, -11.3, 0.25, Color3.fromRGB(240, 200, 80), false)
	letrero(300, 2.6, -11.4, 3, 0.8, "No molestar", Color3.fromRGB(150, 95, 55))
	punto("secreto", Vector3.new(300, 2.8, -9.5), { Secreto = "puertecita" })
	-- un pato de goma perdido en el Pantano
	disco(232, 0.9, -10.5, 1.6, Color3.fromRGB(250, 210, 60))
	disco(232.9, 1.9, -10.4, 1.1, Color3.fromRGB(250, 210, 60))
	plano(233.7, 1.8, -10.2, 0.8, 0.35, Color3.fromRGB(240, 130, 50), false)
	punto("secreto", Vector3.new(232, 2.8, -9), { Secreto = "pato" })
	-- una piedra con cara en las Ruinas
	disco(395, 1.2, -11, 2.6, Color3.fromRGB(175, 170, 160))
	disco(394.4, 1.5, -10.7, 0.35, NEGRO, false)
	disco(395.6, 1.5, -10.7, 0.35, NEGRO, false)
	plano(395, 0.8, -10.7, 0.9, 0.2, NEGRO, false)
	punto("secreto", Vector3.new(395, 2.8, -9.5), { Secreto = "piedra" })
	-- los bordes del mundo (se acaba el cartón)
	letrero(-438, 4, -11, 8, 2.4, "Fin del cartón", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 235, 170))
	punto("secreto", Vector3.new(-438, 2.8, -9), { Secreto = "bordeOeste" })
	letrero(798, 4, -11, 9, 2.4, "Aquí se acabó el papel", Color3.fromRGB(150, 95, 55), Color3.fromRGB(255, 235, 170))
	punto("secreto", Vector3.new(798, 2.8, -9), { Secreto = "bordeEste" })
end

-- ===================== PICOS NEVADOS Y CUMBRE DEL YETI (historia 2, tres años después) =====================
local function picos(rng: Random)
	local NIEVE = Color3.fromRGB(240, 244, 250)
	-- montañas nevadas al fondo
	for _, d in { { 640, 70, 44 }, { 690, 90, 60 }, { 745, 80, 52 }, { 795, 70, 40 } } do
		tri(d[1], 0, -40, d[2], d[3], Color3.fromRGB(170, 185, 215))
		tri(d[1], d[3] * 0.62, -39.6, d[2] * 0.4, d[3] * 0.38, NIEVE, false)
	end
	-- pinos con nieve, montones de nieve y cristales de hielo
	for _ = 1, 16 do
		local x = rng:NextNumber(612, 800)
		if math.abs(x - Mundo.Guaridas.picos) > 9 and math.abs(x - Mundo.Guaridas.cumbre) > 10 and math.abs(x - 706) > 6 then
			pino(x, -15 + rng:NextNumber(-3, 1), rng:NextNumber(0.9, 1.4), Color3.fromRGB(60, 110, 95))
			tri(x, 7.6 * 1.1, -14.2, 3, 2, NIEVE, false)
		end
	end
	for _ = 1, 14 do
		disco(rng:NextNumber(610, 800), 0.6, rng:NextNumber(-12, -10), rng:NextNumber(2, 4), NIEVE)
	end
	for _, x in { 628, 676, 728, 784 } do
		tri(x, 0, -11.4, 1.6, 3.4, Color3.fromRGB(170, 220, 245))
		tri(x + 1.2, 0, -11.2, 1.1, 2.2, Color3.fromRGB(200, 235, 250))
	end
	-- iglú con humo y un lago helado con un pingüino pescando
	disco(645, 2, -18, 12, NIEVE)
	plano(645, 0.5, -17.6, 12.5, 1, NIEVE)
	for k = 0, 2 do
		plano(645, 1.2 + k * 1.6, -17.4, 11 - k * 2.5, 0.15, Color3.fromRGB(200, 210, 225), false)
	end
	plano(641, 1.6, -17.2, 3, 3.2, Color3.fromRGB(60, 70, 90))
	local lago = plano(700, 0.07, -6, 18, 0.1, Color3.fromRGB(170, 215, 240), false)
	lago.Size = Vector3.new(18, 0.1, 6)
	lago.Transparency = 0.2
	letrero(612, 6, -11, 9, 2, "Picos Nevados", Color3.fromRGB(90, 120, 160), Color3.fromRGB(240, 248, 255))

	-- barrera 5: la nieve hasta las rodillas (Cueva → Picos): hacen falta las BOTAS DE NIEVE
	local cerrado, abierto = barrera("botas", 606)
	for k = 0, 8 do
		disco(606 + (k % 2) * 1.5, 1.5 + (k % 3) * 1.2, -11 + k * 2.6, 5, NIEVE, true, cerrado)
	end
	letrero(598, 6.5, -11, 11, 2, "Nieve hasta las rodillas: hacen falta botas", Color3.fromRGB(90, 120, 160), Color3.fromRGB(240, 248, 255), cerrado)
	for k = 0, 3 do
		plano(606, 0.3, -10 + k * 6, 2.4, 0.6, Color3.fromRGB(150, 110, 80), true, abierto)
	end

	-- barrera 6: el muro de hielo (Picos → Cumbre): hace falta el PICO DE HIELO
	cerrado, abierto = barrera("pico", 712)
	for k = 0, 5 do
		local hielo = plano(712 + (k % 2) * 0.8, 8, -11 + k * 4.4, 4, 16, Color3.fromRGB(160, 210, 240), true, cerrado)
		hielo.Transparency = 0.25
	end
	letrero(704, 7, -11, 11, 2, "Muro de hielo: hace falta un pico", Color3.fromRGB(70, 110, 150), Color3.fromRGB(240, 248, 255), cerrado)
	for k = 0, 3 do
		tri(712 + (k % 2) * 2, 0, -10 + k * 6, 2, 1.6, Color3.fromRGB(180, 220, 245), true, abierto)
	end
	-- el guardián del muro (pingüinos bandidos) y el cofre del pico
	cofre(700, 0, -11)
	punto("cofrePico", Vector3.new(700, 1.5, -10))

	-- la cueva del Yeti en la cumbre, con la Olla del Gran Guiso congelada en la puerta
	local gx = Mundo.Guaridas.cumbre
	tri(gx, 0, -18, 70, 40, Color3.fromRGB(180, 195, 225))
	tri(gx, 24, -17.6, 30, 16, NIEVE, false)
	disco(gx, 3, -16.5, 14, Color3.fromRGB(30, 35, 50))
	for k = -2, 2 do
		tri(gx + k * 2.8, 9.6, -16, 1.6, -3, Color3.fromRGB(200, 235, 250), true)
	end
	letrero(gx, 17, -16, 13, 2.4, "Cueva del Yeti Tragón", Color3.fromRGB(70, 110, 150), Color3.fromRGB(240, 248, 255))
	-- la olla atrapada en un bloque de hielo
	disco(gx + 14, 3, -13, 6, Color3.fromRGB(70, 66, 76))
	plano(gx + 14, 5.6, -12.8, 7, 0.8, Color3.fromRGB(85, 82, 92))
	local bloque = plano(gx + 14, 3.6, -12.4, 9, 7.4, Color3.fromRGB(170, 220, 245), true)
	bloque.Transparency = 0.45
	letrero(gx + 14, 9.4, -12.2, 8, 1.6, "¡La Olla!", Color3.fromRGB(190, 80, 60), Color3.fromRGB(255, 240, 200))
	-- copos de nieve que caen (usan el balanceo de "Flota" del cliente)
	for k = 1, 18 do
		local m = Instance.new("Model")
		m.Name = "Copo"
		m:SetAttribute("Flota", rng:NextNumber(0.5, 1.4))
		m.Parent = raiz
		disco(rng:NextNumber(610, 805), rng:NextNumber(6, 30), rng:NextNumber(-20, -14), rng:NextNumber(0.5, 1), NIEVE, false, m)
	end
	-- el Rey Hongo, ahora cocinero arrepentido, en la entrada de su cueva (punto para hablar con él)
	punto("reyHongoNpc", Vector3.new(552, 2.8, -10))
end

function Mundo.construir(): { [BasePart]: any }
	local zonas: { [BasePart]: any } = {}
	local existente = workspace:FindFirstChild("MundoVael")
	if existente then
		raiz = existente :: Folder
		for _, d in raiz:GetDescendants() do
			if d:IsA("BasePart") and d:GetAttribute("Zona") then
				for _, z in Datos.Zonas do
					if z.id == d:GetAttribute("Zona") then
						zonas[d] = z
					end
				end
			end
		end
		return zonas
	end

	raiz = Instance.new("Folder")
	raiz.Name = "MundoVael"
	pasto = Instance.new("Folder")
	pasto.Name = "Pasto"
	pasto.Parent = raiz
	local rng = Random.new(2026)

	luces()
	-- la placa gris de la plantilla Baseplate no pega con el dibujo: se esconde (el suelo es nuestro)
	local placa = workspace:FindFirstChild("Baseplate")
	if placa and placa:IsA("BasePart") then
		placa.Transparency = 1
		placa.CanCollide = false
		for _, h in placa:GetChildren() do
			if h:IsA("Texture") or h:IsA("Decal") then
				h:Destroy()
			end
		end
	end
	for _, d in workspace:GetDescendants() do
		if d:IsA("SpawnLocation") then
			d.Enabled = false
			d.Transparency = 1
			d.CanCollide = false
			for _, h in d:GetChildren() do
				if h:IsA("Decal") then
					h:Destroy()
				end
			end
		end
	end

	cielo()
	fondoLejano(rng)
	suelo()
	ciudad(rng)
	pradera(rng)
	pantano(rng)
	bosque(rng)
	ruinas(rng)
	cueva(rng)
	picos(rng)
	fondoVivo(rng)
	pastoPorTodas(rng)
	exploracion(rng)
	aldea(rng)
	taberna()
	posada()
	calles(rng)
	extras(rng)

	local sp = Instance.new("SpawnLocation")
	sp.Anchored = true
	sp.Size = Vector3.new(6, 1, 6)
	sp.Position = Vector3.new(Mundo.Aparicion, 0.5, 2)
	sp.Transparency = 1
	sp.CanCollide = false
	sp.Neutral = true
	sp.Duration = 0
	sp.Parent = raiz

	for _, z in Datos.Zonas do
		zonas[guarida(z)] = z
	end
	-- todo a cartulina (textura de cartón, sin neón, colores apagados)
	Datos.encartonar(raiz, NEGRO)
	raiz.Parent = workspace
	return zonas
end

return Mundo
