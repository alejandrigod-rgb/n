--!nonstrict
-- Crónicas de Vael · portada y prólogo (todo dibujado con Frames, sin imágenes, estilo cartulina).
--  · Portada.fondo(capa, Munecos): el fondo animado de la pantalla de inicio. Es un teatrillo de papel: el telón
--    se abre y detrás está el valle de Vael (sol con rayos, nubes, montañas, el castillo-seta del Rey Hongo con el
--    Cucharón de bandera, colinas que se mecen, casas con humo, un molino, un globo, pájaros y banderines).
--  · Portada.prologo(gui, Munecos, apariencia, alTerminar): la historia contada como un libro de cuentos animado.
--
-- LA HISTORIA (la cuentan el prólogo, la abuela Rosa y los vecinos):
--   Cada otoño, Vael celebra la Fiesta del Gran Guiso, que se remueve con el Cucharón de Vael. El ingrediente
--   secreto son setas… y a las setas nadie les preguntó. Este año el Rey Hongo se hartó: robó el Cucharón y se
--   lo puso de corona. Sin él, el guiso se pudre y sus esporas ponen rabiosos a los bichos del valle (por eso hay
--   peleas por todas partes). Tú eres el nuevo de la aldea, y Vael no tiene a nadie más.

local RunService = game:GetService("RunService")

local Ui = require(script.Parent:WaitForChild("Ui"))

local Portada = {}

local TINTA = Color3.fromRGB(48, 38, 34)

local function caja(padre: Instance, props: { [string]: any }): Frame
	props.BorderSizePixel = 0
	props.Parent = padre
	return Ui.crear("Frame", props)
end

--- Círculo (o cuadrado/rombo) que no se deforma: su tamaño va en proporción a la altura del padre.
local function redondo(padre: Instance, x: number, y: number, d: number, color: Color3, z: number, borde: number?): Frame
	local f = caja(padre, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(d, d), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundColor3 = color, ZIndex = z })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = f })
	if borde then
		Ui.borde(f, TINTA, borde)
	end
	return f
end

local function rombo(padre: Instance, x: number, y: number, d: number, color: Color3, z: number, borde: number?): Frame
	local f = caja(padre, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(d, d), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundColor3 = color, Rotation = 45, ZIndex = z })
	if borde then
		Ui.borde(f, TINTA, borde)
	end
	return f
end

-- ---------- piezas de decorado que se usan en la portada y en el prólogo ----------

--- Casita: devuelve el contenedor y la posición de la chimenea (para el humo).
local function casita(padre: Instance, x: number, yBase: number, alto: number, pared: Color3, techo: Color3, z: number): (Frame, Frame)
	local c = caja(padre, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(x, yBase), Size = UDim2.fromScale(alto * 0.78, alto), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = z })
	local chimenea = caja(c, { Position = UDim2.fromScale(0.62, 0.12), Size = UDim2.fromScale(0.14, 0.3), BackgroundColor3 = Color3.fromRGB(140, 90, 70), ZIndex = z })
	Ui.borde(chimenea, TINTA, 2)
	local tejado = caja(c, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromScale(0.72, 0.72), SizeConstraint = Enum.SizeConstraint.RelativeXX, BackgroundColor3 = techo, Rotation = 45, ZIndex = z + 1 })
	Ui.borde(tejado, TINTA, 2.5)
	local muro = caja(c, { Position = UDim2.fromScale(0.1, 0.45), Size = UDim2.fromScale(0.8, 0.55), BackgroundColor3 = pared, ZIndex = z + 2 })
	Ui.borde(muro, TINTA, 2.5)
	caja(muro, { Position = UDim2.fromScale(0.12, 0.45), Size = UDim2.fromScale(0.28, 0.55), BackgroundColor3 = Color3.fromRGB(120, 75, 45), ZIndex = z + 3 })
	for k = 0, 1 do
		local v = caja(muro, { Position = UDim2.fromScale(0.55 + k * 0.2, 0.22), Size = UDim2.fromScale(0.16, 0.26), BackgroundColor3 = Color3.fromRGB(255, 220, 130), ZIndex = z + 3 })
		v:SetAttribute("Ventana", true)
	end
	return c, chimenea
end

--- Olla gigante del Gran Guiso.
local function olla(padre: Instance, x: number, yBase: number, d: number, color: Color3, z: number): Frame
	local c = caja(padre, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(x, yBase), Size = UDim2.fromScale(d, d * 0.85), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = z })
	for _, dx in { 0.18, 0.72 } do
		caja(c, { Position = UDim2.fromScale(dx, 0.8), Size = UDim2.fromScale(0.1, 0.2), BackgroundColor3 = Color3.fromRGB(60, 58, 66), ZIndex = z })
	end
	local cuerpo = caja(c, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.92), Size = UDim2.fromScale(1, 0.82), BackgroundColor3 = color, ZIndex = z + 1 })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.45, 0), Parent = cuerpo })
	Ui.borde(cuerpo, TINTA, 3)
	local borde = caja(c, { Position = UDim2.fromScale(-0.06, 0.08), Size = UDim2.fromScale(1.12, 0.12), BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.15), ZIndex = z + 2 })
	Ui.esquinas(borde, 6)
	Ui.borde(borde, TINTA, 3)
	return c
end

--- El Cucharón de Vael (mango + cazo). Gira desde el centro del contenedor.
local function cucharon(padre: Instance, x: number, y: number, largo: number, z: number, rot: number?): Frame
	local c = caja(padre, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(largo, largo), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, Rotation = rot or 0, ZIndex = z })
	local mango = caja(c, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.1, 0.72), BackgroundColor3 = Color3.fromRGB(190, 140, 80), ZIndex = z })
	Ui.esquinas(mango, 4)
	Ui.borde(mango, TINTA, 2.5)
	local cazo = caja(c, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(0.42, 0.34), BackgroundColor3 = Color3.fromRGB(205, 155, 90), ZIndex = z + 1 })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = cazo })
	Ui.borde(cazo, TINTA, 2.5)
	-- brillo de "objeto mágico"
	redondo(cazo, 0.32, 0.35, 0.22, Color3.fromRGB(255, 240, 200), z + 2)
	return c
end

