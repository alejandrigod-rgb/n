--!strict
-- Mapa de Vael (tecla M) y objetivos. Un mapa de papel dibujado: zonas, caminos, el río, las calles de la ciudad,
-- los sitios importantes, los caminos cerrados (candado), los paraderos (!), el objetivo (estrella) y tú.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ui = require(script.Parent:WaitForChild("Ui"))
local Datos = require(ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Datos")) :: any
local C = Ui.Colores

local Mapa = {}

-- zonas del mundo: dónde están en el mapa dibujado (mx, my) y qué tramo del mundo ocupan (desde, hasta)
local ZONAS = {
	{ id = "aldea", nombre = "Aldea de Brezo", mx = 90, my = 300, desde = -445, hasta = -205, color = Color3.fromRGB(170, 200, 120) },
	{ id = "ciudad", nombre = "Ciudad de Vael", mx = 250, my = 260, desde = -205, hasta = 45, color = Color3.fromRGB(225, 190, 140) },
	{ id = "pradera", nombre = "Pradera", mx = 410, my = 230, desde = 45, hasta = 163, color = Color3.fromRGB(140, 200, 110) },
	{ id = "pantano", nombre = "Pantano Brumoso", mx = 560, my = 300, desde = 163, hasta = 263, color = Color3.fromRGB(110, 150, 130), llave = "cuerda" },
	{ id = "bosque", nombre = "Bosque Susurrante", mx = 690, my = 190, desde = 263, hasta = 363, color = Color3.fromRGB(80, 140, 85), llave = "hacha" },
	{ id = "ruinas", nombre = "Ruinas de Ceniza", mx = 800, my = 290, desde = 363, hasta = 463, color = Color3.fromRGB(170, 155, 135), llave = "llave" },
	{ id = "cueva", nombre = "Cueva del Rey Hongo", mx = 870, my = 130, desde = 463, hasta = 606, color = Color3.fromRGB(120, 105, 110), llave = "farol" },
	{ id = "picos", nombre = "Picos Nevados", mx = 720, my = 60, desde = 606, hasta = 712, color = Color3.fromRGB(200, 220, 240), llave = "botas" },
	{ id = "cumbre", nombre = "Cumbre del Yeti", mx = 560, my = 60, desde = 712, hasta = 806, color = Color3.fromRGB(150, 185, 225), llave = "pico" },
}
local CALLES = {
	mercado = { nombre = "Calle del Mercado", mx = 230, my = 120, color = Color3.fromRGB(240, 170, 110) },
	callejon = { nombre = "Callejón del Gato", mx = 300, my = 390, color = Color3.fromRGB(140, 120, 160) },
}
local SITIOS = {
	{ nombre = "Tu casa", mx = 60, my = 340, icono = "corazon" },
	{ nombre = "Huerto", mx = 140, my = 340, icono = "espada" },
	{ nombre = "Taberna", mx = 215, my = 300, icono = "moneda" },
	{ nombre = "Posada", mx = 280, my = 300, icono = "estrella" },
	{ nombre = "Herrería", mx = 195, my = 230, icono = "escudo" },
	{ nombre = "Ermitaño", mx = 720, my = 230, icono = "magia" },
}

--- Qué hacer ahora, según lo que ya tienes. Devuelve el texto y la x del mundo a la que ir.
local SETAS = { 272, 302.5, 352 }
local PALANCAS = { 372, 395, 452 }
function Mapa.objetivo(e: any): (string, number?)
	if not e or not e.clase then
		return "Elige tu clase y crea a tu héroe", nil
	end
	local ll = e.llaves or {}
	if not ll.cuerda then
		return "Gana 2 veces seguidas a los vasos en la taberna (ciudad)", -102
	elseif not ll.hacha then
		return "Sube por las tablas del Pantano hasta el cofre del hacha", 252
	elseif not ll.llave then
		local tengo = e.setas or {}
		if #tengo >= 3 then
			return "Lleva las 3 setas al ermitaño del Bosque", 329
		end
		for i, x in SETAS do
			if not table.find(tengo, i) then
				return Ui.t("Busca setas brillantes en el Bosque") .. " (" .. #tengo .. "/3)", x
			end
		end
	elseif not ll.farol then
		local tiradas = e.palancas or {}
		if #tiradas >= 3 then
			return "Abre el cofre de la cripta de las Ruinas", 440
		end
		for i, x in PALANCAS do
			if not table.find(tiradas, i) then
				return Ui.t("Tira de las palancas de las Ruinas") .. " (" .. #tiradas .. "/3)", x
			end
		end
	end
	if not e.final then
		return "Derrota al Rey Hongo en la Cueva", 540
	end
	-- historia 2
	if e.barba then
		if not e.afeitado then
			return "Ve al barbero Paco de la ciudad", -147
		end
		return "Date un baño en la posada", -22
	elseif not ll.botas then
		return "Habla con el Rey Hongo en su cueva", 552
	elseif not ll.pico then
		return "Consigue el pico de hielo junto al lago helado", 700
	elseif not e.final2 then
		return "Recupera la Olla: derrota al Yeti Tragón", 772
	end
	return "¡Historia terminada! Busca los secretos que te falten", nil
end

--- Dónde cae una posición del mundo en el mapa dibujado.
local function enMapa(pos: Vector3): (number, number)
	if pos.Y > 650 then
		return CALLES.callejon.mx, CALLES.callejon.my
	elseif pos.Y > 450 then
		return CALLES.mercado.mx, CALLES.mercado.my
	elseif pos.Y > 150 then
		return ZONAS[2].mx, ZONAS[2].my
	end
	for i, z in ZONAS do
		if pos.X >= z.desde and pos.X < z.hasta then
			local k = (pos.X - z.desde) / (z.hasta - z.desde)
			local sig = ZONAS[i + 1]
			if sig then
				return z.mx + (sig.mx - z.mx) * k * 0.6, z.my + (sig.my - z.my) * k * 0.6
			end
			return z.mx, z.my
		end
	end
	return ZONAS[1].mx, ZONAS[1].my
end

local function linea(padre: Instance, x1: number, y1: number, x2: number, y2: number, grosor: number, color: Color3, z: number)
	local dx, dy = x2 - x1, y2 - y1
	local largo = math.sqrt(dx * dx + dy * dy)
	local f = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2), Size = UDim2.fromOffset(largo + grosor * 0.6, grosor), Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = z, Parent = padre })
	Ui.esquinas(f, 999)
	return f
