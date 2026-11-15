--!strict
-- Crónicas de Vael · datos del juego (compartidos entre servidor y cliente).
-- Mundo original: clases, habilidades, enemigos, objetos y zonas. Cambia aquí los números para equilibrar el juego.

local Datos = {}

export type Stats = { hp: number, mp: number, atk: number, def: number, mag: number, spd: number }

export type Habilidad = {
	id: string,
	nombre: string,
	descripcion: string,
	coste: number, -- maná
	tipo: "dano" | "cura" | "revivir" | "mejora",
	objetivo: "enemigo" | "enemigos" | "aliado" | "aliados" | "yo",
	base: "atk" | "mag",
	poder: number, -- multiplicador del atributo base
	nivelMinimo: number,
	efecto: string?, -- "veneno", "defensa", "furia"
	critExtra: number?,
}

-- ============ HABILIDADES ============
Datos.Habilidades = {
	golpeFuerte = { id = "golpeFuerte", nombre = "Golpe fuerte", descripcion = "Un tajo con todo tu peso.", coste = 5, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.7, nivelMinimo = 1 },
	grito = { id = "grito", nombre = "Grito de guerra", descripcion = "Tu equipo pega un 30 % más durante 3 turnos.", coste = 6, tipo = "mejora", objetivo = "aliados", base = "atk", poder = 0, nivelMinimo = 2, efecto = "furia" },
	torbellino = { id = "torbellino", nombre = "Torbellino", descripcion = "Golpea a todos los enemigos.", coste = 10, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 1.0, nivelMinimo = 4 },

	bolaFuego = { id = "bolaFuego", nombre = "Bola de fuego", descripcion = "Fuego concentrado en un enemigo.", coste = 7, tipo = "dano", objetivo = "enemigo", base = "mag", poder = 1.9, nivelMinimo = 1 },
	escudoArcano = { id = "escudoArcano", nombre = "Escudo arcano", descripcion = "Un aliado recibe la mitad de daño 3 turnos.", coste = 8, tipo = "mejora", objetivo = "aliado", base = "mag", poder = 0, nivelMinimo = 2, efecto = "defensa" },
	tormenta = { id = "tormenta", nombre = "Tormenta de rayos", descripcion = "Rayos sobre todos los enemigos.", coste = 14, tipo = "dano", objetivo = "enemigos", base = "mag", poder = 1.2, nivelMinimo = 4 },

	disparoCerte = { id = "disparoCerte", nombre = "Disparo certero", descripcion = "Mucha probabilidad de crítico.", coste = 5, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.5, nivelMinimo = 1, critExtra = 0.4 },
	flechaVeneno = { id = "flechaVeneno", nombre = "Flecha venenosa", descripcion = "Envenena: daño cada turno durante 3 turnos.", coste = 7, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 0.9, nivelMinimo = 2, efecto = "veneno" },
	lluviaFlechas = { id = "lluviaFlechas", nombre = "Lluvia de flechas", descripcion = "Flechas sobre todos los enemigos.", coste = 11, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 0.9, nivelMinimo = 4 },

	curar = { id = "curar", nombre = "Curar", descripcion = "Cura mucho a un aliado.", coste = 6, tipo = "cura", objetivo = "aliado", base = "mag", poder = 2.0, nivelMinimo = 1 },
	curaGrupal = { id = "curaGrupal", nombre = "Luz sanadora", descripcion = "Cura a todo el equipo.", coste = 14, tipo = "cura", objetivo = "aliados", base = "mag", poder = 1.1, nivelMinimo = 2 },
	revivir = { id = "revivir", nombre = "Revivir", descripcion = "Levanta a un aliado caído con un 40 % de vida.", coste = 18, tipo = "revivir", objetivo = "aliado", base = "mag", poder = 0.4, nivelMinimo = 3 },

	-- habilidades de enemigos
	mordisco = { id = "mordisco", nombre = "Mordisco", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.4, nivelMinimo = 1 },
	esporas = { id = "esporas", nombre = "Nube de esporas", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigos", base = "mag", poder = 0.7, nivelMinimo = 1, efecto = "veneno" },
	hechizoOscuro = { id = "hechizoOscuro", nombre = "Hechizo oscuro", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigo", base = "mag", poder = 1.6, nivelMinimo = 1 },
	golpeRey = { id = "golpeRey", nombre = "Puñetazo real", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 2.0, nivelMinimo = 1 },
} :: { [string]: Habilidad }

-- ============ CLASES ============
export type Clase = { id: string, nombre: string, descripcion: string, color: Color3, base: Stats, crece: Stats, habilidades: { string } }

Datos.Clases = {
	guerrero = {
		id = "guerrero", nombre = "Guerrero", descripcion = "Mucha vida y defensa. Aguanta los golpes del equipo.", color = Color3.fromRGB(214, 69, 65),
		base = { hp = 120, mp = 20, atk = 14, def = 10, mag = 4, spd = 8 }, crece = { hp = 14, mp = 2, atk = 3, def = 2, mag = 0, spd = 1 },
		habilidades = { "golpeFuerte", "grito", "torbellino" },
	},
	maga = {
		id = "maga", nombre = "Maga", descripcion = "Hechizos devastadores, pero poca vida.", color = Color3.fromRGB(122, 92, 214),
		base = { hp = 75, mp = 60, atk = 5, def = 5, mag = 16, spd = 10 }, crece = { hp = 8, mp = 6, atk = 1, def = 1, mag = 3, spd = 1 },
		habilidades = { "bolaFuego", "escudoArcano", "tormenta" },
	},
	arquero = {
		id = "arquero", nombre = "Arquero", descripcion = "El más rápido. Críticos y veneno.", color = Color3.fromRGB(70, 160, 90),
		base = { hp = 90, mp = 30, atk = 12, def = 7, mag = 6, spd = 14 }, crece = { hp = 10, mp = 3, atk = 3, def = 1, mag = 1, spd = 2 },
		habilidades = { "disparoCerte", "flechaVeneno", "lluviaFlechas" },
	},
	sanador = {
		id = "sanador", nombre = "Sanador", descripcion = "Cura y revive al equipo. Imprescindible en grupo.", color = Color3.fromRGB(240, 200, 80),
		base = { hp = 85, mp = 55, atk = 7, def = 7, mag = 13, spd = 9 }, crece = { hp = 9, mp = 6, atk = 1, def = 1, mag = 3, spd = 1 },
		habilidades = { "curar", "curaGrupal", "revivir" },
	},
} :: { [string]: Clase }
Datos.OrdenClases = { "guerrero", "maga", "arquero", "sanador" }

-- ============ ENEMIGOS ============
export type Enemigo = { id: string, nombre: string, color: Color3, tamano: number, forma: string, stats: Stats, xp: number, oro: number, habilidades: { string }, probHabilidad: number }

Datos.Enemigos = {
	babosa = { id = "babosa", nombre = "Babosa de musgo", color = Color3.fromRGB(120, 190, 80), tamano = 3, forma = "gota", stats = { hp = 38, mp = 0, atk = 8, def = 3, mag = 2, spd = 5 }, xp = 8, oro = 4, habilidades = {}, probHabilidad = 0 },
	lobo = { id = "lobo", nombre = "Lobo sombrío", color = Color3.fromRGB(70, 70, 95), tamano = 4, forma = "bestia", stats = { hp = 55, mp = 0, atk = 13, def = 4, mag = 2, spd = 13 }, xp = 14, oro = 7, habilidades = { "mordisco" }, probHabilidad = 0.35 },
	duende = { id = "duende", nombre = "Duende lancero", color = Color3.fromRGB(150, 170, 60), tamano = 3.5, forma = "humanoide", stats = { hp = 60, mp = 0, atk = 14, def = 7, mag = 4, spd = 10 }, xp = 18, oro = 10, habilidades = {}, probHabilidad = 0 },
	esqueleto = { id = "esqueleto", nombre = "Esqueleto errante", color = Color3.fromRGB(225, 220, 200), tamano = 4.5, forma = "humanoide", stats = { hp = 85, mp = 0, atk = 17, def = 10, mag = 6, spd = 8 }, xp = 28, oro = 15, habilidades = {}, probHabilidad = 0 },
	murcielago = { id = "murcielago", nombre = "Murciélago de cripta", color = Color3.fromRGB(110, 60, 130), tamano = 3, forma = "volador", stats = { hp = 45, mp = 0, atk = 12, def = 4, mag = 12, spd = 16 }, xp = 20, oro = 9, habilidades = { "hechizoOscuro" }, probHabilidad = 0.3 },
	reyHongo = { id = "reyHongo", nombre = "Rey Hongo", color = Color3.fromRGB(200, 70, 60), tamano = 9, forma = "jefe", stats = { hp = 420, mp = 0, atk = 22, def = 12, mag = 18, spd = 7 }, xp = 160, oro = 120, habilidades = { "esporas", "golpeRey" }, probHabilidad = 0.45 },
} :: { [string]: Enemigo }

-- ============ OBJETOS ============
Datos.Objetos = {
	pocion = { id = "pocion", nombre = "Poción", descripcion = "Cura 50 de vida.", cura = 50, mana = 0, precio = 15 },
	eter = { id = "eter", nombre = "Éter", descripcion = "Recupera 25 de maná.", cura = 0, mana = 25, precio = 25 },
}
Datos.OrdenObjetos = { "pocion", "eter" }

-- ============ ZONAS DEL MAPA ============
-- Cada zona dispara un combate al pisarla. `grupos`: posibles grupos de enemigos (se elige uno al azar).
Datos.Zonas = {
	{ id = "pradera", nombre = "Pradera de Vael", nivel = 1, color = Color3.fromRGB(140, 210, 110), grupos = { { "babosa", "babosa" }, { "babosa", "lobo" }, { "lobo" } } },
	{ id = "bosque", nombre = "Bosque Susurrante", nivel = 3, color = Color3.fromRGB(70, 140, 80), grupos = { { "duende", "lobo" }, { "duende", "duende" }, { "lobo", "lobo", "babosa" } } },
	{ id = "ruinas", nombre = "Ruinas de Ceniza", nivel = 5, color = Color3.fromRGB(150, 140, 130), grupos = { { "esqueleto", "murcielago" }, { "esqueleto", "esqueleto" }, { "murcielago", "murcielago", "duende" } } },
	{ id = "cueva", nombre = "Cueva del Rey Hongo", nivel = 7, color = Color3.fromRGB(200, 70, 60), grupos = { { "reyHongo", "babosa", "babosa" } } },
}

-- ============ FÓRMULAS ============
Datos.MAX_EQUIPO = 4
Datos.TIEMPO_TURNO = 20 -- segundos para elegir acción

function Datos.xpParaNivel(nivel: number): number
	return math.floor(25 * nivel ^ 1.5)
end

function Datos.statsDe(claseId: string, nivel: number): Stats
	local c = Datos.Clases[claseId]
	local n = nivel - 1
	return {
		hp = c.base.hp + c.crece.hp * n,
		mp = c.base.mp + c.crece.mp * n,
		atk = c.base.atk + c.crece.atk * n,
		def = c.base.def + c.crece.def * n,
		mag = c.base.mag + c.crece.mag * n,
		spd = c.base.spd + c.crece.spd * n,
	}
end

--- Daño: (atributo × poder) contra la defensa, con un 10 % de variación. Nunca menos de 1.
function Datos.dano(atributo: number, poder: number, defensa: number, rng: Random): number
	local bruto = atributo * poder * (rng:NextNumber(0.9, 1.1))
	local reducido = bruto * (100 / (100 + defensa * 6))
	return math.max(1, math.floor(reducido + 0.5))
end

return Datos
