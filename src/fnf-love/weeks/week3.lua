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

local sky, city, cityWindows, behindTrain, street
local winColors, winColor
local heyTimes, heyTriggered

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 3 then
			inst = love.audio.newSource("music/week3/blammed-inst.ogg", "stream")
			voices = love.audio.newSource("music/week3/blammed-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/week3/philly-nice-inst.ogg", "stream")
			voices = love.audio.newSource("music/week3/philly-nice-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week3/pico-inst.ogg", "stream")
			voices = love.audio.newSource("music/week3/pico-voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:loadChart("charts/week3/blammed" .. difficulty)
		elseif song == 2 then
			weeks:loadChart("charts/week3/philly-nice" .. difficulty)
		else
			weeks:loadChart("charts/week3/pico" .. difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)

		if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 240000 / bpm) < 100 then
			winColor = winColor + 1

			if winColor > 5 then
				winColor = 1
			end
		end

		if song == 2 and not countingDown and not paused then
			for i, t in ipairs(heyTimes) do
				if not heyTriggered[i] and math.abs(absMusicTime - t) < 100 then
					-- Animación de Boyfriend
					boyfriend:animate("hey", false)
					local bfAnim = boyfriend.anims["hey"]
					if bfAnim then
						local bfDuration = (bfAnim.stop - bfAnim.start + 1) / bfAnim.speed
						weeks:setSpriteTimer(3, 999999)
						Timer.after(bfDuration, function()
							weeks:setSpriteTimer(3, 0)    -- Restaura para próximo idle
						end)
					end

					girlfriend:animate("cheer", false)
					local gfAnim = girlfriend.anims["cheer"]
					if gfAnim then
						local gfDuration = (gfAnim.stop - gfAnim.start + 1) / gfAnim.speed
						weeks:setSpriteTimer(1, 999999)
						Timer.after(gfDuration, function()
							weeks:setSpriteTimer(1, 0)
						end)
					end

					heyTriggered[i] = true
				end
			end
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
		local curWinColor = winColors[winColor]

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x * 0.25, cam.y * 0.25)

				sky:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 0.5, cam.y * 0.5)

				city:draw()
				graphics.setColor(curWinColor[1] / 255, curWinColor[2] / 255, curWinColor[3] / 255)
				cityWindows:draw()
				graphics.setColor(1, 1, 1)
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

				behindTrain:draw()
				street:draw()

				girlfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()
			weeks:drawRating(0.9)
		love.graphics.pop()

		weeks:drawUI()
	end,

	loadStage = function(self, songNum, songAppend)
		song = songNum
		difficulty = songAppend

		cam.sizeX, cam.sizeY = 1, 1
		camScale.x, camScale.y = 1, 1

		winColors = {
			{49, 162, 253}, {49, 253, 140}, {251, 51, 245}, {253, 69, 49}, {251, 166, 51},
		}
		winColor = 1

		if songNum == 2 then
			heyTimes = {13714.2857142857, 24685.7142857143, 35657.1428571429, 46628.5714285714, 57600, 79542.8571428571}
			heyTriggered = {}
		end

		sky = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/sky")))
		city = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/city")))
		cityWindows = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/city-windows")))
		behindTrain = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/behind-train")))
		street = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/street")))

		behindTrain.y = -100
		behindTrain.sizeX, behindTrain.sizeY = 1.25, 1.25
		street.y = -100
		street.sizeX, street.sizeY = 1.25, 1.25

		enemy = love.filesystem.load("sprites/week3/pico-enemy.lua")()

		girlfriend.x, girlfriend.y = -70, -140
		enemy.x, enemy.y = -480, 50
		enemy.sizeX = -1
		boyfriend.x, boyfriend.y = 165, 50

		enemyIcon:animate("pico", false)
	end,

	leave = function(self)
	end,
}