local json  = require("lib.json")
local stage = require("stages.military.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/week7.json"))
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
		inst   = love.audio.newSource("music/" .. fileName .. "/Inst.ogg",   "stream")
		voices = love.audio.newSource("music/" .. fileName .. "/Voices.ogg", "stream")

		self:initUI()

		-- Tank.hx: las 3 canciones tienen su propia cutscene de intro en
		-- Story Mode (isStoryMode && !seenCutscene real -- acá no hace
		-- falta "seenCutscene": como M.load() recarga todo el stage en cada
		-- intento, repetir la cutscene al reintentar es el mismo
		-- comportamiento que Psych real, que también resetea esa bandera
		-- en retry/restart).
		if _G.storyMode then
			stage.startCutscene(song, function() weeks:setupCountdown() end)
		else
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
		weeks:drawUI()
	end,

	loadStage = function(self, songNum, songAppend)
		song       = songNum
		difficulty = songAppend
		-- El zoom (defaultZoom=0.9 de tank.json) ya lo aplica
		-- psychStages.apply() automáticamente dentro de stage.load().
		stage.load(songNum)
	end,

	leave = function(self)
		stage.leave()
		weeks:leave()
	end,
}
