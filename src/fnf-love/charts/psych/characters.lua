-- Registro de personajes Psych Engine (player1/player2/gfVersion, "Change
-- Character") -> sprites Lua reales de FNF Rewritten.
--
-- Cada entrada indica el slot global que ocupa ("boyfriend"/"girlfriend"/"enemy")
-- y la ruta del sprite. Las posiciones de escenario NO van aquí — las define
-- el stage.lua de cada semana, igual que Psych Engine usa stage.json para eso.
--
-- Si un nombre Psych no está aquí, get()/loadInto() avisan por consola y no
-- hacen nada (se mantiene el personaje actual del week) — nunca rompe el juego.

local character = require("charts.psych.character")

local M = {}

-- "icon": nombre de animación de icono (ver sprites/icons.lua), usado para que
-- la barra de salud tome el color correcto desde la tabla characterColors de
-- states/weeks.lua. Si se omite, la barra usa el color por defecto (rojo/verde).
--
-- "kind": si es "psych", "json" apunta a un characters/<id>.json (formato
-- Psych Engine, ver charts/psych/character.lua) que se carga y anima a partir
-- del atlas Sparrow XML. Si se omite, se trata como "legacy": "path" apunta a
-- un sprite Lua ya "horneado".
--
-- Las posiciones de slot (dónde va cada personaje en el escenario) las define
-- el stage, NO el personaje — igual que en Psych Engine donde stage.json tiene
-- los campos "boyfriend"/"girlfriend"/"opponent". El personaje solo conoce su
-- propio offset fino (campo "position" en characters/<id>.json).
local REGISTRY = {
	bf             = { kind = "psych", json = "characters/bf.json",  slot = "boyfriend", icon = "boyfriend" },
	["bf-christmas"] = { path = "sprites/week4/boyfriend.lua",   slot = "boyfriend", icon = "boyfriend" },
	["bf-pixel"]   = { path = "sprites/boyfriend.lua",           slot = "boyfriend", icon = "boyfriend (pixel)" },

	gf             = { kind = "psych", json = "characters/gf.json",  slot = "girlfriend", icon = "girlfriend" },
	["gf-christmas"] = { path = "sprites/week4/girlfriend.lua",  slot = "girlfriend", icon = "girlfriend" },
	["gf-car"]     = { path = "sprites/week4/limo-dancer.lua",   slot = "girlfriend", icon = "girlfriend" },
	["gf-pixel"]   = { path = "sprites/girlfriend.lua",          slot = "girlfriend", icon = "girlfriend" },
	["gf-tankman"] = { path = "sprites/week7/gftankmen.lua",     slot = "girlfriend", icon = "girlfriend" },

	dad            = { kind = "psych", json = "characters/dad.json", slot = "enemy", icon = "daddy dearest" },

	spooky         = { path = "sprites/week2/monster.lua",       slot = "enemy", icon = "monster" },
	monster        = { path = "sprites/week2/monster.lua",       slot = "enemy", icon = "monster" },
	["monster-christmas"] = { path = "sprites/week5/monster.lua", slot = "enemy", icon = "monster" },

	pico           = { path = "sprites/week3/pico-enemy.lua",    slot = "enemy", icon = "pico" },

	mom            = { path = "sprites/week4/mommy-mearest.lua", slot = "enemy", icon = "mommy mearest" },
	["mom-car"]    = { path = "sprites/week4/mommy-mearest.lua", slot = "enemy", icon = "mommy mearest" },
	["parents-christmas"] = { path = "sprites/week5/dearest-duo.lua", slot = "enemy", icon = "dearest duo" },

	senpai         = { path = "sprites/week6/senpai.lua",        slot = "enemy", icon = "senpai" },
	["senpai-angry"] = { path = "sprites/week6/senpai-angry.lua", slot = "enemy", icon = "senpai-angry" },
	spirit         = { path = "sprites/week6/spirit.lua",        slot = "enemy", icon = "spirit" },

	tankman        = { path = "sprites/week7/tankman.lua",       slot = "enemy", icon = "tankman" },

	darnell        = { path = "sprites/weekend1/darnell.lua",    slot = "enemy", icon = "darnell" },
	nene           = { path = "sprites/weekend1/Nene.lua",       slot = "enemy" },
}

-- name: nombre Psych (player1/player2/gfVersion, o value1 de "Change Character")
-- Devuelve la entrada del registro, o nil + warn si no hay sprite equivalente.
function M.get(name)
	if not name then return nil end

	local entry = REGISTRY[name]
	if not entry then
		print("WARN: personaje Psych '" .. tostring(name) .. "' sin sprite Lua en FNF Rewritten, se mantiene el personaje actual")
	end

	return entry
end

-- Reemplaza el sprite global del slot ("boyfriend"/"girlfriend"/"enemy") por
-- el personaje Psych indicado, preservando escala si el sprite anterior tenía
-- alguna y usando la posición nativa conocida (o la del sprite anterior si no
-- hay una registrada).
-- Devuelve true, entry si se hizo el cambio; false si no (nombre desconocido o
-- error al cargar el sprite).
function M.loadInto(slot, name)
	local entry = M.get(name)
	if not entry then return false end

	local ok, sprite

	if entry.kind == "psych" then
		ok, sprite = pcall(character.load, entry.json, slot == "boyfriend")
		if not ok or not sprite then
			print("WARN: no se pudo cargar el personaje Psych '" .. entry.json .. "': " .. tostring(sprite))
			return false
		end
	else
		ok, sprite = pcall(function() return love.filesystem.load(entry.path)() end)
		if not ok or not sprite then
			print("WARN: no se pudo cargar el sprite Psych '" .. entry.path .. "': " .. tostring(sprite))
			return false
		end
	end

	local current = _G[slot]

	-- El offset propio del personaje (startCharacterPos / "position" en Psych Engine).
	-- La posición de slot del stage la suma el stage.lua DESPUÉS de loadInto,
	-- igual que Psych Engine: stageData.boyfriend + charOffset = posición final.
	local posX, posY = 0, 0
	if sprite.psychChar and sprite.psychChar.position then
		posX = sprite.psychChar.position[1] or 0
		posY = sprite.psychChar.position[2] or 0
	end

	-- Guardamos el offset propio para que "Change Character" pueda recuperar
	-- la posición de slot del sprite anterior: slotX = current.x - current._charOffsetX
	sprite._charOffsetX = posX
	sprite._charOffsetY = posY

	if current then
		-- Change Character mid-song: recuperar slot del personaje saliente y reusar.
		local slotX = (current.x or 0) - (current._charOffsetX or 0)
		local slotY = (current.y or 0) - (current._charOffsetY or 0)
		sprite.x = slotX + posX
		sprite.y = slotY + posY
	else
		-- Primera carga: solo el offset del personaje.
		-- El stage.lua sumará el slot en su M.load().
		sprite.x = posX
		sprite.y = posY
	end

	if entry.kind ~= "psych" and current then
		if current.sizeX then sprite.sizeX = current.sizeX end
		if current.sizeY then sprite.sizeY = current.sizeY end
	end

	if sprite:getAnims()["idle"] then
		sprite:animate("idle", false)
	end

	_G[slot] = sprite

	return true, entry
end

-- Expuesto para el editor de charts (selector de personajes).
M.REGISTRY = REGISTRY

return M
