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

local json  = require("lib.json")
local stage = require("stages.stage.stage")

local weekJSON = json.decode(love.filesystem.read("weeks/week1.json"))
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
			if _G.storyMode and song < 3 then
				song = song + 1
				_G.currentSongIndex = song
				_G.currentSongName  = _G.weekSongs[song]
				self:load()
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		stage.draw()    -- fondos, personajes, efectos (incluye weeks:drawRating())
		weeks:drawUI()  -- HUD, notas, UI de juego
	end,

	loadStage = function(self, songNum, songAppend)
		song       = songNum
		difficulty = songAppend
		-- Personajes ya cargados por weekLoader (player1/player2/gfVersion del chart).
		stage.load()
	end,

	leave = function(self)
		stage.leave()
		weeks:leave()
	end,
}
