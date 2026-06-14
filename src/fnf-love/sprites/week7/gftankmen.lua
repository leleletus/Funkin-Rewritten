--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021 HTV04

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

return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/gfTankmen")),
	{
		-- Crying frames (sad animation)
		{x = 1824, y = 1926, width = 911, height = 625, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 1: GF Crying at Gunpoint 0000
		{x = 1824, y = 1926, width = 911, height = 625, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 2: GF Crying at Gunpoint 0001
		{x = 0, y = 1925, width = 911, height = 629, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 3: GF Crying at Gunpoint 0002
		{x = 0, y = 1925, width = 911, height = 629, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 4: GF Crying at Gunpoint 0003
		{x = 4569, y = 1288, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: GF Crying at Gunpoint 0004
		{x = 4569, y = 1288, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: GF Crying at Gunpoint 0005
		{x = 0, y = 1291, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: GF Crying at Gunpoint 0006
		{x = 0, y = 1291, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: GF Crying at Gunpoint 0007
		{x = 915, y = 1292, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: GF Crying at Gunpoint 0008
		{x = 915, y = 1292, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: GF Crying at Gunpoint 0009
		{x = 4569, y = 1922, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: GF Crying at Gunpoint 0010
		{x = 4569, y = 1922, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: GF Crying at Gunpoint 0011
		{x = 4569, y = 1288, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13: GF Crying at Gunpoint 0012

		-- Dancing frames for danceLeft (D15, D0..D14)
		{x = 915, y = 652, width = 907, height = 636, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 14: GF Dancing at Gunpoint0015 (copy1)
		{x = 6399, y = 1287, width = 907, height = 634, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 15: GF Dancing at Gunpoint0000
		{x = 2737, y = 1288, width = 907, height = 634, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 16: GF Dancing at Gunpoint0001
		{x = 6399, y = 1925, width = 905, height = 632, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 17: GF Dancing at Gunpoint0002
		{x = 915, y = 1926, width = 905, height = 632, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 18: GF Dancing at Gunpoint0003
		{x = 3660, y = 647, width = 911, height = 635, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 19: GF Dancing at Gunpoint0004
		{x = 0, y = 652, width = 911, height = 635, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 20: GF Dancing at Gunpoint0005
		{x = 5490, y = 646, width = 911, height = 637, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 21: GF Dancing at Gunpoint0006
		{x = 0, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 22: GF Dancing at Gunpoint0007
		{x = 0, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 23: GF Dancing at Gunpoint0008
		{x = 0, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 24: GF Dancing at Gunpoint0009
		{x = 915, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: GF Dancing at Gunpoint0010
		{x = 915, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 26: GF Dancing at Gunpoint0011
		{x = 915, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 27: GF Dancing at Gunpoint0012
		{x = 1830, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 28: GF Dancing at Gunpoint0013
		{x = 1830, y = 0, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 29: GF Dancing at Gunpoint0014

		-- Dancing frames for danceRight (D15 copy2, D16..D29)
		{x = 915, y = 652, width = 907, height = 636, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 30: GF Dancing at Gunpoint0015 (copy2)
		{x = 1826, y = 652, width = 907, height = 636, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 31: GF Dancing at Gunpoint0016
		{x = 3660, y = 1286, width = 905, height = 636, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 32: GF Dancing at Gunpoint0017
		{x = 5490, y = 1287, width = 905, height = 636, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 33: GF Dancing at Gunpoint0018
		{x = 6405, y = 646, width = 911, height = 637, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 34: GF Dancing at Gunpoint0019
		{x = 2745, y = 647, width = 911, height = 637, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 35: GF Dancing at Gunpoint0020
		{x = 4575, y = 646, width = 911, height = 638, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 36: GF Dancing at Gunpoint0021
		{x = 2745, y = 0, width = 911, height = 643, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 37: GF Dancing at Gunpoint0022
		{x = 2745, y = 0, width = 911, height = 643, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 38: GF Dancing at Gunpoint0023
		{x = 3660, y = 0, width = 911, height = 643, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 39: GF Dancing at Gunpoint0024
		{x = 4575, y = 0, width = 911, height = 642, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 40: GF Dancing at Gunpoint0025
		{x = 4575, y = 0, width = 911, height = 642, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 41: GF Dancing at Gunpoint0026
		{x = 5490, y = 0, width = 911, height = 642, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 42: GF Dancing at Gunpoint0027
		{x = 6405, y = 0, width = 911, height = 642, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 43: GF Dancing at Gunpoint0028
		{x = 6405, y = 0, width = 911, height = 642, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}  -- 44: GF Dancing at Gunpoint0029
	},
	{
		["sad"] = {start = 1, stop = 13, speed = 24, offsetX = 0, offsetY = -27},
		["danceLeft"] = {start = 14, stop = 29, speed = 24, offsetX = 0, offsetY = -9},
		["danceRight"] = {start = 30, stop = 44, speed = 24, offsetX = 0, offsetY = -9}
	},
	"danceRight",
	false
)