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

local sakuraA = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sserafim/char/sakuraA")),
	{
		{x = 1976, y = 628, width = 383, height = 628, offsetX = -373, offsetY = -55, offsetWidth = 1280, offsetHeight = 720}, -- 1: idle0000
		{x = 0, y = 1846, width = 382, height = 628, offsetX = -374, offsetY = -55, offsetWidth = 1280, offsetHeight = 720}, -- 2: idle0001
		{x = 799, y = 0, width = 394, height = 621, offsetX = -363, offsetY = -63, offsetWidth = 1280, offsetHeight = 720}, -- 3: idle0002
		{x = 404, y = 0, width = 395, height = 621, offsetX = -362, offsetY = -62, offsetWidth = 1280, offsetHeight = 720}, -- 4: idle0003
		{x = 1193, y = 0, width = 390, height = 627, offsetX = -367, offsetY = -57, offsetWidth = 1280, offsetHeight = 720}, -- 5: idle0004
		{x = 1976, y = 0, width = 386, height = 628, offsetX = -371, offsetY = -56, offsetWidth = 1280, offsetHeight = 720}, -- 6: idle0005
		{x = 1976, y = 0, width = 386, height = 628, offsetX = -371, offsetY = -56, offsetWidth = 1280, offsetHeight = 720}, -- 7: idle0006
		{x = 1976, y = 0, width = 386, height = 628, offsetX = -371, offsetY = -56, offsetWidth = 1280, offsetHeight = 720}, -- 8: idle0007
		{x = 0, y = 0, width = 404, height = 608, offsetX = -355, offsetY = -75, offsetWidth = 1280, offsetHeight = 720}, -- 9: down0000
		{x = 787, y = 1226, width = 398, height = 611, offsetX = -360, offsetY = -72, offsetWidth = 1280, offsetHeight = 720}, -- 10: down0001
		{x = 2362, y = 613, width = 395, height = 613, offsetX = -362, offsetY = -70, offsetWidth = 1280, offsetHeight = 720}, -- 11: down0002
		{x = 2362, y = 0, width = 395, height = 613, offsetX = -362, offsetY = -70, offsetWidth = 1280, offsetHeight = 720}, -- 12: down0003
		{x = 0, y = 608, width = 397, height = 618, offsetX = -360, offsetY = -65, offsetWidth = 1280, offsetHeight = 720}, -- 13: left0000
		{x = 393, y = 1226, width = 394, height = 618, offsetX = -363, offsetY = -65, offsetWidth = 1280, offsetHeight = 720}, -- 14: left0001
		{x = 1583, y = 0, width = 393, height = 620, offsetX = -364, offsetY = -63, offsetWidth = 1280, offsetHeight = 720}, -- 15: left0002
		{x = 0, y = 1226, width = 393, height = 620, offsetX = -364, offsetY = -63, offsetWidth = 1280, offsetHeight = 720}, -- 16: left0003
		{x = 1456, y = 2474, width = 361, height = 630, offsetX = -396, offsetY = -53, offsetWidth = 1280, offsetHeight = 720}, -- 17: right0000
		{x = 364, y = 2474, width = 364, height = 631, offsetX = -393, offsetY = -52, offsetWidth = 1280, offsetHeight = 720}, -- 18: right0001
		{x = 728, y = 2474, width = 364, height = 631, offsetX = -393, offsetY = -52, offsetWidth = 1280, offsetHeight = 720}, -- 19: right0002
		{x = 1092, y = 2474, width = 364, height = 631, offsetX = -393, offsetY = -52, offsetWidth = 1280, offsetHeight = 720}, -- 20: right0003
		{x = 0, y = 2474, width = 364, height = 645, offsetX = -391, offsetY = -39, offsetWidth = 1280, offsetHeight = 720}, -- 21: up0000
		{x = 2757, y = 1285, width = 369, height = 643, offsetX = -386, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 22: up0001
		{x = 2757, y = 0, width = 370, height = 643, offsetX = -385, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 23: up0002
		{x = 2757, y = 643, width = 370, height = 642, offsetX = -385, offsetY = -41, offsetWidth = 1280, offsetHeight = 720}, -- 24: up0003
	},
	{
		["idle"] = {start = 1, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["down"] = {start = 9, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 13, stop = 16, speed = 24, offsetX = 0, offsetY = 0},
		["right"] = {start = 17, stop = 20, speed = 24, offsetX = 0, offsetY = 0},
		["up"] = {start = 21, stop = 24, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return sakuraA