local json  = require("lib.json")
local stage = require("stages.limo.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/week4.json"))
local song, difficulty

local camScaleTimer

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	load = function(self)
		weeks:load()

		local fileName = weekJSON.songs[song][4]
		inst   = love.audio.newSource("music/week4/" .. fileName .. "-inst.ogg",   "stream")
		voices = love.audio.newSource("music/week4/" .. fileName .. "-voices.ogg", "stream")

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

		-- M.I.L.F. camera zoom (entre tiempos 56s-67s)
		if song == 3 and musicTime > 56000 and musicTime < 67000
			and musicThres ~= oldMusicThres
			and math.fmod(absMusicTime, 60000 / bpm) < 100 then
			if camScaleTimer then Timer.cancel(camScaleTimer) end
			camScaleTimer = Timer.tween(
				(60 / bpm) / 16, cam,
				{sizeX = camScale.x * 1.05, sizeY = camScale.y * 1.05}, "out-quad",
				function()
					camScaleTimer = Timer.tween((60 / bpm), cam,
						{sizeX = camScale.x, sizeY = camScale.y}, "out-quad")
				end
			)
		end

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
		if camScaleTimer then Timer.cancel(camScaleTimer); camScaleTimer = nil end
		stage.leave()
		weeks:leave()
	end,
}
