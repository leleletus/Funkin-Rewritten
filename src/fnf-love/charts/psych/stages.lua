-- Registro de stages Psych Engine (campo "stage" del chart) -> posiciones
-- nativas de boyfriend/girlfriend/enemy en FNF Rewritten.
--
-- No reemplaza fondos/gráficos del stage (eso requeriría portar el arte y la
-- lógica de cada `weeks/weekN.lua`, fuera de alcance) — solo reposiciona a
-- los tres personajes para que un personaje "trasplantado" desde otro chart
-- no aparezca en un lugar absurdo. Si el nombre de stage no se reconoce, se
-- avisa por consola y se dejan las posiciones tal cual están.

local M = {}

-- Posiciones en el sistema de coordenadas de FNF Rewritten (NO coordenadas
-- de Psych Engine). Para personajes "psych" (bf/gf/dad) = REGISTRY.x/y +
-- JSON.position; para personajes "legacy" = REGISTRY.x/y directamente.
-- Estas posiciones son las que psychCharacters.loadInto ya produce, así que
-- apply() es un no-op para la semana nativa y solo reposiciona cuando hay un
-- personaje "trasplantado" de otra semana.
local STAGES = {
	-- bf=(974,636)  gf=(749,440)  dad=(308,483)
	stage             = { boyfriend = {x = 974, y = 636},  girlfriend = {x = 749, y = 440},  enemy = {x = 308, y = 483} },  -- week1
	-- bf=(974,636)  gf=(749,440)  spooky=(-610,140)
	spooky            = { boyfriend = {x = 974, y = 636},  girlfriend = {x = 749, y = 440},  enemy = {x = -610, y = 140} }, -- week2
	-- bf=(974,636)  gf=(749,440)  pico=(-480,50)
	philly            = { boyfriend = {x = 974, y = 636},  girlfriend = {x = 749, y = 440},  enemy = {x = -480, y = 50} },  -- week3
	["phillyChristmas"] = { boyfriend = {x = 974, y = 636}, girlfriend = {x = 749, y = 440}, enemy = {x = -480, y = 50} },  -- week3 navideña
	-- bf=(974,636)  gf-car hereda (749,440)  mom=(-380,-10)
	limo              = { boyfriend = {x = 974, y = 636},  girlfriend = {x = 749, y = 440},  enemy = {x = -380, y = -10} }, -- week4
	-- bf=(974,636)  gf-christmas hereda (749,440)  monster-christmas=(-780,410)
	mall              = { boyfriend = {x = 974, y = 636},  girlfriend = {x = 749, y = 440},  enemy = {x = -780, y = 410} }, -- week5
	["mallEvil"]      = { boyfriend = {x = 974, y = 636},  girlfriend = {x = 749, y = 440},  enemy = {x = -780, y = 410} }, -- week5 variante
	-- bf=(974,636)  gf-tankman=(-635,-105)  tankman=(-810,90)
	tank              = { boyfriend = {x = 974, y = 636},  girlfriend = {x = -635, y = -105}, enemy = {x = -810, y = 90} }, -- week7
}

-- name: nombre Psych del stage (meta.stage / "Change Character" no lo usa).
-- Devuelve el layout {boyfriend=, girlfriend=, enemy=}, o nil + warn.
function M.get(name)
	if not name then return nil end

	local entry = STAGES[name]
	if not entry then
		print("WARN: stage Psych '" .. tostring(name) .. "' sin layout definido en FNF Rewritten, se mantienen las posiciones actuales")
	end

	return entry
end

-- Aplica las posiciones del stage a los sprites globales actuales
-- (boyfriend/girlfriend/enemy), sin tocar fondos. Devuelve true si se aplicó.
function M.apply(name)
	local entry = M.get(name)
	if not entry then return false end

	for slot, pos in pairs(entry) do
		local sprite = _G[slot]
		if sprite then
			sprite.x, sprite.y = pos.x, pos.y
		end
	end

	return true
end

-- Expuesto para el editor de charts (selector de stages).
M.STAGES = STAGES

return M
