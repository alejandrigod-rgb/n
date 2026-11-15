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
	picadura = { id = "picadura", nombre = "Picadura", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 0.9, nivelMinimo = 1, efecto = "veneno" },
	lengua = { id = "lengua", nombre = "Lengüetazo", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.4, nivelMinimo = 1 },
	raices = { id = "raices", nombre = "Raíces", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 0.8, nivelMinimo = 1 },
	terremoto = { id = "terremoto", nombre = "Terremoto", descripcion = "", coste = 0, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 0.9, nivelMinimo = 1 },
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
	-- pradera
	babosa = { id = "babosa", nombre = "Babosa de musgo", color = Color3.fromRGB(120, 190, 80), tamano = 3.2, forma = "babosa", stats = { hp = 38, mp = 0, atk = 8, def = 3, mag = 2, spd = 5 }, xp = 8, oro = 4, habilidades = {}, probHabilidad = 0 },
	hongo = { id = "hongo", nombre = "Hongo saltarín", color = Color3.fromRGB(230, 130, 60), tamano = 3, forma = "hongo", stats = { hp = 32, mp = 0, atk = 7, def = 3, mag = 4, spd = 7 }, xp = 7, oro = 4, habilidades = {}, probHabilidad = 0 },
	abeja = { id = "abeja", nombre = "Abeja zumbona", color = Color3.fromRGB(250, 200, 50), tamano = 2.8, forma = "abeja", stats = { hp = 26, mp = 0, atk = 9, def = 2, mag = 2, spd = 15 }, xp = 7, oro = 3, habilidades = { "picadura" }, probHabilidad = 0.3 },
	lobo = { id = "lobo", nombre = "Lobo sombrío", color = Color3.fromRGB(85, 85, 115), tamano = 4.2, forma = "lobo", stats = { hp = 55, mp = 0, atk = 13, def = 4, mag = 2, spd = 13 }, xp = 14, oro = 7, habilidades = { "mordisco" }, probHabilidad = 0.35 },
	-- pantano
	rana = { id = "rana", nombre = "Sapo del pantano", color = Color3.fromRGB(90, 170, 110), tamano = 3.6, forma = "rana", stats = { hp = 50, mp = 0, atk = 11, def = 5, mag = 5, spd = 9 }, xp = 12, oro = 6, habilidades = { "lengua" }, probHabilidad = 0.3 },
	planta = { id = "planta", nombre = "Planta carnívora", color = Color3.fromRGB(200, 60, 80), tamano = 4.4, forma = "planta", stats = { hp = 62, mp = 0, atk = 12, def = 6, mag = 8, spd = 4 }, xp = 14, oro = 7, habilidades = { "mordisco" }, probHabilidad = 0.35 },
	fantasma = { id = "fantasma", nombre = "Fantasma de niebla", color = Color3.fromRGB(225, 235, 250), tamano = 3.8, forma = "fantasma", stats = { hp = 48, mp = 0, atk = 6, def = 3, mag = 15, spd = 12 }, xp = 18, oro = 9, habilidades = { "hechizoOscuro" }, probHabilidad = 0.4 },
	-- bosque
	duende = { id = "duende", nombre = "Duende lancero", color = Color3.fromRGB(150, 180, 70), tamano = 3.8, forma = "duende", stats = { hp = 60, mp = 0, atk = 14, def = 7, mag = 4, spd = 10 }, xp = 18, oro = 10, habilidades = {}, probHabilidad = 0 },
	arana = { id = "arana", nombre = "Araña tejedora", color = Color3.fromRGB(60, 50, 70), tamano = 3.8, forma = "arana", stats = { hp = 58, mp = 0, atk = 14, def = 6, mag = 4, spd = 12 }, xp = 18, oro = 9, habilidades = { "picadura" }, probHabilidad = 0.35 },
	tronco = { id = "tronco", nombre = "Tronco furioso", color = Color3.fromRGB(130, 90, 55), tamano = 6, forma = "tronco", stats = { hp = 120, mp = 0, atk = 16, def = 12, mag = 2, spd = 3 }, xp = 30, oro = 14, habilidades = { "raices" }, probHabilidad = 0.3 },
	-- ruinas
	esqueleto = { id = "esqueleto", nombre = "Esqueleto errante", color = Color3.fromRGB(235, 230, 210), tamano = 4.6, forma = "esqueleto", stats = { hp = 85, mp = 0, atk = 17, def = 10, mag = 6, spd = 8 }, xp = 28, oro = 15, habilidades = {}, probHabilidad = 0 },
	murcielago = { id = "murcielago", nombre = "Murciélago de cripta", color = Color3.fromRGB(120, 70, 150), tamano = 3.2, forma = "murcielago", stats = { hp = 45, mp = 0, atk = 12, def = 4, mag = 12, spd = 16 }, xp = 20, oro = 9, habilidades = { "hechizoOscuro" }, probHabilidad = 0.3 },
	golem = { id = "golem", nombre = "Gólem de piedra", color = Color3.fromRGB(140, 140, 150), tamano = 6.5, forma = "golem", stats = { hp = 150, mp = 0, atk = 20, def = 16, mag = 2, spd = 4 }, xp = 40, oro = 20, habilidades = { "terremoto" }, probHabilidad = 0.3 },
	-- jefe
	reyHongo = { id = "reyHongo", nombre = "Rey Hongo", color = Color3.fromRGB(210, 60, 55), tamano = 9, forma = "reyHongo", stats = { hp = 420, mp = 0, atk = 22, def = 12, mag = 18, spd = 7 }, xp = 160, oro = 120, habilidades = { "esporas", "golpeRey" }, probHabilidad = 0.45 },
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
	{ id = "pradera", nombre = "Pradera de Vael", nivel = 1, color = Color3.fromRGB(140, 210, 110), grupos = { { "babosa", "babosa" }, { "hongo", "abeja" }, { "abeja", "abeja", "babosa" }, { "lobo" }, { "hongo", "hongo", "babosa" } } },
	{ id = "pantano", nombre = "Pantano Brumoso", nivel = 2, color = Color3.fromRGB(110, 160, 140), grupos = { { "rana", "babosa" }, { "planta", "rana" }, { "fantasma", "rana" }, { "planta", "planta" } } },
	{ id = "bosque", nombre = "Bosque Susurrante", nivel = 3, color = Color3.fromRGB(70, 140, 80), grupos = { { "duende", "lobo" }, { "arana", "duende" }, { "tronco" }, { "lobo", "lobo", "arana" }, { "duende", "duende" } } },
	{ id = "ruinas", nombre = "Ruinas de Ceniza", nivel = 5, color = Color3.fromRGB(170, 150, 130), grupos = { { "esqueleto", "murcielago" }, { "golem" }, { "fantasma", "esqueleto" }, { "esqueleto", "esqueleto", "murcielago" } } },
	{ id = "cueva", nombre = "Cueva del Rey Hongo", nivel = 7, color = Color3.fromRGB(210, 70, 60), grupos = { { "reyHongo", "hongo", "hongo" } } },
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
