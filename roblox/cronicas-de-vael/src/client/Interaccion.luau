--!strict
-- Indicador de interacción propio (sustituye al aviso gris de Roblox).
-- Los avisos del servidor (ProximityPrompt) llevan Style = Custom: Roblox sigue detectando la distancia y la tecla E,
-- pero no dibuja nada; aquí se dibuja una etiqueta de cartulina con la tecla E y la acción («Hablar», «Abrir»…).
-- Con el ratón o el dedo también se puede pulsar la etiqueta.

local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Ui = require(script.Parent:WaitForChild("Ui"))
local C = Ui.Colores

local Interaccion = {}

local activos: { [ProximityPrompt]: BillboardGui } = {}

local function crear(prompt: ProximityPrompt, tipoEntrada: Enum.ProximityPromptInputType)
	local adorno = prompt.Parent
	if not adorno or not adorno:IsA("BasePart") then
		return
	end
	local jugador = Players.LocalPlayer
	local b = Instance.new("BillboardGui")
	b.Name = "AvisoVael"
	b.Size = UDim2.fromOffset(240, 64)
	b.StudsOffset = Vector3.new(0, 3.6, 0)
	b.AlwaysOnTop = true
	b.LightInfluence = 0
	b.Active = true
	b.Adornee = adorno
	b.ResetOnSpawn = false
	-- tarjeta de cartón con la tecla
	local tarjeta = Ui.crear("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 0, 0, 48), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(236, 222, 190), Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = b })
	Ui.esquinas(tarjeta, 8)
	Ui.borde(tarjeta, C.tinta, 3)
	Ui.crear("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 12), Parent = tarjeta })
	Ui.crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), Parent = tarjeta })
	local tecla = Ui.crear("Frame", { Size = UDim2.fromOffset(36, 36), BackgroundColor3 = Color3.fromRGB(200, 75, 65), BorderSizePixel = 0, LayoutOrder = 1, Parent = tarjeta })
	Ui.esquinas(tecla, 6)
	Ui.borde(tecla, C.tinta, 2)
	local letra = tipoEntrada == Enum.ProximityPromptInputType.Touch and "Toca" or (tipoEntrada == Enum.ProximityPromptInputType.Gamepad and "X" or "E")
	local textoTecla = Ui.crear("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = letra, Font = Ui.Fuente, TextScaled = true, TextColor3 = Color3.fromRGB(250, 240, 220), Parent = tecla })
	Ui.crear("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), Parent = textoTecla })
	local textos = Ui.crear("Frame", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = 2, Parent = tarjeta })
	Ui.crear("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Center, Parent = textos })
	Ui.crear("TextLabel", { Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = prompt.ActionText, Font = Ui.Fuente, TextSize = 20, TextColor3 = C.tinta, LayoutOrder = 1, Parent = textos })
	if prompt.ObjectText ~= "" then
		Ui.crear("TextLabel", { Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = prompt.ObjectText, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(110, 90, 75), LayoutOrder = 2, Parent = textos })
	end
	local escala = Ui.crear("UIScale", { Scale = 0.3, Parent = tarjeta })
	TweenService:Create(escala, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	-- con ratón o dedo también se puede pulsar
	tarjeta.Activated:Connect(function()
		prompt:InputHoldBegin()
		task.wait(0.05)
		prompt:InputHoldEnd()
	end)
	-- al pulsar la E, la tecla se hunde
	prompt.Triggered:Connect(function()
		if b.Parent then
			TweenService:Create(escala, TweenInfo.new(0.08), { Scale = 0.9 }):Play()
			task.delay(0.1, function()
				TweenService:Create(escala, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			end)
		end
	end)
	b.Parent = jugador:WaitForChild("PlayerGui")
	activos[prompt] = b
end

local function quitar(prompt: ProximityPrompt)
	local b = activos[prompt]
	activos[prompt] = nil
	if b then
		local tarjeta = b:FindFirstChildWhichIsA("GuiObject")
		local escala = tarjeta and tarjeta:FindFirstChildOfClass("UIScale")
		if escala then
			local t = TweenService:Create(escala, TweenInfo.new(0.15), { Scale = 0 })
			t:Play()
			t.Completed:Connect(function()
				b:Destroy()
			end)
		else
			b:Destroy()
		end
	end
end

function Interaccion.iniciar()
	ProximityPromptService.PromptShown:Connect(function(prompt, tipoEntrada)
		if prompt.Style == Enum.ProximityPromptStyle.Custom then
			crear(prompt, tipoEntrada)
		end
	end)
	ProximityPromptService.PromptHidden:Connect(quitar)
end

--- Oculta los avisos mientras hay un diálogo o un menú abierto.
function Interaccion.visibles(si: boolean)
	for _, b in activos do
		b.Enabled = si
	end
end

return Interaccion
