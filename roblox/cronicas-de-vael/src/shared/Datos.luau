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
	alcance: number?, -- casillas (distancia en cruz); sin poner = 1
	area: string?, -- "uno" (por defecto), "cruz" (objetivo y sus vecinos), "alrededor" (pegados a ti), "alrededor2", "todos"
	empuje: number?, -- casillas que empuja (negativo: atrae)
}

-- ============ HABILIDADES ============
Datos.Habilidades = {
	golpeFuerte = { id = "golpeFuerte", nombre = "Golpe fuerte", descripcion = "Un tajo con todo tu peso. Empuja 1 casilla.", empuje = 1, alcance = 1, coste = 5, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.7, nivelMinimo = 1 },
	grito = { id = "grito", nombre = "Grito de guerra", descripcion = "Tu equipo pega un 30 % más durante 3 turnos.", area = "todos", coste = 6, tipo = "mejora", objetivo = "aliados", base = "atk", poder = 0, nivelMinimo = 2, efecto = "furia" },
	torbellino = { id = "torbellino", nombre = "Torbellino", descripcion = "Golpea y empuja a todos los que tengas pegados.", area = "alrededor", empuje = 1, coste = 10, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 1.0, nivelMinimo = 4 },

	bolaFuego = { id = "bolaFuego", nombre = "Bola de fuego", descripcion = "Fuego a distancia (4 casillas).", alcance = 4, coste = 7, tipo = "dano", objetivo = "enemigo", base = "mag", poder = 1.9, nivelMinimo = 1 },
	escudoArcano = { id = "escudoArcano", nombre = "Escudo arcano", descripcion = "Un aliado recibe la mitad de daño 3 turnos.", alcance = 4, coste = 8, tipo = "mejora", objetivo = "aliado", base = "mag", poder = 0, nivelMinimo = 2, efecto = "defensa" },
	tormenta = { id = "tormenta", nombre = "Tormenta de rayos", descripcion = "Rayos sobre todos los enemigos.", area = "todos", coste = 14, tipo = "dano", objetivo = "enemigos", base = "mag", poder = 1.2, nivelMinimo = 4 },

	disparoCerte = { id = "disparoCerte", nombre = "Disparo certero", descripcion = "Mucho crítico, 5 casillas.", alcance = 5, coste = 5, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.5, nivelMinimo = 1, critExtra = 0.4 },
	flechaVeneno = { id = "flechaVeneno", nombre = "Flecha venenosa", descripcion = "Envenena 3 turnos, 5 casillas.", alcance = 5, coste = 7, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 0.9, nivelMinimo = 2, efecto = "veneno" },
	lluviaFlechas = { id = "lluviaFlechas", nombre = "Lluvia de flechas", descripcion = "Flechas sobre una casilla y las de al lado.", alcance = 5, area = "cruz", coste = 11, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 0.9, nivelMinimo = 4 },

	curar = { id = "curar", nombre = "Curar", descripcion = "Cura mucho a un aliado (4 casillas).", alcance = 4, coste = 6, tipo = "cura", objetivo = "aliado", base = "mag", poder = 2.0, nivelMinimo = 1 },
	curaGrupal = { id = "curaGrupal", nombre = "Luz sanadora", descripcion = "Cura a todo el equipo.", area = "todos", coste = 14, tipo = "cura", objetivo = "aliados", base = "mag", poder = 1.1, nivelMinimo = 2 },
	revivir = { id = "revivir", nombre = "Revivir", descripcion = "Levanta a un aliado caído con un 40 % de vida.", alcance = 3, coste = 18, tipo = "revivir", objetivo = "aliado", base = "mag", poder = 0.4, nivelMinimo = 3 },

	-- habilidades de enemigos
	mordisco = { id = "mordisco", nombre = "Mordisco", descripcion = "", alcance = 1, coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.4, nivelMinimo = 1 },
	esporas = { id = "esporas", nombre = "Nube de esporas", descripcion = "", area = "alrededor2", coste = 0, tipo = "dano", objetivo = "enemigos", base = "mag", poder = 0.7, nivelMinimo = 1, efecto = "veneno" },
	hechizoOscuro = { id = "hechizoOscuro", nombre = "Hechizo oscuro", descripcion = "", alcance = 4, coste = 0, tipo = "dano", objetivo = "enemigo", base = "mag", poder = 1.6, nivelMinimo = 1 },
	golpeRey = { id = "golpeRey", nombre = "Puñetazo real", descripcion = "", alcance = 1, empuje = 2, coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 2.0, nivelMinimo = 1 },
	picadura = { id = "picadura", nombre = "Picadura", descripcion = "", alcance = 1, coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 0.9, nivelMinimo = 1, efecto = "veneno" },
	lengua = { id = "lengua", nombre = "Lengüetazo", descripcion = "", alcance = 3, empuje = -2, coste = 0, tipo = "dano", objetivo = "enemigo", base = "atk", poder = 1.4, nivelMinimo = 1 },
	raices = { id = "raices", nombre = "Raíces", descripcion = "", area = "todos", coste = 0, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 0.8, nivelMinimo = 1 },
	terremoto = { id = "terremoto", nombre = "Terremoto", descripcion = "", area = "todos", coste = 0, tipo = "dano", objetivo = "enemigos", base = "atk", poder = 0.9, nivelMinimo = 1 },
} :: { [string]: Habilidad }

-- ============ CLASES ============
export type Clase = { id: string, nombre: string, descripcion: string, color: Color3, base: Stats, crece: Stats, habilidades: { string }, mov: number, alcance: number }

Datos.Clases = {
	guerrero = {
		mov = 3, alcance = 1,
		id = "guerrero", nombre = "Guerrero", descripcion = "Mucha vida y defensa. Aguanta los golpes del equipo.", color = Color3.fromRGB(214, 69, 65),
		base = { hp = 120, mp = 20, atk = 14, def = 10, mag = 4, spd = 8 }, crece = { hp = 14, mp = 2, atk = 3, def = 2, mag = 0, spd = 1 },
		habilidades = { "golpeFuerte", "grito", "torbellino" },
	},
	maga = {
		mov = 3, alcance = 3,
		id = "maga", nombre = "Maga", descripcion = "Hechizos devastadores, pero poca vida.", color = Color3.fromRGB(122, 92, 214),
		base = { hp = 75, mp = 60, atk = 5, def = 5, mag = 16, spd = 10 }, crece = { hp = 8, mp = 6, atk = 1, def = 1, mag = 3, spd = 1 },
		habilidades = { "bolaFuego", "escudoArcano", "tormenta" },
	},
	arquero = {
		mov = 4, alcance = 4,
		id = "arquero", nombre = "Arquero", descripcion = "El más rápido. Críticos y veneno.", color = Color3.fromRGB(70, 160, 90),
		base = { hp = 90, mp = 30, atk = 12, def = 7, mag = 6, spd = 14 }, crece = { hp = 10, mp = 3, atk = 3, def = 1, mag = 1, spd = 2 },
		habilidades = { "disparoCerte", "flechaVeneno", "lluviaFlechas" },
	},
	sanador = {
		mov = 3, alcance = 1,
		id = "sanador", nombre = "Sanador", descripcion = "Cura y revive al equipo. Imprescindible en grupo.", color = Color3.fromRGB(240, 200, 80),
		base = { hp = 85, mp = 55, atk = 7, def = 7, mag = 13, spd = 9 }, crece = { hp = 9, mp = 6, atk = 1, def = 1, mag = 3, spd = 1 },
		habilidades = { "curar", "curaGrupal", "revivir" },
	},
} :: { [string]: Clase }
Datos.OrdenClases = { "guerrero", "maga", "arquero", "sanador" }

