-- Simulador mínimo de Roblox para ejecutar los scripts del juego fuera de Studio.
-- Valida nombres de propiedades, eventos y enums contra el volcado oficial de la API.
local API = API_DATA
local RT = {}
RT.errores = {}
RT.avisos = {}
local ahora = 0

local function err(msg)
	error(msg, 3)
end

-- ===================== tipos de datos =====================
local Vector3, Vector2, Color3, UDim, UDim2, CFrame
local mt3 = {}
mt3.__index = function(v, k)
	if k == "Magnitude" then return math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z) end
	if k == "Unit" then local m = math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z); if m == 0 then return Vector3.new() end; return Vector3.new(v.X / m, v.Y / m, v.Z / m) end
	if k == "Lerp" then return function(a, b, t) return a + (b - a) * t end end
	if k == "Dot" then return function(a, b) return a.X * b.X + a.Y * b.Y + a.Z * b.Z end end
	if k == "Cross" then return function(a, b) return Vector3.new(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X) end end
	err("Vector3." .. tostring(k) .. " no existe")
end
mt3.__add = function(a, b) return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
mt3.__sub = function(a, b) return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
mt3.__mul = function(a, b)
	if type(a) == "number" then return Vector3.new(b.X * a, b.Y * a, b.Z * a) end
	if type(b) == "number" then return Vector3.new(a.X * b, a.Y * b, a.Z * b) end
	return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
mt3.__div = function(a, b) return Vector3.new(a.X / b, a.Y / b, a.Z / b) end
mt3.__unm = function(a) return Vector3.new(-a.X, -a.Y, -a.Z) end
mt3.__eq = function(a, b) return a.X == b.X and a.Y == b.Y and a.Z == b.Z end
mt3.__tostring = function(a) return string.format("%g, %g, %g", a.X, a.Y, a.Z) end
mt3.__type = "Vector3"
Vector3 = { new = function(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0, __tipo = "Vector3" }, mt3) end }
Vector3.zero = Vector3.new()
Vector3.one = Vector3.new(1, 1, 1)
Vector3.yAxis = Vector3.new(0, 1, 0)

local mt2 = {}
mt2.__index = function(v, k)
	if k == "Magnitude" then return math.sqrt(v.X * v.X + v.Y * v.Y) end
	if k == "Unit" then local m = math.sqrt(v.X * v.X + v.Y * v.Y); return Vector2.new(v.X / m, v.Y / m) end
	if k == "Lerp" then return function(a, b, t) return a + (b - a) * t end end
	err("Vector2." .. tostring(k) .. " no existe")
end
mt2.__add = function(a, b) return Vector2.new(a.X + b.X, a.Y + b.Y) end
mt2.__sub = function(a, b) return Vector2.new(a.X - b.X, a.Y - b.Y) end
mt2.__mul = function(a, b)
	if type(a) == "number" then return Vector2.new(b.X * a, b.Y * a) end
	if type(b) == "number" then return Vector2.new(a.X * b, a.Y * b) end
	return Vector2.new(a.X * b.X, a.Y * b.Y)
end
mt2.__div = function(a, b) return Vector2.new(a.X / b, a.Y / b) end
Vector2 = { new = function(x, y) return setmetatable({ X = x or 0, Y = y or 0, __tipo = "Vector2" }, mt2) end }
Vector2.zero = Vector2.new()

local mtc = {}
mtc.__index = function(c, k)
	if k == "Lerp" then return function(a, b, t) return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t) end end
	if k == "ToHSV" then return function() return 0, 0, 0 end end
	err("Color3." .. tostring(k) .. " no existe")
end
mtc.__eq = function(a, b) return a.R == b.R and a.G == b.G and a.B == b.B end
Color3 = {
	new = function(r, g, b) return setmetatable({ R = r or 0, G = g or 0, B = b or 0, __tipo = "Color3" }, mtc) end,
	fromRGB = function(r, g, b)
		assert(type(r) == "number" and type(g) == "number" and type(b) == "number", "Color3.fromRGB con argumentos no numéricos")
		return setmetatable({ R = r / 255, G = g / 255, B = b / 255, __tipo = "Color3" }, mtc)
	end,
	fromHSV = function() return Color3.new() end,
}

