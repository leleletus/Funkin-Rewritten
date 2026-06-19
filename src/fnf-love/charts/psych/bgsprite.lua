-- Equivalente de objects/BGSprite.hx: fondo animado cargado directamente del
-- atlas Sparrow XML de Psych Engine, con conversión automática de coordenadas
-- (Psych: top-left del bounding box sin trim -> FNF Rewritten: centro del
-- bounding box sin trim, ver modules/graphics.lua:getOrigin()).
--
-- M.new(image, x, y, animArray, loop, scale):
--   image:     ruta sin extensión bajo images/png/ (p.ej. "week2/halloween_bg")
--   x, y:      posición Psych (top-left, tal cual aparece en el .hx del stage)
--   animArray: lista de entradas, cada una es:
--              - un string (prefijo): se vuelve una animación con ese mismo
--                nombre (igual que animation.addByPrefix(anim, anim, 24, loop)
--                en BGSprite.hx).
--              - una tabla {name=, prefix=, indices={...}}: replica
--                animation.addByIndices(name, prefix, indices, "", fps, loop) --
--                selecciona frames EXACTOS "<prefix><índice de 4 dígitos>" en
--                el orden dado por `indices` (no el orden del atlas). Usado
--                por sprites con varias animaciones compartiendo el mismo
--                prefijo de región (p.ej. freaks.lua: danceLeft/danceRight
--                dentro de la misma región "BG girls group").
--              La primera entrada de la lista se reproduce de entrada.
--   loop:      si las animaciones hacen loop por defecto (BGSprite.hx: false)
--   scale:     equivalente a setGraphicSize()/scale.set() en Psych (default 1).
--              IMPORTANTE: pasar la escala acá, no asignar sprite.sizeX/sizeY
--              después de M.new() -- la posición (x+ox, y+oy) ya se calcula
--              con el origen escalado; si la escala se aplica después, la
--              posición queda calculada con el tamaño sin escalar y el
--              sprite aparece desplazado.
--   originScale: escala a usar SOLO para el cálculo de origen (x+ox*originScale),
--              normalmente igual a `scale` (default). Existe porque en Psych
--              real no todos los BGSprite re-centran su posición al escalar:
--              School.hx llama setGraphicSize()+updateHitbox() (recentra,
--              usar originScale=scale, el default), pero SchoolEvil.hx hace
--              `bg.scale.set(daPixelZoom,daPixelZoom)` SIN updateHitbox() --
--              en Flixel eso deja x/y ancladas al top-left SIN escalar
--              (el sprite simplemente se dibuja más grande desde ese punto,
--              sin recentrar). Para esos casos pasar originScale=1.
--
-- NOTA (intento de unificación REVERTIDO): en una ronda se quitó por completo
-- el escalado del origen acá, razonando (por análisis de cómo LÖVE auto-
-- escala ox/oy en graphics.lua:draw()) que esto sería consistente con el fix
-- de characters.lua (que sí necesita el origen SIN escalar, confirmado).
-- Eso rompió visualmente el stage "school" normal (sky/school/street/
-- treesBack/petals -- los que SÍ llaman setGraphicSize()+updateHitbox() en
-- Psych real), aunque "schoolEvil" siguió viéndose bien (no es sorpresa:
-- evilSchool ya usaba originScale=1 desde antes, así que el "unscale
-- universal" no le cambió nada). Conclusión empírica: personajes (vía
-- updateHitbox() + Group.add(), que SÍ aplica un comportamiento distinto en
-- Flixel) necesitan origen sin escalar; BGSprite con updateHitbox() (sin
-- Group) necesita origen escalado. No se encontró la razón exacta en el
-- código de Flixel (no está vendorizado en este repo, es un haxelib externo)
-- pero la diferencia es real y reproducible -- no volver a unificar sin
-- verificar en el juego real primero.

local atlas = require("charts.psych.atlas")
local graphics = require("modules.graphics")

local M = {}

local function framesByPrefix(frames, prefix)
	local result = {}
	for _, frame in ipairs(frames) do
		if frame.name and frame.name:sub(1, #prefix) == prefix then
			table.insert(result, frame)
		end
	end
	return result
end

local function frameByExactName(frames, name)
	for _, frame in ipairs(frames) do
		if frame.name == name then return frame end
	end
	return nil
end

function M.new(image, x, y, animArray, loop, scale, originScale)
	scale = scale or 1
	originScale = originScale or scale
	local pngPath = graphics.imagePath(image)
	local xmlPath = pngPath:gsub("%.png$", ".xml")
	local txtPath = pngPath:gsub("%.png$", ".txt")

	local img = love.graphics.newImage(pngPath)

	-- Igual que character.lua: formato decidido por existencia de archivo
	-- (Paths.getAtlas() de Psych real), nunca por contenido.
	local allFrames
	if love.filesystem.getInfo(xmlPath) then
		allFrames = atlas.loadSparrow(xmlPath)
	elseif love.filesystem.getInfo(txtPath) then
		allFrames = atlas.loadPacker(txtPath)
	else
		error("no se encontró atlas (.xml ni .txt) para '" .. image .. "'")
	end

	local frameData = {}
	local animData = {}
	local firstAnim

	for _, entry in ipairs(animArray or {}) do
		local name, matched

		if type(entry) == "table" then
			name = entry.name
			matched = {}
			for _, index in ipairs(entry.indices) do
				local frame = frameByExactName(allFrames, ("%s%04d"):format(entry.prefix, index))
				if frame then table.insert(matched, frame) end
			end
		else
			name = entry
			matched = framesByPrefix(allFrames, entry)
		end

		if #matched > 0 then
			local start = #frameData + 1
			for _, frame in ipairs(matched) do
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

			animData[name] = { start = start, stop = #frameData, speed = 24, offsetX = 0, offsetY = 0 }

			if not firstAnim then firstAnim = name end
		else
			print("WARN: bgsprite '" .. image .. "': sin frames para animación '" .. tostring(name) .. "'")
		end
	end

	if not firstAnim then
		error("bgsprite '" .. image .. "': ninguna animación tuvo frames válidos")
	end

	local sprite = graphics.newSprite(img, frameData, animData, firstAnim, loop or false)

	sprite.sizeX, sprite.sizeY = scale, scale

	local ox, oy = sprite:getOrigin()
	sprite.x = x + ox * originScale
	sprite.y = y + oy * originScale

	return sprite
end

return M