-- ============ ENEMIGOS ============
export type Enemigo = { id: string, nombre: string, color: Color3, tamano: number, forma: string, stats: Stats, xp: number, oro: number, habilidades: { string }, probHabilidad: number, mov: number?, alcance: number?, vuela: boolean?, frases: { string }?, jefe: boolean? }

Datos.Enemigos = {
	-- pradera
	babosa = { mov = 2, alcance = 1, frases = { "Blub.", "¿Me das un abrazo pegajoso?" }, id = "babosa", nombre = "Babosa de musgo", color = Color3.fromRGB(120, 190, 80), tamano = 3.2, forma = "babosa", stats = { hp = 38, mp = 0, atk = 8, def = 3, mag = 2, spd = 5 }, xp = 8, oro = 4, habilidades = {}, probHabilidad = 0 },
	hongo = { mov = 2, alcance = 1, frases = { "¡Boing!", "No soy comestible. Creo." }, id = "hongo", nombre = "Hongo saltarín", color = Color3.fromRGB(230, 130, 60), tamano = 3, forma = "hongo", stats = { hp = 32, mp = 0, atk = 7, def = 3, mag = 4, spd = 7 }, xp = 7, oro = 4, habilidades = {}, probHabilidad = 0 },
	abeja = { mov = 4, alcance = 1, vuela = true, frases = { "¡Bzzz!", "Mi reina me paga poco." }, id = "abeja", nombre = "Abeja zumbona", color = Color3.fromRGB(250, 200, 50), tamano = 2.8, forma = "abeja", stats = { hp = 26, mp = 0, atk = 9, def = 2, mag = 2, spd = 15 }, xp = 7, oro = 3, habilidades = { "picadura" }, probHabilidad = 0.3 },
	lobo = { mov = 4, alcance = 1, frases = { "¡Auuu!", "Tengo hambre de héroe." }, id = "lobo", nombre = "Lobo sombrío", color = Color3.fromRGB(85, 85, 115), tamano = 4.2, forma = "lobo", stats = { hp = 55, mp = 0, atk = 13, def = 4, mag = 2, spd = 13 }, xp = 14, oro = 7, habilidades = { "mordisco" }, probHabilidad = 0.35 },
	-- pantano
	rana = { mov = 3, alcance = 1, frases = { "¡Croac!", "Mi lengua mide tres casillas." }, id = "rana", nombre = "Sapo del pantano", color = Color3.fromRGB(90, 170, 110), tamano = 3.6, forma = "rana", stats = { hp = 50, mp = 0, atk = 11, def = 5, mag = 5, spd = 9 }, xp = 12, oro = 6, habilidades = { "lengua" }, probHabilidad = 0.3 },
	planta = { mov = 0, alcance = 2, frases = { "¡Ñam ñam!", "No puedo moverme… ¡acércate tú!" }, id = "planta", nombre = "Planta carnívora", color = Color3.fromRGB(200, 60, 80), tamano = 4.4, forma = "planta", stats = { hp = 62, mp = 0, atk = 12, def = 6, mag = 8, spd = 4 }, xp = 14, oro = 7, habilidades = { "mordisco" }, probHabilidad = 0.35 },
	fantasma = { mov = 3, alcance = 1, vuela = true, frases = { "¡Buuu!", "Atravieso paredes, no impuestos." }, id = "fantasma", nombre = "Fantasma de niebla", color = Color3.fromRGB(225, 235, 250), tamano = 3.8, forma = "fantasma", stats = { hp = 48, mp = 0, atk = 6, def = 3, mag = 15, spd = 12 }, xp = 18, oro = 9, habilidades = { "hechizoOscuro" }, probHabilidad = 0.4 },
	-- bosque
	duende = { mov = 3, alcance = 2, frases = { "¡Por el bosque!", "Mi lanza es de segunda mano." }, id = "duende", nombre = "Duende lancero", color = Color3.fromRGB(150, 180, 70), tamano = 3.8, forma = "duende", stats = { hp = 60, mp = 0, atk = 14, def = 7, mag = 4, spd = 10 }, xp = 18, oro = 10, habilidades = {}, probHabilidad = 0 },
	arana = { mov = 3, alcance = 1, frases = { "Ocho patas, cero amigos.", "¡Sssss!" }, id = "arana", nombre = "Araña tejedora", color = Color3.fromRGB(60, 50, 70), tamano = 3.8, forma = "arana", stats = { hp = 58, mp = 0, atk = 14, def = 6, mag = 4, spd = 12 }, xp = 18, oro = 9, habilidades = { "picadura" }, probHabilidad = 0.35 },
	tronco = { mov = 2, alcance = 1, frases = { "Soy… madera… enfadada.", "¡CRAC!" }, id = "tronco", nombre = "Tronco furioso", color = Color3.fromRGB(130, 90, 55), tamano = 6, forma = "tronco", stats = { hp = 120, mp = 0, atk = 16, def = 12, mag = 2, spd = 3 }, xp = 30, oro = 14, habilidades = { "raices" }, probHabilidad = 0.3 },
	-- ruinas
	esqueleto = { mov = 2, alcance = 1, frases = { "Me falta un hueso. ¿Lo tienes tú?", "¡Clac clac!" }, id = "esqueleto", nombre = "Esqueleto errante", color = Color3.fromRGB(235, 230, 210), tamano = 4.6, forma = "esqueleto", stats = { hp = 85, mp = 0, atk = 17, def = 10, mag = 6, spd = 8 }, xp = 28, oro = 15, habilidades = {}, probHabilidad = 0 },
	murcielago = { mov = 4, alcance = 1, vuela = true, frases = { "¡Iiiih!", "Duermo boca abajo, ¿y qué?" }, id = "murcielago", nombre = "Murciélago de cripta", color = Color3.fromRGB(120, 70, 150), tamano = 3.2, forma = "murcielago", stats = { hp = 45, mp = 0, atk = 12, def = 4, mag = 12, spd = 16 }, xp = 20, oro = 9, habilidades = { "hechizoOscuro" }, probHabilidad = 0.3 },
	golem = { mov = 2, alcance = 1, frases = { "GÓLEM. APLASTA.", "…" }, id = "golem", nombre = "Gólem de piedra", color = Color3.fromRGB(140, 140, 150), tamano = 6.5, forma = "golem", stats = { hp = 150, mp = 0, atk = 20, def = 16, mag = 2, spd = 4 }, xp = 40, oro = 20, habilidades = { "terremoto" }, probHabilidad = 0.3 },
	-- de los paraderos
	mimico = { mov = 2, alcance = 1, frases = { "¡Sorpresa!", "¿Buscabas oro? Busca esto." }, id = "mimico", nombre = "Cofre mímico", color = Color3.fromRGB(170, 110, 60), tamano = 3.6, forma = "mimico", stats = { hp = 70, mp = 0, atk = 15, def = 8, mag = 2, spd = 9 }, xp = 30, oro = 60, habilidades = { "mordisco" }, probHabilidad = 0.5 },
	-- jefe
	-- historia 2: Picos Nevados
	pinguino = { mov = 4, alcance = 1, frases = { "¡La bolsa o el pez!", "Mi antifaz es de verdad." }, id = "pinguino", nombre = "Pingüino bandido", color = Color3.fromRGB(55, 60, 80), tamano = 3.2, forma = "pinguino", stats = { hp = 80, mp = 0, atk = 18, def = 9, mag = 4, spd = 15 }, xp = 32, oro = 16, habilidades = { "picadura" }, probHabilidad = 0.3 },
	munecoNieve = { mov = 2, alcance = 3, frases = { "¡Bola va!", "No me derrito, me relajo." }, id = "munecoNieve", nombre = "Muñeco de nieve", color = Color3.fromRGB(240, 245, 250), tamano = 4.4, forma = "munecoNieve", stats = { hp = 110, mp = 0, atk = 17, def = 12, mag = 10, spd = 6 }, xp = 36, oro = 18, habilidades = {}, probHabilidad = 0 },
	loboBlanco = { mov = 4, alcance = 1, frases = { "¡Auuuu… qué frío!", "Huelo a héroe congelado." }, id = "loboBlanco", nombre = "Lobo de la ventisca", color = Color3.fromRGB(220, 230, 240), tamano = 4.4, forma = "lobo", stats = { hp = 100, mp = 0, atk = 22, def = 10, mag = 4, spd = 16 }, xp = 40, oro = 20, habilidades = { "mordisco" }, probHabilidad = 0.4 },
	espiritu = { mov = 3, alcance = 2, vuela = true, frases = { "Brrrr…", "Soy un soplo de aire. Un soplo MALO." }, id = "espiritu", nombre = "Espíritu de escarcha", color = Color3.fromRGB(170, 215, 245), tamano = 3.8, forma = "fantasma", stats = { hp = 85, mp = 0, atk = 10, def = 8, mag = 24, spd = 13 }, xp = 40, oro = 20, habilidades = { "hechizoOscuro" }, probHabilidad = 0.45 },
	yeti = { mov = 2, alcance = 2, jefe = true, frases = { "¡TENGO HAMBREEE!", "¡Esa olla es MÍA!", "¡Nadie me invita nunca!" }, id = "yeti", nombre = "Yeti Tragón", color = Color3.fromRGB(225, 235, 245), tamano = 9, forma = "yeti", stats = { hp = 700, mp = 0, atk = 30, def = 16, mag = 22, spd = 9 }, xp = 320, oro = 250, habilidades = { "golpeRey", "terremoto" }, probHabilidad = 0.45 },
	reyHongo = { mov = 2, alcance = 2, jefe = true, frases = { "¡Arrodillaos ante el Rey!", "¡Mis esporas son reales!", "¡Esta cueva es mía!" }, id = "reyHongo", nombre = "Rey Hongo", color = Color3.fromRGB(210, 60, 55), tamano = 9, forma = "reyHongo", stats = { hp = 420, mp = 0, atk = 22, def = 12, mag = 18, spd = 7 }, xp = 160, oro = 120, habilidades = { "esporas", "golpeRey" }, probHabilidad = 0.45 },
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
	{ id = "huerto", nombre = "Huerto invadido", nivel = 1, color = Color3.fromRGB(170, 200, 110), grupos = { { "babosa" }, { "babosa", "hongo" }, { "hongo", "hongo" } } },
	{ id = "pradera", nombre = "Pradera de Vael", nivel = 1, color = Color3.fromRGB(140, 210, 110), grupos = { { "babosa", "babosa" }, { "hongo", "abeja" }, { "abeja", "abeja", "babosa" }, { "lobo" }, { "hongo", "hongo", "babosa" } } },
	{ id = "pantano", nombre = "Pantano Brumoso", nivel = 2, color = Color3.fromRGB(110, 160, 140), grupos = { { "rana", "babosa" }, { "planta", "rana" }, { "fantasma", "rana" }, { "planta", "planta" } } },
	{ id = "bosque", nombre = "Bosque Susurrante", nivel = 3, color = Color3.fromRGB(70, 140, 80), grupos = { { "duende", "lobo" }, { "arana", "duende" }, { "tronco" }, { "lobo", "lobo", "arana" }, { "duende", "duende" } } },
	{ id = "ruinas", nombre = "Ruinas de Ceniza", nivel = 5, color = Color3.fromRGB(170, 150, 130), grupos = { { "esqueleto", "murcielago" }, { "golem" }, { "fantasma", "esqueleto" }, { "esqueleto", "esqueleto", "murcielago" } } },
	{ id = "cueva", nombre = "Cueva del Rey Hongo", nivel = 7, color = Color3.fromRGB(210, 70, 60), grupos = { { "reyHongo", "hongo", "hongo" } } },
	-- historia 2 (tres años después)
	{ id = "picos", nombre = "Picos Nevados", nivel = 8, color = Color3.fromRGB(200, 225, 245), grupos = { { "pinguino", "pinguino" }, { "munecoNieve", "loboBlanco" }, { "espiritu", "pinguino" }, { "loboBlanco", "loboBlanco" }, { "munecoNieve", "espiritu", "pinguino" } } },
	{ id = "cumbre", nombre = "Cumbre del Yeti", nivel = 10, color = Color3.fromRGB(150, 190, 230), grupos = { { "yeti", "munecoNieve", "pinguino" } } },
}

