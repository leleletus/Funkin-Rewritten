-- Semana "Weekend 1" (Pico vs Darnell) -- reconstruido desde cero contra
-- states/stages/PhillyStreets.hx/PhillyBlazin.hx reales. NO se reusó nada
-- del sistema viejo de Rewritten (movido a _backup_weekend1/).
--
-- Canciones 1-3 (Darnell/Lit Up/2Hot): stage "phillyStreets".
-- Canción 4 (Blazin'): stage "phillyBlazin" (pelea de boxeo).
--
-- Cutscenes (solo story mode):
--   - "darnell" (canción 1): video intro (videos/darnellCutscene.ogv,
--     convertido de .mp4 real con ffmpeg -- LÖVE solo soporta Ogg Theora)
--     seguido de la secuencia escrita en stage.lua:startDarnellCutscene().
--   - "2hot" (canción 3): video outro (videos/2hotCutscene.ogv) antes de
--     pasar a Blazin'.
--   - "blazin" (canción 4, última): video outro (videos/blazinCutscene.ogv)
--     antes del cierre normal de semana (lo maneja weeks.lua genérico).
--
-- NO portado todavía (gap conocido, documentado): noteMissPress -- Psych
-- real dispara una reacción (Pico tira un golpe al aire) cuando el
-- jugador aprieta una tecla sin ninguna nota cerca ("ghost tap" fallido).
-- weeks.lua no expone un hook genérico para ese caso todavía -- el resto
-- de la pelea (notas reales, hit/miss) funciona completo. Tampoco el
-- choreo de cámara de la cutscene de Darnell (ver nota en stage.lua).

local json = require("lib.json")

local stagePhillyStreets = require("stages.phillyStreets.stage")
local stagePhillyBlazin  = require("stages.phillyBlazin.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/weekend1.json"))
local song, difficulty
local stage  -- referencia al stage ACTIVO (phillyStreets o phillyBlazin)

-- Voces separadas jugador/oponente (Voices-Player.ogg/Voices-Opponent.ogg
-- -- convención real de Psych para esta semana, distinta del "Voices.ogg"
-- único que usa el resto del proyecto). Blazin' no tiene voces (canción
-- íntegramente instrumental).
-- GLOBAL (sin local) a propósito: substates/pause.lua necesita pausarla/
-- reanudarla junto con inst/voices (que también son globales) -- ver el
-- guard `if voicesOpponent then` agregado ahí, no afecta otras semanas.
voicesOpponent = nil

-- Persisten entre canciones DENTRO de la misma sesión (require() cachea
-- este módulo) -- mismo criterio que el "seenCutscene" real: no se repite
-- si el jugador reintenta la canción.
local seenDarnellCutscene = false
local shownOutro3, shownOutro4 = false, false

local video, videoPlaying, videoOnEnd = nil, false, nil

local function startVideo(path, onEnd)
	video = love.graphics.newVideo(path)
	video:play()
	videoPlaying = true
	videoOnEnd = onEnd
end

local function stopVideo()
	videoPlaying = false
	if video then
		if video.stop then video:stop()
		elseif video.pause then video:pause() end
		video = nil
	end
end

local function loadSongAudio(fileName)
	inst = love.audio.newSource("music/" .. fileName .. "/Inst.ogg", "stream")

	local okP, vP = pcall(love.audio.newSource, "music/" .. fileName .. "/Voices-Player.ogg", "stream")
	voices = okP and vP or nil

	local okO, vO = pcall(love.audio.newSource, "music/" .. fileName .. "/Voices-Opponent.ogg", "stream")
	voicesOpponent = okO and vO or nil
