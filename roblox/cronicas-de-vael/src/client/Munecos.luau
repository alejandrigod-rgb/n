--!strict
-- Muñecos 2D de recortes de papel (personajes propios de Crónicas de Vael).
-- Todo se dibuja con Frames (círculos y rectángulos con contorno negro grueso), sin imágenes, así que funciona
-- en cualquier lugar sin subir nada. Sirve igual dentro de un BillboardGui (en el mundo) que en la interfaz
-- (retratos). Un único bucle por fotograma (RenderStepped, 60 fps) los anima a todos: respiración, saltitos al
-- andar, parpadeo, mirada, alas, golpes y caídas.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Datos = require(game:GetService("ReplicatedStorage"):WaitForChild("Vael"):WaitForChild("Datos")) :: any

local Munecos = {}

local NEGRO = Datos.TINTA -- contorno marrón muy oscuro (estilo cartulina)
local BLANCO = Color3.fromRGB(255, 255, 255)

type Pieza = { f: Frame, x: number, rot: number, color: Color3 }
export type Muneco = {
	raiz: Frame,
	cuerpo: Frame,
	aspecto: number,
	grosor: number,
	piezas: { Pieza },
	ojos: { { f: Frame, tam: UDim2 } },
	pupilas: { { f: Frame, x: number, y: number } },
	boca: { f: Frame, tam: UDim2 }?,
	pies: { { f: Frame, y: number } },
	alas: { { p: Pieza, amp: number, vel: number, fase: number } },
	manos: { { f: Frame, x: number, y: number } },
	vy: number, -- velocidad vertical (la pone quien lo usa): >0 sube, <0 cae
	ritmo: number, -- 1 andando, ~1.5 corriendo (acelera los pasos)
	giro: number, -- al cambiar de dirección, un instante de "media vuelta"
	ultimoMirar: number,
	enSuelo: boolean,
	aterriza: number,
	brillos: { Frame },
	vuela: boolean,
	andar: number, -- 0 quieto, 1 andando (lo pone quien lo usa)
	mirar: number, -- -1 izquierda, 1 derecha
	espejo: boolean,
	t: number,
	proxParpadeo: number,
	parpadeo: number,
	golpe: number,
	hablar: number,
	salto: number,
	dirSalto: number,
	caido: boolean,
	tenido: boolean,
	semilla: number,
}

local activos: { Muneco } = {}
local conexion: RBXScriptConnection? = nil

-- ===================== PIEZAS =====================
type Opciones = { sb: boolean?, t: number?, gr: number? }

local function pieza(m: Muneco, x: number, y: number, w: number, h: number, color: Color3, radio: number?, z: number?, rot: number?, op: Opciones?): Pieza
	-- colores apagados, como de cartulina (nada de colores chillones)
	if color ~= NEGRO and color ~= BLANCO then
		color = Datos.apagar(color, 0.06)
	elseif color == BLANCO then
		color = Color3.fromRGB(246, 240, 226)
	end
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(x, y)
	f.Size = UDim2.fromScale(w, h)
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.ZIndex = z or 1
	f.Rotation = rot or 0
	if op and op.t then
		f.BackgroundTransparency = op.t
	end
	if radio then
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(radio, 0)
		c.Parent = f
	end
	if not (op and op.sb) then
		local s = Instance.new("UIStroke")
		s.Thickness = op and op.gr or m.grosor
		s.Color = NEGRO
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = f
	end
	f.Parent = m.cuerpo
	local p = { f = f, x = x, rot = rot or 0, color = color }
	table.insert(m.piezas, p)
	return p
end

--- Círculo: d es la fracción del ANCHO (el alto se corrige con el aspecto del lienzo para que salga redondo).
local function circ(m: Muneco, x: number, y: number, d: number, color: Color3, z: number?, op: Opciones?): Pieza
	return pieza(m, x, y, d, d / m.aspecto, color, 0.5, z, 0, op)
end

local function ojo(m: Muneco, x: number, y: number, w: number, h: number, z: number, colorOjo: Color3?, colorPupila: Color3?, tamPupila: number?, dxPupila: number?)
	local o = pieza(m, x, y, w, h, colorOjo or BLANCO, 0.5, z)
	table.insert(m.ojos, { f = o.f, tam = o.f.Size })
	local d = tamPupila or w * 0.3
	local px = x + (dxPupila or 0)
	local p = pieza(m, px, y + h * 0.05, d, d / m.aspecto, colorPupila or NEGRO, 0.5, z + 1, 0, { sb = true })
	table.insert(m.pupilas, { f = p.f, x = px, y = y + h * 0.05 })
end

local function boca(m: Muneco, x: number, y: number, w: number, h: number, z: number, color: Color3?)
	local b = pieza(m, x, y, w, h, color or Color3.fromRGB(120, 30, 40), 0.5, z, 0, { sb = true })
	m.boca = { f = b.f, tam = b.f.Size }
end

local function pie(m: Muneco, x: number, y: number, w: number, h: number, color: Color3, z: number?, rot: number?)
	local p = pieza(m, x, y, w, h, color, 0.45, z or 2, rot)
	table.insert(m.pies, { f = p.f, y = y })
end

local function ala(m: Muneco, x: number, y: number, w: number, h: number, color: Color3, z: number, rot: number, amp: number, vel: number, fase: number, op: Opciones?)
	local p = pieza(m, x, y, w, h, color, 0.5, z, rot, op)
	table.insert(m.alas, { p = p, amp = amp, vel = vel, fase = fase })
end

local function sombra(m: Muneco, ancho: number)
	pieza(m, 0.5, 0.975, ancho, 0.04, NEGRO, 0.5, 0, 0, { sb = true, t = 0.65 })
end

local function brillo(_m: Muneco, p: Pieza)
	-- sin brillos que parpadean: en cartulina todo es mate
	p.f.BackgroundTransparency = 0
end

-- ===================== HÉROES (personalizables) =====================
local COLOR_CLASE: { [string]: Color3 } = {
	guerrero = Color3.fromRGB(200, 75, 65),
	maga = Color3.fromRGB(125, 95, 200),
	arquero = Color3.fromRGB(80, 150, 90),
	sanador = Color3.fromRGB(230, 195, 90),
}
local A = Datos.Apariencia

--- Cuerpo de muñeco de cartulina: pies, cuerpo, manos y una cabeza grande y redonda.
local function cuerpoBase(m: Muneco, piel: Color3, colorCuerpo: Color3, pies: Color3, sinMochila: boolean?)
	sombra(m, 0.62)
	if not sinMochila then
		-- mochila de aventurero (asoma por detrás, con saco de dormir enrollado encima)
		pieza(m, 0.5, 0.7, 0.66, 0.3, Color3.fromRGB(150, 105, 60), 0.25, 1)
		pieza(m, 0.5, 0.55, 0.62, 0.07, Color3.fromRGB(110, 140, 90), 0.5, 1)
		pieza(m, 0.21, 0.76, 0.08, 0.12, Color3.fromRGB(130, 90, 50), 0.3, 1)
	end
	pie(m, 0.37, 0.935, 0.2, 0.06, pies)
	pie(m, 0.63, 0.935, 0.2, 0.06, pies)
	pieza(m, 0.5, 0.76, 0.56, 0.3, colorCuerpo, 0.3, 3)
	pieza(m, 0.5, 0.84, 0.56, 0.035, Color3.fromRGB(90, 60, 40), 0, 4, 0, { sb = true })
	pieza(m, 0.5, 0.64, 0.04, 0.2, colorCuerpo:Lerp(NEGRO, 0.25), 0, 4, 0, { sb = true }) -- costura de la chaqueta
	if not sinMochila then
		pieza(m, 0.36, 0.7, 0.04, 0.24, Color3.fromRGB(110, 75, 45), 0, 5, 8, { sb = true }) -- correas
		pieza(m, 0.64, 0.7, 0.04, 0.24, Color3.fromRGB(110, 75, 45), 0, 5, -8, { sb = true })
	end
	local mi = circ(m, 0.2, 0.77, 0.15, piel, 6)
	local md = circ(m, 0.8, 0.77, 0.15, piel, 6)
	table.insert(m.manos, { f = mi.f, x = 0.2, y = 0.77 })
	table.insert(m.manos, { f = md.f, x = 0.8, y = 0.77 })
	circ(m, 0.5, 0.42, 0.74, piel, 5)
end

