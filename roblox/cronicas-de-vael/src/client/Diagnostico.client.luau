--!strict
-- Muestra en pantalla la versión del juego y, si algo falla, el error (del cliente y, en Studio, también del
-- servidor). Así basta una captura para saber qué pasa, sin abrir la ventana de Salida.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")

local VERSION = "v1.2 · 17-nov"

local jugador = Players.LocalPlayer

-- Limpieza: si alguien descomprime el ZIP nuevo ENCIMA de la carpeta vieja, quedan scripts antiguos
-- (por ejemplo, el minimapa viejo "Mapa.client.luau") que chocan con los módulos nuevos. Aquí se apagan.
local VIEJOS = { Mapa = true }
for _, h in script.Parent:GetChildren() do
	if VIEJOS[h.Name] and h:IsA("LocalScript") then
		h.Disabled = true
		h:Destroy()
	end
end
task.spawn(function()
	local pg = jugador:WaitForChild("PlayerGui")
	for _ = 1, 30 do
		local viejo = pg:FindFirstChild("VaelMapa")
		if viejo then viejo:Destroy() end
		task.wait(0.5)
	end
end)
local gui = Instance.new("ScreenGui")
gui.Name = "VaelDiagnostico"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1000
gui.Parent = jugador:WaitForChild("PlayerGui")

local version = Instance.new("TextLabel")
version.AnchorPoint = Vector2.new(1, 1)
version.Position = UDim2.new(1, -8, 1, -6)
version.Size = UDim2.fromOffset(220, 18)
version.BackgroundTransparency = 1
version.Font = Enum.Font.GothamBold
version.TextSize = 13
version.TextXAlignment = Enum.TextXAlignment.Right
version.TextColor3 = Color3.new(1, 1, 1)
version.TextStrokeTransparency = 0.4
version.Text = "Crónicas de Vael " .. VERSION
version.Parent = gui

local caja = Instance.new("Frame")
caja.AnchorPoint = Vector2.new(0, 1)
caja.Position = UDim2.new(0, 8, 1, -28)
caja.Size = UDim2.fromOffset(620, 0)
caja.AutomaticSize = Enum.AutomaticSize.Y
caja.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
caja.BackgroundTransparency = 0.15
caja.BorderSizePixel = 0
caja.Visible = false
caja.Parent = gui
local lista = Instance.new("UIListLayout")
lista.Parent = caja
local relleno = Instance.new("UIPadding")
relleno.PaddingLeft = UDim.new(0, 8)
relleno.PaddingRight = UDim.new(0, 8)
relleno.PaddingTop = UDim.new(0, 6)
relleno.PaddingBottom = UDim.new(0, 6)
relleno.Parent = caja

local vistos: { [string]: boolean } = {}
local n = 0
local function mostrar(origen: string, texto: string)
	local clave = string.sub(texto, 1, 200)
	if vistos[clave] or n >= 6 then
		return
	end
	vistos[clave] = true
	n += 1
	caja.Visible = true
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0, 0)
	t.AutomaticSize = Enum.AutomaticSize.Y
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.Code
	t.TextSize = 13
	t.TextWrapped = true
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextColor3 = Color3.fromRGB(255, 220, 210)
	t.Text = "[" .. origen .. "] " .. string.sub(texto, 1, 400)
	t.Parent = caja
end

ScriptContext.Error:Connect(function(mensaje, traza, _script)
	mostrar("cliente", mensaje .. "\n" .. string.sub(traza or "", 1, 200))
end)

-- también los avisos (por ejemplo, un WaitForChild que se queda esperando para siempre)
game:GetService("LogService").MessageOut:Connect(function(mensaje, tipo)
	if tipo == Enum.MessageType.MessageWarning and (string.find(mensaje, "Infinite yield", 1, true) or string.find(mensaje, "Vael", 1, true) or string.find(mensaje, "Menú", 1, true)) then
		mostrar("aviso", mensaje)
	end
end)

-- ¿han arrancado los scripts del juego? (cada uno pone su marca al terminar de cargar)
task.delay(10, function()
	-- si un script no ha terminado, se ve en qué paso se quedó
	local function marca(nombre: string): string
		if jugador:GetAttribute("Cargado" .. nombre) then
			return nombre .. " ✓"
		end
		return nombre .. " ✗ (" .. tostring(jugador:GetAttribute("Paso" .. nombre) or "sin empezar") .. ")"
	end
	version.Size = UDim2.fromOffset(760, 18)
	version.Text ..= "  ·  " .. marca("Principal") .. " · " .. marca("Menu")
end)

-- en Studio, el servidor reenvía sus errores (ver Principal.server)
task.spawn(function()
	local remotos = ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Remotos", 30)
	local r = remotos and remotos:WaitForChild("ErrorServidor", 30)
	if r and r:IsA("RemoteEvent") then
		r.OnClientEvent:Connect(function(texto: string)
			mostrar("servidor", texto)
		end)
	end
end)

if RunService:IsStudio() then
	version.Text ..= " · Studio"
end
