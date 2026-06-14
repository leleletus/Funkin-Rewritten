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

local results_ranking_assets_v2 = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("resultsScreen/results ranking assets v2")),
	{
		{x = 0, y = 0, width = 86, height = 87, offsetX = 0, offsetY = 0, offsetWidth = 86, offsetHeight = 87}, -- 1: 0a big0000
		{x = 86, y = 0, width = 80, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 80, offsetHeight = 90}, -- 2: 0b big0000
		{x = 166, y = 0, width = 63, height = 89, offsetX = 0, offsetY = 0, offsetWidth = 63, offsetHeight = 89}, -- 3: 1a big0000
		{x = 229, y = 0, width = 61, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 61, offsetHeight = 88}, -- 4: 1b big0000
		{x = 290, y = 0, width = 75, height = 84, offsetX = 0, offsetY = 0, offsetWidth = 75, offsetHeight = 84}, -- 5: 2a big0000
		{x = 365, y = 0, width = 74, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 74, offsetHeight = 88}, -- 6: 2b big0000
		{x = 439, y = 0, width = 76, height = 83, offsetX = 0, offsetY = 0, offsetWidth = 76, offsetHeight = 83}, -- 7: 3a big0000
		{x = 515, y = 0, width = 77, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 88}, -- 8: 3b big0000
		{x = 592, y = 0, width = 77, height = 84, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 84}, -- 9: 4a big0000
		{x = 669, y = 0, width = 78, height = 86, offsetX = 0, offsetY = 0, offsetWidth = 78, offsetHeight = 86}, -- 10: 4b big0000
		{x = 747, y = 0, width = 79, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 88}, -- 11: 5a big0000
		{x = 826, y = 0, width = 79, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 90}, -- 12: 5b big0000
		{x = 905, y = 0, width = 75, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 75, offsetHeight = 88}, -- 13: 6a big0000
		{x = 980, y = 0, width = 74, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 74, offsetHeight = 88}, -- 14: 6b big0000
		{x = 1054, y = 0, width = 79, height = 84, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 84}, -- 15: 7a big0000
		{x = 1133, y = 0, width = 74, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 74, offsetHeight = 85}, -- 16: 7b big0000
		{x = 1207, y = 0, width = 79, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 90}, -- 17: 8a big0000
		{x = 1286, y = 0, width = 77, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 90}, -- 18: 8b big0000
		{x = 1363, y = 0, width = 79, height = 87, offsetX = 0, offsetY = 0, offsetWidth = 79, offsetHeight = 87}, -- 19: 9a big0000
		{x = 1442, y = 0, width = 77, height = 88, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 88}, -- 20: 9b big0000
		{x = 1519, y = 0, width = 251, height = 159, offsetX = 0, offsetY = 0, offsetWidth = 251, offsetHeight = 159}, -- 21: CLEAR PERCENT TEXT0000
		{x = 1519, y = 0, width = 251, height = 159, offsetX = 0, offsetY = 0, offsetWidth = 251, offsetHeight = 159}, -- 22: CLEAR PERCENT TEXT0001
		{x = 1770, y = 0, width = 1049, height = 144, offsetX = 0, offsetY = 0, offsetWidth = 1049, offsetHeight = 144}, -- 23: EXCELLENT BG SCROLL0000
		{x = 2819, y = 0, width = 380, height = 634, offsetX = 0, offsetY = 0, offsetWidth = 380, offsetHeight = 634}, -- 24: GOOD0000
		{x = 3199, y = 0, width = 489, height = 144, offsetX = 0, offsetY = 0, offsetWidth = 489, offsetHeight = 144}, -- 25: GOOD BG SCROLL0000
		{x = 3688, y = 0, width = 383, height = 637, offsetX = 0, offsetY = 0, offsetWidth = 383, offsetHeight = 637}, -- 26: GOOD RANK0000
		{x = 0, y = 637, width = 380, height = 423, offsetX = 0, offsetY = 0, offsetWidth = 380, offsetHeight = 423}, -- 27: GREAT0000
		{x = 380, y = 637, width = 595, height = 144, offsetX = 0, offsetY = 0, offsetWidth = 595, offsetHeight = 144}, -- 28: GREAT BG SCROLL0000
		{x = 975, y = 637, width = 383, height = 426, offsetX = 0, offsetY = 0, offsetWidth = 383, offsetHeight = 426}, -- 29: GREAT RANK0000
		{x = 1358, y = 637, width = 380, height = 634, offsetX = 0, offsetY = 0, offsetWidth = 380, offsetHeight = 634}, -- 30: LOSS0000
		{x = 1738, y = 637, width = 491, height = 144, offsetX = 0, offsetY = 0, offsetWidth = 491, offsetHeight = 144}, -- 31: LOSS BG SCROLL0000
		{x = 2229, y = 637, width = 383, height = 637, offsetX = 0, offsetY = 0, offsetWidth = 383, offsetHeight = 637}, -- 32: LOSS RANK0000
		{x = 2612, y = 637, width = 380, height = 634, offsetX = 0, offsetY = 0, offsetWidth = 380, offsetHeight = 634}, -- 33: PERFECT0000
		{x = 2992, y = 637, width = 815, height = 144, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 144}, -- 34: PERFECT BG SCROLL0000
		{x = 0, y = 1274, width = 383, height = 637, offsetX = 0, offsetY = 0, offsetWidth = 383, offsetHeight = 637}, -- 35: PERFECT RANK0000
		{x = 383, y = 1274, width = 380, height = 634, offsetX = 0, offsetY = 0, offsetWidth = 380, offsetHeight = 634}, -- 36: excellent 20000
		{x = 763, y = 1274, width = 383, height = 637, offsetX = 0, offsetY = 0, offsetWidth = 383, offsetHeight = 637}, -- 37: excellent symbol again0000
		{x = 86, y = 0, width = 80, height = 90, offsetX = 0, offsetY = -1, offsetWidth = 80, offsetHeight = 90}, -- 38: numbers BIG LEFT0000
		{x = 1146, y = 1274, width = 62, height = 88, offsetX = -6, offsetY = -1, offsetWidth = 81, offsetHeight = 91}, -- 39: numbers BIG LEFT0001
		{x = 365, y = 0, width = 74, height = 88, offsetX = -1, offsetY = -1, offsetWidth = 74, offsetHeight = 88}, -- 40: numbers BIG LEFT0002
		{x = 1208, y = 1274, width = 78, height = 88, offsetX = -3, offsetY = -1, offsetWidth = 81, offsetHeight = 91}, -- 41: numbers BIG LEFT0003
		{x = 669, y = 0, width = 78, height = 86, offsetX = -1, offsetY = -2, offsetWidth = 78, offsetHeight = 86}, -- 42: numbers BIG LEFT0004
		{x = 1286, y = 1274, width = 79, height = 90, offsetX = -2, offsetY = -1, offsetWidth = 81, offsetHeight = 91}, -- 43: numbers BIG LEFT0005
		{x = 980, y = 0, width = 74, height = 88, offsetX = -2, offsetY = -2, offsetWidth = 74, offsetHeight = 88}, -- 44: numbers BIG LEFT0006
		{x = 1365, y = 1274, width = 75, height = 86, offsetX = -5, offsetY = -2, offsetWidth = 81, offsetHeight = 91}, -- 45: numbers BIG LEFT0007
		{x = 1440, y = 1274, width = 78, height = 90, offsetX = -2, offsetY = 0, offsetWidth = 81, offsetHeight = 91}, -- 46: numbers BIG LEFT0008
		{x = 1518, y = 1274, width = 78, height = 87, offsetX = -3, offsetY = -2, offsetWidth = 81, offsetHeight = 91}, -- 47: numbers BIG LEFT0009
		{x = 0, y = 0, width = 86, height = 87, offsetX = 0, offsetY = -1, offsetWidth = 86, offsetHeight = 87}, -- 48: numbers BIG RIGHT0000
		{x = 166, y = 0, width = 63, height = 89, offsetX = -8, offsetY = 0, offsetWidth = 63, offsetHeight = 89}, -- 49: numbers BIG RIGHT0001
		{x = 290, y = 0, width = 75, height = 84, offsetX = -4, offsetY = -3, offsetWidth = 75, offsetHeight = 84}, -- 50: numbers BIG RIGHT0002
		{x = 439, y = 0, width = 76, height = 83, offsetX = -5, offsetY = -2, offsetWidth = 76, offsetHeight = 83}, -- 51: numbers BIG RIGHT0003
		{x = 592, y = 0, width = 77, height = 84, offsetX = -4, offsetY = -2, offsetWidth = 77, offsetHeight = 84}, -- 52: numbers BIG RIGHT0004
		{x = 747, y = 0, width = 79, height = 88, offsetX = -3, offsetY = -1, offsetWidth = 79, offsetHeight = 88}, -- 53: numbers BIG RIGHT0005
		{x = 905, y = 0, width = 75, height = 88, offsetX = -2, offsetY = -1, offsetWidth = 75, offsetHeight = 88}, -- 54: numbers BIG RIGHT0006
		{x = 1054, y = 0, width = 79, height = 84, offsetX = -5, offsetY = -4, offsetWidth = 79, offsetHeight = 84}, -- 55: numbers BIG RIGHT0007
		{x = 1207, y = 0, width = 79, height = 90, offsetX = -3, offsetY = -1, offsetWidth = 79, offsetHeight = 90}, -- 56: numbers BIG RIGHT0008
		{x = 1363, y = 0, width = 79, height = 87, offsetX = -3, offsetY = -1, offsetWidth = 79, offsetHeight = 87}, -- 57: numbers BIG RIGHT0009
		{x = 1596, y = 1274, width = 1303, height = 233, offsetX = 0, offsetY = 0, offsetWidth = 1303, offsetHeight = 233}, -- 58: orange fade0000
		{x = 0, y = 1911, width = 1320, height = 1244, offsetX = 0, offsetY = 0, offsetWidth = 1320, offsetHeight = 1244} -- 59: yellow0000
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
		["CLEAR PERCENT TEXT"] = {start = 21, stop = 22, speed = 24, offsetX = 0, offsetY = 0},
		["EXCELLENT BG SCROLL"] = {start = 23, stop = 23, speed = 24, offsetX = 0, offsetY = 0},
		["GOOD"] = {start = 24, stop = 24, speed = 24, offsetX = 0, offsetY = 0},
		["GOOD BG SCROLL"] = {start = 25, stop = 25, speed = 24, offsetX = 0, offsetY = 0},
		["GOOD RANK"] = {start = 26, stop = 26, speed = 24, offsetX = 0, offsetY = 0},
		["GREAT"] = {start = 27, stop = 27, speed = 24, offsetX = 0, offsetY = 0},
		["GREAT BG SCROLL"] = {start = 28, stop = 28, speed = 24, offsetX = 0, offsetY = 0},
		["GREAT RANK"] = {start = 29, stop = 29, speed = 24, offsetX = 0, offsetY = 0},
		["LOSS"] = {start = 30, stop = 30, speed = 24, offsetX = 0, offsetY = 0},
		["LOSS BG SCROLL"] = {start = 31, stop = 31, speed = 24, offsetX = 0, offsetY = 0},
		["LOSS RANK"] = {start = 32, stop = 32, speed = 24, offsetX = 0, offsetY = 0},
		["PERFECT"] = {start = 33, stop = 33, speed = 24, offsetX = 0, offsetY = 0},
		["PERFECT BG SCROLL"] = {start = 34, stop = 34, speed = 24, offsetX = 0, offsetY = 0},
		["PERFECT RANK"] = {start = 35, stop = 35, speed = 24, offsetX = 0, offsetY = 0},
		["excellent"] = {start = 36, stop = 36, speed = 24, offsetX = 0, offsetY = 0},
		["excellent symbol again"] = {start = 37, stop = 37, speed = 24, offsetX = 0, offsetY = 0},
		["numbers BIG LEFT"] = {start = 38, stop = 47, speed = 24, offsetX = 0, offsetY = 0},
		["numbers BIG RIGHT"] = {start = 48, stop = 57, speed = 24, offsetX = 0, offsetY = 0},
		["orange fade"] = {start = 58, stop = 58, speed = 24, offsetX = 0, offsetY = 0},
		["yellow"] = {start = 59, stop = 59, speed = 24, offsetX = 0, offsetY = 0}
	},
	"0a big"
)

return results_ranking_assets_v2