--- Cartelito de onomatopeya (¡BUM!, ¡LADRÓN!…).
local function onomatopeya(padre: Instance, texto: string, x: number, y: number, color: Color3, z: number): TextLabel
	local t = Ui.crear("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(0.3, 0.16), BackgroundTransparency = 1, Text = texto, Font = Enum.Font.Bangers, TextScaled = true, TextColor3 = color, Rotation = -8, ZIndex = z, Parent = padre })
	Ui.crear("UIStroke", { Thickness = 4, Color = TINTA, Parent = t })
	local escala = Ui.crear("UIScale", { Scale = 0, Parent = t })
	Ui.tween(escala, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
	return t
end

-- ---------- bucle de animación (uno por pantalla; se para solo cuando la pantalla desaparece) ----------
type Anim = (t: number, dt: number) -> ()
local function animar(raiz: Instance, pasos: { Anim })
	local t0 = os.clock()
	local con
	con = RunService.RenderStepped:Connect(function(dt)
		if not raiz.Parent then
			con:Disconnect()
			return
		end
		local t = os.clock() - t0
		for _, f in pasos do
			f(t, dt)
		end
	end)
end

--- Bocanadas de humo que salen de una chimenea (dentro del contenedor de la casa).
local function humo(chimenea: Frame, pasos: { Anim }, z: number)
	local casa = chimenea.Parent :: Frame
	local bocanadas = {}
	for k = 1, 4 do
		bocanadas[k] = redondo(casa, 0.69, 0.1, 0.12, Color3.fromRGB(230, 226, 218), z)
	end
	table.insert(pasos, function(t)
		for k, b in bocanadas do
			local fase = (t * 0.22 + k / 4) % 1
			b.Position = UDim2.fromScale(0.69 + fase * 0.35, 0.1 - fase * 0.75)
			b.Size = UDim2.fromScale(0.08 + fase * 0.16, 0.08 + fase * 0.16)
			b.BackgroundTransparency = 0.1 + fase * 0.9
		end
	end)
end

local function nube(padre: Instance, x: number, y: number, e: number, z: number): Frame
	local c = caja(padre, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(0.22 * e, 0.1 * e), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = z })
	local blanco = Color3.fromRGB(250, 246, 236)
	local base = caja(c, { Position = UDim2.fromScale(0.05, 0.5), Size = UDim2.fromScale(0.9, 0.45), BackgroundColor3 = blanco, ZIndex = z })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = base })
	Ui.borde(base, TINTA, 2)
	for _, d in { { 0.3, 0.5, 0.75 }, { 0.55, 0.38, 1 }, { 0.75, 0.55, 0.7 } } do
		local b = caja(c, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(d[1], d[2]), Size = UDim2.fromScale(d[3] * 0.45, d[3]), BackgroundColor3 = blanco, ZIndex = z })
		Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = b })
		Ui.borde(b, TINTA, 2)
	end
	-- tapa los bordes interiores para que parezca una sola nube
	local tapa = caja(c, { Position = UDim2.fromScale(0.08, 0.52), Size = UDim2.fromScale(0.84, 0.36), BackgroundColor3 = blanco, ZIndex = z })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = tapa })
	return c
end

--- Pájaro de dos trazos que aletea.
local function pajaro(padre: Instance, z: number): (Frame, (t: number) -> ())
	local c = caja(padre, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromScale(0.04, 0.02), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = z })
	local a = caja(c, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 0.18), BackgroundColor3 = TINTA, ZIndex = z })
	local b = caja(c, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 0.18), BackgroundColor3 = TINTA, ZIndex = z })
	return c, function(t)
		local ala = math.sin(t * 9) * 25
		a.Rotation = 20 + ala
		b.Rotation = -20 - ala
	end
end

local COLORES_BANDERIN = { Color3.fromRGB(220, 90, 75), Color3.fromRGB(240, 200, 80), Color3.fromRGB(110, 160, 210), Color3.fromRGB(140, 190, 100), Color3.fromRGB(200, 130, 190) }

