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

local stageData          -- tabla del stage cargada
local stageLayers = {}   -- objetos gráficos listos para dibujar
local backgroundSprites = {}
local lastBeatTime = 0

-- Variables para eventos personalizados
local customCountdownActive = false
local customCountdownImage = nil
local customCountdownAlpha = 0

-- ============================================================
-- SWAP DE TEXTURAS MAJIN
-- Se activa una sola vez al recibir el GO! (number == "4")
-- y permanece activo hasta el final de la canción.
-- ============================================================
local majinTexturesActive = false

-- Carga la imagen de Majin_Notes y la asigna a images.notes
-- para que todos los sprites que lean images.notes usen la nueva textura.
local function activateMajinTextures()
	if majinTexturesActive then return end
	majinTexturesActive = true

	-- 1. Reemplazar images.notes e images.noteSplashes por las texturas de Majin/Endless
	local majinNotesImg    = love.graphics.newImage(graphics.imagePath("FunInfiniteStage/Majin_Notes"))
	local endlessSplashImg = love.graphics.newImage(graphics.imagePath("FunInfiniteStage/endlessNoteSplashes"))

	images.notes        = majinNotesImg
	images.noteSplashes = endlessSplashImg

	-- 2. Recargar los loaders de flechas para que apunten a sprites/FunInfiniteStage/
	--    (los archivos *-arrow.lua de esa carpeta usan images.notes que ya está actualizado)
	sprites.leftArrow  = love.filesystem.load("sprites/FunInfiniteStage/left-arrow.lua")
	sprites.downArrow  = love.filesystem.load("sprites/FunInfiniteStage/down-arrow.lua")
	sprites.upArrow    = love.filesystem.load("sprites/FunInfiniteStage/up-arrow.lua")
	sprites.rightArrow = love.filesystem.load("sprites/FunInfiniteStage/right-arrow.lua")

	-- 3. Recrear las flechas estáticas (strums) con el nuevo sprite
	weeks:recreateStaticArrows()

	-- 4. Recrear todas las notas en vuelo con el nuevo sprite
	weeks:recreateAllNotes()

	-- 5. Cambiar los splashes por los de Endless, uno por carril:
	--    lane 1 = left  = purple
	--    lane 2 = down  = blue
	--    lane 3 = up    = green
	--    lane 4 = right = red
	weeks:setSplashPerLane({
		love.filesystem.load("sprites/FunInfiniteStage/splash-left.lua"),   -- purple
		love.filesystem.load("sprites/FunInfiniteStage/splash-down.lua"),   -- blue
		love.filesystem.load("sprites/FunInfiniteStage/splash-up.lua"),     -- green
		love.filesystem.load("sprites/FunInfiniteStage/splash-right.lua"),  -- red
	})

	print("[Endless] Texturas Majin activadas.")
