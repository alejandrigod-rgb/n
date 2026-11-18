--!strict
-- Crónicas de Vael · servidor. Arranca el mundo, las partidas guardadas, las guaridas de combate, la fuente,
-- el mercader, los personajes con los que se habla (taberna, posada, herrería, ermitaño), los secretos que
-- abren el camino (cuerda, hacha, llave y farol) y los paraderos aleatorios.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Vael = ReplicatedStorage:WaitForChild("Vael")
local Datos = require(Vael.Datos)
local DatosJugador = require(script.Parent.DatosJugador)
local Combate = require(script.Parent.Combate)
local Mundo = require(script.Parent.Mundo)
local Eventos = require(script.Parent.Eventos)

-- remotos (servidor ↔ cliente)
local Remotos = Instance.new("Folder")
Remotos.Name = "Remotos"
for _, nombre in {
	"ElegirClase", "EstadoJugador", "BatallaInicio", "BatallaEstado", "BatallaEvento", "BatallaTurno", "PedirAccion", "EnviarAccion", "BatallaFin",
	"Notificar", "AbrirTienda", "Comprar", "OfrecerMejoras", "ElegirMejora", "AbrirVendedor", "ComprarMejora", "Dialogo", "ElegirOpcion",
	"Vasos", "ElegirVaso", "Teletransporte", "Sonido", "GuardarApariencia", "ErrorServidor", "Emboscada", "AbrirEditor", "UsarObjeto", "GuardarAjustes", "Epilogo", "ElegirCompanero", "Final2", "Despertar", "AbrirTablon", "AceptarEncargo", "EntregarEncargo", "AbrirArmeria", "ComprarEquipo", "MejorarEquipo", "Equipar", "Regalar", "Emote", "EmoteJugador", "PedirClasificacion", "Clasificacion",
} do
	local r = Instance.new("RemoteEvent")
	r.Name = nombre
	r.Parent = Remotos
end
Remotos.Parent = Vael

local function remoto(nombre: string): RemoteEvent
	return Remotos:FindFirstChild(nombre) :: RemoteEvent
end

-- en Studio, los errores del servidor salen también en la pantalla del jugador (cuadro rojo abajo a la izquierda)
if game:GetService("RunService"):IsStudio() then
	game:GetService("LogService").MessageOut:Connect(function(mensaje, tipo)
		if tipo == Enum.MessageType.MessageError then
			remoto("ErrorServidor"):FireAllClients(mensaje)
		end
	end)
end

Combate.iniciar(Remotos)

--- Compañeros que ya te tocan por lo que llevas hecho (para partidas de antes de que existieran).
local function asegurarCompaneros(perfil: any)
	local pr = perfil.progreso
	pr.companeros = pr.companeros or {}
	if (pr.vencidas and pr.vencidas.huerto) or perfil.llaves.cuerda or perfil.nivel >= 3 then
		pr.companeros.tomas = true
	end
	if pr.pelotaEntregada then
		pr.companeros.lucas = true
	end
	if perfil.llaves.llave then
		pr.companeros.fermin = true
	end
	if pr.companero == nil then
		for _, cid in Datos.OrdenCompaneros do
			if pr.companeros[cid] then
				pr.companero = cid
			end
		end
	end
end

--- Manda al cliente su estado (para el HUD, las barreras y los secretos).
local function enviarEstado(j: Player)
	local perfil = DatosJugador.obtener(j)
	if not perfil then
		return
	end
	asegurarCompaneros(perfil)
	-- equipamiento: cada clase empieza con su arma de madera (o de rama, o de junco…)
	local pr = perfil.progreso
	pr.armas = pr.armas or {}
	pr.equipo = pr.equipo or {}
	if perfil.clase and next(pr.armas) == nil and Datos.ArmaInicial[perfil.clase] then
		pr.armas[Datos.ArmaInicial[perfil.clase]] = 0
		pr.equipo.arma = Datos.ArmaInicial[perfil.clase]
	end
	for hueco, id in pr.equipo do
		if not (pr.armas[id] ~= nil and Datos.puedeLlevar(id, perfil.clase)) then
			pr.equipo[hueco] = nil
		end
	end
	j:SetAttribute("FinalVisto", perfil.progreso.final == true)
	j:SetAttribute("Final2Visto", perfil.progreso.final2 == true)
	-- la lista de jugadores de Roblox (arriba a la derecha) enseña el nivel y las victorias
	local stats = j:FindFirstChild("leaderstats")
	if not stats then
		stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		for _, n in { "Nivel", "Victorias" } do
			local v = Instance.new("IntValue")
			v.Name = n
			v.Parent = stats
		end
		stats.Parent = j
	end
	local ls = stats :: any
	ls.Nivel.Value = perfil.nivel
	ls.Victorias.Value = perfil.progreso.victorias or 0
	local hp, maxHp, mp, maxMp = Combate.vidaDe(j)
	-- los clientes dibujan el muñeco 2D de cada jugador según su clase
	j:SetAttribute("Creado", perfil.creado)
	j:SetAttribute("Clase", perfil.clase)
	-- tras los tres años, el héroe tiene barba hasta que pase por el barbero (se dibuja en el muñeco)
	local ap = table.clone(perfil.apariencia)
	ap.barba = perfil.progreso.barba == true
	-- lo que lleva puesto también se ve en el muñeco
	ap.eq = { arma = pr.equipo.arma, armadura = pr.equipo.armadura, amuleto = pr.equipo.amuleto }
	j:SetAttribute("Apariencia", HttpService:JSONEncode(ap))
	j:SetAttribute("NombreHeroe", perfil.nombreHeroe ~= "" and perfil.nombreHeroe or j.DisplayName)
	local _, sinergias = Datos.efectosDe(perfil.mejoras)
	remoto("EstadoJugador"):FireClient(j, {
		clase = perfil.clase,
		nivel = perfil.nivel,
		xp = perfil.xp,
		xpSiguiente = Datos.xpParaNivel(perfil.nivel),
		oro = perfil.oro,
		objetos = perfil.objetos,
		hp = hp,
		maxHp = maxHp,
		mp = mp,
		maxMp = maxMp,
		enBatalla = Combate.enBatalla(j),
		mejoras = perfil.mejoras,
		sinergias = sinergias,
		llaves = perfil.llaves,
		setas = perfil.progreso.setas,
		palancas = perfil.progreso.palancas,
		apariencia = perfil.apariencia,
		ajustes = (perfil :: any).ajustes,
		creado = perfil.creado,
		nombreHeroe = perfil.nombreHeroe,
		final = perfil.progreso.final == true,
		final2 = perfil.progreso.final2 == true,
		barba = perfil.progreso.barba == true,
		afeitado = perfil.progreso.afeitado == true,
		banado = perfil.progreso.banado == true,
		companeros = perfil.progreso.companeros,
		armas = pr.armas,
		equipo = pr.equipo,
		companero = perfil.progreso.companero,
	})
end
Combate.alCambiarJugador = enviarEstado

local function notificar(j: Player, texto: string)
	remoto("Notificar"):FireClient(j, texto)
end

local pista: (any) -> string
local SECRETOS: { [string]: any } = {}
local TOTAL_SECRETOS = 0

-- ===================== DIÁLOGOS =====================
-- dialogo(j, { titulo, texto, quien = { tipo, id }, opciones = { { texto, accion = function() return "respuesta" end } } })
type Opcion = { texto: string, accion: (() -> string?)? }
local pendientes: { [Player]: { id: number, opciones: { Opcion } } } = {}
local siguienteDialogo = 0

local function dialogo(j: Player, d: any)
	siguienteDialogo += 1
	local textos = {}
	for _, o in d.opciones do
		table.insert(textos, o.texto)
	end
	pendientes[j] = { id = siguienteDialogo, opciones = d.opciones }
	remoto("Dialogo"):FireClient(j, { id = siguienteDialogo, titulo = d.titulo, texto = d.texto, quien = d.quien, opciones = textos })
end

--- Un vecino se une a tu equipo (y pasa a ser tu compañero si ibas sin nadie o con uno anterior).
local function reclutar(j: Player, cid: string)
	local perfil = DatosJugador.obtener(j) :: any
	local def = Datos.Companeros[cid]
	if not perfil or not def then
		return
	end
	local pr = perfil.progreso
	pr.companeros = pr.companeros or {}
	if pr.companeros[cid] then
		return
	end
	pr.companeros[cid] = true
	pr.companero = cid
	DatosJugador.guardar(j)
	task.delay(0.8, function()
		if not j.Parent then
			return
		end
		local textos = {
			tomas = "¡Me has salvado las coles! Mira, yo me apunto: si vas a por el Rey Hongo, mi horca va contigo.",
			lucas = "¡Quiero ir contigo! Tengo tirachinas y no me da miedo nada. Bueno, los gatos del callejón un poco.",
			fermin = "Hace años que no salgo de casa… pero alguien tendrá que curarte. Iré contigo, joven.",
		}
		dialogo(j, {
			titulo = def.nombre .. " se une",
			texto = textos[cid] or def.descripcion,
			quien = { "vecino", def.vecino },
			opciones = { { texto = "¡Bienvenido al equipo!" }, { texto = "Prefiero ir solo", accion = function()
				pr.companero = "solo"
				return "Puedes llevarlo cuando quieras desde la mochila (B)."
			end } },
		})
	end)
end

remoto("ElegirCompanero").OnServerEvent:Connect(function(j, cid)
	local perfil = DatosJugador.obtener(j) :: any
	if not perfil or type(cid) ~= "string" or Combate.enBatalla(j) then
		return
	end
	local pr = perfil.progreso
	if cid == "solo" then
		pr.companero = "solo"
		notificar(j, "Irás solo a las peleas")
	elseif Datos.Companeros[cid] and pr.companeros and pr.companeros[cid] then
		pr.companero = cid
		notificar(j, Datos.Companeros[cid].nombre .. " irá contigo")
	else
		return
	end
	DatosJugador.guardar(j)
	enviarEstado(j)
end)

remoto("ElegirOpcion").OnServerEvent:Connect(function(j, id, indice)
	local p = pendientes[j]
	if not p or p.id ~= id or type(indice) ~= "number" then
		return
	end
	pendientes[j] = nil
	local o = p.opciones[indice]
	if o and o.accion then
		local respuesta = o.accion()
		if respuesta then
			notificar(j, respuesta)
		end
	end
	enviarEstado(j)
end)

