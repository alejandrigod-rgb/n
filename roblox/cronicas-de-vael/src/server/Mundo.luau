--!strict
-- Construye el mundo de Vael si el lugar está vacío (así se puede probar con un Baseplate nuevo).
-- Si ya existe una carpeta "MundoVael" en Workspace (por ejemplo, porque lo decoraste a mano), no toca nada:
-- solo busca dentro las partes con el atributo "Zona" para usarlas como zonas de combate.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Datos = require(ReplicatedStorage.Vael.Datos)

local Mundo = {}

-- posición de cada zona (centro del círculo de combate)
local POSICIONES: { [string]: Vector3 } = {
	pradera = Vector3.new(0, 0, -130),
	bosque = Vector3.new(-150, 0, -170),
	ruinas = Vector3.new(150, 0, -170),
	cueva = Vector3.new(0, 0, -300),
}

local raiz: Folder

local function parte(props: { [string]: any }): BasePart
	local tipo = props.Clase or "Part"
	local p = Instance.new(tipo) :: BasePart
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		if k ~= "Clase" and k ~= "Padre" then
			(p :: any)[k] = v
		end
	end
	p.Parent = props.Padre or raiz
	return p
end

local function cartel(adorno: BasePart, texto: string, sub: string, color: Color3)
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.fromOffset(260, 80)
	b.StudsOffset = Vector3.new(0, 4, 0)
	b.AlwaysOnTop = false
	b.MaxDistance = 220
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0.6, 0)
	t.BackgroundTransparency = 1
	t.Text = texto
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.TextStrokeColor3 = color
	t.Parent = b
	local s = Instance.new("TextLabel")
	s.Size = UDim2.new(1, 0, 0.4, 0)
	s.Position = UDim2.fromScale(0, 0.6)
	s.BackgroundTransparency = 1
	s.Text = sub
	s.Font = Enum.Font.GothamBold
	s.TextScaled = true
	s.TextColor3 = Color3.fromRGB(255, 235, 150)
	s.TextStrokeTransparency = 0.3
	s.Parent = b
	b.Parent = adorno
end

