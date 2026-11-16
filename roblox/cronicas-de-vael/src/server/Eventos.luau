--!strict
-- Paraderos aleatorios por el camino (no todo son peleas): cada cierto tiempo aparece algo en una zona.
--  · Hoguera de viajeros, cofre sospechoso (a veces muerde), pozo de los deseos, viajero perdido
--  · y, muy de vez en cuando, el Vendedor sospechoso, que vende mejoras raras.
-- Cada jugador puede usar cada paradero una vez. Desaparecen solos a los 3 minutos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Datos = require(ReplicatedStorage.Vael.Datos)

local Eventos = {}

local NEGRO = Color3.fromRGB(25, 20, 30)
local rng = Random.new()

type Ctx = {
	dialogo: (Player, any) -> (),
	notificar: (Player, string) -> (),
	enviarEstado: (Player) -> (),
	Combate: any,
	DatosJugador: any,
	remoto: (string) -> RemoteEvent,
}
local ctx: Ctx

local ZONAS = {
	{ nombre = "la Pradera", desde = 45, hasta = 155, llave = nil },
	{ nombre = "el Pantano", desde = 178, hasta = 222, llave = "cuerda" },
	{ nombre = "el Bosque", desde = 270, hasta = 325, llave = "hacha" },
	{ nombre = "las Ruinas", desde = 368, hasta = 405, llave = "llave" },
}

local function parte(padre: Instance, x: number, y: number, z: number, w: number, h: number, color: Color3, redondo: boolean?, giro: number?)
	for capa = 0, 1 do
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.SmoothPlastic
		if redondo then
			p.Shape = Enum.PartType.Cylinder
			p.Size = capa == 0 and Vector3.new(0.2, w + 0.5, w + 0.5) or Vector3.new(0.4, w, w)
			p.CFrame = CFrame.new(x, y, z - (capa == 0 and 0.3 or 0)) * CFrame.Angles(0, math.rad(90), 0)
		else
			p.Size = capa == 0 and Vector3.new(w + 0.5, h + 0.5, 0.2) or Vector3.new(w, h, 0.4)
			p.CFrame = CFrame.new(x, y, z - (capa == 0 and 0.3 or 0)) * CFrame.Angles(0, 0, math.rad(giro or 0))
		end
		p.Color = capa == 0 and NEGRO or color
		p.Parent = padre
	end
end

type Paradero = { tipo: string, modelo: Model, usados: { [Player]: boolean }, x: number, stock: { string }?, comprados: { [Player]: { [string]: boolean } } }
local activos: { Paradero } = {}

local TIPOS = { "hoguera", "hoguera", "cofre", "cofre", "pozo", "viajero", "viajero", "vendedor" }

local function crearModelo(tipo: string, x: number): (Model, Part)
	local m = Instance.new("Model")
	m.Name = "Paradero_" .. tipo
	local z = -9.5
	if tipo == "hoguera" then
		parte(m, x, 0.5, z, 3.4, 0.7, Color3.fromRGB(120, 80, 50), false, 15)
		parte(m, x, 0.5, z + 0.1, 3.4, 0.7, Color3.fromRGB(140, 95, 60), false, -15)
		parte(m, x, 1.6, z + 0.3, 2.2, 0, Color3.fromRGB(255, 150, 40), true)
		parte(m, x, 2.1, z + 0.5, 1.2, 0, Color3.fromRGB(255, 230, 110), true)
		parte(m, x - 3.2, 0.6, z, 2.4, 1.2, Color3.fromRGB(150, 110, 70))
	elseif tipo == "cofre" then
		parte(m, x, 0.8, z, 3, 1.6, Color3.fromRGB(160, 100, 55))
		parte(m, x, 2, z - 0.05, 3.2, 1, Color3.fromRGB(190, 120, 60))
		parte(m, x, 1.2, z + 0.4, 0.6, 0.7, Color3.fromRGB(240, 200, 70))
	elseif tipo == "pozo" then
		parte(m, x, 1.2, z, 4, 2.4, Color3.fromRGB(160, 155, 165))
		parte(m, x - 1.8, 3.4, z - 0.3, 0.4, 4, Color3.fromRGB(120, 80, 50))
		parte(m, x + 1.8, 3.4, z - 0.3, 0.4, 4, Color3.fromRGB(120, 80, 50))
		parte(m, x, 5.6, z - 0.2, 5, 0.8, Color3.fromRGB(190, 75, 60))
		parte(m, x, 2.5, z + 0.2, 3.4, 0.4, Color3.fromRGB(80, 160, 230))
	elseif tipo == "vendedor" then
		parte(m, x + 2.6, 1.2, z, 2.4, 2.4, Color3.fromRGB(120, 80, 50))
		parte(m, x + 2.6, 2.6, z + 0.2, 1.4, 0, Color3.fromRGB(190, 120, 255), true)
	end
	local p = Instance.new("Part")
	p.Name = "Punto"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = Vector3.new(2, 3, 2)
	p.Position = Vector3.new(x, 2.8, z + 0.6)
	if tipo == "viajero" then
		p:SetAttribute("Npc", "vecino:" .. rng:NextInteger(1, 99999))
		p:SetAttribute("Frases", "Creo que me he perdido…|¿Esto es el Pantano o la Pradera?")
	elseif tipo == "vendedor" then
		p:SetAttribute("Npc", "vendedor")
		p:SetAttribute("Frases", "Psst… ¿mejoras?|Yo no estuve aquí.|No preguntes de dónde las saco.")
	elseif tipo == "hoguera" then
		p:SetAttribute("Npc", "vecino:" .. rng:NextInteger(1, 99999))
		p:SetAttribute("NpcX", x - 3.2)
		p:SetAttribute("Frases", "¡Siéntate, que hay sitio!|Esta hoguera calienta más que mi abuela.")
	end
	p.Parent = m
	return m, p
