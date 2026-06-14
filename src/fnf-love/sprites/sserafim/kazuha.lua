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


local kazuha = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sserafim/char/kazuha")),
	{
		{x = 1021, y = 657, width = 321, height = 635, offsetX = -423, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 1: idle0000
		{x = 2286, y = 1268, width = 322, height = 631, offsetX = -418, offsetY = -44, offsetWidth = 1280, offsetHeight = 720}, -- 2: idle0001
		{x = 2286, y = 0, width = 322, height = 633, offsetX = -420, offsetY = -42, offsetWidth = 1280, offsetHeight = 720}, -- 3: idle0002
		{x = 2286, y = 633, width = 320, height = 635, offsetX = -422, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 4: idle0003
		{x = 0, y = 1963, width = 319, height = 636, offsetX = -423, offsetY = -39, offsetWidth = 1280, offsetHeight = 720}, -- 5: idle0004
		{x = 319, y = 1963, width = 319, height = 635, offsetX = -423, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 6: idle0005
		{x = 0, y = 0, width = 344, height = 645, offsetX = -397, offsetY = -54, offsetWidth = 1280, offsetHeight = 720}, -- 7: down0000
		{x = 0, y = 645, width = 339, height = 647, offsetX = -400, offsetY = -52, offsetWidth = 1280, offsetHeight = 720}, -- 8: down0001
		{x = 344, y = 0, width = 338, height = 648, offsetX = -401, offsetY = -51, offsetWidth = 1280, offsetHeight = 720}, -- 9: down0002
		{x = 1973, y = 0, width = 313, height = 657, offsetX = -415, offsetY = -42, offsetWidth = 1280, offsetHeight = 720}, -- 10: left0000
		{x = 1021, y = 0, width = 322, height = 657, offsetX = -412, offsetY = -42, offsetWidth = 1280, offsetHeight = 720}, -- 11: left0001
		{x = 682, y = 628, width = 323, height = 657, offsetX = -411, offsetY = -42, offsetWidth = 1280, offsetHeight = 720}, -- 12: left0002
		{x = 682, y = 0, width = 339, height = 628, offsetX = -417, offsetY = -47, offsetWidth = 1280, offsetHeight = 720}, -- 13: right0000
		{x = 344, y = 648, width = 333, height = 632, offsetX = -418, offsetY = -43, offsetWidth = 1280, offsetHeight = 720}, -- 14: right0001
		{x = 312, y = 1292, width = 331, height = 632, offsetX = -419, offsetY = -43, offsetWidth = 1280, offsetHeight = 720}, -- 15: right0002
		{x = 0, y = 1292, width = 312, height = 671, offsetX = -424, offsetY = -28, offsetWidth = 1280, offsetHeight = 720}, -- 16: up0000
		{x = 1343, y = 0, width = 315, height = 669, offsetX = -420, offsetY = -30, offsetWidth = 1280, offsetHeight = 720}, -- 17: up0001
		{x = 1658, y = 0, width = 315, height = 668, offsetX = -420, offsetY = -31, offsetWidth = 1280, offsetHeight = 720}, -- 18: up0002
	},
	{
		["idle"] = {start = 1, stop = 6, speed = 12, offsetX = 0, offsetY = 0},
		["down"] = {start = 7, stop = 9, speed = 12, offsetX = -5, offsetY = 25},
		["left"] = {start = 10, stop = 12, speed = 12, offsetX = -5, offsetY = 25},
		["right"] = {start = 13, stop = 15, speed = 12, offsetX = 0, offsetY = 0},
		["up"] = {start = 16, stop = 18, speed = 12, offsetX = 0, offsetY = 25},
	},
	"idle"
)

return kazuha
