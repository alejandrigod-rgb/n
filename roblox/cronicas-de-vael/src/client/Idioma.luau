--!strict
-- Idiomas con las herramientas oficiales de Roblox: LocalizationService y la tabla de localización
-- (src/localizacion/Textos.csv, que Rojo convierte en un LocalizationTable dentro de LocalizationService).
--
-- Cómo funciona:
--  · Los textos del juego se escriben en español (es el texto "Source" de la tabla).
--  · Idioma.t(texto) devuelve la traducción al idioma elegido usando Translator:Translate (busca por el texto original).
--  · Idioma.clave(clave, args) usa Translator:FormatByKey para textos con huecos, por ejemplo "Nivel {1}".
--  · Ui.crear traduce solo el Text de cada etiqueta y botón al crearlo, y guarda el original en el atributo
--    "TextoOriginal" para volver a traducir todo si el jugador cambia de idioma.
--  · Al empezar se usa el idioma de la cuenta de Roblox (si es uno de los 5); se puede cambiar en Configuración.
--  · Lo que no esté en la tabla se queda en español (y Roblox puede traducirlo solo si la traducción automática
--    está activada en el Creator Hub).

local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")

local Idioma = {}

Idioma.DISPONIBLES = {
	{ codigo = "es", nombre = "Español" },
	{ codigo = "en", nombre = "English" },
	{ codigo = "pt", nombre = "Português" },
	{ codigo = "fr", nombre = "Français" },
	{ codigo = "de", nombre = "Deutsch" },
}

local traductor: Translator? = nil
local actual = "es"
local alCambiar: { () -> () } = {}

local function base(codigo: string?): string
	local c = string.lower(string.sub(codigo or "es", 1, 2))
	for _, d in Idioma.DISPONIBLES do
		if d.codigo == c then
			return c
		end
	end
	return "es"
end

function Idioma.actual(): string
	return actual
end

--- Cambia el idioma (y vuelve a traducir los textos que ya están en pantalla).
function Idioma.poner(codigo: string)
	actual = base(codigo)
	traductor = nil
	if actual ~= "es" then
		local ok, t = pcall(function()
			return LocalizationService:GetTranslatorForLocaleAsync(actual)
		end)
		if ok then
			traductor = t
		end
	end
	local jugador = Players.LocalPlayer
	if jugador then
		jugador:SetAttribute("Idioma", actual)
		local pg = jugador:FindFirstChild("PlayerGui")
		if pg then
			for _, d in pg:GetDescendants() do
				if (d:IsA("TextLabel") or d:IsA("TextButton")) and d:GetAttribute("TextoOriginal") then
					d.Text = Idioma.t(d:GetAttribute("TextoOriginal") :: string)
				end
			end
		end
	end
	for _, f in alCambiar do
		task.spawn(f)
	end
end

--- Traduce un texto escrito en español. Si no hay traducción, lo deja igual.
function Idioma.t(texto: string): string
	if actual == "es" or not traductor or texto == "" then
		return texto
	end
	local ok, r = pcall(function()
		return (traductor :: Translator):Translate(game, texto)
	end)
	return (ok and r and r ~= "") and r or texto
end

--- Texto con huecos ({1}, {2}…) por su clave de la tabla. respaldo: el texto en español con los mismos huecos.
function Idioma.clave(clave: string, args: { any }?, respaldo: string?): string
	local function rellenar(plantilla: string): string
		return (string.gsub(plantilla, "{(%d+)}", function(n)
			local v = args and args[tonumber(n) :: number]
			return v ~= nil and tostring(v) or ""
		end))
	end
	if traductor and actual ~= "es" then
		local ok, r = pcall(function()
			return (traductor :: Translator):FormatByKey(clave, args or {})
		end)
		if ok and r then
			return r
		end
	end
	return rellenar(respaldo or clave)
end

function Idioma.alCambiar(f: () -> ())
	table.insert(alCambiar, f)
end

-- idioma inicial: el de la cuenta de Roblox
task.spawn(function()
	local ok, codigo = pcall(function()
		return LocalizationService.RobloxLocaleId
	end)
	Idioma.poner(ok and codigo or "es")
end)

return Idioma