-- ============ FÓRMULAS ============
-- objetos clave que abren el camino (estilo metroidvania) y dónde está cada barrera
Datos.Llaves = {
	cuerda = { nombre = "Cuerda", descripcion = "Para arreglar el puente roto del río.", icono = "huir", color = Color3.fromRGB(210, 170, 110) },
	hacha = { nombre = "Hacha", descripcion = "Corta las zarzas del Bosque.", icono = "espada", color = Color3.fromRGB(200, 200, 215) },
	llave = { nombre = "Llave de piedra", descripcion = "Abre la puerta de las Ruinas.", icono = "estrella", color = Color3.fromRGB(170, 160, 150) },
	farol = { nombre = "Farol", descripcion = "Ilumina la Cueva del Rey Hongo.", icono = "estrella", color = Color3.fromRGB(255, 220, 90) },
	botas = { nombre = "Botas de nieve", descripcion = "Para cruzar la nieve hacia los Picos Nevados.", icono = "huir", color = Color3.fromRGB(150, 110, 80) },
	pico = { nombre = "Pico de hielo", descripcion = "Rompe el muro de hielo de la Cumbre.", icono = "espada", color = Color3.fromRGB(160, 210, 240) },
}
Datos.OrdenLlaves = { "cuerda", "hacha", "llave", "farol", "botas", "pico" }

