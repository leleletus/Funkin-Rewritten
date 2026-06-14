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


local GF_Dialogue = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("dialogue/GF_Dialogue")),
	{
		{x = 4, y = 4, width = 293, height = 414, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: GF0000
		{x = 301, y = 4, width = 293, height = 414, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: GF CONFUSED0000
		{x = 598, y = 4, width = 293, height = 424, offsetX = -3, offsetY = 0, offsetWidth = 299, offsetHeight = 424}, -- 3: GF CONFUSED LOOP0000
		{x = 598, y = 4, width = 293, height = 424, offsetX = -3, offsetY = 0, offsetWidth = 299, offsetHeight = 424}, -- 4: GF CONFUSED LOOP0001
		{x = 895, y = 4, width = 292, height = 419, offsetX = 0, offsetY = -3, offsetWidth = 299, offsetHeight = 424}, -- 5: GF CONFUSED LOOP0002
		{x = 895, y = 4, width = 292, height = 419, offsetX = 0, offsetY = -3, offsetWidth = 299, offsetHeight = 424}, -- 6: GF CONFUSED LOOP0003
		{x = 1191, y = 4, width = 293, height = 414, offsetX = -4, offsetY = -8, offsetWidth = 299, offsetHeight = 424}, -- 7: GF CONFUSED LOOP0004
		{x = 1488, y = 4, width = 295, height = 413, offsetX = -4, offsetY = -9, offsetWidth = 299, offsetHeight = 424}, -- 8: GF CONFUSED LOOP0005
		{x = 1787, y = 4, width = 293, height = 414, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: GF DEMON0000
		{x = 1787, y = 4, width = 293, height = 414, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: GF DEMON0001
		{x = 2084, y = 4, width = 293, height = 414, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: GF DEMON0002
		{x = 2084, y = 4, width = 293, height = 414, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: GF DEMON0003
		{x = 2381, y = 4, width = 293, height = 424, offsetX = -3, offsetY = 0, offsetWidth = 299, offsetHeight = 424}, -- 13: GF DEMON LOOP0000
		{x = 2381, y = 4, width = 293, height = 424, offsetX = -3, offsetY = 0, offsetWidth = 299, offsetHeight = 424}, -- 14: GF DEMON LOOP0001
		{x = 2678, y = 4, width = 292, height = 419, offsetX = 0, offsetY = -3, offsetWidth = 299, offsetHeight = 424}, -- 15: GF DEMON LOOP0002
		{x = 2678, y = 4, width = 292, height = 419, offsetX = 0, offsetY = -3, offsetWidth = 299, offsetHeight = 424}, -- 16: GF DEMON LOOP0003
		{x = 2974, y = 4, width = 293, height = 414, offsetX = -4, offsetY = -8, offsetWidth = 299, offsetHeight = 424}, -- 17: GF DEMON LOOP0004
		{x = 3271, y = 4, width = 295, height = 413, offsetX = -4, offsetY = -9, offsetWidth = 299, offsetHeight = 424}, -- 18: GF DEMON LOOP0005
		{x = 3570, y = 4, width = 292, height = 422, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: GF EXCITED0000
		{x = 4, y = 432, width = 283, height = 446, offsetX = -9, offsetY = 0, offsetWidth = 302, offsetHeight = 446}, -- 20: GF EXCITED LOOP0000
		{x = 4, y = 432, width = 283, height = 446, offsetX = -9, offsetY = 0, offsetWidth = 302, offsetHeight = 446}, -- 21: GF EXCITED LOOP0001
		{x = 291, y = 432, width = 289, height = 432, offsetX = 0, offsetY = -9, offsetWidth = 302, offsetHeight = 446}, -- 22: GF EXCITED LOOP0002
		{x = 291, y = 432, width = 289, height = 432, offsetX = 0, offsetY = -9, offsetWidth = 302, offsetHeight = 446}, -- 23: GF EXCITED LOOP0003
		{x = 584, y = 432, width = 292, height = 423, offsetX = -7, offsetY = -16, offsetWidth = 302, offsetHeight = 446}, -- 24: GF EXCITED LOOP0004
		{x = 880, y = 432, width = 294, height = 422, offsetX = -8, offsetY = -17, offsetWidth = 302, offsetHeight = 446}, -- 25: GF EXCITED LOOP0005
		{x = 1178, y = 432, width = 293, height = 424, offsetX = -3, offsetY = 0, offsetWidth = 299, offsetHeight = 424}, -- 26: GF LOOP0000
		{x = 1178, y = 432, width = 293, height = 424, offsetX = -3, offsetY = 0, offsetWidth = 299, offsetHeight = 424}, -- 27: GF LOOP0001
		{x = 1475, y = 432, width = 292, height = 419, offsetX = 0, offsetY = -3, offsetWidth = 299, offsetHeight = 424}, -- 28: GF LOOP0002
		{x = 1475, y = 432, width = 292, height = 419, offsetX = 0, offsetY = -3, offsetWidth = 299, offsetHeight = 424}, -- 29: GF LOOP0003
		{x = 1771, y = 432, width = 293, height = 414, offsetX = -4, offsetY = -8, offsetWidth = 299, offsetHeight = 424}, -- 30: GF LOOP0004
		{x = 2068, y = 432, width = 295, height = 413, offsetX = -4, offsetY = -9, offsetWidth = 299, offsetHeight = 424}, -- 31: GF LOOP0005
		{x = 2367, y = 432, width = 385, height = 392, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 32: GF SHOCK0000
		{x = 2756, y = 432, width = 386, height = 412, offsetX = 0, offsetY = 0, offsetWidth = 390, offsetHeight = 412}, -- 33: GF SHOCK LOOP0000
		{x = 2756, y = 432, width = 386, height = 412, offsetX = 0, offsetY = 0, offsetWidth = 390, offsetHeight = 412}, -- 34: GF SHOCK LOOP0001
		{x = 3146, y = 432, width = 383, height = 396, offsetX = -2, offsetY = -11, offsetWidth = 390, offsetHeight = 412}, -- 35: GF SHOCK LOOP0002
		{x = 3146, y = 432, width = 383, height = 396, offsetX = -2, offsetY = -11, offsetWidth = 390, offsetHeight = 412}, -- 36: GF SHOCK LOOP0003
		{x = 3533, y = 432, width = 386, height = 392, offsetX = 0, offsetY = -14, offsetWidth = 390, offsetHeight = 412}, -- 37: GF SHOCK LOOP0004
		{x = 4, y = 882, width = 390, height = 391, offsetX = 0, offsetY = -15, offsetWidth = 390, offsetHeight = 412}, -- 38: GF SHOCK LOOP0005
	},
	{
		["GF"] = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
		["GF CONFUSED"] = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
		["GF CONFUSED LOOP"] = {start = 3, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["GF DEMON"] = {start = 9, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
		["GF DEMON LOOP"] = {start = 13, stop = 18, speed = 24, offsetX = 0, offsetY = 0},
		["GF EXCITED"] = {start = 19, stop = 19, speed = 24, offsetX = 0, offsetY = 0},
		["GF EXCITED LOOP"] = {start = 20, stop = 25, speed = 24, offsetX = 0, offsetY = 0},
		["GF LOOP"] = {start = 26, stop = 31, speed = 24, offsetX = 0, offsetY = 0},
		["GF SHOCK"] = {start = 32, stop = 32, speed = 24, offsetX = 0, offsetY = 0},
		["GF SHOCK LOOP"] = {start = 33, stop = 38, speed = 24, offsetX = 0, offsetY = 0}
	},
	"GF"
)

return GF_Dialogue
