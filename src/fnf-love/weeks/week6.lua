--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten
Copyright (C) 2021  HTV04
...
------------------------------------------------------------------------------]]

local song, difficulty

-- Fondos y elementos normales (Senpai / Roses)
local sky, school, street, treesBack
local trees, petals, freaks

-- Elementos para Thorns (pre‑escena y canción)
local senpaiCrazy                 -- sprite de Senpai enloquecido (pre‑escena)
local preThornsActive = false
local preThornsPhase = "frozen"   -- "frozen", "crazy", "white"
local preThornsTimer = 0
local senpaiAlpha = 0
local fadeAlpha = 0
local fadeStarted = false
local crazyDuration = 4            -- duración de la animación loca (seg)
local fadeDuration = 1.15          -- duración del fundido a blanco (seg)
local whiteHoldDuration = 4        -- pausa en blanco (seg)

-- Eventos de los fantasmas (Thorns)
local ghoulEvents = {}
local ghoulEventIndex = 1
local ghoulsVisible = false
local ghoulsFading = false

-- Factor de escala para todos los elementos (excepto iconos)
local SCALE = 6.5

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		_G.isPixelWeek = true
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)

		-- Si es Thorns, preparamos la escena inicial (no se carga la canción todavía)
		if song == 3 then
			preThornsActive = true
			preThornsPhase = "frozen"
			preThornsTimer = 0
			senpaiAlpha = 0
			fadeAlpha = 0
			fadeStarted = false

			senpaiCrazy = love.filesystem.load("sprites/week6/senpaiCrazy.lua")()
			senpaiCrazy.sizeX, senpaiCrazy.sizeY = SCALE, SCALE
			senpaiCrazy.x, senpaiCrazy.y = -50 * SCALE, 0   -- -325, 0
			senpaiCrazy:animate("anim", false)   -- primer frame congelado

			-- Ajuste de cámara para centrar a Senpai
			cam.x = 90 * SCALE
			cam.y = -5 * SCALE
			cam.sizeX, cam.sizeY = 0.8, 0.8
		else
			self:load()   -- para Senpai y Roses se carga la canción directamente
		end
	end,

	load = function(self)
		-- Si estamos en la pre‑escena de Thorns, no cargamos la canción todavía
		if preThornsActive then
			return
		end

		-- Cargar sprites del oponente según la canción y establecer su posición
		if song == 3 then
			-- Thorns real (después de la pre‑escena)
			school = love.filesystem.load("sprites/week6/evil-school.lua")()
			school.sizeX, school.sizeY = SCALE, SCALE
			enemy = love.filesystem.load("sprites/week6/spirit.lua")()
			enemy.sizeX, enemy.sizeY = SCALE, SCALE
			enemy.x, enemy.y = -50 * SCALE, 0
			freaks = love.filesystem.load("sprites/week6/bgGhouls.lua")()
			freaks.sizeX, freaks.sizeY = SCALE, SCALE
			freaks:animate("anim", false)
			enemyIcon:animate("spirit", false)

			ghoulEvents = love.filesystem.load("charts/week6/events_thorns.lua")()
			ghoulEventIndex = 1
			ghoulsVisible = false
			ghoulsFading = false

		elseif song == 2 then
			enemy = love.filesystem.load("sprites/week6/senpai-angry.lua")()
			enemy.sizeX, enemy.sizeY = SCALE, SCALE
			enemy.x, enemy.y = -50 * SCALE, 0
			freaks:animate("dissuaded", true)
			enemyIcon:animate("senpai-angry", false)

			-- Reproducir el sonido de texto enojado (siempre al cargar Roses)
			local angrySound = love.audio.newSource("sounds/week6/ANGRY_TEXT_BOX.ogg", "static")
			angrySound:play()
		else
			enemy = love.filesystem.load("sprites/week6/senpai.lua")()
			enemy.sizeX, enemy.sizeY = SCALE, SCALE
			enemy.x, enemy.y = -50 * SCALE, 0
			enemyIcon:animate("senpai", false)
		end

		-- Cargar archivos de música
		if song == 3 then
			inst = love.audio.newSource("music/week6/thorns-inst.ogg", "stream")
			voices = love.audio.newSource("music/week6/thorns-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/week6/roses-inst.ogg", "stream")
			voices = love.audio.newSource("music/week6/roses-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week6/senpai-inst.ogg", "stream")
			voices = love.audio.newSource("music/week6/senpai-voices.ogg", "stream")
		end

		weeks:load()          -- Inicializa estados comunes (cámara, idle, etc.)
		self:initUI()
		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		-- Cargar las notas correspondientes
		if song == 3 then
			weeks:loadChart("charts/week6/thorns" .. difficulty)
		elseif song == 2 then
			weeks:loadChart("charts/week6/roses" .. difficulty)
		else
			weeks:loadChart("charts/week6/senpai" .. difficulty)
		end
	end,

	update = function(self, dt)
		-- --- Pre‑escena de Thorns ---
		if preThornsActive then
			preThornsTimer = preThornsTimer + dt

			if preThornsPhase == "frozen" then
				senpaiAlpha = math.min(preThornsTimer / 2, 1)   -- fundido de entrada en 2 segundos

				if preThornsTimer >= 2 then
					preThornsPhase = "crazy"
					preThornsTimer = 0
					senpaiAlpha = 1

					local dieSound = love.audio.newSource("sounds/week6/Senpai_Dies.ogg", "static")
					dieSound:play()
				end

			elseif preThornsPhase == "crazy" then
				senpaiCrazy:update(dt)   -- ahora sí anima

				if not fadeStarted and preThornsTimer >= crazyDuration then
					fadeStarted = true
					fadeAlpha = 0
				end

				if fadeStarted then
					fadeAlpha = fadeAlpha + dt / fadeDuration
					if fadeAlpha >= 1 then
						fadeAlpha = 1
						preThornsPhase = "white"
						preThornsTimer = 0
					end
				end

			elseif preThornsPhase == "white" then
				if preThornsTimer >= whiteHoldDuration then
					preThornsActive = false
					-- Iniciar la canción Thorns de verdad
					self:load()   -- esto cargará todo lo necesario y comenzará el countdown
				end
			end

			return   -- no se ejecuta el update normal del juego
		end

		-- --- Update normal (durante la canción) ---
		weeks:update(dt)

		if song == 2 and musicThres ~= oldMusicThres and math.fmod(absMusicTime + 500, 480000 / bpm) < 100 then
			weeks:safeAnimate(boyfriend, "hey", false, 3)
		end

		-- Actualizar sprites adicionales
		if song == 3 then
			school:update(dt)
			freaks:update(dt)

			-- Eventos de los fantasmas
			local currentTime = voices:isPlaying() and voices:tell("seconds") * 1000 or 0
			while ghoulEventIndex <= #ghoulEvents and ghoulEvents[ghoulEventIndex].time <= currentTime do
				local event = ghoulEvents[ghoulEventIndex]
				if event.action == "appear" then
					ghoulsVisible = true
					ghoulsFading = false
					freaks:animate("anim", false)
				elseif event.action == "" then
					-- Si ya están visibles, reiniciar animación
					if ghoulsVisible then
						freaks:animate("anim", false)
					end
				elseif event.action == "disappear" then
					ghoulsFading = true
				end
				ghoulEventIndex = ghoulEventIndex + 1
			end

			if ghoulsFading and not freaks:isAnimated() then
				ghoulsVisible = false
				ghoulsFading = false
			end
		else
			-- Actualizar árboles, pétalos y público de fondo
			trees:update(dt)
			petals:update(dt)
			freaks:update(dt)
		end

		-- Transición entre canciones en modo historia
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
		-- Fondo rojo para la pre‑escena (cubre toda la pantalla)
		if preThornsActive then
			love.graphics.setColor(1, 0, 0)
			love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())
			love.graphics.setColor(1, 1, 1)
		end

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			-- Capas de fondo (paralaje)
			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

				if preThornsActive then
					-- No hay fondos adicionales en la pre‑escena
				elseif song == 3 then
					school:draw()
					if ghoulsVisible then
						freaks:draw()
					end
				else
					sky:draw()
					school:draw()
				end
			love.graphics.pop()

			-- Capa media (personajes)
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

				if not preThornsActive then
					if song ~= 3 then
						street:draw()
						treesBack:draw()
						trees:draw()
						petals:draw()
						freaks:draw()
					end
					girlfriend:draw()
					enemy:draw()
					boyfriend:draw()
				else
					love.graphics.setColor(1, 1, 1, senpaiAlpha)
					senpaiCrazy:draw()
					love.graphics.setColor(1, 1, 1)
				end
			love.graphics.pop()

			-- Calificación (con parallax opcional)
			if not preThornsActive then
				weeks:drawRating(0.9)
			end
		love.graphics.pop()

		-- Fundido a blanco durante la pre‑escena (cubre toda la pantalla)
		if preThornsActive and fadeStarted and fadeAlpha > 0 then
			love.graphics.setColor(1, 1, 1, fadeAlpha)
			love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())
			love.graphics.setColor(1, 1, 1)
		end

		-- UI (barra de salud, puntuación, iconos, etc.)
		if not preThornsActive then
			weeks:drawUI()
		end
	end,


	loadStage = function(self, songNum, songAppend)
		_G.isPixelWeek = true
		song = songNum
		difficulty = songAppend
		local SCALE = 6.5

		boyfriend = love.filesystem.load("sprites/pixel/boyfriend.lua")()
		girlfriend = love.filesystem.load("sprites/pixel/girlfriend.lua")()
		boyfriend.sizeX, boyfriend.sizeY = SCALE, SCALE
		girlfriend.sizeX, girlfriend.sizeY = SCALE, SCALE
		boyfriend.x, boyfriend.y = 50 * SCALE, 30 * SCALE
		girlfriend.x, girlfriend.y = 0, 0

		local iconScale = SCALE
		enemyIcon.sizeX, enemyIcon.sizeY = iconScale, iconScale
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = -iconScale, iconScale
		enemyIcon.baseSizeX, enemyIcon.baseSizeY = enemyIcon.sizeX, enemyIcon.sizeY
		boyfriendIcon.baseSizeX, boyfriendIcon.baseSizeY = boyfriendIcon.sizeX, boyfriendIcon.sizeY
		boyfriendIcon:animate("boyfriend (pixel)", false)

		if songNum ~= 3 then
			local skyImg = love.graphics.newImage(graphics.imagePath("week6/sky"))
			skyImg:setFilter("nearest", "nearest")
			sky = graphics.newImage(skyImg)
			local schoolImg = love.graphics.newImage(graphics.imagePath("week6/school"))
			schoolImg:setFilter("nearest", "nearest")
			school = graphics.newImage(schoolImg)
			local streetImg = love.graphics.newImage(graphics.imagePath("week6/street"))
			streetImg:setFilter("nearest", "nearest")
			street = graphics.newImage(streetImg)
			local treesBackImg = love.graphics.newImage(graphics.imagePath("week6/trees-back"))
			treesBackImg:setFilter("nearest", "nearest")
			treesBack = graphics.newImage(treesBackImg)
			sky.sizeX, sky.sizeY = SCALE, SCALE
			school.sizeX, school.sizeY = SCALE, SCALE
			street.sizeX, street.sizeY = SCALE, SCALE
			treesBack.sizeX, treesBack.sizeY = SCALE, SCALE
			sky.y = 1 * SCALE
			school.y = 1 * SCALE
			street.y = 0
			treesBack.y = 0
			trees = love.filesystem.load("sprites/week6/trees.lua")()
			petals = love.filesystem.load("sprites/week6/petals.lua")()
			freaks = love.filesystem.load("sprites/week6/freaks.lua")()
			trees.sizeX, trees.sizeY = SCALE, SCALE
			petals.sizeX, petals.sizeY = SCALE, SCALE
			freaks.sizeX, freaks.sizeY = SCALE, SCALE
		end
		enemyIcon:animate("senpai", false)
	end,

	leave = function(self)
		_G.isPixelWeek = nil
		sky = nil
		school = nil
		street = nil
		treesBack = nil
		trees = nil
		petals = nil
		freaks = nil
		senpaiCrazy = nil
		ghoulEvents = {}

		weeks:leave()
	end
}