local function arbol(pos: Vector3, escala: number, colorCopa: Color3?)
	parte({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(9, 1.6, 1.6) * escala, CFrame = CFrame.new(pos + Vector3.new(0, 4.5 * escala, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(110, 75, 45), Material = Enum.Material.Wood })
	parte({ Clase = "Part", Shape = Enum.PartType.Ball, Size = Vector3.new(8, 8, 8) * escala, Position = pos + Vector3.new(0, 10 * escala, 0), Color = colorCopa or Color3.fromRGB(80, 150, 70), Material = Enum.Material.Grass })
end

local function casa(pos: Vector3, giro: number, color: Color3)
	local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(giro), 0)
	parte({ Size = Vector3.new(16, 10, 14), CFrame = cf * CFrame.new(0, 5, 0), Color = color, Material = Enum.Material.Plaster })
	parte({ Clase = "WedgePart", Size = Vector3.new(16, 6, 7.5), CFrame = cf * CFrame.new(0, 13, -3.6), Color = Color3.fromRGB(170, 70, 55), Material = Enum.Material.Slate })
	parte({ Clase = "WedgePart", Size = Vector3.new(16, 6, 7.5), CFrame = cf * CFrame.new(0, 13, 3.6) * CFrame.Angles(0, math.rad(180), 0), Color = Color3.fromRGB(170, 70, 55), Material = Enum.Material.Slate })
	parte({ Size = Vector3.new(3.5, 6, 0.4), CFrame = cf * CFrame.new(0, 3, -7.1), Color = Color3.fromRGB(110, 70, 40), Material = Enum.Material.Wood })
	parte({ Size = Vector3.new(3, 3, 0.4), CFrame = cf * CFrame.new(-5, 6, -7.1), Color = Color3.fromRGB(255, 225, 140), Material = Enum.Material.Neon })
	parte({ Size = Vector3.new(3, 3, 0.4), CFrame = cf * CFrame.new(5, 6, -7.1), Color = Color3.fromRGB(255, 225, 140), Material = Enum.Material.Neon })
end

local function camino(desde: Vector3, hasta: Vector3)
	local medio = (desde + hasta) / 2
	local largo = (hasta - desde).Magnitude
	parte({ Size = Vector3.new(10, 0.3, largo), CFrame = CFrame.lookAt(medio + Vector3.new(0, 0.15, 0), hasta + Vector3.new(0, 0.15, 0)), Color = Color3.fromRGB(200, 175, 125), Material = Enum.Material.Ground, CanCollide = false })
end

local function decorarZona(id: string, centro: Vector3, rng: Random)
	if id == "pradera" then
		for _ = 1, 30 do
			local p = centro + Vector3.new(rng:NextNumber(-45, 45), 0.4, rng:NextNumber(-45, 45))
			if (p - centro).Magnitude > 20 then
				parte({ Shape = Enum.PartType.Ball, Size = Vector3.new(1, 1, 1), Position = p, Color = ({ Color3.fromRGB(255, 220, 90), Color3.fromRGB(240, 120, 160), Color3.new(1, 1, 1) })[rng:NextInteger(1, 3)], Material = Enum.Material.SmoothPlastic, CanCollide = false })
			end
		end
		for _ = 1, 4 do
			arbol(centro + Vector3.new(rng:NextNumber(-50, 50), 0, rng:NextNumber(-55, -30)), rng:NextNumber(0.8, 1.2))
		end
	elseif id == "bosque" then
		for _ = 1, 26 do
			local p = centro + Vector3.new(rng:NextNumber(-60, 60), 0, rng:NextNumber(-60, 60))
			if (p - centro).Magnitude > 24 then
				arbol(p, rng:NextNumber(1, 1.8), Color3.fromRGB(45, 110, 60))
			end
		end
	elseif id == "ruinas" then
		for k = 0, 9 do
			local a = k / 10 * math.pi * 2
			local p = centro + Vector3.new(math.cos(a) * 28, 0, math.sin(a) * 28)
			local alto = rng:NextNumber(4, 16)
			parte({ Size = Vector3.new(4, alto, 4), Position = p + Vector3.new(0, alto / 2, 0), Color = Color3.fromRGB(165, 155, 145), Material = Enum.Material.Cobblestone, Orientation = Vector3.new(0, 0, rng:NextNumber(-8, 8)) })
		end
		parte({ Size = Vector3.new(30, 2, 4), Position = centro + Vector3.new(0, 17, -28), Color = Color3.fromRGB(150, 140, 130), Material = Enum.Material.Cobblestone })
	elseif id == "cueva" then
		for k = 0, 14 do
			local a = math.rad(-150 + k * 20)
			local p = centro + Vector3.new(math.cos(a) * 34, 0, math.sin(a) * 34)
			parte({ Size = Vector3.new(10, rng:NextNumber(10, 24), 10), Position = p + Vector3.new(0, 6, 0), Color = Color3.fromRGB(85, 75, 80), Material = Enum.Material.Rock, Orientation = Vector3.new(rng:NextNumber(-10, 10), rng:NextNumber(0, 90), 0) })
		end
		for _ = 1, 8 do
			local p = centro + Vector3.new(rng:NextNumber(-30, 30), 0, rng:NextNumber(-30, 30))
			if (p - centro).Magnitude > 18 then
				parte({ Size = Vector3.new(0.8, 3, 0.8), Position = p + Vector3.new(0, 1.5, 0), Color = Color3.fromRGB(240, 230, 210), Material = Enum.Material.SmoothPlastic })
				parte({ Shape = Enum.PartType.Ball, Size = Vector3.new(3.5, 1.6, 3.5), Position = p + Vector3.new(0, 3.2, 0), Color = Color3.fromRGB(210, 80, 70), Material = Enum.Material.SmoothPlastic })
			end
		end
	end
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
	raiz.Parent = workspace
	local rng = Random.new(2026)

	-- suelo (si no hay Baseplate)
	if not workspace:FindFirstChild("Baseplate") then
		parte({ Name = "Suelo", Size = Vector3.new(900, 2, 900), Position = Vector3.new(0, -1, -150), Color = Color3.fromRGB(110, 170, 90), Material = Enum.Material.Grass })
	end
	-- punto de aparición
	local sp = Instance.new("SpawnLocation")
	sp.Anchored = true
	sp.Size = Vector3.new(8, 1, 8)
	sp.Position = Vector3.new(0, 0.5, 15)
	sp.Color = Color3.fromRGB(240, 200, 80)
	sp.Material = Enum.Material.Marble
	sp.Parent = raiz

	-- aldea
	local colores = { Color3.fromRGB(240, 225, 190), Color3.fromRGB(200, 220, 235), Color3.fromRGB(235, 200, 190), Color3.fromRGB(215, 235, 200) }
	casa(Vector3.new(-40, 0, 35), 30, colores[1])
	casa(Vector3.new(40, 0, 35), -30, colores[2])
	casa(Vector3.new(-45, 0, -15), 90, colores[3])
	casa(Vector3.new(45, 0, -15), -90, colores[4])
	for _ = 1, 10 do
		arbol(Vector3.new(rng:NextNumber(-80, 80), 0, rng:NextNumber(50, 90)), rng:NextNumber(0.9, 1.4))
	end

	-- fuente curativa
	local fuente = parte({ Name = "Fuente", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 16, 16), CFrame = CFrame.new(0, 1, -10) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(170, 170, 180), Material = Enum.Material.Marble })
	local agua = parte({ Name = "AguaFuente", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 13, 13), CFrame = CFrame.new(0, 2.1, -10) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(90, 190, 230), Material = Enum.Material.Glass, Transparency = 0.2, CanCollide = false })
	agua:SetAttribute("Fuente", true)
	cartel(fuente, "Fuente de Vael", "Cura vida y maná", Color3.fromRGB(60, 140, 200))

	-- mercader
	local puesto = parte({ Name = "Mercader", Size = Vector3.new(8, 4, 4), Position = Vector3.new(22, 2, 0), Color = Color3.fromRGB(150, 100, 60), Material = Enum.Material.Wood })
	parte({ Size = Vector3.new(9, 0.5, 5), Position = Vector3.new(22, 7, 0), Color = Color3.fromRGB(214, 69, 65), Material = Enum.Material.Fabric })
	puesto:SetAttribute("Mercader", true)
	cartel(puesto, "Mercader", "Pociones y éteres", Color3.fromRGB(200, 120, 40))

	-- zonas de combate
	for _, z in Datos.Zonas do
		local centro = POSICIONES[z.id]
		local disco = parte({ Name = "Zona_" .. z.id, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 30, 30), CFrame = CFrame.new(centro + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = z.color, Material = Enum.Material.Neon, Transparency = 0.55, CanCollide = false })
		disco:SetAttribute("Zona", z.id)
		local poste = parte({ Size = Vector3.new(1, 8, 1), Position = centro + Vector3.new(0, 4, 18), Color = Color3.fromRGB(110, 75, 45), Material = Enum.Material.Wood })
		cartel(poste, z.nombre, "Nivel recomendado " .. z.nivel, z.color)
		camino(Vector3.new(0, 0, -15), centro)
		decorarZona(z.id, centro, rng)
		zonas[disco] = z
	end
	return zonas
end

return Mundo