--- Qué toca hacer ahora (lo dicen la abuela y la lista de objetivos).
pista = function(perfil: any): string
	if not perfil.llaves.cuerda then
		return "Para cruzar el río necesitas una cuerda. Ve a la ciudad (a la derecha), entra en la taberna y gánale a Bruno a los vasos dos veces seguidas."
	elseif not perfil.llaves.hacha then
		return "Ya tienes la cuerda. Cruza el río hasta el Pantano y sube por las tablas: arriba hay un cofre con un hacha."
	elseif not perfil.llaves.llave then
		return "Con el hacha cortas las zarzas del Bosque. El ermitaño Fermín busca 3 setas que brillan: llévaselas y te dará una llave."
	elseif not perfil.llaves.farol then
		return "La llave abre las Ruinas. Tira de las 3 palancas (¡una está arriba!) y abre el cofre de la cripta: dentro hay un farol."
	end
	if not perfil.progreso.final then
		return "¡Ya lo tienes todo! Entra en la Cueva, dale su merecido al Rey Hongo y recupera el Cucharón."
	end
	-- historia 2: tres años después
	if perfil.progreso.barba then
		local falta = {}
		if not perfil.progreso.afeitado then
			table.insert(falta, "ve al barbero Paco de la ciudad")
		end
		if not perfil.progreso.banado then
			table.insert(falta, "date un baño en la posada")
		end
		return "¡Así no puedes pelear, cielo! Con esa barba no ves ni la espada y hueles a guiso de hace tres años. Primero " .. table.concat(falta, " y ") .. "."
	elseif not perfil.llaves.botas then
		return "Han pasado tres años, cielo. El Yeti Tragón se ha llevado la Olla del Gran Guiso a los Picos Nevados. Habla con el Rey Hongo en su cueva: dice que tiene algo para ti."
	elseif not perfil.llaves.pico then
		return "Con las botas cruzas la nieve hasta los Picos Nevados. Junto al lago helado hay un cofre con un pico de hielo… pero unos pingüinos bandidos lo vigilan."
	elseif not perfil.progreso.final2 then
		return "¡Rompe el muro de hielo con el pico y sube a la Cumbre! El Yeti Tragón tiene nuestra Olla."
	end
	return "¡Vael vuelve a tener su Olla! Descansa, héroe… por ahora."
end

local function darLlave(j: Player, llave: string)
	local perfil = DatosJugador.obtener(j)
	if perfil and not perfil.llaves[llave] then
		perfil.llaves[llave] = true
		DatosJugador.guardar(j)
		remoto("Sonido"):FireClient(j, "llave")
		task.delay(0.4, function()
			notificar(j, "¡Conseguido: " .. Datos.Llaves[llave].nombre .. "! " .. Datos.Llaves[llave].descripcion)
		end)
		enviarEstado(j)
	end
end

--- Pelea obligatoria para conseguir un objeto clave: unos guardianes salen y hay que ganarles.
--- Si pierdes, vuelves a intentarlo cuando quieras (el objeto sigue ahí).
local function guardianes(j: Player, titulo: string, texto: string, quien: { string }, batalla: any, x: number, alGanar: (Player) -> ())
	if Combate.enBatalla(j) then
		return
	end
	dialogo(j, {
		titulo = titulo,
		texto = texto,
		quien = quien,
		opciones = {
			{ texto = "¡A pelear!", accion = function()
				if not Combate.enBatalla(j) then
					batalla.guardian = true
					Combate.empezar(batalla, Vector3.new(x, 0, 0), { j }, { emboscada = true, alGanar = alGanar })
				end
				return nil
			end },
			{ texto = "Mejor luego" },
		},
	})
end

-- ===================== JUGADORES =====================
Players.PlayerAdded:Connect(function(j)
	DatosJugador.cargar(j)
	j.CharacterAdded:Connect(function()
		task.wait(0.5)
		enviarEstado(j)
	end)
	task.wait(1)
	enviarEstado(j)
end)
Players.PlayerRemoving:Connect(function(j)
	DatosJugador.soltar(j)
	pendientes[j] = nil
end)

remoto("ElegirClase").OnServerEvent:Connect(function(j, claseId)
	local perfil = DatosJugador.obtener(j)
	if perfil and perfil.clase == nil and type(claseId) == "string" and Datos.Clases[claseId] then
		perfil.clase = claseId
		Combate.curarDelTodo(j)
		DatosJugador.guardar(j)
		enviarEstado(j)
		notificar(j, "¡Bienvenido a Vael, " .. Datos.Clases[claseId].nombre .. "!")
	end
end)

-- personalizar el personaje (el nombre pasa por el filtro de texto de Roblox, obligatorio para que lo vean otros)
remoto("GuardarApariencia").OnServerEvent:Connect(function(j, datos)
	local perfil = DatosJugador.obtener(j)
	if not perfil then
		return
	end
	local ap = Datos.validarApariencia(datos)
	local nombre = ""
	if ap.nombre ~= "" then
		local ok, filtrado = pcall(function()
			return TextService:FilterStringAsync(ap.nombre, j.UserId):GetNonChatStringForBroadcastAsync()
		end)
		nombre = ok and filtrado or ""
	end
	ap.nombre = nombre
	local primeraVez = not perfil.creado
	perfil.apariencia = ap
	perfil.nombreHeroe = nombre
	perfil.creado = true
	if primeraVez then
		task.delay(1.5, function()
			if j.Parent then
				dialogo(j, {
					titulo = "Abuela Rosa",
					texto = "¡Por fin despiertas! El Rey Hongo se ha llevado el Cucharón y sus esporas tienen a todos los bichos rabiosos. Empieza echando las babosas del huerto de Tomás y luego ve a la ciudad. Y llévate la mochila, que hace frío.",
					quien = { "vecino", "1955" },
					opciones = { { texto = "¡Allá voy!" }, { texto = "¿Puedo dormir cinco minutos más?", accion = function()
						return "«¡NO!»"
					end } },
				})
			end
		end)
	end
	DatosJugador.guardar(j)
	enviarEstado(j)
	notificar(j, "¡Qué buena pinta!")
end)

-- final de la historia: al ganar al Rey Hongo se recupera el Cucharón de Vael
Combate.alVencerJefe = function(j: Player, jefeId: string?)
	local perfil = DatosJugador.obtener(j) :: any
	if jefeId == "yeti" then
		if perfil and not perfil.progreso.final2 then
			perfil.progreso.final2 = true
			DatosJugador.guardar(j)
			j:SetAttribute("Final2Visto", true)
			remoto("Final2"):FireClient(j)
			return
		end
		dialogo(j, {
			titulo = "Abuela Rosa",
			texto = "¿Otra vez peleando con el Yeti? Ese pobre ya viene a cenar todos los domingos, cielo.",
			quien = { "vecino", "1955" },
			opciones = { { texto = "Era un entrenamiento" } },
		})
		return
	end
	if perfil and not perfil.progreso.final then
		-- la primera vez: el epílogo (el cliente lo cuenta como el prólogo)
		perfil.progreso.final = true
		-- tres años después: barba y sin bañar (hay que pasar por el barbero y la posada antes de volver a pelear)
		perfil.progreso.barba = true
		perfil.progreso.afeitado = false
		perfil.progreso.banado = false
		perfil.progreso.desperto = false
		DatosJugador.guardar(j)
		j:SetAttribute("FinalVisto", true)
		remoto("Epilogo"):FireClient(j)
		return
	end
	dialogo(j, {
		titulo = "Abuela Rosa",
		texto = "¡Has recuperado el Cucharón de Vael! Esta noche hay Gran Guiso… y este año, sin setas. El Rey Hongo está invitado, eso sí.",
		quien = { "vecino", "1955" },
		opciones = { { texto = "¡A comer!" }, { texto = "¿Y si me pide revancha?", accion = function()
			return "«Pues le ganas otra vez, cielo. La cueva sigue ahí.»"
		end } },
	})
end

-- ===================== ENCARGOS DEL TABLÓN (misiones secundarias) =====================
local function progresoEncargo(perfil: any, e: any): number
	local pr = perfil.progreso
	if e.tipo == "secretos" then
		local n = 0
		for _ in pr.secretos or {} do
			n += 1
		end
		return math.min(n, e.cantidad)
	elseif e.tipo == "entregar" then
		return math.min(perfil.objetos[e.objetivo] or 0, e.cantidad)
	end
	local st = pr.encargos and pr.encargos[e.id]
	return st and math.min(st.n or 0, e.cantidad) or 0
end

local function listaEncargos(perfil: any): any
	local pr = perfil.progreso
	pr.encargos = pr.encargos or {}
	local lista = {}
	for _, id in Datos.OrdenEncargos do
		local e = Datos.Encargos[id]
		local st = pr.encargos[id]
		local estado = "disponible"
		if e.requiere == "final" and not pr.final then
			estado = "bloqueado"
		elseif st and st.estado == "hecha" then
			estado = "hecha"
		elseif st and st.estado == "activa" then
			estado = progresoEncargo(perfil, e) >= e.cantidad and "lista" or "activa"
		end
		table.insert(lista, { id = id, estado = estado, n = progresoEncargo(perfil, e) })
	end
	return lista
end

local function abrirTablon(j: Player, entregado: string?)
	local perfil = DatosJugador.obtener(j)
	if perfil then
		remoto("AbrirTablon"):FireClient(j, { lista = listaEncargos(perfil), entregado = entregado })
	end
end

--- Suma progreso a los encargos activos que encajen (cazar, ganar en una zona, romper rocas…).
local function sumarEncargo(j: Player, tipo: string, objetivo: string?, cantidad: number)
	local perfil = DatosJugador.obtener(j) :: any
	local encargos = perfil and perfil.progreso.encargos
	if not encargos then
		return
	end
	for id, st in encargos do
		local e = Datos.Encargos[id]
		if e and st.estado == "activa" and e.tipo == tipo and (e.objetivo == nil or e.objetivo == objetivo) then
			st.n = math.min(e.cantidad, (st.n or 0) + cantidad)
			if st.n >= e.cantidad and not st.avisado then
				st.avisado = true
				notificar(j, "¡Encargo listo! «" .. e.titulo .. "» · vuelve al tablón de la plaza")
			end
		end
	end
