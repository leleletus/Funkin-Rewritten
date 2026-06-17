-- Loader genérico de personajes en formato Psych Engine
-- (characters/<id>.json + atlas Sparrow XML en images/png/characters/).
--
-- Construye animaciones via addByPrefix/addByIndices a partir del atlas,
-- igual que Character.hx, y devuelve un sprite compatible con
-- modules/graphics.lua (graphics.newSprite).

local json = require("lib.json")
local graphics = require("modules.graphics")
local atlas = require("charts.psych.atlas")
local animnames = require("charts.psych.animnames")

local M = {}

local atlasCache = {}

-- imagePath: ruta relativa a images/png/ sin extensión (p.ej. "characters/BOYFRIEND")
local function loadAtlas(imagePath)
	if atlasCache[imagePath] then return atlasCache[imagePath] end

	local pngPath = graphics.imagePath(imagePath)
	local xmlPath = pngPath:gsub("%.png$", ".xml")

	local entry = {
		image = love.graphics.newImage(pngPath),
		frames = atlas.load(xmlPath),
	}

	atlasCache[imagePath] = entry

	return entry
end

-- Replica FlxAnimationController.findByPrefix/addByPrefix: todo frame cuyo
-- nombre EMPIECE por `prefix` (substring en la posición 0), en el mismo orden
-- en que aparecen en el XML (que ya es el orden numérico para los atlas de
-- Psych). No se exige que lo que sigue al prefijo sean solo dígitos: nombres
-- como "BF HEY!!0000" (prefijo "BF HEY") o "GF FEAR 0000" (prefijo "GF FEAR",
-- con espacio) deben matchear igual que en Flixel.
local function framesByPrefix(frames, prefix)
	local result = {}

	for _, frame in ipairs(frames) do
		if frame.name and frame.name:sub(1, #prefix) == prefix then
			table.insert(result, frame)
		end
	end

	return result
end

-- Replica FlxAnimationController.addByIndices: busca el frame cuyo nombre es
-- EXACTAMENTE "<prefix><índice de 4 dígitos>"; si no existe, devuelve nil (el
-- índice se omite, como hace Psych con índices que no tienen frame).
local function frameByExactName(frames, name)
	for _, frame in ipairs(frames) do
		if frame.name == name then return frame end
	end

	return nil
end

-- Diferencia entre la fórmula de Flixel y la de modules/graphics.lua para la
-- posición en pantalla de la esquina superior-izquierda del frame recortado
-- ("trim"), a escala 1 sin rotación/flip:
--   Flixel (Psych):  x + frameX - psychOffset
--   graphics.lua:    x - (oxBase + animOffset), con oxBase = floor(frameWidth/2) + frameX
-- (o floor(width/2) + 0 si el frame no tiene recorte, frameWidth == 0).
-- Igualando ambas: animOffset = psychOffset - oxBase - frameX, es decir
-- psychOffset + correctionDelta(frame), con:
--   correctionDelta(frame) = -floor(frameWidth/2) - 2*frameX
--
-- correctionDelta depende SOLO del frame (no del offset de Psych), y varía
-- de una animación a otra según el tamaño/recorte de su primer frame. Por eso
-- M.load no la aplica directo: se usa la DIFERENCIA entre correctionDelta de
-- cada animación y la de la animación inicial, de forma que la posición base
-- del personaje (la que ya usa characters.lua) no cambie y solo se corrijan
-- los desplazamientos RELATIVOS entre animaciones.
local function correctionDelta(frame)
	local frameWidth, frameX = frame.width, 0
	local frameHeight, frameY = frame.height, 0

	if frame.frameWidth ~= 0 then frameWidth, frameX = frame.frameWidth, frame.frameX end
	if frame.frameHeight ~= 0 then frameHeight, frameY = frame.frameHeight, frame.frameY end

	return -math.floor(frameWidth / 2) - 2 * frameX,
		-math.floor(frameHeight / 2) - 2 * frameY
end

-- jsonPath: ruta a characters/<id>.json
-- isPlayer: true si el personaje ocupa el slot "boyfriend" (afecta flip_x)
function M.load(jsonPath, isPlayer)
	local raw, err = love.filesystem.read(jsonPath)

	if not raw then
		error("no se pudo leer el personaje Psych '" .. jsonPath .. "': " .. tostring(err))
	end

	local def = json.decode(raw)
	local sheet = loadAtlas(def.image)

	local frameData = {}
	local pending = {}
	local firstAnim

	for _, animDef in ipairs(def.animations or {}) do
		local byPrefix = framesByPrefix(sheet.frames, animDef.name)
		local selected

		if animDef.indices and #animDef.indices > 0 then
			selected = {}

			for _, index in ipairs(animDef.indices) do
				local frame = frameByExactName(sheet.frames, ("%s%04d"):format(animDef.name, index))

				if frame then table.insert(selected, frame) end
			end
		else
			selected = byPrefix
		end

		if #selected > 0 then
			local start = #frameData + 1

			for _, frame in ipairs(selected) do
				table.insert(frameData, {
					x = frame.x,
					y = frame.y,
					width = frame.width,
					height = frame.height,
					offsetX = frame.frameX,
					offsetY = frame.frameY,
					offsetWidth = frame.frameWidth,
					offsetHeight = frame.frameHeight,
				})
			end

			local offsets = animDef.offsets or {0, 0}
			local internalName = animnames.toInternal(animDef.anim)

			table.insert(pending, {
				internalName = internalName,
				start = start,
				stop = #frameData,
				speed = animDef.fps or 24,
				offsetX = offsets[1] or 0,
				offsetY = offsets[2] or 0,
				anchorFrame = selected[1],
			})

			if not firstAnim then firstAnim = internalName end
		else
			print("WARN: animación Psych '" .. tostring(animDef.anim) .. "' (" .. tostring(animDef.name)
				.. ") sin frames en '" .. jsonPath .. "', ignorada")
		end
	end

	if not firstAnim then
		error("el personaje Psych '" .. jsonPath .. "' no tiene ninguna animación válida")
	end

	local hasAnim = {}
	for _, anim in ipairs(pending) do hasAnim[anim.internalName] = true end

	local initialAnim = hasAnim["idle"] and "idle" or hasAnim["danceRight"] and "danceRight" or firstAnim

	-- Ancla la corrección a la animación inicial: su corrección relativa es
	-- 0, así que su offset final queda igual al de Psych (y por tanto la
	-- posición base del personaje, definida por characters.lua, no cambia).
	local anchorCorrectionX, anchorCorrectionY = 0, 0
	for _, anim in ipairs(pending) do
		if anim.internalName == initialAnim then
			anchorCorrectionX, anchorCorrectionY = correctionDelta(anim.anchorFrame)
			break
		end
	end

	local animData = {}
	for _, anim in ipairs(pending) do
		local dx, dy = correctionDelta(anim.anchorFrame)

		animData[anim.internalName] = {
			start = anim.start,
			stop = anim.stop,
			speed = anim.speed,
			offsetX = anim.offsetX + (dx - anchorCorrectionX),
			offsetY = anim.offsetY + (dy - anchorCorrectionY),
		}
	end

	local sprite = graphics.newSprite(sheet.image, frameData, animData, initialAnim, false)

	local scale = def.scale or 1
	sprite.sizeX = scale
	sprite.sizeY = scale

	local flipX = def.flip_x or false
	if isPlayer then flipX = not flipX end
	if flipX then sprite.sizeX = -sprite.sizeX end

	sprite.psychChar = {
		position = def.position or {0, 0},
		camera_position = def.camera_position or {0, 0},
		healthicon = def.healthicon,
		healthbar_colors = def.healthbar_colors,
		sing_duration = def.sing_duration,
		flip_x = flipX,
	}

	return sprite
end

return M