local mtu = { __index = function(_, k) err("UDim." .. tostring(k) .. " no existe") end }
mtu.__add = function(a, b) return UDim.new(a.Scale + b.Scale, a.Offset + b.Offset) end
UDim = { new = function(s, o) return setmetatable({ Scale = s or 0, Offset = o or 0, __tipo = "UDim" }, mtu) end }
local mtu2 = { __index = function(_, k) err("UDim2." .. tostring(k) .. " no existe") end }
mtu2.__add = function(a, b) return UDim2.new(a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset, a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset) end
mtu2.__sub = function(a, b) return UDim2.new(a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset, a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset) end
mtu2.__eq = function(a, b) return a.X.Scale == b.X.Scale and a.X.Offset == b.X.Offset and a.Y.Scale == b.Y.Scale and a.Y.Offset == b.Y.Offset end
UDim2 = {
	new = function(xs, xo, ys, yo)
		if type(xs) == "table" then return setmetatable({ X = xs, Y = xo, Width = xs, Height = xo, __tipo = "UDim2" }, mtu2) end
		for _, v in { xs or 0, xo or 0, ys or 0, yo or 0 } do assert(type(v) == "number", "UDim2.new con argumento no numérico") end
		local x, y = UDim.new(xs, xo), UDim.new(ys, yo)
		return setmetatable({ X = x, Y = y, Width = x, Height = y, __tipo = "UDim2" }, mtu2)
	end,
}
UDim2.fromScale = function(x, y) return UDim2.new(x, 0, y, 0) end
UDim2.fromOffset = function(x, y) return UDim2.new(0, x, 0, y) end

local mtcf = {}
mtcf.__index = function(c, k)
	if k == "Position" or k == "p" then return c.__p end
	if k == "X" then return c.__p.X end
	if k == "Y" then return c.__p.Y end
	if k == "Z" then return c.__p.Z end
	if k == "LookVector" then return Vector3.new(0, 0, -1) end
	if k == "RightVector" then return Vector3.new(1, 0, 0) end
	if k == "UpVector" then return Vector3.new(0, 1, 0) end
	if k == "Lerp" then return function(a, b, t) return CFrame.new(a.__p + (b.__p - a.__p) * t) end end
	if k == "Inverse" then return function(a) return CFrame.new(-a.__p) end end
	if k == "PointToWorldSpace" then return function(a, v) return a.__p + v end end
	if k == "ToObjectSpace" then return function(a, b) return b end end
	err("CFrame." .. tostring(k) .. " no existe")
end
mtcf.__mul = function(a, b)
	if getmetatable(b) == mt3 then return a.__p + b end
	return CFrame.new(a.__p + b.__p)
end
mtcf.__add = function(a, b) return CFrame.new(a.__p + b) end
mtcf.__sub = function(a, b) return CFrame.new(a.__p - b) end
CFrame = {
	new = function(x, y, z)
		if type(x) == "table" then return setmetatable({ __p = x, __tipo = "CFrame" }, mtcf) end
		return setmetatable({ __p = Vector3.new(x, y, z), __tipo = "CFrame" }, mtcf)
	end,
}
CFrame.lookAt = function(p) return CFrame.new(p) end
CFrame.Angles = function() return CFrame.new() end
CFrame.fromEulerAnglesXYZ = CFrame.Angles
CFrame.identity = CFrame.new()

local cacheEnum = {}
local function enumItem(enumName, itemName, value)
	local clave = enumName .. "." .. itemName
	if cacheEnum[clave] then return cacheEnum[clave] end
	cacheEnum[clave] = setmetatable({ Name = itemName, Value = value, EnumType = enumName, __tipo = "EnumItem" }, { __tostring = function() return "Enum." .. enumName .. "." .. itemName end })
	return cacheEnum[clave]
end
local Enum = setmetatable({}, {
	__index = function(_, enumName)
		local items = API.enums[enumName]
		if not items then err("Enum." .. tostring(enumName) .. " no existe") end
		return setmetatable({}, {
			__index = function(_, itemName)
				if itemName == "GetEnumItems" then return function() local t = {} for n, v in items do table.insert(t, enumItem(enumName, n, v)) end return t end end
				local v = items[itemName]
				if v == nil then err("Enum." .. enumName .. "." .. tostring(itemName) .. " no existe") end
				return enumItem(enumName, itemName, v)
			end,
		})
	end,
})

