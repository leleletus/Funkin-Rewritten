--[[----------------------------------------------------------------------------
  menuCharacter — loader genérico para los íconos de personaje del StoryMenu,
  para los personajes que NO tienen un sprite pre-horneado en
  sprites/storymenu/props/*.lua (hoy: darnell, nene, pico-player, de
  Weekend 1). Carga el atlas Sparrow real directo (igual mecanismo que
  charts/psych/character.lua, mismo bridge atlas.lua -> graphics.newSprite),
  en vez de hornear más .lua a mano.

  Replica MenuCharacter.hx real: cada animación es TODO frame cuyo nombre
  empiece con el prefijo dado (FlxAnimationController.addByPrefix), sin
  índices -- los menucharacters/<id>.json reales nunca usan "indices",
  a diferencia de characters/<id>.json.

  flipX: ninguno de los 12 personajes de menú reales (bf/gf/dad/spooky/
  pico/mom/parents-christmas/senpai/tankman/darnell/nene/pico-player) usa
  flipX=true -- no implementado a propósito (sin caso real para probarlo
  contra la fuente; ver MenuCharacter.hx real: flipX = sprite.flipX, simple
  booleano de Flixel, no la convención sizeX negativo de este motor).
------------------------------------------------------------------------------]]

local atlas = require("charts.psych.atlas")

local M = {}

local atlasCache = {}

local function loadAtlas(imagePath)
	if atlasCache[imagePath] then return atlasCache[imagePath] end

	local pngPath = "images/png/" .. imagePath .. ".png"
	local xmlPath = "images/png/" .. imagePath .. ".xml"

	local entry = {
		image = love.graphics.newImage(pngPath),
		frames = atlas.loadSparrow(xmlPath),
	}

	atlasCache[imagePath] = entry
	return entry
end

local function framesByPrefix(frames, prefix)
	local result = {}
	for _, frame in ipairs(frames) do
		if frame.name and frame.name:sub(1, #prefix) == prefix then
			table.insert(result, frame)
		end
	end
	return result
end

-- def: {image=, idle_anim=, confirm_anim=}, todos campos crudos del
-- menucharacters/<id>.json real. Devuelve sprite, hasConfirmAnimation
-- (igual semántica que MenuCharacter.hx: hasConfirmAnimation solo true si
-- confirm_anim existe Y es distinto de idle_anim Y tiene frames válidos).
function M.create(def)
	local sheet = loadAtlas("storymenu/props/" .. def.image)
	local frameData = {}
	local animData = {}

	local function addAnim(internalName, prefix)
		local selected = framesByPrefix(sheet.frames, prefix)
		if #selected == 0 then return false end

		local start = #frameData + 1
		for _, frame in ipairs(selected) do
			-- rotated=true: mismo manejo que charts/psych/character.lua --
			-- width/height intercambiados para que el resto del motor
			-- trabaje con el tamaño lógico post-rotación.
			local fw, fh = frame.width, frame.height
			if frame.rotated then fw, fh = fh, fw end

			table.insert(frameData, {
				x = frame.x, y = frame.y,
				width = fw, height = fh,
				offsetX = frame.frameX,
				offsetY = frame.frameY,
				offsetWidth = frame.frameWidth,
				offsetHeight = frame.frameHeight,
				rotated = frame.rotated,
			})
		end

		animData[internalName] = { start = start, stop = #frameData, speed = 24, offsetX = 0, offsetY = 0 }
		return true
	end

	addAnim("idle", def.idle_anim)

	local hasConfirmAnimation = false
	if def.confirm_anim and def.confirm_anim ~= def.idle_anim then
		hasConfirmAnimation = addAnim("confirm", def.confirm_anim)
	end

	local sprite = graphics.newSprite(sheet.image, frameData, animData, "idle", false)
	return sprite, hasConfirmAnimation
end

return M