-- ============ ESTILO DE CARTULINA ============
-- Todos los colores pasan por aquí: se apagan un poco hacia un gris cálido de cartón (nada de colores chillones).
local CARTON = Color3.fromRGB(150, 138, 122)
function Datos.apagar(c: Color3, cuanto: number?): Color3
	return c:Lerp(CARTON, cuanto or 0.1)
end
Datos.TINTA = Color3.fromRGB(48, 38, 34) -- contorno marrón muy oscuro (en vez de negro puro)
local okMaterial, carton = pcall(function()
	return Enum.Material.Cardboard
end)
Datos.MaterialCarton = okMaterial and carton or Enum.Material.SmoothPlastic

--- Pasa todas las piezas a cartulina: textura de cartón, sin neón ni brillos, colores apagados.
--- Los contornos (color tinta) se dejan como están.
function Datos.encartonar(raiz: Instance, tinta: Color3?)
	local t = tinta or Datos.TINTA
	for _, d in raiz:GetDescendants() do
		if d:IsA("BasePart") and d.Transparency < 1 then
			if d.Color ~= t then
				d.Color = Datos.apagar(d.Color, 0.08)
			end
			if d.Material ~= Enum.Material.Glass then
				d.Material = Datos.MaterialCarton
			end
			d.Reflectance = 0
		end
	end
end

-- ============ PERSONALIZAR EL PERSONAJE ============
Datos.Apariencia = {
	pieles = { Color3.fromRGB(255, 224, 189), Color3.fromRGB(241, 194, 150), Color3.fromRGB(214, 160, 112), Color3.fromRGB(170, 115, 75), Color3.fromRGB(120, 78, 50), Color3.fromRGB(180, 220, 160) },
	pelos = { "Calvo", "Corto", "Flequillo", "Melena", "Cresta", "Coleta", "Afro" },
	coloresPelo = { Color3.fromRGB(60, 40, 30), Color3.fromRGB(25, 22, 25), Color3.fromRGB(150, 85, 40), Color3.fromRGB(235, 195, 90), Color3.fromRGB(200, 70, 50), Color3.fromRGB(210, 210, 215), Color3.fromRGB(90, 140, 220), Color3.fromRGB(230, 120, 190) },
	ojos = { "Normales", "Grandes", "Dormilones", "Bizcos", "Enfadados" },
	coloresOjos = { Color3.fromRGB(25, 20, 25), Color3.fromRGB(60, 110, 200), Color3.fromRGB(70, 140, 70), Color3.fromRGB(120, 75, 40), Color3.fromRGB(150, 60, 170) },
	coloresRopa = { Color3.fromRGB(0, 0, 0), Color3.fromRGB(200, 70, 60), Color3.fromRGB(70, 110, 190), Color3.fromRGB(80, 150, 80), Color3.fromRGB(235, 190, 70), Color3.fromRGB(140, 90, 180), Color3.fromRGB(240, 130, 60), Color3.fromRGB(80, 80, 90), Color3.fromRGB(230, 225, 210) },
	gorros = { "De la clase", "Ninguno", "Gorro de lana", "Sombrero vaquero", "Corona de cartón", "Gorra", "Chistera" },
	coloresGorro = { Color3.fromRGB(200, 70, 60), Color3.fromRGB(70, 110, 190), Color3.fromRGB(80, 150, 80), Color3.fromRGB(235, 190, 70), Color3.fromRGB(140, 90, 180), Color3.fromRGB(60, 55, 60), Color3.fromRGB(150, 100, 60) },
	accesorios = { "Ninguno", "Gafas", "Gafas de sol", "Bigote", "Tirita", "Parche de pirata", "Pato en la cabeza", "Pajarita" },
}
-- el primer color de ropa (negro) significa "el color de mi clase"
Datos.CAMPOS_APARIENCIA = { piel = "pieles", pelo = "pelos", colorPelo = "coloresPelo", ojos = "ojos", colorOjos = "coloresOjos", ropa = "coloresRopa", gorro = "gorros", colorGorro = "coloresGorro", accesorio = "accesorios" }

function Datos.aparienciaInicial(): { [string]: any }
	return { piel = 1, pelo = 2, colorPelo = 1, ojos = 1, colorOjos = 1, ropa = 1, gorro = 1, colorGorro = 1, accesorio = 1, nombre = "" }
end

--- Deja solo valores válidos (lo que llegue del cliente no es de fiar).
function Datos.validarApariencia(t: any): { [string]: any }
	local r = Datos.aparienciaInicial()
	if type(t) ~= "table" then
		return r
	end
	for campo, lista in Datos.CAMPOS_APARIENCIA do
		local v = tonumber(t[campo])
		local n = #Datos.Apariencia[lista]
		if v then
			r[campo] = math.clamp(math.floor(v), 1, n)
		end
	end
	if type(t.nombre) == "string" then
		r.nombre = string.sub(string.gsub(t.nombre, "[%c]", ""), 1, 16)
	end
	return r
end

Datos.MAX_EQUIPO = 4

