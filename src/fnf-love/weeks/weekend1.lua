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

local song, difficulty

local stageData
local stageLayers = {}
local backgroundSprites = {}
local lastBeatTime = 0

-- Blazin fight system
local blazinFight = require("states.blazinFight")
local isBlazinSong = false
local blazinEnemyLayer = nil   -- layer ref for Darnell fighting sprite
local blazinBfLayer = nil      -- layer ref for Pico fighting sprite

-- Referencias para los componentes de Nene/Abot
local abotSystem = nil
local abotAis = nil
local lastCamFocus = nil  -- "player" o "oponent", para saber cuándo cambiar ojos

-- Posición del nastyObject3 (usado como objetivo de cámara al enfocar a Nene/char=2)
-- Valor de fallback tomado de philly.lua; se sobreescribe al cargar el stage.
local nastyObject3Pos = {x = 13, y = -85}

-- Posición del nastyObject (usado como objetivo de cámara al enfocar a Pico/char=0)
-- Valor de fallback tomado de philly.lua; se sobreescribe al cargar el stage.
local nastyObjectPos = {x = 371.85714285714, y = 35.142857142857}

-- =====================================================================
-- Sistema de semáforo y vehículos (portado de PhillyStreets.hx)
-- =====================================================================
local phillyTraffic = nil     -- sprite del semáforo
local phillyCars = nil        -- sprite del carro 1 (va hacia adelante)
local phillyCars2 = nil       -- sprite del carro 2 (va hacia atrás, flipX)
local phillyCarsLayer = nil   -- referencia al layer del carro 1 en stageLayers
local phillyCars2Layer = nil  -- referencia al layer del carro 2 en stageLayers
local phillyTrafficLayer = nil -- referencia al layer del semáforo en stageLayers

-- Estado del semáforo
local lightsStop = false
local lastLightChange = 0     -- último beat donde cambiaron las luces
local changeInterval = 8      -- beats entre cambios de luz

-- Estado de los carros
local carWaiting = false
local carInterruptable = true
local car2Interruptable = true

-- Tweens activos para carros (para poder cancelarlos)
local carTween = nil
local carAngleTween = nil
local car2Tween = nil
local car2AngleTween = nil

-- Beat tracking para el sistema de carros/semáforo
local curBeat = 0
local lastBeatTimeTraffic = 0

-- =====================================================================
-- Rain Shader System (portado de PhillyStreets.hx / RainShader.hx)
-- =====================================================================
local rainShader = nil
local rainCanvas = nil
local rainTime = 0
local rainShaderStartIntensity = 0
local rainShaderEndIntensity = 0

-- =====================================================================
-- Blazin: Lightning system (portado de PhillyBlazin.hx)
local LIGHTNING_FULL_DURATION = 1.5   -- duración del fade del cielo
local LIGHTNING_FLASH_DURATION = 0.08 -- flash blanco: muy rápido (≈2 frames a 24fps)
-- =====================================================================
local lightningSprite = nil     -- referencia al sprite del rayo (capturado desde stageLayers)
local lightningLayer  = nil     -- referencia al layer del rayo en stageLayers
local lightningTimer  = 3.0     -- tiempo hasta el próximo rayo
local lightningSounds = {}      -- Lightning1.ogg, Lightning2.ogg, Lightning3.ogg
-- Shader addColor para el flash blanco puro (usando addColor.glsl del proyecto)
local addColorShader = nil
-- Valores de tinte de personajes durante el rayo (hex en LÖVE 0..1)
local CHAR_DARK_R, CHAR_DARK_G, CHAR_DARK_B = 0x60/255, 0x60/255, 0x60/255
local CHAR_NORM_R, CHAR_NORM_G, CHAR_NORM_B = 0xDE/255, 0xDE/255, 0xDE/255
-- Tween de flash de pantalla (blanco puro vía addColor)
local lightningFlash = {alpha = 0, active = false, elapsed = 0, duration = 0}
-- Tween de fade del cielo durante el rayo
local lightningFade  = {alpha = 0, active = false, elapsed = 0, duration = 0}
-- Tween de personajes (vuelven a color normal)
local charColorTween = {active = false, elapsed = 0, duration = 0,
	bfR=CHAR_NORM_R, bfG=CHAR_NORM_G, bfB=CHAR_NORM_B,
	dadR=CHAR_NORM_R, dadG=CHAR_NORM_G, dadB=CHAR_NORM_B}

local lightningSprite = nil     -- referencia al sprite del rayo
-- =====================================================================
-- darkenStageProps: flash oscuro al disparar (portado de PhillyStreets.hx)
-- En el original: sprite.color = 0xFF111111 instantáneo, luego tras 1 frame
-- pasa a 0xFF222222 y hace FlxTween.color a 0xFFFFFFFF en 1.4s.
-- Aquí: cada layer darkenable recibe un tinte (colorR/G/B) que se interpola.
-- Los personajes (Pico, Darnell, Nene, Abot) NO se oscurecen.
-- =====================================================================
local darkenTint = 1.0  -- 1.0 = blanco normal, 0x11/0xFF ≈ 0.067 = casi negro
local darkenFade = { active = false, elapsed = 0, duration = 1.4, phase = 0 }
-- phase 0 = inactivo, 1 = frame inicial (0x11), 2 = tweening (0x22 → 0xFF)

local function triggerDarkenStage()
	darkenTint = 0x11 / 0xFF  -- ≈ 0.067, casi negro
	darkenFade.active = true
	darkenFade.elapsed = 0
	darkenFade.phase = 1  -- primer frame: 0x111111
end

-- =====================================================================
-- Blazin: shaders para oscurecer/difuminar personajes de fondo (Nene, Abot)
-- En el FNF original, PhillyBlazin usa AdjustColor (brightness -60) +
-- un GaussianBlur leve para que Nene y Abot se vean "en el fondo".
-- =====================================================================
local blazinDarkenShader = nil
local blazinBlurShader = nil

-- =====================================================================
-- Utilidades de tweening para paths cuadráticos y ángulos
-- =====================================================================

-- Interpolación cuadrática (Bezier de 3 puntos)
local function quadBezier(t, p0x, p0y, p1x, p1y, p2x, p2y)
	local u = 1 - t
	local x = u*u*p0x + 2*u*t*p1x + t*t*p2x
	local y = u*u*p0y + 2*u*t*p1y + t*t*p2y
	return x, y
end

-- Easing functions (portadas de HaxeFlixel)
local function easeLinear(t) return t end
local function easeSineIn(t) return -math.cos(t * math.pi / 2) + 1 end
local function easeCubeOut(t)
	local t2 = t - 1
	return t2*t2*t2 + 1
end

-- Estructura de tween activo
local function createPathTween(sprite, p0x, p0y, p1x, p1y, p2x, p2y, duration, easeFn, onComplete)
	return {
		sprite = sprite,
		p0x = p0x, p0y = p0y,
		p1x = p1x, p1y = p1y,
		p2x = p2x, p2y = p2y,
		duration = duration,
		elapsed = 0,
		easeFn = easeFn or easeLinear,
		onComplete = onComplete,
		active = true
	}
end

local function createAngleTween(sprite, startAngle, endAngle, duration, easeFn, startDelay)
	return {
		sprite = sprite,
		startAngle = startAngle,
		endAngle = endAngle,
		duration = duration,
		elapsed = 0,
		startDelay = startDelay or 0,
		delayElapsed = 0,
		easeFn = easeFn or easeLinear,
		active = true
	}
end

local function updatePathTween(tw, dt)
	if not tw or not tw.active then return end
	tw.elapsed = tw.elapsed + dt
	local t = math.min(tw.elapsed / tw.duration, 1)
	local et = tw.easeFn(t)
	local x, y = quadBezier(et, tw.p0x, tw.p0y, tw.p1x, tw.p1y, tw.p2x, tw.p2y)
	tw.sprite.x = x
	tw.sprite.y = y
	if t >= 1 then
		tw.active = false
		if tw.onComplete then tw.onComplete() end
	end
end

local function updateAngleTween(tw, dt)
	if not tw or not tw.active then return end
	if tw.startDelay > 0 then
		tw.delayElapsed = tw.delayElapsed + dt
		if tw.delayElapsed < tw.startDelay then return end
		dt = tw.delayElapsed - tw.startDelay
		tw.startDelay = 0
	end
	tw.elapsed = tw.elapsed + dt
	local t = math.min(tw.elapsed / tw.duration, 1)
	local et = tw.easeFn(t)
	tw.sprite.angle = tw.startAngle + (tw.endAngle - tw.startAngle) * et
	if t >= 1 then
		tw.active = false
	end
end

-- =====================================================================
-- Funciones del sistema de vehículos (portado de PhillyStreets.hx)
-- Coordenadas convertidas: las posiciones Haxe son relativas al
-- origen del carro Haxe (1200, 818). Se aplican como deltas sobre
-- la posición base del layer en el engine Lua.
-- =====================================================================

-- Posición base del carro en Haxe (donde se coloca antes de moverse)
local HAXE_CAR_BASE_X = 1200
local HAXE_CAR_BASE_Y = 818