local function seq(cl)
	return { new = function(...) return { __tipo = cl, Keypoints = { ... } } end }
end
local ColorSequence = seq("ColorSequence")
local NumberSequence = seq("NumberSequence")
local ColorSequenceKeypoint = seq("ColorSequenceKeypoint")
local NumberSequenceKeypoint = seq("NumberSequenceKeypoint")
local TweenInfo = { new = function(t, ...) return { Time = t or 1, __tipo = "TweenInfo" } end }
local RaycastParams = { new = function() return { FilterType = nil, FilterDescendantsInstances = {}, __tipo = "RaycastParams" } end }
local Random = {
	new = function(seed)
		local r = { __tipo = "Random" }
		function r:NextNumber(a, b) a = a or 0; b = b or 1; return a + math.random() * (b - a) end
		function r:NextInteger(a, b) return math.random(a, b) end
		return r
	end,
}

local function tipo(v)
	if type(v) == "table" then
		if v.__tipo then return v.__tipo end
		if rawget(v, "__inst") then return "Instance" end
	end
	return type(v)
end

-- ===================== planificador (task) =====================
local cola = {} -- { t = tiempo, co = corrutina, args }
local function reanudar(co, ...)
	local ok, e = coroutine.resume(co, ...)
	if not ok then
		table.insert(RT.errores, tostring(e) .. "\n" .. debug.traceback(co))
	end
end
local task = {}
function task.spawn(f, ...)
	local co = type(f) == "thread" and f or coroutine.create(f)
	reanudar(co, ...)
	return co
end
function task.defer(f, ...)
	local co = type(f) == "thread" and f or coroutine.create(f)
	table.insert(cola, { t = ahora, co = co, args = table.pack(...) })
	return co
end
function task.delay(t, f, ...)
	local co = coroutine.create(f)
	table.insert(cola, { t = ahora + (t or 0), co = co, args = table.pack(...) })
	return co
end
function task.wait(t)
	local co = coroutine.running()
	table.insert(cola, { t = ahora + (t or 1 / 60), co = co, args = table.pack(t or 0) })
	return coroutine.yield()
end
function task.cancel() end
local function wait(t) return task.wait(t) end

-- ===================== señales =====================
local function Senal(nombre)
	local s = { __tipo = "RBXScriptSignal", conexiones = {}, nombre = nombre }
	function s:Connect(f)
		assert(type(f) == "function", "Connect necesita una función (" .. tostring(nombre) .. ")")
		local c = { Connected = true, f = f }
		function c:Disconnect() c.Connected = false end
		table.insert(s.conexiones, c)
		return c
	end
	s.Once = s.Connect
	function s:Wait()
		local co = coroutine.running()
		table.insert(s, co)
		return coroutine.yield()
	end
	function s:Fire(...)
		for _, c in s.conexiones do
			if c.Connected then task.spawn(c.f, ...) end
		end
		for i = #s, 1, -1 do
			local co = table.remove(s, i)
			task.spawn(co, ...)
		end
	end
	return s
end

-- ===================== instancias =====================
local function esClase(nombre, base)
	while nombre do
		if nombre == base then return true end
		local c = API.classes[nombre]
		nombre = c and c.s
	end
	return false
end
local function miembro(clase, nombre)
	local c = clase
	while c do
		local d = API.classes[c]
		if not d then return nil end
		if d.m[nombre] then return d.m[nombre] end
		c = d.s
	end
	return nil
end

local defectos = {
	Vector3 = function() return Vector3.new() end,
	Vector2 = function() return Vector2.new() end,
	UDim2 = function() return UDim2.new() end,
	UDim = function() return UDim.new() end,
	Color3 = function() return Color3.new(1, 1, 1) end,
	CFrame = function() return CFrame.new() end,
	float = function() return 0 end, double = function() return 0 end, int = function() return 0 end, int64 = function() return 0 end,
	bool = function() return false end, string = function() return "" end,
}
local DEF_ESP = { Visible = true, Enabled = true, Size = nil, ZIndex = 1, Archivable = true, AbsoluteSize = Vector2.new(800, 600), AbsolutePosition = Vector2.new(0, 0), Volume = 0.5, PlaybackSpeed = 1, Scale = 1, Thickness = 1, IsLoaded = true, ViewportSize = Vector2.new(1280, 720), Health = 100, MaxHealth = 100, WalkSpeed = 16 }