end
Combate.alRomperRoca = function(j: Player)
	sumarEncargo(j, "rocas", nil, 1)
end

remoto("AceptarEncargo").OnServerEvent:Connect(function(j, id)
	local perfil = DatosJugador.obtener(j) :: any
	local e = type(id) == "string" and Datos.Encargos[id]
	if not perfil or not e then
		return
	end
	local pr = perfil.progreso
	pr.encargos = pr.encargos or {}
	if pr.encargos[id] or (e.requiere == "final" and not pr.final) then
		return
	end
	local activos = 0
	for _, st in pr.encargos do
		if st.estado == "activa" then
			activos += 1
		end
	end
	if activos >= Datos.MAX_ENCARGOS then
		notificar(j, "Ya llevas " .. Datos.MAX_ENCARGOS .. " encargos. Termina alguno antes.")
		return
	end
	pr.encargos[id] = { estado = "activa", n = 0 }
	DatosJugador.guardar(j)
	abrirTablon(j)
end)

remoto("EntregarEncargo").OnServerEvent:Connect(function(j, id)
	local perfil = DatosJugador.obtener(j) :: any
	local e = type(id) == "string" and Datos.Encargos[id]
	local st = perfil and e and perfil.progreso.encargos and perfil.progreso.encargos[id]
	if not st or st.estado ~= "activa" or progresoEncargo(perfil, e) < e.cantidad then
		return
	end
	if e.tipo == "entregar" then
		perfil.objetos[e.objetivo] -= e.cantidad
	end
	st.estado = "hecha"
	perfil.oro += e.oro
	perfil.xp += e.xp
	while perfil.xp >= Datos.xpParaNivel(perfil.nivel) do
		perfil.xp -= Datos.xpParaNivel(perfil.nivel)
		perfil.nivel += 1
		notificar(j, "¡Subes a nivel " .. perfil.nivel .. "!")
	end
	if e.objeto then
		perfil.objetos[e.objeto] = (perfil.objetos[e.objeto] or 0) + 1
	end
	if e.mejora then
		Combate.darMejora(j, e.mejora)
	end
	DatosJugador.guardar(j)
	enviarEstado(j)
	abrirTablon(j, id)
end)

-- ===================== ARMERÍA (equipamiento: comprar, mejorar y equipar) =====================
local function abrirArmeria(j: Player, novedad: string?)
	local perfil = DatosJugador.obtener(j) :: any
	if not perfil then
		return
	end
	remoto("AbrirArmeria"):FireClient(j, { oro = perfil.oro, nivel = perfil.nivel, clase = perfil.clase, armas = perfil.progreso.armas or {}, equipo = perfil.progreso.equipo or {}, novedad = novedad })
end

remoto("ComprarEquipo").OnServerEvent:Connect(function(j, id)
	local perfil = DatosJugador.obtener(j) :: any
	local p = type(id) == "string" and Datos.Equipo[id]
	if not perfil or not p or Combate.enBatalla(j) then
		return
	end
	local pr = perfil.progreso
	pr.armas = pr.armas or {}
	pr.equipo = pr.equipo or {}
	if pr.armas[id] ~= nil or not Datos.puedeLlevar(id, perfil.clase) then
		return
	end
	if perfil.nivel < p.nivel then
		notificar(j, "Olga: «Vuelve cuando seas nivel " .. p.nivel .. ". Esto pesa mucho para ti.»")
		return
	end
	if perfil.oro < p.precio then
		notificar(j, "Olga: «Sin oro no hay hierro, chaval.»")
		return
	end
	perfil.oro -= p.precio
	pr.armas[id] = 0
	pr.equipo[p.hueco] = id -- se lo pone directamente
	DatosJugador.guardar(j)
	enviarEstado(j)
	abrirArmeria(j, id)
end)

remoto("MejorarEquipo").OnServerEvent:Connect(function(j, id)
	local perfil = DatosJugador.obtener(j) :: any
	local armas = perfil and perfil.progreso.armas
	if not armas or type(id) ~= "string" or armas[id] == nil or Combate.enBatalla(j) then
		return
	end
	local nivel = armas[id]
	if nivel >= Datos.MAX_MEJORA_EQUIPO then
		return
	end
	local precio = Datos.precioMejora(id, nivel)
	if perfil.oro < precio then
		notificar(j, "Olga: «Para mejorar eso necesito " .. precio .. " de oro.»")
		return
	end
	perfil.oro -= precio
	armas[id] = nivel + 1
	DatosJugador.guardar(j)
	enviarEstado(j)
	abrirArmeria(j, id)
end)

remoto("Equipar").OnServerEvent:Connect(function(j, id)
	local perfil = DatosJugador.obtener(j) :: any
	local p = type(id) == "string" and Datos.Equipo[id]
	if not perfil or not p or Combate.enBatalla(j) then
		return
	end
	local pr = perfil.progreso
	pr.equipo = pr.equipo or {}
	if not (pr.armas and pr.armas[id] ~= nil) or not Datos.puedeLlevar(id, perfil.clase) then
		return
	end
	if pr.equipo[p.hueco] == id then
		pr.equipo[p.hueco] = nil -- quitárselo
	else
		pr.equipo[p.hueco] = id
	end
	DatosJugador.guardar(j)
	enviarEstado(j)
end)

-- ===================== REGALAR, EMOTES Y CLASIFICACIÓN (cooperativo) =====================
--- Regalar a otro jugador del servidor: una poción, un éter o 10 de oro.
remoto("Regalar").OnServerEvent:Connect(function(j, userId, tipo, id)
	local destino = type(userId) == "number" and Players:GetPlayerByUserId(userId)
	if not destino or destino == j or Combate.enBatalla(j) then
		return
	end
	local p1 = DatosJugador.obtener(j) :: any
	local p2 = DatosJugador.obtener(destino) :: any
	if not p1 or not p2 then
		return
	end
	local que = ""
	if tipo == "oro" then
		if p1.oro < 10 then
			notificar(j, "No tienes 10 de oro para regalar.")
			return
		end
		p1.oro -= 10
		p2.oro += 10
		que = "10 de oro"
	elseif tipo == "objeto" and type(id) == "string" and Datos.Objetos[id] and (p1.objetos[id] or 0) > 0 then
		p1.objetos[id] -= 1
		p2.objetos[id] = (p2.objetos[id] or 0) + 1
		que = Datos.Objetos[id].nombre
	else
		return
	end
	DatosJugador.guardar(j)
	DatosJugador.guardar(destino)
	enviarEstado(j)
	enviarEstado(destino)
	notificar(j, "Le has regalado " .. que .. " a " .. destino.DisplayName .. ".")
	notificar(destino, j.DisplayName .. " te ha regalado " .. que .. ". ¡Qué detalle!")
	remoto("Sonido"):FireClient(destino, "moneda")
	remoto("EmoteJugador"):FireAllClients(j.UserId, "regalo")
end)

--- Emotes: el servidor los reparte a todos (con un pequeño freno para que nadie los spamee).
local ultimoEmote: { [Player]: number } = {}
local EMOTES = { saludar = true, bailar = true, reir = true, aplaudir = true, enfado = true, dormir = true, pelea = true }
remoto("Emote").OnServerEvent:Connect(function(j, nombre)
	if type(nombre) ~= "string" or not EMOTES[nombre] or os.clock() < (ultimoEmote[j] or 0) + 1.5 then
		return
	end
	ultimoEmote[j] = os.clock()
	remoto("EmoteJugador"):FireAllClients(j.UserId, nombre)
end)