end

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	loadStage = function(self, songNum, songAppend)
		song = song or songNum
		difficulty = songAppend

		-- Resetear flag de texturas al entrar/reiniciar la canción
		majinTexturesActive = false

		-- Cargar el stage desde stages/endless.lua
		local chunk, err = love.filesystem.load("stages/endless.lua")
		if not chunk then
			print("Error al cargar el stage endless:", err)
			stageLayers = {}
		else
			local ok, loaded = pcall(chunk)
			if ok and loaded then
				stageData = loaded
				stageLayers = {}
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
						obj = nil
					}
					if layer.type == "image" then
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
									local animName = layer.obj.anims["idle"] and "idle" or next(layer.obj.anims)
									if animName then layer.obj:animate(animName, false) end
								end
							end
						end
					end
					table.insert(stageLayers, layer)

					if layer.path == "MajinOG" and layer.obj then
						enemy = layer.obj
						enemy.x, enemy.y = layer.x, layer.y
						enemy.sizeX = layer.scaleX * (enemy.sizeX or 1)
						enemy.sizeY = layer.scaleY * (enemy.sizeY or 1)
					elseif layer.path == "endless_bf" and layer.obj then
						boyfriend = layer.obj
						boyfriend.x, boyfriend.y = layer.x, layer.y
						boyfriend.sizeX = layer.scaleX * (boyfriend.sizeX or 1)
						boyfriend.sizeY = layer.scaleY * (boyfriend.sizeY or 1)
					elseif layer.path == "girlfriend" and layer.obj then
						girlfriend = layer.obj
						girlfriend.x, girlfriend.y = layer.x, layer.y
						girlfriend.sizeX = layer.scaleX * (girlfriend.sizeX or 1)
						girlfriend.sizeY = layer.scaleY * (girlfriend.sizeY or 1)
					end

					if layer.type == "sprite" and layer.obj and layer.obj ~= enemy and layer.obj ~= boyfriend and layer.obj ~= girlfriend then
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

				for _, layer in ipairs(stageLayers) do
					if layer.type == "sprite" and layer.obj then
						local isCharacter = layer.obj == enemy or layer.obj == boyfriend or layer.obj == girlfriend
						if not isCharacter then
							layer.obj.sizeX = layer.scaleX * (layer.obj.sizeX or 1)
							layer.obj.sizeY = layer.scaleY * (layer.obj.sizeY or 1)
						end
					end
				end
			else
				print("Error al ejecutar el stage endless:", loaded)
			end
		end

		if not enemy then
			enemy = love.filesystem.load("sprites/MajinOG.lua")()
			enemy.x, enemy.y = -380, 100
		end
		if not boyfriend then
			boyfriend = love.filesystem.load("sprites/endless_bf.lua")()
			boyfriend.x, boyfriend.y = 260, 100
		end
		if not girlfriend then
			girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
			girlfriend.x, girlfriend.y = 30, -90
		end

		enemyIcon:animate("majin", false)

		_G.currentWeek = self

		cam.sizeX = 0.95
		cam.sizeY = 0.95
		camScale.x = 0.95
		camScale.y = 0.95
		_G.disableAutoCam = false

		self.events = nil
		self.eventIndex = nil
		customCountdownActive = false
		customCountdownImage = nil
		customCountdownAlpha = 0
	end,

	load = function(self)
		weeks:load()

		inst = love.audio.newSource("music/endless/endless-inst.ogg", "stream")
		voices = love.audio.newSource("music/endless/endless-voices.ogg", "stream")

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:loadChart("charts/endless/endless-hard")

		self.events = {}
		local json = require("lib.json")
		local content = love.filesystem.read("charts/endless/events.json")
		if content then
			local ok, data = pcall(json.decode, content)
			if ok and data and data.song and data.song.notes then
				for _, section in ipairs(data.song.notes) do
					for _, note in ipairs(section.sectionNotes) do
						if note[2] == -1 then
							local ev = {
								time = note[1],
								type = note[3],
								param1 = note[4] or "",
								param2 = note[5] or ""
							}
							table.insert(self.events, ev)
						end
					end
				end
				table.sort(self.events, function(a, b) return a.time < b.time end)
				print("Cargados", #self.events, "eventos desde events.json")
			else
				print("Error al cargar events.json:", data or "contenido inválido")
			end
		else
			print("No se encontró charts/endless/events.json")
		end
		self.eventIndex = 1
	end,

	update = function(self, dt)
		weeks:update(dt)

		-- Procesar eventos
		if self.events and self.eventIndex then
			local musicTime = weeks:getMusicTime()
			while self.eventIndex <= #self.events do
				local ev = self.events[self.eventIndex]
				if musicTime >= ev.time then
					if ev.type == "Majin spin" then
						self:doMajinSpin(ev.param1)
					elseif ev.type == "Majin count" then
						self:doMajinCount(ev.param1)
					end
					self.eventIndex = self.eventIndex + 1
				else
					break
				end
			end
		end

		-- Actualizar countdown personalizado (fade out)
		if customCountdownActive then
			customCountdownAlpha = customCountdownAlpha - dt * 2
			if customCountdownAlpha <= 0 then
				customCountdownActive = false
				customCountdownImage = nil
			end
		end

		-- Animación de los sprites de fondo al ritmo del beat
		local musicTime = weeks:getMusicTime()
		local bpm = weeks:getBPM()
		if musicTime and bpm then
			local beatInterval = 60000 / bpm
			if lastBeatTime == 0 then
				lastBeatTime = musicTime
			end
			if musicTime - lastBeatTime >= beatInterval then
				lastBeatTime = musicTime

				for _, bg in ipairs(backgroundSprites) do
					if not bg.sprite:isAnimated() then
						local desiredSpeed = (bg.frameCount * bpm / 60) / 2
						bg.sprite:setAnimSpeed(desiredSpeed)
						bg.sprite:animate(bg.animName, false)
					end
				end
			end
		end

		for _, bg in ipairs(backgroundSprites) do
			bg.sprite:update(dt)
		end

		if not (countingDown or graphics.isFading()) and weeks.songEnded then
			if _G.storyMode and song < 3 then
				song = song + 1
				_G.currentSongIndex = song
				_G.currentSongName = _G.weekSongs[song]
				self:load()
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			for _, layer in ipairs(stageLayers) do
				if layer.visible and layer.obj then
					love.graphics.push()
						love.graphics.translate(cam.x * layer.scrollX, cam.y * layer.scrollY)
						layer.obj.x = layer.x
						layer.obj.y = layer.y
						layer.obj:draw()
					love.graphics.pop()
				end
			end

			weeks:drawRating(0.9)
		love.graphics.pop()

		weeks:drawUI()

		if customCountdownActive and customCountdownImage then
			love.graphics.push()
			love.graphics.origin()
			local cw, ch = love.graphics.getDimensions()
			local imgW = customCountdownImage:getWidth()
			local imgH = customCountdownImage:getHeight()
			local x = (cw - imgW) / 2
			local y = (ch - imgH) / 2
			graphics.setColor(1, 1, 1, customCountdownAlpha)
			love.graphics.draw(customCountdownImage, x, y)
			love.graphics.pop()
		end
	end,

	doMajinSpin = function(self, param)
		local duration = 0.25
		local startTime = love.timer.getTime()

		local function step()
			local elapsed = love.timer.getTime() - startTime
			local t = math.min(1, elapsed / duration)
			local rad = t * 2 * math.pi

			weeks:rotateArrows(rad)

			if t < 1 then
				Timer.after(0, step)
			else
				weeks:rotateArrows(0)
			end
		end

		step()
	end,

	doMajinCount = function(self, number)
		local filename
		if number == "1" then
			filename = "png/FunInfiniteStage/three"
		elseif number == "2" then
			filename = "png/FunInfiniteStage/two"
		elseif number == "3" then
			filename = "png/FunInfiniteStage/one"
		elseif number == "4" then
			filename = "png/FunInfiniteStage/gofun"
		else
			return
		end

		if filename:sub(1, 4) == "png/" then
			filename = filename:sub(5)
		end
		local imgPath = graphics.imagePath(filename)
		if love.filesystem.getInfo(imgPath) then
			customCountdownImage = love.graphics.newImage(imgPath)
			customCountdownActive = true
			customCountdownAlpha = 1
			if number == "3" then
				audio.playSound(sounds.countdown.one)
			elseif number == "2" then
				audio.playSound(sounds.countdown.two)
			elseif number == "1" then
				audio.playSound(sounds.countdown.three)
			elseif number == "4" then
				audio.playSound(sounds.countdown.go)
			end
		else
			print("No se encontró imagen:", imgPath)
		end

		-- ============================================================
		-- GO! → activar las texturas de Majin a partir de este momento
		-- ============================================================
		if number == "4" then
			activateMajinTextures()
		end
	end,

	leave = function(self)
		backgroundSprites = {}
		stageLayers = {}
		stageData = nil
		lastBeatTime = 0
		_G.currentWeek = nil

		self.events = nil
		self.eventIndex = nil
		customCountdownActive = false
		customCountdownImage = nil
		customCountdownAlpha = 0

		-- Resetear el flag para la próxima vez que se cargue la canción
		majinTexturesActive = false

		weeks:leave()
	end
}