local Instance = {}
local mtInst = {}

local function nuevaInstancia(clase)
	if not API.classes[clase] then err("Instance.new: la clase '" .. tostring(clase) .. "' no existe") end
	local o = { __inst = true, __clase = clase, __props = { Name = clase }, __hijos = {}, __attr = {}, __senales = {}, __attrSen = {}, __propSen = {} }
	return setmetatable(o, mtInst)
end

local metodos = {}
function metodos.IsA(self, c) return esClase(self.__clase, c) end
function metodos.GetChildren(self) local t = {} for _, h in self.__hijos do table.insert(t, h) end return t end
function metodos.GetDescendants(self)
	local t = {}
	local function rec(o) for _, h in o.__hijos do table.insert(t, h) rec(h) end end
	rec(self)
	return t
end
function metodos.FindFirstChild(self, n, recursivo)
	for _, h in self.__hijos do if h.__props.Name == n then return h end end
	if recursivo then for _, h in self.__hijos do local r = metodos.FindFirstChild(h, n, true) if r then return r end end end
	return nil
end
function metodos.FindFirstChildOfClass(self, c) for _, h in self.__hijos do if h.__clase == c then return h end end return nil end
function metodos.FindFirstChildWhichIsA(self, c) for _, h in self.__hijos do if esClase(h.__clase, c) then return h end end return nil end
function metodos.FindFirstAncestorOfClass(self, c)
	local p = self.__props.Parent
	while p do if p.__clase == c then return p end p = p.__props.Parent end
	return nil
end
function metodos.FindFirstAncestorWhichIsA(self, c)
	local p = self.__props.Parent
	while p do if esClase(p.__clase, c) then return p end p = p.__props.Parent end
	return nil
end
function metodos.FindFirstAncestor(self, n)
	local p = self.__props.Parent
	while p do if p.__props.Name == n then return p end p = p.__props.Parent end
	return nil
end
function metodos.IsDescendantOf(self, a)
	local p = self.__props.Parent
	while p do if p == a then return true end p = p.__props.Parent end
	return false
end
function metodos.IsAncestorOf(self, d) return metodos.IsDescendantOf(d, self) end
function metodos.WaitForChild(self, n, tiempo)
	local h = metodos.FindFirstChild(self, n)
	if h then return h end
	local inicio = ahora
	while true do
		task.wait(0.1)
		h = metodos.FindFirstChild(self, n)
		if h then return h end
		if tiempo and ahora - inicio >= tiempo then return nil end
		if not tiempo and ahora - inicio >= 5 and not self.__avisado then
			self.__avisado = true
			table.insert(RT.avisos, "Infinite yield possible on '" .. metodos.GetFullName(self) .. ":WaitForChild(\"" .. n .. "\")'")
		end
	end
end
function metodos.GetFullName(self)
	local t = {}
	local o = self
	while o and o ~= RT.game do table.insert(t, 1, o.__props.Name) o = o.__props.Parent end
	return table.concat(t, ".")
end
function metodos.Destroy(self)
	if self.__props.Parent then
		local hs = self.__props.Parent.__hijos
		for i, h in hs do if h == self then table.remove(hs, i) break end end
	end
	self.__props.Parent = nil
	self.__destruido = true
	local s = self.__senales.Destroying
	if s then s:Fire() end
end
function metodos.ClearAllChildren(self) for _, h in metodos.GetChildren(self) do metodos.Destroy(h) end end
function metodos.Clone(self)
	local c = nuevaInstancia(self.__clase)
	for k, v in self.__props do if k ~= "Parent" then c.__props[k] = v end end
	for k, v in self.__attr do c.__attr[k] = v end
	for _, h in self.__hijos do local hc = metodos.Clone(h) hc.Parent = c end
	return c
end
function metodos.SetAttribute(self, k, v)
	assert(type(k) == "string", "SetAttribute: nombre no válido")
	local t = type(v)
	if v ~= nil and t ~= "string" and t ~= "number" and t ~= "boolean" and not (t == "table" and v.__tipo) then
		err("SetAttribute: tipo no admitido en atributo " .. k .. " (" .. t .. ")")
	end
	self.__attr[k] = v
	local s = self.__attrSen[k]
	if s then s:Fire() end