end

local abierto: Frame? = nil

function Mapa.estaAbierto(): boolean
	return abierto ~= nil and abierto.Parent ~= nil
end

function Mapa.cerrar()
	if abierto then
		abierto:Destroy()
		abierto = nil
	end
end

--- Abre el mapa grande (o lo cierra si ya está abierto).
function Mapa.alternar(gui: Instance, estado: any)
	if Mapa.estaAbierto() then
		Mapa.cerrar()
		return
	end
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(1000, 600), Parent = gui, ZIndex = 120 })
	abierto = p
	Ui.aparecer(p)
	Ui.crear("UISizeConstraint", { MaxSize = Vector2.new(1000, 600), Parent = p })
	Ui.texto({ Position = UDim2.fromOffset(0, 12), Size = UDim2.new(1, 0, 0, 40), Text = "Mapa de Vael", TextColor3 = C.oro, ZIndex = 121, Parent = p })
	Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 18), Size = UDim2.fromOffset(200, 24), Text = "M: cerrar", TextColor3 = C.suave, ZIndex = 121, Parent = p })
	-- hoja de papel del mapa
	local hoja = Ui.crear("Frame", { Position = UDim2.fromOffset(40, 60), Size = UDim2.fromOffset(920, 440), BackgroundColor3 = Color3.fromRGB(236, 222, 190), BorderSizePixel = 0, Rotation = -0.6, ZIndex = 121, Parent = p })
	Ui.esquinas(hoja, 6)
	Ui.borde(hoja, C.tinta, 2)
	-- manchas de bosque y montañas dibujadas
	for k = 0, 9 do
		local m = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(60 + k * 95, 40 + (k % 3) * 12), Size = UDim2.fromOffset(46, 46), Rotation = 45, BackgroundColor3 = Color3.fromRGB(190, 180, 165), BorderSizePixel = 0, ZIndex = 122, Parent = hoja })
		Ui.borde(m, Color3.fromRGB(140, 125, 110), 1.5)
	end
	-- el río (entre la Pradera y el Pantano)
	for k = 0, 7 do
		linea(hoja, 488 + (k % 2) * 14, k * 58, 488 + ((k + 1) % 2) * 14, (k + 1) * 58, 9, Color3.fromRGB(110, 170, 210), 123)
	end
	-- caminos
	for i = 1, #ZONAS - 1 do
		local a, b = ZONAS[i], ZONAS[i + 1]
		linea(hoja, a.mx, a.my, b.mx, b.my, 12, Color3.fromRGB(190, 150, 100), 124)
	end
	for _, c in CALLES do
		linea(hoja, ZONAS[2].mx, ZONAS[2].my, c.mx, c.my, 9, Color3.fromRGB(170, 140, 110), 124)
	end
	-- zonas
	local function zona(nombre: string, mx: number, my: number, color: Color3, cerrada: boolean)
		local f = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(mx, my), Size = UDim2.fromOffset(150, 64), BackgroundColor3 = cerrada and Color3.fromRGB(150, 145, 140) or Ui.apagar(color), BorderSizePixel = 0, ZIndex = 125, Parent = hoja })
		Ui.esquinas(f, 20)
		Ui.borde(f, C.tinta, 2.5)
		Ui.texto({ Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -16, 1, -12), Text = nombre, TextWrapped = true, TextColor3 = C.texto, ZIndex = 126, Parent = f })
		if cerrada then
			local candado = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0, 0), Size = UDim2.fromOffset(26, 22), BackgroundColor3 = Color3.fromRGB(80, 70, 65), BorderSizePixel = 0, ZIndex = 127, Parent = f })
			Ui.esquinas(candado, 4)
			Ui.borde(candado, C.tinta, 2)
			local arco = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, 2), Size = UDim2.fromOffset(16, 14), BackgroundTransparency = 1, ZIndex = 127, Parent = candado })
			Ui.esquinas(arco, 8)
			Ui.borde(arco, Color3.fromRGB(80, 70, 65), 3)
		end
	end
	local llaves = estado and estado.llaves or {}
	for _, z in ZONAS do
		zona(z.nombre, z.mx, z.my, z.color, z.llave ~= nil and not llaves[z.llave])
	end
	for _, c in CALLES do
		zona(c.nombre, c.mx, c.my, c.color, false)
	end
	-- sitios importantes
	for _, s in SITIOS do
		local fondo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(s.mx, s.my), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(250, 244, 230), BorderSizePixel = 0, ZIndex = 128, Parent = hoja })
		Ui.esquinas(fondo, 15)
		Ui.borde(fondo, C.tinta, 2)
		Ui.icono(s.icono, fondo, UDim2.fromOffset(4, 4), UDim2.fromOffset(22, 22), 129)
		Ui.texto({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 2), Size = UDim2.fromOffset(110, 18), Text = s.nombre, TextColor3 = C.tinta, Contorno = false, ZIndex = 129, Parent = fondo })
	end
	-- paraderos que hay ahora mismo
	local mundo = workspace:FindFirstChild("MundoVael")
	if mundo then
		for _, m in mundo:GetChildren() do
			if m:IsA("Model") and string.sub(m.Name, 1, 9) == "Paradero_" then
				local punto = m:FindFirstChild("Punto", true)
				if punto and punto:IsA("BasePart") then
					local x, y = enMapa(punto.Position)
					Ui.texto({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromOffset(x, y - 26), Size = UDim2.fromOffset(30, 34), Text = "!", TextColor3 = Color3.fromRGB(230, 90, 70), ZIndex = 130, Parent = hoja })
				end
			end
		end
	end
	-- objetivo
	local texto, objetivoX = Mapa.objetivo(estado)
	if objetivoX then
		local ox, oy = enMapa(Vector3.new(objetivoX, 0, 0))
		local e = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(ox + 46, oy - 34), Size = UDim2.fromOffset(34, 34), BackgroundTransparency = 1, ZIndex = 131, Parent = hoja })
		Ui.icono("estrella", e, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 131)
	end
	-- tú
	local ch = Players.LocalPlayer.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart")
	if raiz and raiz:IsA("BasePart") then
		local x, y = enMapa(raiz.Position)
		local yo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y - 40), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(200, 75, 65), BorderSizePixel = 0, ZIndex = 132, Parent = hoja })
		Ui.esquinas(yo, 15)
		Ui.borde(yo, C.tinta, 3)
		Ui.texto({ Size = UDim2.fromScale(1, 1), Text = "Tú", TextColor3 = Color3.new(1, 1, 1), ZIndex = 133, Parent = yo })
	end
	-- pie: objetivo y leyenda
	Ui.texto({ Position = UDim2.fromOffset(40, 512), Size = UDim2.new(1, -80, 0, 30), Text = Ui.t("Misión") .. ": " .. Ui.t(texto), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 121, Parent = p })
	Ui.texto({ Position = UDim2.fromOffset(40, 546), Size = UDim2.new(1, -80, 0, 22), Text = "Candado: camino cerrado · Estrella: misión · !: algo ha aparecido", TextColor3 = C.suave, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 121, Parent = p })
end

local _ = Datos
return Mapa
