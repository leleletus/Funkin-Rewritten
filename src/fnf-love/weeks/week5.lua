local json  = require("lib.json")
local stage = require("stages.mall.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/week5.json"))
local song, difficulty

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	load = function(self)
		weeks:load()

		-- Song 3 changes stage and enemy — reload stage with new slots
		-- (psychStages.apply() es idempotente, no acumula sobre la posición anterior)
		if song == 3 then
			stage.leave()
			stage.load(3)
		end

		local fileName = weekJSON.songs[song][4]
		inst   = love.audio.newSource("music/" .. fileName .. "/Inst.ogg",   "stream")
		voices = love.audio.newSource("music/" .. fileName .. "/Voices.ogg", "stream")

		self:initUI()

		if song == 3 then
			stage.startEvilTransition(function()
				weeks:setupCountdown()
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

		-- El zoom (defaultZoom de mall.json/mallEvil.json) ya lo aplica
		-- psychStages.apply() automáticamente dentro de stage.load().
		stage.load(songNum)
	end,

	leave = function(self)
		stage.leave()
		weeks:leave()
	end,
}
