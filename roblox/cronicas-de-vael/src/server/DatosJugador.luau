--!strict
-- Guardado de partida con DataStore (clase, nivel, experiencia, oro, objetos y mejoras).
-- En Studio hace falta activar: Game Settings → Security → "Enable Studio Access to API Services".
-- Si el DataStore falla, el juego sigue con datos nuevos (no se pierde la partida en curso).

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DatosJugador = {}

export type Perfil = { clase: string?, nivel: number, xp: number, oro: number, objetos: { [string]: number }, mejoras: { string }, llaves: { [string]: boolean }, progreso: { [string]: any } }

local almacen: DataStore? = nil
pcall(function()
	almacen = DataStoreService:GetDataStore("CronicasDeVael_v1")
end)

local perfiles: { [Player]: Perfil } = {}

local function nuevo(): Perfil
	return { clase = nil, nivel = 1, xp = 0, oro = 20, objetos = { pocion = 3, eter = 1 }, mejoras = {}, llaves = {}, progreso = { setas = {}, palancas = {}, racha = 0 } }
end

function DatosJugador.cargar(jugador: Player): Perfil
	local perfil = nuevo()
	if almacen then
		local ok, datos = pcall(function()
			return (almacen :: DataStore):GetAsync("j_" .. jugador.UserId)
		end)
		if ok and type(datos) == "table" then
			perfil.clase = datos.clase
			perfil.nivel = datos.nivel or 1
			perfil.xp = datos.xp or 0
			perfil.oro = datos.oro or 20
			perfil.objetos = datos.objetos or perfil.objetos
			perfil.mejoras = type(datos.mejoras) == "table" and datos.mejoras or {}
			perfil.llaves = type(datos.llaves) == "table" and datos.llaves or {}
			if type(datos.progreso) == "table" then
				perfil.progreso.setas = datos.progreso.setas or {}
				perfil.progreso.palancas = datos.progreso.palancas or {}
			end
		end
	end
	perfiles[jugador] = perfil
	return perfil
end

function DatosJugador.obtener(jugador: Player): Perfil?
	return perfiles[jugador]
end

function DatosJugador.guardar(jugador: Player)
	local perfil = perfiles[jugador]
	if not perfil or not almacen then
		return
	end
	pcall(function()
		(almacen :: DataStore):SetAsync("j_" .. jugador.UserId, perfil)
	end)
end

function DatosJugador.soltar(jugador: Player)
	DatosJugador.guardar(jugador)
	perfiles[jugador] = nil
end

-- Guardado al cerrar el servidor
game:BindToClose(function()
	for _, j in Players:GetPlayers() do
		DatosJugador.guardar(j)
	end
end)

return DatosJugador
