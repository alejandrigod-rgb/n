--!strict
-- Mochila (tecla B): una mochila de aventurero de cartón con casillas.
--  · Arriba a la izquierda, tu héroe y sus datos (nivel, vida, maná y oro).
--  · Casillas: consumibles (se pueden usar), objetos clave y mejoras (con su rareza).
--  · Al pulsar una casilla, abajo salen el nombre, la descripción y, si se puede, el botón «Usar».

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ui = require(script.Parent:WaitForChild("Ui"))
local Munecos = require(script.Parent:WaitForChild("Munecos"))
local Datos = require(ReplicatedStorage:WaitForChild("Vael"):WaitForChild("Datos")) :: any
local C = Ui.Colores

local Mochila = {}

local abierta: Frame? = nil

function Mochila.estaAbierta(): boolean
	return abierta ~= nil and abierta.Parent ~= nil
end

function Mochila.cerrar()
	if abierta then
		abierta:Destroy()
		abierta = nil
	end
end

--- Abre la mochila (o la cierra si ya está abierta). usar(id) pide al servidor usar un objeto.
function Mochila.alternar(gui: Instance, e: any, apariencia: any, usar: (string) -> (), elegirCompanero: ((string) -> ())?, equipar: ((string) -> ())?, regalar: ((string, string?) -> ())?)
	if Mochila.estaAbierta() then
		Mochila.cerrar()
		return
	end
	e = e or {}
	-- la mochila: cartón marrón con solapa y correas
	local p = Ui.panel({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(860, 540), BackgroundColor3 = Color3.fromRGB(150, 105, 65), Parent = gui, ZIndex = 120 })
	abierta = p
	Ui.aparecer(p)
	local solapa = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, 16), Size = UDim2.fromOffset(420, 54), BackgroundColor3 = Color3.fromRGB(125, 85, 50), BorderSizePixel = 0, ZIndex = 121, Parent = p })
	Ui.esquinas(solapa, 14)
	Ui.borde(solapa, C.tinta, 3)
	Ui.texto({ Size = UDim2.fromScale(1, 1), Text = "Mochila", TextColor3 = C.oro, ZIndex = 122, Parent = solapa })
	for _, x in { 0.2, 0.8 } do
		local correa = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(x, 0, 0, -6), Size = UDim2.fromOffset(26, 70), BackgroundColor3 = Color3.fromRGB(100, 65, 40), BorderSizePixel = 0, ZIndex = 122, Parent = p })
		Ui.borde(correa, C.tinta, 2)
		local hebilla = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.fromOffset(20, 16), BackgroundColor3 = Color3.fromRGB(220, 190, 90), BorderSizePixel = 0, ZIndex = 123, Parent = correa })
		Ui.borde(hebilla, C.tinta, 2)
	end
	Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 14), Size = UDim2.fromOffset(160, 22), Text = "B: cerrar", TextColor3 = C.suave, ZIndex = 122, Parent = p })

	-- ficha del héroe (hoja de papel)
	local ficha = Ui.crear("Frame", { Position = UDim2.fromOffset(24, 70), Size = UDim2.fromOffset(230, 330), BackgroundColor3 = Color3.fromRGB(236, 222, 190), BorderSizePixel = 0, Rotation = -1, ZIndex = 121, Parent = p })
	Ui.esquinas(ficha, 4)
	Ui.borde(ficha, C.tinta, 2)
	local lienzo = Ui.crear("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.fromOffset(150, 195), BackgroundTransparency = 1, ZIndex = 122, Parent = ficha })
	if e.clase then
		Munecos.crear(lienzo, "clase", e.clase, 3, apariencia)
	end
	local cl = e.clase and Datos.Clases[e.clase]
	local lineas = {
		(e.nombreHeroe and e.nombreHeroe ~= "" and e.nombreHeroe or "") .. (cl and (" · " .. Ui.t(cl.nombre)) or ""),
		Ui.t("Nivel") .. " " .. tostring(e.nivel or 1),
		Ui.t("Vida") .. " " .. tostring(e.hp or 0) .. "/" .. tostring(e.maxHp or 0) .. "   " .. Ui.t("Maná") .. " " .. tostring(e.mp or 0) .. "/" .. tostring(e.maxMp or 0),
		tostring(e.oro or 0) .. " " .. Ui.t("oro"),
	}
	for i, l in lineas do
		Ui.texto({ Position = UDim2.fromOffset(10, 200 + (i - 1) * 30), Size = UDim2.new(1, -20, 0, 26), Text = l, TextColor3 = C.tinta, Contorno = false, ZIndex = 122, Parent = ficha })
	end
	if regalar then
		Ui.boton({ Position = UDim2.fromOffset(24, 18), Size = UDim2.fromOffset(210, 38), Text = "Regalar 10 de oro", Icono = "moneda", BackgroundColor3 = Color3.fromRGB(200, 160, 60), ZIndex = 123, Parent = p }, function()
			(regalar :: any)("oro", nil)
			Mochila.cerrar()
		end)
	end

	-- detalle del objeto elegido
	local detalle = Ui.crear("Frame", { Position = UDim2.fromOffset(24, 414), Size = UDim2.new(1, -48, 0, 106), BackgroundColor3 = Color3.fromRGB(236, 222, 190), BorderSizePixel = 0, ZIndex = 121, Parent = p })
	Ui.esquinas(detalle, 6)
	Ui.borde(detalle, C.tinta, 2)
	local detTitulo = Ui.texto({ Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -200, 0, 30), Text = "Elige una casilla", TextColor3 = C.tinta, Contorno = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 122, Parent = detalle })
	local detTexto = Ui.texto({ Position = UDim2.fromOffset(16, 40), Size = UDim2.new(1, -200, 0, 56), Text = "", TextScaled = false, TextSize = 19, TextWrapped = true, TextColor3 = Color3.fromRGB(90, 75, 65), Contorno = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 122, Parent = detalle })
	local botonUsar: TextButton? = nil
	local botonExtra: TextButton? = nil
	local function elegir(titulo: string, texto: string, idUsable: string?, extra: { texto: string, alPulsar: () -> () }?)
		detTitulo.Text = Ui.t(titulo)
		detTexto.Text = Ui.t(texto)
		if botonUsar then
			botonUsar:Destroy()
			botonUsar = nil
		end
		if botonExtra then
			botonExtra:Destroy()
			botonExtra = nil
		end
		if extra then
			-- si además se puede usar, este botón va a la izquierda del de «Usar»
			botonExtra = Ui.boton({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, idUsable and -186 or -16, 0.5, 0), Size = UDim2.fromOffset(160, 50), Text = extra.texto, Icono = "estrella", BackgroundColor3 = Color3.fromRGB(100, 160, 90), ZIndex = 123, Parent = detalle }, function()
				extra.alPulsar()
				Mochila.cerrar()
			end)
		end
		if idUsable then
			botonUsar = Ui.boton({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(160, 50), Text = "Usar", Icono = "corazon", BackgroundColor3 = Color3.fromRGB(100, 160, 90), ZIndex = 123, Parent = detalle }, function()
				usar(idUsable)
				Mochila.cerrar()
			end)
		end
	end

	-- casillas
	local zona = Ui.crear("ScrollingFrame", { Position = UDim2.fromOffset(272, 70), Size = UDim2.fromOffset(564, 330), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 6, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 121, Parent = p })
	Ui.crear("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = zona })
	local orden = 0
	local function seccion(titulo: string): Frame
		orden += 1
		Ui.texto({ Size = UDim2.new(1, 0, 0, 26), Text = titulo, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = orden, ZIndex = 122, Parent = zona })
		orden += 1
		local rejilla = Ui.crear("Frame", { Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = orden, ZIndex = 121, Parent = zona })
		Ui.crear("UIGridLayout", { CellSize = UDim2.fromOffset(66, 66), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rejilla })
		return rejilla
	end
	local function casilla(rejilla: Frame, icono: string, color: Color3, borde: Color3, cuenta: number?, apagada: boolean?, alPulsar: () -> ())
		local b = Ui.crear("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = apagada and Color3.fromRGB(120, 100, 85) or Color3.fromRGB(245, 236, 214), BorderSizePixel = 0, ZIndex = 122, Parent = rejilla })
		Ui.esquinas(b, 10)
		Ui.borde(b, apagada and Color3.fromRGB(90, 75, 65) or borde, 3)
		local ic = Ui.icono(icono, b, UDim2.fromOffset(13, 13), UDim2.fromOffset(40, 40), 123)
		if apagada then
			for _, d in ic:GetDescendants() do
				if d:IsA("Frame") then
					d.BackgroundTransparency = 0.75
				end
			end
		else
			Ui.crear("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -5, 1, -5), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 124, Parent = b }, { Ui.crear("UICorner", { CornerRadius = UDim.new(0.5, 0) }) })
		end
		if cuenta and cuenta > 1 then
			Ui.texto({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -4, 0, 2), Size = UDim2.fromOffset(34, 20), Text = "×" .. cuenta, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 125, Parent = b })
		end
		local escala = Ui.crear("UIScale", { Parent = b })
		b.MouseEnter:Connect(function()
			Ui.tween(escala, { Scale = 1.08 }, 0.12)
		end)
		b.MouseLeave:Connect(function()
			Ui.tween(escala, { Scale = 1 }, 0.12)
		end)
		b.Activated:Connect(alPulsar)
	end

	-- compañeros: quién pelea contigo (o ir solo)
	local equipo = seccion("Compañeros")
	local actual = e.companero
	local function tarjetaCompanero(cid: string?, nombre: string, semilla: string?, tengo: boolean, alPulsar: () -> ())
		local elegido = (cid or "solo") == (actual or "solo") and tengo
		local b = Ui.crear("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = tengo and Color3.fromRGB(245, 236, 214) or Color3.fromRGB(120, 100, 85), BorderSizePixel = 0, ZIndex = 122, Parent = equipo })
		Ui.esquinas(b, 10)
		Ui.borde(b, elegido and Color3.fromRGB(110, 190, 110) or Color3.fromRGB(150, 110, 70), elegido and 4 or 3)
		local lienzo = Ui.crear("Frame", { Position = UDim2.fromOffset(8, 2), Size = UDim2.fromOffset(50, 62), BackgroundTransparency = 1, ZIndex = 123, Parent = b })
		if semilla and tengo then
			Munecos.crear(lienzo, "vecino", semilla, 2)
		else
			Ui.texto({ Size = UDim2.fromScale(1, 1), Text = semilla and "¿?" or "—", TextColor3 = tengo and C.tinta or C.suave, ZIndex = 124, Parent = lienzo })
		end
		if elegido then
			Ui.icono("estrella", b, UDim2.fromOffset(44, 2), UDim2.fromOffset(20, 20), 125)
		end
		b.Activated:Connect(alPulsar)
	end
	tarjetaCompanero(nil, "Ir solo", nil, true, function()
		elegir("Ir solo", "Peleas tú solo (o con tus amigos de Roblox). Más difícil, pero toda la gloria es tuya.", nil, elegirCompanero and { texto = "Ir solo", alPulsar = function()
			(elegirCompanero :: any)("solo")
		end } or nil)
	end)
	for _, cid in Datos.OrdenCompaneros do
		local def = Datos.Companeros[cid]
		local tengo = e.companeros ~= nil and e.companeros[cid] == true
		tarjetaCompanero(cid, def.nombre, def.vecino, tengo, function()
			if tengo then
				local cl = Datos.Clases[def.clase]
				elegir(def.nombre .. (cl and (" · " .. Ui.t(cl.nombre)) or ""), def.descripcion, nil, elegirCompanero and { texto = "Llevar", alPulsar = function()
					(elegirCompanero :: any)(cid)
				end } or nil)
			else
				elegir("¿?", Ui.t("Aún no se ha unido.") .. " " .. Ui.t(def.como))
			end
		end)
	end

	-- equipo: lo que tienes (armas, armaduras y amuletos); lo puesto lleva una estrella
	local equipoS = seccion("Equipo")
	local puesto = e.equipo or {}
	local tieneAlgo = false
	for _, id in Datos.OrdenEquipo do
		local mejora = e.armas and e.armas[id]
		local pz = Datos.Equipo[id]
		if mejora ~= nil and pz then
			tieneAlgo = true
			local llevado = puesto[pz.hueco] == id
			local icono = pz.forma == "baston" and "magia" or (pz.hueco == "arma" and "espada" or pz.hueco == "armadura" and "escudo" or "estrella")
			casilla(equipoS, icono, pz.color, llevado and Color3.fromRGB(220, 170, 60) or Color3.fromRGB(150, 110, 70), nil, false, function()
				local titulo = pz.nombre .. (mejora > 0 and (" +" .. mejora) or "")
				local texto = Ui.t(pz.descripcion) .. "\n" .. Datos.textoStats(Datos.statsPieza(id, mejora))
				elegir(titulo, texto, nil, equipar and { texto = llevado and "Quitármelo" or "Ponérmelo", alPulsar = function()
					(equipar :: any)(id)
				end } or nil)
			end)
		end
	end
	if not tieneAlgo then
		Ui.texto({ Size = UDim2.fromOffset(500, 30), Text = "Compra equipo en la herrería de Olga.", TextColor3 = C.suave, LayoutOrder = orden + 1, ZIndex = 122, Parent = zona })
		orden += 1
	end

	local consumibles = seccion("Objetos")
	for _, id in Datos.OrdenObjetos do
		local o = Datos.Objetos[id]
		local n = e.objetos and e.objetos[id] or 0
		casilla(consumibles, id, id == "pocion" and Color3.fromRGB(220, 80, 90) or Color3.fromRGB(80, 140, 230), Color3.fromRGB(150, 110, 70), n, n <= 0, function()
			elegir(o.nombre .. " ×" .. n, o.descripcion, n > 0 and id or nil, (n > 0 and regalar) and { texto = "Regalar", alPulsar = function()
				(regalar :: any)("objeto", id)
			end } or nil)
		end)
	end
	local clave = seccion("Objetos clave")
	for _, id in Datos.OrdenLlaves do
		local l = Datos.Llaves[id]
		local tengo = e.llaves and e.llaves[id]
		casilla(clave, l.icono, l.color, Color3.fromRGB(220, 180, 80), nil, not tengo, function()
			elegir(tengo and l.nombre or "¿?", tengo and l.descripcion or "Aún no lo tienes. Explora y habla con la gente.")
		end)
	end
	local mejoras = seccion("Mejoras")
	local cuenta: { [string]: number } = {}
	local lista: { string } = {}
	for _, id in e.mejoras or {} do
		if not cuenta[id] then
			table.insert(lista, id)
		end
		cuenta[id] = (cuenta[id] or 0) + 1
	end
	if #lista == 0 then
		Ui.texto({ Size = UDim2.fromOffset(500, 30), Text = "Aún no tienes mejoras: ábrelas en cofres, del jefe o cómpralas.", TextColor3 = C.suave, LayoutOrder = 99, ZIndex = 122, Parent = zona })
	end
	for _, id in lista do
		local m = Datos.Mejoras[id]
		if m then
			casilla(mejoras, m.icono, m.color, Datos.ColorRareza[m.rareza], cuenta[id], false, function()
				elegir(m.nombre, m.descripcion)
			end)
		end
	end
	if e.sinergias and #e.sinergias > 0 then
		Ui.texto({ Size = UDim2.new(1, 0, 0, 26), Text = Ui.t("Combinaciones") .. ": " .. table.concat(e.sinergias, " · "), TextColor3 = C.oro, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 100, ZIndex = 122, Parent = zona })
	end
end

return Mochila
