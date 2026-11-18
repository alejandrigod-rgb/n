--!strict
-- Sonido de Crónicas de Vael: música que cambia según dónde estés (ciudad, aventura, combate, jefe) con fundido,
-- y efectos sacados de un único archivo (vael-efectos.ogg) por tramos. Los ids se ponen en src/shared/Sonidos.luau.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Sonidos = require(ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Sonidos")) :: any

local Audio = {}
Audio.volMusica = 0.5
Audio.volEfectos = 0.8
Audio.forzada = nil :: string? -- "combate" o "jefe" mientras dura una pelea

local grupoMusica = Instance.new("SoundGroup")
grupoMusica.Name = "VaelMusica"
grupoMusica.Volume = Audio.volMusica
grupoMusica.Parent = SoundService
local grupoEfectos = Instance.new("SoundGroup")
grupoEfectos.Name = "VaelEfectos"
grupoEfectos.Volume = Audio.volEfectos
grupoEfectos.Parent = SoundService

local function hay(id: string?): boolean
	return id ~= nil and id ~= "" and id ~= "rbxassetid://"
end

-- ===================== MÚSICA =====================
local pistas: { [string]: Sound } = {}
for _, nombre in { "ciudad", "aventura", "combate", "jefe", "aldea", "pantano", "bosque", "ruinas", "picos", "callejon", "taberna", "bodegas" } do
	local id = Sonidos.IDS[nombre]
	if hay(id) then
		local s = Instance.new("Sound")
		s.Name = "Musica_" .. nombre
		s.SoundId = id
		s.Looped = true
		s.Volume = 0
		s.SoundGroup = grupoMusica
		s.Parent = SoundService
		pistas[nombre] = s
	end
end
local actual: string? = nil

-- si la canción de una zona aún no está subida, suena otra con distinto tempo (para que al menos cambie)
local RESERVA: { [string]: { any } } = {
	aldea = { "ciudad", 0.9 }, pantano = { "aventura", 0.82 }, bosque = { "aventura", 0.92 }, ruinas = { "jefe", 0.85 },
	picos = { "aventura", 1.08 }, callejon = { "ciudad", 0.8 }, taberna = { "ciudad", 1.15 }, bodegas = { "combate", 0.92 },
}

function Audio.musica(nombre: string?)
	if nombre == actual then
		return
	end
	actual = nombre
	local pista, velocidad = nombre and pistas[nombre], 1
	if nombre and not pista and RESERVA[nombre] then
		pista, velocidad = pistas[RESERVA[nombre][1]], RESERVA[nombre][2]
	end
	for _, s in pistas do
		if s == pista then
			if not s.IsPlaying then
				s.TimePosition = 0
				s:Play()
			end
			TweenService:Create(s, TweenInfo.new(1.2), { Volume = 0.6, PlaybackSpeed = velocidad }):Play()
		else
			local t = TweenService:Create(s, TweenInfo.new(1.2), { Volume = 0 })
			t:Play()
			t.Completed:Connect(function()
				if s ~= pista and s.Volume < 0.01 then
					s:Stop()
				end
			end)
		end
	end
end

function Audio.volumen(musica: number?, efectos: number?)
	if musica then
		Audio.volMusica = musica
		grupoMusica.Volume = musica
	end
	if efectos then
		Audio.volEfectos = efectos
		grupoEfectos.Volume = efectos
	end
end

-- ===================== EFECTOS =====================
local plantilla: Sound? = nil
if hay(Sonidos.IDS.efectos) then
	local s = Instance.new("Sound")
	s.Name = "PlantillaEfectos"
	s.SoundId = Sonidos.IDS.efectos
	s.SoundGroup = grupoEfectos
	s.Parent = SoundService
	plantilla = s
	-- que esté cargado antes de saltar a un tramo (si no, sonaría desde el principio)
	task.spawn(function()
		pcall(function()
			game:GetService("ContentProvider"):PreloadAsync({ s })
		end)
	end)
end

-- sonidos que sí valen en la pantalla de inicio (pasar por encima y pulsar botones)
local DE_MENU = { click = true, hover = true, pop = true, mejora = true }

--- Suena un efecto por su nombre (ver Sonidos.Efectos). tono cambia la velocidad (1 = normal).
function Audio.sfx(nombre: string, volumen: number?, tono: number?)
	-- en la pantalla de inicio solo suenan la música y los botones (nada de pitiditos, pasos ni charlas)
	if Players.LocalPlayer:GetAttribute("EnMenu") == true and not DE_MENU[nombre] then
		return
	end
	local tramo = Sonidos.Efectos[nombre]
	if not plantilla or not tramo or not (plantilla :: Sound).IsLoaded then
		return
	end
	local s = (plantilla :: Sound):Clone()
	s.Volume = volumen or 0.8
	s.PlaybackSpeed = tono or 1
	s.TimePosition = tramo[1]
	s.Parent = SoundService
	s:Play()
	task.delay(tramo[2] / (tono or 1) + 0.05, function()
		s:Stop()
		s:Destroy()
	end)
end

local pie = false
--- Paso de muñeco de cartón (alterna dos sonidos y varía un poco el tono para que no canse).
function Audio.paso()
	pie = not pie
	Audio.sfx(pie and "paso" or "paso2", 0.45, 0.92 + math.random() * 0.16)
end

--- Voz de bocadillo: pitiditos con un tono propio por personaje (como un muñeco que "habla").
function Audio.hablar(semilla: number, letras: number)
	local r = Random.new(semilla)
	local base = 0.8 + r:NextNumber() * 0.7
	task.spawn(function()
		for _ = 1, math.clamp(math.floor(letras / 3), 2, 14) do
			Audio.sfx("blip", 0.35, base + (math.random() - 0.5) * 0.25)
			task.wait(0.07)
		end
	end)
end

-- ===================== MINI FANFARRIAS =====================
-- Se hacen encadenando los efectos que ya hay (con otro tono), así no hace falta subir audio nuevo.
local JINGLES: { [string]: { { any } } } = {
	-- { cuándo (s), efecto, volumen, tono }
	victoria = { { 0, "victoria", 0.9, 1 }, { 0.35, "moneda", 0.6, 1.2 }, { 0.6, "brillo", 0.6, 1.1 } },
	jefeVencido = { { 0, "explosion", 0.8, 0.8 }, { 0.3, "victoria", 1, 1 }, { 0.75, "nivel", 0.9, 1 }, { 1.15, "brillo", 0.7, 1.3 }, { 1.45, "mejora", 0.9, 1.15 }, { 1.8, "moneda", 0.7, 1.4 } },
	jefe = { { 0, "explosion", 0.8, 0.6 }, { 0.45, "critico", 0.8, 0.75 }, { 0.9, "rayo", 0.7, 0.7 } },
	zona = { { 0, "aviso", 0.6, 1 }, { 0.22, "brillo", 0.6, 1.2 }, { 0.5, "mejora", 0.7, 1 } },
	zonaNueva = { { 0, "aviso", 0.7, 1 }, { 0.2, "brillo", 0.7, 1.25 }, { 0.45, "mejora", 0.8, 1 }, { 0.8, "nivel", 0.7, 1.1 } },
	encargo = { { 0, "cofre", 0.8, 1.1 }, { 0.3, "moneda", 0.7, 1.2 }, { 0.55, "mejora", 0.8, 1.1 } },
}
function Audio.jingle(nombre: string)
	local j = JINGLES[nombre]
	if not j then
		return
	end
	for _, nota in j do
		task.delay(nota[1], function()
			Audio.sfx(nota[2], nota[3], nota[4])
		end)
	end
end

-- ===================== MÚSICA SEGÚN EL SITIO =====================
local jugador = Players.LocalPlayer
local ultimoCambio = 0
RunService.Heartbeat:Connect(function()
	if os.clock() - ultimoCambio < 0.5 then
		return
	end
	ultimoCambio = os.clock()
	if Audio.forzada then
		Audio.musica(Audio.forzada)
		return
	end
	local ch = jugador.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not raiz then
		Audio.musica("ciudad")
		return
	end
	-- cada sitio con su canción
	local p = raiz.Position
	if p.Y > 850 then
		Audio.musica("bodegas")
	elseif p.Y > 650 then
		Audio.musica("callejon")
	elseif p.Y > 450 then
		Audio.musica("ciudad") -- Calle del Mercado
	elseif p.Y > 300 then
		Audio.musica("aldea") -- la posada, tranquila
	elseif p.Y > 150 then
		Audio.musica("taberna")
	elseif p.X < -205 then
		Audio.musica("aldea")
	elseif p.X < 45 then
		Audio.musica("ciudad")
	elseif p.X < 163 then
		Audio.musica("aventura") -- la Pradera
	elseif p.X < 263 then
		Audio.musica("pantano")
	elseif p.X < 363 then
		Audio.musica("bosque")
	elseif p.X < 463 then
		Audio.musica("ruinas")
	elseif p.X < 606 then
		Audio.musica("jefe") -- la Cueva del Rey Hongo
	elseif p.X < 712 then
		Audio.musica("picos")
	else
		Audio.musica("jefe") -- la Cumbre del Yeti
	end
end)

-- si no hay efectos subidos, se dejan los pasos de Roblox; si los hay, se silencian (usamos los nuestros)
local function silenciarPasosRoblox(ch: Model)
	if not plantilla then
		return
	end
	local raiz = ch:WaitForChild("HumanoidRootPart", 10)
	if not raiz then
		return
	end
	task.wait(1)
	for _, s in raiz:GetChildren() do
		if s:IsA("Sound") and (s.Name == "Running" or s.Name == "Jumping" or s.Name == "Landing") then
			s.Volume = 0
		end
	end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.StateChanged:Connect(function(_, nuevo)
			if nuevo == Enum.HumanoidStateType.Jumping then
				Audio.sfx("salto", 0.6, 0.95 + math.random() * 0.1)
			end
		end)
	end
end
jugador.CharacterAdded:Connect(silenciarPasosRoblox)
if jugador.Character then
	task.spawn(silenciarPasosRoblox, jugador.Character)
end

return Audio