-- ===================== ENCARGOS (misiones secundarias del tablón de la plaza) =====================
-- tipo: "cazar" (enemigo, cantidad), "zona" (ganar peleas en una zona), "rocas" (romper rocas en combate),
-- "secretos" (encontrar secretos) o "entregar" (dar objetos). requiere = "final" para los de la historia 2.
export type Encargo = { id: string, titulo: string, de: string, texto: string, tipo: string, objetivo: string?, cantidad: number, oro: number, xp: number, objeto: string?, mejora: string?, requiere: string? }
Datos.Encargos = {
	babosas = { id = "babosas", titulo = "Babosas fuera", de = "Granjero Tomás", texto = "Las babosas se comen mis coles otra vez. Échame a 6.", tipo = "cazar", objetivo = "babosa", cantidad = 6, oro = 30, xp = 20 },
	setas = { id = "setas", titulo = "Setas rebeldes", de = "Abuela Rosa", texto = "Los hongos saltarines me pisan las flores. Quítame 8 de encima.", tipo = "cazar", objetivo = "hongo", cantidad = 8, oro = 40, xp = 25 },
	abejas = { id = "abejas", titulo = "Miel sin picaduras", de = "La panadera", texto = "Quiero miel para los bollos, pero las abejas pican. Espanta a 4.", tipo = "cazar", objetivo = "abeja", cantidad = 4, oro = 35, xp = 25, objeto = "pocion" },
	lobos = { id = "lobos", titulo = "Aullidos de noche", de = "La guardia", texto = "Los lobos sombríos no dejan dormir a nadie. Vence a 3.", tipo = "cazar", objetivo = "lobo", cantidad = 3, oro = 50, xp = 40, mejora = "botas" },
	ranas = { id = "ranas", titulo = "Concierto de ranas", de = "Ermitaño Fermín", texto = "¡Croac, croac, toda la noche! Gana 3 peleas en el Pantano.", tipo = "zona", objetivo = "pantano", cantidad = 3, oro = 60, xp = 50, objeto = "eter" },
	fantasmas = { id = "fantasmas", titulo = "Sábanas que flotan", de = "La lavandera", texto = "Se me escapan las sábanas… ah no, son fantasmas. Vence a 3.", tipo = "cazar", objetivo = "fantasma", cantidad = 3, oro = 70, xp = 60, mejora = "espejo" },
	lena = { id = "lena", titulo = "Leña segura", de = "El herrero", texto = "Necesito leña del Bosque, pero da miedo. Gana 3 peleas allí.", tipo = "zona", objetivo = "bosque", cantidad = 3, oro = 80, xp = 70 },
	huesos = { id = "huesos", titulo = "Huesos sueltos", de = "Bigotes, el perro de la plaza", texto = "¡Guau! (Quiere que venzas a 5 esqueletos. Y los huesos, para él.)", tipo = "cazar", objetivo = "esqueleto", cantidad = 5, oro = 90, xp = 80, mejora = "diente" },
	mimico = { id = "mimico", titulo = "Cofres con dientes", de = "Madame Zoé", texto = "Veo… un cofre que muerde en tu futuro. Véncelo y te pago.", tipo = "cazar", objetivo = "mimico", cantidad = 1, oro = 100, xp = 80 },
	rocas = { id = "rocas", titulo = "Picapedrero", de = "El herrero", texto = "Me falta piedra para la fragua. Rompe 10 rocas en combate.", tipo = "rocas", cantidad = 10, oro = 80, xp = 60, mejora = "muelles" },
	curioso = { id = "curioso", titulo = "Curiosidad", de = "Niño Lucas", texto = "¡Dicen que Vael está lleno de secretos! Encuentra 4.", tipo = "secretos", cantidad = 4, oro = 60, xp = 40, mejora = "lupa" },
	botiquin = { id = "botiquin", titulo = "Botiquín", de = "Posadera Lola", texto = "Con tanto héroe herido me quedo sin pociones. Tráeme 3.", tipo = "entregar", objetivo = "pocion", cantidad = 3, oro = 120, xp = 50 },
	pinguinos = { id = "pinguinos", titulo = "Pescado robado", de = "El Rey Hongo", texto = "¡Los pingüinos bandidos me roban el pescado del guiso! Vence a 5.", tipo = "cazar", objetivo = "pinguino", cantidad = 5, oro = 150, xp = 120, mejora = "gafas", requiere = "final" },
	nieve = { id = "nieve", titulo = "Muñecos sin nariz", de = "Niño Lucas", texto = "Quiero zanahorias para mis muñecos… ¡los de verdad las tienen! Vence a 4 muñecos de nieve.", tipo = "cazar", objetivo = "munecoNieve", cantidad = 4, oro = 150, xp = 120, requiere = "final" },
}
Datos.OrdenEncargos = { "babosas", "setas", "abejas", "lobos", "ranas", "fantasmas", "lena", "huesos", "mimico", "rocas", "curioso", "botiquin", "pinguinos", "nieve" }
Datos.MAX_ENCARGOS = 3

-- ===================== COMPAÑEROS =====================
-- Vecinos que se unen a tu aventura y pelean a tu lado (los maneja el juego). Se llevan de uno en uno, o ninguno
-- ("ir solo"). Se eligen en la mochila. Cada uno se consigue en un momento de la historia.
export type Companero = { id: string, nombre: string, vecino: string, clase: string, habilidad: string, frases: { string }, descripcion: string, como: string }
Datos.Companeros = {
	tomas = { id = "tomas", nombre = "Tomás", vecino = "4242", clase = "guerrero", habilidad = "golpeFuerte", frases = { "¡Fuera de mi huerto!", "¡Esta horca no es de adorno!", "¡Por mis coles!" }, descripcion = "Granjero con horca. Aguanta en primera fila y empuja.", como = "Echa a las babosas del Huerto invadido." },
	lucas = { id = "lucas", nombre = "Lucas", vecino = "5", clase = "arquero", habilidad = "disparoCerte", frases = { "¡Tirachinas en mano!", "¿Le he dado? ¡Le he dado!", "¡Esto se lo cuento a mi madre!" }, descripcion = "Niño con tirachinas. Dispara desde lejos.", como = "Devuélvele la pelota a Lucas." },
	fermin = { id = "fermin", nombre = "Fermín", vecino = "60606", clase = "sanador", habilidad = "curar", frases = { "Las setas buenas curan.", "Respira hondo, joven.", "¡Ay, mi espalda!" }, descripcion = "Ermitaño. Cura al equipo y pega con su bastón.", como = "Llévale las 3 setas brillantes a Fermín." },
}
Datos.OrdenCompaneros = { "tomas", "lucas", "fermin" }

--- Estadísticas de un compañero: las de su clase a tu nivel, algo más flojas que un héroe.
function Datos.statsCompanero(cid: string, nivel: number): Stats
	local def = Datos.Companeros[cid]
	local s = table.clone(Datos.statsDe(def.clase, nivel, {}))
	s.hp = math.floor(s.hp * 0.8)
	s.atk = math.floor(s.atk * 0.85)
	s.mag = math.floor(s.mag * 0.85)
	return s
end
Datos.TIEMPO_TURNO = 20 -- segundos para elegir acción

-- ============ CAMPO DE BATALLA CON CASILLAS ============
Datos.Rejilla = { columnas = 10, filas = 4, ancho = 3.6, fondo = 3.0 }
-- cosas que salen en el campo: obstáculos (bloquean y cubren de los disparos) y trampas (se activan al pisarlas)
Datos.Casillas = {
	roca = { nombre = "Roca", bloquea = true },
	arbusto = { nombre = "Arbusto", bloquea = true },
	pinchos = { nombre = "Pinchos", trampa = true, dano = 0.12, texto = "pisa unos pinchos. ¡Auch!" },
	barro = { nombre = "Barro", trampa = true, frena = true, texto = "se queda atascado en el barro" },
	seta = { nombre = "Seta curativa", trampa = true, cura = 0.18, texto = "se come una seta del suelo. ¡Ñam!" },
}

-- ============ MEJORAS (se juntan y se combinan, como en los roguelikes) ============
export type Mejora = { id: string, nombre: string, descripcion: string, rareza: "comun" | "rara" | "legendaria", icono: string, color: Color3, mods: { [string]: any } }