-- Convierte un punto absoluto Haxe a coordenadas del engine Lua
-- relativas a la posición base del carro en el layer
local function haxeToLua(hx, hy, baseLayerX, baseLayerY)
	local lx = baseLayerX + (hx - HAXE_CAR_BASE_X)
	local ly = baseLayerY + (hy - HAXE_CAR_BASE_Y)
	return lx, ly
end

local function cancelCarTweens()
	if carTween then carTween.active = false end
	if carAngleTween then carAngleTween.active = false end
	carTween = nil
	carAngleTween = nil
end

local function cancelCar2Tweens()
	if car2Tween then car2Tween.active = false end
	if car2AngleTween then car2AngleTween.active = false end
	car2Tween = nil
	car2AngleTween = nil
end

-- finishCarLights: cuando la luz cambia a verde, el carro que esperaba sale
local function finishCarLights(sprite)
	carWaiting = false
	local duration = 1.8 + love.math.random() * 1.2
	local startdelay = 0.2 + love.math.random() * 1.0
	local rotStart, rotEnd = -5, 18
	local offX, offY = 306.6, 168.3

	local bx = phillyCarsLayer and phillyCarsLayer.x or 436.67
	local by = phillyCarsLayer and phillyCarsLayer.y or -43.33

	local p0x, p0y = haxeToLua(1950 - offX - 80, 980 - offY + 15, bx, by)
	local p1x, p1y = haxeToLua(2400 - offX, 980 - offY - 50, bx, by)
	local p2x, p2y = haxeToLua(3102 - offX, 1127 - offY + 40, bx, by)

	cancelCarTweens()
	carAngleTween = createAngleTween(sprite, rotStart, rotEnd, duration, easeSineIn, startdelay)
	carTween = createPathTween(sprite, p0x, p0y, p1x, p1y, p2x, p2y, duration, easeSineIn, function()
		carInterruptable = true
		sprite.visible = false
	end)
	carTween.startDelay = startdelay
	carTween.delayElapsed = 0
end

-- driveCarLights: carro se acerca y se detiene en el semáforo rojo
local function driveCarLights(sprite)
	carInterruptable = false
	cancelCarTweens()
	sprite.visible = true

	local variant = love.math.random(1, 4)
	if sprite.animate then
		sprite:animate("car" .. variant, false)
	end

	local extraOffX, extraOffY = 0, 0
	local duration = 2

	if variant == 1 then
		duration = 1 + love.math.random() * 0.7
	elseif variant == 2 then
		extraOffX, extraOffY = 20, -15
		duration = 0.9 + love.math.random() * 0.6
	elseif variant == 3 then
		extraOffX, extraOffY = 30, 50
		duration = 1.5 + love.math.random() * 1.0
	elseif variant == 4 then
		extraOffX, extraOffY = 10, 60
		duration = 1.5 + love.math.random() * 1.0
	end

	local rotStart, rotEnd = -7, -5
	local offX, offY = 306.6, 168.3
	sprite.extraOffX = extraOffX
	sprite.extraOffY = extraOffY

	local bx = phillyCarsLayer and phillyCarsLayer.x or 436.67
	local by = phillyCarsLayer and phillyCarsLayer.y or -43.33

	local p0x, p0y = haxeToLua(1500 - offX - 20, 1049 - offY - 20, bx, by)
	local p1x, p1y = haxeToLua(1770 - offX - 80, 994 - offY + 10, bx, by)
	local p2x, p2y = haxeToLua(1950 - offX - 80, 980 - offY + 15, bx, by)

	carAngleTween = createAngleTween(sprite, rotStart, rotEnd, duration, easeCubeOut)
	carTween = createPathTween(sprite, p0x, p0y, p1x, p1y, p2x, p2y, duration, easeCubeOut, function()
		carWaiting = true
		if lightsStop == false then
			finishCarLights(phillyCars)
		end
	end)
end

-- driveCar: carro pasa de largo (luz verde)
local function driveCar(sprite)
	carInterruptable = false
	cancelCarTweens()
	sprite.visible = true

	local variant = love.math.random(1, 4)
	if sprite.animate then
		sprite:animate("car" .. variant, false)
	end

	local extraOffX, extraOffY = 0, 0
	local duration = 2

	if variant == 1 then
		duration = 1 + love.math.random() * 0.7
	elseif variant == 2 then
		extraOffX, extraOffY = 20, -15
		duration = 0.6 + love.math.random() * 0.6
	elseif variant == 3 then
		extraOffX, extraOffY = 30, 50
		duration = 1.5 + love.math.random() * 1.0
	elseif variant == 4 then
		extraOffX, extraOffY = 10, 60
		duration = 1.5 + love.math.random() * 1.0
	end

	local offX, offY = 306.6, 168.3
	sprite.extraOffX = extraOffX
	sprite.extraOffY = extraOffY

	local bx = phillyCarsLayer and phillyCarsLayer.x or 436.67
	local by = phillyCarsLayer and phillyCarsLayer.y or -43.33

	local rotStart, rotEnd = -8, 18
	local p0x, p0y = haxeToLua(1570 - offX, 1049 - offY - 30, bx, by)
	local p1x, p1y = haxeToLua(2400 - offX, 980 - offY - 50, bx, by)
	local p2x, p2y = haxeToLua(3102 - offX, 1127 - offY + 40, bx, by)

	carAngleTween = createAngleTween(sprite, rotStart, rotEnd, duration, easeLinear)
	carTween = createPathTween(sprite, p0x, p0y, p1x, p1y, p2x, p2y, duration, easeLinear, function()
		carInterruptable = true
		sprite.visible = false
	end)
end

-- driveCarBack: carro 2 va en la dirección opuesta (flipX)
local function driveCarBack(sprite)
	car2Interruptable = false
	cancelCar2Tweens()
	sprite.visible = true

	local variant = love.math.random(1, 4)
	if sprite.animate then
		sprite:animate("car" .. variant, false)
	end

	local extraOffX, extraOffY = 0, 0
	local duration = 2

	if variant == 1 then
		duration = 1 + love.math.random() * 0.7
	elseif variant == 2 then
		extraOffX, extraOffY = 20, -15
		duration = 0.6 + love.math.random() * 0.6
	elseif variant == 3 then
		extraOffX, extraOffY = 30, 50
		duration = 1.5 + love.math.random() * 1.0
	elseif variant == 4 then
		extraOffX, extraOffY = 10, 60
		duration = 1.5 + love.math.random() * 1.0
	end

	local offX, offY = 306.6, 168.3
	sprite.extraOffX = extraOffX
	sprite.extraOffY = extraOffY

	local bx = phillyCarsLayer and phillyCarsLayer.x or -14.89
	local by = phillyCarsLayer and phillyCarsLayer.y or -29.33
	local bx = phillyCarsLayer and phillyCarsLayer.x or 436.67
	local by = phillyCarsLayer and phillyCarsLayer.y or -43.33

	local rotStart, rotEnd = 18, -8
	local p0x, p0y = haxeToLua(3102 - offX, 1127 - offY + 60, bx, by)
	local p1x, p1y = haxeToLua(2400 - offX, 980 - offY - 30, bx, by)
	local p2x, p2y = haxeToLua(1570 - offX, 1049 - offY - 10, bx, by)

	car2AngleTween = createAngleTween(sprite, rotStart, rotEnd, duration, easeLinear)
	car2Tween = createPathTween(sprite, p0x, p0y, p1x, p1y, p2x, p2y, duration, easeLinear, function()
		car2Interruptable = true
		sprite.visible = false
	end)
end

-- changeLights: alterna el semáforo entre rojo y verde
-- lightsStop = true  → luz ROJA  (carros se detienen, driveCarLights)
-- lightsStop = false → luz VERDE (carros pasan, driveCar)
local function changeLights(beat)
	lastLightChange = beat
	lightsStop = not lightsStop

	if phillyTraffic then
		if lightsStop then
			-- Luz ROJA: en este spritesheet "redtogreen" es visualmente el estado rojo
			phillyTraffic:animate("redtogreen", false)
			phillyTraffic:animate("greentored", false)
			changeInterval = 20
		else
			-- Luz VERDE: "greentored" es visualmente el estado verde
			phillyTraffic:animate("greentored", false)
			phillyTraffic:animate("redtogreen", false)
			changeInterval = 30
			-- El carro que estaba esperando ahora puede salir
			if carWaiting == true and phillyCars then
				finishCarLights(phillyCars)
			end
		end
	end
end

