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
--
-- Replica Paths.getAtlas() de Psych real: decide Sparrow XML vs "packer" por
-- EXISTENCIA de archivo, nunca por contenido -- si existe <key>.xml es
-- Sparrow (siempre, sin excepción); si no existe pero hay <key>.txt, es
-- packer (caso de characters/spirit.txt). Antes esto se adivinaba leyendo el
-- contenido del archivo, lo cual era frágil y llegó a clasificar mal atlas
-- Sparrow válidos.
local function loadAtlas(imagePath)
	if atlasCache[imagePath] then return atlasCache[imagePath] end

	local pngPath = graphics.imagePath(imagePath)
	local xmlPath = pngPath:gsub("%.png$", ".xml")
	local txtPath = pngPath:gsub("%.png$", ".txt")

	local frames
	if love.filesystem.getInfo(xmlPath) then
		frames = atlas.loadSparrow(xmlPath)
	elseif love.filesystem.getInfo(txtPath) then
		frames = atlas.loadPacker(txtPath)
	else
		error("no se encontró atlas (.xml ni .txt) para '" .. imagePath .. "'")
	end

	local entry = {
		image = love.graphics.newImage(pngPath),
		frames = frames,
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

-- NOTA: en rondas anteriores existió acá un sistema de "correctionDelta" que
-- intentaba compensar a mano diferencias de tamaño de canvas entre
-- animaciones (pensado para Spirit, cuyo "singDOWN" usa un canvas de 256x256
-- frente a 128x128 del resto). Se sacó por completo: terminaba aplicando una
-- corrección espuria al offset de CASI TODOS los personajes (cualquiera cuyas
-- animaciones de canto tuvieran un canvas recortado distinto al de "idle" --
-- el caso normal, no la excepción). Character.hx real es mucho más simple --
-- playAnim() hace literalmente:
--   var daOffset = animOffsets.get(AnimName);
--   offset.set(daOffset[0], daOffset[1]);
-- es decir, el offset crudo del JSON se aplica DIRECTO, sin ningún ajuste
-- basado en el recorte/tamaño del frame. M.load() ahora hace exactamente
-- eso (ver animData[...].offsetX/Y abajo). Si algún personaje puntual con
-- animaciones de tamaño de canvas muy distinto entre sí (como Spirit) queda
-- descolocado en una animación específica, se corrige a mano con el editor
-- de personajes (states/character-offset-debug.lua) -- igual que en Psych
-- real, donde esos valores los ajusta a mano quien crea el personaje.

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

	-- offsetX/Y = el valor CRUDO de "offsets" del JSON, sin ningún ajuste --
	-- igual que Character.hx:playAnim() (offset.set(daOffset[0], daOffset[1])).
	local animData = {}
	for _, anim in ipairs(pending) do
		animData[anim.internalName] = {
			start = anim.start,
			stop = anim.stop,
			speed = anim.speed,
			offsetX = anim.offsetX,
			offsetY = anim.offsetY,
		}
	end

	-- Alias "idle" para personajes que solo tienen danceLeft/danceRight (p.ej.
	-- Skid and Pump), igual que Character.hx hace al reproducir la animación
	-- inicial cuando no existe "idle".
	if not animData["idle"] then
		animData["idle"] = animData["danceRight"] or animData["danceLeft"]
	end

	-- fixedPivot: ver comentario en modules/graphics.lua:newSprite() -- evita
	-- que el personaje se desplace visualmente al cambiar de animación
	-- cuando el canvas sin recortar de esa animación difiere del de "idle"
	-- (caso normal, no la excepción). characters.lua ancla la posición base
	-- al mismo frame inicial, así que ambos quedan consistentes entre sí.
	local sprite = graphics.newSprite(sheet.image, frameData, animData, initialAnim, false, { fixedPivot = true })

	if def.no_antialiasing then
		sheet.image:setFilter("nearest", "nearest")
	end

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