Datos.Mejoras = {
	calcetin = { id = "calcetin", nombre = "Calcetín sudado", descripcion = "+15 % de vida. Huele a victoria (y a pies).", rareza = "comun", icono = "corazon", color = Color3.fromRGB(240, 240, 220), mods = { hpMult = 0.15 } },
	cuerno = { id = "cuerno", nombre = "Cuerno de cabra", descripcion = "+3 de ataque.", rareza = "comun", icono = "espada", color = Color3.fromRGB(240, 225, 190), mods = { atk = 3 } },
	muelles = { id = "muelles", nombre = "Zapatillas con muelles", descripcion = "+1 casilla de movimiento. ¡Boing!", rareza = "comun", icono = "huir", color = Color3.fromRGB(120, 200, 255), mods = { mov = 1 } },
	lupa = { id = "lupa", nombre = "Lupa de la abuela", descripcion = "+12 % de crítico.", rareza = "comun", icono = "estrella", color = Color3.fromRGB(255, 220, 120), mods = { crit = 0.12 } },
	pan = { id = "pan", nombre = "Pan duro", descripcion = "+4 de defensa. Lleva ahí desde el martes.", rareza = "comun", icono = "escudo", color = Color3.fromRGB(220, 170, 100), mods = { def = 4 } },
	tostadora = { id = "tostadora", nombre = "Tostadora mágica", descripcion = "+4 de magia. Tuesta hechizos.", rareza = "comun", icono = "magia", color = Color3.fromRGB(200, 200, 215), mods = { mag = 4 } },
	chocolate = { id = "chocolate", nombre = "Moneda de chocolate", descripcion = "+3 de velocidad. El azúcar ayuda.", rareza = "comun", icono = "moneda", color = Color3.fromRGB(150, 95, 55), mods = { spd = 3 } },
	bolsillo = { id = "bolsillo", nombre = "Bolsillo agujereado", descripcion = "+50 % de oro. No preguntes cómo.", rareza = "comun", icono = "moneda", color = Color3.fromRGB(255, 205, 80), mods = { oro = 0.5 } },
	pluma = { id = "pluma", nombre = "Pluma de gallina", descripcion = "12 % de esquivar los golpes.", rareza = "comun", icono = "huir", color = Color3.new(1, 1, 1), mods = { esquiva = 0.12 } },
	botas = { id = "botas", nombre = "Botas de barro", descripcion = "Las trampas no te hacen nada.", rareza = "comun", icono = "escudo", color = Color3.fromRGB(130, 90, 55), mods = { inmuneTrampas = true } },
	diente = { id = "diente", nombre = "Diente de leche", descripcion = "Te curas el 15 % del daño que haces.", rareza = "rara", icono = "corazon", color = Color3.new(1, 1, 1), mods = { robo = 0.15 } },
	espejo = { id = "espejo", nombre = "Espejo roto", descripcion = "25 % de devolver la mitad del daño. Siete años de mala suerte… para ellos.", rareza = "rara", icono = "escudo", color = Color3.fromRGB(170, 220, 255), mods = { reflejo = 0.25 } },
	chicle = { id = "chicle", nombre = "Chicle pegajoso", descripcion = "Tus empujones llegan 1 casilla más lejos.", rareza = "rara", icono = "huir", color = Color3.fromRGB(255, 140, 200), mods = { empuje = 1 } },
	muelle = { id = "muelle", nombre = "Muelle de colchón", descripcion = "+10 de daño cuando estampas a alguien.", rareza = "rara", icono = "estrella", color = Color3.fromRGB(190, 190, 205), mods = { choque = 10 } },
	tirita = { id = "tirita", nombre = "Tirita gigante", descripcion = "Recuperas un 6 % de vida en cada turno.", rareza = "rara", icono = "corazon", color = Color3.fromRGB(240, 190, 150), mods = { regen = 0.06 } },
	huevo = { id = "huevo", nombre = "Huevo podrido", descripcion = "25 % de envenenar al golpear.", rareza = "rara", icono = "pocion", color = Color3.fromRGB(190, 210, 120), mods = { venenoGolpe = 0.25 } },
	gafas = { id = "gafas", nombre = "Gafas 3D", descripcion = "+1 de alcance y +20 % de daño a distancia.", rareza = "rara", icono = "estrella", color = Color3.fromRGB(240, 80, 90), mods = { alcance = 1, distancia = 0.2 } },
	sarten = { id = "sarten", nombre = "Sartén de la abuela", descripcion = "Al defender no recibes nada de daño.", rareza = "rara", icono = "escudo", color = Color3.fromRGB(70, 70, 80), mods = { defensaTotal = true } },
	petardo = { id = "petardo", nombre = "Petardo", descripcion = "Cuando matas a alguien, explota y hace 15 a los de al lado.", rareza = "rara", icono = "estrella", color = Color3.fromRGB(240, 70, 60), mods = { explota = 15 } },
	corona = { id = "corona", nombre = "Corona de cartón", descripcion = "+20 % a todo. Eres el rey (de cartón).", rareza = "legendaria", icono = "estrella", color = Color3.fromRGB(255, 210, 60), mods = { todo = 0.2 } },
	calavera = { id = "calavera", nombre = "Calavera de goma", descripcion = "Una vez por combate, revives con un 30 % de vida.", rareza = "legendaria", icono = "corazon", color = Color3.fromRGB(240, 240, 240), mods = { revivir = true } },
	capa = { id = "capa", nombre = "Capa de toalla", descripcion = "+2 de movimiento, +1 de alcance y vuelas sobre los obstáculos.", rareza = "legendaria", icono = "huir", color = Color3.fromRGB(220, 60, 70), mods = { mov = 2, alcance = 1, vuela = true } },
	dado = { id = "dado", nombre = "Dado trucado", descripcion = "Tu daño se multiplica al azar entre ×0,5 y ×2,5.", rareza = "legendaria", icono = "estrella", color = Color3.fromRGB(250, 250, 250), mods = { dado = true } },
} :: { [string]: Mejora }

Datos.OrdenMejoras = { "calcetin", "cuerno", "muelles", "lupa", "pan", "tostadora", "chocolate", "bolsillo", "pluma", "botas", "diente", "espejo", "chicle", "muelle", "tirita", "huevo", "gafas", "sarten", "petardo", "corona", "calavera", "capa", "dado" }
Datos.PrecioRareza = { comun = 60, rara = 140, legendaria = 320 }
Datos.ColorRareza = { comun = Color3.fromRGB(150, 200, 255), rara = Color3.fromRGB(190, 120, 255), legendaria = Color3.fromRGB(255, 190, 50) }