--- Ojos grandes que se tocan en el centro, con pupilas pequeñas (estilo recortable).
local function cara(m: Muneco, piel: Color3, estilo: number, colorPupila: Color3)
	local z = 8
	if estilo == 2 then -- grandes
		ojo(m, 0.385, 0.4, 0.24, 0.2, z, nil, colorPupila, 0.07)
		ojo(m, 0.615, 0.4, 0.24, 0.2, z, nil, colorPupila, 0.07)
	elseif estilo == 4 then -- bizcos
		ojo(m, 0.4, 0.41, 0.2, 0.16, z, nil, colorPupila, 0.055, 0.04)
		ojo(m, 0.6, 0.41, 0.2, 0.16, z, nil, colorPupila, 0.055, -0.04)
	else
		ojo(m, 0.4, 0.41, 0.2, 0.16, z, nil, colorPupila, 0.055)
		ojo(m, 0.6, 0.41, 0.2, 0.16, z, nil, colorPupila, 0.055)
	end
	if estilo == 3 then -- dormilones: párpado a media asta
		pieza(m, 0.4, 0.375, 0.21, 0.085, piel, 0.3, z + 2)
		pieza(m, 0.6, 0.375, 0.21, 0.085, piel, 0.3, z + 2)
	elseif estilo == 5 then -- enfadados: cejas de cartón en diagonal
		pieza(m, 0.4, 0.335, 0.2, 0.025, NEGRO, 0, z + 2, 18, { sb = true })
		pieza(m, 0.6, 0.335, 0.2, 0.025, NEGRO, 0, z + 2, -18, { sb = true })
	end
	boca(m, 0.5, 0.56, 0.11, 0.022, 8)
end

local function cabezaBasica(m: Muneco, piel: Color3, colorCuerpo: Color3, pies: Color3)
	cuerpoBase(m, piel, colorCuerpo, pies, true)
	cara(m, piel, 1, NEGRO)
end

local function peloAtras(m: Muneco, estilo: number, c: Color3)
	if estilo == 4 then -- melena
		pieza(m, 0.5, 0.5, 0.84, 0.46, c, 0.4, 4)
	elseif estilo == 6 then -- coleta
		pieza(m, 0.87, 0.38, 0.14, 0.24, c, 0.45, 4, 22)
		circ(m, 0.82, 0.29, 0.06, Color3.fromRGB(220, 70, 90), 4)
	elseif estilo == 7 then -- afro
		circ(m, 0.5, 0.3, 0.98, c, 4)
	end
end

local function peloDelante(m: Muneco, estilo: number, c: Color3)
	if estilo == 2 or estilo == 4 or estilo == 6 then
		pieza(m, 0.5, 0.19, 0.64, 0.13, c, 0.5, 9)
	elseif estilo == 3 then -- flequillo
		pieza(m, 0.5, 0.19, 0.64, 0.13, c, 0.5, 9)
		pieza(m, 0.4, 0.25, 0.4, 0.08, c, 0.4, 9, -14)
	elseif estilo == 5 then -- cresta
		for k = -1, 1 do
			pieza(m, 0.5 + k * 0.08, 0.1 - (k == 0 and 0.03 or 0), 0.09, 0.17, c, 0.3, 9, k * 18)
		end
	elseif estilo == 7 then
		pieza(m, 0.5, 0.2, 0.7, 0.12, c, 0.5, 9)
	end
end

local function gorroDe(m: Muneco, tipo: number, c: Color3)
	if tipo == 3 then -- gorro de lana
		pieza(m, 0.5, 0.18, 0.66, 0.17, c, 0.45, 11)
		pieza(m, 0.5, 0.26, 0.72, 0.06, c:Lerp(BLANCO, 0.35), 0.3, 12)
		circ(m, 0.5, 0.07, 0.13, c:Lerp(BLANCO, 0.5), 12)
	elseif tipo == 4 then -- sombrero vaquero
		pieza(m, 0.5, 0.215, 1.0, 0.05, c, 0.5, 12)
		pieza(m, 0.5, 0.14, 0.5, 0.13, c, 0.25, 11)
		pieza(m, 0.5, 0.185, 0.51, 0.025, NEGRO, 0, 12, 0, { sb = true })
	elseif tipo == 5 then -- corona de cartón
		pieza(m, 0.5, 0.17, 0.5, 0.07, Color3.fromRGB(240, 200, 70), 0.1, 11)
		for k = -1, 1 do
			pieza(m, 0.5 + k * 0.16, 0.12, 0.08, 0.08, Color3.fromRGB(240, 200, 70), 0.1, 11, 45)
		end
		circ(m, 0.5, 0.17, 0.04, Color3.fromRGB(210, 60, 70), 12, { sb = true })
	elseif tipo == 6 then -- gorra
		pieza(m, 0.47, 0.19, 0.64, 0.14, c, 0.5, 11)
		pieza(m, 0.74, 0.245, 0.32, 0.045, c:Lerp(NEGRO, 0.2), 0.5, 12)
	elseif tipo == 7 then -- chistera
		pieza(m, 0.5, 0.215, 0.8, 0.045, Color3.fromRGB(50, 45, 50), 0.4, 12)
		pieza(m, 0.5, 0.09, 0.42, 0.22, Color3.fromRGB(55, 50, 55), 0.08, 11)
		pieza(m, 0.5, 0.17, 0.43, 0.04, c, 0, 12, 0, { sb = true })
	end
end

local function accesorio(m: Muneco, tipo: number, colorPelo: Color3)
	if tipo == 2 then -- gafas
		for _, x in { 0.4, 0.6 } do
			local g = pieza(m, x, 0.41, 0.22, 0.18, BLANCO, 0.5, 14, 0, { t = 1, gr = m.grosor + 1 })
			g.f.BackgroundTransparency = 1
		end
	elseif tipo == 3 then -- gafas de sol
		pieza(m, 0.39, 0.41, 0.21, 0.13, Color3.fromRGB(40, 40, 50), 0.4, 14)
		pieza(m, 0.61, 0.41, 0.21, 0.13, Color3.fromRGB(40, 40, 50), 0.4, 14)
		pieza(m, 0.5, 0.4, 0.05, 0.02, NEGRO, 0, 14, 0, { sb = true })
	elseif tipo == 4 then -- bigote
		pieza(m, 0.44, 0.515, 0.16, 0.05, colorPelo, 0.5, 14, -8)
		pieza(m, 0.56, 0.515, 0.16, 0.05, colorPelo, 0.5, 14, 8)
	elseif tipo == 5 then -- tirita
		pieza(m, 0.68, 0.3, 0.15, 0.05, Color3.fromRGB(240, 200, 160), 0.3, 14, 30)
		pieza(m, 0.68, 0.3, 0.05, 0.03, Color3.fromRGB(210, 160, 120), 0, 15, 30, { sb = true })
	elseif tipo == 6 then -- parche de pirata
		pieza(m, 0.5, 0.33, 0.78, 0.02, NEGRO, 0, 15, -14, { sb = true })
		pieza(m, 0.6, 0.41, 0.17, 0.15, Color3.fromRGB(40, 35, 40), 0.5, 15)
	elseif tipo == 7 then -- pato en la cabeza
		circ(m, 0.5, 0.06, 0.22, Color3.fromRGB(250, 215, 70), 16)
		circ(m, 0.6, -0.03, 0.13, Color3.fromRGB(250, 215, 70), 16)
		pieza(m, 0.68, -0.02, 0.07, 0.03, Color3.fromRGB(240, 140, 50), 0.3, 17)
		circ(m, 0.61, -0.04, 0.025, NEGRO, 17, { sb = true })
	elseif tipo == 8 then -- pajarita
		pieza(m, 0.44, 0.625, 0.1, 0.06, Color3.fromRGB(200, 60, 60), 0.2, 14, 20)
		pieza(m, 0.56, 0.625, 0.1, 0.06, Color3.fromRGB(200, 60, 60), 0.2, 14, -20)
		circ(m, 0.5, 0.625, 0.045, Color3.fromRGB(170, 40, 40), 15)
	end
end

