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


local MajinOG = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("MajinOG")),
	{
		{x = 15, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: Majin_DOWN0000
		{x = 15, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: Majin_DOWN0001
		{x = 472, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: Majin_DOWN0002
		{x = 472, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: Majin_DOWN0003
		{x = 929, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: Majin_DOWN0004
		{x = 929, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: Majin_DOWN0005
		{x = 1386, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: Majin_DOWN0006
		{x = 1386, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: Majin_DOWN0007
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: Majin_DOWN0008
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: Majin_DOWN0009
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: Majin_DOWN0010
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: Majin_DOWN0011
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13: Majin_DOWN0012
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14: Majin_DOWN0013
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 15: Majin_DOWN0014
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 16: Majin_DOWN0015
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 17: Majin_DOWN0016
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 18: Majin_DOWN0017
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: Majin_DOWN0018
		{x = 1843, y = 15, width = 442, height = 390, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 20: Majin_DOWN0019
		{x = 2300, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 21: Majin_IDLE0000
		{x = 2300, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 22: Majin_IDLE0001
		{x = 2694, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 23: Majin_IDLE0002
		{x = 2694, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 24: Majin_IDLE0003
		{x = 3088, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: Majin_IDLE0004
		{x = 3088, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 26: Majin_IDLE0005
		{x = 3482, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 27: Majin_IDLE0006
		{x = 3482, y = 15, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 28: Majin_IDLE0007
		{x = 15, y = 469, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 29: Majin_IDLE0008
		{x = 15, y = 469, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 30: Majin_IDLE0009
		{x = 409, y = 469, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 31: Majin_IDLE0010
		{x = 409, y = 469, width = 379, height = 439, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 32: Majin_IDLE0011
		{x = 803, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 33: Majin_LEFT0000
		{x = 803, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 34: Majin_LEFT0001
		{x = 1317, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 35: Majin_LEFT0002
		{x = 1317, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 36: Majin_LEFT0003
		{x = 1831, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 37: Majin_LEFT0004
		{x = 1831, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 38: Majin_LEFT0005
		{x = 2345, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 39: Majin_LEFT0006
		{x = 2345, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 40: Majin_LEFT0007
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 41: Majin_LEFT0008
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 42: Majin_LEFT0009
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 43: Majin_LEFT0010
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 44: Majin_LEFT0011
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 45: Majin_LEFT0012
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 46: Majin_LEFT0013
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 47: Majin_LEFT0014
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 48: Majin_LEFT0015
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 49: Majin_LEFT0016
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 50: Majin_LEFT0017
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 51: Majin_LEFT0018
		{x = 2859, y = 469, width = 499, height = 462, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 52: Majin_LEFT0019
		{x = 3373, y = 469, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 53: Majin_RIGHT0000
		{x = 3373, y = 469, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 54: Majin_RIGHT0001
		{x = 15, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 55: Majin_RIGHT0002
		{x = 15, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 56: Majin_RIGHT0003
		{x = 647, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 57: Majin_RIGHT0004
		{x = 647, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 58: Majin_RIGHT0005
		{x = 1279, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 59: Majin_RIGHT0006
		{x = 1279, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 60: Majin_RIGHT0007
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 61: Majin_RIGHT0008
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 62: Majin_RIGHT0009
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 63: Majin_RIGHT0010
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 64: Majin_RIGHT0011
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 65: Majin_RIGHT0012
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 66: Majin_RIGHT0013
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 67: Majin_RIGHT0014
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 68: Majin_RIGHT0015
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 69: Majin_RIGHT0016
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 70: Majin_RIGHT0017
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 71: Majin_RIGHT0018
		{x = 1911, y = 946, width = 617, height = 417, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 72: Majin_RIGHT0019
		{x = 2543, y = 946, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 73: Majin_UP0000
		{x = 2543, y = 946, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 74: Majin_UP0001
		{x = 2950, y = 946, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 75: Majin_UP0002
		{x = 2950, y = 946, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 76: Majin_UP0003
		{x = 3357, y = 946, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 77: Majin_UP0004
		{x = 3357, y = 946, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 78: Majin_UP0005
		{x = 15, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 79: Majin_UP0006
		{x = 15, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 80: Majin_UP0007
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 81: Majin_UP0008
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 82: Majin_UP0009
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 83: Majin_UP0010
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 84: Majin_UP0011
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 85: Majin_UP0012
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 86: Majin_UP0013
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 87: Majin_UP0014
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 88: Majin_UP0015
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 89: Majin_UP0016
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 90: Majin_UP0017
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 91: Majin_UP0018
		{x = 422, y = 1495, width = 392, height = 534, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 92: Majin_UP0019
	},
	{
		["down"] = {start = 1, stop = 20, speed = 24, offsetX = 40, offsetY = -30},
		["idle"] = {start = 21, stop = 32, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 33, stop = 52, speed = 24, offsetX = 140, offsetY = -10},
		["right"] = {start = 53, stop = 72, speed = 24, offsetX = -70, offsetY = -20},
		["up"] = {start = 73, stop = 92, speed = 24, offsetX = 0, offsetY = 25}
	},
	"idle"
)

return MajinOG