-- combinaciones: si tienes las dos mejoras, se activa un efecto extra
Datos.Sinergias = {
	{ id = "olor", nombre = "¡Olor mortal!", piezas = { "calcetin", "huevo" }, descripcion = "Al empezar tu turno, envenenas a los que tengas pegados.", mods = { auraVeneno = true } },
	{ id = "pinball", nombre = "¡Bola de pinball!", piezas = { "chicle", "muelle" }, descripcion = "Empujas 1 casilla más y el golpe al estampar se dobla.", mods = { empuje = 1, choqueDoble = true } },
	{ id = "fiesta", nombre = "¡Fiesta explosiva!", piezas = { "petardo", "tostadora" }, descripcion = "La explosión del petardo es doble y llega más lejos.", mods = { explotaDoble = true } },
	{ id = "vampiro", nombre = "¡Vampiro con tirita!", piezas = { "diente", "tirita" }, descripcion = "Robas y te curas el doble.", mods = { robo = 0.15, regen = 0.06 } },
	{ id = "abuela", nombre = "¡La abuela al poder!", piezas = { "lupa", "sarten" }, descripcion = "+15 % de crítico y al defender te curas un 10 %.", mods = { crit = 0.15, defensaCura = 0.1 } },
}

--- Suma los efectos de todas las mejoras (y combinaciones) de un jugador.
function Datos.efectosDe(mejoras: { string }?): ({ [string]: any }, { string })
	local m: { [string]: any } = {}
	local tiene: { [string]: boolean } = {}
	local function sumar(mods: { [string]: any })
		for k, v in mods do
			if type(v) == "number" then
				m[k] = (m[k] or 0) + v
			else
				m[k] = v
			end
		end
	end
	for _, id in mejoras or {} do
		local def = Datos.Mejoras[id]
		if def then
			tiene[id] = true
			sumar(def.mods)
		end
	end
	local activas = {}
	for _, s in Datos.Sinergias do
		if tiene[s.piezas[1]] and tiene[s.piezas[2]] then
			sumar(s.mods)
			table.insert(activas, s.nombre)
		end
	end
	return m, activas
end

