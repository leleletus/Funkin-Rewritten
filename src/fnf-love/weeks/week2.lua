local json  = require("lib.json")
local stage = require("stages.spooky.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/week2.json"))
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
		inst   = love.audio.newSource("music/week2/" .. fileName .. "-inst.ogg",   "stream")
		voices = love.audio.newSource("music/week2/" .. fileName .. "-voices.ogg", "stream")

		self:initUI()
		weeks:setupCountdown()
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
		stage.load(songNum)
	end,

	leave = function(self)
		stage.leave()
		weeks:leave()
	end,
}