end

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	load = function(self)
		weeks:load()

		local fileName = weekJSON.songs[song][4]
		loadSongAudio(fileName)

		-- Viz del A-Bot (analizador espectral, ver abot-speaker.lua) --
		-- necesita el Source YA cargado (inst, recién asignado arriba) y
		-- el mismo archivo decodificado aparte como SoundData para poder
		-- leer muestras crudas (un Source en streaming no las expone).
		-- DEBE ir después de loadSongAudio(), no antes -- stage.load() (en
		-- loadStage(), llamado ANTES que este self:load()) corre demasiado
		-- temprano para esto, todavía no existe `inst`.
		if stage.setupAbotAudio then
			stage.setupAbotAudio(fileName)
		end

		-- Blazin' (la pelea de boxeo): solo el carril del jugador centrado,
		-- oponente visible y atenuado cerca del centro. DEBE llamarse ANTES
		-- de initUI() -- esa función es la que LEE middleScroll para
		-- calcular las posiciones/alpha de las flechas; llamarlo DESPUÉS
		-- (como estaba antes) no tenía ningún efecto, porque las
		-- posiciones ya habían quedado calculadas con el valor viejo
		-- (false). middleScroll solo se resetea en weeks:leave() (al
		-- salir de la semana entera), no en cada initUI(), así que el
		-- valor seteado acá persiste correctamente entre canciones.
		weeks:setMiddleScroll(song == 4)
		self:initUI()

		if song == 1 and _G.storyMode and not seenDarnellCutscene then
			seenDarnellCutscene = true
			startVideo("videos/darnellCutscene.ogv", function()
				stage.startDarnellCutscene(function()
					weeks:setupCountdown()
				end)
			end)
		else
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		local fileName = weekJSON.songs[song][4]
		weeks:loadChart("data/" .. fileName .. "/" .. fileName .. difficulty)
	end,

	-- customNoteHit/customNoteMiss/customEnemyNoteHit: NO se definen acá --
	-- _G.currentWeek apunta DIRECTO al stage activo (loadStage() lo
	-- registra), que ya expone esos 3 métodos con la firma exacta que
	-- weeks.lua espera. Evita duplicar la delegación en dos lugares.

	update = function(self, dt)
		if videoPlaying then
			if input:pressed("confirm") or input:pressed("gameBack") then
				stopVideo()
				if videoOnEnd then videoOnEnd() end
				return
			end
			if video and not video:isPlaying() then
				stopVideo()
				if videoOnEnd then videoOnEnd() end
			end
			return
		end

		weeks:update(dt)
		stage.update(dt)

		if voices and voicesOpponent then
			-- Mantener sincronizadas las 2 pistas de voz -- ambas arrancan/
			-- paran junto con weeks.lua's manejo normal de `voices`
			-- (countdown, pausa, fin de canción). No hay forma de
			-- "engancharse" a esos puntos sin tocar weeks.lua, así que se
			-- replica el estado de isPlaying() cuadro a cuadro (barato).
			if voices:isPlaying() and not voicesOpponent:isPlaying() then
				voicesOpponent:play()
			elseif not voices:isPlaying() and voicesOpponent:isPlaying() then
				voicesOpponent:stop()
			end
		end

		if not (countingDown or graphics.isFading()) and weeks.songEnded then
			if _G.storyMode and song == 3 and not shownOutro3 then
				shownOutro3 = true
				startVideo("videos/2hotCutscene.ogv", function()
					song = song + 1
					_G.currentSongIndex = song
					_G.currentSongName  = _G.weekSongs[song]
					self:loadStage(song, difficulty)
					self:load()
				end)
			elseif _G.storyMode and song == 4 and not shownOutro4 then
				shownOutro4 = true
				-- Última canción: tras el video, NO se avanza nada acá --
				-- se deja que el próximo update() llame weeks:update(dt)
				-- de nuevo, que detecta songEnded (sigue true) y maneja
				-- el cierre genérico de semana por su cuenta.
				startVideo("videos/blazinCutscene.ogv", function() end)
			elseif _G.storyMode and song < #weekJSON.songs then
				song = song + 1
				_G.currentSongIndex = song
				_G.currentSongName  = _G.weekSongs[song]
				self:loadStage(song, difficulty)
				self:load()
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		if videoPlaying and video then
			love.graphics.push()
			love.graphics.origin()
			local vw, vh = love.graphics.getDimensions()
			local sw, sh = video:getWidth(), video:getHeight()
			love.graphics.draw(video, 0, 0, 0, vw / sw, vh / sh)
			love.graphics.pop()
			return
		end

		stage.draw()
		weeks:drawUI()
	end,

	loadStage = function(self, songNum, songAppend)
		song       = songNum
		difficulty = songAppend

		if stage then stage.leave() end

		if song == 4 then
			stage = stagePhillyBlazin
		else
			stage = stagePhillyStreets
		end

		-- Nombre file-safe ("darnell"/"lit-up"/"2hot"/"blazin", índice [4]
		-- de weekJSON.songs) -- _G.currentSongName puede contener el
		-- nombre de DISPLAY ("Lit Up") según quién lo haya seteado, no es
		-- seguro para comparar contra los switch-case de
		-- PhillyStreets.hx:setupRainShader() (shader de lluvia, ver
		-- M.load()). Se pasa explícito en vez de adivinarlo adentro.
		stage.load(weekJSON.songs[song][4])
		_G.currentWeek = stage
	end,

	leave = function(self)
		stopVideo()
		if voicesOpponent then voicesOpponent:stop() end
		voicesOpponent = nil
		_G.currentWeek = nil
		stage.leave()
		weeks:leave()
		-- BUG corregido: seenDarnellCutscene/shownOutro3/4 son locals de
		-- módulo (require() los cachea para toda la sesión del proceso) --
		-- nunca se resetaban, así que después de la PRIMERA vez que se
		-- intentaba la cutscene (incluso si fallaba o el jugador volvía al
		-- menú), nunca más se volvía a disparar sin cerrar el juego
		-- entero. Se resetean acá porque "salir de la semana del todo" es
		-- un punto razonable para considerar la próxima entrada como un
		-- intento nuevo.
		seenDarnellCutscene = false
		shownOutro3, shownOutro4 = false, false
	end,
}