-- beatHitTraffic: llamada cada beat para manejar carros y semáforo
local function beatHitTraffic(beat)
	-- 10% de probabilidad de que aparezca un carro hacia adelante
	if love.math.random() < 0.10 and beat ~= (lastLightChange + changeInterval) and carInterruptable == true then
		if phillyCars then
			if lightsStop == false then
				-- Luz VERDE: el carro pasa de largo sin frenar
				driveCar(phillyCars)
			else
				-- Luz ROJA: el carro se acerca y se detiene a esperar
				driveCarLights(phillyCars)
			end
		end
	end

	-- 10% de probabilidad de que aparezca carro 2 hacia atrás (solo si luz verde)
	if love.math.random() < 0.10 and beat ~= (lastLightChange + changeInterval) and car2Interruptable == true and lightsStop == false then
		if phillyCars2 then
			driveCarBack(phillyCars2)
		end
	end

	-- Cambiar luces cuando toca
	if beat == (lastLightChange + changeInterval) then
		changeLights(beat)
	end
end

-- Mapeo de nombres de easing de FNF V-Slice / Psych Engine a hump.timer
local fnfEaseMap = {
	["elasticInOut"] = "in-out-elastic",
	["elasticIn"]    = "in-elastic",
	["elasticOut"]   = "out-elastic",
	["quadInOut"]    = "in-out-quad",
	["quadIn"]       = "in-quad",
	["quadOut"]      = "out-quad",
	["cubicInOut"]   = "in-out-cubic",
	["cubicIn"]      = "in-cubic",
	["cubicOut"]     = "out-cubic",
	["sineInOut"]    = "in-out-sine",
	["sineIn"]       = "in-sine",
	["sineOut"]      = "out-sine",
	["expoInOut"]    = "in-out-expo",
	["expoIn"]       = "in-expo",
	["expoOut"]      = "out-expo",
	["CLASSIC"]      = "out-quad",
	["linear"]       = "linear",
}

local function getFnfEase(easeName)
	if not easeName then return "out-quad" end
	return fnfEaseMap[easeName] or "out-quad"
end

