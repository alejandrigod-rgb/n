--!strict
-- Efectos de combate en estilo dibujo: proyectiles, cortes, explosiones, rayos, curas y onomatopeyas
-- ("¡ZAS!", "¡FUUM!"). Se dibujan en pantalla encima del mundo, en el punto donde están los muñecos,
-- y se animan con TweenService (60 fps).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Efectos = {}

local NEGRO = Color3.fromRGB(48, 38, 34)
local camara = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.Name = "VaelEfectos"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = -1 -- por debajo de los menús
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local function tw(o: Instance, props: { [string]: any }, t: number, estilo: Enum.EasingStyle?, dir: Enum.EasingDirection?): Tween
	local x = TweenService:Create(o, TweenInfo.new(t, estilo or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	x:Play()
	return x
end

local function pantalla(pos: Vector3): Vector2
	local v = camara:WorldToViewportPoint(pos)
	return Vector2.new(v.X, v.Y)
end

local function forma(p: Vector2, w: number, h: number, color: Color3, radio: number?, rot: number?, borde: number?, z: number?): Frame
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromOffset(p.X, p.Y)
	f.Size = UDim2.fromOffset(w, h)
	f.BackgroundColor3 = color:Lerp(Color3.fromRGB(150, 138, 122), 0.18) -- colores de cartulina
	f.BorderSizePixel = 0
	f.Rotation = rot or 0
	f.ZIndex = z or 2
	if radio then
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(radio, 0)
		c.Parent = f
	end
	if borde ~= 0 then
		local s = Instance.new("UIStroke")
		s.Thickness = borde or 3
		s.Color = NEGRO
		s.Parent = f
	end
	f.Parent = gui
	return f
end

local function borrarTras(o: Instance, t: number)
	task.delay(t, function()
		o:Destroy()
	end)
end

local function desvanecer(f: GuiObject, t: number, retraso: number?)
	task.delay(retraso or 0, function()
		if f.Parent then
			tw(f, { BackgroundTransparency = 1 }, t)
			local s = f:FindFirstChildOfClass("UIStroke")
			if s then
				tw(s, { Transparency = 1 }, t)
			end
		end
	end)
	borrarTras(f, (retraso or 0) + t + 0.05)
end

-- ===================== PIEZAS DE EFECTO =====================
function Efectos.onomatopeya(p: Vector2, texto: string, color: Color3, grande: boolean?)
	local t = Instance.new("TextLabel")
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.fromOffset(p.X + math.random(-30, 30), p.Y - 60)
	t.Size = UDim2.fromOffset(grande and 300 or 220, grande and 110 or 80)
	t.BackgroundTransparency = 1
	t.Text = texto
	t.Font = Enum.Font.PermanentMarker
	t.TextScaled = true
	t.TextColor3 = color:Lerp(Color3.fromRGB(150, 138, 122), 0.15)
	t.Rotation = math.random(-14, 14)
	t.ZIndex = 6
	local s = Instance.new("UIStroke")
	s.Thickness = 5
	s.Color = NEGRO
	s.Parent = t
	local e = Instance.new("UIScale")
	e.Scale = 0.2
	e.Parent = t
	t.Parent = gui
	tw(e, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
	task.delay(0.55, function()
		tw(t, { TextTransparency = 1, Position = t.Position - UDim2.fromOffset(0, 40) }, 0.35)
		tw(s, { Transparency = 1 }, 0.35)
	end)
	borrarTras(t, 1)
end

function Efectos.estallido(p: Vector2, colores: { Color3 }, n: number, alcance: number)
	for k = 1, n do
		local a = (k / n) * math.pi * 2 + math.random() * 0.4
		local d = math.random(14, 26)
		local f = forma(p, d, d, colores[(k % #colores) + 1], 0.5, 0, 2, 4)
		local destino = p + Vector2.new(math.cos(a), math.sin(a)) * alcance * (0.6 + math.random() * 0.5)
		tw(f, { Position = UDim2.fromOffset(destino.X, destino.Y), Size = UDim2.fromOffset(4, 4) }, 0.5, Enum.EasingStyle.Quart)
		desvanecer(f, 0.2, 0.35)
	end
	local nube = forma(p, 20, 20, colores[1], 0.5, 0, 3, 3)
	tw(nube, { Size = UDim2.fromOffset(alcance * 1.4, alcance * 1.4) }, 0.25, Enum.EasingStyle.Back)
	desvanecer(nube, 0.25, 0.15)
end

function Efectos.corte(p: Vector2, color: Color3?, escala: number?)
	local s = escala or 1
	for k = -1, 1 do
		local f = forma(p + Vector2.new(k * 16, k * 10) * s, 4, 10 * s, color or Color3.new(1, 1, 1), 0.5, -50, 2, 5)
		tw(f, { Size = UDim2.fromOffset(150 * s, 12 * s) }, 0.12, Enum.EasingStyle.Quart)
		desvanecer(f, 0.2, 0.12)
	end
end

function Efectos.anillo(p: Vector2, color: Color3, tam: number)
	local f = forma(p, 20, 20, color, 0.5, 0, 0, 3)
	f.BackgroundTransparency = 1
	local s = Instance.new("UIStroke")
	s.Thickness = 8
	s.Color = color
	s.Parent = f
	tw(f, { Size = UDim2.fromOffset(tam, tam) }, 0.45, Enum.EasingStyle.Quart)
	tw(s, { Transparency = 1, Thickness = 1 }, 0.45)
	borrarTras(f, 0.5)
end

function Efectos.rayo(p: Vector2)
	local arriba = p - Vector2.new(0, 260)
	local puntos = { arriba }
	for k = 1, 4 do
		table.insert(puntos, arriba:Lerp(p, k / 4) + Vector2.new(k < 4 and math.random(-40, 40) or 0, 0))
	end
	for k = 1, #puntos - 1 do
		local a, b = puntos[k], puntos[k + 1]
		local medio = (a + b) / 2
		local dif = b - a
		local f = forma(medio, dif.Magnitude + 6, 12, Color3.fromRGB(255, 240, 90), 0.5, math.deg(math.atan2(dif.Y, dif.X)), 3, 5)
		desvanecer(f, 0.25, 0.2)
	end
	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.new(1, 1, 0.85)
	flash.BackgroundTransparency = 0.55
	flash.BorderSizePixel = 0
	flash.Parent = gui
	tw(flash, { BackgroundTransparency = 1 }, 0.3)
	borrarTras(flash, 0.35)
end

function Efectos.subir(p: Vector2, color: Color3, cruz: boolean, n: number)
	for k = 1, n do
		local x = p.X + math.random(-50, 50)
		local y = p.Y + math.random(0, 40)
		local f
		if cruz then
			f = forma(Vector2.new(x, y), 26, 26, Color3.new(1, 1, 1), 0, 0, 0, 4)
			f.BackgroundTransparency = 1
			local h = Instance.new("Frame")
			h.AnchorPoint = Vector2.new(0.5, 0.5)
			h.Position = UDim2.fromScale(0.5, 0.5)
			h.Size = UDim2.fromScale(1, 0.34)
			h.BackgroundColor3 = color
			h.BorderSizePixel = 0
			local s1 = Instance.new("UIStroke")
			s1.Thickness = 2
			s1.Color = NEGRO
			s1.Parent = h
			h.Parent = f
			local v = h:Clone()
			v.Size = UDim2.fromScale(0.34, 1)
			v.Parent = f
		else
			local d = math.random(12, 22)
			f = forma(Vector2.new(x, y), d, d, color, 0.5, 0, 2, 4)
		end
		local retraso = k * 0.06
		task.delay(retraso, function()
			if f.Parent then
				tw(f, { Position = UDim2.fromOffset(x, y - math.random(80, 130)) }, 0.8, Enum.EasingStyle.Sine)
			end
		end)
		desvanecer(f, 0.3, retraso + 0.5)
		if cruz then
			task.delay(retraso + 0.5, function()
				for _, h in f:GetChildren() do
					if h:IsA("Frame") then
						tw(h, { BackgroundTransparency = 1 }, 0.3)
					end
				end
			end)
		end
	end
end

function Efectos.rocas(p: Vector2)
	for k = 1, 6 do
		local x = p.X + math.random(-120, 120)
		local d = math.random(22, 40)
		local f = forma(Vector2.new(x, p.Y - 320), d, d, Color3.fromRGB(150, 120, 90), 0.25, math.random(0, 90), 3, 5)
		task.delay(k * 0.05, function()
			tw(f, { Position = UDim2.fromOffset(x, p.Y + math.random(-10, 30)), Rotation = f.Rotation + 180 }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end)
		desvanecer(f, 0.25, 0.45 + k * 0.05)
	end
end

function Efectos.raices(p: Vector2)
	for k = -2, 2 do
		local x = p.X + k * 22
		local f = forma(Vector2.new(x, p.Y + 60), 14, 4, Color3.fromRGB(110, 170, 70), 0.4, k * 10, 3, 5)
		f.AnchorPoint = Vector2.new(0.5, 1)
		tw(f, { Size = UDim2.fromOffset(14, math.random(80, 130)) }, 0.25, Enum.EasingStyle.Back)
		desvanecer(f, 0.3, 0.5)
	end
end

function Efectos.dientes(p: Vector2)
	for _, lado in { -1, 1 } do
		local f = forma(p + Vector2.new(0, lado * 70), 120, 26, Color3.new(1, 1, 1), 0.3, 0, 3, 5)
		tw(f, { Position = UDim2.fromOffset(p.X, p.Y + lado * 12) }, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		desvanecer(f, 0.2, 0.25)
	end
end

--- Proyectil que vuela de un punto a otro con estela; llama a alLlegar al final.
function Efectos.proyectil(desde: Vector2, hasta: Vector2, tipo: string, duracion: number, alLlegar: () -> ())
	local dif = hasta - desde
	local ang = math.deg(math.atan2(dif.Y, dif.X))
	local f: Frame
	local color: Color3
	if tipo == "flecha" then
		color = Color3.fromRGB(150, 100, 60)
		f = forma(desde, 70, 8, color, 0.5, ang, 2, 5)
		local punta = forma(Vector2.new(0, 0), 16, 16, Color3.fromRGB(210, 215, 225), 0.1, 45, 2, 6)
		punta.Parent = f
		punta.Position = UDim2.fromScale(1, 0.5)
	elseif tipo == "lengua" then
		color = Color3.fromRGB(250, 120, 150)
		f = forma(desde, 20, 16, color, 0.5, ang, 3, 5)
	else
		color = tipo == "fuego" and Color3.fromRGB(255, 140, 40) or tipo == "oscuro" and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(120, 230, 255)
		f = forma(desde, 44, 44, color, 0.5, 0, 3, 5)
		local nucleo = forma(Vector2.new(0, 0), 20, 20, Color3.fromRGB(255, 250, 200), 0.5, 0, 0, 6)
		nucleo.Parent = f
		nucleo.Position = UDim2.fromScale(0.5, 0.5)
	end
	tw(f, { Position = UDim2.fromOffset(hasta.X, hasta.Y) }, duracion, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	-- estela: copias que se quedan atrás y se apagan
	task.spawn(function()
		local inicio = os.clock()
		while os.clock() - inicio < duracion and f.Parent do
			local fantasma = forma(Vector2.new(f.AbsolutePosition.X + f.AbsoluteSize.X / 2, f.AbsolutePosition.Y + f.AbsoluteSize.Y / 2), f.AbsoluteSize.X * 0.7, f.AbsoluteSize.Y * 0.7, color, 0.5, f.Rotation, 0, 4)
			fantasma.BackgroundTransparency = 0.45
			tw(fantasma, { Size = UDim2.fromOffset(2, 2), BackgroundTransparency = 1 }, 0.25)
			borrarTras(fantasma, 0.3)
			task.wait(0.03)
		end
	end)
	task.delay(duracion, function()
		f:Destroy()
		alLlegar()
	end)
end

-- ===================== QUÉ EFECTO LLEVA CADA HABILIDAD =====================
type Plan = { proyectil: string?, impacto: string, texto: string?, color: Color3? }
local PLANES: { [string]: Plan } = {
	golpeFuerte = { impacto = "corte", texto = "¡ZAS!" },
	grito = { impacto = "anillo", texto = "¡ARGH!", color = Color3.fromRGB(255, 160, 60) },
	torbellino = { impacto = "corte", texto = "¡FIUUU!" },
	bolaFuego = { proyectil = "fuego", impacto = "fuego", texto = "¡FUUM!" },
	escudoArcano = { impacto = "anillo", texto = "¡CLING!", color = Color3.fromRGB(110, 180, 255) },
	tormenta = { impacto = "rayo", texto = "¡BZZT!" },
	disparoCerte = { proyectil = "flecha", impacto = "corte", texto = "¡TOC!" },
	flechaVeneno = { proyectil = "flecha", impacto = "veneno", texto = "¡PIC!" },
	lluviaFlechas = { proyectil = "lluvia", impacto = "corte", texto = "¡TOC TOC!" },
	curar = { impacto = "cura", texto = "¡AAAH!" },
	curaGrupal = { impacto = "cura" },
	revivir = { impacto = "revivir", texto = "¡ARRIBA!" },
	mordisco = { impacto = "dientes", texto = "¡ÑAM!" },
	esporas = { impacto = "esporas", texto = "¡PUF!" },
	hechizoOscuro = { proyectil = "oscuro", impacto = "oscuro", texto = "¡ZUUM!" },
	golpeRey = { impacto = "corte", texto = "¡PUM!" },
	picadura = { impacto = "veneno", texto = "¡PIC!" },
	lengua = { proyectil = "lengua", impacto = "corte", texto = "¡SLURP!" },
	raices = { impacto = "raices", texto = "¡CRAC!" },
	terremoto = { impacto = "rocas", texto = "¡BRUUM!" },
}
local GOLPES_FISICOS = { "¡PAM!", "¡ZAS!", "¡TOMA!", "¡POW!", "¡CATAPLÁN!" }

local function impacto(plan: Plan, p: Vector2, critico: boolean?)
	local i = plan.impacto
	if i == "corte" then
		Efectos.corte(p, nil, critico and 1.5 or 1)
		Efectos.estallido(p, { Color3.new(1, 1, 1), Color3.fromRGB(255, 230, 120) }, 6, 60)
	elseif i == "fuego" then
		Efectos.estallido(p, { Color3.fromRGB(255, 140, 40), Color3.fromRGB(255, 220, 80), Color3.fromRGB(230, 60, 40) }, 10, 90)
	elseif i == "oscuro" then
		Efectos.estallido(p, { Color3.fromRGB(150, 70, 220), Color3.fromRGB(60, 30, 90) }, 9, 80)
	elseif i == "rayo" then
		Efectos.rayo(p)
		Efectos.estallido(p, { Color3.fromRGB(255, 240, 90) }, 6, 60)
	elseif i == "veneno" or i == "esporas" then
		Efectos.subir(p, i == "veneno" and Color3.fromRGB(180, 90, 240) or Color3.fromRGB(200, 220, 80), false, 8)
	elseif i == "anillo" then
		Efectos.anillo(p, plan.color or Color3.new(1, 1, 1), 180)
	elseif i == "cura" then
		Efectos.subir(p, Color3.fromRGB(110, 230, 120), true, 6)
		Efectos.anillo(p, Color3.fromRGB(150, 255, 160), 140)
	elseif i == "revivir" then
		Efectos.subir(p, Color3.fromRGB(255, 220, 90), true, 9)
		Efectos.anillo(p, Color3.fromRGB(255, 230, 120), 220)
	elseif i == "rocas" then
		Efectos.rocas(p)
	elseif i == "raices" then
		Efectos.raices(p)
	elseif i == "dientes" then
		Efectos.dientes(p)
	end
end

--- Reproduce el efecto de una acción. posDe(id) da la posición en el mundo de cada entidad;
--- alImpacto(golpe) se llama cuando el golpe llega (para números, temblor y el destello del muñeco).
function Efectos.accion(ev: any, posDe: (string) -> Vector3?, alImpacto: (any) -> ())
	local golpes = ev.golpes or {}
	local actorPos = ev.actor and posDe(ev.actor)
	local plan: Plan = (ev.habilidad and PLANES[ev.habilidad]) or { impacto = "corte", texto = GOLPES_FISICOS[math.random(1, #GOLPES_FISICOS)] }
	local textoPuesto = false
	for k, g in golpes do
		local pos = posDe(g.id)
		if pos then
			local p = pantalla(pos)
			local function llega()
				local planGolpe = plan
				if g.tipo == "cura" and plan.impacto ~= "revivir" then
					planGolpe = { impacto = "cura" }
				elseif g.tipo == "mana" then
					planGolpe = { impacto = "anillo", color = Color3.fromRGB(110, 170, 255) }
				elseif g.tipo == "defensa" and not ev.habilidad then
					planGolpe = { impacto = "anillo", texto = "¡EN GUARDIA!", color = Color3.fromRGB(110, 180, 255) }
				elseif g.tipo == "veneno" and not ev.habilidad then
					planGolpe = { impacto = "veneno" }
				elseif g.tipo == "envenenado" then
					planGolpe = { impacto = "veneno" }
				elseif g.tipo == "esquiva" then
					Efectos.onomatopeya(p, "¡FALLO!", Color3.fromRGB(200, 220, 255))
					alImpacto(g)
					return
				elseif g.choque then
					Efectos.estallido(p, { Color3.fromRGB(255, 230, 120), Color3.new(1, 1, 1) }, 8, 80)
					Efectos.onomatopeya(p, "¡CATAPLÁN!", Color3.fromRGB(255, 160, 60), true)
					alImpacto(g)
					return
				elseif g.trampa then
					Efectos.onomatopeya(p, "¡AUCH!", Color3.fromRGB(255, 120, 120))
					alImpacto(g)
					return
				end
				impacto(planGolpe, p, g.critico)
				local texto = planGolpe.texto or plan.texto
				if texto and (not textoPuesto or g.critico) and (g.tipo == "dano" or planGolpe ~= plan or k == 1) then
					textoPuesto = true
					Efectos.onomatopeya(p, g.critico and "¡CRÍTICO!" or texto, g.critico and Color3.fromRGB(255, 90, 70) or Color3.fromRGB(255, 235, 110), g.critico)
				end
				alImpacto(g)
			end
			local retraso = (k - 1) * 0.08
			if plan.proyectil and actorPos and g.tipo == "dano" and not g.choque and not g.trampa then
				local desde = pantalla(actorPos)
				if plan.proyectil == "lluvia" then
					desde = p - Vector2.new(math.random(-80, 80), 300)
				end
				task.delay(retraso, function()
					Efectos.proyectil(desde, p, plan.proyectil == "lluvia" and "flecha" or plan.proyectil :: string, 0.32, llega)
				end)
			else
				task.delay(0.16 + retraso, llega)
			end
		end
	end
end

return Efectos
