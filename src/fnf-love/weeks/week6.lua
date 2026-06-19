local json  = require("lib.json")
local stage = require("stages.school.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/week6.json"))
local song, difficulty

local PIXEL_ZOOM = 6  -- daPixelZoom real de Psych Engine

-- Detecta la transición true->false de la pre-escena de Thorns DESDE el
-- propio update() de este módulo (no desde dentro de stage.update()), para
-- no anidar self:load() en la pila de llamadas de la pre-escena.
local wasThornsActive = false

-- Asegura que la pre-escena de Thorns se dispare exactamente una vez, sin
-- importar si se entra por Gamestate.switch (que llama a self:enter(), el
-- de este módulo) o por modules/weekLoader.lua (que para Task 2 llama
-- directamente a la función COMPARTIDA weeks.enter(), NUNCA al enter() de
-- este archivo -- por eso antes, entrando por freeplay/story mode normal
-- -vía weekLoader, el camino real-, startThornsIntro() jamás se ejecutaba y
-- Thorns arrancaba directo en schoolEvil sin la pre-escena ni el chart bien
-- inicializado en el momento esperado). Poner el check DENTRO de load() (que
-- SIEMPRE se llama, sea cual sea el camino de entrada) lo hace robusto a
-- ambos casos.
local thornsIntroStarted = false

return {
	-- Declarativo: modules/weekLoader.lua lo lee ANTES de llamar a
	-- weeks.enter() (la función compartida que de hecho CONSUME
	-- _G.isPixelWeek para decidir qué sonidos/imágenes/sprites cargar --
	-- countdown, notas, etc.). Sin esto, weekLoader llama weeks.enter()
	-- ANTES de loadStage()/enter() de este archivo (que son los que seteaban
	-- _G.isPixelWeek=true), así que weeks.enter() siempre veía isPixelWeek
	-- todavía en false/nil y cargaba recursos NORMALES -- explicaba el
	-- countdown pixel roto, los sonidos pixel ausentes y las notas con
	-- coordenadas de frame pixel (chiquitas) leídas sobre la textura normal
	-- (grande) -- de ahí el "aura azul" residual. Y como nunca quedaba
	-- correctamente resoteada a false para la semana normal siguiente,
	-- esa otra semana heredaba isPixelWeek=true -- el cruce reportado.
	isPixelWeek = true,

	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		_G.isPixelWeek = true

		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	load = function(self)
		if stage.isThornsIntroActive() then return end

		if song == 3 and not thornsIntroStarted then
			thornsIntroStarted = true
			wasThornsActive = true
			stage.startThornsIntro()
			return
		end

		weeks:load()

		-- Thorns switches to schoolEvil — reload stage with correct slots
		-- (psychStages.apply() es idempotente, no acumula sobre la posición anterior)
		if song == 3 then
			stage.leave()
			stage.load(3)
		else
			-- Senpai->Roses (misma stage "school", sin reload completo):
			-- resetear igual el estado por-canción (lastBeatNum/freaks), o
			-- las freaks de Roses heredan el conteo de beats de Senpai y se
			-- quedan tiesas hasta que Roses lo supere (a veces nunca).
			stage.resetSongState()
		end

		if song == 2 then
			local angrySound = love.audio.newSource("sounds/week6/ANGRY_TEXT_BOX.ogg", "static")
			angrySound:play()
		end

		local fileName = weekJSON.songs[song][4]
		inst   = love.audio.newSource("music/week6/" .. fileName .. "-inst.ogg",   "stream")
		voices = love.audio.newSource("music/week6/" .. fileName .. "-voices.ogg", "stream")

		self:initUI()
		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		local fileName = weekJSON.songs[song][4]
		weeks:loadChart("data/" .. fileName .. "/" .. fileName .. difficulty)
	end,

	update = function(self, dt)
		stage.update(dt)

		local isThornsActive = stage.isThornsIntroActive()
		if wasThornsActive and not isThornsActive then
			wasThornsActive = false
			self:load()
			return
		end
		wasThornsActive = isThornsActive
		if isThornsActive then return end

		weeks:update(dt)

		if not (countingDown or graphics.isFading()) and weeks.songEnded then
			if _G.storyMode and song < #weekJSON.songs then
				song = song + 1
				_G.currentSongIndex = song
				_G.currentSongName  = _G.weekSongs[song]
				self:load()
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		stage.draw()
		if stage.isThornsIntroActive() then return end
		weeks:drawUI()
	end,

	loadStage = function(self, songNum, songAppend)
		_G.isPixelWeek = true
		song       = songNum
		difficulty = songAppend
		-- thornsIntroStarted es de módulo (persiste entre entradas a week6 en
		-- la misma sesión) -- reiniciar acá para que la pre-escena se vea de
		-- nuevo cada vez que se entra a la semana, no solo la primera.
		thornsIntroStarted = false

		-- Pixel icon scaling
		local iconScale = PIXEL_ZOOM
		enemyIcon.sizeX,   enemyIcon.sizeY   = iconScale, iconScale
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = -iconScale, iconScale
		enemyIcon.baseSizeX,   enemyIcon.baseSizeY   = enemyIcon.sizeX,   enemyIcon.sizeY
		boyfriendIcon.baseSizeX, boyfriendIcon.baseSizeY = boyfriendIcon.sizeX, boyfriendIcon.sizeY

		stage.load(songNum)
	end,

	leave = function(self)
		_G.isPixelWeek = nil
		stage.leave()
		weeks:leave()
	end,
}