--- Guirnalda de banderines colgando (se mece).
local function banderines(padre: Instance, x0: number, x1: number, y: number, comba: number, z: number, pasos: { Anim })
	local lista = {}
	local n = 18
	for k = 0, n do
		local u = k / n
		local f = rombo(padre, x0 + (x1 - x0) * u, y + math.sin(u * math.pi) * comba, 0.035, COLORES_BANDERIN[k % #COLORES_BANDERIN + 1], z, 2)
		table.insert(lista, { f = f, u = u })
	end
	table.insert(pasos, function(t)
		for _, b in lista do
			b.f.Rotation = 45 + math.sin(t * 2 + b.u * 8) * 8
		end
	end)
end

-- =====================================================================================
-- PORTADA (fondo de la pantalla de inicio)
-- =====================================================================================
function Portada.fondo(capa: Frame, Munecos: any?): Frame
	local raiz = caja(capa, { Name = "Portada", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(170, 200, 212), ClipsDescendants = true, ZIndex = 100 })
	Ui.crear("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(150, 185, 205), Color3.fromRGB(236, 224, 198)), Parent = raiz })
	local pasos: { Anim } = {}
	local Z = 100

	-- sol con rayos que giran
	local rayos = {}
	for k = 0, 5 do
		local r = caja(raiz, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.13, 0.2), Size = UDim2.fromScale(0.34, 0.014), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundColor3 = Color3.fromRGB(250, 215, 120), ZIndex = Z })
		table.insert(rayos, { f = r, base = k * 30 })
	end
	local sol = redondo(raiz, 0.13, 0.2, 0.17, Color3.fromRGB(250, 205, 95), Z + 1, 3)
	-- carita del sol (es un cuento, el sol también mira)
	redondo(sol, 0.36, 0.42, 0.09, TINTA, Z + 2)
	redondo(sol, 0.64, 0.42, 0.09, TINTA, Z + 2)
	local boca = caja(sol, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.66), Size = UDim2.fromScale(0.3, 0.06), BackgroundColor3 = TINTA, ZIndex = Z + 2 })
	Ui.esquinas(boca, 4)
	table.insert(pasos, function(t)
		for _, r in rayos do
			r.f.Rotation = r.base + t * 12
		end
		sol.Rotation = math.sin(t * 0.8) * 4
	end)

	-- nubes que cruzan
	local nubes = {}
	for k, d in { { 0.32, 0.14, 1.1 }, { 0.62, 0.09, 0.8 }, { 0.9, 0.2, 1.2 }, { 0.05, 0.33, 0.7 } } do
		table.insert(nubes, { f = nube(raiz, d[1], d[2], d[3], Z + 1), x = d[1], y = d[2], v = 0.008 + k * 0.003 })
	end
	table.insert(pasos, function(t)
		for _, n in nubes do
			n.f.Position = UDim2.fromScale((n.x + t * n.v) % 1.3 - 0.15, n.y + math.sin(t * 0.5 + n.x * 9) * 0.006)
		end
	end)

	-- montañas lejanas con nieve
	for _, m in { { 0.02, 0.5 }, { 0.2, 0.62 }, { 0.42, 0.48 }, { 0.6, 0.58 }, { 0.8, 0.5 } } do
		local cx, d = m[1], m[2]
		local cy = 0.78
		rombo(raiz, cx, cy, d, Color3.fromRGB(150, 165, 200), Z + 2, 3)
		local cima = cy - d * 0.707
		rombo(raiz, cx, cima + d * 0.3 * 0.707, d * 0.3, Color3.fromRGB(248, 248, 252), Z + 3)
	end

	-- el castillo-seta del Rey Hongo, al fondo a la derecha, con el Cucharón de bandera
	redondo(raiz, 0.9, 0.98, 0.6, Color3.fromRGB(125, 112, 125), Z + 4, 3)
	local seta = caja(raiz, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.89, 0.72), Size = UDim2.fromScale(0.3, 0.42), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = Z + 5 })
	local pie = caja(seta, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(0.34, 0.6), BackgroundColor3 = Color3.fromRGB(236, 226, 200), ZIndex = Z + 5 })
	Ui.borde(pie, TINTA, 3)
	caja(pie, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(0.4, 0.3), BackgroundColor3 = Color3.fromRGB(110, 75, 50), ZIndex = Z + 6 })
	local ojos = {}
	for _, ox in { 0.3, 0.7 } do
		table.insert(ojos, caja(pie, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(ox, 0.35), Size = UDim2.fromScale(0.2, 0.12), BackgroundColor3 = Color3.fromRGB(190, 240, 140), ZIndex = Z + 6 }))
	end
	local recorte = caja(seta, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.12), Size = UDim2.fromScale(1, 0.36), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = Z + 6 })
	local copa = caja(recorte, { Size = UDim2.fromScale(1, 2), BackgroundColor3 = Color3.fromRGB(200, 62, 58), ZIndex = Z + 6 })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = copa })
	Ui.borde(copa, TINTA, 3)
	for _, d in { { 0.25, 0.2, 0.14 }, { 0.55, 0.12, 0.1 }, { 0.75, 0.26, 0.12 }, { 0.42, 0.34, 0.08 } } do
		local p = caja(copa, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(d[1], d[2]), Size = UDim2.fromScale(d[3], d[3]), SizeConstraint = Enum.SizeConstraint.RelativeXX, BackgroundColor3 = Color3.fromRGB(250, 240, 228), ZIndex = Z + 7 })
		Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = p })
	end
	caja(seta, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.13), Size = UDim2.fromScale(0.015, 0.2), BackgroundColor3 = TINTA, ZIndex = Z + 5 })
	local bandera = cucharon(seta, 0.6, -0.08, 0.16, Z + 6, 70)
	-- esporas verdes alrededor del castillo
	local esporas = {}
	for k = 1, 9 do
		table.insert(esporas, { f = redondo(raiz, 0, 0, 0.012 + (k % 3) * 0.006, Color3.fromRGB(190, 230, 140), Z + 7), x = 0.8 + (k * 0.037) % 0.2, y = 0.3 + (k * 0.11) % 0.35, v = 0.4 + (k % 4) * 0.2 })
	end
	table.insert(pasos, function(t)
		seta.Position = UDim2.fromScale(0.89, 0.72 + math.sin(t * 1.3) * 0.006)
		bandera.Rotation = 70 + math.sin(t * 2.2) * 10
		local parpadeo = (t % 4) < 0.15
		for _, o in ojos do
			o.Size = UDim2.fromScale(0.2, parpadeo and 0.02 or 0.12)
		end
		for _, e in esporas do
			e.f.Position = UDim2.fromScale(e.x + math.sin(t * e.v + e.y * 10) * 0.02, e.y - ((t * 0.02 * e.v) % 0.3))
		end
	end)

	-- colinas que se mecen (parallax suave)
	local capas = {}
	for capaN, datos in { { 0.92, 0.62, Color3.fromRGB(135, 195, 115), 0.012 }, { 1.03, 0.55, Color3.fromRGB(110, 178, 92), 0.02 } } do
		local fila = caja(raiz, { Size = UDim2.fromScale(1.2, 1), Position = UDim2.fromScale(-0.1, 0), BackgroundTransparency = 1, ZIndex = Z + 7 + capaN * 4 })
		for k = 0, 6 do
			redondo(fila, k * 0.18 + (capaN - 1) * 0.08, datos[1], datos[2], datos[3], Z + 7 + capaN * 4, 3)
		end
		table.insert(capas, { f = fila, a = datos[4], v = 0.25 + capaN * 0.1 })
	end
	table.insert(pasos, function(t)
		for _, c in capas do
			c.f.Position = UDim2.fromScale(-0.1 + math.sin(t * c.v) * c.a, 0)
		end
	end)

	-- el pueblo: casas con humo y un molino
	local pared = { Color3.fromRGB(245, 228, 195), Color3.fromRGB(205, 222, 238), Color3.fromRGB(240, 205, 195), Color3.fromRGB(215, 232, 200) }
	local techo = { Color3.fromRGB(190, 80, 65), Color3.fromRGB(80, 110, 165), Color3.fromRGB(145, 85, 135), Color3.fromRGB(90, 140, 90) }
	local casas = { { 0.05, 0.2 }, { 0.15, 0.25 }, { 0.25, 0.18 }, { 0.71, 0.22 }, { 0.8, 0.17 } }
	for k, c in casas do
		local _, chimenea = casita(raiz, c[1], 0.88, c[2], pared[k % 4 + 1], techo[k % 4 + 1], Z + 20)
		humo(chimenea, pasos, Z + 19)
	end
	-- molino
	local torre = caja(raiz, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.35, 0.88), Size = UDim2.fromScale(0.07, 0.26), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundColor3 = Color3.fromRGB(240, 230, 210), ZIndex = Z + 20 })
	Ui.borde(torre, TINTA, 3)
	rombo(raiz, 0.35, 0.62, 0.065, Color3.fromRGB(190, 80, 65), Z + 19, 3)
	local aspas = {}
	for k = 0, 1 do
		local a = caja(raiz, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.35, 0.66), Size = UDim2.fromScale(0.3, 0.035), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundColor3 = Color3.fromRGB(235, 225, 195), ZIndex = Z + 22 })
		Ui.borde(a, TINTA, 2.5)
		table.insert(aspas, { f = a, base = k * 90 })
	end
	redondo(raiz, 0.35, 0.66, 0.03, Color3.fromRGB(120, 75, 45), Z + 23, 2)
	table.insert(pasos, function(t)
		for _, a in aspas do
			a.f.Rotation = a.base + t * 40
		end
	end)

	-- la olla del Gran Guiso, fría, con su cartel
	olla(raiz, 0.6, 0.9, 0.13, Color3.fromRGB(70, 66, 76), Z + 22)
	local cartel = Ui.crear("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.6, 0.79), Size = UDim2.fromScale(0.13, 0.05), BackgroundColor3 = Color3.fromRGB(200, 85, 65), BorderSizePixel = 0, Text = "¡APLAZADA!", Font = Enum.Font.Bangers, TextScaled = true, TextColor3 = Color3.fromRGB(255, 240, 210), Rotation = 6, ZIndex = Z + 24, Parent = raiz })
	Ui.borde(cartel, TINTA, 2.5)
	table.insert(pasos, function(t)
		cartel.Rotation = 6 + math.sin(t * 1.6) * 3
	end)

	-- globo que flota
	local globo = caja(raiz, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromScale(0.09, 0.15), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = Z + 3 })
	local tela = caja(globo, { Size = UDim2.fromScale(1, 0.68), BackgroundColor3 = Color3.fromRGB(220, 110, 90), ZIndex = Z + 3 })
	Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = tela })
	Ui.borde(tela, TINTA, 2.5)
	caja(tela, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.22, 1), BackgroundColor3 = Color3.fromRGB(250, 232, 195), ZIndex = Z + 4 })
	local cesta = caja(globo, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(0.35, 0.16), BackgroundColor3 = Color3.fromRGB(150, 100, 60), ZIndex = Z + 3 })
	Ui.borde(cesta, TINTA, 2)
	table.insert(pasos, function(t)
		globo.Position = UDim2.fromScale(0.5 + math.sin(t * 0.15) * 0.25, 0.3 + math.sin(t * 0.9) * 0.02)
	end)

	-- pájaros
	local bandada = {}
	for k = 1, 3 do
		local f, aletear = pajaro(raiz, Z + 3)
		table.insert(bandada, { f = f, aletear = aletear, k = k })
	end
	table.insert(pasos, function(t)
		for _, p in bandada do
			local x = ((t * 0.04 + p.k * 0.05) % 1.4) - 0.2
			p.f.Position = UDim2.fromScale(x, 0.28 + p.k * 0.03 + math.sin(t * 2 + p.k) * 0.01)
			p.aletear(t + p.k)
		end
	end)

	-- hierba delantera (por donde desfilan los héroes)
	local hierba = caja(raiz, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 0.14), BackgroundColor3 = Color3.fromRGB(96, 165, 72), ZIndex = Z + 30 })
	Ui.borde(hierba, TINTA, 3)
	local matas = {}
	for k = 0, 40 do
		local m = caja(raiz, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(k / 40, 0.875), Size = UDim2.fromScale(0.012, 0.035 + (k % 3) * 0.012), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundColor3 = Color3.fromRGB(80, 150, 62), ZIndex = Z + 31 })
		table.insert(matas, { f = m, k = k })
	end
	table.insert(pasos, function(t)
		for _, m in matas do
			m.f.Rotation = math.sin(t * 2 + m.k * 0.7) * 12
		end
	end)

	-- banderines arriba
	banderines(raiz, 0.02, 0.98, 0.05, 0.06, Z + 40, pasos)

	-- el telón del teatrillo: se abre al empezar
	local rojo = Color3.fromRGB(165, 55, 50)
	local telones = {}
	for lado = 0, 1 do
		local tel = caja(raiz, { AnchorPoint = Vector2.new(lado, 0), Position = UDim2.fromScale(lado, 0), Size = UDim2.fromScale(0.52, 1), BackgroundColor3 = rojo, ZIndex = Z + 50 })
		Ui.borde(tel, TINTA, 3)
		for k = 0, 5 do
			caja(tel, { Position = UDim2.fromScale(k / 6 + 0.06, 0), Size = UDim2.fromScale(0.035, 1), BackgroundColor3 = rojo:Lerp(TINTA, 0.3), ZIndex = Z + 51 })
		end
		table.insert(telones, tel)
	end
	local cenefa = caja(raiz, { Size = UDim2.fromScale(1, 0.05), BackgroundColor3 = rojo:Lerp(TINTA, 0.1), ZIndex = Z + 52 })
	Ui.borde(cenefa, TINTA, 3)
	for k = 0, 24 do
		redondo(cenefa, k / 24, 1, 0.9, rojo:Lerp(TINTA, 0.1), Z + 52)
	end
	cenefa.ZIndex = Z + 53
	task.delay(0.35, function()
		for _, tel in telones do
			Ui.tween(tel, { Size = UDim2.fromScale(0.08, 1) }, 1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
		end
	end)

	animar(raiz, pasos)
	return raiz
end

-- =====================================================================================
-- PRÓLOGO (libro de cuentos animado)
-- =====================================================================================
type Lamina = { texto: string, cielo: Color3, dibujar: (l: Frame, M: any, pasos: { Anim }, apariencia: any) -> () }

local function suelo(l: Frame, color: Color3, z: number)
	local s = caja(l, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 0.22), BackgroundColor3 = color, ZIndex = z })
	Ui.borde(s, TINTA, 3)
