-- Prueba del servidor: monta el árbol como Rojo, arranca Principal.server y simula un jugador.
local RT = BASE.RT
local E = BASE.E
local I = E.Instance
RT.esCliente = false
-- para poder contestar a los diálogos, se apunta el id del último que se manda
local ultimoDialogo = nil
RT.especiales.RemoteEvent = {
	FireClient = function(self, _j, d)
		if self.Name == "Dialogo" and type(d) == "table" then ultimoDialogo = d.id end
	end,
	FireAllClients = function() end,
}

local RS = RT.servicio("ReplicatedStorage")
local vael = I.new("Folder")
vael.Name = "Vael"
vael.Parent = RS
BASE.modulo("Datos", vael, FUENTES["shared/Datos.luau"])
BASE.modulo("Sonidos", vael, FUENTES["shared/Sonidos.luau"])
local SSS = RT.servicio("ServerScriptService")
local carpeta = I.new("Folder")
carpeta.Name = "VaelServidor"
carpeta.Parent = SSS
local principal
for ruta, fuente in FUENTES do
	local nombre = string.match(ruta, "^server/(.+)%.luau$")
	if nombre then
		local esScript = string.match(nombre, "%.server$") ~= nil
		local limpio = string.gsub(nombre, "%.server$", "")
		local s = BASE.modulo(limpio, carpeta, fuente, esScript and "Script" or "ModuleScript")
		if esScript then principal = s end
	end
end
local base = I.new("Part")
base.Name = "Baseplate"
base.Parent = E.workspace
local sp = I.new("SpawnLocation")
sp.Parent = E.workspace
local Lighting = RT.servicio("Lighting")
local atm = I.new("Atmosphere")
atm.Parent = Lighting

BASE.ejecutar(principal)
RT.avanzar(2)

local function informe(titulo)
	print("==== " .. titulo .. " (t=" .. string.format("%.1f", RT.ahora()) .. ")")
	for _, e in RT.errores do print("ERROR: " .. e) end
	for _, a in RT.avisos do print("AVISO: " .. a) end
	RT.errores = {}
	RT.avisos = {}
