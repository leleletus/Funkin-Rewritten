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


local BF_Dialogue = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("dialogue/BF_Dialogue")),
	{
		{x = 4, y = 4, width = 402, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: BF0000
		{x = 4, y = 4, width = 402, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: BF0001
		{x = 410, y = 4, width = 396, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: BF CONFUSED0000
		{x = 410, y = 4, width = 396, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: BF CONFUSED0001
		{x = 810, y = 4, width = 400, height = 421, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: BF CONFUSED LOOP0000
		{x = 810, y = 4, width = 400, height = 421, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: BF CONFUSED LOOP0001
		{x = 1214, y = 4, width = 395, height = 415, offsetX = -3, offsetY = -6, offsetWidth = 400, offsetHeight = 421}, -- 7: BF CONFUSED LOOP0002
		{x = 1214, y = 4, width = 395, height = 415, offsetX = -3, offsetY = -6, offsetWidth = 400, offsetHeight = 421}, -- 8: BF CONFUSED LOOP0003
		{x = 1613, y = 4, width = 396, height = 407, offsetX = -3, offsetY = -14, offsetWidth = 400, offsetHeight = 421}, -- 9: BF CONFUSED LOOP0004
		{x = 1613, y = 4, width = 396, height = 407, offsetX = -3, offsetY = -14, offsetWidth = 400, offsetHeight = 421}, -- 10: BF CONFUSED LOOP0005
		{x = 2013, y = 4, width = 414, height = 412, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: BF EXCITED0000
		{x = 2013, y = 4, width = 414, height = 412, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: BF EXCITED0001
		{x = 2431, y = 4, width = 415, height = 422, offsetX = 0, offsetY = 0, offsetWidth = 415, offsetHeight = 423}, -- 13: BF EXCITED LOOP0000
		{x = 2431, y = 4, width = 415, height = 422, offsetX = 0, offsetY = 0, offsetWidth = 415, offsetHeight = 423}, -- 14: BF EXCITED LOOP0001
		{x = 2850, y = 4, width = 412, height = 417, offsetX = -1, offsetY = -6, offsetWidth = 415, offsetHeight = 423}, -- 15: BF EXCITED LOOP0002
		{x = 2850, y = 4, width = 412, height = 417, offsetX = -1, offsetY = -6, offsetWidth = 415, offsetHeight = 423}, -- 16: BF EXCITED LOOP0003
		{x = 3266, y = 4, width = 414, height = 412, offsetX = -1, offsetY = -10, offsetWidth = 415, offsetHeight = 423}, -- 17: BF EXCITED LOOP0004
		{x = 3266, y = 4, width = 414, height = 412, offsetX = -1, offsetY = -10, offsetWidth = 415, offsetHeight = 423}, -- 18: BF EXCITED LOOP0005
		{x = 3684, y = 4, width = 404, height = 421, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: BF LOOP0000
		{x = 3684, y = 4, width = 404, height = 421, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 20: BF LOOP0001
		{x = 4, y = 430, width = 402, height = 415, offsetX = 0, offsetY = -6, offsetWidth = 404, offsetHeight = 421}, -- 21: BF LOOP0002
		{x = 4, y = 430, width = 402, height = 415, offsetX = 0, offsetY = -6, offsetWidth = 404, offsetHeight = 421}, -- 22: BF LOOP0003
		{x = 410, y = 430, width = 402, height = 407, offsetX = -1, offsetY = -14, offsetWidth = 404, offsetHeight = 421}, -- 23: BF LOOP0004
		{x = 410, y = 430, width = 402, height = 407, offsetX = -1, offsetY = -14, offsetWidth = 404, offsetHeight = 421}, -- 24: BF LOOP0005
		{x = 816, y = 430, width = 381, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: BF PISSED0000
		{x = 816, y = 430, width = 381, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 26: BF PISSED0001
		{x = 1201, y = 430, width = 386, height = 399, offsetX = -1, offsetY = -8, offsetWidth = 387, offsetHeight = 407}, -- 27: BF PISSED LOOP0000
		{x = 1201, y = 430, width = 386, height = 399, offsetX = -1, offsetY = -8, offsetWidth = 387, offsetHeight = 407}, -- 28: BF PISSED LOOP0001
		{x = 1591, y = 430, width = 384, height = 403, offsetX = 0, offsetY = -4, offsetWidth = 387, offsetHeight = 407}, -- 29: BF PISSED LOOP0002
		{x = 1591, y = 430, width = 384, height = 403, offsetX = 0, offsetY = -4, offsetWidth = 387, offsetHeight = 407}, -- 30: BF PISSED LOOP0003
		{x = 816, y = 430, width = 381, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 31: BF PISSED LOOP0004
		{x = 816, y = 430, width = 381, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 32: BF PISSED LOOP0005
		{x = 1979, y = 430, width = 396, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 33: BF SHOCK0000
		{x = 2379, y = 430, width = 396, height = 407, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 34: BF SHOCK0001
		{x = 2779, y = 430, width = 400, height = 421, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 35: BF SHOCK LOOP0000
		{x = 3183, y = 430, width = 400, height = 421, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 36: BF SHOCK LOOP0001
		{x = 3587, y = 430, width = 395, height = 415, offsetX = -3, offsetY = -6, offsetWidth = 400, offsetHeight = 421}, -- 37: BF SHOCK LOOP0002
		{x = 4, y = 855, width = 395, height = 415, offsetX = -3, offsetY = -6, offsetWidth = 400, offsetHeight = 421}, -- 38: BF SHOCK LOOP0003
		{x = 403, y = 855, width = 396, height = 407, offsetX = -3, offsetY = -14, offsetWidth = 400, offsetHeight = 421}, -- 39: BF SHOCK LOOP0004
		{x = 803, y = 855, width = 396, height = 407, offsetX = -3, offsetY = -14, offsetWidth = 400, offsetHeight = 421}, -- 40: BF SHOCK LOOP0005
	},
	{
		["BF"] = {start = 1, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
		["BF CONFUSED"] = {start = 3, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
		["BF CONFUSED LOOP"] = {start = 5, stop = 10, speed = 24, offsetX = 0, offsetY = 0},
		["BF EXCITED"] = {start = 11, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
		["BF EXCITED LOOP"] = {start = 13, stop = 18, speed = 24, offsetX = 0, offsetY = 0},
		["BF LOOP"] = {start = 19, stop = 24, speed = 24, offsetX = 0, offsetY = 0},
		["BF PISSED"] = {start = 25, stop = 26, speed = 24, offsetX = 0, offsetY = 0},
		["BF PISSED LOOP"] = {start = 27, stop = 32, speed = 24, offsetX = 0, offsetY = 0},
		["BF SHOCK"] = {start = 33, stop = 34, speed = 24, offsetX = 0, offsetY = 0},
		["BF SHOCK LOOP"] = {start = 35, stop = 40, speed = 24, offsetX = 0, offsetY = 0}
	},
	"BF"
)

return BF_Dialogue