local function dibujarHeroe(m: Muneco, clase: string, ap: { [string]: any }?)
	local a = Datos.validarApariencia(ap or {})
	local piel = A.pieles[a.piel]
	local colorClase = COLOR_CLASE[clase] or COLOR_CLASE.guerrero
	local ropa = a.ropa > 1 and A.coloresRopa[a.ropa] or colorClase
	local cPelo = A.coloresPelo[a.colorPelo]
	local cGorro = A.coloresGorro[a.colorGorro]
	local deClase = a.gorro == 1
	local capucha = deClase and (clase == "arquero" or clase == "sanador")
	local casco = deClase and clase == "guerrero"
	-- detrás de la cabeza
	if clase == "guerrero" then
		pieza(m, 0.5, 0.78, 0.7, 0.34, ropa:Lerp(NEGRO, 0.3), 0.2, 2) -- capa
	end
	if capucha then
		local cc = clase == "arquero" and Color3.fromRGB(70, 115, 70) or Color3.fromRGB(235, 228, 212)
		circ(m, 0.5, 0.4, 0.88, cc, 4)
		pieza(m, 0.5, 0.11, 0.24, 0.12, cc, 0.2, 4, 45)
	elseif not casco then
		peloAtras(m, a.pelo, cPelo)
	elseif a.pelo == 4 or a.pelo == 6 then
		peloAtras(m, a.pelo, cPelo)
	end
	-- arco y carcaj del arquero (detrás del cuerpo)
	if clase == "arquero" then
		local arco = pieza(m, 0.13, 0.68, 0.26, 0.42, BLANCO, 0.5, 2, 0, { t = 1, gr = m.grosor + 2 })
		arco.f.BackgroundTransparency = 1
		local trazo = arco.f:FindFirstChildOfClass("UIStroke")
		if trazo then
			trazo.Color = Color3.fromRGB(120, 80, 45)
		end
		pieza(m, 0.13, 0.68, 0.012, 0.4, Color3.fromRGB(240, 240, 230), 0, 2, 0, { sb = true })
		pieza(m, 0.8, 0.6, 0.1, 0.24, Color3.fromRGB(130, 85, 50), 0.3, 2, 15)
	end
	cuerpoBase(m, piel, ropa, Color3.fromRGB(70, 50, 40))
	cara(m, piel, a.ojos, A.coloresOjos[a.colorOjos])
	-- tres años después: barba enmarañada (hasta que pasa por el barbero)
	if ap and ap.barba then
		pieza(m, 0.5, 0.57, 0.4, 0.17, cPelo:Lerp(Color3.fromRGB(110, 90, 70), 0.3), 0.5, 9)
		pieza(m, 0.42, 0.52, 0.14, 0.05, cPelo:Lerp(Color3.fromRGB(110, 90, 70), 0.3), 0.5, 10, -12)
		pieza(m, 0.58, 0.52, 0.14, 0.05, cPelo:Lerp(Color3.fromRGB(110, 90, 70), 0.3), 0.5, 10, 12)
		pieza(m, 0.5, 0.56, 0.09, 0.02, Color3.fromRGB(120, 30, 40), 0.5, 11, 0, { sb = true })
		pieza(m, 0.66, 0.62, 0.05, 0.05, Color3.fromRGB(120, 180, 90), 0.5, 11, 0, { sb = true }) -- una hoja enredada
	end
	if clase == "sanador" then
		pieza(m, 0.5, 0.74, 0.05, 0.12, COLOR_CLASE.sanador:Lerp(Color3.fromRGB(200, 60, 60), 0.6), 0, 5, 0, { sb = true })
		pieza(m, 0.5, 0.725, 0.15, 0.035, COLOR_CLASE.sanador:Lerp(Color3.fromRGB(200, 60, 60), 0.6), 0, 5, 0, { sb = true })
	end
	-- pelo de delante (lo tapan la capucha y el casco)
	if not capucha and not casco and a.gorro ~= 7 then
		peloDelante(m, a.pelo, cPelo)
	end
	-- lo que lleva en la cabeza
	if casco then
		pieza(m, 0.5, 0.2, 0.72, 0.2, Color3.fromRGB(175, 180, 195), 0.45, 10)
		pieza(m, 0.5, 0.275, 0.8, 0.06, Color3.fromRGB(140, 145, 160), 0.3, 11)
		pieza(m, 0.5, 0.32, 0.05, 0.09, Color3.fromRGB(140, 145, 160), 0.3, 11)
		pieza(m, 0.12, 0.14, 0.08, 0.14, Color3.fromRGB(250, 240, 215), 0.4, 9, -28)
		pieza(m, 0.88, 0.14, 0.08, 0.14, Color3.fromRGB(250, 240, 215), 0.4, 9, 28)
	elseif deClase and clase == "maga" then
		pieza(m, 0.5, 0.21, 0.96, 0.06, Color3.fromRGB(85, 60, 150), 0.5, 12)
		pieza(m, 0.5, 0.13, 0.46, 0.13, Color3.fromRGB(110, 85, 180), 0.3, 11)
		pieza(m, 0.54, 0.05, 0.28, 0.09, Color3.fromRGB(110, 85, 180), 0.3, 11, 10)
		pieza(m, 0.62, -0.01, 0.13, 0.07, Color3.fromRGB(110, 85, 180), 0.3, 11, 24)
		pieza(m, 0.46, 0.13, 0.06, 0.046, Color3.fromRGB(240, 210, 90), 0.1, 13, 45)
	elseif clase == "arquero" and capucha then
		pieza(m, 0.66, 0.16, 0.05, 0.16, Color3.fromRGB(220, 80, 70), 0.5, 4, 30)
	elseif not deClase then
		gorroDe(m, a.gorro, cGorro)
	end
	-- arma de la clase
	if clase == "guerrero" then
		pieza(m, 0.88, 0.57, 0.06, 0.32, Color3.fromRGB(215, 220, 225), 0.3, 12)
		pieza(m, 0.88, 0.73, 0.18, 0.03, Color3.fromRGB(220, 180, 70), 0.3, 13)
		pieza(m, 0.88, 0.78, 0.045, 0.07, Color3.fromRGB(110, 70, 45), 0.3, 12)
	elseif clase == "maga" then
		pieza(m, 0.12, 0.62, 0.035, 0.55, Color3.fromRGB(120, 80, 50), 0.3, 12)
		circ(m, 0.12, 0.33, 0.13, Color3.fromRGB(130, 200, 220), 13)
	elseif clase == "sanador" then
		pieza(m, 0.88, 0.62, 0.035, 0.55, Color3.fromRGB(120, 80, 50), 0.3, 12)
		pieza(m, 0.88, 0.34, 0.05, 0.11, COLOR_CLASE.sanador, 0.2, 13)
		pieza(m, 0.88, 0.33, 0.13, 0.035, COLOR_CLASE.sanador, 0.2, 13)
	end
	accesorio(m, a.accesorio, cPelo)
end

-- ===================== VECINOS DE LA CIUDAD =====================
local ROPA = { Color3.fromRGB(90, 140, 200), Color3.fromRGB(200, 90, 90), Color3.fromRGB(240, 190, 80), Color3.fromRGB(120, 180, 110), Color3.fromRGB(180, 120, 200), Color3.fromRGB(240, 140, 60) }
local PIELES = { Color3.fromRGB(255, 220, 185), Color3.fromRGB(235, 190, 150), Color3.fromRGB(200, 150, 110), Color3.fromRGB(150, 105, 75) }
local PELO = { Color3.fromRGB(60, 40, 30), Color3.fromRGB(230, 190, 90), Color3.fromRGB(160, 70, 40), Color3.fromRGB(40, 40, 50), Color3.fromRGB(200, 200, 200) }