--- Clasificación: los de este servidor (nivel, victorias y récord de oleadas) y el top 10 de todos los servidores.
local rankingGlobal: { [string]: any } = { lista = {}, hora = 0 }
local almacenRanking: OrderedDataStore? = nil
pcall(function()
	almacenRanking = game:GetService("DataStoreService"):GetOrderedDataStore("VaelVictorias_v1")
end)
local ultimoGuardadoRanking: { [Player]: number } = {}
local function guardarRanking(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	if not almacenRanking or not perfil or os.clock() < (ultimoGuardadoRanking[j] or 0) + 60 then
		return
	end
	ultimoGuardadoRanking[j] = os.clock()
	task.spawn(function()
		pcall(function()
			(almacenRanking :: any):SetAsync(tostring(j.UserId), perfil.progreso.victorias or 0)
		end)
	end)
end
local nombres: { [number]: string } = {}
remoto("PedirClasificacion").OnServerEvent:Connect(function(j)
	local servidor = {}
	for _, otro in Players:GetPlayers() do
		local p = DatosJugador.obtener(otro) :: any
		if p then
			table.insert(servidor, { nombre = otro.DisplayName, nivel = p.nivel, victorias = p.progreso.victorias or 0, oleada = p.progreso.mejorOleada or 0, yo = otro == j })
		end
	end
	table.sort(servidor, function(a, b)
		return a.victorias > b.victorias
	end)
	if almacenRanking and os.clock() - rankingGlobal.hora > 60 then
		rankingGlobal.hora = os.clock()
		pcall(function()
			local pagina = (almacenRanking :: any):GetSortedAsync(false, 10):GetCurrentPage()
			local lista = {}
			for _, fila in pagina do
				local uid = tonumber(fila.key) or 0
				if not nombres[uid] then
					local ok, n = pcall(function()
						return Players:GetNameFromUserIdAsync(uid)
					end)
					nombres[uid] = ok and n or "???"
				end
				table.insert(lista, { nombre = nombres[uid], victorias = fila.value })
			end
			rankingGlobal.lista = lista
		end)
	end
	remoto("Clasificacion"):FireClient(j, { servidor = servidor, global = rankingGlobal.lista })
end)

-- ===================== TRES AÑOS DESPUÉS: BARBA, BARBERO Y BAÑO =====================
--- Cuando ya se ha afeitado y bañado, vuelve a poder pelear.
local function quizaLimpio(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	local pr = perfil and perfil.progreso
	if pr and pr.barba and pr.afeitado and pr.banado then
		pr.barba = nil
		DatosJugador.guardar(j)
		task.delay(1, function()
			if j.Parent then
				dialogo(j, {
					titulo = "Abuela Rosa",
					texto = "¡Ahora sí te reconozco! Guapo, limpio y oliendo a jabón. Ya puedes volver a pelear. El Rey Hongo te espera en su cueva: dice que tiene algo para ti.",
					quien = { "vecino", "1955" },
					opciones = { { texto = "¡Allá voy!" } },
				})
			end
		end)
	end
	enviarEstado(j)
end

remoto("Despertar").OnServerEvent:Connect(function(j)
	local perfil = DatosJugador.obtener(j) :: any
	local pr = perfil and perfil.progreso
	if not pr or not pr.barba or pr.desperto then
		return
	end
	pr.desperto = true
	DatosJugador.guardar(j)
	local ch = j.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if raiz then
		raiz.CFrame = CFrame.new(Mundo.Aparicion, 3.5, 2)
	end
	enviarEstado(j)
	task.delay(1.5, function()
		if j.Parent then
			dialogo(j, {
				titulo = "Abuela Rosa",
				texto = "¡Por fin despiertas! Tres años durmiendo la siesta del guiso… ¡Mírate esa barba! Así no puedes pelear: ni ves la espada y hueles a guiso rancio. Ve al barbero Paco de la ciudad y date un baño en la posada. ¡Y rapidito, que se han llevado la Olla!",
				quien = { "vecino", "1955" },
				opciones = { { texto = "¿Tres años?", accion = function()
					return "«Y roncando todo el rato. Hasta los vecinos se quejaban.»"
				end }, { texto = "Voy al barbero" } },
			})
		end
	end)
end)

-- ===================== SECRETOS (easter eggs) =====================
-- Cada uno da 5 de oro la primera vez; encontrarlos todos regala la Corona de cartón.
SECRETOS = {
	gato = { accion = "Acariciar", titulo = "¿Un gato morado?", quien = { "vecino", "4040" }, texto = "Un gato morado con pañuelo rojo te mira, hace «miau» y suena su cascabel. Juraría que no es de este mundo… Cuando parpadeas, ya no está.", respuesta = "¿Hola…?" },
	puerta = { accion = "Llamar", titulo = "La puerta del NO", quien = { "enemigo", "fantasma" }, texto = "Llamas. Silencio. Luego, una voz desde dentro: «…todavía no.» Y unos ojos amarillos se cierran despacio.", respuesta = "Me voy, me voy" },
	olla = { accion = "Remover", titulo = "La olla del Gran Guiso", quien = { "vecino", "1955" }, texto = "Remueves la olla vacía. Suena a eco… y huele a setas tristes. Sin el Cucharón no hay fiesta.", respuesta = "Lo recuperaré" },
	puertecita = { accion = "Llamar", titulo = "Una puertecita", quien = { "vecino", "999" }, texto = "Una vocecita grita: «¡NO HAY NADIE!» …y alguien desliza unas monedas por debajo de la puerta para que te vayas.", respuesta = "Gracias, nadie" },
	pato = { accion = "Apretar", titulo = "Un pato de goma", quien = { "vecino", "42" }, texto = "¡CUAC! Un pato de goma en mitad del pantano. Alguien lo perdió en la bañera… hace unos 300 años.", respuesta = "Cuac" },
	piedra = { accion = "Escuchar", titulo = "Una piedra con cara", quien = { "enemigo", "golem" }, texto = "La piedra susurra: «Aquí estuvo AEZ». Nadie en Vael sabe qué significa.", respuesta = "Qué misterio" },
	bordeOeste = { accion = "Mirar", titulo = "El fin del cartón", quien = { "vecino", "1" }, texto = "Más allá solo hay mesa, unas tijeras y una mancha de pegamento. Mejor no saltes.", respuesta = "Vuelvo" },
	bordeEste = { accion = "Mirar", titulo = "Se acabó el papel", quien = { "vecino", "2" }, texto = "Aquí el dibujante se quedó sin papel. Dejó una nota: «Continuará… cuando compre más cartulina».", respuesta = "Esperaré" },
}
for _ in SECRETOS do
	TOTAL_SECRETOS += 1
end

-- ===================== MUNDO Y GUARIDAS =====================
local zonas = Mundo.construir()
local ocupada: { [BasePart]: boolean } = {}
local enfriamiento: { [BasePart]: number } = {}

local function jugadorDe(parte: BasePart): Player?
	local modelo = parte:FindFirstAncestorOfClass("Model")
	return modelo and Players:GetPlayerFromCharacter(modelo) or nil
end

local function empezarEn(disco: BasePart, zona: any, j: Player)
	if ocupada[disco] or Combate.enBatalla(j) then
		return
	end
	-- el equipo: quien lo pisa y los jugadores cercanos que no estén luchando
	local equipo = { j }
	for _, otro in Players:GetPlayers() do
		if otro ~= j and #equipo < Datos.MAX_EQUIPO and not Combate.enBatalla(otro) then
			local p = DatosJugador.obtener(otro)
			local ch = otro.Character
			if p and p.clase and ch and ch.PrimaryPart and (ch.PrimaryPart.Position - disco.Position).Magnitude < 45 then
				table.insert(equipo, otro)
			end
		end
	end
	ocupada[disco] = true
	disco:SetAttribute("Ocupada", true)
	local b = Combate.empezar(zona, disco.Position - Vector3.new(0, disco.Position.Y, 0), equipo)
	if not b then
		ocupada[disco] = false
		disco:SetAttribute("Ocupada", false)
	end
end

-- si ya ganaste en esa guarida, antes de repetir la pelea se pregunta (así no se repite sin querer)
local noPreguntar: { [Player]: number } = {}
Players.PlayerRemoving:Connect(function(j)
	noPreguntar[j] = nil
end)
for disco, zona in zonas do
	disco.Touched:Connect(function(toca)
		local j = jugadorDe(toca)
		if not j or ocupada[disco] or os.clock() < (enfriamiento[disco] or 0) or Combate.enBatalla(j) then
			return
		end
		local perfil = DatosJugador.obtener(j) :: any
		if not perfil or not perfil.clase then
			notificar(j, "Elige tu clase primero")
			return
		end
		local vencidas = perfil.progreso.vencidas
		if vencidas and vencidas[zona.id] then
			if os.clock() < (noPreguntar[j] or 0) or j:GetAttribute("Preguntando") then
				return
			end
			j:SetAttribute("Preguntando", true)
			noPreguntar[j] = os.clock() + 8
			local primero = zona.grupos[1] and zona.grupos[1][1] or "babosa"
			dialogo(j, {
				titulo = zona.nombre,
				texto = "Ya limpiaste esta guarida. ¿Quieres repetir la pelea?",
				quien = { "enemigo", primero },
				opciones = {
					{ texto = "Sí", accion = function()
						j:SetAttribute("Preguntando", false)
						empezarEn(disco, zona, j)
						return nil
					end },
					{ texto = "No", accion = function()
						j:SetAttribute("Preguntando", false)
						noPreguntar[j] = os.clock() + 10
						return nil
					end },
				},
			})
			-- por si cierra el diálogo sin elegir
			task.delay(20, function()
				if j.Parent then
					j:SetAttribute("Preguntando", false)
				end
			end)
			return
		end
		empezarEn(disco, zona, j)
	end)
end

local mazmorraFin: ((any) -> ())? = nil
Combate.alTerminar = function(b)
	if b.zona and b.zona.mazmorra and mazmorraFin then
		task.spawn(mazmorraFin :: any, b)
	end
	if b.victoria then
		for _, e in b.aliados do
			local j = e.jugador
			local perfil = j and DatosJugador.obtener(j) :: any
			if j and perfil then
				local pr0 = perfil.progreso
				pr0.victorias = (pr0.victorias or 0) + 1
				if guardarRanking then
					guardarRanking(j)
				end
				-- encargos: cada monstruo vencido y cada pelea ganada en una zona
				for _, en in b.enemigos do
					if en.enemigoId then
						sumarEncargo(j, "cazar", en.enemigoId, 1)
					end
				end
				sumarEncargo(j, "zona", b.zona.id, 1)
				local pr = perfil.progreso
				pr.vencidas = pr.vencidas or {}
				local primera = not pr.vencidas[b.zona.id]
				if not b.zona.guardian then
					pr.vencidas[b.zona.id] = true
				end
				-- Tomás se une al echar a las babosas de su huerto
				if primera and b.zona.id == "huerto" then
					task.delay(3, function()
						reclutar(j, "tomas")
					end)
				end
				-- ganar en tu guarida evita que te pregunte justo al acabar (sigues encima del círculo)
				noPreguntar[j] = os.clock() + 6
			end
		end
	end
	for disco, zona in zonas do
		if zona == b.zona and ocupada[disco] then
			ocupada[disco] = false
			enfriamiento[disco] = os.clock() + 5
			disco:SetAttribute("Ocupada", false)
		end
	end
end

-- ===================== PUNTOS CON LOS QUE SE INTERACTÚA =====================
local mundo = workspace:WaitForChild("MundoVael")
local ultimaFuente: { [Player]: number } = {}

local function aviso(parte: BasePart, accion: string, objeto: string, alPulsar: (Player) -> (), distancia: number?)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Style = Enum.ProximityPromptStyle.Custom -- lo dibuja el cliente (Interaccion.luau)
	prompt.ActionText = accion
	prompt.ObjectText = objeto
	prompt.MaxActivationDistance = distancia or 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = parte
	prompt.Triggered:Connect(function(j)
		local perfil = DatosJugador.obtener(j)
		if not perfil or not perfil.clase or Combate.enBatalla(j) then
			return
		end
		alPulsar(j)
	end)
end

local function teletransportar(j: Player, pos: Vector3)
	local ch = j.Character
	local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if raiz then
		remoto("Teletransporte"):FireClient(j, pos)
		-- con StreamingEnabled, que llegue el suelo antes de mover al jugador
		pcall(function()
			j:RequestStreamAroundAsync(pos, 3)
		end)
		task.wait(0.35)
		raiz.CFrame = CFrame.new(pos)
	end
end

-- ===================== MAZMORRA DE OLEADAS: LAS BODEGAS DEL GRAN GUISO (cooperativo, hasta 4) =====================
-- Alguien pulsa la trampilla de la plaza → 10 s de sala de espera (los demás se apuntan con la trampilla) →
-- todos bajan → 5 oleadas seguidas (con un respiro entre ellas). Si caen todos, se acaba. Si ganan la 5.ª, premio gordo.
local OLEADAS = {
	{ "babosa", "hongo", "babosa" },
	{ "lobo", "abeja", "abeja" },
	{ "rana", "planta", "fantasma" },
	{ "esqueleto", "esqueleto", "murcielago", "duende" },
	{ "golem", "tronco", "mimico" },
}
local OLEADAS_DIFICILES = { -- tras la primera historia, las bodegas se llenan de bichos del frío
	{ "pinguino", "hongo", "pinguino" },
	{ "loboBlanco", "abeja", "lobo" },
	{ "espiritu", "planta", "fantasma" },
	{ "esqueleto", "munecoNieve", "murcielago", "pinguino" },
	{ "golem", "munecoNieve", "loboBlanco", "mimico" },
}
type Expedicion = { id: number, jugadores: { Player }, oleada: number, dificil: boolean }
local esperaMazmorra: { jugadores: { Player }, hasta: number }? = nil
local expediciones: { [number]: Expedicion } = {}
local siguienteExpedicion = 0

local function enExpedicion(j: Player): boolean
	for _, ex in expediciones do
		if table.find(ex.jugadores, j) then
			return true
		end
	end
	return false
end

local function puedeBajar(j: Player): boolean
	local perfil = DatosJugador.obtener(j) :: any
	return j.Parent ~= nil and perfil ~= nil and perfil.clase ~= nil and not perfil.progreso.barba and not Combate.enBatalla(j) and not enExpedicion(j)
end

local function lanzarOleada(ex: Expedicion)
	local vivos = {}
	for _, j in ex.jugadores do
		if j.Parent and not Combate.enBatalla(j) then
			table.insert(vivos, j)
		end
	end
	if #vivos == 0 then
		expediciones[ex.id] = nil
		return
	end
	local grupo = (ex.dificil and OLEADAS_DIFICILES or OLEADAS)[ex.oleada]
	for _, j in vivos do
		notificar(j, "¡Oleada " .. ex.oleada .. " de " .. #OLEADAS .. "!")
	end
	local zona = { id = "ruinas", mazmorra = ex.id, nombre = "Bodegas · oleada " .. ex.oleada .. "/" .. #OLEADAS, nivel = 3 + ex.oleada, grupos = { grupo }, color = Color3.fromRGB(150, 110, 80) }
	local b = Combate.empezar(zona, Mundo.Mazmorra.centro, vivos, { altura = Mundo.Mazmorra.centro.Y })
	if not b then
		expediciones[ex.id] = nil
	end
end

local function empezarExpedicion(lista: { Player })
	local jugadores = {}
	for _, j in lista do
		if puedeBajar(j) and #jugadores < Datos.MAX_EQUIPO then
			table.insert(jugadores, j)
		end
	end
	if #jugadores == 0 then
		return
	end
	siguienteExpedicion += 1
	local dificil = false
	for _, j in jugadores do
		local perfil = DatosJugador.obtener(j) :: any
		if perfil and perfil.progreso.final then
			dificil = true
		end
	end
	local ex: Expedicion = { id = siguienteExpedicion, jugadores = jugadores, oleada = 1, dificil = dificil }
	expediciones[ex.id] = ex
	for k, j in jugadores do
		task.spawn(teletransportar, j, Mundo.Mazmorra.entrada + Vector3.new(k * 2.5, 0, 0))
	end
	task.wait(2.5)
	lanzarOleada(ex)
end

--- Al acabar cada pelea de la mazmorra: siguiente oleada, premio final o fin de la expedición.
mazmorraFin = function(b: any)
	local ex = expediciones[b.zona.mazmorra]
	if not ex then
		return
	end
	if not b.victoria then
		for _, j in ex.jugadores do
			if j.Parent then
				local perfil = DatosJugador.obtener(j) :: any
				local llegada = ex.oleada - 1
				if perfil and llegada > (perfil.progreso.mejorOleada or 0) then
					perfil.progreso.mejorOleada = llegada
					DatosJugador.guardar(j)
				end
				notificar(j, "Las Bodegas os echan a escobazos… Llegasteis a la oleada " .. ex.oleada .. ".")
			end
		end
		expediciones[ex.id] = nil
		return
	end
	if ex.oleada >= #OLEADAS then
		-- ¡las 5 oleadas!
		task.wait(3)
		for _, j in ex.jugadores do
			local perfil = j.Parent and DatosJugador.obtener(j) :: any
			if perfil then
				perfil.oro += 150
				perfil.progreso.mejorOleada = #OLEADAS
				perfil.progreso.bodegas = (perfil.progreso.bodegas or 0) + 1
				DatosJugador.guardar(j)
				enviarEstado(j)
				notificar(j, "¡Bodegas limpias! +150 de oro y un cofre de mejoras para cada uno.")
				Combate.ofrecerMejoras(j, "jefe")
			end
		end
		expediciones[ex.id] = nil
		task.wait(8)
		for _, j in ex.jugadores do
			if j.Parent and not Combate.enBatalla(j) then
				task.spawn(teletransportar, j, Mundo.Mazmorra.salida)
			end
		end
		return
	end
	-- respiro: cada uno recupera un 35 % de vida y maná
	ex.oleada += 1
	for _, j in ex.jugadores do
		if j.Parent then
			local hp, maxHp, mp, maxMp = Combate.vidaDe(j)
			Combate.ponerVida(j, math.min(maxHp, hp + math.floor(maxHp * 0.35)), math.min(maxMp, mp + math.floor(maxMp * 0.35)))
			enviarEstado(j)
			notificar(j, "Un respiro… La siguiente oleada llega en 6 segundos.")
		end
	end
	task.wait(6)
	if expediciones[ex.id] then
		lanzarOleada(ex)
	end
end

--- La trampilla: abre (o se une a) la sala de espera.
local function apuntarseMazmorra(j: Player)
	if not puedeBajar(j) then
		local perfil = DatosJugador.obtener(j) :: any
		notificar(j, perfil and perfil.progreso.barba and "¡Con esa barba no bajas ni a por vino! Primero el barbero." or "Ahora no puedes bajar.")
		return
	end
	if esperaMazmorra then
		local espera = esperaMazmorra :: any
		if table.find(espera.jugadores, j) then
			notificar(j, "Ya estás en la sala de espera.")
		elseif #espera.jugadores >= Datos.MAX_EQUIPO then
			notificar(j, "Ya hay " .. Datos.MAX_EQUIPO .. " valientes. Espera a la próxima.")
		else
			table.insert(espera.jugadores, j)
			for _, otro in espera.jugadores do
				notificar(otro, j.DisplayName .. " se apunta a las Bodegas (" .. #espera.jugadores .. "/" .. Datos.MAX_EQUIPO .. ")")
			end
		end
		return
	end
	local espera = { jugadores = { j }, hasta = os.clock() + 10 }
	esperaMazmorra = espera
	for _, otro in Players:GetPlayers() do
		notificar(otro, j.DisplayName .. " baja a las Bodegas del Gran Guiso. ¡Pulsa E en la trampilla de la plaza para unirte! (10 s)")
	end
	task.delay(10, function()
		if esperaMazmorra == espera then
			esperaMazmorra = nil
			empezarExpedicion(espera.jugadores)
		end
	end)
end

local VASOS_FRASES = { "¡Ja! Otra vez será.", "El vaso de la izquierda… o no.", "Mis manos son más rápidas que tus ojos." }
local partidasVasos: { [Player]: { ganador: number, cambios: { { number } } } } = {}

local function tabernero(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	dialogo(j, {
		titulo = "Bruno, el tabernero",
		texto = perfil.llaves.cuerda and "¡Mi campeón de los vasos! ¿Qué te pongo?" or "Bienvenido a El Hongo Feliz. Si me ganas a los vasos dos veces seguidas, te doy mi cuerda de la suerte.",
		quien = { "vecino", "1984" },
		opciones = {
			{ texto = "Jugar a los vasos (5 oro)", accion = function()
				if perfil.oro < 5 then
					return "«Sin oro no hay vasos, amigo.»"
				end
				perfil.oro -= 5
				local r = Random.new()
				local ganador = r:NextInteger(1, 3)
				local cambios = {}
				for _ = 1, 7 + math.min(4, perfil.progreso.racha or 0) * 2 do
					local a = r:NextInteger(1, 3)
					local b = (a % 3) + 1
					table.insert(cambios, { a, b })
				end
				partidasVasos[j] = { ganador = ganador, cambios = cambios }
				remoto("Vasos"):FireClient(j, { ganador = ganador, cambios = cambios, velocidad = 0.32 - math.min(0.12, (perfil.progreso.racha or 0) * 0.05) })
				return nil
			end },
			{ texto = "Comer un guiso (8 oro, cura)", accion = function()
				if perfil.oro < 8 then
					return "«El guiso no es gratis, eh.»"
				end
				perfil.oro -= 8
				local _, maxHp, mp, maxMp = Combate.vidaDe(j)
				Combate.ponerVida(j, maxHp, math.min(maxMp, mp + math.floor(maxMp * 0.5)))
				return "Ñam. Sabe a hongo feliz. Vida al máximo."
			end },
			{ texto = "Escuchar rumores", accion = function()
				local rumores = {
					"Dicen que en el Pantano hay un cofre en lo alto de unas tablas.",
					"El ermitaño del Bosque colecciona setas que brillan. Raro, ¿eh?",
					"En las Ruinas hay tres palancas. Una está donde nadie mira: arriba.",
					"Sin farol no se entra en la cueva. Lo sé porque lo intenté.",
					"Un vendedor con gafas de sol aparece y desaparece. No le compres calcetines.",
				}
				return rumores[math.random(1, #rumores)]
			end },
			{ texto = "Adiós" },
		},
	})
end

remoto("ElegirVaso").OnServerEvent:Connect(function(j, vaso)
	local p = partidasVasos[j]
	local perfil = DatosJugador.obtener(j)
	if not p or not perfil or type(vaso) ~= "number" then
		return
	end
	partidasVasos[j] = nil
	-- dónde acaba la bola tras los cambios
	local pos = p.ganador
	for _, c in p.cambios do
		if pos == c[1] then
			pos = c[2]
		elseif pos == c[2] then
			pos = c[1]
		end
	end
	if vaso == pos then
		perfil.progreso.racha = (perfil.progreso.racha or 0) + 1
		perfil.oro += 12
		notificar(j, "¡Acertaste! +12 de oro. Racha: " .. perfil.progreso.racha)
		if perfil.progreso.racha >= 2 and not perfil.llaves.cuerda then
			task.delay(1.2, function()
				guardianes(j, "Tabernero Bruno", "Vale, vale… te la has ganado. La cuerda está en mi almacén de atrás… pero se ha llenado de babosas. Si las echas, es tuya.", { "vecino", "1984" },
					{ id = "pradera", nombre = "El almacén de Bruno", nivel = 2, grupos = { { "babosa", "babosa", "hongo", "babosa" } }, color = Color3.fromRGB(120, 190, 80) }, -100,
					function(g)
						notificar(g, "Bruno: «¡Mi almacén está limpio! Toma, la cuerda.»")
						darLlave(g, "cuerda")
					end)
			end)
		end
	else
		perfil.progreso.racha = 0
		notificar(j, "Bruno: «" .. VASOS_FRASES[math.random(1, #VASOS_FRASES)] .. "»")
	end
	enviarEstado(j)
end)

local function ermitano(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	local n = #perfil.progreso.setas
	if perfil.llaves.llave then
		dialogo(j, { titulo = "Ermitaño Fermín", texto = "Mis setas brillan de felicidad. Que la llave te sirva, joven.", quien = { "vecino", "60606" }, opciones = { { texto = "Gracias, Fermín" } } })
	elseif n >= 3 then
		dialogo(j, {
			titulo = "Ermitaño Fermín",
			texto = "¡Mis tres setas brillantes! Gracias, joven. Con ellas te daré la llave de piedra de las Ruinas… Espera. ¿Qué es ese ruido?",
			quien = { "vecino", "60606" },
			opciones = { { texto = "¡De nada!", accion = function()
				-- unos duendes le han seguido para robar las setas: pelea antes de la llave
				task.delay(0.6, function()
					guardianes(j, "¡Duendes ladrones!", "¡Unos duendes te han seguido hasta aquí para robar las setas brillantes! Fermín se esconde detrás de ti. «¡Defiéndelas, joven!»", { "enemigo", "duende" },
						{ id = "bosque", nombre = "¡Duendes ladrones!", nivel = 4, grupos = { { "duende", "duende", "arana" } }, color = Color3.fromRGB(150, 180, 70) }, 329,
						function(g)
							notificar(g, "Fermín: «¡Gracias! Toma, la llave de piedra.»")
							darLlave(g, "llave")
							reclutar(g, "fermin")
						end)
				end)
				return nil
			end } },
		})
	else
		dialogo(j, {
			titulo = "Ermitaño Fermín",
			texto = "Perdí mis 3 setas brillantes por el Bosque. Una está escondida detrás de los arbustos, otra en lo alto de las tablas… y la otra, a saber. Llevas " .. n .. " de 3.",
			quien = { "vecino", "60606" },
			opciones = { { texto = "Las buscaré" }, { texto = "¿Por qué brillan?", accion = function()
				return "«No preguntes. Simplemente brillan.»"
			end } },
		})
	end
end

local HERRERO_STOCK = { "cuerno", "pan", "botas", "muelles" }
local function herrero(j: Player)
	local perfil = DatosJugador.obtener(j) :: any
	local lista = {}
	for _, id in HERRERO_STOCK do
		local m = Datos.Mejoras[id]
		local cuantos = 0
		for _, x in perfil.mejoras do
			if x == id then
				cuantos += 1
			end
		end
		table.insert(lista, { id = id, nombre = m.nombre, descripcion = m.descripcion, rareza = m.rareza, precio = Datos.PrecioRareza[m.rareza] + cuantos * 40, vendido = cuantos >= 3 })
	end
	remoto("AbrirVendedor"):FireClient(j, { titulo = "Herrería de Olga", frase = "Lo que forjo, dura. Lo que vendo, se paga.", lista = lista, origen = "herrero" })
end

remoto("ComprarMejora").OnServerEvent:Connect(function(j, origen, id)
	if type(id) ~= "string" or not Datos.Mejoras[id] or Combate.enBatalla(j) then
		return
	end
	if origen == "herrero" then
		local perfil = DatosJugador.obtener(j)
		if not perfil or not table.find(HERRERO_STOCK, id) then
			return
		end
		local cuantos = 0
		for _, x in perfil.mejoras do
			if x == id then
				cuantos += 1
			end
		end
		local precio = Datos.PrecioRareza[Datos.Mejoras[id].rareza] + cuantos * 40
		if cuantos >= 3 then
			notificar(j, "Olga: «De eso ya no te queda sitio.»")
		elseif perfil.oro < precio then
			notificar(j, "Olga: «Vuelve cuando tengas " .. precio .. " de oro.»")
		else
			perfil.oro -= precio
			Combate.darMejora(j, id)
			herrero(j)
		end
		enviarEstado(j)
	elseif origen == "vendedor" then
		Eventos.comprar(j, id)
	end
end)

for _, d in mundo:GetDescendants() do
	if not d:IsA("BasePart") then
		continue
	end
	local p = d :: BasePart
	if p:GetAttribute("Fuente") then
		p.Touched:Connect(function(toca)
			local j = jugadorDe(toca)
			if j and not Combate.enBatalla(j) and os.clock() > (ultimaFuente[j] or 0) then
				ultimaFuente[j] = os.clock() + 3
				Combate.curarDelTodo(j)
				enviarEstado(j)
				notificar(j, "La fuente te cura del todo")
			end
		end)
	end
	if p:GetAttribute("Mercader") then
		aviso(p, "Comprar", "Mercader", function(j)
			local lista = {}
			for _, oid in Datos.OrdenObjetos do
				local o = Datos.Objetos[oid]
				table.insert(lista, { id = oid, nombre = o.nombre, descripcion = o.descripcion, precio = o.precio })
			end
			remoto("AbrirTienda"):FireClient(j, lista)
		end)
	end
	local nombre = p:GetAttribute("Punto")
	if nombre == "entrarTaberna" then
		aviso(p, "Entrar", "Taberna El Hongo Feliz", function(j)
			teletransportar(j, Mundo.Taberna.entrada)
		end)
	elseif nombre == "salirTaberna" then
		aviso(p, "Salir", "Puerta", function(j)
			teletransportar(j, Mundo.Taberna.salida)
		end)
	elseif nombre == "tabernero" then
		p:SetAttribute("Npc", "vecino:1984")
		p:SetAttribute("Frases", "¡Pasa, pasa!|¿Unos vasos?|El guiso de hoy lleva… cosas.")
		aviso(p, "Hablar", "Bruno, el tabernero", tabernero)
	elseif nombre == "ermitano" then
		p:SetAttribute("Npc", "vecino:60606")
		p:SetAttribute("Frases", "Mis setas…|¿Has visto algo que brille?")
		aviso(p, "Hablar", "Ermitaño Fermín", ermitano)
	elseif nombre == "herrero" then
		p:SetAttribute("Npc", "vecino:5150")
		p:SetAttribute("Frases", "¡CLANG! ¡CLANG!|Mejoras de hierro, a buen precio.")
		aviso(p, "Comprar", "Herrería de Olga", function(j)
			dialogo(j, {
				titulo = "Herrera Olga",
				texto = "¿Qué buscas? Tengo armas, armaduras y amuletos… y unas cuantas rarezas para los valientes. También mejoro lo tuyo, si traes oro.",
				quien = { "vecino", "5150" },
				opciones = {
					{ texto = "Armas y armaduras", accion = function()
						abrirArmeria(j)
						return nil
					end },
					{ texto = "Rarezas (mejoras)", accion = function()
						herrero(j)
						return nil
					end },
					{ texto = "Solo miraba" },
				},
			})
		end)
	elseif nombre == "irMercado" or nombre == "irCallejon" then
		local destino = nombre == "irMercado" and "mercado" or "callejon"
		aviso(p, "Entrar", destino == "mercado" and "Calle del Mercado" or "Callejón del Gato", function(j)
			teletransportar(j, Mundo.Calles[destino].entrada)
		end)
	elseif nombre == "volverPlaza" then
		local calle = p:GetAttribute("Calle") :: string
		aviso(p, "Volver", "Plaza de Vael", function(j)
			teletransportar(j, Mundo.Calles[calle].salida)
		end)
	elseif nombre == "tendero" then
		aviso(p, "Hablar", "Frutero Paco", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Frutero Paco",
				texto = "¡Manzanas de cartón piedra, las mejores de Vael! Curan un montón. Y no engordan, porque no se pueden comer… es broma, sí se pueden.",
				quien = { "vecino", "7070" },
				opciones = {
					{ texto = "Comprar una manzana (6 oro)", accion = function()
						if perfil.oro < 6 then
							return "«Sin oro no hay manzana, colega.»"
						end
						perfil.oro -= 6
						local hp, maxHp, mp = Combate.vidaDe(j)
						Combate.ponerVida(j, math.min(maxHp, hp + math.floor(maxHp * 0.35)), mp)
						return "Crunch. Recuperas vida."
					end },
					{ texto = "Adiós" },
				},
			})
		end)
	elseif nombre == "sastre" then
		aviso(p, "Hablar", "Sastre Benito", function(j)
			dialogo(j, {
				titulo = "Sastre Benito",
				texto = "¿Ese look? Mmm… valiente. ¿Quieres que te lo arregle? Hoy cambiar de pinta sale gratis.",
				quien = { "vecino", "6262" },
				opciones = {
					{ texto = "¡Cámbiame el look!", accion = function()
						remoto("AbrirEditor"):FireClient(j)
						return nil
					end },
					{ texto = "Así estoy perfecto" },
				},
			})
		end)
	elseif nombre == "nino" then
		aviso(p, "Hablar", "Niño Lucas", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			local pr = perfil.progreso
			if pr.pelotaEntregada then
				dialogo(j, { titulo = "Niño Lucas", texto = "¡Gracias por mi pelota! Ahora juego todos los días. Bueno, cuando no hay monstruos.", quien = { "vecino", "5" }, opciones = { { texto = "De nada" } } })
			elseif pr.pelota then
				dialogo(j, {
					titulo = "Niño Lucas",
					texto = "¡MI PELOTA! ¡La encontraste en el Callejón! Toma, mi moneda de chocolate de la suerte. Y 40 de oro de mi hucha.",
					quien = { "vecino", "5" },
					opciones = { { texto = "¡Gracias, Lucas!", accion = function()
						pr.pelotaEntregada = true
						perfil.oro += 40
						Combate.darMejora(j, "chocolate")
						reclutar(j, "lucas")
						return nil
					end } },
				})
			else
				dialogo(j, { titulo = "Niño Lucas", texto = "Se me fue la pelota al Callejón del Gato y me da miedo entrar. ¿Me la traes? Está en un cofre al fondo.", quien = { "vecino", "5" }, opciones = { { texto = "¡Yo te la traigo!" } } })
			end
		end)
	elseif nombre == "adivina" then
		aviso(p, "Hablar", "Madame Zoé", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Madame Zoé",
				texto = "Acércate, acércate… Por 5 monedas leo tu destino en una bola de cristal. (Es una pecera.)",
				quien = { "vecino", "1313" },
				opciones = {
					{ texto = "Leer mi destino (5 oro)", accion = function()
						if perfil.oro < 5 then
							return "«El destino no fía, cariño.»"
						end
						perfil.oro -= 5
						local destinos = {
							"Veo… que pronto lucharás contra algo viscoso. Lleva pañuelos.",
							"Las estrellas dicen que empujar monstruos contra rocas te traerá alegría.",
							"Veo un cofre… con dientes. No lo abras con la mano buena.",
							"Tu número de la suerte es el 3. Como las palancas de las Ruinas. Qué casualidad.",
							"Veo… veo… " .. pista(perfil),
						}
						return "Madame Zoé: «" .. destinos[math.random(1, #destinos)] .. "»"
					end },
					{ texto = "No creo en estas cosas" },
				},
			})
		end)
	elseif nombre == "reyHongoNpc" then
		aviso(p, "Hablar", "Rey Hongo", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if not perfil.progreso.final then
				dialogo(j, { titulo = "Rey Hongo", texto = "¡¿Quién osa molestar al REY?! Si quieres hablar, primero tendrás que ganarme en mi guarida.", quien = { "enemigo", "reyHongo" }, opciones = { { texto = "Ya nos veremos" } } })
			elseif not perfil.llaves.botas then
				dialogo(j, {
					titulo = "Rey Hongo",
					texto = "¡Héroe! Cuánto tiempo… Ahora soy el cocinero oficial de la fiesta (sin setas, prometido). Pero el Yeti Tragón bajó de los Picos y se llevó la Olla del Gran Guiso. Toma mis botas de nieve: sin ellas no cruzas ni un metro.",
					quien = { "enemigo", "reyHongo" },
					opciones = { { texto = "¡Gracias, Majestad!", accion = function()
						darLlave(j, "botas")
						return nil
					end } },
				})
			else
				dialogo(j, { titulo = "Rey Hongo", texto = "Tráeme esa Olla, que tengo un guiso de calabaza pendiente. ¡Y abrígate!", quien = { "enemigo", "reyHongo" }, opciones = { { texto = "Voy" } } })
			end
		end)
	elseif nombre == "cofrePico" then
		aviso(p, "Abrir", "Cofre helado", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if perfil.llaves.pico then
				notificar(j, "Vacío. Solo hay un pez congelado que te mira mal.")
			else
				guardianes(j, "¡Pingüinos bandidos!", "Unos pingüinos con antifaz rodean el cofre. «La bolsa o el pez. Y este cofre es nuestro.»", { "enemigo", "pinguino" },
					{ id = "cueva", nombre = "Los pingüinos bandidos", nivel = 8, grupos = { { "pinguino", "pinguino", "munecoNieve" } }, color = Color3.fromRGB(200, 225, 245) }, 690,
					function(g)
						darLlave(g, "pico")
					end)
			end
		end, 7)
	elseif nombre == "barbero" then
		aviso(p, "Hablar", "Barbero Paco", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			local pr = perfil.progreso
			if pr.barba and not pr.afeitado then
				dialogo(j, {
					titulo = "Barbero Paco",
					texto = "¡Madre mía! ¿Eso es una barba o un nido de pájaros? Siéntate, siéntate… Esto va a llevar un rato.",
					quien = { "vecino", "8080" },
					opciones = { { texto = "Adelante", accion = function()
						pr.afeitado = true
						remoto("Teletransporte"):FireClient(j, nil, "Chas, chas, chas…")
						remoto("Sonido"):FireClient(j, "mejora")
						task.delay(1.5, function()
							notificar(j, "¡Afeitado! Has encontrado dos lápices y una seta dentro de la barba.")
							quizaLimpio(j)
						end)
						return nil
					end } },
				})
			else
				dialogo(j, { titulo = "Barbero Paco", texto = "¿Un repaso? Vuelve cuando tengas pelo de sobra. ¡Ese corte te queda de héroe!", quien = { "vecino", "8080" }, opciones = { { texto = "Gracias, Paco" } } })
			end
		end)
	elseif nombre == "banera" then
		aviso(p, "Bañarse", "Bañera", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			local pr = perfil.progreso
			if pr.barba and not pr.banado then
				pr.banado = true
				remoto("Teletransporte"):FireClient(j, nil, "Glu, glu, glu…")
				remoto("Sonido"):FireClient(j, "cura")
				task.delay(1.5, function()
					notificar(j, "¡Qué gusto! El agua ha salido marrón. La posadera Lola dice que vas a pagar la bañera nueva.")
					quizaLimpio(j)
				end)
			else
				notificar(j, "Ya estás limpio como una patena.")
			end
		end, 7)
	elseif nombre == "tablon" then
		aviso(p, "Ver encargos", "Tablón", function(j)
			abrirTablon(j)
		end)
	elseif nombre == "secreto" then
		local id = p:GetAttribute("Secreto") :: string
		local d = SECRETOS[id]
		if d then
			aviso(p, d.accion, "¿?", function(j)
				local perfil = DatosJugador.obtener(j) :: any
				local pr = perfil.progreso
				pr.secretos = pr.secretos or {}
				local nuevo = not pr.secretos[id]
				local texto = d.texto
				if id == "olla" and pr.final then
					texto = "La olla huele a Gran Guiso del bueno. Alguien ha dejado un cuenco para ti… y te cura del todo."
					Combate.curarDelTodo(j)
				end
				dialogo(j, { titulo = d.titulo, texto = texto, quien = d.quien, opciones = { { texto = d.respuesta or "Vale…" } } })
				if nuevo then
					pr.secretos[id] = true
					local n = 0
					for _ in pr.secretos do
						n += 1
					end
					perfil.oro += 5
					remoto("Sonido"):FireClient(j, "mejora")
					notificar(j, "¡Secreto encontrado! " .. n .. "/" .. TOTAL_SECRETOS .. " · +5 de oro")
					if n >= TOTAL_SECRETOS then
						task.delay(4, function()
							if j.Parent then
								Combate.darMejora(j, "corona")
								notificar(j, "¡Todos los secretos! Te ganas la Corona de cartón")
								enviarEstado(j)
							end
						end)
					end
					DatosJugador.guardar(j)
					enviarEstado(j)
				end
			end, 7)
		end
	elseif nombre == "cofreMercado" or nombre == "cofreCallejon" then
		aviso(p, "Abrir", "Cofre", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			local pr = perfil.progreso
			pr.cofres = pr.cofres or {}
			if pr.cofres[nombre] then
				notificar(j, "Está vacío. Solo hay una pelusa.")
				return
			end
			pr.cofres[nombre] = true
			remoto("Sonido"):FireClient(j, "cofre")
			if nombre == "cofreMercado" then
				perfil.oro += 30
				notificar(j, "¡30 de oro escondidos detrás de los puestos!")
			else
				pr.pelota = true
				Combate.darMejora(j, "pluma")
				notificar(j, "Dentro hay una pelota… y una pluma de gallina. Lucas estará contento.")
			end
			DatosJugador.guardar(j)
			enviarEstado(j)
		end, 6)
	elseif nombre == "posada" then
		aviso(p, "Entrar", "Posada El Ronquido", function(j)
			teletransportar(j, Mundo.Posada.entrada)
		end)
	elseif nombre == "mazmorra" then
		aviso(p, "Bajar", "Bodegas del Gran Guiso", function(j)
			if esperaMazmorra then
				apuntarseMazmorra(j)
				return
			end
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Bodegas del Gran Guiso",
				texto = "Una trampilla bajo la plaza. Huele a guiso de hace cien años… y algo se mueve ahí abajo. 5 oleadas de monstruos, hasta 4 valientes. Récord: oleada " .. tostring(perfil.progreso.mejorOleada or 0) .. ".",
				quien = { "enemigo", "babosa" },
				opciones = { { texto = "¡Bajar!", accion = function()
					apuntarseMazmorra(j)
					return nil
				end }, { texto = "Mejor no" } },
			})
		end)
	elseif nombre == "salirMazmorra" then
		aviso(p, "Subir", "Escalera", function(j)
			for id, ex in expediciones do
				local k = table.find(ex.jugadores, j)
				if k then
					table.remove(ex.jugadores, k)
					if #ex.jugadores == 0 then
						expediciones[id] = nil
					end
				end
			end
			teletransportar(j, Mundo.Mazmorra.salida)
		end)
	elseif nombre == "salirPosada" then
		aviso(p, "Salir", "Puerta", function(j)
			teletransportar(j, Mundo.Posada.salida)
		end)
	elseif nombre == "abuela" then
		p:SetAttribute("Npc", "vecino:1955")
		p:SetAttribute("Frases", "¡Ten cuidado ahí fuera, cielo!|¿Has comido? Estás muy flaco.|En mis tiempos las babosas eran más pequeñas.")
		aviso(p, "Hablar", "Abuela Rosa", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Abuela Rosa",
				texto = pista(perfil),
				quien = { "vecino", "1955" },
				opciones = { { texto = "¡Gracias, abuela!" }, { texto = "Cuéntame lo del Rey Hongo", accion = function()
					return "«Vive en la cueva del final del camino. Lleva nuestro Cucharón de corona… y huele fatal.»"
				end } },
			})
		end)
	elseif nombre == "granjero" then
		p:SetAttribute("Npc", "vecino:4242")
		p:SetAttribute("Frases", "¡Las babosas se comen mis coles!|Ese espantapájaros no espanta ni a una mosca.")
		aviso(p, "Hablar", "Granjero Tomás", function(j)
			dialogo(j, {
				titulo = "Granjero Tomás",
				texto = "¡Las babosas se han metido en mi huerto! Entra en la mancha verde de detrás de las coles y échalas. Es fácil, hasta mi gallina lo haría.",
				quien = { "vecino", "4242" },
				opciones = { { texto = "¡Voy!" }, { texto = "¿Y tu gallina?", accion = function()
					return "«Está de vacaciones.»"
				end } },
			})
		end)
	elseif nombre == "guardaPuente" then
		p:SetAttribute("Npc", "vecino:8080")
		p:SetAttribute("Frases", "Sin cuerda no se cruza.|El río lleva agua de verdad, eh.")
		aviso(p, "Hablar", "Guardia del puente", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			dialogo(j, {
				titulo = "Guardia del puente",
				texto = perfil.llaves.cuerda and "¡Con esa cuerda el puente queda como nuevo! Adelante, el Pantano te espera." or "El puente está roto. Necesitas una CUERDA. Bruno, el de la taberna de la ciudad, tiene una… pero solo se la da a quien le gane dos veces seguidas a los vasos.",
				quien = { "vecino", "8080" },
				opciones = { { texto = "Entendido" } },
			})
		end)
	elseif nombre == "posadera" then
		p:SetAttribute("Npc", "vecino:2468")
		p:SetAttribute("Frases", "Camas blanditas, ronquidos incluidos.|¿Una siestecita?")
		aviso(p, "Dormir (10 oro)", "Posadera Lola", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if perfil.oro < 10 then
				notificar(j, "«Sin 10 de oro no hay cama, cielo.»")
				return
			end
			perfil.oro -= 10
			remoto("Teletransporte"):FireClient(j, nil, "Zzz…")
			task.wait(1)
			Combate.curarDelTodo(j)
			DatosJugador.guardar(j)
			enviarEstado(j)
			notificar(j, "Has dormido como un tronco. Vida y maná al máximo. Partida guardada.")
		end)
	elseif nombre == "cofreHacha" then
		aviso(p, "Abrir", "Cofre", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if perfil.llaves.hacha then
				notificar(j, "El cofre está vacío. Ya cogiste el hacha.")
			else
				guardianes(j, "¡Un sapo enorme!", "Un sapo gordísimo está sentado encima del cofre. «Croac. Este cofre es MÍO. Y mis primos opinan igual.»", { "enemigo", "rana" },
					{ id = "pantano", nombre = "Los guardianes del cofre", nivel = 3, grupos = { { "rana", "rana", "planta" } }, color = Color3.fromRGB(90, 170, 110) }, 245,
					function(g)
						darLlave(g, "hacha")
					end)
			end
		end, 6)
	elseif nombre == "seta" then
		local id = p:GetAttribute("SetaId") :: number
		aviso(p, "Coger", "Seta brillante", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if table.find(perfil.progreso.setas, id) or perfil.llaves.llave then
				return
			end
			table.insert(perfil.progreso.setas, id)
			remoto("Sonido"):FireClient(j, "brillo")
			notificar(j, "Seta brillante (" .. #perfil.progreso.setas .. " de 3). Huele a menta.")
			DatosJugador.guardar(j)
			enviarEstado(j)
		end, 6)
	elseif nombre == "palanca" then
		local id = p:GetAttribute("PalancaId") :: number
		aviso(p, "Tirar", "Palanca", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if table.find(perfil.progreso.palancas, id) then
				return
			end
			table.insert(perfil.progreso.palancas, id)
			remoto("Sonido"):FireClient(j, "palanca")
			local n = #perfil.progreso.palancas
			notificar(j, n >= 3 and "¡CLONK! Se oye abrirse algo en las Ruinas…" or ("Clac. Palanca " .. n .. " de 3."))
			DatosJugador.guardar(j)
			enviarEstado(j)
		end, 6)
	elseif nombre == "cofreFarol" then
		aviso(p, "Abrir", "Cofre de la cripta", function(j)
			local perfil = DatosJugador.obtener(j) :: any
			if perfil.llaves.farol then
				notificar(j, "Vacío. Solo hay una araña que te saluda.")
			elseif #perfil.progreso.palancas < 3 then
				notificar(j, "Está cerrado con un mecanismo. Faltan palancas: " .. #perfil.progreso.palancas .. " de 3.")
			else
				guardianes(j, "La cripta despierta", "Al tocar el cofre, la cripta tiembla. Los huesos del suelo se levantan… y no parecen contentos.", { "enemigo", "esqueleto" },
					{ id = "ruinas", nombre = "Los guardianes de la cripta", nivel = 5, grupos = { { "esqueleto", "esqueleto", "murcielago" } }, color = Color3.fromRGB(200, 190, 160) }, 432,
					function(g)
						darLlave(g, "farol")
					end)
			end
		end)
	end
end

-- ===================== PARADEROS ALEATORIOS =====================
Eventos.iniciar({
	dialogo = dialogo,
	notificar = notificar,
	enviarEstado = enviarEstado,
	Combate = Combate,
	DatosJugador = DatosJugador,
	remoto = remoto,
})

-- tienda del mercader (pociones y éteres)
remoto("Comprar").OnServerEvent:Connect(function(j, objetoId)
	local perfil = DatosJugador.obtener(j)
	local o = type(objetoId) == "string" and Datos.Objetos[objetoId] or nil
	if not perfil or not o or Combate.enBatalla(j) then
		return
	end
	if perfil.oro < o.precio then
		notificar(j, "No te llega el oro")
		return
	end
	perfil.oro -= o.precio
	perfil.objetos[o.id] = (perfil.objetos[o.id] or 0) + 1
	enviarEstado(j)
	notificar(j, "Has comprado: " .. o.nombre)
end)

-- ===================== EMBOSCADAS =====================
-- Al ir andando por las zonas salvajes, a veces saltan monstruos de entre los arbustos: ¡EMBOSCADA!
-- (los monstruos atacan primero). El campo de batalla se coloca dentro de la zona, sin cruzar barreras.
local TRAMOS = {
	{ id = "pradera", desde = 64, hasta = 144 },
	{ id = "pantano", desde = 183, hasta = 244 },
	{ id = "bosque", desde = 283, hasta = 344 },
	{ id = "ruinas", desde = 383, hasta = 444 },
}
local ultimaEmboscada: { [Player]: number } = {}
local ultimaPos: { [Player]: Vector3 } = {}
local rngEmb = Random.new()

local function zonaPorId(id: string): any
	for _, z in Datos.Zonas do
		if z.id == id then
			return z
		end
	end
	return nil
end

task.spawn(function()
	while true do
		task.wait(12)
		for _, j in Players:GetPlayers() do
			local ch = j.Character
			local raiz = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
			local perfil = DatosJugador.obtener(j)
			if raiz and perfil and perfil.clase and perfil.creado and not Combate.enBatalla(j) then
				local pos = raiz.Position
				local antes = ultimaPos[j]
				ultimaPos[j] = pos
				local andando = antes ~= nil and (pos - antes).Magnitude > 8 and pos.Y < 100
				if andando and os.clock() > (ultimaEmboscada[j] or 0) + 90 and rngEmb:NextNumber() < 0.3 then
					for _, t in TRAMOS do
						if pos.X > t.desde - 18 and pos.X < t.hasta + 18 then
							local zona = zonaPorId(t.id)
							if zona then
								ultimaEmboscada[j] = os.clock()
								notificar(j, "¡Algo se mueve entre los arbustos…!")
								task.wait(1)
								if not Combate.enBatalla(j) then
									local x = math.clamp(pos.X, t.desde, t.hasta)
									Combate.empezar({ id = zona.id, nombre = "¡Emboscada en " .. zona.nombre .. "!", nivel = zona.nivel, grupos = zona.grupos, color = zona.color }, Vector3.new(x, 0, 0), { j }, { emboscada = true })
								end
							end
							break
						end
					end
				end
			end
		end
	end
end)
Players.PlayerRemoving:Connect(function(j)
	ultimaEmboscada[j] = nil
	ultimaPos[j] = nil
end)

-- ajustes del jugador (idioma y volumen): se guardan con la partida
remoto("GuardarAjustes").OnServerEvent:Connect(function(j, a)
	local perfil = DatosJugador.obtener(j) :: any
	if not perfil or type(a) ~= "table" then
		return
	end
	local idiomas = { es = true, en = true, pt = true, fr = true, de = true }
	perfil.ajustes = {
		idioma = idiomas[a.idioma] and a.idioma or "es",
		musica = math.clamp(tonumber(a.musica) or 0.5, 0, 1),
		efectos = math.clamp(tonumber(a.efectos) or 0.8, 0, 1),
	}
end)

-- usar pociones y éteres desde la mochila (fuera de combate)
remoto("UsarObjeto").OnServerEvent:Connect(function(j, id)
	local perfil = DatosJugador.obtener(j)
	local o = type(id) == "string" and Datos.Objetos[id] or nil
	if not perfil or not o or Combate.enBatalla(j) or (perfil.objetos[id] or 0) <= 0 then
		return
	end
	local hp, maxHp, mp, maxMp = Combate.vidaDe(j)
	if (o.cura > 0 and hp >= maxHp) and (o.mana <= 0 or mp >= maxMp) then
		notificar(j, "Ya estás como una rosa. No hace falta.")
		return
	end
	perfil.objetos[id] -= 1
	Combate.ponerVida(j, math.min(maxHp, hp + o.cura), math.min(maxMp, mp + o.mana))
	remoto("Sonido"):FireClient(j, "cura")
	notificar(j, "Usas: " .. o.nombre)
	enviarEstado(j)
end)

-- autoguardado cada 2 minutos
task.spawn(function()
	while true do
		task.wait(120)
		for _, j in Players:GetPlayers() do
			DatosJugador.guardar(j)
		end
	end
end)
