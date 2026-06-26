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
local animateAtlas = require("modules.animate_atlas")

local M = {}

local atlasCache = {}

-- Personajes Adobe Animate (darnell-blazin.json, pico-blazin.json -- la
-- pelea "Blazin Fight" de Weekend 1): Character.hx real detecta este caso
-- igual -- existencia de "images/<json.image>/Animation.json", nunca por
-- contenido del JSON del personaje. A diferencia de Sparrow XML, TODA la
-- hoja de animaciones de estos personajes vive en UN solo símbolo enorme
-- ("Darnell Fighting ALL ANIMS"/"Pico Fighting ALL ANIMS"), y cada "anim"
-- de Psych es un RANGO de índices contiguo dentro de ese símbolo (nunca
-- salteado en los JSON reales) -- ver modules/animate_atlas.lua:
-- Instance:playSymbolRange().
local function loadAnimateCharacter(def, jsonPath, isPlayer)
	local folderPath = "images/png/" .. def.image

	local ok, data = pcall(animateAtlas.load, folderPath)
	if not ok then
		error("no se pudo cargar el atlas Adobe Animate '" .. folderPath .. "': " .. tostring(data))
	end

	local inst = animateAtlas.newInstance(data)

	-- animName interno -> {symbolName, startIdx, endIdx, loop, offsetX, offsetY}
	local animLookup = {}
	local firstAnim

	for _, animDef in ipairs(def.animations or {}) do
		local internalName = animnames.toInternal(animDef.anim)
		local indices = animDef.indices

		local startIdx, endIdx
		if indices and #indices > 0 then
			startIdx, endIdx = indices[1], indices[#indices]
		end

		local offsets = animDef.offsets or {0, 0}

		animLookup[internalName] = {
			symbolName = animDef.name,
			startIdx = startIdx,
			endIdx = endIdx,
			loop = animDef.loop or false,
			offsetX = offsets[1] or 0,
			offsetY = offsets[2] or 0,
		}

		if not firstAnim then firstAnim = internalName end
	end

	if not firstAnim then
		error("el personaje Adobe Animate '" .. jsonPath .. "' no tiene ninguna animación")
	end

	local currentAnimName = nil
	local currentLoop = false
	local animCallback = nil
	local wasFinished = false

	local sprite = {
		x = 0, y = 0,
		orientation = 0,
		sizeX = 1, sizeY = 1,
		offsetX = 0, offsetY = 0,
		visible = true,
		alpha = 1,

		-- getOrigin(): (0,0) por defecto. Personajes YA EXISTENTES en el
		-- proyecto que usan este loader (darnell-blazin/pico-blazin/
		-- title-screen-text) vienen de PSYCH Engine, confirmado SIN
		-- ningún concepto de "characterOrigin" (cero referencias en todo
		-- FNF-PsychEngine-main/source/objects/Character.hx:
		-- copyAtlasValues() solo copia x/y directo) -- (0,0) es exacto
		-- para ellos, y sus posiciones ya están afinadas a mano contra
		-- ese valor (tankmanCutscene/picoCutscene en
		-- stages/military/stage.lua) -- cambiar el default los rompería.
		--
		-- Personajes que vienen del motor MODERNO real (Sserafim) SÍ usan
		-- characterOrigin -- confirmado en
		-- funkin/play/character/BaseCharacter.hx:get_characterOrigin():
		-- "xPos = width/2; yPos = height" (centro-X, PISO-Y del bounding
		-- box real, no (0,0)) -- de ahí que sus personajes aparecieran
		-- lejísimos de su posición real. Opt-in vía "originMode" en el
		-- JSON (NO default general, ver párrafo anterior), con DOS modos
		-- reales distintos -- confirmado leyendo el .hxc/.hx real, no
		-- adivinado:
		--   "feet"     : BaseCharacter real (los 6 personajes de Sserafim
		--                que SÍ son "character", vía slot o standalone) --
		--                -(minX+w/2), -(minY+h).
		--   "topleft"  : sserafimCutscene/sserafimGf/sserafimBf, que NO
		--                heredan de BaseCharacter -- extienden FunkinSprite
		--                DIRECTO (confirmado: cero override de x/y/position
		--                ahí), o sea Flixel estándar (x,y = esquina
		--                superior izquierda del bounding box, SIN ningún
		--                characterOrigin) -- -minX, -minY (alinea el
		--                origen LOCAL del símbolo con esa esquina, sin el
		--                centrado/piso de "feet").
		-- Cualquier otro valor (incl. nil, el default real para
		-- darnell-blazin/pico-blazin/title-screen-text): (0,0), sin tocar
		-- su comportamiento ya afinado a mano.
		getOrigin = function(self)
			if def.originMode == "feet" then
				local minX, minY, w, h = animateAtlas.getInstanceBounds(inst)
				return -(minX + w / 2), -(minY + h)
			elseif def.originMode == "topleft" then
				local minX, minY = animateAtlas.getInstanceBounds(inst)
				return -minX, -minY
			end
			return 0, 0
		end,

		-- Expone el bounding box crudo (sin convertir a origen) -- para
		-- diagnóstico (ver states/sserafim-stage-debug.lua) sin tener que
		-- reverse-ingenierar minX/minY/w/h a partir de getOrigin().
		getBounds = function(self)
			return animateAtlas.getInstanceBounds(inst)
		end,

		-- Expone el Instance crudo de modules/animate_atlas.lua -- usado
		-- por modules/lipsync.lua (animateAtlas.findNamedTransform(inst,
		-- ...)) para encontrar, en el frame ACTUAL de este personaje, dónde
		-- cae el placeholder "mouth default"/"mouth edit"/"mouth yunjin" y
		-- dibujar ahí el sprite de boca por separado.
		getAtlasInstance = function(self)
			return inst
		end,

		animate = function(self, animName, loopOverride, callback)
			local entry = animLookup[animName]
			if not entry then
				print("WARN: animación '" .. tostring(animName) .. "' no existe en personaje Adobe Animate, ignorando")
				return
			end

			-- BUG corregido (verificado contra FlxAnim.hx real, play():
			-- "Force = Force || finished || curInstance != curThing.instance"
			-- -- solo reinicia el frame si la animación CAMBIA o ya terminó).
			-- weeks.lua:safeAnimate() llama a animate() con la MISMA
			-- animación en CADA frame mientras se sostiene una nota larga
			-- (ver el chequeo "input:down(curInput) and ... hold/end" en
			-- weeks.lua) -- inst:playSymbol()/playSymbolRange() reinicia
			-- self.frame=0 SIEMPRE, sin condición, así que el personaje
			-- quedaba prácticamente congelado en el frame 0 (con un leve
			-- vaivén hacia ~0.5 frames y de vuelta, según el timing exacto
			-- entre llamadas) durante TODA nota sostenida -- el "bamboleo"
			-- reportado en Sakura.
			local sameAnim = (animName == currentAnimName) and not inst:isFinished()

			currentAnimName = animName
			currentLoop = (loopOverride ~= nil) and loopOverride or entry.loop
			animCallback = callback

			if sameAnim then
				inst.looping = currentLoop
				return
			end

			wasFinished = false

			if entry.startIdx then
				inst:playSymbolRange(entry.symbolName, entry.startIdx, entry.endIdx, currentLoop)
			else
				inst:playSymbol(entry.symbolName, currentLoop)
			end
		end,

		getAnims = function(self)
			return animLookup
		end,

		getAnimName = function(self)
			return currentAnimName
		end,

		isAnimated = function(self)
			return not inst.finished
		end,

		-- Agregados para que states/character-offset-debug.lua (el editor
		-- genérico de personajes, hecho originalmente solo para sprites
		-- Sparrow vía modules/graphics.lua) también funcione con
		-- personajes Adobe Animate -- sin esto, sprite:getFrameCount()
		-- (usado para el contador "Frame: X/Y" y A/D de avance manual)
		-- crasheaba al cargar cualquiera de estos personajes.
		getFrameCount = function(self)
			local entry = animLookup[currentAnimName]
			if not entry then return 1 end
			if entry.startIdx then
				return entry.endIdx - entry.startIdx + 1
			end
			return animateAtlas.symbolLength(inst.data, entry.symbolName)
		end,

		getCurrentFrame = function(self)
			return math.floor(inst.frame) + 1
		end,

		setFrame = function(self, f)
			inst.frame = f - 1
		end,

		-- animate_atlas.lua no soporta velocidad variable por instancia
		-- (frameRate vive en `data`, compartido entre instancias del MISMO
		-- atlas) -- no usado por darnell-blazin/pico-blazin en Psych real
		-- (sing_duration fijo, sin "Set GF Speed"), no-op intencional.
		setAnimSpeed = function(self, speed) end,

		update = function(self, dt)
			inst:update(dt)

			if inst.finished and not wasFinished then
				wasFinished = true
				local cb = animCallback
				animCallback = nil
				if cb then cb() end
			end
		end,

		-- BUG corregido: el campo "offsets" del JSON se guardaba en
		-- animLookup (ver arriba, "offsetX = offsets[1]...") pero NUNCA se
		-- aplicaba en ningún lado para personajes Adobe Animate -- a
		-- diferencia de Sparrow (modules/graphics.lua SÍ lo usa para el
		-- pivote de cada draw) quedaba completamente inerte acá. Esto
		-- importa en particular para personajes cuyas animaciones de
		-- canto/fallo se disparan por el mecanismo NORMAL de notas
		-- durante el juego real (Sakura/boyfriend es el único caso de
		-- Sserafim -- las otras 5 solo cambian de animación cuando un
		-- script las redirige a mano) -- sin esto, cualquier diferencia
		-- de alineación interna entre "idle" y las poses de canto/fallo
		-- (MUY probable, dado que cada pose es un dibujo manual distinto
		-- dentro del símbolo, no garantizado a estar centrado igual)
		-- hace que el personaje "salte" de posición exactamente cuando
		-- empieza a cantar -- justo lo reportado.
		draw = function(self)
			if self.visible == false then return end
			local entry = animLookup[currentAnimName]
			local offX = (entry and entry.offsetX) or 0
			local offY = (entry and entry.offsetY) or 0
			inst.x, inst.y = self.x + offX, self.y + offY
			inst.sizeX, inst.sizeY = self.sizeX, self.sizeY
			inst.alpha = self.alpha
			inst.visible = true
			inst.shader = self.shader -- opt-in, nil por defecto (ver modules/animate_atlas.lua)
			inst:draw()
		end,
	}

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

	sprite:animate(firstAnim, animLookup[firstAnim].loop)

	return sprite
end

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
	-- El atlas (.xml/.txt) SIEMPRE vive junto al .png fuente, nunca como
	-- variante .dds -- derivarlo de graphics.imagePath() (que devuelve .dds
	-- en modo compresión de hardware) rompía esto en cuanto el .png tenía
	-- también un .dds (el gsub("%.png$",...) no hacía nada sobre una ruta
	-- que termina en .dds, dejando xmlPath/txtPath apuntando a un .dds).
	local xmlPath = "images/png/" .. imagePath .. ".xml"
	local txtPath = "images/png/" .. imagePath .. ".txt"

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

-- Replica FlxAnimationController.addByIndices REAL de Flixel: no reconstruye
-- el nombre exacto pegando "<prefix><índice de 4 dígitos>" -- eso rompía
-- cualquier atlas cuyo nombre real tenga algo entre el prefijo y el número
-- (p.ej. "GF Crying at Gunpoint 0000", CON espacio antes del índice -- así
-- es el atlas real de Psych para gf-tankmen "sad", confirmado comparando
-- byte a byte contra FNF-PsychEngine-main; el JSON de Psych tampoco lleva
-- ese espacio en "name", así que reconstruir con concat directo nunca iba
-- a matchear). Flixel real extrae el SUFIJO de cada frame que ya matcheó
-- por prefijo, lo interpreta como número (tonumber ya recorta espacios) y
-- compara contra el índice pedido -- por eso un espacio de más no importa.
-- byPrefix: la lista YA filtrada por framesByPrefix (mismo prefijo).
local function frameByIndex(byPrefix, prefix, index)
	for _, frame in ipairs(byPrefix) do
		if tonumber(frame.name:sub(#prefix + 1)) == index then
			return frame
		end
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

	-- Detección igual que Character.hx real: existencia de Animation.json
	-- junto a la imagen, nunca por contenido del JSON del personaje.
	if love.filesystem.getInfo("images/png/" .. def.image .. "/Animation.json") then
		return loadAnimateCharacter(def, jsonPath, isPlayer)
	end

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
				local frame = frameByIndex(byPrefix, animDef.name, index)

				if frame then table.insert(selected, frame) end
			end
		else
			selected = byPrefix
		end

		if #selected > 0 then
			local start = #frameData + 1

			for _, frame in ipairs(selected) do
				-- rotated=true: width/height del XML describen el rectángulo
				-- TAL COMO está empacado en la hoja (verificado empíricamente
				-- contra Nene.xml -- esos valores NO se superponen entre
				-- frames sin intercambiar). frameX/Y/frameWidth/frameHeight
				-- (el canvas completo) YA están en la orientación lógica
				-- final -- no se tocan. Para que el resto del motor (origen,
				-- offsets, etc.) trabaje con el tamaño LÓGICO (post-rotación)
				-- en width/height, hay que intercambiarlos acá -- ver
				-- modules/graphics.lua:newSprite() para el "des-rotado" real
				-- del Quad, que asume justamente que width/height YA vienen
				-- intercambiados.
				local fw, fh = frame.width, frame.height
				if frame.rotated then fw, fh = fh, fw end

				table.insert(frameData, {
					x = frame.x,
					y = frame.y,
					width = fw,
					height = fh,
					offsetX = frame.frameX,
					offsetY = frame.frameY,
					offsetWidth = frame.frameWidth,
					offsetHeight = frame.frameHeight,
					rotated = frame.rotated,
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
