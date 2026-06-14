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
local icons = require("sprites.icons")
local song, difficulty

local walls, escalator, christmasTree, snow

local topBop, bottomBop, santa

local scaryIntro = false

local misses = 0

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 3 then
			camScale.x, camScale.y = 0.9, 0.9

			if scaryIntro then
				cam.x, cam.y = -150, 750
				cam.sizeX, cam.sizeY = 2.5, 2.5

				graphics.setFade(1)
			else
				cam.sizeX, cam.sizeY = 0.9, 0.9
			end

			walls = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/evil-bg")))
			christmasTree = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/evil-tree")))
			snow = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/evil-snow")))

			walls.y = -250
			christmasTree.x = 75
			christmasTree.sizeX, christmasTree.sizeY = 0.5, 0.5
			snow.x, snow.y = -50, 770

			enemy = love.filesystem.load("sprites/week5/monster.lua")()

			enemy.x, enemy.y = -780, 420

			enemyIcon:animate("monster", false)

			inst = love.audio.newSource("music/week5/winter-horrorland-inst.ogg", "stream")
			voices = love.audio.newSource("music/week5/winter-horrorland-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/week5/eggnog-inst.ogg", "stream")
			voices = love.audio.newSource("music/week5/eggnog-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week5/cocoa-inst.ogg", "stream")
			voices = love.audio.newSource("music/week5/cocoa-voices.ogg", "stream")
		end

		self:initUI()

		if scaryIntro then
			Timer.after(
				5,
				function()
					scaryIntro = false

					camTimer = Timer.tween(2, cam, {x = -boyfriend.x + 100, y = -boyfriend.y + 75, sizeX = 0.9, sizeY = 0.9}, "out-quad")

					weeks:setupCountdown()
				end
			)

			audio.playSound(sounds.lightsOn)
		else
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes(love.filesystem.load("charts/week5/winter-horrorland" .. difficulty .. ".lua")())
		elseif song == 2 then
			weeks:generateNotes(love.filesystem.load("charts/week5/eggnog" .. difficulty .. ".lua")())
		else
			weeks:generateNotes(love.filesystem.load("charts/week5/cocoa" .. difficulty .. ".lua")())
		end
	end,

	update = function(self, dt)
		if not scaryIntro then
			weeks:update(dt)

			if song ~= 3 then
				topBop:update(dt)
				bottomBop:update(dt)
				santa:update(dt)

				if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
					topBop:animate("anim", false)
					bottomBop:animate("anim", false)
					santa:animate("anim", false)
				end
			end

			if not (scaryIntro or countingDown or graphics.isFading()) and weeks.songEnded then
				if _G.storyMode and song < 3 then
					song = song + 1
					_G.currentSongIndex = song
					_G.currentSongName = _G.weekSongs[song]

					-- Winter Horrorland setup
					if song == 3 then
						scaryIntro = true

						audio.playSound(sounds.lightsOff)

						graphics.setFade(0)

						Timer.after(3, function() self:load() end)
					else
						self:load()
					end
				end
			end

			weeks:updateUI(dt)
		end
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x * 0.5, cam.y * 0.5)

				walls:draw()
				if song ~= 3 then
					topBop:draw()
					escalator:draw()
				end
				christmasTree:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

				if song ~= 3 then
					bottomBop:draw()
				end

				snow:draw()

				girlfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

				if song ~= 3 then
					santa:draw()
				end
				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 1.1, cam.y * 1.1)
			love.graphics.pop()
			weeks:drawRating(0.9)
		love.graphics.pop()

		if not scaryIntro then
			weeks:drawUI()
		end
	end,


	loadStage = function(self, songNum, songAppend)
		local icons = require("sprites.icons")
		cam.sizeX, cam.sizeY = 0.7, 0.7
		camScale.x, camScale.y = 0.7, 0.7
		bpm = 100
		useAltAnims = false
		enemyFrameTimer = 0
		boyfriendFrameTimer = 0

		sounds = {
			countdown = {
				three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
				two = love.audio.newSource("sounds/countdown-2.ogg", "static"),
				one = love.audio.newSource("sounds/countdown-1.ogg", "static"),
				go = love.audio.newSource("sounds/countdown-go.ogg", "static")
			},
			miss = {
				love.audio.newSource("sounds/miss1.ogg", "static"),
				love.audio.newSource("sounds/miss2.ogg", "static"),
				love.audio.newSource("sounds/miss3.ogg", "static")
			},
			death = love.audio.newSource("sounds/death.ogg", "static"),
			lightsOff = love.audio.newSource("sounds/week5/lights-off.ogg", "static"),
			lightsOn = love.audio.newSource("sounds/week5/lights-on.ogg", "static")
		}
		images = {
			icons = love.graphics.newImage(graphics.imagePath("icons")),
			notes = love.graphics.newImage(graphics.imagePath("notes")),
			numbers = love.graphics.newImage(graphics.imagePath("numbers")),
			noteSplashes = love.graphics.newImage(graphics.imagePath("noteSplashes"))
		}
		images.timeBar = love.graphics.newImage(graphics.imagePath("timeBar"))
		sprites = { numbers = love.filesystem.load("sprites/numbers.lua") }

		song = songNum
		difficulty = songAppend

		if songNum ~= 3 then
			walls = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/walls")))
			escalator = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/escalator")))
			christmasTree = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/christmas-tree")))
			snow = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/snow")))
			escalator.x = 125
			christmasTree.x = 75
			snow.y = 850
			snow.sizeX, snow.sizeY = 2, 2
			topBop = love.filesystem.load("sprites/week5/top-bop.lua")()
			bottomBop = love.filesystem.load("sprites/week5/bottom-bop.lua")()
			santa = love.filesystem.load("sprites/week5/santa.lua")()
			topBop.x, topBop.y = 60, -250
			bottomBop.x, bottomBop.y = -75, 375
			santa.x, santa.y = -1350, 410
		end

		girlfriend = love.filesystem.load("sprites/week5/girlfriend.lua")()
		enemy = love.filesystem.load("sprites/week5/dearest-duo.lua")()
		boyfriend = love.filesystem.load("sprites/week5/boyfriend.lua")()
		fakeBoyfriend = love.filesystem.load("sprites/boyfriend.lua")()
		rating = love.filesystem.load("sprites/rating.lua")()

		girlfriend.x, girlfriend.y = -50, 410
		enemy.x, enemy.y = -780, 410
		boyfriend.x, boyfriend.y = 300, 620
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 620
		_G.deathBoyfriend = fakeBoyfriend
		rating.sizeX, rating.sizeY = 0.75, 0.75
		numbers = {}
		for i = 1, 3 do
			numbers[i] = sprites.numbers()
			numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5
		end

		enemyIcon = icons.create()
		boyfriendIcon = icons.create()
		if settings.downscroll then
			enemyIcon.y = -400
			boyfriendIcon.y = -400
		else
			enemyIcon.y = 400
			boyfriendIcon.y = 400
		end
		enemyIcon.sizeX, enemyIcon.sizeY = 1.5, 1.5
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = -1.5, 1.5
		countdownFade = {}
		countdown = love.filesystem.load("sprites/countdown.lua")()
		enemyIcon:animate("dearest duo", false)
	end,

	leave = function()
		walls = nil
		escalator = nil

		santa = nil
		_G.deathBoyfriend = nil
		weeks:leave()
	end
}