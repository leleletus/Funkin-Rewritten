--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local imageType = "png"
local fade = {1}
local isFading = false

local fadeTimer

local screenWidth, screenHeight

-- Offset de shake de cámara: PURAMENTE visual, sumado al final de
-- pushParallax() sin tocar cam.x/y para nada. Antes (p.ej. el shake de
-- "TooSlowShakeFlash" en stages/AngelIsland/stage.lua) el shake escribía
-- directo en cam.x/y y apagaba _G.disableAutoCam mientras duraba -- al
-- reactivarla, el seguimiento automático de cámara (que se recrea cada
-- frame en states/weeks.lua) tenía que "alcanzar" desde la posición
-- congelada hasta el objetivo real, lo que se veía como un bamboleo feo
-- en vez de un corte limpio. Con un offset ADITIVO en el dibujado, cam.x/y
-- nunca se toca -- el seguimiento normal sigue corriendo de fondo sin
-- interrupción, el shake es pura cosmética encima.
local shakeOffsetX, shakeOffsetY = 0, 0

return {
	screenBase = function(width, height)
		screenWidth, screenHeight = width, height
	end,
	getWidth = function()
		return screenWidth
	end,
	getHeight = function()
		return screenHeight
	end,

	setShakeOffset = function(x, y)
		shakeOffsetX, shakeOffsetY = x or 0, y or 0
	end,

	-- Aplica la transformación de cámara para una capa de fondo con el
	-- scrollFactor `sf` indicado (igual que Flixel: 1 = misma velocidad que
	-- los personajes, <1 = más lento/lejano, >1 = más rápido/cercano), y la
	-- ancla siempre al CENTRO de pantalla sin importar `sf`.
	--
	-- Si solo se hiciera `translate(w*sf, h*sf)` antes de escalar, cada capa
	-- haría zoom alrededor de un punto distinto (w*sf, h*sf) en vez del
	-- centro real -- con sf bajo (fondos lejanos) el zoom de cada beat las
	-- hace "derivar" de forma visible relativo a los personajes. Con este
	-- pivote, sf solo afecta el paneo (cam.x/y), nunca el centro del zoom,
	-- y la posición de reposo (cam=0, zoom=1) no cambia: sigue siendo
	-- exactamente w*sf + sprite.x, igual que antes.
	--
	-- Llamar a love.graphics.pop() para cerrar, igual que con push() normal.
	pushParallax = function(sfX, sfY)
		sfY = sfY or sfX
		local w, h = screenWidth / 2, screenHeight / 2
		love.graphics.push()
		love.graphics.translate(w, h)
		love.graphics.scale(cam.sizeX, cam.sizeY)
		love.graphics.translate(
			w * (sfX - 1) + cam.x * sfX + shakeOffsetX,
			h * (sfY - 1) + cam.y * sfY + shakeOffsetY
		)
	end,

	imagePath = function(path)
		local pathStr = "images/" .. imageType .. "/" .. path .. "." .. imageType

		if love.filesystem.getInfo(pathStr) then
			return pathStr
		else
			return "images/png/" .. path .. ".png"
		end
	end,
	setImageType = function(type)
		imageType = type
	end,
	getImageType = function()
		return imageType
	end,

	newImage = function(imageData, optionsTable)
		local image, width, height

		local options

		local object = {
			x = 0,
			y = 0,
			orientation = 0,
			sizeX = 1,
			sizeY = 1,
			offsetX = 0,
			offsetY = 0,
			shearX = 0,
			shearY = 0,

			setImage = function(self, imageData)
				image = imageData
				width = image:getWidth()
				height = image:getHeight()
			end,

			getImage = function(self)
				return image
			end,

			draw = function(self)
				if self.visible == false then return end
				local x = self.x
				local y = self.y

				if options and options.floored then
					x = math.floor(x)
					y = math.floor(y)
				end

				-- self.shader: opt-in, nil por defecto -- mismo criterio que
				-- newSprite() más abajo (usado por el shader HSL de Sserafim
				-- sobre los props de fondo, que se cargan vía newImage()).
				if self.shader then love.graphics.setShader(self.shader) end

				love.graphics.draw(
					image,
					self.x,
					self.y,
					self.orientation,
					self.sizeX,
					self.sizeY,
					math.floor(width / 2) + self.offsetX,
					math.floor(height / 2) + self.offsetY,
					self.shearX,
					self.shearY
				)

				if self.shader then love.graphics.setShader() end
			end
		}

		object:setImage(imageData)

		options = optionsTable

		return object
	end,

	newSprite = function(imageData, frameData, animData, animName, loopAnim, optionsTable)
		local sheet, sheetWidth, sheetHeight

		local frames = {}
		-- frameImages[i]: nil para frames normales (se dibujan del `sheet`
		-- compartido) -- solo se llena para frames con rotated=true (Sparrow/
		-- TexturePacker pueden empacar un frame rotado 90° para ahorrar
		-- espacio; Nene.xml de Weekend 1 tiene TODOS sus frames así). Se
		-- "des-rota" UNA SOLA VEZ a un canvas propio al crear el sprite, en
		-- vez de hacerlo cada draw() -- ver el loop de construcción de
		-- `frames` más abajo.
		local frameImages = {}
		local frame
		local anims = animData
		local anim = {
			name = nil,
			start = nil,
			stop = nil,
			speed = nil,
			offsetX = nil,
			offsetY = nil
		}

		-- Pivote FIJO opt-in (options.fixedPivot): SOLO lo usan los
		-- personajes (charts/psych/character.lua), nadie mas -- el
		-- comportamiento por defecto del modulo sigue intacto para los
		-- otros 160+ usos de newSprite (notas, menus, alfabeto, iconos,
		-- etc.) -- esos tienen frames con y sin recorte real mezclados en
		-- la MISMA animacion, asi que cualquier heuristica basada en
		-- "tiene recorte real" para distinguir personajes del resto les
		-- rompia el dibujado igual.
		--
		-- Anclado POR ANIMACION (no global a "idle"): se recalcula cada
		-- vez que animate() arranca una animacion nueva, usando el
		-- PRIMER frame de ESA animacion como referencia (ver animate()
		-- mas abajo). Para el primer frame de cualquier animacion esto
		-- da EXACTAMENTE el mismo resultado que el calculo original (sin
		-- pivote fijo) -- que es lo que Psych ya tiene tuneado en
		-- "offsets" -- y solo evita el bamboleo entre frames DENTRO de
		-- esa misma animacion. Un ancla GLOBAL (siempre "idle") se probo
		-- antes y rompia personajes cuyo canvas varia MUCHO entre
		-- animaciones (Pico: idle 453px de ancho vs singDOWN 736px) --
		-- mezclar el canvas de "idle" con el offset tuneado para
		-- "singDOWN" no tiene sentido si Psych asumio el canvas de la
		-- propia animacion al tunear ese offset.
		local referenceOx, referenceOy = 0, 0

		local isAnimated
		local isLooped
		local animCallback  -- callback al terminar la animación (si no loop)

		local options

		local object = {
			x = 0,
			y = 0,
			orientation = 0,
			sizeX = 1,
			sizeY = 1,
			offsetX = 0,
			offsetY = 0,
			shearX = 0,
			shearY = 0,
			visible = true,  -- soporte para ocultar sprites

			setSheet = function(self, imageData)
				sheet = imageData
				sheetWidth = sheet:getWidth()
				sheetHeight = sheet:getHeight()
			end,

			getSheet = function(self)
				return sheet
			end,

			animate = function(self, animName, loopAnim, callback, ...)
				if not anims[animName] then
					print("WARN: animación '" .. tostring(animName) .. "' no existe en sprite, ignorando")
					return
				end

				-- BUG corregido (mismo patrón que charts/psych/character.lua
				-- -- ver FlxAnim.hx real, play(): "Force = Force || finished
				-- || curInstance != curThing.instance"): llamar animate()
				-- con la MISMA animación que YA está activa no debe
				-- reiniciar el frame -- antes esto reiniciaba SIEMPRE, sin
				-- condición. weeks.lua re-dispara la animación de canto en
				-- cada segmento de una nota larga/hold -- con el reset
				-- incondicional, cada segmento volvía a frame 1, dejando al
				-- personaje prácticamente sin animar (o "tieso") durante
				-- TODA nota sostenida, para CUALQUIER personaje Sparrow, no
				-- solo los de atlas.
				local sameAnim = (animName == anim.name) and isAnimated

				anim.name = animName
				anim.start = anims[animName].start
				anim.stop = anims[animName].stop
				anim.speed = anims[animName].speed
				anim.offsetX = anims[animName].offsetX
				anim.offsetY = anims[animName].offsetY

				isLooped = loopAnim

				if sameAnim then return end

				frame = anim.start
				animCallback = callback  -- puede ser nil

				isAnimated = true
			end,
			getAnims = function(self)
				return anims
			end,
			-- FASE 3 de la refactorización de ergonomía de modding (ver
			-- memoria del proyecto "modding-ergonomics-refactor"): registra
			-- en caliente una animación de UN solo frame respaldada por su
			-- PROPIA imagen (no el `sheet` compartido del atlas con el que se
			-- creó este sprite) -- mismo mecanismo que ya usan los frames
			-- `rotated=true` de Sparrow/TexturePacker más abajo
			-- (frameImages[i], ya leído por draw() en
			-- "frameImages[flooredFrame] or sheet"), solo que sin la rotación.
			-- Pensado para sprites/icons.lua: un ícono nuevo, no registrado
			-- en su tabla `characters`, se carga y se agrega así, sin tocar
			-- el resto del sprite ni el atlas combinado.
			addStandaloneAnim = function(self, animName, image, x, y, w, h)
				x, y = x or 0, y or 0
				w, h = w or image:getWidth(), h or image:getHeight()
				local i = #frames + 1
				frameImages[i] = image
				frames[i] = love.graphics.newQuad(x, y, w, h, image:getWidth(), image:getHeight())
				anims[animName] = { start = i, stop = i, speed = 0, offsetX = 0, offsetY = 0 }
			end,
			getAnimName = function(self)
				return anim.name
			end,
			setAnimSpeed = function(self, speed)
				anim.speed = speed
			end,
			isAnimated = function(self)
				return isAnimated
			end,
			isAnimFinished = function(self)
				return not isAnimated
			end,
			isLooped = function(self)
				return isLooped
			end,

			getFrameWidth = function(self)
				local f = math.floor(frame)
				if f >= 1 and f <= #frameData then
					return frameData[f].width
				end
				return frameData[1] and frameData[1].width or 0
			end,
			getFrameHeight = function(self)
				local f = math.floor(frame)
				if f >= 1 and f <= #frameData then
					return frameData[f].height
				end
				return frameData[1] and frameData[1].height or 0
			end,
			-- Para el visor de frames del debug: fija un frame exacto sin animación
			setFrame = function(self, f)
				frame = math.max(1, math.min(math.floor(f), #frameData))
				anim.start = 1
				anim.stop  = #frameData
				isAnimated = false
			end,
			getCurrentFrame = function(self)
				return math.floor(frame)
			end,
			getFrameData = function(self)
				return frameData
			end,
			getFrameCount = function(self)
				return #frameData
			end,

			-- Origen (ox, oy) que draw() usaría para el frame dado (por defecto
			-- el frame inicial de la animación actual). Representa el punto del
			-- frame trimado que coincide con self.x/self.y en pantalla — es decir,
			-- el centro del bounding box SIN trim (igual que Flixel calcula el
			-- offset de frame). Útil para convertir coordenadas Psych Engine
			-- (top-left del bounding box sin trim) a las de FNF Rewritten
			-- (centro del bounding box sin trim): rewritten = psych + (ox, oy).
			getOrigin = function(self, frameIndex)
				local f = frameData[frameIndex or anim.start or 1]
				if not f then return 0, 0 end

				local ox, oy

				if f.offsetWidth == 0 then
					ox = math.floor(f.width / 2)
				else
					ox = math.floor(f.offsetWidth / 2) + f.offsetX
				end

				if f.offsetHeight == 0 then
					oy = math.floor(f.height / 2)
				else
					oy = math.floor(f.offsetHeight / 2) + f.offsetY
				end

				return ox, oy
			end,

			setOptions = function(self, optionsTable)
				options = optionsTable
			end,
			getOptions = function(self)
				return options
			end,

			update = function(self, dt)
				if isAnimated then
					frame = frame + anim.speed * dt
				end

				if isAnimated and frame > anim.stop then
					if isLooped then
						frame = anim.start
					else
						isAnimated = false
						if animCallback then
							local cb = animCallback
							animCallback = nil  -- limpiar antes de llamar (evita loops)
							cb()
						end
					end
				end
			end,
			draw = function(self)
				if self.visible == false then return end

				local flooredFrame = math.floor(frame)

				if flooredFrame <= anim.stop then
					local x = self.x
					local y = self.y
					local width
					local height

					if options and options.floored then
						x = math.floor(x)
						y = math.floor(y)
					end

					if options and options.noOffset then
						if frameData[flooredFrame].offsetWidth ~= 0 then
							width = frameData[flooredFrame].offsetX
						end
						if frameData[flooredFrame].offsetHeight ~= 0 then
							height = frameData[flooredFrame].offsetY
						end
					elseif options and options.fixedPivot then
						-- Pivote fijo (frame ancla de la animación inicial) +
						-- recorte del frame ACTUAL -- solo personajes
						-- (character.lua pasa fixedPivot=true).
						--
						-- X e Y se tratan INDEPENDIENTES: un personaje puede
						-- tener sizeX<0 (flip_x) sin que sizeY lo esté (caso
						-- normal -- nadie en este juego espeja verticalmente).
						--
						-- Rama SIN espejar (por eje): confirmada buena. NO
						-- tocar sin probar en el juego real.
						--
						-- Rama ESPEJADA (por eje, ej. sizeX<0 -- Pico,
						-- Tankman): FlxFrame.hx real NO espeja simplemente
						-- invirtiendo la escala -- aplica, por cada frame
						-- individual: mat.scale(-1,1); mat.translate(w,0);
						-- con w = sourceSize.x = el ANCHO DEL CANVAS de ESE
						-- frame (nuestro offsetWidth, o width si no hay
						-- recorte real). Esto reemplaza el "+offsetX" de la
						-- rama sin espejar por "+ canvas + offsetX - pivote
						-- fijo" -- un término que SOLO existe al espejar, y
						-- que antes faltaba por completo (de ahí que el error
						-- creciera con el ancho del canvas del frame actual:
						-- catastrófico en frames muy anchos como "Pico Down
						-- Note", canvas de 736px).
						if self.sizeX and self.sizeX < 0 then
							local canvasW = frameData[flooredFrame].offsetWidth == 0 and frameData[flooredFrame].width or frameData[flooredFrame].offsetWidth
							width = canvasW + frameData[flooredFrame].offsetX - referenceOx
						elseif frameData[flooredFrame].offsetWidth == 0 then
							width = referenceOx
						else
							width = referenceOx + frameData[flooredFrame].offsetX
						end

						if self.sizeY and self.sizeY < 0 then
							local canvasH = frameData[flooredFrame].offsetHeight == 0 and frameData[flooredFrame].height or frameData[flooredFrame].offsetHeight
							height = canvasH + frameData[flooredFrame].offsetY - referenceOy
						elseif frameData[flooredFrame].offsetHeight == 0 then
							height = referenceOy
						else
							height = referenceOy + frameData[flooredFrame].offsetY
						end
					else
						if frameData[flooredFrame].offsetWidth == 0 then
							width = math.floor(frameData[flooredFrame].width / 2)
						else
							width = math.floor(frameData[flooredFrame].offsetWidth / 2) + frameData[flooredFrame].offsetX
						end
						if frameData[flooredFrame].offsetHeight == 0 then
							height = math.floor(frameData[flooredFrame].height / 2)
						else
							height = math.floor(frameData[flooredFrame].offsetHeight / 2) + frameData[flooredFrame].offsetY
						end
					end

					-- anim.offsetX/Y (el campo "offsets" de Psych, ej. characters/*.json)
					-- y self.offsetX/Y (usado por el editor de offsets) representan un
					-- ajuste manual en píxeles "crudos" de Psych -- NO deben escalarse
					-- por sizeX/Y. Pero love.graphics.draw() recibe ox,oy como
					-- parámetros DENTRO del espacio local del quad, que LÖVE escala
					-- automáticamente por sx,sy al dibujar -- así que sin dividir antes,
					-- cualquier offset terminaba multiplicado por la escala del
					-- personaje. Para personajes normales (escala 1) esto era invisible;
					-- para personajes pixel (escala 6) cualquier offset quedaba 6x más
					-- grande de lo que debía -- catastrófico para personajes con offsets
					-- grandes (Spirit: -218,-280 -> desplazamiento real de -1308,-1680px),
					-- y una causa de descolocación más sutil para el resto (Senpai,
					-- BF-pixel, GF-pixel) con offsets más chicos.
					-- División con SIGNO (no abs): el ajuste manual ("offsets" de
					-- Psych) debe verse igual sin importar si el personaje está
					-- espejado (flip_x) -- es un nudge en píxeles de pantalla
					-- que quien armó el JSON ajustó mirando el personaje YA
					-- espejado (ej. Pico, Tankman: flip_x=true siempre como
					-- enemigo). Si se usara abs() acá, el término quedaría
					-- multiplicado por sign(sizeX) en el dibujado final
					-- (love.graphics.draw multiplica ox por sx con signo), o
					-- sea que CUALQUIER personaje espejado tendría el ajuste
					-- de cada animación aplicado en la dirección contraria --
					-- exactamente el bug reportado para Pico/Tankman (offsets
					-- mal SOLO en los personajes con la X flippeada). Dividir
					-- por sizeX con signo cancela la escala Y el signo,
					-- dejando el ajuste como un desplazamiento de
					-- pantalla fijo, igual en cualquier escala/orientación --
					-- que es justo lo que se busca: Spirit (escala 6, sin
					-- flip) sigue funcionando igual que antes (con sizeX
					-- positivo, abs(sizeX) y sizeX dan lo mismo).
					local offsetScaleX = self.sizeX ~= 0 and self.sizeX or 1
					local offsetScaleY = self.sizeY ~= 0 and self.sizeY or 1

					-- self.shader: opt-in, nil por defecto (no afecta a ningún
					-- sprite existente). Usado por el splash "vanilla" de Psych
					-- (states/weeks.lua) para el tintado RGB por carril -- el
					-- mismo mecanismo que Psych real hace con un shader de
					-- Flixel (NoteSplash.hx:PixelSplashShader), acá vía
					-- love.graphics.setShader.
					if self.shader then
						love.graphics.setShader(self.shader)
					end

					love.graphics.draw(
						frameImages[flooredFrame] or sheet,
						frames[flooredFrame],
						x,
						y,
						self.orientation,
						self.sizeX,
						self.sizeY,
						width + anim.offsetX / offsetScaleX + self.offsetX / offsetScaleX,
						height + anim.offsetY / offsetScaleY + self.offsetY / offsetScaleY,
						self.shearX,
						self.shearY
					)

					if self.shader then
						love.graphics.setShader()
					end
				end
			end
		}

		object:setSheet(imageData)

		for i = 1, #frameData do
			local fd = frameData[i]

			if fd.rotated then
				-- TexturePacker/Sparrow "rotated=true": el frame se guardó
				-- rotado 90° en la hoja para ahorrar espacio -- la región en
				-- (x,y) mide REALMENTE height x width (ejes intercambiados),
				-- no width x height. Se "des-rota" UNA vez a un canvas propio
				-- de tamaño width x height (la orientación correcta), así el
				-- resto del archivo (offsets, recorte, flip) sigue
				-- funcionando exactamente igual que con un frame normal.
				local sheetQuad = love.graphics.newQuad(
					fd.x, fd.y, fd.height, fd.width, sheetWidth, sheetHeight
				)
				local canvas = love.graphics.newCanvas(fd.width, fd.height)
				canvas:setFilter(imageData:getFilter())

				love.graphics.push("all")
				love.graphics.setCanvas(canvas)
				love.graphics.clear(0, 0, 0, 0)
				love.graphics.origin()
				-- Color BLANCO explícito: este horneado pasa UNA sola vez,
				-- al crear el sprite -- si el color activo de LÖVE en ESE
				-- momento no era blanco (p.ej. durante un fade-in/out de la
				-- pantalla de carga, que sí puede estar corriendo mientras
				-- se cargan personajes en pleno gameplay), el tinte quedaba
				-- grabado para siempre en el canvas (de ahí que Nene se
				-- viera negra en gameplay pero bien en el editor de
				-- offsets, que no pasa por ninguna pantalla de carga).
				love.graphics.setColor(1, 1, 1, 1)
				-- Rotar -90° alrededor de (ox=0, oy=fd.height) y trasladar
				-- por (fd.height, fd.height) -- verificado a mano resolviendo
				-- la transformación completa de love.graphics.draw() para
				-- las 4 esquinas del quad fuente: con traslación (0,0) (como
				-- estaba antes) el contenido caía ENTERO afuera del canvas
				-- (corrido en -fd.height en ambos ejes) -- de ahí que casi
				-- ningún frame rotado se viera. Con (fd.height, fd.height)
				-- las 4 esquinas mapean exactamente a las esquinas del
				-- canvas [0,fd.width]x[0,fd.height].
				love.graphics.draw(imageData, sheetQuad, fd.height, fd.height, -math.pi / 2, 1, 1, 0, fd.height)
				love.graphics.pop()

				frameImages[i] = canvas
				table.insert(frames, love.graphics.newQuad(0, 0, fd.width, fd.height, fd.width, fd.height))
			else
				table.insert(
					frames,
					love.graphics.newQuad(
						fd.x,
						fd.y,
						fd.width,
						fd.height,
						sheetWidth,
						sheetHeight
					)
				)
			end
		end

		object:animate(animName, loopAnim)

		-- Fija el pivote de referencia UNA SOLA VEZ (global al sprite, no
		-- por animación), usando el frame ancla de la animación INICIAL
		-- (anim.start recién establecido por animate() arriba). Nunca se
		-- recalcula después.
		if optionsTable and optionsTable.fixedPivot then
			local anchorFrame = frameData[anim.start]
			if anchorFrame then
				referenceOx = anchorFrame.offsetWidth == 0 and math.floor(anchorFrame.width / 2) or math.floor(anchorFrame.offsetWidth / 2)
				referenceOy = anchorFrame.offsetHeight == 0 and math.floor(anchorFrame.height / 2) or math.floor(anchorFrame.offsetHeight / 2)
			end
		end

		options = optionsTable

		object.anims = anims

		return object
	end,

	setFade = function(value)
		if fadeTimer then
			Timer.cancel(fadeTimer)

			isFading = false
		end

		fade[1] = value
	end,
	getFade = function(value)
		return fade[1]
	end,
	fadeOut = function(duration, func)
		if fadeTimer then
			Timer.cancel(fadeTimer)
		end

		isFading = true

		fadeTimer = Timer.tween(
			duration,
			fade,
			{0},
			"linear",
			function()
				isFading = false

				if func then func() end
			end
		)
	end,
	fadeIn = function(duration, func)
		if fadeTimer then
			Timer.cancel(fadeTimer)
		end

		isFading = true

		fadeTimer = Timer.tween(
			duration,
			fade,
			{1},
			"linear",
			function()
				isFading = false

				if func then func() end
			end
		)
	end,
	isFading = function()
		return isFading
	end,

	clear = function(r, g, b, a, s, d)
		local fade = fade[1]

		love.graphics.clear(fade * r, fade * g, fade * b, a, s, d)
	end,
	setColor = function(r, g, b, a)
		local fade = fade[1]

		love.graphics.setColor(fade * r, fade * g, fade * b, a)
	end,
	setBackgroundColor = function(r, g, b, a)
		local fade = fade[1]

		love.graphics.setBackgroundColor(fade * r, fade * g, fade * b, a)
	end,
	getColor = function()
		local r, g, b, a = love.graphics.getColor()
		local fade = fade[1]

		return r / fade, g / fade, b / fade, a
	end
}