end
function metodos.GetAttribute(self, k) return self.__attr[k] end
function metodos.GetAttributes(self) return self.__attr end
function metodos.GetAttributeChangedSignal(self, k)
	self.__attrSen[k] = self.__attrSen[k] or Senal("attr " .. k)
	return self.__attrSen[k]
end
function metodos.GetPropertyChangedSignal(self, k)
	if not miembro(self.__clase, k) then err("GetPropertyChangedSignal: " .. k .. " no es propiedad de " .. self.__clase) end
	self.__propSen[k] = self.__propSen[k] or Senal("prop " .. k)
	return self.__propSen[k]
end
function metodos.GetPivot(self) return self.__props.WorldPivot or self.__props.CFrame or CFrame.new() end
function metodos.PivotTo(self, cf) self.__props.CFrame = cf end
function metodos.GetService(self, n) return RT.servicio(n) end
metodos.FindService = metodos.GetService

local function valorPorDefecto(self, k, tipoV)
	if DEF_ESP[k] ~= nil then return DEF_ESP[k] end
	if not tipoV then return nil end
	if string.sub(tipoV, 1, 5) == "Enum:" then
		local e = string.sub(tipoV, 6)
		for n, v in API.enums[e] or {} do return enumItem(e, n, v) end
		return nil
	end
	local f = defectos[tipoV]
	return f and f() or nil
end

mtInst.__index = function(self, k)
	if type(k) == "string" and string.sub(k, 1, 2) == "__" then return rawget(self, k) end
	if metodos[k] then return metodos[k] end
	local c = self.__clase
	while c do
		local esp = RT.especiales[c]
		if esp and esp[k] ~= nil then
			return esp[k]
		end
		local d = API.classes[c]
		c = d and d.s
	end
	local propia = rawget(self, k)
	if propia ~= nil then return propia end
	local tipoM = miembro(self.__clase, k)
	if tipoM == "@event" then
		self.__senales[k] = self.__senales[k] or Senal(k)
		return self.__senales[k]
	elseif tipoM == "@fn" then
		return function() return nil end
	elseif tipoM then
		local v = self.__props[k]
		if v == nil and k ~= "Parent" then
			v = valorPorDefecto(self, k, tipoM)
		end
		return v
	end
	local h = metodos.FindFirstChild(self, k)
	if h then return h end
	err(tostring(k) .. " is not a valid member of " .. self.__clase .. " \"" .. tostring(self.__props.Name) .. "\"")
end
mtInst.__newindex = function(self, k, v)
	if type(k) == "string" and string.sub(k, 1, 2) == "__" then rawset(self, k, v) return end
	local tipoM = miembro(self.__clase, k)
	if not tipoM or tipoM == "@event" or tipoM == "@fn" then
		err(tostring(k) .. " is not a valid member of " .. self.__clase)
	end
	if self.__destruido and k == "Parent" and v ~= nil then
		err("The Parent property of " .. self.__props.Name .. " is locked (destruido)")
	end
	-- comprobación de tipo básica
	if v ~= nil and k ~= "Parent" then
		local esperado = tipoM
		local t = tipo(v)
		if string.sub(esperado, 1, 5) == "Enum:" then
			if t ~= "EnumItem" or v.EnumType ~= string.sub(esperado, 6) then err("Propiedad " .. self.__clase .. "." .. k .. ": se esperaba " .. esperado .. ", llega " .. t) end
		elseif (esperado == "float" or esperado == "double" or esperado == "int" or esperado == "int64") and t ~= "number" then
			err("Propiedad " .. self.__clase .. "." .. k .. ": se esperaba número, llega " .. t)
		elseif esperado == "bool" and t ~= "boolean" then
			err("Propiedad " .. self.__clase .. "." .. k .. ": se esperaba boolean, llega " .. t)
		elseif esperado == "string" and t ~= "string" then
			err("Propiedad " .. self.__clase .. "." .. k .. ": se esperaba texto, llega " .. t)
		elseif (esperado == "UDim2" or esperado == "Vector3" or esperado == "Color3" or esperado == "Vector2" or esperado == "UDim" or esperado == "CFrame") and t ~= esperado then
			err("Propiedad " .. self.__clase .. "." .. k .. ": se esperaba " .. esperado .. ", llega " .. t)
		end
	end
	if k == "Parent" then
		local viejo = self.__props.Parent
		if viejo then
			for i, h in viejo.__hijos do if h == self then table.remove(viejo.__hijos, i) break end end
		end
		self.__props.Parent = v
		if v then
			table.insert(v.__hijos, self)
			local s = v.__senales.ChildAdded
			if s then s:Fire(self) end
			local p = v
			while p do
				local d = p.__senales.DescendantAdded
				if d then d:Fire(self) end
				p = p.__props.Parent
			end
		end
		return
	end
	self.__props[k] = v
	local s = self.__propSen[k]
	if s then s:Fire() end
	local ch = self.__senales.Changed
	if ch then ch:Fire(k) end
