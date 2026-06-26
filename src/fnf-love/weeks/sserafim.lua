-- weeks/sserafim.lua -- colab especial "LE SSERAFIM", canción única
-- "Spaghetti". Estructura mínima a propósito (un solo song, sin progresión
-- multi-canción) -- mismo patrón que weeks/week7.lua, el caso más simple
-- ya existente con cutscene de intro propia del stage (no por video, a
-- diferencia de weekend1).
local json  = require("lib.json")
local stage = require("stages.sserafim.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/sserafim.json"))
local song, difficulty

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	load = function(self)
		weeks:load()

		local fileName = weekJSON.songs[song][4]
		-- Real: Inst.ogg + Voices-sserafim-sakura.ogg (un solo track de
		-- voces para los 5 oponentes que se alternan -- nunca hay swap de
		-- audio por personaje, ver memoria del proyecto). Se copia/renombra
		-- a la convención genérica Voices.ogg de este motor.
		inst   = love.audio.newSource("music/" .. fileName .. "/Inst.ogg",   "stream")
		voices = love.audio.newSource("music/" .. fileName .. "/Voices.ogg", "stream")

		self:initUI()

		-- Cutscene de intro propia del stage (choque de auto + getup,
		-- ver sserafim.hxc:735-903) -- mismo patrón que
		-- stages/military/stage.lua:startCutscene() (semana 7).
		if _G.storyMode then
			stage.startCutscene(song, function() weeks:setupCountdown() end)
		else
			-- BUG corregido: sin cutscene, el polvo/tinte sucio post-choque
			-- (yunjin todavía no pateó la puerta a esta altura de la
			-- canción) nunca se aplicaba en freeplay -- ver comentario
			-- completo en stage.lua:M.applyPostCrashDustState().
			stage.applyPostCrashDustState()
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		local fileName = weekJSON.songs[song][4]
		weeks:loadChart("data/" .. fileName .. "/" .. fileName .. difficulty)
	end,

	update = function(self, dt)
		weeks:update(dt)
		stage.update(dt)

		-- Una sola canción -- no hay progresión a la "próxima canción" de
		-- la semana (a diferencia de week7.lua/weekend1.lua).

		weeks:updateUI(dt)
	end,

	draw = function(self)
		stage.draw()
		-- camHUD.visible=false real durante la cutscene (sserafim.hxc:591)
		-- -- sin esto, el strumline/notas/HUD quedan dibujados ENCIMA de
		-- la cutscene (la simulación ya está congelada por
		-- _G.cutscenePause, pero drawUI() no lo chequea solo).
		if not _G.cutscenePause then
			weeks:drawUI()
		end
	end,

	loadStage = function(self, songNum, songAppend)
		song       = songNum
		difficulty = songAppend
		-- defaultZoom (stages/data/sserafim.json) ya lo aplica
		-- psychStages.apply() automáticamente dentro de stage.load().
		stage.load(songNum)

		-- weeks.lua llama a customNoteHit/customNoteMiss/customEnemyNoteHit
		-- sobre _G.currentWeek directo (NO sobre el módulo de semana) --
		-- mismo patrón que weeks/weekend1.lua:229. Sin esto, los hooks ya
		-- implementados en stages/sserafim/stage.lua (customEnemyNoteHit,
		-- customNoteHit) nunca se llamarían.
		_G.currentWeek = stage
	end,

	leave = function(self)
		_G.currentWeek = nil
		stage.leave()
		weeks:leave()
	end,
}
