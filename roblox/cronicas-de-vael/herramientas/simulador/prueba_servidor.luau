-- Prueba del servidor: monta el árbol como Rojo, arranca Principal.server y simula un jugador.
local RT = BASE.RT
local E = BASE.E
local I = E.Instance
RT.esCliente = false

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
print("combate:", b ~= nil)
for paso = 1, 40 do
	RT.avanzar(1)
	remotos.EnviarAccion.OnServerEvent:Fire(j, { tipo = paso % 3 == 0 and "mover" or "atacar", col = 2, fila = 2 })
	if not Combate.enBatalla(j) then break end
end
RT.avanzar(5)
informe("combate")
remotos.ElegirMejora.OnServerEvent:Fire(j, "calcetin")
print("zonas ganadas:", pf.progreso.vencidas and pf.progreso.vencidas[Datos.Zonas[2].id])
-- final: la primera vez manda el epílogo, la segunda un diálogo
Combate.alVencerJefe(j)
Combate.alVencerJefe(j)
RT.avanzar(1)
print("final visto:", pf.progreso.final, j:GetAttribute("FinalVisto"))
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