end

local function quitar(par: Paradero)
	local i = table.find(activos, par)
	if i then
		table.remove(activos, i)
	end
	par.modelo:Destroy()
end

local function curarParte(j: Player, k: number)
	local hp, maxHp, mp, maxMp = ctx.Combate.vidaDe(j)
	ctx.Combate.ponerVida(j, math.min(maxHp, hp + math.floor(maxHp * k)), math.min(maxMp, mp + math.floor(maxMp * k)))
end

local function usar(par: Paradero, j: Player)
	local perfil = ctx.DatosJugador.obtener(j)
	if not perfil or not perfil.clase or ctx.Combate.enBatalla(j) then
		return
	end
	if par.tipo ~= "vendedor" and par.usados[j] then
		ctx.notificar(j, "Ya has pasado por aquí")
		return
	end
	local function hecho()
		par.usados[j] = true
		ctx.enviarEstado(j)
		ctx.DatosJugador.guardar(j)
	end
	if par.tipo == "hoguera" then
		ctx.dialogo(j, {
			titulo = "Hoguera de viajeros",
			texto = "Unos viajeros te hacen sitio junto al fuego. Huele a castañas (y a calcetín).",
			quien = { "vecino", "777" },
			opciones = {
				{ texto = "Descansar (cura la mitad)", accion = function()
					curarParte(j, 0.5)
					hecho()
					return "Te calientas las manos. Te sientes mucho mejor."
				end },
				{ texto = "Contar un chiste", accion = function()
					hecho()
					if rng:NextNumber() < 0.5 then
						perfil.oro += 15
						return "¡Se parten de risa! Te dan 15 de oro de propina."
					end
					return "Silencio total. Un grillo tose."
				end },
				{ texto = "Seguir el camino" },
			},
		})
	elseif par.tipo == "cofre" then
		local function mimico()
			hecho()
			quitar(par)
			ctx.Combate.empezar({ id = "pradera", nombre = "¡Un cofre mímico!", nivel = 4, grupos = { { "mimico" } }, color = Color3.fromRGB(170, 110, 60) }, Vector3.new(par.x, 0, 0), { j })
			return "¡EL COFRE TIENE DIENTES!"
		end
		ctx.dialogo(j, {
			titulo = "Un cofre en mitad del camino",
			texto = "Nadie deja un cofre así como así. ¿Verdad?",
			quien = { "enemigo", "mimico" },
			opciones = {
				{ texto = "Abrirlo", accion = function()
					if rng:NextNumber() < 0.55 then
						local oro = rng:NextInteger(25, 60)
						perfil.oro += oro
						hecho()
						quitar(par)
						return "¡Era de verdad! Encuentras " .. oro .. " de oro."
					end
					return mimico()
				end },
				{ texto = "Darle una patada primero", accion = function()
					if rng:NextNumber() < 0.5 then
						perfil.oro += 20
						hecho()
						quitar(par)
						return "¡AY, el dedo! Era un cofre normal. Dentro hay 20 de oro."
					end
					return mimico()
				end },
				{ texto = "Dejarlo en paz" },
			},
		})
	elseif par.tipo == "pozo" then
		ctx.dialogo(j, {
			titulo = "Pozo de los deseos",
			texto = "Un cartel dice: «10 de oro por deseo. No se aceptan devoluciones».",
			quien = { "vecino", "4040" },
			opciones = {
				{ texto = "Echar 10 de oro", accion = function()
					if perfil.oro < 10 then
						return "No te llega. El pozo te mira con pena."
					end
					perfil.oro -= 10
					hecho()
					local t = rng:NextNumber()
					if t < 0.15 then
						local comunes = {}
						for _, id in Datos.OrdenMejoras do
							if Datos.Mejoras[id].rareza == "comun" then
								table.insert(comunes, id)
							end
						end
						local id = comunes[rng:NextInteger(1, #comunes)]
						ctx.Combate.darMejora(j, id)
						return "¡El pozo escupe algo! Es: " .. Datos.Mejoras[id].nombre
					elseif t < 0.4 then
						perfil.objetos.pocion = (perfil.objetos.pocion or 0) + 1
						return "Sale flotando una poción. ¡Gracias, pozo!"
					elseif t < 0.65 then
						perfil.oro += 25
						return "¡El pozo te devuelve 25 de oro! Hoy está generoso."
					end
					return "Plof. Nada. El pozo eructa."
				end },
				{ texto = "Asomarse", accion = function()
					return "Ves tu reflejo. Qué guapo vas hoy."
				end },
				{ texto = "Irse" },
			},
		})
	elseif par.tipo == "viajero" then
		ctx.dialogo(j, {
			titulo = "Viajero perdido",
			texto = "«Me he perdido y me han mordido tres babosas. ¿Me das una poción?»",
			quien = { "vecino", "31337" },
			opciones = {
				{ texto = "Darle una poción", accion = function()
					if (perfil.objetos.pocion or 0) <= 0 then
						return "No te quedan pociones. Le das ánimos. No sirve de mucho."
					end
					perfil.objetos.pocion -= 1
					perfil.oro += 45
					hecho()
					return "«¡Gracias!» Te da 45 de oro y se va dando saltitos."
				end },
				{ texto = "Indicarle el camino", accion = function()
					hecho()
					return "Se va justo por el lado contrario. Bueno, lo intentaste."
				end },
				{ texto = "Hacer como que no lo ves" },
			},
		})
	elseif par.tipo == "vendedor" then
		local lista = {}
		par.comprados[j] = par.comprados[j] or {}
		for _, id in par.stock or {} do
			local m = Datos.Mejoras[id]
			table.insert(lista, { id = id, nombre = m.nombre, descripcion = m.descripcion, rareza = m.rareza, precio = Datos.PrecioRareza[m.rareza], vendido = par.comprados[j][id] == true })
		end
		ctx.remoto("AbrirVendedor"):FireClient(j, { titulo = "Vendedor sospechoso", frase = "Psst… mercancía de primera. No preguntes.", lista = lista, origen = "vendedor" })
		Eventos.ultimoVendedor = par
	end
end

Eventos.ultimoVendedor = nil :: Paradero?

--- Compra al vendedor sospechoso (o al herrero, que usa la misma ventana).
function Eventos.comprar(j: Player, id: string): boolean
	local par = Eventos.ultimoVendedor
	if not par or not par.modelo.Parent or not par.stock or not table.find(par.stock, id) then
		return false
	end
	par.comprados[j] = par.comprados[j] or {}
	if par.comprados[j][id] then
		return false
	end
	local perfil = ctx.DatosJugador.obtener(j)
	local precio = Datos.PrecioRareza[Datos.Mejoras[id].rareza]
	if not perfil or perfil.oro < precio then
		ctx.notificar(j, "No te llega el oro. El vendedor resopla.")
		return false
	end
	perfil.oro -= precio
	par.comprados[j][id] = true
	ctx.Combate.darMejora(j, id)
	ctx.enviarEstado(j)
	return true
end

local function aparecer()
	if #activos >= 2 then
		return
	end
	local tipo = TIPOS[rng:NextInteger(1, #TIPOS)]
	-- solo en zonas a las que alguien pueda llegar ya
	local posibles = {}
	for _, z in ZONAS do
		local alcanzable = z.llave == nil
		for _, j in Players:GetPlayers() do
			local perfil = ctx.DatosJugador.obtener(j)
			if perfil and z.llave and perfil.llaves[z.llave] then
				alcanzable = true
			end
		end
		if alcanzable then
			table.insert(posibles, z)
		end
	end
	local zona = posibles[rng:NextInteger(1, #posibles)]
	local x = rng:NextNumber(zona.desde, zona.hasta)
	local carpeta = workspace:FindFirstChild("MundoVael")
	if not carpeta then
		return
	end
	local m, p = crearModelo(tipo, x)
	local par: Paradero = { tipo = tipo, modelo = m, usados = {}, x = x, stock = tipo == "vendedor" and Datos.ofertaMejoras(rng) or nil, comprados = {} }
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = tipo == "vendedor" and "Hablar" or (tipo == "cofre" and "Mirar" or "Acercarse")
	prompt.ObjectText = ({ hoguera = "Hoguera", cofre = "Cofre", pozo = "Pozo de los deseos", viajero = "Viajero", vendedor = "Vendedor sospechoso" })[tipo]
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = p
	prompt.Triggered:Connect(function(j)
		usar(par, j)
	end)
	m.Parent = carpeta
	table.insert(activos, par)
	local aviso = ({
		hoguera = "Alguien ha encendido una hoguera en " .. zona.nombre,
		cofre = "Se ha visto un cofre solitario en " .. zona.nombre,
		pozo = "Ha aparecido un pozo de los deseos en " .. zona.nombre,
		viajero = "Un viajero se ha perdido en " .. zona.nombre,
		vendedor = "Psst… un vendedor sospechoso ronda por " .. zona.nombre,
	})[tipo]
	for _, j in Players:GetPlayers() do
		ctx.notificar(j, aviso)
	end
	task.delay(tipo == "vendedor" and 150 or 200, function()
		if m.Parent then
			quitar(par)
		end
	end)
end

function Eventos.iniciar(c: Ctx)
	ctx = c
	task.spawn(function()
		task.wait(40)
		while true do
			aparecer()
			task.wait(rng:NextNumber(90, 150))
		end
	end)
end

return Eventos