local function dibujarVecino(m: Muneco, semilla: number)
	local r = Random.new(semilla)
	local piel = PIELES[r:NextInteger(1, #PIELES)]
	local ropa = ROPA[r:NextInteger(1, #ROPA)]
	local pelo = PELO[r:NextInteger(1, #PELO)]
	local estilo = r:NextInteger(1, 4)
	if estilo == 2 then
		pieza(m, 0.5, 0.5, 0.82, 0.42, pelo, 0.4, 4) -- melena
	end
	cabezaBasica(m, piel, ropa, Color3.fromRGB(70, 50, 40))
	if estilo == 1 then
		pieza(m, 0.5, 0.17, 0.66, 0.14, pelo, 0.5, 10)
	elseif estilo == 2 then
		pieza(m, 0.5, 0.16, 0.7, 0.14, pelo, 0.5, 10)
	elseif estilo == 3 then
		pieza(m, 0.5, 0.2, 0.92, 0.05, Color3.fromRGB(150, 110, 60), 0.5, 11) -- sombrero de paja
		pieza(m, 0.5, 0.13, 0.5, 0.12, Color3.fromRGB(200, 160, 90), 0.3, 10)
	else
		pieza(m, 0.5, 0.17, 0.7, 0.13, ROPA[r:NextInteger(1, #ROPA)], 0.5, 10) -- pañuelo
		pieza(m, 0.8, 0.2, 0.14, 0.06, ROPA[r:NextInteger(1, #ROPA)], 0.5, 9, 30)
	end
	if r:NextNumber() < 0.4 then
		pieza(m, 0.5, 0.78, 0.36, 0.24, Color3.fromRGB(245, 240, 230), 0.2, 5) -- delantal
	end
	if r:NextNumber() < 0.3 then
		pieza(m, 0.5, 0.62, 0.3, 0.06, pelo, 0.5, 9) -- bigote
	end
end

--- El vendedor sospechoso: gabardina, sombrero, gafas de sol y bigote.
local function dibujarVendedor(m: Muneco)
	local piel = Color3.fromRGB(235, 195, 160)
	sombra(m, 0.62)
	pie(m, 0.37, 0.935, 0.2, 0.06, Color3.fromRGB(40, 35, 35))
	pie(m, 0.63, 0.935, 0.2, 0.06, Color3.fromRGB(40, 35, 35))
	pieza(m, 0.5, 0.76, 0.62, 0.34, Color3.fromRGB(150, 115, 70), 0.25, 3)
	pieza(m, 0.5, 0.76, 0.04, 0.3, Color3.fromRGB(110, 80, 50), 0, 4, 0, { sb = true })
	for k = 0, 2 do
		circ(m, 0.44, 0.68 + k * 0.06, 0.035, Color3.fromRGB(240, 200, 70), 5, { sb = true })
	end
	pieza(m, 0.5, 0.62, 0.46, 0.08, Color3.fromRGB(130, 95, 60), 0.3, 4) -- cuello subido
	circ(m, 0.2, 0.77, 0.15, piel, 6)
	circ(m, 0.8, 0.77, 0.15, piel, 6)
	circ(m, 0.5, 0.42, 0.72, piel, 5)
	pieza(m, 0.39, 0.41, 0.2, 0.09, NEGRO, 0.4, 8)
	pieza(m, 0.61, 0.41, 0.2, 0.09, NEGRO, 0.4, 8)
	pieza(m, 0.5, 0.41, 0.06, 0.02, NEGRO, 0, 8, 0, { sb = true })
	circ(m, 0.36, 0.4, 0.05, BLANCO, 9, { sb = true, t = 0.3 })
	pieza(m, 0.5, 0.52, 0.3, 0.05, Color3.fromRGB(60, 40, 30), 0.5, 8)
	boca(m, 0.52, 0.575, 0.08, 0.02, 8)
	pieza(m, 0.5, 0.21, 0.98, 0.06, Color3.fromRGB(70, 55, 45), 0.5, 11)
	pieza(m, 0.5, 0.13, 0.54, 0.15, Color3.fromRGB(80, 62, 50), 0.25, 10)
	pieza(m, 0.5, 0.18, 0.55, 0.03, Color3.fromRGB(150, 60, 60), 0, 11, 0, { sb = true })
end

-- ===================== MONSTRUOS =====================
-- Todos miran a la izquierda (hacia los héroes). El lienzo es cuadrado (aspecto 1).
local DIBUJOS: { [string]: (Muneco, Color3) -> () } = {}

DIBUJOS.babosa = function(m, c)
	sombra(m, 0.8)
	pieza(m, 0.38, 0.42, 0.03, 0.14, c:Lerp(NEGRO, 0.2), 0, 1, -10)
	circ(m, 0.36, 0.34, 0.08, c, 1)
	pieza(m, 0.5, 0.76, 0.88, 0.42, c, 0.5, 2)
	pieza(m, 0.45, 0.6, 0.52, 0.42, c, 0.5, 3)
	circ(m, 0.34, 0.52, 0.12, BLANCO, 4, { sb = true, t = 0.45 })
	ojo(m, 0.37, 0.64, 0.13, 0.15, 5)
	ojo(m, 0.53, 0.64, 0.13, 0.15, 5)
	boca(m, 0.44, 0.79, 0.14, 0.03, 5)
end

DIBUJOS.hongo = function(m, c)
	sombra(m, 0.6)
	pie(m, 0.4, 0.94, 0.16, 0.07, Color3.fromRGB(110, 70, 45))
	pie(m, 0.6, 0.94, 0.16, 0.07, Color3.fromRGB(110, 70, 45))
	pieza(m, 0.5, 0.72, 0.46, 0.4, Color3.fromRGB(245, 235, 210), 0.3, 2)
	pieza(m, 0.5, 0.42, 0.92, 0.42, c, 0.5, 3)
	circ(m, 0.3, 0.36, 0.14, BLANCO, 4, { sb = true })
	circ(m, 0.56, 0.3, 0.12, BLANCO, 4, { sb = true })
	circ(m, 0.74, 0.43, 0.1, BLANCO, 4, { sb = true })
	ojo(m, 0.42, 0.68, 0.12, 0.13, 5)
	ojo(m, 0.58, 0.68, 0.12, 0.13, 5)
	boca(m, 0.5, 0.8, 0.1, 0.03, 5)
end

DIBUJOS.abeja = function(m, c)
	m.vuela = true
	ala(m, 0.52, 0.27, 0.24, 0.3, BLANCO, 2, -20, 25, 38, 0, { t = 0.3 })
	pieza(m, 0.86, 0.58, 0.08, 0.08, NEGRO, 0.1, 2, 45)
	pieza(m, 0.54, 0.56, 0.62, 0.42, c, 0.5, 3)
	pieza(m, 0.58, 0.56, 0.07, 0.36, NEGRO, 0, 4, 0, { sb = true })
	pieza(m, 0.72, 0.56, 0.07, 0.3, NEGRO, 0, 4, 0, { sb = true })
	circ(m, 0.27, 0.5, 0.32, c, 5)
	pieza(m, 0.21, 0.29, 0.02, 0.13, NEGRO, 0, 4, -20, { sb = true })
	pieza(m, 0.31, 0.29, 0.02, 0.13, NEGRO, 0, 4, 15, { sb = true })
	circ(m, 0.19, 0.22, 0.05, NEGRO, 4, { sb = true })
	circ(m, 0.33, 0.22, 0.05, NEGRO, 4, { sb = true })
	ojo(m, 0.21, 0.47, 0.1, 0.11, 6)
	ojo(m, 0.33, 0.47, 0.1, 0.11, 6)
	boca(m, 0.26, 0.58, 0.08, 0.025, 6)
	ala(m, 0.64, 0.29, 0.24, 0.3, BLANCO, 7, 15, 25, 38, 0.5, { t = 0.3 })
end

DIBUJOS.lobo = function(m, c)
	sombra(m, 0.8)
	pieza(m, 0.86, 0.5, 0.24, 0.08, c, 0.5, 1, -35)
	local oscuro = c:Lerp(NEGRO, 0.25)
	pie(m, 0.4, 0.83, 0.08, 0.18, oscuro)
	pie(m, 0.52, 0.83, 0.08, 0.18, oscuro)
	pie(m, 0.66, 0.83, 0.08, 0.18, oscuro)
	pie(m, 0.78, 0.83, 0.08, 0.18, oscuro)
	pieza(m, 0.6, 0.6, 0.58, 0.3, c, 0.4, 3)
	pieza(m, 0.2, 0.27, 0.1, 0.13, c, 0.2, 4, -15)
	pieza(m, 0.35, 0.26, 0.1, 0.13, c, 0.2, 4, 15)
	circ(m, 0.28, 0.44, 0.34, c, 5)
	pieza(m, 0.13, 0.53, 0.2, 0.12, c:Lerp(BLANCO, 0.3), 0.4, 6)
	circ(m, 0.05, 0.5, 0.06, NEGRO, 7, { sb = true })
	ojo(m, 0.23, 0.42, 0.1, 0.08, 7, Color3.fromRGB(255, 220, 80))
	ojo(m, 0.34, 0.42, 0.1, 0.08, 7, Color3.fromRGB(255, 220, 80))
	boca(m, 0.15, 0.59, 0.13, 0.02, 7)
	pieza(m, 0.12, 0.61, 0.025, 0.04, BLANCO, 0, 8, 0, { sb = true })
end

DIBUJOS.rana = function(m, c)
	sombra(m, 0.8)
	pieza(m, 0.78, 0.82, 0.24, 0.13, c:Lerp(NEGRO, 0.15), 0.5, 2)
	pieza(m, 0.5, 0.72, 0.74, 0.4, c, 0.5, 3)
	pieza(m, 0.48, 0.79, 0.42, 0.22, Color3.fromRGB(215, 235, 175), 0.5, 4, 0, { sb = true })
	circ(m, 0.33, 0.47, 0.24, c, 4)
	circ(m, 0.6, 0.47, 0.24, c, 4)
	ojo(m, 0.33, 0.47, 0.15, 0.15, 5)
	ojo(m, 0.6, 0.47, 0.15, 0.15, 5)
	boca(m, 0.46, 0.66, 0.42, 0.025, 5, NEGRO)
	circ(m, 0.22, 0.66, 0.08, Color3.fromRGB(250, 130, 140), 5, { sb = true, t = 0.4 })
	pie(m, 0.32, 0.93, 0.18, 0.06, c:Lerp(NEGRO, 0.15))
	pie(m, 0.62, 0.93, 0.18, 0.06, c:Lerp(NEGRO, 0.15))
end

DIBUJOS.planta = function(m, c)
	sombra(m, 0.5)
	pieza(m, 0.5, 0.93, 0.36, 0.1, Color3.fromRGB(190, 110, 70), 0.2, 3) -- maceta de raíces
	pieza(m, 0.6, 0.74, 0.08, 0.4, Color3.fromRGB(80, 150, 70), 0.4, 1)
	ala(m, 0.76, 0.8, 0.26, 0.1, Color3.fromRGB(90, 170, 80), 2, -25, 8, 3, 0)
	ala(m, 0.42, 0.85, 0.24, 0.09, Color3.fromRGB(90, 170, 80), 2, 25, 8, 3, 1.5)
	circ(m, 0.44, 0.42, 0.62, c, 3)
	circ(m, 0.62, 0.28, 0.08, BLANCO, 4, { sb = true })
	circ(m, 0.66, 0.5, 0.06, BLANCO, 4, { sb = true })
	boca(m, 0.32, 0.48, 0.32, 0.22, 4, Color3.fromRGB(70, 10, 25))
	for k = 0, 2 do
		pieza(m, 0.22 + k * 0.09, 0.39, 0.05, 0.05, BLANCO, 0, 5, 45, { gr = 1 })
		pieza(m, 0.22 + k * 0.09, 0.57, 0.05, 0.05, BLANCO, 0, 5, 45, { gr = 1 })
	end
	ojo(m, 0.46, 0.22, 0.12, 0.12, 5)
	ojo(m, 0.6, 0.22, 0.12, 0.12, 5)
end

DIBUJOS.fantasma = function(m, c)
	m.vuela = true
	ala(m, 0.2, 0.56, 0.18, 0.08, c, 2, 30, 15, 4, 0, { t = 0.15 })
	pieza(m, 0.5, 0.5, 0.6, 0.64, c, 0.5, 3, 0, { t = 0.12 })
	for k = -1, 1 do
		circ(m, 0.5 + k * 0.18, 0.8, 0.2, c, 3, { t = 0.12 })
	end
	pieza(m, 0.42, 0.44, 0.09, 0.14, NEGRO, 0.5, 5, 0, { sb = true })
	pieza(m, 0.58, 0.44, 0.09, 0.14, NEGRO, 0.5, 5, 0, { sb = true })
	boca(m, 0.5, 0.6, 0.1, 0.1, 5, NEGRO)
	ala(m, 0.8, 0.56, 0.18, 0.08, c, 4, -30, 15, 4, 1, { t = 0.15 })
end

DIBUJOS.duende = function(m, c)
	sombra(m, 0.6)
	pieza(m, 0.16, 0.55, 0.03, 0.82, Color3.fromRGB(120, 80, 50), 0.3, 1)
	pieza(m, 0.16, 0.13, 0.08, 0.08, Color3.fromRGB(200, 205, 215), 0.1, 1, 45)
	pie(m, 0.42, 0.94, 0.14, 0.06, Color3.fromRGB(80, 55, 40))
	pie(m, 0.58, 0.94, 0.14, 0.06, Color3.fromRGB(80, 55, 40))
	pieza(m, 0.5, 0.74, 0.42, 0.3, Color3.fromRGB(130, 90, 60), 0.3, 3)
	circ(m, 0.2, 0.68, 0.1, c, 6)
	circ(m, 0.78, 0.7, 0.1, c, 6)
	pieza(m, 0.24, 0.38, 0.22, 0.07, c, 0.5, 4, 15)
	pieza(m, 0.76, 0.38, 0.22, 0.07, c, 0.5, 4, -15)
	circ(m, 0.5, 0.4, 0.5, c, 5)
	ojo(m, 0.42, 0.38, 0.12, 0.1, 7, Color3.fromRGB(255, 240, 150), Color3.fromRGB(170, 30, 30))
	ojo(m, 0.58, 0.38, 0.12, 0.1, 7, Color3.fromRGB(255, 240, 150), Color3.fromRGB(170, 30, 30))
	pieza(m, 0.46, 0.46, 0.08, 0.06, c:Lerp(NEGRO, 0.2), 0.5, 8)
	boca(m, 0.5, 0.53, 0.16, 0.03, 8)
	pieza(m, 0.46, 0.55, 0.025, 0.03, BLANCO, 0, 9, 0, { sb = true })
	pieza(m, 0.54, 0.55, 0.025, 0.03, BLANCO, 0, 9, 0, { sb = true })
end

DIBUJOS.arana = function(m, c)
	sombra(m, 0.85)
	for k = 0, 3 do
		local ang = -36 + k * 24
		ala(m, 0.3, 0.68, 0.36, 0.035, NEGRO, 1, ang, 7, 9, k, { sb = true })
		ala(m, 0.76, 0.68, 0.36, 0.035, NEGRO, 1, -ang, 7, 9, k + 2, { sb = true })
	end
	circ(m, 0.6, 0.56, 0.44, c, 3)
	circ(m, 0.66, 0.5, 0.1, Color3.fromRGB(200, 60, 60), 4, { sb = true })
	circ(m, 0.37, 0.62, 0.28, c, 4)
	for _, o in { { 0.31, 0.58 }, { 0.4, 0.57 }, { 0.33, 0.64 }, { 0.42, 0.64 } } do
		ojo(m, o[1], o[2], 0.06, 0.06, 5, Color3.fromRGB(255, 70, 70), NEGRO, 0.025)
	end
	boca(m, 0.36, 0.72, 0.08, 0.02, 5)
	pieza(m, 0.33, 0.75, 0.02, 0.04, BLANCO, 0, 6, 0, { sb = true })
	pieza(m, 0.39, 0.75, 0.02, 0.04, BLANCO, 0, 6, 0, { sb = true })
end

DIBUJOS.tronco = function(m, c)
	sombra(m, 0.7)
	pie(m, 0.3, 0.95, 0.22, 0.06, c:Lerp(NEGRO, 0.2))
	pie(m, 0.7, 0.95, 0.22, 0.06, c:Lerp(NEGRO, 0.2))
	ala(m, 0.17, 0.55, 0.32, 0.06, c, 2, 25, 10, 2.5, 0)
	ala(m, 0.83, 0.5, 0.32, 0.06, c, 2, -25, 10, 2.5, 1.5)
	circ(m, 0.33, 0.24, 0.42, Color3.fromRGB(70, 145, 65), 1)
	circ(m, 0.66, 0.21, 0.44, Color3.fromRGB(80, 155, 70), 1)
	circ(m, 0.5, 0.11, 0.4, Color3.fromRGB(95, 170, 80), 1)
	pieza(m, 0.5, 0.62, 0.5, 0.66, c, 0.15, 3)
	pieza(m, 0.38, 0.47, 0.025, 0.3, c:Lerp(NEGRO, 0.3), 0, 4, 0, { sb = true })
	pieza(m, 0.64, 0.78, 0.025, 0.24, c:Lerp(NEGRO, 0.3), 0, 4, 0, { sb = true })
	ojo(m, 0.42, 0.5, 0.12, 0.1, 5, Color3.fromRGB(40, 25, 20), Color3.fromRGB(255, 220, 80))
	ojo(m, 0.58, 0.5, 0.12, 0.1, 5, Color3.fromRGB(40, 25, 20), Color3.fromRGB(255, 220, 80))
	boca(m, 0.5, 0.68, 0.22, 0.05, 5, Color3.fromRGB(40, 25, 20))
end

DIBUJOS.esqueleto = function(m, c)
	sombra(m, 0.55)
	pieza(m, 0.82, 0.56, 0.05, 0.42, Color3.fromRGB(170, 120, 90), 0.2, 1, 8)
	pieza(m, 0.8, 0.74, 0.15, 0.03, Color3.fromRGB(110, 80, 60), 0.2, 1, 8)
	pie(m, 0.43, 0.88, 0.045, 0.17, c)
	pie(m, 0.57, 0.88, 0.045, 0.17, c)
	pieza(m, 0.31, 0.66, 0.045, 0.24, c, 0.4, 2, 15)
	pieza(m, 0.69, 0.66, 0.045, 0.24, c, 0.4, 2, -15)
	pieza(m, 0.5, 0.68, 0.32, 0.28, c, 0.3, 3)
	for k = 0, 2 do
		pieza(m, 0.5, 0.61 + k * 0.065, 0.26, 0.022, Color3.fromRGB(80, 70, 70), 0, 4, 0, { sb = true })
	end
	pieza(m, 0.5, 0.68, 0.03, 0.28, Color3.fromRGB(80, 70, 70), 0, 4, 0, { sb = true })
	circ(m, 0.5, 0.34, 0.42, c, 5)
	pieza(m, 0.5, 0.5, 0.24, 0.08, c, 0.3, 5)
	ojo(m, 0.42, 0.34, 0.11, 0.11, 6, Color3.fromRGB(40, 30, 45), Color3.fromRGB(255, 70, 70), 0.04)
	ojo(m, 0.58, 0.34, 0.11, 0.11, 6, Color3.fromRGB(40, 30, 45), Color3.fromRGB(255, 70, 70), 0.04)
	pieza(m, 0.5, 0.42, 0.04, 0.04, Color3.fromRGB(40, 30, 45), 0, 6, 45, { sb = true })
	boca(m, 0.5, 0.5, 0.18, 0.02, 6, Color3.fromRGB(40, 30, 45))
end

DIBUJOS.murcielago = function(m, c)
	m.vuela = true
	local oscuro = c:Lerp(NEGRO, 0.3)
	ala(m, 0.22, 0.45, 0.38, 0.18, oscuro, 2, 20, 30, 16, 0)
	ala(m, 0.78, 0.45, 0.38, 0.18, oscuro, 2, -20, -30, 16, 0)
	pieza(m, 0.4, 0.3, 0.08, 0.13, c, 0.2, 2, -15)
	pieza(m, 0.6, 0.3, 0.08, 0.13, c, 0.2, 2, 15)
	circ(m, 0.5, 0.5, 0.4, c, 3)
	ojo(m, 0.43, 0.46, 0.11, 0.1, 5, Color3.fromRGB(255, 230, 90))
	ojo(m, 0.57, 0.46, 0.11, 0.1, 5, Color3.fromRGB(255, 230, 90))
	boca(m, 0.5, 0.58, 0.12, 0.025, 5)
	pieza(m, 0.46, 0.605, 0.025, 0.04, BLANCO, 0, 6, 0, { sb = true })
	pieza(m, 0.54, 0.605, 0.025, 0.04, BLANCO, 0, 6, 0, { sb = true })
end

DIBUJOS.golem = function(m, c)
	sombra(m, 0.75)
	pie(m, 0.38, 0.93, 0.18, 0.08, c:Lerp(NEGRO, 0.2))
	pie(m, 0.62, 0.93, 0.18, 0.08, c:Lerp(NEGRO, 0.2))
	ala(m, 0.15, 0.62, 0.18, 0.34, c:Lerp(NEGRO, 0.1), 2, 8, 5, 2, 0)
	ala(m, 0.85, 0.62, 0.18, 0.34, c:Lerp(NEGRO, 0.1), 2, -8, 5, 2, 1)
	pieza(m, 0.5, 0.64, 0.58, 0.46, c, 0.12, 3)
	pieza(m, 0.36, 0.46, 0.18, 0.06, Color3.fromRGB(90, 160, 80), 0.4, 4, 0, { sb = true })
	pieza(m, 0.66, 0.8, 0.14, 0.05, Color3.fromRGB(90, 160, 80), 0.4, 4, 0, { sb = true })
	brillo(m, circ(m, 0.5, 0.64, 0.12, Color3.fromRGB(110, 230, 255), 5))
	pieza(m, 0.5, 0.29, 0.38, 0.26, c, 0.12, 4)
	ojo(m, 0.43, 0.28, 0.09, 0.05, 6, Color3.fromRGB(110, 230, 255), Color3.fromRGB(110, 230, 255))
	ojo(m, 0.57, 0.28, 0.09, 0.05, 6, Color3.fromRGB(110, 230, 255), Color3.fromRGB(110, 230, 255))
	boca(m, 0.5, 0.36, 0.14, 0.025, 6, Color3.fromRGB(50, 50, 60))
end

DIBUJOS.mimico = function(m, c)
	sombra(m, 0.75)
	pie(m, 0.3, 0.94, 0.1, 0.08, c:Lerp(NEGRO, 0.3))
	pie(m, 0.7, 0.94, 0.1, 0.08, c:Lerp(NEGRO, 0.3))
	pieza(m, 0.5, 0.74, 0.74, 0.34, c, 0.1, 2)
	pieza(m, 0.5, 0.74, 0.76, 0.05, Color3.fromRGB(240, 200, 70), 0, 3)
	boca(m, 0.5, 0.56, 0.6, 0.14, 3, Color3.fromRGB(110, 20, 40))
	pieza(m, 0.44, 0.6, 0.16, 0.05, Color3.fromRGB(240, 110, 140), 0.5, 4, -15, { sb = true }) -- lengua
	for k = 0, 4 do
		pieza(m, 0.26 + k * 0.12, 0.51, 0.06, 0.06, BLANCO, 0, 4, 45, { gr = 1 })
		pieza(m, 0.26 + k * 0.12, 0.61, 0.06, 0.06, BLANCO, 0, 4, 45, { gr = 1 })
	end
	ala(m, 0.5, 0.36, 0.78, 0.22, c:Lerp(BLANCO, 0.1), 5, 0, 6, 5, 0) -- la tapa abre y cierra
	pieza(m, 0.5, 0.42, 0.14, 0.08, Color3.fromRGB(240, 200, 70), 0.2, 6)
	ojo(m, 0.38, 0.3, 0.12, 0.1, 7, Color3.fromRGB(255, 240, 120))
	ojo(m, 0.62, 0.3, 0.12, 0.1, 7, Color3.fromRGB(255, 240, 120))
end

DIBUJOS.reyHongo = function(m, c)
	sombra(m, 0.8)
	pie(m, 0.38, 0.95, 0.2, 0.06, Color3.fromRGB(120, 80, 50))
	pie(m, 0.62, 0.95, 0.2, 0.06, Color3.fromRGB(120, 80, 50))
	ala(m, 0.17, 0.68, 0.2, 0.08, Color3.fromRGB(245, 235, 210), 2, 20, 12, 3, 0)
	ala(m, 0.83, 0.68, 0.2, 0.08, Color3.fromRGB(245, 235, 210), 2, -20, 12, 3, 1.5)
	pieza(m, 0.5, 0.72, 0.5, 0.46, Color3.fromRGB(245, 235, 210), 0.3, 3)
	pieza(m, 0.5, 0.36, 0.98, 0.46, c, 0.5, 4)
	for _, s in { { 0.22, 0.34, 0.12 }, { 0.42, 0.24, 0.13 }, { 0.62, 0.3, 0.11 }, { 0.8, 0.4, 0.09 }, { 0.36, 0.45, 0.08 } } do
		circ(m, s[1], s[2], s[3], BLANCO, 5, { sb = true })
	end
	pieza(m, 0.5, 0.12, 0.3, 0.06, Color3.fromRGB(250, 200, 60), 0.1, 6)
	for k = -1, 1 do
		pieza(m, 0.5 + k * 0.09, 0.075, 0.06, 0.06, Color3.fromRGB(250, 200, 60), 0.1, 6, 45)
	end
	circ(m, 0.5, 0.12, 0.04, Color3.fromRGB(230, 50, 60), 7, { sb = true })
	ojo(m, 0.42, 0.66, 0.12, 0.11, 6, Color3.fromRGB(255, 245, 160))
	ojo(m, 0.58, 0.66, 0.12, 0.11, 6, Color3.fromRGB(255, 245, 160))
	boca(m, 0.5, 0.8, 0.22, 0.06, 6, Color3.fromRGB(70, 20, 30))
	for k = -1, 1 do
		pieza(m, 0.5 + k * 0.06, 0.785, 0.03, 0.03, BLANCO, 0, 7, 0, { sb = true })
	end
end

-- ---------- Picos Nevados (historia 2) ----------
DIBUJOS.pinguino = function(m, c)
	sombra(m, 0.55)
	pie(m, 0.42, 0.95, 0.14, 0.05, Color3.fromRGB(240, 160, 60))
	pie(m, 0.58, 0.95, 0.14, 0.05, Color3.fromRGB(240, 160, 60))
	ala(m, 0.24, 0.62, 0.1, 0.28, c, 2, 15, 18, 6, 0)
	ala(m, 0.76, 0.62, 0.1, 0.28, c, 2, -15, 18, 6, 1)
	pieza(m, 0.5, 0.6, 0.5, 0.66, c, 0.5, 3)
	pieza(m, 0.5, 0.66, 0.34, 0.5, BLANCO, 0.5, 4)
	-- antifaz de bandido
	pieza(m, 0.5, 0.42, 0.42, 0.08, Color3.fromRGB(40, 35, 45), 0.4, 5)
	ojo(m, 0.43, 0.42, 0.09, 0.07, 6)
	ojo(m, 0.57, 0.42, 0.09, 0.07, 6)
	pieza(m, 0.44, 0.5, 0.1, 0.05, Color3.fromRGB(240, 160, 60), 0.3, 6, -10)
	pieza(m, 0.66, 0.4, 0.14, 0.035, Color3.fromRGB(200, 60, 60), 0.4, 6, -25) -- cinta del antifaz
end

DIBUJOS.munecoNieve = function(m, c)
	sombra(m, 0.7)
	pieza(m, 0.5, 0.77, 0.66, 0.4, c, 0.5, 2)
	pieza(m, 0.5, 0.47, 0.5, 0.32, c, 0.5, 3)
	pieza(m, 0.5, 0.22, 0.36, 0.24, c, 0.5, 4)
	ala(m, 0.17, 0.46, 0.22, 0.03, Color3.fromRGB(110, 75, 45), 2, 25, 15, 4, 0)
	ala(m, 0.83, 0.46, 0.22, 0.03, Color3.fromRGB(110, 75, 45), 2, -25, 15, 4, 1)
	for k = 0, 2 do
		circ(m, 0.5, 0.42 + k * 0.08, 0.04, Color3.fromRGB(50, 45, 55), 5, { sb = true })
	end
	pieza(m, 0.5, 0.33, 0.44, 0.06, Color3.fromRGB(200, 60, 60), 0.3, 6) -- bufanda
	pieza(m, 0.6, 0.39, 0.08, 0.14, Color3.fromRGB(200, 60, 60), 0.3, 6, 10)
	ojo(m, 0.44, 0.19, 0.07, 0.06, 7, Color3.fromRGB(50, 45, 55), Color3.fromRGB(50, 45, 55))
	ojo(m, 0.56, 0.19, 0.07, 0.06, 7, Color3.fromRGB(50, 45, 55), Color3.fromRGB(50, 45, 55))
	pieza(m, 0.38, 0.25, 0.16, 0.04, Color3.fromRGB(240, 140, 50), 0.4, 7, 8) -- zanahoria
	boca(m, 0.52, 0.29, 0.1, 0.02, 7, Color3.fromRGB(50, 45, 55))
	pieza(m, 0.5, 0.09, 0.3, 0.05, Color3.fromRGB(50, 45, 55), 0.1, 8) -- sombrero
	pieza(m, 0.5, 0.04, 0.2, 0.08, Color3.fromRGB(50, 45, 55), 0.1, 8)
end

DIBUJOS.yeti = function(m, c)
	sombra(m, 0.85)
	pie(m, 0.36, 0.95, 0.22, 0.07, c:Lerp(NEGRO, 0.15))
	pie(m, 0.64, 0.95, 0.22, 0.07, c:Lerp(NEGRO, 0.15))
	ala(m, 0.13, 0.6, 0.22, 0.4, c, 2, 12, 10, 2.5, 0)
	ala(m, 0.87, 0.6, 0.22, 0.4, c, 2, -12, 10, 2.5, 1.5)
	pieza(m, 0.5, 0.62, 0.72, 0.62, c, 0.4, 3)
	pieza(m, 0.5, 0.68, 0.42, 0.4, Color3.fromRGB(190, 210, 230), 0.45, 4) -- barriga
	-- babero de cocinero (le encanta comer)
	pieza(m, 0.5, 0.58, 0.3, 0.2, BLANCO, 0.2, 5)
	pieza(m, 0.5, 0.26, 0.56, 0.38, c, 0.45, 6)
	pieza(m, 0.5, 0.31, 0.34, 0.2, Color3.fromRGB(150, 180, 210), 0.45, 7) -- cara
	pieza(m, 0.5, 0.06, 0.3, 0.1, BLANCO, 0.5, 8) -- gorro de cocinero
	pieza(m, 0.5, 0.11, 0.24, 0.06, BLANCO, 0.1, 8)
	ojo(m, 0.43, 0.27, 0.08, 0.07, 9)
	ojo(m, 0.57, 0.27, 0.08, 0.07, 9)
	boca(m, 0.5, 0.37, 0.18, 0.05, 9, Color3.fromRGB(80, 30, 40))
	pieza(m, 0.46, 0.355, 0.03, 0.04, BLANCO, 0, 10, 0, { sb = true })
	pieza(m, 0.54, 0.355, 0.03, 0.04, BLANCO, 0, 10, 0, { sb = true })
end
DIBUJOS.loboBlanco = DIBUJOS.lobo
DIBUJOS.espiritu = DIBUJOS.fantasma

-- ===================== CREAR =====================
local function nuevo(padre: Instance, aspecto: number, grosor: number?): Muneco
	local raiz = Instance.new("Frame")
	raiz.Name = "Muneco"
	raiz.Size = UDim2.fromScale(1, 1)
	raiz.BackgroundTransparency = 1
	local cuerpo = Instance.new("Frame")
	cuerpo.Name = "Cuerpo"
	cuerpo.AnchorPoint = Vector2.new(0.5, 1)
	cuerpo.Position = UDim2.fromScale(0.5, 1)
	cuerpo.Size = UDim2.fromScale(1, 1)
	cuerpo.BackgroundTransparency = 1
	cuerpo.Parent = raiz
	local m: Muneco = {
		raiz = raiz,
		cuerpo = cuerpo,
		aspecto = aspecto,
		grosor = math.max(1.5, (grosor or 3) - 0.5),
		piezas = {},
		ojos = {},
		pupilas = {},
		boca = nil,
		pies = {},
		alas = {},
		manos = {},
		vy = 0,
		ritmo = 1,
		giro = 0,
		ultimoMirar = 0,
		enSuelo = true,
		aterriza = 0,
		brillos = {},
		vuela = false,
		andar = 0,
		mirar = 0,
		espejo = false,
		t = math.random() * 10,
		proxParpadeo = os.clock() + math.random() * 3,
		parpadeo = 0,
		golpe = 0,
		hablar = 0,
		salto = 0,
		dirSalto = 1,
		caido = false,
		tenido = false,
		semilla = math.random(1, 1e6),
	}
	raiz.Parent = padre
	return m
end

local function arrancar()
	if conexion then
		return
	end
	conexion = RunService.RenderStepped:Connect(function(dt)
		local ahora = os.clock()
		local i = 1
		while i <= #activos do
			local m = activos[i]
			if not m.raiz.Parent or not m.raiz:IsDescendantOf(game) then
				table.remove(activos, i)
			else
				Munecos.actualizar(m, dt, ahora)
				i += 1
			end
		end
	end)
end

--- tipo: "clase" (héroe), "enemigo" o "vecino". Devuelve el muñeco ya animándose.
function Munecos.crear(padre: Instance, tipo: string, id: string, grosor: number?, apariencia: { [string]: any }?): Muneco
	local m
	if tipo == "enemigo" then
		m = nuevo(padre, 1, grosor)
		local dibujar = DIBUJOS[id] or DIBUJOS.babosa
		local def = Datos.Enemigos[id]
		local color = def and def.color or Color3.fromRGB(150, 150, 150)
		dibujar(m, color)
	elseif tipo == "vendedor" then
		m = nuevo(padre, 1.3, grosor)
		dibujarVendedor(m)
	elseif tipo == "vecino" then
		m = nuevo(padre, 1.3, grosor)
		dibujarVecino(m, tonumber(id) or 1)
	else
		m = nuevo(padre, 1.3, grosor)
		dibujarHeroe(m, id, apariencia)
	end
	table.insert(activos, m)
	arrancar()
	return m
end

--- Da la vuelta al muñeco (mirar al otro lado).
function Munecos.espejo(m: Muneco, valor: boolean)
	if m.espejo == valor then
		return
	end
	m.espejo = valor
	for _, p in m.piezas do
		local x = valor and (1 - p.x) or p.x
		p.f.Position = UDim2.new(x, 0, p.f.Position.Y.Scale, 0)
		p.f.Rotation = valor and -p.rot or p.rot
	end
end

-- ===================== ANIMACIÓN (cada fotograma) =====================
function Munecos.actualizar(m: Muneco, dt: number, ahora: number)
	m.t += dt
	local t = m.t
	if m.caido then
		return
	end
	-- respiración y saltitos al andar (squash & stretch)
	local bote, aplasta = 0, 0
	if m.vuela then
		bote = math.sin(t * 3) * 0.05 + 0.04
		aplasta = math.sin(t * 6) * 0.015
	elseif m.andar > 0.05 then
		-- el ritmo de los pasos va con la velocidad (al correr, pasos más rápidos y más bote)
		m.t += dt * (m.ritmo - 1)
		t = m.t
		local fase = math.abs(math.sin(t * 9))
		bote = fase * 0.07 * m.andar * math.min(1.4, m.ritmo)
		aplasta = (0.5 - fase) * 0.06 * m.andar
	else
		aplasta = math.sin(t * 2.4) * 0.02
	end
	if m.salto > 0 then
		m.salto = math.max(0, m.salto - dt)
		local k = m.salto / 0.45
		bote += math.sin(k * math.pi) * 0.18
	end
	-- en el aire: se estira al subir y encoge las piernas al caer; al aterrizar, se aplasta (como en los plataformas)
	local inclina = 0
	if not m.enSuelo and not m.vuela then
		if m.vy > 2 then
			aplasta = -0.09
		elseif m.vy < -2 then
			aplasta = -0.04
		end
		inclina = math.clamp(-m.vy * 0.4, -8, 8) * (m.mirar ~= 0 and m.mirar or 1)
		m.aterriza = 0.18
	elseif m.aterriza > 0 then
		m.aterriza = math.max(0, m.aterriza - dt)
		if m.aterriza < 0.16 then
			aplasta = 0.12 * (m.aterriza / 0.16)
		end
	end
	local temblor = 0
	if m.golpe > 0 then
		m.golpe = math.max(0, m.golpe - dt)
		temblor = math.sin(ahora * 70) * 0.04 * (m.golpe / 0.5)
	end
	local avance = 0
	if m.salto > 0 then
		avance = math.sin((m.salto / 0.45) * math.pi) * 0.12 * m.dirSalto
	end
	-- media vuelta: al cambiar de dirección se estrecha un momento, como un recortable que gira
	if m.mirar ~= 0 and m.ultimoMirar ~= 0 and m.mirar ~= m.ultimoMirar then
		m.giro = 0.16
	end
	if m.mirar ~= 0 then
		m.ultimoMirar = m.mirar
	end
	local estrecha = 0
	if m.giro > 0 then
		m.giro = math.max(0, m.giro - dt)
		estrecha = math.sin((m.giro / 0.16) * math.pi) * 0.35
	end
	m.cuerpo.Position = UDim2.fromScale(0.5 + temblor + avance, 1 - bote)
	m.cuerpo.Size = UDim2.fromScale((1 + aplasta) * (1 - estrecha), 1 - aplasta)
	-- al correr se inclina hacia delante (hacia donde mira) y se balancea
	local carrera = m.andar > 0.05 and (math.sin(t * 9) * 3 * m.andar + 6 * m.andar * m.mirar * m.ritmo) or 0
	m.cuerpo.Rotation = carrera + inclina
	-- brazos: se balancean al correr y suben al saltar
	for k, mano in m.manos do
		local lado = k == 1 and 1 or -1
		local dy = 0
		if not m.enSuelo and not m.vuela then
			dy = m.vy > 0 and -0.14 or -0.07
		elseif m.andar > 0.05 then
			dy = math.sin(t * 9 + (lado > 0 and 0 or math.pi)) * 0.035 * m.andar
		end
		local x = m.espejo and (1 - mano.x) or mano.x
		mano.f.Position = UDim2.fromScale(x, mano.y + dy)
	end

	-- pies alternos
	for k, p in m.pies do
		local lado = (k % 2 == 0) and 1 or -1
		local sube = m.andar > 0.05 and math.max(0, math.sin(t * 9 + (lado > 0 and math.pi or 0))) * 0.04 * m.andar or 0
		if not m.enSuelo and not m.vuela then
			sube = 0.05 + (lado > 0 and 0.02 or 0)
		end
		p.f.Position = UDim2.new(p.f.Position.X.Scale, 0, p.y - sube, 0)
	end

	-- alas, patas y ramas
	for _, a in m.alas do
		local r = a.p.rot + math.sin(t * a.vel + a.fase) * a.amp
		a.p.f.Rotation = m.espejo and -r or r
	end

	-- parpadeo
	if ahora > m.proxParpadeo then
		m.parpadeo = 0.13
		m.proxParpadeo = ahora + 2 + math.random() * 3.5
	end
	local cerrado = m.parpadeo > 0
	if cerrado then
		m.parpadeo -= dt
	end
	for _, o in m.ojos do
		o.f.Size = cerrado and UDim2.fromScale(o.tam.X.Scale, o.tam.Y.Scale * 0.12) or o.tam
	end
	-- pupilas: miran hacia donde va
	local dx = m.mirar * 0.025
	for _, p in m.pupilas do
		local x = m.espejo and (1 - p.x) or p.x
		p.f.Position = UDim2.fromScale(x + dx, p.y)
		p.f.Visible = not cerrado
	end
	-- boca: se abre al hablar o atacar
	if m.boca then
		if m.hablar > 0 then
			m.hablar = math.max(0, m.hablar - dt)
			local abre = 1 + math.abs(math.sin(ahora * 18)) * 3
			m.boca.f.Size = UDim2.fromScale(m.boca.tam.X.Scale, m.boca.tam.Y.Scale * abre)
		else
			m.boca.f.Size = m.boca.tam
		end
	end
	-- brillos (orbes, runas)
	for _, b in m.brillos do
		b.BackgroundTransparency = 0.15 + math.sin(t * 4) * 0.15
	end
	-- destello rojo al recibir un golpe
	if m.golpe > 0 then
		local k = (math.sin(ahora * 40) > 0) and 0.55 or 0.1
		for _, p in m.piezas do
			p.f.BackgroundColor3 = p.color:Lerp(Color3.fromRGB(255, 60, 60), k)
		end
		m.tenido = true
	elseif m.tenido then
		for _, p in m.piezas do
			p.f.BackgroundColor3 = p.color
		end
		m.tenido = false
	end
end

-- ===================== ACCIONES =====================
function Munecos.golpear(m: Muneco)
	m.golpe = 0.5
end

function Munecos.atacar(m: Muneco, direccion: number?)
	m.salto = 0.45
	m.dirSalto = direccion or 1
	m.hablar = 0.45
end

function Munecos.hablar(m: Muneco, segundos: number)
	m.hablar = segundos
end

function Munecos.caer(m: Muneco, caido: boolean)
	if m.caido == caido then
		return
	end
	m.caido = caido
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	if caido then
		TweenService:Create(m.cuerpo, info, { Rotation = m.espejo and 82 or -82, Position = UDim2.fromScale(0.5, 1.05) }):Play()
	else
		TweenService:Create(m.cuerpo, info, { Rotation = 0, Position = UDim2.fromScale(0.5, 1) }):Play()
	end
end

return Munecos
