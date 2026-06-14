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


local yunjin = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sserafim/char/yunjin")),
	{
		{x = 1965, y = 2090, width = 657, height = 677, offsetX = -263, offsetY = -33, offsetWidth = 1280, offsetHeight = 720}, -- 1: idle0000
		{x = 3268, y = 0, width = 657, height = 677, offsetX = -263, offsetY = -33, offsetWidth = 1280, offsetHeight = 720}, -- 2: idle0001
		{x = 1310, y = 2090, width = 655, height = 683, offsetX = -264, offsetY = -27, offsetWidth = 1280, offsetHeight = 720}, -- 3: idle0002
		{x = 0, y = 2090, width = 655, height = 684, offsetX = -264, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 4: idle0003
		{x = 655, y = 2090, width = 655, height = 684, offsetX = -264, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 5: idle0004
		{x = 655, y = 2090, width = 655, height = 684, offsetX = -264, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 6: idle0005
		{x = 655, y = 2090, width = 655, height = 684, offsetX = -264, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 7: idle0006
		{x = 1980, y = 2774, width = 661, height = 669, offsetX = -260, offsetY = -41, offsetWidth = 1280, offsetHeight = 720}, -- 8: down0000
		{x = 1320, y = 2774, width = 660, height = 672, offsetX = -261, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 9: down0001
		{x = 0, y = 2774, width = 660, height = 673, offsetX = -261, offsetY = -37, offsetWidth = 1280, offsetHeight = 720}, -- 10: down0002
		{x = 660, y = 2774, width = 660, height = 673, offsetX = -261, offsetY = -37, offsetWidth = 1280, offsetHeight = 720}, -- 11: down0003
		{x = 656, y = 702, width = 656, height = 690, offsetX = -263, offsetY = -20, offsetWidth = 1280, offsetHeight = 720}, -- 12: left0000
		{x = 1304, y = 0, width = 656, height = 691, offsetX = -264, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 13: left0001
		{x = 648, y = 0, width = 656, height = 691, offsetX = -264, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 14: left0002
		{x = 0, y = 702, width = 656, height = 691, offsetX = -264, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 15: left0003
		{x = 2609, y = 0, width = 659, height = 685, offsetX = -261, offsetY = -25, offsetWidth = 1280, offsetHeight = 720}, -- 16: right0000
		{x = 1298, y = 1393, width = 659, height = 686, offsetX = -261, offsetY = -24, offsetWidth = 1280, offsetHeight = 720}, -- 17: right0001
		{x = 2609, y = 1371, width = 657, height = 686, offsetX = -262, offsetY = -24, offsetWidth = 1280, offsetHeight = 720}, -- 18: right0002
		{x = 2609, y = 685, width = 657, height = 686, offsetX = -262, offsetY = -24, offsetWidth = 1280, offsetHeight = 720}, -- 19: right0003
		{x = 0, y = 0, width = 648, height = 702, offsetX = -265, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 20: up0000
		{x = 0, y = 1393, width = 649, height = 697, offsetX = -265, offsetY = -15, offsetWidth = 1280, offsetHeight = 720}, -- 21: up0001
		{x = 649, y = 1393, width = 649, height = 697, offsetX = -265, offsetY = -15, offsetWidth = 1280, offsetHeight = 720}, -- 22: up0002
		{x = 1960, y = 0, width = 649, height = 697, offsetX = -265, offsetY = -15, offsetWidth = 1280, offsetHeight = 720}, -- 23: up0003
	},
	{
		["idle"] = {start = 1, stop = 7, speed = 12, offsetX = 0, offsetY = 0},
		["down"] = {start = 8, stop = 11, speed = 12, offsetX = 0, offsetY = 0},
		["left"] = {start = 12, stop = 15, speed = 12, offsetX = 0, offsetY = 0},
		["right"] = {start = 16, stop = 19, speed = 12, offsetX = 0, offsetY = 0},
		["up"] = {start = 20, stop = 23, speed = 12, offsetX = 0, offsetY = 0},
	},
	"idle"
)

return yunjin