end

local function muneco(l: Frame, M: any, tipo: string, id: string, x: number, yBase: number, alto: number, z: number, apariencia: any?): (any, Frame)
	local f = caja(l, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(x, yBase), Size = UDim2.fromScale(alto * 0.8, alto), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = z })
	local m = M and M.crear(f, tipo, id, 3, apariencia) or nil
	return m, f
end

local LAMINAS: { Lamina } = {
	{
		texto = "Esto es Vael: un valle tranquilo donde lo más emocionante del año es la Fiesta del Gran Guiso.",
		cielo = Color3.fromRGB(175, 205, 215),
		dibujar = function(l, M, pasos)
			for k, x in { 0.12, 0.3, 0.75, 0.9 } do
				local _, ch = casita(l, x, 0.8, 0.32, Color3.fromRGB(240, 222, 190), k % 2 == 0 and Color3.fromRGB(190, 80, 65) or Color3.fromRGB(80, 110, 165), 10)
				humo(ch, pasos, 9)
			end
			banderines(l, 0.05, 0.95, 0.12, 0.08, 30, pasos)
			suelo(l, Color3.fromRGB(110, 178, 85), 15)
			olla(l, 0.52, 0.84, 0.32, Color3.fromRGB(70, 66, 76), 20)
			-- vapor del guiso
			local vapor = {}
			for k = 1, 5 do
				vapor[k] = redondo(l, 0.5, 0.4, 0.06, Color3.fromRGB(250, 248, 240), 19)
			end
			table.insert(pasos, function(t)
				for k, v in vapor do
					local fase = (t * 0.3 + k / 5) % 1
					v.Position = UDim2.fromScale(0.47 + k * 0.012 + math.sin(t * 2 + k) * 0.02, 0.55 - fase * 0.4)
					v.BackgroundTransparency = fase
				end
			end)
			-- vecinos que bailan alrededor
			local bailan = {}
			for k, d in { { 0.25, "12" }, { 0.37, "88" }, { 0.68, "403" }, { 0.8, "1955" } } do
				local m, f = muneco(l, M, "vecino", d[2], d[1], 0.86, 0.3, 25)
				if m then
					m.mirar = d[1] < 0.5 and 1 or -1
					M.espejo(m, d[1] > 0.5)
				end
				table.insert(bailan, { f = f, x = d[1], k = k })
			end
			table.insert(pasos, function(t)
				for _, b in bailan do
					b.f.Position = UDim2.fromScale(b.x, 0.86 - math.abs(math.sin(t * 4 + b.k)) * 0.05)
					b.f.Rotation = math.sin(t * 4 + b.k) * 8
				end
			end)
		end,
	},
	{
		texto = "Cada otoño, todo el pueblo remueve el guiso con el Cucharón de Vael. Con él, sale el guiso más rico del mundo.",
		cielo = Color3.fromRGB(235, 200, 150),
		dibujar = function(l, M, pasos)
			suelo(l, Color3.fromRGB(150, 110, 75), 5)
			olla(l, 0.5, 0.9, 0.5, Color3.fromRGB(70, 66, 76), 10)
			local cu = cucharon(l, 0.5, 0.38, 0.5, 8, 15)
			local brillos = {}
			for k = 1, 6 do
				brillos[k] = rombo(l, 0, 0, 0.03, Color3.fromRGB(255, 235, 140), 30, 2)
			end
			local _, abuela = muneco(l, M, "vecino", "1955", 0.18, 0.9, 0.42, 20)
			local _, nino = muneco(l, M, "vecino", "777", 0.83, 0.9, 0.34, 20)
			local _ = nino
			table.insert(pasos, function(t)
				cu.Rotation = math.sin(t * 2.5) * 25
				cu.Position = UDim2.fromScale(0.5 + math.sin(t * 2.5) * 0.05, 0.38)
				for k, b in brillos do
					local a = t * 1.5 + k
					b.Position = UDim2.fromScale(0.5 + math.cos(a) * 0.22, 0.3 + math.sin(a * 1.3) * 0.12)
					b.Rotation = 45 + t * 90
				end
				abuela.Rotation = math.sin(t * 3) * 5
			end)
		end,
	},
	{
		texto = "El ingrediente secreto… son setas. Y a las setas, nadie les preguntó nunca qué opinaban.",
		cielo = Color3.fromRGB(190, 215, 200),
		dibujar = function(l, M, pasos)
			suelo(l, Color3.fromRGB(110, 178, 85), 5)
			olla(l, 0.82, 0.86, 0.36, Color3.fromRGB(70, 66, 76), 10)
			local fila = {}
			for k = 0, 3 do
				local m, f = muneco(l, M, "enemigo", "hongo", 0.12 + k * 0.15, 0.86, 0.2, 20)
				if m then
					m.andar = 1
					m.mirar = 1
				end
				table.insert(fila, { f = f, k = k })
			end
			local gota = redondo(l, 0.58, 0.55, 0.035, Color3.fromRGB(150, 200, 240), 25, 2)
			task.delay(1.2, function()
				if l.Parent then
					onomatopeya(l, "¡¿EH?!", 0.55, 0.3, Color3.fromRGB(250, 220, 90), 40)
				end
			end)
			table.insert(pasos, function(t)
				for _, h in fila do
					h.f.Position = UDim2.fromScale(0.12 + h.k * 0.15 + math.min(t * 0.02, 0.06), 0.86 - math.abs(math.sin(t * 6 + h.k)) * 0.03)
				end
				gota.Position = UDim2.fromScale(0.58 + math.min(t * 0.02, 0.06), 0.55 + (t * 0.08) % 0.15)
			end)
		end,
	},
	{
		texto = "Así que este otoño, el Rey Hongo se plantó: robó el Cucharón… y se lo puso de corona.",
		cielo = Color3.fromRGB(150, 130, 170),
		dibujar = function(l, M, pasos)
			suelo(l, Color3.fromRGB(95, 140, 80), 5)
			local rey, f = muneco(l, M, "enemigo", "reyHongo", 0.5, 0.9, 0.7, 20)
			local corona = cucharon(l, 0.5, 0.18, 0.22, 30, 180)
			local miedo = {}
			for k, d in { { 0.13, "12" }, { 0.86, "403" } } do
				local m, fv = muneco(l, M, "vecino", d[2], d[1], 0.9, 0.28, 18)
				if m then
					M.espejo(m, d[1] > 0.5)
				end
				table.insert(miedo, { f = fv, x = d[1], k = k })
			end
			task.delay(0.8, function()
				if l.Parent then
					onomatopeya(l, "¡LADRÓN!", 0.2, 0.3, Color3.fromRGB(240, 110, 90), 40)
				end
			end)
			local ultimo = 0
			table.insert(pasos, function(t)
				local bote = math.abs(math.sin(t * 2.2)) * 0.03
				f.Position = UDim2.fromScale(0.5, 0.9 - bote)
				corona.Position = UDim2.fromScale(0.5, 0.18 - bote)
				corona.Rotation = 180 + math.sin(t * 2.2) * 8
				for _, v in miedo do
					v.f.Position = UDim2.fromScale(v.x + math.sin(t * 30 + v.k) * 0.003, 0.9)
				end
				if rey and t - ultimo > 1.6 then
					ultimo = t
					M.hablar(rey, 0.8)
				end
			end)
		end,
	},
	{
		texto = "Sin el Cucharón, el guiso se pudre. Y sus esporas ponen rabiosos a todos los bichos del valle. Por eso, ahora, hay peleas por todas partes.",
		cielo = Color3.fromRGB(165, 185, 150),
		dibujar = function(l, M, pasos)
			suelo(l, Color3.fromRGB(105, 150, 80), 5)
			olla(l, 0.5, 0.86, 0.3, Color3.fromRGB(95, 120, 70), 10)
			local burbujas = {}
			for k = 1, 10 do
				burbujas[k] = redondo(l, 0.5, 0.5, 0.025 + (k % 3) * 0.01, Color3.fromRGB(170, 215, 110), 12, 2)
			end
			local bichos = {}
			for k, d in { { 0.15, "babosa", 0.2 }, { 0.32, "lobo", 0.3 }, { 0.7, "abeja", 0.22 }, { 0.86, "rana", 0.24 } } do
				local m, f = muneco(l, M, "enemigo", d[2], d[1], 0.86, d[3], 20)
				if m then
					M.espejo(m, d[1] > 0.5)
				end
				table.insert(bichos, { m = m, f = f, k = k })
			end
			task.delay(0.6, function()
				if l.Parent then
					onomatopeya(l, "¡GRRR!", 0.5, 0.22, Color3.fromRGB(190, 230, 120), 40)
				end
			end)
			local proximo = 0.5
			table.insert(pasos, function(t)
				for k, b in burbujas do
					local fase = (t * 0.25 + k / 10) % 1
					b.Position = UDim2.fromScale(0.5 + math.sin(k * 7 + t) * (0.05 + fase * 0.3), 0.6 - fase * 0.55)
					b.BackgroundTransparency = fase * 0.8
				end
				if t > proximo then
					proximo = t + 0.45
					local b = bichos[math.random(1, #bichos)]
					if b.m then
						M.atacar(b.m, b.k > 2 and -1 or 1)
					end
				end
			end)
		end,
	},
	{
		texto = "Quedan pocos días para la fiesta. Vael necesita un héroe… y, por desgracia, solo te tiene a ti.",
		cielo = Color3.fromRGB(245, 205, 150),
		dibujar = function(l, M, pasos, apariencia)
			-- el castillo-seta a lo lejos
			local lejos = caja(l, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.85, 0.8), Size = UDim2.fromScale(0.12, 0.3), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundTransparency = 1, ZIndex = 4 })
			caja(lejos, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(0.3, 0.6), BackgroundColor3 = Color3.fromRGB(230, 220, 195), ZIndex = 4 })
			local cap = caja(lejos, { Position = UDim2.fromScale(0, 0.1), Size = UDim2.fromScale(1, 0.45), BackgroundColor3 = Color3.fromRGB(200, 62, 58), ZIndex = 5 })
			Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = cap })
			Ui.borde(cap, TINTA, 2)
			suelo(l, Color3.fromRGB(110, 178, 85), 6)
			local heroe, fh = muneco(l, M, "clase", "guerrero", 0.42, 0.88, 0.5, 20, apariencia)
			local _, fa = muneco(l, M, "vecino", "1955", 0.16, 0.88, 0.4, 20)
			if heroe then
				heroe.mirar = 1
			end
			task.delay(1, function()
				if l.Parent then
					onomatopeya(l, "¡TÚ!", 0.42, 0.18, Color3.fromRGB(250, 220, 90), 40)
				end
			end)
			table.insert(pasos, function(t)
				fh.Position = UDim2.fromScale(0.42, 0.88 - math.max(0, math.sin(t * 1.5)) * 0.04)
				fa.Rotation = math.sin(t * 5) * 6
			end)
		end,
	},
}

