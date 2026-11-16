--!strict
-- Música y efectos de Crónicas de Vael (originales, hechos para el juego: carpeta audio/ del proyecto).
-- Roblox solo deja usar sonidos subidos a tu cuenta, así que:
--   1. En Studio: Ventana → Gestor de recursos → Importación masiva → elige los 5 archivos de la carpeta audio/.
--   2. Cuando se suban, clic derecho en cada uno → Copiar ID del recurso.
--   3. Pega cada número aquí abajo, entre las comillas (por ejemplo, efectos = "rbxassetid://1234567890").
-- Mientras esté vacío, el juego funciona igual pero sin sonido (salvo los pasos y saltos que trae Roblox).

local Sonidos = {}

Sonidos.IDS = {
	efectos = "", -- vael-efectos.ogg (todos los efectos en un solo archivo)
	ciudad = "", -- vael-musica-ciudad.ogg (ciudad y menú)
	aventura = "", -- vael-musica-aventura.ogg (pradera, pantano, bosque)
	combate = "", -- vael-musica-combate.ogg
	jefe = "", -- vael-musica-jefe.ogg (ruinas, cueva y Rey Hongo)
}

-- dónde empieza cada efecto dentro de vael-efectos.ogg (segundos) y cuánto dura
Sonidos.Efectos = {
	paso = { 0, 0.25 },
	paso2 = { 1, 0.25 },
	salto = { 2, 0.45 },
	click = { 3, 0.15 },
	hover = { 4, 0.12 },
	golpe = { 5, 0.4 },
	corte = { 6, 0.4 },
	fuego = { 7, 0.8 },
	rayo = { 8, 0.8 },
	flecha = { 9, 0.5 },
	cura = { 10, 0.9 },
	veneno = { 11, 0.7 },
	escudo = { 12, 0.6 },
	critico = { 13, 0.7 },
	moneda = { 14, 0.5 },
	cofre = { 15, 0.9 },
	mejora = { 16, 0.95 },
	nivel = { 17, 0.95 },
	victoria = { 18, 2.6 },
	derrota = { 21, 2.6 },
	blip = { 24, 0.08 },
	llave = { 25, 0.95 },
	brillo = { 26, 0.8 },
	palanca = { 27, 0.5 },
	vasos = { 28, 0.3 },
	boing = { 29, 0.6 },
	explosion = { 30, 0.9 },
	pop = { 31, 0.2 },
	poof = { 32, 0.6 },
	aviso = { 33, 0.4 },
	psst = { 34, 0.6 },
}

return Sonidos
