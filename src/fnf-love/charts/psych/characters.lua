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
	-- ── Boyfriend ─────────────────────────────────────────────────────────────
	bf               = { kind = "psych", json = "characters/bf.json",             slot = "boyfriend",  icon = "boyfriend" },
	["bf-holding-gf"]= { kind = "psych", json = "characters/bf-holding-gf.json",  slot = "boyfriend",  icon = "boyfriend" },
	["bf-car"]       = { kind = "psych", json = "characters/bf-car.json",         slot = "boyfriend",  icon = "boyfriend" },
	["bf-christmas"] = { kind = "psych", json = "characters/bf-christmas.json",   slot = "boyfriend",  icon = "boyfriend" },
	["bf-pixel"]     = { kind = "psych", json = "characters/bf-pixel.json",       slot = "boyfriend",  icon = "boyfriend (pixel)" },

	-- ── Girlfriend ────────────────────────────────────────────────────────────
	gf               = { kind = "psych", json = "characters/gf.json",             slot = "girlfriend", icon = "girlfriend" },
	["gf-christmas"] = { kind = "psych", json = "characters/gf-christmas.json",   slot = "girlfriend", icon = "girlfriend" },
	["gf-car"]       = { kind = "psych", json = "characters/gf-car.json",         slot = "girlfriend", icon = "girlfriend" },
	["gf-pixel"]     = { kind = "psych", json = "characters/gf-pixel.json",       slot = "girlfriend", icon = "girlfriend" },
	["gf-tankmen"]   = { kind = "psych", json = "characters/gf-tankmen.json",     slot = "girlfriend", icon = "girlfriend" },

	-- ── Week 1 ────────────────────────────────────────────────────────────────
	dad              = { kind = "psych", json = "characters/dad.json",            slot = "enemy",      icon = "daddy dearest" },

	-- ── Week 2 (Spooky Month) ─────────────────────────────────────────────────
	spooky           = { kind = "psych", json = "characters/spooky.json",         slot = "enemy",      icon = "skid and pump" },
	["skid and pump"]= { kind = "psych", json = "characters/spooky.json",         slot = "enemy",      icon = "skid and pump" },
	monster          = { kind = "psych", json = "characters/monster.json",        slot = "enemy",      icon = "monster" },
	["monster-christmas"] = { kind = "psych", json = "characters/monster-christmas.json", slot = "enemy", icon = "monster" },

	-- ── Week 3 (Pico) ─────────────────────────────────────────────────────────
	pico             = { kind = "psych", json = "characters/pico.json",           slot = "enemy",      icon = "pico" },

	-- ── Week 4 (Mommy Must Murder) ────────────────────────────────────────────
	mom              = { kind = "psych", json = "characters/mom.json",            slot = "enemy",      icon = "mommy mearest" },
	["mom-car"]      = { kind = "psych", json = "characters/mom-car.json",        slot = "enemy",      icon = "mommy mearest" },

	-- ── Week 5 (Red Snow) ─────────────────────────────────────────────────────
	["parents-christmas"] = { kind = "psych", json = "characters/parents-christmas.json", slot = "enemy", icon = "dearest duo" },

	-- ── Week 6 (Hating Simulator) ─────────────────────────────────────────────
	senpai           = { kind = "psych", json = "characters/senpai.json",         slot = "enemy",      icon = "senpai" },
	["senpai-angry"] = { kind = "psych", json = "characters/senpai-angry.json",   slot = "enemy",      icon = "senpai-angry" },
	spirit           = { kind = "psych", json = "characters/spirit.json",         slot = "enemy",      icon = "spirit" },

	-- ── Week 7 (Tankman) ──────────────────────────────────────────────────────
	tankman          = { kind = "psych", json = "characters/tankman.json",        slot = "enemy",      icon = "tankman" },
	["pico-speaker"] = { kind = "psych", json = "characters/pico-speaker.json",   slot = "girlfriend", icon = "pico" },

	-- ── Weekend 1 ─────────────────────────────────────────────────────────────
	darnell          = { path = "sprites/weekend1/darnell.lua",                   slot = "enemy",      icon = "darnell" },
	nene             = { path = "sprites/weekend1/Nene.lua",                      slot = "enemy" },
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
	-- La posición de slot del stage la suma stages.lua DESPUÉS de loadInto,
	-- igual que Psych Engine: stageData.boyfriend + charOffset = posición final.
	local posX, posY = 0, 0
	if sprite.psychChar and sprite.psychChar.position then
		posX = sprite.psychChar.position[1] or 0
		posY = sprite.psychChar.position[2] or 0
	end

	if entry.kind ~= "psych" and current then
		if current.sizeX then sprite.sizeX = current.sizeX end
		if current.sizeY then sprite.sizeY = current.sizeY end
	end

	if sprite:getAnims()["idle"] then
		sprite:animate("idle", false)
	end

	-- Conversión Psych (top-left del bounding box sin trim) -> FNF Rewritten
	-- (centro del bounding box sin trim) -- nunca adivinada a mano, ver
	-- modules/graphics.lua:getOrigin(). Sin argumento: usa el frame de la
	-- animación ACTUALMENTE activa (graphics.lua: frameIndex or anim.start),
	-- que justo tras construir el sprite es la animación inicial
	-- (character.lua elige "idle" si existe, sino "danceRight", sino la
	-- primera con frames válidos -- "idle" casi nunca es la primera listada
	-- en el JSON, así que usar literalmente el frame 1 del JSON daba una
	-- conversión distinta a la real y descolocaba personajes como dad/gf/
	-- spooky donde "idle"/"danceRight" no es la primera animación listada).
	-- getOrigin() devuelve el origen SIN escalar (no multiplica por
	-- sprite.sizeX/Y). Esto es CORRECTO acá, sin multiplicar por la escala:
	-- modules/graphics.lua:draw() pasa exactamente este mismo valor SIN
	-- escalar como ox/oy a love.graphics.draw(), que internamente lo escala
	-- por sx,sy al dibujar -- es decir, sprite.x/y YA representa el centro
	-- visual del frame ESCALADO, precisamente PORQUE el origen que se le
	-- resta en el dibujado está sin escalar (LÖVE hace esa multiplicación
	-- una sola vez, automáticamente). Si acá TAMBIÉN multiplicáramos por la
	-- escala, el centro quedaría desplazado por un factor extra de `scale`
	-- (para personajes pixel, escala 6 -- exactamente el bug de "personajes
	-- hundidos en el suelo" reportado: la ronda pasada multipliqué por
	-- error, pensando que esta conversión necesitaba escalar igual que
	-- charts/psych/bgsprite.lua -- pero bgsprite.lua SÍ multiplica porque ahí
	-- el origen se suma directo a x,y sin pasar por un draw() que ya escale
	-- automáticamente; characters.lua no tiene esa segunda escalada).
	local slotConvX, slotConvY = sprite:getOrigin()
	sprite._slotConversionX = slotConvX
	sprite._slotConversionY = slotConvY

	-- Guardamos el offset propio para que "Change Character" pueda recuperar
	-- la posición de slot Psych del sprite anterior:
	-- slotPsychX = current.x - current._slotConversionX - current._charOffsetX
	sprite._charOffsetX = posX
	sprite._charOffsetY = posY

	if current then
		-- Change Character mid-song: recuperar slot Psych del personaje saliente y reusar.
		local slotX = (current.x or 0) - (current._slotConversionX or 0) - (current._charOffsetX or 0)
		local slotY = (current.y or 0) - (current._slotConversionY or 0) - (current._charOffsetY or 0)
		sprite.x = slotX + slotConvX + posX
		sprite.y = slotY + slotConvY + posY
	else
		-- Primera carga: solo el offset del personaje + conversión de coordenadas.
		-- stages.lua sumará el slot Psych real en su M.apply().
		sprite.x = slotConvX + posX
		sprite.y = slotConvY + posY
	end

	_G[slot] = sprite

	return true, entry
end

-- Expuesto para el editor de charts (selector de personajes).
M.REGISTRY = REGISTRY

return M