end
informe("arranque del servidor")
local mundo = E.workspace:FindFirstChild("MundoVael")
print("MundoVael:", mundo ~= nil, mundo and #mundo:GetDescendants())

-- un jugador entra
local Players = RT.servicio("Players")
local j = I.new("Player")
j.Name = "kilonil"
j.DisplayName = "kilonil"
j.UserId = 1
j.Parent = Players
Players.PlayerAdded:Fire(j)
RT.avanzar(3)
informe("jugador entra")
local remotos = vael:FindFirstChild("Remotos")
remotos.ElegirClase.OnServerEvent:Fire(j, "guerrero")
RT.avanzar(1)
remotos.GuardarApariencia.OnServerEvent:Fire(j, { piel = 2, pelo = 3, nombre = "Kilo" })
RT.avanzar(3)
informe("clase y apariencia")
print("Atributos:", j:GetAttribute("Clase"), j:GetAttribute("NombreHeroe"), j:GetAttribute("Creado"))

-- pulsar todos los avisos (ProximityPrompt) del mundo
local n = 0
for _, d in E.workspace:GetDescendants() do
	if d:IsA("ProximityPrompt") then
		n += 1
		d.Triggered:Fire(j)
		RT.avanzar(0.5)
		remotos.ElegirOpcion.OnServerEvent:Fire(j, 1, 1)
	end
end
RT.avanzar(3)
informe("avisos pulsados: " .. n)
remotos.ElegirVaso.OnServerEvent:Fire(j, 2)
remotos.Comprar.OnServerEvent:Fire(j, "pocion")
remotos.ComprarMejora.OnServerEvent:Fire(j, "herrero", "cuerno")
RT.avanzar(2)
informe("compras")

-- un combate de principio a fin (el jugador elige: mover, atacar…)
local Combate = E.require(carpeta.Combate)
local Datos = E.require(vael.Datos)
-- con compañero (Fermín, el que cura) para probar su IA
local DJ = E.require(carpeta.DatosJugador)
local pf = DJ.obtener(j)
pf.progreso.companeros = { tomas = true, fermin = true }
remotos.ElegirCompanero.OnServerEvent:Fire(j, "fermin")
RT.avanzar(0.5)
print("compañero elegido:", pf.progreso.companero)
local b = Combate.empezar(Datos.Zonas[2], E.Vector3.new(110, 0, -10), { j }, { emboscada = true })
print("aliados en combate:", b and #b.aliados)
-- una roca pegada al héroe, para probar a romperla
for _, e in (b and b.aliados or {}) do
	if e.jugador == j then b.casillas[(e.col + 1) .. "," .. e.fila] = "roca" end
end
local rocasAntes = 0
for _, t in (b and b.casillas or {}) do if t == "roca" then rocasAntes += 1 end end
print("combate:", b ~= nil)
for paso = 1, 40 do
	RT.avanzar(1)
	-- de vez en cuando, intentar romper una roca
	local roca = nil
	for k, t in b.casillas do
		if t == "roca" then
			roca = k
		end
	end
	if roca and paso <= 12 then
		remotos.EnviarAccion.OnServerEvent:Fire(j, { tipo = "atacar", objetivo = "roca:" .. roca })
	else
		remotos.EnviarAccion.OnServerEvent:Fire(j, { tipo = paso % 3 == 0 and "mover" or "atacar", col = 2, fila = 2 })
	end
	if not Combate.enBatalla(j) then break end
end
RT.avanzar(5)
local rocasDespues = 0
for _, t in (b and b.casillas or {}) do if t == "roca" then rocasDespues += 1 end end
print("rocas antes/después:", rocasAntes, rocasDespues)
informe("combate")
remotos.ElegirMejora.OnServerEvent:Fire(j, "calcetin")
print("zonas ganadas:", pf.progreso.vencidas and pf.progreso.vencidas[Datos.Zonas[2].id])
-- si la pelea de la prueba sigue abierta, se acaba (los monstruos caen)
if b and Combate.enBatalla(j) then
	for _, e in b.enemigos do e.hp = 0 e.vivo = false end
	for _ = 1, 30 do
		RT.avanzar(1)
		remotos.EnviarAccion.OnServerEvent:Fire(j, { tipo = "defender" })
		if not Combate.enBatalla(j) then break end
	end
end
print("pelea acabada:", not Combate.enBatalla(j), "zonas ganadas:", pf.progreso.vencidas and pf.progreso.vencidas[Datos.Zonas[2].id])
-- final: la primera vez manda el epílogo, la segunda un diálogo
Combate.alVencerJefe(j)
Combate.alVencerJefe(j)
RT.avanzar(1)
print("final visto:", pf.progreso.final, j:GetAttribute("FinalVisto"))
print("barba tras el final:", pf.progreso.barba)
-- tres años después: despertar, barbero y baño
remotos.Despertar.OnServerEvent:Fire(j)
RT.avanzar(2)
local function pulsarPunto(nombre)
	for _, d in mundo:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("Punto") == nombre then
			local pr = d:FindFirstChildOfClass("ProximityPrompt")
			if pr then pr.Triggered:Fire(j) end
		end
	end
	RT.avanzar(0.5)
end
local ok = Combate.empezar(Datos.Zonas[2], E.Vector3.new(110, 0, -10), { j })
print("¿pelea con barba?", ok ~= nil)
pulsarPunto("barbero")
remotos.ElegirOpcion.OnServerEvent:Fire(j, ultimoDialogo, 1)
RT.avanzar(2)
pulsarPunto("banera")
RT.avanzar(3)
print("barba tras barbero y baño:", pf.progreso.barba, pf.progreso.afeitado, pf.progreso.banado)
pulsarPunto("reyHongoNpc")
remotos.ElegirOpcion.OnServerEvent:Fire(j, ultimoDialogo, 1)
RT.avanzar(1)
print("botas:", pf.llaves.botas)
pulsarPunto("cofrePico")
remotos.ElegirOpcion.OnServerEvent:Fire(j, ultimoDialogo, 1)
RT.avanzar(2)
print("pelea de los pingüinos:", Combate.enBatalla(j))
for paso = 1, 40 do
	RT.avanzar(1)
	remotos.EnviarAccion.OnServerEvent:Fire(j, { tipo = "atacar" })
	if not Combate.enBatalla(j) then break end
end
RT.avanzar(4)
Combate.alVencerJefe(j, "yeti")
RT.avanzar(1)
print("final 2:", pf.progreso.final2, j:GetAttribute("Final2Visto"))
informe("compañeros y final")
-- eventos aleatorios y emboscadas
RT.avanzar(200, 0.5)
informe("eventos")
local paraderos = 0
for _, m in mundo:GetChildren() do
	if string.sub(m.Name, 1, 9) == "Paradero_" then
		paraderos += 1
		local pr = m:FindFirstChild("ProximityPrompt", true)
		if pr then
			pr.Triggered:Fire(j)
			RT.avanzar(0.5)
			remotos.ElegirOpcion.OnServerEvent:Fire(j, 99, 1)
		end
	end
end
RT.avanzar(5)
informe("paraderos: " .. paraderos)
print("FIN")