-- =====================================================================
-- applyLightning: dispara el efecto visual y sonoro del rayo
-- Portado de PhillyBlazin.hx → applyLightning()
-- =====================================================================
local function applyLightning()
	-- Sonido del trueno (aleatorio entre los 3 disponibles)
	if #lightningSounds > 0 then
		local snd = lightningSounds[love.math.random(1, #lightningSounds)]
		if snd then snd:stop(); snd:play() end
	end

	-- Sprite del rayo: posición fija según stage (65% izquierda, 35% derecha)
	if lightningSprite and lightningLayer then
		lightningSprite.visible = true
		if love.math.random() < 0.65 then
			-- Posición izquierda (coincide con stage)
			lightningLayer.x = -458
			lightningLayer.y = -300
		else
			-- Posición derecha
			lightningLayer.x = 131
			lightningLayer.y = -300
		end
		if lightningSprite.anims and lightningSprite.anims["lightning"] then
			lightningSprite:animate("lightning", false)
		end
	end

	-- Flash blanco puro: usa addColor.glsl (suma 1,1,1 sobre toda la escena = blanco)
	-- Muy rápido (LIGHTNING_FLASH_DURATION = 0.08s, aprox 2 frames)
	lightningFlash = {alpha = 1.0, active = true, elapsed = 0, duration = LIGHTNING_FLASH_DURATION}

	-- Fade del cielo (skyAdditive del original: tinte azulado que desaparece lento)
	lightningFade  = {alpha = 0.7, active = true, elapsed = 0, duration = LIGHTNING_FULL_DURATION}

	-- Oscurecer personajes instantáneamente y luego volver al color normal
	if boyfriend and boyfriend.colorR ~= nil then
		boyfriend.colorR = CHAR_DARK_R
		boyfriend.colorG = CHAR_DARK_G
		boyfriend.colorB = CHAR_DARK_B
	end
	if enemy and enemy.colorR ~= nil then
		enemy.colorR = CHAR_DARK_R
		enemy.colorG = CHAR_DARK_G
		enemy.colorB = CHAR_DARK_B
	end
	charColorTween = {
		active   = true,
		elapsed  = 0,
		duration = LIGHTNING_FLASH_DURATION,  -- igual que el flash: rápido
	}
end

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	loadStage = function(self, songNum, songAppend)
		song = songNum
		difficulty = songAppend

		-- Determinar qué stage cargar
		local stageFile
		if song == 4 then
			stageFile = "stages/blazin.lua"
			isBlazinSong = true
		else
			stageFile = "stages/philly.lua"
			isBlazinSong = false
		end

		-- Cargar el stage
		local chunk, err = love.filesystem.load(stageFile)
		if not chunk then
			print("Error al cargar el stage:", err)
			stageLayers = {}
		else
			local ok, loaded = pcall(chunk)
			if ok and loaded then
				stageData = loaded
				stageLayers = {}
				backgroundSprites = {}
				for _, layerData in ipairs(stageData.layers) do
					local layer = {
						type = layerData.type,
						path = layerData.path,
						x = layerData.x,
						y = layerData.y,
						scrollX = layerData.scrollX or 1,
						scrollY = layerData.scrollY or 1,
						scaleX = layerData.scaleX or 1,
						scaleY = layerData.scaleY or 1,
						visible = layerData.visible,
						blend = layerData.blend,   -- "add", "multiply", etc. (nil = normal)
						alpha = layerData.alpha,   -- nil = 1.0
						darkenable = true,         -- se desactiva para personajes/abot/rayo
						obj = nil
					}
					if layer.type == "image" then
						-- Si el path empieza con "png/", quitar ese prefijo
						-- para que graphics.imagePath lo maneje normalmente
						-- (igual que en todos los demás stages)
						local cleanPath = layer.path
						if cleanPath:sub(1, 4) == "png/" then
							cleanPath = cleanPath:sub(5)
						end
						local imgPath = graphics.imagePath(cleanPath)
						if love.filesystem.getInfo(imgPath) then
							layer.obj = graphics.newImage(love.graphics.newImage(imgPath))
						else
							print("Imagen no encontrada:", imgPath)
						end
					elseif layer.type == "sprite" then
						local ok2, sprite = pcall(love.filesystem.load, "sprites/" .. layer.path .. ".lua")
						if ok2 then
							local ok3, spriteObj = pcall(sprite)
							if ok3 then
								layer.obj = spriteObj
								if layer.obj.anims then
									-- Preferir "idle"; si no existe, usar la primera disponible
									local animName = layer.obj.anims["idle"] and "idle" or next(layer.obj.anims)
									if animName then layer.obj:animate(animName, false) end
								end
							end
						end
					end
					table.insert(stageLayers, layer)

					-- Asignar personajes según la ruta
					if layer.path == "weekend1/darnell" and layer.obj then
						enemy = layer.obj
						enemy.x, enemy.y = layer.x, layer.y
						enemy.sizeX = layer.scaleX * (enemy.sizeX or 1)
						enemy.sizeY = layer.scaleY * (enemy.sizeY or 1)
						layer.darkenable = false
					elseif layer.path == "weekend1/Darnell Fighting Animations V2" and layer.obj then
						enemy = layer.obj
						enemy.x, enemy.y = layer.x, layer.y
						enemy.sizeX = layer.scaleX * (enemy.sizeX or 1)
						enemy.sizeY = layer.scaleY * (enemy.sizeY or 1)
						blazinEnemyLayer = layer
						layer.darkenable = false
					elseif layer.path == "weekend1/Pico_FNF_assetss" and layer.obj then
						boyfriend = layer.obj
						boyfriend.x, boyfriend.y = layer.x, layer.y
						boyfriend.sizeX = layer.scaleX * (boyfriend.sizeX or 1)
						boyfriend.sizeY = layer.scaleY * (boyfriend.sizeY or 1)
						layer.darkenable = false
					elseif layer.path == "weekend1/Pico Fighting Animations V2" and layer.obj then
						boyfriend = layer.obj
						boyfriend.x, boyfriend.y = layer.x, layer.y
						boyfriend.sizeX = layer.scaleX * (boyfriend.sizeX or 1)
						boyfriend.sizeY = layer.scaleY * (boyfriend.sizeY or 1)
						blazinBfLayer = layer
						layer.darkenable = false
					elseif layer.path == "weekend1/Nene" and layer.obj then
						girlfriend = layer.obj
						girlfriend.x, girlfriend.y = layer.x, layer.y
						girlfriend.sizeX = layer.scaleX * (girlfriend.sizeX or 1)
						girlfriend.sizeY = layer.scaleY * (girlfriend.sizeY or 1)
						layer.darkenable = false
					elseif layer.path == "weekend1/AbotSystem" and layer.obj then
						abotSystem = layer.obj
						abotSystem.sizeX = layer.scaleX * (abotSystem.sizeX or 1)
						abotSystem.sizeY = layer.scaleY * (abotSystem.sizeY or 1)
						layer.darkenable = false
					elseif layer.path == "weekend1/AbotAis" and layer.obj then
						abotAis = layer.obj
						abotAis.sizeX = layer.scaleX * (abotAis.sizeX or 1)
						abotAis.sizeY = layer.scaleY * (abotAis.sizeY or 1)
						-- Los ojos NO deben hacer loop automático.
						-- Se quedan quietos en el primer frame de "player" hasta que
						-- un evento FocusCamera dispare el cambio.
						abotAis:animate("player", false)
						lastCamFocus = "player"
						layer.darkenable = false
					elseif layer.path == "weekend1/phillyCars" and layer.obj then
						phillyCars = layer.obj
						phillyCars.angle = 0
						phillyCars.extraOffX = 0
						phillyCars.extraOffY = 0
						phillyCars.visible = false  -- oculto hasta que un tween lo mueva
						phillyCarsLayer = layer
					elseif layer.path == "weekend1/phillyCars2" and layer.obj then
						phillyCars2 = layer.obj
						phillyCars2.angle = 0
						phillyCars2.extraOffX = 0
						phillyCars2.extraOffY = 0
						phillyCars2.flipX = true
						phillyCars2.visible = false
						phillyCars2Layer = layer
					elseif layer.path == "weekend1/phillyTraffic" and layer.obj then
						phillyTraffic = layer.obj
						-- lightsStop inicia false (verde); spritesheet invertido: "greentored" = visual verde
						phillyTraffic:animate("greentored", false)
						phillyTraffic:animate("redtogreen", false)
						phillyTrafficLayer = layer
					elseif layer.path == "weekend1/lightning" and layer.obj then
						-- El sprite del rayo viene del stage (blazin.lua), capturarlo aquí
						lightningSprite = layer.obj
						lightningLayer  = layer
						lightningSprite.visible = false  -- oculto hasta que caiga un rayo
					end

					-- Capturar posición de nastyObject3 para enfocar cámara en lugar de Nene
					if layer.path == "png/nastyObject3" or layer.path == "nastyObject3" then
						nastyObject3Pos = {x = layerData.x, y = layerData.y}
					end

					-- Capturar posición de nastyObject para enfocar cámara en lugar de Pico
					if layer.path == "png/nastyObject" or layer.path == "nastyObject" then
						nastyObjectPos = {x = layerData.x, y = layerData.y}
					end

					-- Agregar sprites de fondo (excluyendo personajes, Abot, carros, semáforo y rayo)
					if layer.type == "sprite" and layer.obj
						and layer.obj ~= enemy
						and layer.obj ~= boyfriend
						and layer.obj ~= girlfriend
						and layer.obj ~= abotSystem
						and layer.obj ~= abotAis
						and layer.obj ~= phillyCars
						and layer.obj ~= phillyCars2
						and layer.obj ~= phillyTraffic
						and layer.obj ~= lightningSprite
					then
						local animName = layer.obj.anims["idle"] and "idle" or next(layer.obj.anims)
						if animName then
							local anim = layer.obj.anims[animName]
							local frameCount = anim.stop - anim.start + 1
							table.insert(backgroundSprites, {
								sprite = layer.obj,
								animName = animName,
								frameCount = frameCount
							})
							layer.obj:animate(animName, false)
						end
					end
				end

				-- Aplicar escala a sprites de fondo (no personajes, no carros/semáforo, no rayo)
				for _, layer in ipairs(stageLayers) do
					if layer.type == "sprite" and layer.obj then
						local isCharacter = layer.obj == enemy or layer.obj == boyfriend or layer.obj == girlfriend
						or layer.obj == abotSystem or layer.obj == abotAis
						or layer.obj == phillyCars or layer.obj == phillyCars2 or layer.obj == phillyTraffic
						or layer.obj == lightningSprite
						if not isCharacter then
							layer.obj.sizeX = layer.scaleX * (layer.obj.sizeX or 1)
							layer.obj.sizeY = layer.scaleY * (layer.obj.sizeY or 1)
						end
					end
				end
			else
				print("Error al ejecutar el stage:", loaded)
			end
		end

		-- Fallbacks si no se cargaron los personajes
		if not enemy then
			enemy = love.filesystem.load("sprites/weekend1/darnell.lua")()
			enemy.x, enemy.y = -380, 100
		end
		if not boyfriend then
			boyfriend = love.filesystem.load("sprites/weekend1/Pico_FNF_assetss.lua")()
			boyfriend.x, boyfriend.y = 260, 100
		end
		if not girlfriend then
			girlfriend = love.filesystem.load("sprites/weekend1/Nene.lua")()
			girlfriend.x, girlfriend.y = -23, -288
		end

		enemyIcon:animate("darnell", false)
		boyfriendIcon:animate("pico", false)

		-- =================================================================
		-- Inicializar sistema de semáforo y vehículos
		-- phillyCars, phillyCars2 y phillyTraffic ya fueron capturados desde stageLayers
		-- Solo necesitamos crear phillyCars2 (carro que va en reversa)
		-- =================================================================
		if phillyCars then
			phillyCars.angle = 0
			phillyCars.extraOffX = 0
			phillyCars.extraOffY = 0
			phillyCars.visible = false  -- oculto hasta que un tween lo active

			-- Crear segundo carro como sprite independiente
			local carsPath = "sprites/weekend1/phillyCars.lua"
			if love.filesystem.getInfo(carsPath) then
				local ok2, carSprite2 = pcall(love.filesystem.load(carsPath))
				if ok2 and carSprite2 then
					phillyCars2 = carSprite2
					phillyCars2.angle = 0
					phillyCars2.extraOffX = 0
					phillyCars2.extraOffY = 0
					phillyCars2.flipX = true
					phillyCars2.visible = false
				end
			end
		end

		-- Resetear estado del semáforo y carros
		lightsStop = false
		lastLightChange = 0
		changeInterval = 8
		carWaiting = false
		carInterruptable = true
		car2Interruptable = true
		curBeat = 0
		lastBeatTimeTraffic = 0
		cancelCarTweens()
		cancelCar2Tweens()

		-- Variables para cutscenes de video
		self.cutscene = nil
		self.cutscenePlaying = false
		self.cutsceneStartTime = 0
		self.cutsceneDuration = 0
		self.pendingBlazinEnd = false  -- Para la cutscene al terminar blazin

		-- Alejar la cámara para ver más del stage
		cam.sizeX = 0.85
		cam.sizeY = 0.85
		-- Inicializar zoom base para Weekend 1 (coordina con camScale de weeks)
		camScale.x = 0.85
		camScale.y = 0.85
		_G.disableAutoCam = false

		-- =====================================================================
		-- Pico Shoot: cargar sonidos y registrar hooks de notas custom
		-- =====================================================================
		self.picoShootSounds = {
			gunPrep = love.audio.newSource("sounds/weekend1/Gun_Prep.ogg", "static"),
			shots = {
				love.audio.newSource("sounds/weekend1/shot1.ogg", "static"),
				love.audio.newSource("sounds/weekend1/shot2.ogg", "static"),
				love.audio.newSource("sounds/weekend1/shot3.ogg", "static"),
				love.audio.newSource("sounds/weekend1/shot4.ogg", "static"),
			}
		}

		-- =====================================================================
		-- Blazin: cargar sonidos de tormenta y rayo
		-- Solo se cargan cuando la canción es blazin (song == 4)
		-- =====================================================================
		if isBlazinSong then
			-- Truenos (Lightning1.ogg … Lightning3.ogg)
			lightningSounds = {}
			for i = 1, 3 do
				local p = "sounds/weekend1/Lightning" .. i .. ".ogg"
				if love.filesystem.getInfo(p) then
					lightningSounds[i] = love.audio.newSource(p, "static")
				end
			end
		-- Registrar este week como currentWeek para que weeks.lua llame a nuestros hooks
		_G.currentWeek = self

			-- El sprite del rayo ya fue capturado desde stageLayers (path "weekend1/lightning").
			-- lightningSprite y lightningLayer se asignaron arriba en el loop de stageLayers.
			-- Solo nos aseguramos de que esté oculto al iniciar.
			if lightningSprite then
				lightningSprite.visible = false
			end

			-- Shader addColor para flash blanco puro (addColor.glsl suma R+G+B sobre toda la escena)
			addColorShader = nil
			local acPath = "shaders/addColor.glsl"
			if love.filesystem.getInfo(acPath) then
				local ok2, s = pcall(love.graphics.newShader, acPath)
				if ok2 and s then
					addColorShader = s
					-- Pre-enviar valores neutros
					addColorShader:send("colorAlpha", 0.0)
					addColorShader:send("colorRed",   0.0)
					addColorShader:send("colorGreen", 0.0)
					addColorShader:send("colorBlue",  0.0)
				else
					print("addColor shader error:", s)
				end
			end

			-- Resetear timer y tweens del rayo
			lightningTimer = 3.0
			lightningFlash = {alpha = 0, active = false, elapsed = 0, duration = 0}
			lightningFade  = {alpha = 0, active = false, elapsed = 0, duration = 0}
			charColorTween = {active = false, elapsed = 0, duration = 0,
				bfR=CHAR_NORM_R, bfG=CHAR_NORM_G, bfB=CHAR_NORM_B,
				dadR=CHAR_NORM_R, dadG=CHAR_NORM_G, dadB=CHAR_NORM_B}
		else
			-- Limpiar sonidos de tormenta si no es blazin
			lightningSounds = {}
			if lightningSprite then
				lightningSprite = nil
				lightningLayer = nil
			end
			addColorShader = nil
		end

		-- Registrar hooks para que weeks.lua llame a nuestros hooks de notas custom
		if isBlazinSong then
			-- Blazin: el sistema de pelea maneja las notas
			blazinFight.init(self)
			-- blazinFight se registra como _G.currentWeek internamente
			-- Activar middle scroll para Blazin (solo flechas del jugador, centradas)
			weeks:setMiddleScroll(true)
		else
			_G.currentWeek = self
			weeks:setMiddleScroll(false)
		end

		-- =====================================================================
		-- Rain Shader: cargar y configurar (como en PhillyStreets.hx)
		-- Se aplica a toda la escena EXCEPTO la GUI, igual que el original.
		-- =====================================================================
		rainTime = 0
		rainShader = nil
		rainCanvas = nil

		local shaderPath = "shaders/rain.glsl"
		if love.filesystem.getInfo(shaderPath) then
			local ok, shader = pcall(love.graphics.newShader, shaderPath)
			if ok and shader then
				rainShader = shader
				-- uScale = FlxG.height / 200 en el original
				local screenH = love.graphics.getHeight()
				rainShader:send("uScale", screenH / 200)
				rainShader:send("uTime", 0)
				rainShader:send("uIntensity", 0)
			else
				print("Rain shader compilation error:", shader)
			end
		else
			print("Rain shader not found at:", shaderPath)
		end

		-- Canvas para renderizar la escena del juego (sin GUI)
		-- El shader se aplica al dibujar este canvas a pantalla
		local cw, ch = love.graphics.getDimensions()
		rainCanvas = love.graphics.newCanvas(cw, ch)

		-- =====================================================================
		-- Blazin: cargar shaders para oscurecer/difuminar Nene y Abot
		-- =====================================================================
		blazinDarkenShader = nil
		blazinBlurShader = nil

		local darkenPath = "shaders/adjustColor.glsl"
		if love.filesystem.getInfo(darkenPath) then
			local ok, s = pcall(love.graphics.newShader, darkenPath)
			if ok and s then
				blazinDarkenShader = s
				-- Oscurecer: brightness negativo (-60 como en el original)
				blazinDarkenShader:send("brightness", -60.0)
				blazinDarkenShader:send("hue", 0.0)
				blazinDarkenShader:send("saturation", -20.0)
				blazinDarkenShader:send("contrast", -20.0)
			else
				print("adjustColor shader error:", s)
			end
		end

		local blurPath = "shaders/gaussianBlur.glsl"
		if love.filesystem.getInfo(blurPath) then
			local ok, s = pcall(love.graphics.newShader, blurPath)
			if ok and s then
				blazinBlurShader = s
				blazinBlurShader:send("_amount", 1.5)
			else
				print("gaussianBlur shader error:", s)
			end
		end

		self:load()
	end,

	-- =====================================================================
	-- Hook: customNoteHit — maneja notas picoShoot al ser golpeadas
	-- Retorna true si se manejó la nota (weeks.lua no ejecuta la animación default)
	-- =====================================================================
	customNoteHit = function(self, curAnim, note, bfSprite)
		-- Blazin fight notes (tienen noteKind)
		if note.noteKind then
			return blazinFight.customNoteHit(self, curAnim, note, bfSprite)
		end

		-- PicoShoot notes (canciones 1-3)
		if note.altNote ~= "picoShoot" then return false end

		-- Pico Shoot Down → Gun_Prep.ogg + animación "down alt" (reload)
		if curAnim == "down" then
			if self.picoShootSounds and self.picoShootSounds.gunPrep then
				self.picoShootSounds.gunPrep:stop()
				self.picoShootSounds.gunPrep:play()
			end
			bfSprite:animate("down alt", false)
			return true
		end

		-- Pico Shoot Left → shot aleatorio + animación "left alt" (shoot)
		if curAnim == "left" then
			if self.picoShootSounds and self.picoShootSounds.shots then
				local snd = self.picoShootSounds.shots[love.math.random(1, 4)]
				snd:stop()
				snd:play()
			end
			bfSprite:animate("left alt", false)
			-- Oscurecer escena 1 frame después del disparo (igual que el original)
			self.darkenTimer = 1/24
			return true
		end

		-- Las demás direcciones de picoShoot se comportan como alt normales
		bfSprite:animate(curAnim .. " alt", false)
		return true
	end,

	-- =====================================================================
	-- Hook: customNoteMiss — maneja miss en notas picoShoot
	-- Retorna true si se manejó el miss (weeks.lua no ejecuta la animación default)
	-- =====================================================================
	customNoteMiss = function(self, curAnim, note, bfSprite)
		-- Blazin fight notes
		if note.noteKind then
			return blazinFight.customNoteMiss(self, curAnim, note, bfSprite)
		end

		-- PicoShoot notes
		if note.altNote ~= "picoShoot" then return false end

		-- Pico Shoot Left miss → animación "Pico Hit Can" + 3x daño extra
		-- (weeks.lua ya aplicó -2 de salud base, sumamos -4 extra para un total de -6 = 3x)
		if curAnim == "left" then
			bfSprite:animate("Pico Hit Can", false)
			health = health - 4  -- extra: base ya puso -2, total = -6 (3x el normal de -2)
			return true
		end

		-- Las demás direcciones: miss regular (return false deja que weeks.lua lo maneje)
		return false
	end,

	load = function(self)
		weeks:load()

		-- Resetear cámara para cada canción
		_G.disableAutoCam = false
		if isBlazinSong then
			-- Blazin: cámara más cercana para ver la pelea
			camScale.x = 1.25
			camScale.y = 1.25
		else
			camScale.x = 0.85
			camScale.y = 0.85
		end
		lastBeatTime = 0
		lastCamFocus = nil

		-- Limpiar timers de eventos anteriores
		if self.focusTimer then Timer.cancel(self.focusTimer); self.focusTimer = nil end
		if self.zoomTimer then Timer.cancel(self.zoomTimer); self.zoomTimer = nil end

		if song == 4 then
			inst = love.audio.newSource("music/weekend1/blazin-inst.ogg", "stream")
			voices = love.audio.newSource("music/weekend1/blazin-voices.ogg", "stream")
		elseif song == 3 then
			inst = love.audio.newSource("music/weekend1/2hot-inst.ogg", "stream")
			voices = love.audio.newSource("music/weekend1/2hot-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/weekend1/lit-up-inst.ogg", "stream")
			voices = love.audio.newSource("music/weekend1/lit-up-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/weekend1/darnell-inst.ogg", "stream")
			voices = love.audio.newSource("music/weekend1/darnell-voices.ogg", "stream")
		end

		self:initUI()

		-- =====================================================================
		-- Rain Shader: intensidad progresiva por canción (como en PhillyStreets.hx)
		-- Darnell: 0 → 0.1 | Lit Up: 0.1 → 0.2 | 2hot: 0.2 → 0.4 | Blazin: 0.4 → 0.7
		-- =====================================================================
		rainTime = 0
		if song == 1 then       -- Darnell
			rainShaderStartIntensity = 0
			rainShaderEndIntensity = 0.1
		elseif song == 2 then   -- Lit Up
			rainShaderStartIntensity = 0.1
			rainShaderEndIntensity = 0.2
		elseif song == 3 then   -- 2hot
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
		elseif song == 4 then   -- Blazin
			rainShaderStartIntensity = 0.4
			rainShaderEndIntensity = 0.7
		end
		if rainShader then
			rainShader:send("uIntensity", rainShaderStartIntensity)
		end

		-- Determinar si hay cutscene antes de esta canción
		local cutsceneFile = nil
		local cutsceneDur = 30
		if song == 1 then
			cutsceneFile = "videos/darnellCutscene.ogv"
			cutsceneDur = 86   -- 1:26
		elseif song == 4 then
			cutsceneFile = "videos/2hotCutscene.ogv"
			cutsceneDur = 28
		end

		if cutsceneFile and love.filesystem.getInfo(cutsceneFile) then
			self.cutscene = love.graphics.newVideo(cutsceneFile)
			self.cutscene:play()
			self.cutscenePlaying = true
			self.cutsceneStartTime = love.timer.getTime()
			self.cutsceneDuration = cutsceneDur
		else
			weeks:setupCountdown()
		end

		-- Para blazin (song 4): interceptar handleSongEnd de weeks para
		-- reproducir blazinCutscene.ogv antes de ir a resultados
		if song == 4 then
			self.origHandleSongEnd = weeks.handleSongEnd
			local weekSelf = self
			weeks.handleSongEnd = function(weeksObj)
				if not weekSelf.pendingBlazinEnd then
					local blazinFile = "videos/blazinCutscene.ogv"
					if love.filesystem.getInfo(blazinFile) then
						weekSelf.pendingBlazinEnd = true
						weekSelf.cutscene = love.graphics.newVideo(blazinFile)
						weekSelf.cutscene:play()
						weekSelf.cutscenePlaying = true
						weekSelf.cutsceneStartTime = love.timer.getTime()
						weekSelf.cutsceneDuration = 43
						return  -- No ir a resultados todavía
					end
				end
				-- Sin video o ya se reprodujo: comportamiento original
				weekSelf.origHandleSongEnd(weeksObj)
			end
		else
			self.origHandleSongEnd = nil
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 4 then
			weeks:loadChart("charts/weekend1/blazin" .. difficulty)
		elseif song == 3 then
			weeks:loadChart("charts/weekend1/2hot" .. difficulty)
		elseif song == 2 then
			weeks:loadChart("charts/weekend1/lit-up" .. difficulty)
		else
			weeks:loadChart("charts/weekend1/darnell" .. difficulty)
		end

		-- Cargar eventos de FocusCamera/ZoomCamera propios de Weekend 1
		self.w1Events = {}
		local evFile
		if song == 4 then evFile = "charts/weekend1/events/events-blazin.lua"
		elseif song == 3 then evFile = "charts/weekend1/events/events-2hot.lua"
		elseif song == 2 then evFile = "charts/weekend1/events/events-lit-up.lua"
		else evFile = "charts/weekend1/events/events-darnell.lua"
		end

		local chunk, err = love.filesystem.load(evFile)
		if chunk then
			local ok, evList = pcall(chunk)
			if ok and evList then
				for _, ev in ipairs(evList) do
					table.insert(self.w1Events, ev)
				end
				table.sort(self.w1Events, function(a, b) return a.time < b.time end)
				print("Weekend1: cargados", #self.w1Events, "eventos desde", evFile)
			end
		else
			print("Weekend1: no se encontró", evFile, err)
		end

		-- Índice del próximo evento a procesar
		self.w1EventIndex = 1

		-- Timers locales para FocusCamera y ZoomCamera
		self.focusTimer = nil
		self.zoomTimer = nil
	end,

	update = function(self, dt)
		-- === Cutscene en reproducción (antes de canción o después de blazin) ===
		if self.cutscenePlaying then
			if not graphics.isFading() then
				if input:pressed("confirm") then
					-- Saltar cutscene
					self:stopCutscene()
					if self.pendingBlazinEnd then
						self:finishBlazinEnd()
					else
						weeks:setupCountdown()
					end
					return
				elseif input:pressed("gameBack") then
					-- Salir al menú
					self:stopCutscene()
					if inst then inst:stop() end
					if voices then voices:stop() end
					status.setLoading(true)
					graphics.fadeOut(0.5, function()
						Gamestate.switch(menu)
						status.setLoading(false)
					end)
					return
				end
			end

			-- Verificar si terminó por duración
			if love.timer.getTime() - self.cutsceneStartTime >= self.cutsceneDuration then
				self:stopCutscene()
				if self.pendingBlazinEnd then
					self:finishBlazinEnd()
				else
					weeks:setupCountdown()
				end
			end
			return  -- No actualizar el juego mientras haya cutscene
		end

		weeks:update(dt)

		-- =====================================================================
		-- Rain Shader: actualizar tiempo e intensidad cada frame
		-- Replica el comportamiento de PhillyStreets.update():
		--   rainShader.update(elapsed)  →  time += elapsed
		--   rainShader.intensity = remap(songPosition, 0, songLength, start, end)
		-- =====================================================================
		if rainShader then
			rainTime = rainTime + dt
			rainShader:send("uTime", rainTime)

			-- weeks.songPercent va de 0.0 a 1.0 durante la canción
			local progress = weeks.songPercent or 0
			local intensity = rainShaderStartIntensity
				+ progress * (rainShaderEndIntensity - rainShaderStartIntensity)
			rainShader:send("uIntensity", intensity)
		end

		-- =====================================================================
		-- Blazin: sistema de rayos
		-- =====================================================================
		if isBlazinSong then
			-- Countdown hasta el próximo rayo
			lightningTimer = lightningTimer - dt
			if lightningTimer <= 0 then
				applyLightning()
				lightningTimer = 7 + love.math.random() * 8  -- 7–15 s (igual que el original)
			end

			-- Actualizar sprite del rayo (animar frames)
			if lightningSprite and lightningSprite.visible then
				lightningSprite:update(dt)
				-- Ocultar cuando la animación termina
				if lightningSprite.anims and lightningSprite.anims["lightning"] then
					if not lightningSprite:isAnimated() then
						lightningSprite.visible = false
					end
				end
			end

			-- Actualizar flash de pantalla (fade out ultra-rápido vía addColor shader)
			if lightningFlash.active then
				lightningFlash.elapsed = lightningFlash.elapsed + dt
				local t = math.min(lightningFlash.elapsed / lightningFlash.duration, 1)
				lightningFlash.alpha = 1.0 * (1 - t)  -- blanco puro que desaparece rápido
				if addColorShader then
					addColorShader:send("colorRed",   lightningFlash.alpha)
					addColorShader:send("colorGreen", lightningFlash.alpha)
					addColorShader:send("colorBlue",  lightningFlash.alpha)
					addColorShader:send("colorAlpha", 0.0)
				end
				if t >= 1 then
					lightningFlash.active = false
					lightningFlash.alpha = 0
					if addColorShader then
						addColorShader:send("colorRed",   0.0)
						addColorShader:send("colorGreen", 0.0)
						addColorShader:send("colorBlue",  0.0)
					end
				end
			end

			-- Actualizar fade del fondo (fade out lento)
			if lightningFade.active then
				lightningFade.elapsed = lightningFade.elapsed + dt
				local t = math.min(lightningFade.elapsed / lightningFade.duration, 1)
				lightningFade.alpha = 0.7 * (1 - t)
				if t >= 1 then
					lightningFade.active = false
					lightningFade.alpha = 0
				end
			end

			-- Actualizar tween de color de personajes (vuelven a su color normal)
			if charColorTween.active then
				charColorTween.elapsed = charColorTween.elapsed + dt
				local t = math.min(charColorTween.elapsed / charColorTween.duration, 1)
				-- Interpolar de oscuro a normal
				local r = CHAR_DARK_R + (CHAR_NORM_R - CHAR_DARK_R) * t
				local g = CHAR_DARK_G + (CHAR_NORM_G - CHAR_DARK_G) * t
				local b = CHAR_DARK_B + (CHAR_NORM_B - CHAR_DARK_B) * t
				if boyfriend and boyfriend.colorR ~= nil then
					boyfriend.colorR = r; boyfriend.colorG = g; boyfriend.colorB = b
				end
				if enemy and enemy.colorR ~= nil then
					enemy.colorR = r; enemy.colorG = g; enemy.colorB = b
				end
				if t >= 1 then charColorTween.active = false end
			end
		end

		if not (countingDown or graphics.isFading()) and weeks.songEnded then
			if _G.storyMode and song < 3 then
				song = song + 1
				_G.currentSongIndex = song
				_G.currentSongName = _G.weekSongs[song]
				self:load()
			end
		end

		-- =====================================================================
		-- Procesar eventos FocusCamera / ZoomCamera de Weekend 1
		-- =====================================================================
		local musicTime = weeks:getMusicTime()
		local currentBpm = weeks:getBPM()

		if musicTime and self.w1Events and self.w1EventIndex then
			while self.w1EventIndex <= #self.w1Events do
				local ev = self.w1Events[self.w1EventIndex]
				if musicTime < ev.time then
					break  -- Aún no toca este evento
				end

				if ev.type == "FocusCamera" then
					-- char: 0 = boyfriend (Pico), 1 = enemy (Darnell), 2 = girlfriend (Nene)
					local charId = tonumber(ev.char) or 0
					local offsetX = tonumber(ev.x) or 0
					local offsetY = tonumber(ev.y) or 0
					local duration = tonumber(ev.duration) or 0
					local easeName = ev.ease

					-- Determinar hacia dónde miran los ojos de Abot
					local newFocus = (charId == 0) and "player" or "oponent"
					if abotAis and newFocus ~= lastCamFocus then
						abotAis:animate(newFocus, false)
						lastCamFocus = newFocus
					end

					local targetX, targetY
					if charId == 0 then
						-- Boyfriend (Pico) → enfocar nastyObject en lugar del personaje
						targetX = -nastyObjectPos.x + offsetX
						targetY = -nastyObjectPos.y + offsetY
					elseif charId == 2 then
						-- Girlfriend (Nene) → enfocar nastyObject3 en lugar del personaje
						targetX = -nastyObject3Pos.x + offsetX
						targetY = -nastyObject3Pos.y + offsetY
					else
						-- Enemy (Darnell) — char == 1
						targetX = -enemy.x - 100 + offsetX
						targetY = -enemy.y + 75 + offsetY
					end

					-- Cancelar tweens anteriores de cámara
					if self.focusTimer then Timer.cancel(self.focusTimer); self.focusTimer = nil end
					if camTimer then Timer.cancel(camTimer) end

					-- Desactivar autoCam de weeks para que no sobreescriba
					_G.disableAutoCam = true

					if easeName == "INSTANT" then
						-- Teletransporte instantáneo
						cam.x = targetX
						cam.y = targetY
					elseif duration > 0 then
						-- Tween con duración en beats, convertir a segundos
						local humpEase = getFnfEase(easeName)
						local tweenDur = duration * 60 / (currentBpm or 100)
						self.focusTimer = Timer.tween(tweenDur, cam, {x = targetX, y = targetY}, humpEase or "out-quad", function() self.focusTimer = nil end)
					else
						-- Sin duración explícita: tween suave por defecto (1.25s)
						self.focusTimer = Timer.tween(1.25, cam, {x = targetX, y = targetY}, "out-quad", function() self.focusTimer = nil end)
					end

				elseif ev.type == "ZoomCamera" then
					local targetZoom = ev.zoom or 1
					local duration = tonumber(ev.duration) or 0
					local easeName = ev.ease

					-- Cancelar tween de zoom anterior
					if self.zoomTimer then Timer.cancel(self.zoomTimer); self.zoomTimer = nil end

					if easeName == "INSTANT" or duration <= 0 then
						-- Cambio instantáneo
						camScale.x = targetZoom
						camScale.y = targetZoom
					else
						local humpEase = getFnfEase(easeName)
						local tweenDur = duration * 60 / (currentBpm or 100)
						self.zoomTimer = Timer.tween(tweenDur, camScale, {x = targetZoom, y = targetZoom}, humpEase or "out-quad", function() self.zoomTimer = nil end)
					end
				end

				self.w1EventIndex = self.w1EventIndex + 1
			end
		end

		-- Actualizar sprites de fondo al ritmo del beat
		if musicTime and currentBpm then
			local beatInterval = 60000 / currentBpm
			if lastBeatTime == 0 then
				lastBeatTime = musicTime
			end
			if musicTime - lastBeatTime >= beatInterval then
				lastBeatTime = musicTime

				for _, bg in ipairs(backgroundSprites) do
					if not bg.sprite:isAnimated() then
						local desiredSpeed = (bg.frameCount * currentBpm / 60) / 2
						bg.sprite:setAnimSpeed(desiredSpeed)
						bg.sprite:animate(bg.animName, false)
					end
				end

				-- AbotSystem hace idle sincronizado con el beat (igual que Nene/GF)
				if abotSystem and abotSystem.anims and abotSystem.anims["idle"] then
					abotSystem:animate("idle", false)
					local anim = abotSystem.anims["idle"]
					local frameCount = anim.stop - anim.start + 1
					local desiredSpeed = (frameCount * currentBpm / 60) / 2
					abotSystem:setAnimSpeed(desiredSpeed)
				end

				-- Semáforo y vehículos: ejecutar lógica de beat
				curBeat = curBeat + 1
				beatHitTraffic(curBeat)
			end
		end

		for _, bg in ipairs(backgroundSprites) do
			bg.sprite:update(dt)
		end

		-- Actualizar AbotSystem y AbotAis (no son backgroundSprites)
		if abotSystem then abotSystem:update(dt) end
		if abotAis then abotAis:update(dt) end

		-- =================================================================
		-- Actualizar tweens de vehículos y sprites de semáforo/carros
		-- =================================================================
		-- Actualizar path tweens con soporte de startDelay
		if carTween and carTween.active then
			if carTween.startDelay and carTween.startDelay > 0 then
				carTween.delayElapsed = (carTween.delayElapsed or 0) + dt
				if carTween.delayElapsed >= carTween.startDelay then
					local remainder = carTween.delayElapsed - carTween.startDelay
					carTween.startDelay = 0
					updatePathTween(carTween, remainder)
				end
			else
				updatePathTween(carTween, dt)
			end
		end
		updateAngleTween(carAngleTween, dt)

		if car2Tween and car2Tween.active then
			if car2Tween.startDelay and car2Tween.startDelay > 0 then
				car2Tween.delayElapsed = (car2Tween.delayElapsed or 0) + dt
				if car2Tween.delayElapsed >= car2Tween.startDelay then
					local remainder = car2Tween.delayElapsed - car2Tween.startDelay
					car2Tween.startDelay = 0
					updatePathTween(car2Tween, remainder)
				end
			else
				updatePathTween(car2Tween, dt)
			end
		end
		updateAngleTween(car2AngleTween, dt)

		-- Actualizar animaciones de sprites de carros y semáforo
		if phillyCars then phillyCars:update(dt) end
		if phillyCars2 then phillyCars2:update(dt) end
		if phillyTraffic then phillyTraffic:update(dt) end

		-- =====================================================================
		-- darkenStageProps: timer de 1 frame + fade de vuelta a normal
		-- =====================================================================
		if self.darkenTimer then
			self.darkenTimer = self.darkenTimer - dt
			if self.darkenTimer <= 0 then
				self.darkenTimer = nil
				triggerDarkenStage()
			end
		end
		if darkenFade.active then
			if darkenFade.phase == 1 then
				-- Primer frame: 0x111111 ya aplicado por triggerDarkenStage
				-- Tras ~1 frame (1/24s), pasar a fase 2: 0x222222 → 0xFFFFFF
				darkenFade.elapsed = darkenFade.elapsed + dt
				if darkenFade.elapsed >= 1/24 then
					darkenTint = 0x22 / 0xFF  -- ≈ 0.133
					darkenFade.phase = 2
					darkenFade.elapsed = 0
				end
			elseif darkenFade.phase == 2 then
				-- Tween de 0x222222 → 0xFFFFFF en 1.4s
				darkenFade.elapsed = darkenFade.elapsed + dt
				local t = math.min(darkenFade.elapsed / darkenFade.duration, 1)
				darkenTint = (0x22 / 0xFF) + (1.0 - 0x22 / 0xFF) * t
				if t >= 1 then
					darkenFade.active = false
					darkenFade.phase = 0
					darkenTint = 1.0
				end
			end
		end

		weeks:updateUI(dt)
	end,

	-- Detener y limpiar el video de cutscene actual
	stopCutscene = function(self)
		self.cutscenePlaying = false
		if self.cutscene then
			if self.cutscene.stop then
				self.cutscene:stop()
			elseif self.cutscene.pause then
				self.cutscene:pause()
			end
			self.cutscene = nil
		end
	end,

	-- Finalizar la transición después de la cutscene de blazin
	finishBlazinEnd = function(self)
		-- Restaurar handleSongEnd original y ejecutarlo
		if self.origHandleSongEnd then
			weeks.handleSongEnd = self.origHandleSongEnd
			self.origHandleSongEnd = nil
		end
		weeks:handleSongEnd()
	end,

	draw = function(self)
		-- Si hay cutscene reproduciéndose, dibujar solo el video
		if self.cutscenePlaying and self.cutscene then
			love.graphics.push()
			love.graphics.origin()
			local vw, vh = love.graphics.getDimensions()
			local sw = self.cutscene:getWidth()
			local sh = self.cutscene:getHeight()
			local sx = vw / sw
			local sy = vh / sh
			love.graphics.draw(self.cutscene, 0, 0, 0, sx, sy)
			love.graphics.pop()
			return
		end

		-- =================================================================
		-- RAIN SHADER: renderizar la escena del juego a un Canvas
		-- intermedio, luego dibujar ese canvas CON el shader.
		-- Esto replica FlxG.camera.setFilters([new ShaderFilter(rainShader)])
		-- del PhillyStreets.hx original: afecta TODA la escena pero NO la GUI.
		-- =================================================================
		local useRain = (rainShader ~= nil and rainCanvas ~= nil)

		if useRain then
			-- Asegurar que el canvas tenga el tamaño correcto (por si cambió la ventana)
			local cw, ch = love.graphics.getDimensions()
			if rainCanvas:getWidth() ~= cw or rainCanvas:getHeight() ~= ch then
				rainCanvas = love.graphics.newCanvas(cw, ch)
			end
			love.graphics.setCanvas(rainCanvas)
			love.graphics.clear(0, 0, 0, 1)
		end

		-- ===== ESCENA DEL JUEGO (stage + personajes + ratings) =====
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			for _, layer in ipairs(stageLayers) do
				if layer.visible and layer.obj then
					-- Blazin: skip the fighting characters in the normal loop,
					-- we draw them manually below with dynamic z-ordering
					local isBlazinChar = isBlazinSong and (layer == blazinEnemyLayer or layer == blazinBfLayer)

					if not isBlazinChar then
						love.graphics.push()
							love.graphics.translate(cam.x * layer.scrollX, cam.y * layer.scrollY)

							-- Blend mode y alpha opcionales por layer (usado por lightmaps)
							local hasBlend = layer.blend ~= nil
							local layerAlpha = layer.alpha or 1.0
							if hasBlend then love.graphics.setBlendMode(layer.blend) end

							-- Color del layer: fade del engine × darkenTint (solo para layers darkenable)
							local f = graphics.getFade()
							local tint = (layer.darkenable and darkenTint < 1.0) and darkenTint or 1.0
							love.graphics.setColor(f * tint, f * tint, f * tint, layerAlpha)

							if layer.obj == phillyCars then
								-- El carro 1 usa posición propia (movida por tweens)
								-- Si no está visible (no hay tween activo), no dibujar
								if phillyCars.visible then
									phillyCars.orientation = math.rad(phillyCars.angle or 0)
									phillyCars:draw()
								end
							elseif layer.obj == phillyCars2 then
								-- El carro 2 igual que el 1 pero con flipX (va en sentido contrario)
								if phillyCars2.visible then
									phillyCars2.orientation = math.rad(phillyCars2.angle or 0)
									local origSizeX = math.abs(phillyCars2.sizeX or 1)
									phillyCars2.sizeX = phillyCars2.flipX and -origSizeX or origSizeX
									phillyCars2:draw()
								end
							elseif layer.obj == phillyTraffic then
								-- El semáforo se dibuja en su posición del layer
								layer.obj.x = layer.x
								layer.obj.y = layer.y
								layer.obj:draw()
							elseif layer.obj == lightningSprite then
								-- El rayo: solo dibujar si está visible (lo activa applyLightning)
								-- applyLightning modifica layer.x y layer.y según las posiciones fijas
								if lightningSprite.visible then
									layer.obj.x = layer.x
									layer.obj.y = layer.y
									layer.obj:draw()
								end
							else
								layer.obj.x = layer.x
								layer.obj.y = layer.y

								-- Blazin: Nene y AbotSystem se dibujan oscurecidos y difuminados
								-- para dar el efecto de profundidad del fondo (como en el original)
								local isBlazinBgChar = isBlazinSong
									and (layer.obj == girlfriend or layer.obj == abotSystem)

								if isBlazinBgChar and blazinDarkenShader then
									love.graphics.setShader(blazinDarkenShader)
									layer.obj:draw()
									love.graphics.setShader()
								else
									layer.obj:draw()
								end
							end

							-- Restaurar blend y color
							if hasBlend then love.graphics.setBlendMode("alpha") end
							love.graphics.setColor(1, 1, 1, 1)
					love.graphics.pop()
					end
				end
			end

			-- Blazin: draw fighting characters with dynamic z-order
			-- The attacker (the one throwing the punch) draws ON TOP
			-- so their fist visually passes in front of the dodger/blocker
			if isBlazinSong and blazinEnemyLayer and blazinBfLayer then
				local drawOrder = blazinFight.getDrawOrder()
				-- drawOrder: "darnellOnTop" or "picoOnTop" (default)
				local function drawFighter(layer)
					love.graphics.push()
						love.graphics.translate(cam.x * layer.scrollX, cam.y * layer.scrollY)
						local f = graphics.getFade()
						love.graphics.setColor(f, f, f, 1)
						layer.obj.x = layer.x
						layer.obj.y = layer.y
						layer.obj:draw()
						love.graphics.setColor(1, 1, 1, 1)
					love.graphics.pop()
				end

				if drawOrder == "darnellOnTop" then
					drawFighter(blazinBfLayer)     -- Pico behind (dodging/blocking)
					drawFighter(blazinEnemyLayer)  -- Darnell on top (attacking)
				else
					drawFighter(blazinEnemyLayer)  -- Darnell behind
					drawFighter(blazinBfLayer)     -- Pico on top (attacking)
				end
			end
			-- Dibujar carro 2 (no está en stageLayers, se creó aparte)
			if phillyCars2 and phillyCars2.visible then
				love.graphics.push()
					love.graphics.translate(cam.x * 0.9, cam.y * 1)
					phillyCars2.orientation = math.rad(phillyCars2.angle or 0)
					-- flipX: escalar sizeX negativamente
					local origSizeX = math.abs(phillyCars2.sizeX or 1)
					if phillyCars2.flipX then
						phillyCars2.sizeX = -origSizeX
					else
						phillyCars2.sizeX = origSizeX
					end
					phillyCars2:draw()
				love.graphics.pop()
			end

			weeks:drawRating(0.9)
			-- Nota: el sprite del rayo (lightningSprite) se dibuja automáticamente
			-- por el loop de stageLayers de arriba, en su posición correcta del stage.
		love.graphics.pop()

		-- =================================================================
		-- RAIN SHADER: aplicar shader al canvas y dibujarlo en pantalla.
		-- =================================================================
		if useRain then
			love.graphics.setCanvas()
			love.graphics.setShader(rainShader)
			love.graphics.draw(rainCanvas, 0, 0)
			love.graphics.setShader()
		end

		-- =================================================================
		-- Blazin: efectos de flash/fade del rayo SOBRE el canvas final
		-- Flash blanco (rápido) + fade blanco (lento) = efecto limpio sin tinte
		-- Ambos usan blend ADD sobre blanco puro, igual que additionalLighten
		-- y skyAdditive en el original Haxe.
		-- =================================================================
		if isBlazinSong then
			local cw, ch = love.graphics.getDimensions()
			local f = graphics.getFade()

			-- 1) Fade del cielo: blanco puro tenue que desaparece lento (skyAdditive)
			--    Se dibuja primero para que el flash quede encima
			if lightningFade.alpha > 0.001 then
				love.graphics.setBlendMode("add")
				love.graphics.setColor(
					lightningFade.alpha * 0.7 * f,
					lightningFade.alpha * 0.7 * f,
					lightningFade.alpha * 0.7 * f,
					1.0
				)
				love.graphics.rectangle("fill", 0, 0, cw, ch)
				love.graphics.setBlendMode("alpha")
				love.graphics.setColor(1, 1, 1, 1)
			end

			-- 2) Flash blanco puro: muy brillante y muy rápido (additionalLighten)
			if lightningFlash.active and lightningFlash.alpha > 0.001 then
				love.graphics.setBlendMode("add")
				love.graphics.setColor(
					lightningFlash.alpha * f,
					lightningFlash.alpha * f,
					lightningFlash.alpha * f,
					1.0
				)
				love.graphics.rectangle("fill", 0, 0, cw, ch)
				love.graphics.setBlendMode("alpha")
				love.graphics.setColor(1, 1, 1, 1)
			end
		end

		-- ===== GUI: se dibuja SIN shader (equivale a camHUD en el original) =====
		weeks:drawUI()
	end,

	leave = function(self)
		-- Restaurar handleSongEnd original si fue interceptado
		if self.origHandleSongEnd then
			weeks.handleSongEnd = self.origHandleSongEnd
			self.origHandleSongEnd = nil
		end

		-- Detener video si está reproduciéndose
		if self.cutscene then
			if self.cutscene.stop then
				self.cutscene:stop()
			elseif self.cutscene.pause then
				self.cutscene:pause()
			end
			self.cutscene = nil
		end
		self.cutscenePlaying = false
		self.pendingBlazinEnd = false

		backgroundSprites = {}
		stageLayers = {}
		stageData = nil
		lastBeatTime = 0
		abotSystem = nil
		abotAis = nil
		lastCamFocus = nil
		nastyObject3Pos = {x = 13, y = -85}
		nastyObjectPos = {x = 371.85714285714, y = 35.142857142857}
		_G.disableAutoCam = false
		_G.currentWeek = nil  -- Limpiar referencia a hooks custom

		-- Limpiar sistema de pelea Blazin
		if isBlazinSong then
			blazinFight.cleanup()
			weeks:setMiddleScroll(false)
			isBlazinSong = false
		end
		blazinEnemyLayer = nil
		blazinBfLayer = nil

		-- Limpiar sistema de semáforo y vehículos
		cancelCarTweens()
		cancelCar2Tweens()
		phillyCars = nil
		phillyCars2 = nil
		phillyTraffic = nil
		phillyCarsLayer = nil
		phillyCars2Layer = nil
		phillyTrafficLayer = nil
		lightsStop = false
		lastLightChange = 0
		changeInterval = 8
		carWaiting = false
		carInterruptable = true
		car2Interruptable = true
		curBeat = 0
		lastBeatTimeTraffic = 0

		-- Limpiar sonidos de Pico Shoot
		self.picoShootSounds = nil

		-- Limpiar sistema de rayos (Blazin)
		lightningSprite = nil
		lightningLayer  = nil
		addColorShader  = nil
		lightningTimer = 3.0
		for _, s in ipairs(lightningSounds) do if s then s:stop() end end
		lightningSounds = {}
		lightningFlash = {alpha=0, active=false, elapsed=0, duration=0}
		lightningFade  = {alpha=0, active=false, elapsed=0, duration=0}
		charColorTween = {active=false, elapsed=0, duration=0}

		-- Limpiar Rain Shader
		rainShader = nil
		rainCanvas = nil
		rainTime = 0

		-- Limpiar darkenStageProps
		darkenTint = 1.0
		darkenFade = { active = false, elapsed = 0, duration = 1.4, phase = 0 }
		self.darkenTimer = nil

		-- Limpiar Blazin background shaders
		blazinDarkenShader = nil
		blazinBlurShader = nil

		-- Limpiar timers de eventos Weekend 1
		if self.focusTimer then Timer.cancel(self.focusTimer); self.focusTimer = nil end
		if self.zoomTimer then Timer.cancel(self.zoomTimer); self.zoomTimer = nil end
		self.w1Events = nil
		self.w1EventIndex = nil

		weeks:leave()
	end
}