-- ---------- EPÍLOGO (sale la primera vez que ganas al Rey Hongo) ----------
local EPILOGO: { Lamina } = {
	{
		texto = "El Rey Hongo cayó… de culo. Y el Cucharón de Vael rodó hasta tus pies.",
		cielo = Color3.fromRGB(120, 105, 130),
		dibujar = function(l, M, pasos, apariencia)
			suelo(l, Color3.fromRGB(110, 100, 105), 5)
			local rey, _ = muneco(l, M, "enemigo", "reyHongo", 0.72, 0.9, 0.6, 20)
			if rey then
				task.delay(0.4, function()
					M.caer(rey, true)
				end)
			end
			local heroe, _ = muneco(l, M, "clase", "guerrero", 0.2, 0.9, 0.45, 20, apariencia)
			if heroe then
				heroe.mirar = 1
			end
			local cu = cucharon(l, 0.62, 0.7, 0.16, 30, 0)
			task.delay(0.6, function()
				if l.Parent then
					onomatopeya(l, "¡PLOF!", 0.72, 0.3, Color3.fromRGB(250, 220, 90), 40)
				end
			end)
			table.insert(pasos, function(t)
				local u = math.clamp((t - 0.8) / 1.6, 0, 1)
				cu.Position = UDim2.fromScale(0.62 - u * 0.3, 0.7 + math.abs(math.sin(u * math.pi * 3)) * -0.08 * (1 - u) + u * 0.12)
				cu.Rotation = -u * 720
			end)
		end,
	},
	{
		texto = "Esa misma noche, Vael celebró la Fiesta del Gran Guiso más grande de su historia.",
		cielo = Color3.fromRGB(55, 60, 100),
		dibujar = function(l, M, pasos)
			-- fuegos artificiales
			local fuegos = {}
			for k = 1, 3 do
				local chispas = {}
				for n = 1, 8 do
					chispas[n] = redondo(l, 0, 0, 0.025, COLORES_BANDERIN[(k + n) % #COLORES_BANDERIN + 1], 6)
				end
				fuegos[k] = { chispas = chispas, x = 0.2 + k * 0.25, y = 0.22 + (k % 2) * 0.08, fase = k * 0.7 }
			end
			for k, x in { 0.1, 0.9 } do
				local _, ch = casita(l, x, 0.8, 0.3, Color3.fromRGB(240, 222, 190), k == 1 and Color3.fromRGB(190, 80, 65) or Color3.fromRGB(80, 110, 165), 10)
				humo(ch, pasos, 9)
			end
			banderines(l, 0.05, 0.95, 0.1, 0.08, 30, pasos)
			suelo(l, Color3.fromRGB(90, 140, 75), 15)
			olla(l, 0.5, 0.84, 0.3, Color3.fromRGB(70, 66, 76), 20)
			local vapor = {}
			for k = 1, 5 do
				vapor[k] = redondo(l, 0.5, 0.4, 0.06, Color3.fromRGB(250, 248, 240), 19)
			end
			local bailan = {}
			for k, d in { { 0.24, "12" }, { 0.36, "4242" }, { 0.66, "5" }, { 0.78, "1955" } } do
				local m, f = muneco(l, M, "vecino", d[2], d[1], 0.86, 0.28, 25)
				if m then
					M.espejo(m, d[1] > 0.5)
				end
				table.insert(bailan, { f = f, x = d[1], k = k })
			end
			table.insert(pasos, function(t)
				for _, fu in fuegos do
					local fase = ((t + fu.fase) % 2.2) / 2.2
					for n, c in fu.chispas do
						local a = n / #fu.chispas * math.pi * 2
						c.Position = UDim2.fromScale(fu.x + math.cos(a) * fase * 0.12, fu.y + math.sin(a) * fase * 0.12 + fase * fase * 0.05)
						c.BackgroundTransparency = fase
					end
				end
				for k, v in vapor do
					local fase = (t * 0.3 + k / 5) % 1
					v.Position = UDim2.fromScale(0.47 + k * 0.012 + math.sin(t * 2 + k) * 0.02, 0.6 - fase * 0.4)
					v.BackgroundTransparency = fase
				end
				for _, b in bailan do
					b.f.Position = UDim2.fromScale(b.x, 0.86 - math.abs(math.sin(t * 5 + b.k)) * 0.06)
					b.f.Rotation = math.sin(t * 5 + b.k) * 10
				end
			end)
		end,
	},
	{
		texto = "Por primera vez, el guiso no llevaba setas. Y por primera vez, las setas también comieron.",
		cielo = Color3.fromRGB(235, 200, 150),
		dibujar = function(l, M, pasos)
			suelo(l, Color3.fromRGB(150, 110, 75), 5)
			-- una mesa larga
			local mesa = caja(l, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.66), Size = UDim2.fromScale(0.86, 0.06), BackgroundColor3 = Color3.fromRGB(170, 115, 70), ZIndex = 30 })
			Ui.borde(mesa, TINTA, 3)
			local comensales = {}
			for k, d in { { 0.18, "hongo", 0.22 }, { 0.36, "reyHongo", 0.42 }, { 0.58, "hongo", 0.2 }, { 0.78, "hongo", 0.24 } } do
				local _, f = muneco(l, M, "enemigo", d[2], d[1], 0.7, d[3], 20)
				table.insert(comensales, { f = f, x = d[1], k = k })
				-- un cuenco humeante delante de cada uno
				local cuenco = caja(l, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(d[1], 0.67), Size = UDim2.fromScale(0.06, 0.035), SizeConstraint = Enum.SizeConstraint.RelativeYY, BackgroundColor3 = Color3.fromRGB(240, 235, 225), ZIndex = 31 })
				Ui.crear("UICorner", { CornerRadius = UDim.new(0.4, 0), Parent = cuenco })
				Ui.borde(cuenco, TINTA, 2)
			end
			task.delay(1, function()
				if l.Parent then
					onomatopeya(l, "¡ÑAM!", 0.5, 0.2, Color3.fromRGB(250, 220, 90), 40)
				end
			end)
			table.insert(pasos, function(t)
				for _, c in comensales do
					c.f.Position = UDim2.fromScale(c.x, 0.7 + math.abs(math.sin(t * 6 + c.k * 1.7)) * -0.015)
				end
			end)
		end,
	},
	{
		texto = "Tomás, Lucas y Fermín brindaron por ti. La abuela Rosa lloró un poquito. Dijo que era la cebolla.",
		cielo = Color3.fromRGB(70, 70, 110),
		dibujar = function(l, M, pasos, apariencia)
			suelo(l, Color3.fromRGB(90, 140, 75), 5)
			local grupo = {}
			for k, d in { { 0.14, "vecino", "4242" }, { 0.32, "vecino", "5" }, { 0.5, "clase", "guerrero" }, { 0.68, "vecino", "60606" }, { 0.86, "vecino", "1955" } } do
				local m, f = muneco(l, M, d[2], d[3], d[1], 0.9, d[2] == "clase" and 0.42 or 0.34, 20, d[2] == "clase" and apariencia or nil)
				if m then
					M.espejo(m, d[1] > 0.5)
				end
				table.insert(grupo, { f = f, x = d[1], k = k })
			end
			local lagrima = redondo(l, 0.86, 0.45, 0.025, Color3.fromRGB(150, 200, 240), 30, 2)
			task.delay(0.8, function()
				if l.Parent then
					onomatopeya(l, "¡CHIN CHIN!", 0.42, 0.2, Color3.fromRGB(250, 220, 90), 40)
				end
			end)
			table.insert(pasos, function(t)
				for _, g in grupo do
					g.f.Position = UDim2.fromScale(g.x, 0.9 - math.max(0, math.sin(t * 2.5 + g.k * 0.4)) * 0.03)
				end
				lagrima.Position = UDim2.fromScale(0.84, 0.45 + (t * 0.12) % 0.3)
			end)
		end,
	},
	{
		texto = "Y los bichos del valle volvieron a ser como siempre: igual de raros, pero ya no muerden tanto. FIN… ¿o no?",
		cielo = Color3.fromRGB(175, 205, 215),
		dibujar = function(l, M, pasos)
			suelo(l, Color3.fromRGB(110, 178, 85), 5)
			local bichos = {}
			for k, d in { { 0.15, "babosa", 0.2 }, { 0.35, "abeja", 0.2 }, { 0.6, "rana", 0.24 }, { 0.82, "lobo", 0.3 } } do
				local m, f = muneco(l, M, "enemigo", d[2], d[1], 0.86, d[3], 20)
				if m then
					m.andar = 1
					M.espejo(m, k % 2 == 0)
				end
				table.insert(bichos, { f = f, x = d[1], k = k })
			end
			-- el cofre del fondo… parpadea
			local _, cofre = muneco(l, M, "enemigo", "mimico", 0.92, 0.6, 0.12, 8)
			cofre.Visible = false
			task.delay(2.5, function()
				if l.Parent then
					cofre.Visible = true
					onomatopeya(l, "¿…?", 0.85, 0.35, Color3.fromRGB(240, 240, 240), 40)
				end
			end)
			table.insert(pasos, function(t)
				for _, b in bichos do
					b.f.Position = UDim2.fromScale(b.x + math.sin(t * 0.8 + b.k) * 0.04, 0.86 - math.abs(math.sin(t * 3 + b.k)) * 0.04)
				end
			end)
		end,
	},
}