--- Tres mejoras al azar según la rareza. jefe = más raras.
function Datos.ofertaMejoras(rng: Random, jefe: boolean?): { string }
	local pesos = jefe and { comun = 0, rara = 60, legendaria = 40 } or { comun = 64, rara = 29, legendaria = 7 }
	local elegidas: { string } = {}
	local intentos = 0
	while #elegidas < 3 and intentos < 100 do
		intentos += 1
		local tirada = rng:NextNumber() * 100
		local rareza = tirada < pesos.comun and "comun" or (tirada < pesos.comun + pesos.rara and "rara" or "legendaria")
		local candidatas = {}
		for _, id in Datos.OrdenMejoras do
			if Datos.Mejoras[id].rareza == rareza and not table.find(elegidas, id) then
				table.insert(candidatas, id)
			end
		end
		if #candidatas > 0 then
			table.insert(elegidas, candidatas[rng:NextInteger(1, #candidatas)])
		end
	end
	return elegidas
end

function Datos.xpParaNivel(nivel: number): number
	return math.floor(25 * nivel ^ 1.5)
end

function Datos.statsDe(claseId: string, nivel: number, mejoras: { string }?, bonos: { [string]: number }?): Stats
	local c = Datos.Clases[claseId]
	local n = nivel - 1
	local m = Datos.efectosDe(mejoras)
	local todo = 1 + (m.todo or 0)
	local b = bonos or {}
	return {
		hp = math.floor((c.base.hp + c.crece.hp * n + (b.hp or 0)) * (1 + (m.hpMult or 0)) * todo),
		mp = math.floor((c.base.mp + c.crece.mp * n + (b.mp or 0)) * todo),
		atk = math.floor((c.base.atk + c.crece.atk * n + (m.atk or 0) + (b.atk or 0)) * todo),
		def = math.floor((c.base.def + c.crece.def * n + (m.def or 0) + (b.def or 0)) * todo),
		mag = math.floor((c.base.mag + c.crece.mag * n + (m.mag or 0) + (b.mag or 0)) * todo),
		spd = math.max(1, math.floor((c.base.spd + c.crece.spd * n + (m.spd or 0) + (b.spd or 0)) * todo)),
	}
end

-- ===================== EQUIPAMIENTO (armas, armaduras y amuletos; se compran y mejoran en la herrería) =====================
-- hueco: "arma" | "armadura" | "amuleto". clases: quién puede llevarla (nil = todos). forma: cómo se dibuja el arma.
-- Se guarda en el perfil: progreso.armas = { [id] = mejora (0 a 3) } y progreso.equipo = { arma, armadura, amuleto }.
export type Pieza = { id: string, nombre: string, hueco: string, descripcion: string, stats: { [string]: number }, precio: number, nivel: number, color: Color3, forma: string?, clases: { [string]: boolean }? }
Datos.Equipo = {
	-- armas
	espadaMadera = { id = "espadaMadera", nombre = "Espada de madera", hueco = "arma", descripcion = "La de toda la vida. Astillas incluidas.", stats = { atk = 3 }, precio = 40, nivel = 1, color = Color3.fromRGB(190, 140, 80), forma = "espada", clases = { guerrero = true } },
	espadaHierro = { id = "espadaHierro", nombre = "Espada de hierro", hueco = "arma", descripcion = "Corta de verdad. No la uses para el pan.", stats = { atk = 7 }, precio = 140, nivel = 3, color = Color3.fromRGB(205, 210, 220), forma = "espada", clases = { guerrero = true } },
	hachaLenador = { id = "hachaLenador", nombre = "Hacha de leñador", hueco = "arma", descripcion = "Pega fuerte, pero pesa lo suyo.", stats = { atk = 12, spd = -1 }, precio = 280, nivel = 5, color = Color3.fromRGB(180, 185, 195), forma = "hacha", clases = { guerrero = true } },
	varitaRama = { id = "varitaRama", nombre = "Varita de rama", hueco = "arma", descripcion = "Un palo con mucha fe.", stats = { mag = 4 }, precio = 45, nivel = 1, color = Color3.fromRGB(130, 200, 220), forma = "baston", clases = { maga = true } },
	baculoCristal = { id = "baculoCristal", nombre = "Báculo de cristal", hueco = "arma", descripcion = "Brilla un poquito. Bastante, en realidad.", stats = { mag = 10, mp = 10 }, precio = 260, nivel = 4, color = Color3.fromRGB(200, 140, 240), forma = "baston", clases = { maga = true } },
	arcoJunco = { id = "arcoJunco", nombre = "Arco de junco", hueco = "arma", descripcion = "Ligero como una pluma. Y casi igual de fuerte.", stats = { atk = 4 }, precio = 45, nivel = 1, color = Color3.fromRGB(150, 120, 70), forma = "arco", clases = { arquero = true } },
	arcoTejo = { id = "arcoTejo", nombre = "Arco de tejo", hueco = "arma", descripcion = "Llega lejos y no falla. Casi nunca.", stats = { atk = 9, spd = 1 }, precio = 250, nivel = 4, color = Color3.fromRGB(110, 70, 40), forma = "arco", clases = { arquero = true } },
	cayadoHierbas = { id = "cayadoHierbas", nombre = "Cayado de hierbas", hueco = "arma", descripcion = "Huele a manzanilla. Cura el alma.", stats = { mag = 4, hp = 10 }, precio = 45, nivel = 1, color = Color3.fromRGB(120, 190, 100), forma = "baston", clases = { sanador = true } },
	cayadoLuz = { id = "cayadoLuz", nombre = "Cayado de luz", hueco = "arma", descripcion = "Por la noche sirve de farol.", stats = { mag = 9, hp = 20 }, precio = 250, nivel = 4, color = Color3.fromRGB(255, 230, 130), forma = "baston", clases = { sanador = true } },
	cucharonCombate = { id = "cucharonCombate", nombre = "Cucharón de combate", hueco = "arma", descripcion = "Réplica del Cucharón de Vael. Para remover… cabezas.", stats = { atk = 8, mag = 8 }, precio = 420, nivel = 6, color = Color3.fromRGB(205, 155, 90), forma = "cucharon" },
	-- armaduras
	chalecoCarton = { id = "chalecoCarton", nombre = "Chaleco de cartón", hueco = "armadura", descripcion = "Si llueve, mejor ponte a cubierto.", stats = { def = 3, hp = 10 }, precio = 40, nivel = 1, color = Color3.fromRGB(190, 160, 115) },
	cotaMalla = { id = "cotaMalla", nombre = "Cota de malla", hueco = "armadura", descripcion = "Hace clinc, clinc al andar.", stats = { def = 7, hp = 25, spd = -1 }, precio = 180, nivel = 3, color = Color3.fromRGB(160, 165, 175) },
	abrigoPieles = { id = "abrigoPieles", nombre = "Abrigo de pieles", hueco = "armadura", descripcion = "Calentito para los Picos Nevados.", stats = { def = 6, hp = 35 }, precio = 240, nivel = 5, color = Color3.fromRGB(170, 120, 80) },
	armaduraCazos = { id = "armaduraCazos", nombre = "Armadura de cazos", hueco = "armadura", descripcion = "Hecha con los cazos viejos del Gran Guiso. Suena a cocina.", stats = { def = 12, hp = 45, spd = -2 }, precio = 450, nivel = 7, color = Color3.fromRGB(120, 120, 135) },
	-- amuletos
	dienteLobo = { id = "dienteLobo", nombre = "Colmillo de lobo", hueco = "amuleto", descripcion = "Te sientes más rápido. Y con ganas de aullar.", stats = { spd = 2, atk = 1 }, precio = 70, nivel = 2, color = Color3.fromRGB(240, 235, 220) },
	colganteSeta = { id = "colganteSeta", nombre = "Colgante de seta", hueco = "amuleto", descripcion = "Una seta brillante. Fermín no sabe que la tienes.", stats = { mag = 4, mp = 10 }, precio = 120, nivel = 3, color = Color3.fromRGB(150, 220, 255) },
	cascabel = { id = "cascabel", nombre = "Cascabel de la suerte", hueco = "amuleto", descripcion = "Lo encontraron junto a un gato morado. Tilín, tilín.", stats = { spd = 3, def = 2 }, precio = 160, nivel = 3, color = Color3.fromRGB(240, 200, 60) },
	corazonPiedra = { id = "corazonPiedra", nombre = "Corazón de piedra", hueco = "amuleto", descripcion = "Late despacito. Te da mucha vida.", stats = { hp = 45 }, precio = 220, nivel = 4, color = Color3.fromRGB(200, 90, 100) },
	estrellaHielo = { id = "estrellaHielo", nombre = "Estrella de hielo", hueco = "amuleto", descripcion = "Nunca se derrite. Ni en el bolsillo.", stats = { def = 4, mag = 4, hp = 20 }, precio = 300, nivel = 6, color = Color3.fromRGB(190, 230, 255) },
}
Datos.OrdenEquipo = { "espadaMadera", "espadaHierro", "hachaLenador", "varitaRama", "baculoCristal", "arcoJunco", "arcoTejo", "cayadoHierbas", "cayadoLuz", "cucharonCombate", "chalecoCarton", "cotaMalla", "abrigoPieles", "armaduraCazos", "dienteLobo", "colganteSeta", "cascabel", "corazonPiedra", "estrellaHielo" }
Datos.ArmaInicial = { guerrero = "espadaMadera", maga = "varitaRama", arquero = "arcoJunco", sanador = "cayadoHierbas" }
Datos.MAX_MEJORA_EQUIPO = 3
Datos.NOMBRES_STAT = { hp = "VIDA", mp = "MANÁ", atk = "ATQ", def = "DEF", mag = "MAG", spd = "VEL" }

--- Estadísticas de una pieza con su mejora (+1, +2, +3: un 35 % más cada una).
function Datos.statsPieza(id: string, mejora: number?): { [string]: number }
	local p = Datos.Equipo[id]
	local r = {}
	if not p then
		return r
	end
	local f = 1 + 0.35 * (mejora or 0)
	for k, v in p.stats do
		r[k] = v > 0 and math.floor(v * f + 0.5) or v
	end
	return r
end

--- Lo que cuesta mejorar una pieza al siguiente nivel.
function Datos.precioMejora(id: string, mejora: number): number
	local p = Datos.Equipo[id]
	return p and math.floor(p.precio * 0.6 * (mejora + 1)) or 0
end

function Datos.puedeLlevar(id: string, clase: string?): boolean
	local p = Datos.Equipo[id]
	return p ~= nil and (p.clases == nil or (clase ~= nil and p.clases[clase] == true))
end

--- Suma de lo que da todo lo equipado (a partir de progreso.equipo y progreso.armas).
function Datos.bonosEquipo(progreso: any, clase: string?): { [string]: number }
	local total: { [string]: number } = {}
	local equipo = progreso and progreso.equipo or {}
	local armas = progreso and progreso.armas or {}
	for _, id in equipo do
		if type(id) == "string" and armas[id] ~= nil and Datos.puedeLlevar(id, clase) then
			for k, v in Datos.statsPieza(id, armas[id]) do
				total[k] = (total[k] or 0) + v
			end
		end
	end
	return total
end

--- Texto corto de estadísticas: "+7 ATQ · -1 VEL".
function Datos.textoStats(st: { [string]: number }): string
	local partes = {}
	for _, k in { "hp", "mp", "atk", "def", "mag", "spd" } do
		local v = st[k]
		if v and v ~= 0 then
			table.insert(partes, (v > 0 and "+" or "") .. v .. " " .. Datos.NOMBRES_STAT[k])
		end
	end
	return table.concat(partes, " · ")
end

--- Daño: (atributo × poder) contra la defensa, con un 10 % de variación. Nunca menos de 1.
function Datos.dano(atributo: number, poder: number, defensa: number, rng: Random): number
	local bruto = atributo * poder * (rng:NextNumber(0.9, 1.1))
	local reducido = bruto * (100 / (100 + defensa * 6))
	return math.max(1, math.floor(reducido + 0.5))
end

return Datos