end
mtInst.__tostring = function(self) return self.__props.Name end

function Instance.new(clase, padre)
	local o = nuevaInstancia(clase)
	if padre then o.Parent = padre end
	return o
end
RT.Instance = Instance
RT.nuevaInstancia = nuevaInstancia

-- ===================== servicios =====================
RT.especiales = {}
RT.game = nuevaInstancia("DataModel")
RT.game.__props.Name = "Game"
local servicios = {}
function RT.servicio(n)
	if servicios[n] then return servicios[n] end
	if not API.classes[n] then err("GetService: servicio desconocido " .. tostring(n)) end
	local s = nuevaInstancia(n)
	s.__props.Name = n
	s.Parent = RT.game
	servicios[n] = s
	return s
end

RT.entorno = {
	Vector3 = Vector3, Vector2 = Vector2, Color3 = Color3, UDim = UDim, UDim2 = UDim2, CFrame = CFrame, Enum = Enum,
	ColorSequence = ColorSequence, NumberSequence = NumberSequence, ColorSequenceKeypoint = ColorSequenceKeypoint, NumberSequenceKeypoint = NumberSequenceKeypoint,
	TweenInfo = TweenInfo, RaycastParams = RaycastParams, Random = Random, Instance = Instance, task = task, wait = wait,
	typeof = tipo, game = RT.game, warn = function(...) table.insert(RT.avisos, table.concat({ ... }, " ")) end,
	print = function() end, tick = function() return ahora end, time = function() return ahora end,
	utf8 = utf8, string = string, table = table, math = math, coroutine = coroutine, debug = debug, os = { clock = function() return ahora end, time = os.time, date = os.date },
	pcall = pcall, xpcall = xpcall, error = error, assert = assert, type = type, tostring = tostring, tonumber = tonumber, select = select,
	pairs = pairs, ipairs = ipairs, next = next, setmetatable = setmetatable, getmetatable = getmetatable, rawget = rawget, rawset = rawset, rawequal = rawequal, unpack = table.unpack, buffer = buffer,
}
RT.entorno.workspace = RT.servicio("Workspace")
RT.entorno.Workspace = RT.entorno.workspace

-- ===================== avance del tiempo =====================
RT.renderPasos = {}
function RT.avanzar(segundos, dt)
	dt = dt or 1 / 30
	local fin = ahora + segundos
	while ahora < fin do
		ahora += dt
		-- tareas listas
		local listas = {}
		for i = #cola, 1, -1 do
			if cola[i].t <= ahora then table.insert(listas, table.remove(cola, i)) end
		end
		table.sort(listas, function(a, b) return a.t < b.t end)
		for _, c in listas do
			if coroutine.status(c.co) == "suspended" then reanudar(c.co, table.unpack(c.args, 1, c.args.n)) end
		end
		for _, f in RT.renderPasos do
			local ok, e = xpcall(f, debug.traceback, dt)
			if not ok then table.insert(RT.errores, "[RenderStep] " .. tostring(e)) RT.renderPasos[_] = nil end
		end
		local rs = RT.servicio("RunService")
		for _, nombre in { "RenderStepped", "Heartbeat", "Stepped" } do
			local s = rs.__senales[nombre]
			if s then
				for _, c in s.conexiones do
					if c.Connected then
						local ok, e = xpcall(c.f, debug.traceback, dt)
						if not ok then table.insert(RT.errores, "[" .. nombre .. "] " .. tostring(e)) c.Connected = false end
					end
				end
			end
		end
	end
end
function RT.ahora() return ahora end

return RT