--- Libro de cuentos animado. Se pasa de lámina con un clic, con "Siguiente" o con Espacio; "Saltar" lo termina.
local function libro(gui: ScreenGui, LAMINAS: { Lamina }, Munecos: any?, apariencia: any?, alTerminar: (() -> ())?)
	local capa = caja(gui, { Name = "Prologo", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(38, 30, 26), ZIndex = 350 })
	local libro = caja(capa, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.88), BackgroundColor3 = Color3.fromRGB(238, 226, 198), ZIndex = 351 })
	Ui.crear("UISizeConstraint", { MaxSize = Vector2.new(1150, 720), Parent = libro })
	Ui.esquinas(libro, 10)
	Ui.borde(libro, TINTA, 4)
	local marco = caja(libro, { Position = UDim2.new(0, 22, 0, 22), Size = UDim2.new(1, -44, 0.7, -22), BackgroundTransparency = 1, ZIndex = 352 })
	local texto = Ui.crear("TextLabel", { Position = UDim2.new(0, 34, 0.7, 14), Size = UDim2.new(1, -68, 0.3, -70), BackgroundTransparency = 1, Text = "", Font = Ui.FuenteDialogo, TextSize = 30, TextWrapped = true, TextColor3 = TINTA, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 353, Parent = libro })
	local pagina = Ui.crear("TextLabel", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 34, 1, -14), Size = UDim2.fromOffset(120, 36), BackgroundTransparency = 1, Text = "", Font = Ui.Fuente, TextSize = 22, TextColor3 = Color3.fromRGB(150, 120, 95), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 353, Parent = libro })

	local indice = 0
	local escribiendo = false
	local completo = ""
	local terminado = false
	local actual: Frame? = nil

	local function cerrar()
		if terminado then
			return
		end
		terminado = true
		Ui.tween(libro, { Position = UDim2.fromScale(0.5, 1.6), Rotation = 8 }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		Ui.tween(capa, { BackgroundTransparency = 1 }, 0.6)
		task.delay(0.6, function()
			capa:Destroy()
			if alTerminar then
				alTerminar()
			end
		end)
	end

	local function mostrar(i: number)
		local datos = LAMINAS[i]
		-- pasar página: la lámina vieja se dobla y llega la nueva
		if actual then
			local vieja = actual
			Ui.tween(vieja, { Size = UDim2.fromScale(0, 1), Position = UDim2.fromScale(0, 0) }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(0.26, function()
				vieja:Destroy()
			end)
		end
		local l = caja(marco, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(actual and 0 or 1, 1), BackgroundColor3 = datos.cielo, ClipsDescendants = true, ZIndex = 352 })
		Ui.esquinas(l, 8)
		Ui.borde(l, TINTA, 3)
		actual = l
		if Ui.tween and l.Size.X.Scale < 1 then
			task.delay(0.22, function()
				if l.Parent then
					Ui.tween(l, { Size = UDim2.fromScale(1, 1) }, 0.3, Enum.EasingStyle.Quad)
				end
			end)
		end
		local pasos: { Anim } = {}
		local ok, err = pcall(datos.dibujar, l, Munecos, pasos, apariencia)
		if not ok then
			warn("Vael · prólogo: " .. tostring(err))
		end
		animar(l, pasos)
		pagina.Text = i .. " / " .. #LAMINAS
		completo = Ui.t(datos.texto)
		escribiendo = true
		task.spawn(function()
			local n = utf8.len(completo) or #completo
			for k = 1, n do
				if not escribiendo or indice ~= i or not texto.Parent then
					return
				end
				local corte = utf8.offset(completo, k + 1)
				texto.Text = corte and string.sub(completo, 1, corte - 1) or completo
				task.wait(0.028)
			end
			escribiendo = false
		end)
	end

	local function siguiente()
		if terminado then
			return
		end
		if escribiendo then
			escribiendo = false
			texto.Text = completo
			return
		end
		indice += 1
		if indice > #LAMINAS then
			cerrar()
			return
		end
		mostrar(indice)
	end

	local botones = caja(libro, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -14), Size = UDim2.fromOffset(380, 48), BackgroundTransparency = 1, ZIndex = 354 })
	Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10), Parent = botones })
	Ui.boton({ Size = UDim2.fromOffset(150, 46), Text = "Saltar", BackgroundColor3 = Color3.fromRGB(120, 110, 100), ZIndex = 355, LayoutOrder = 1, Parent = botones }, cerrar)
	Ui.boton({ Size = UDim2.fromOffset(200, 46), Text = "Siguiente", BackgroundColor3 = Color3.fromRGB(100, 160, 90), Icono = "estrella", ZIndex = 355, LayoutOrder = 2, Parent = botones }, siguiente)
	-- clic en la lámina o Espacio: siguiente
	local zona = Ui.crear("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 360, Parent = marco })
	zona.Activated:Connect(siguiente)
	local UIS = game:GetService("UserInputService")
	local con
	con = UIS.InputBegan:Connect(function(e, procesado)
		if not capa.Parent then
			con:Disconnect()
			return
		end
		if not procesado and (e.KeyCode == Enum.KeyCode.Space or e.KeyCode == Enum.KeyCode.Return) then
			siguiente()
		end
	end)

	libro.Position = UDim2.fromScale(0.5, 1.6)
	Ui.tween(libro, { Position = UDim2.fromScale(0.5, 0.5) }, 0.6, Enum.EasingStyle.Back)
	siguiente()
end

function Portada.prologo(gui: ScreenGui, Munecos: any?, apariencia: any?, alTerminar: (() -> ())?)
	libro(gui, LAMINAS, Munecos, apariencia, alTerminar)
end

function Portada.epilogo(gui: ScreenGui, Munecos: any?, apariencia: any?, alTerminar: (() -> ())?)
	libro(gui, EPILOGO, Munecos, apariencia, alTerminar)
end

return Portada
