-- Monta un "Roblox" falso con los scripts del juego (lo incluye construir.py junto con rt.luau y FUENTES).
local RT = RT_MODULO
local E = RT.entorno
local Instance = RT.Instance
local game = RT.game
local task = E.task

local JSON = {}
local cuentaJSON = 0
local function copia(t)
	if type(t) ~= "table" then return t end
	local r = {}
	for k, v in t do r[k] = copia(v) end
	return r
end

-- ---------- métodos especiales de servicios y clases ----------
local esp = RT.especiales
esp.TweenService = {
	Create = function(_, obj, info, props)
		assert(obj and rawget(obj, "__inst"), "TweenService:Create sin instancia")
		local tw = Instance.new("Tween")
		tw.__especial = true
		local completado = tw.Completed
		rawset(tw, "_jugar", function()
			for k, v in props do obj[k] = v end
			task.delay(info and info.Time or 0.1, function() completado:Fire() end)
		end)
		return tw
	end,
}
esp.Tween = {
	Play = function(self) self._jugar() end,
	Cancel = function() end,
	Pause = function() end,
}
esp.RunService = {
	BindToRenderStep = function(_, nombre, _p, f) RT.renderPasos[nombre] = f end,
	UnbindFromRenderStep = function(_, nombre) RT.renderPasos[nombre] = nil end,
	IsStudio = function() return true end,
	IsClient = function() return RT.esCliente end,
	IsServer = function() return not RT.esCliente end,
	IsRunning = function() return true end,
}
esp.UserInputService = {
	GetMouseLocation = function() return E.Vector2.new(400, 300) end,
	IsKeyDown = function() return false end,
	IsMouseButtonPressed = function() return false end,
	GetFocusedTextBox = function() return nil end,
	TouchEnabled = false,
	KeyboardEnabled = true,
}
esp.HttpService = {
	JSONEncode = function(_, t)
		cuentaJSON += 1
		local clave = "{json#" .. cuentaJSON .. "}"
		JSON[clave] = copia(t)
		return clave
	end,
	JSONDecode = function(_, s)
		local t = JSON[s]
		if t == nil then error("JSONDecode: texto no válido") end
		return copia(t)
	end,
	GenerateGUID = function() return "guid" end,
}
esp.ContentProvider = { PreloadAsync = function() end }
esp.TextService = {
	FilterStringAsync = function(_, texto)
		return { GetNonChatStringForBroadcastAsync = function() return texto end }
	end,
}
esp.Camera = {
	WorldToViewportPoint = function() return E.Vector3.new(400, 300, 10), true end,
	WorldToScreenPoint = function() return E.Vector3.new(400, 300, 10), true end,
	ViewportPointToRay = function() return { Origin = E.Vector3.new(), Direction = E.Vector3.new(0, 0, -1) } end,
	ScreenPointToRay = function() return { Origin = E.Vector3.new(), Direction = E.Vector3.new(0, 0, -1) } end,
	ViewportSize = E.Vector2.new(1280, 720),
}
esp.Workspace = {
	Raycast = function() return nil end,
}
esp.DataStoreService = {
	GetDataStore = function()
		local ds = {}
		function ds:GetAsync() return nil end
		function ds:SetAsync() end
		function ds:UpdateAsync() end
		return ds
	end,
}
esp.Player = {
	RequestStreamAroundAsync = function() end,
	LoadCharacter = function() end,
	Kick = function() end,
}
esp.Players = {
	GetPlayers = function(self) local t = {} for _, h in self:GetChildren() do if h:IsA("Player") then table.insert(t, h) end end return t end,
	GetPlayerByUserId = function(self, id) for _, h in self:GetChildren() do if h:IsA("Player") and h.UserId == id then return h end end return nil end,
	GetPlayerFromCharacter = function() return nil end,
}
esp.LocalizationService = {
	GetTranslatorForLocaleAsync = function(_, locale)
		local tr = {}
		function tr:Translate(_ctx, texto) return "[" .. locale .. "]" .. texto end
		function tr:FormatByKey(clave) return "[" .. locale .. "]" .. clave end
		return tr
	end,
	RobloxLocaleId = "es-es",
}
esp.ProximityPrompt = {
	InputHoldBegin = function() end,
	InputHoldEnd = function() end,
}
esp.Sound = { Play = function() end, Stop = function() end, Pause = function() end, Resume = function() end }

-- ---------- require ----------
local cache = {}
local function cargar(scriptInst, fuente)
	local f, e = loadstring(fuente, "=" .. scriptInst:GetFullName())
	if not f then error("Error de sintaxis en " .. scriptInst:GetFullName() .. ": " .. tostring(e)) end
	local env = setmetatable({ script = scriptInst }, { __index = E })
	env.require = function(m)
		assert(m and rawget(m, "__inst"), "require: no es una instancia (" .. tostring(m) .. ")")
		if cache[m] ~= nil then return cache[m] end
		local fu = rawget(m, "__fuente")
		if not fu then error("require: " .. m:GetFullName() .. " no tiene código") end
		local r = cargar(m, fu)()
		cache[m] = r
		return r
	end
	setfenv(f, env)
	return f
end
E.require = function(m)
	if cache[m] ~= nil then return cache[m] end
	local r = cargar(m, rawget(m, "__fuente"))()
	cache[m] = r
	return r
end

local function modulo(nombre, padre, fuente, clase)
	local m = Instance.new(clase or "ModuleScript")
	m.Name = nombre
	rawset(m, "__fuente", fuente)
	m.Parent = padre
	return m
end

local function ejecutar(scriptInst)
	task.spawn(function()
		local ok, e = xpcall(cargar(scriptInst, rawget(scriptInst, "__fuente")), debug.traceback)
		if not ok then table.insert(RT.errores, "[" .. scriptInst:GetFullName() .. "] " .. tostring(e)) end
	end)
end

local B = {}
B.RT = RT
B.E = E
B.modulo = modulo
B.ejecutar = ejecutar
B.copia = copia
return B
