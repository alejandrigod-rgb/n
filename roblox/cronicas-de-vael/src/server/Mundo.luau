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
Mundo.Guaridas = { huerto = -262, pradera = 110, pantano = 215, bosque = 315, ruinas = 415, cueva = 540 }
Mundo.Inicio = -60 -- x de la plaza de la ciudad
Mundo.Aparicion = -395 -- se empieza en la Aldea de Brezo, a las afueras
Mundo.Limites = { -445, 605 }

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

local function farola(x: number, z: number)
	plano(x, 4.5, z, 0.6, 9, Color3.fromRGB(50, 50, 60))
	plano(x, 9.2, z + 0.2, 1.8, 0.5, Color3.fromRGB(50, 50, 60))
	local luz = disco(x, 9.9, z + 0.3, 1.5, Color3.fromRGB(255, 225, 120))
	luz.Material = Enum.Material.Neon
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
	cc.Saturation = -0.18
	cc.Contrast = -0.12
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
	s.Size = Vector3.new(1100, 4, 70)
	s.Position = Vector3.new(85, -1.95, -21)
	s.Color = Color3.fromRGB(112, 190, 82)
	s.Parent = raiz
	-- borde delantero de tierra (el corte del papel)
	plano(85, -6, 14.6, 1100, 12, Color3.fromRGB(125, 85, 55))
	plano(85, -0.3, 14.9, 1100, 1, Color3.fromRGB(85, 155, 62), false)
	for k = 0, 103 do
		disco(-460 + k * 10.6, -4 - (k % 3) * 2.5, 15, 1.2 + (k % 4) * 0.4, Color3.fromRGB(100, 68, 45), false)
	end
	-- camino de tierra
	local camino = plano(85, 0.06, 1, 1100, 0.1, Color3.fromRGB(225, 200, 140), false)
	camino.Size = Vector3.new(1100, 0.1, 6)
	-- paredes invisibles para quedarse en el carril (como en un juego 2D con algo de fondo)
	for _, datos in { { 85, -12.8, 1100, 1 }, { 85, 10.8, 1100, 1 } } do
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
	mancha(462, 610, Color3.fromRGB(110, 105, 100))
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
	pastoPorTodas(rng)
	exploracion(rng)
	aldea(rng)
	taberna()
	posada()

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
