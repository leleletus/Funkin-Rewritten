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

local big_numbers_clear = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("resultsScreen/big numbers clear")),
	{
		{x = 0, y = 0, width = 86, height = 87, offsetX = 0, offsetY = 0, offsetWidth = 86, offsetHeight = 87}, -- 1: 0a big0000
		{x = 86, y = 0, width = 80, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 80, offsetHeight = 90}, -- 2: 0b big0000
		{x = 166, y = 0, width = 63, height = 89, offsetX = 0, offsetY = 0, offsetWidth = 63, offsetHeight = 89}, -- 3: 1a big0000
		{x = 229, y = 0, width = 61, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 61, offsetHeight = 88}, -- 4: 1b big0000
		{x = 290, y = 0, width = 75, height = 84, offsetX = 0, offsetY = 0, offsetWidth = 75, offsetHeight = 84}, -- 5: 2a big0000
		{x = 365, y = 0, width = 74, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 74, offsetHeight = 88}, -- 6: 2b big0000
		{x = 0, y = 90, width = 76, height = 83, offsetX = 0, offsetY = 0, offsetWidth = 76, offsetHeight = 83}, -- 7: 3a big0000
		{x = 76, y = 90, width = 77, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 88}, -- 8: 3b big0000
		{x = 153, y = 90, width = 77, height = 84, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 84}, -- 9: 4a big0000
		{x = 230, y = 90, width = 78, height = 86, offsetX = 0, offsetY = 0, offsetWidth = 78, offsetHeight = 86}, -- 10: 4b big0000
		{x = 308, y = 90, width = 79, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 88}, -- 11: 5a big0000
		{x = 387, y = 90, width = 79, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 90}, -- 12: 5b big0000
		{x = 0, y = 180, width = 75, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 75, offsetHeight = 88}, -- 13: 6a big0000
		{x = 75, y = 180, width = 74, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 74, offsetHeight = 88}, -- 14: 6b big0000
		{x = 149, y = 180, width = 79, height = 84, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 84}, -- 15: 7a big0000
		{x = 228, y = 180, width = 74, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 74, offsetHeight = 85}, -- 16: 7b big0000
		{x = 302, y = 180, width = 79, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 90}, -- 17: 8a big0000
		{x = 381, y = 180, width = 77, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 90}, -- 18: 8b big0000
		{x = 0, y = 270, width = 79, height = 87, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 87}, -- 19: 9a big0000
		{x = 79, y = 270, width = 77, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 88}, -- 20: 9b big0000
		{x = 156, y = 270, width = 251, height = 159, offsetX = 0, offsetY = 0, offsetWidth = 251, offsetHeight = 159}, -- 21: CLEAR PERCENT TEXT0000
		{x = 156, y = 270, width = 251, height = 159, offsetX = 0, offsetY = 0, offsetWidth = 251, offsetHeight = 159} -- 22: CLEAR PERCENT TEXT0001
	},
	{
		["0a big"] = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
		["0b big"] = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
		["1a big"] = {start = 3, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
		["1b big"] = {start = 4, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
		["2a big"] = {start = 5, stop = 5, speed = 24, offsetX = 0, offsetY = 0},
		["2b big"] = {start = 6, stop = 6, speed = 24, offsetX = 0, offsetY = 0},
		["3a big"] = {start = 7, stop = 7, speed = 24, offsetX = 0, offsetY = 0},
		["3b big"] = {start = 8, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["4a big"] = {start = 9, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["4b big"] = {start = 10, stop = 10, speed = 24, offsetX = 0, offsetY = 0},
		["5a big"] = {start = 11, stop = 11, speed = 24, offsetX = 0, offsetY = 0},
		["5b big"] = {start = 12, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
		["6a big"] = {start = 13, stop = 13, speed = 24, offsetX = 0, offsetY = 0},
		["6b big"] = {start = 14, stop = 14, speed = 24, offsetX = 0, offsetY = 0},
		["7a big"] = {start = 15, stop = 15, speed = 24, offsetX = 0, offsetY = 0},
		["7b big"] = {start = 16, stop = 16, speed = 24, offsetX = 0, offsetY = 0},
		["8a big"] = {start = 17, stop = 17, speed = 24, offsetX = 0, offsetY = 0},
		["8b big"] = {start = 18, stop = 18, speed = 24, offsetX = 0, offsetY = 0},
		["9a big"] = {start = 19, stop = 19, speed = 24, offsetX = 0, offsetY = 0},
		["9b big"] = {start = 20, stop = 20, speed = 24, offsetX = 0, offsetY = 0},
		["CLEAR PERCENT TEXT"] = {start = 21, stop = 22, speed = 24, offsetX = 0, offsetY = 0}
	},
	"0a big"
)

return big_numbers_clear
