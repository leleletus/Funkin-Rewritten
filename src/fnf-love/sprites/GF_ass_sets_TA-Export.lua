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

local GF_ass_sets_TA_Export = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("GF_ass_sets_TA-Export")),
	{
		{x = 0, y = 0, width = 911, height = 625, offsetX = 0, offsetY = -5, offsetWidth = 911, offsetHeight = 630}, -- 1: GF Crying at Gunpoint 0000
		{x = 0, y = 0, width = 911, height = 625, offsetX = 0, offsetY = -5, offsetWidth = 911, offsetHeight = 630}, -- 2: GF Crying at Gunpoint 0001
		{x = 911, y = 0, width = 911, height = 629, offsetX = 0, offsetY = -1, offsetWidth = 911, offsetHeight = 630}, -- 3: GF Crying at Gunpoint 0002
		{x = 911, y = 0, width = 911, height = 629, offsetX = 0, offsetY = -1, offsetWidth = 911, offsetHeight = 630}, -- 4: GF Crying at Gunpoint 0003
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 5: GF Crying at Gunpoint 0004
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 6: GF Crying at Gunpoint 0005
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 7: GF Crying at Gunpoint 0006
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 8: GF Crying at Gunpoint 0007
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 9: GF Crying at Gunpoint 0008
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 10: GF Crying at Gunpoint 0009
		{x = 4555, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 11: GF Crying at Gunpoint 0010
		{x = 4555, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 12: GF Crying at Gunpoint 0011
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 13: GF Crying at Gunpoint 0012
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 14: GF Crying at Gunpoint 0013
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 15: GF Crying at Gunpoint 0014
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 16: GF Crying at Gunpoint 0015
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 17: GF Crying at Gunpoint 0016
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 18: GF Crying at Gunpoint 0017
		{x = 4555, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 19: GF Crying at Gunpoint 0018
		{x = 4555, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 20: GF Crying at Gunpoint 0019
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 21: GF Crying at Gunpoint 0020
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 22: GF Crying at Gunpoint 0021
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 23: GF Crying at Gunpoint 0022
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 24: GF Crying at Gunpoint 0023
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 25: GF Crying at Gunpoint 0024
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 26: GF Crying at Gunpoint 0025
		{x = 4555, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 27: GF Crying at Gunpoint 0026
		{x = 4555, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 28: GF Crying at Gunpoint 0027
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 29: GF Crying at Gunpoint 0028
		{x = 1822, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 30: GF Crying at Gunpoint 0029
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 31: GF Crying at Gunpoint 0030
		{x = 2733, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 32: GF Crying at Gunpoint 0031
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 33: GF Crying at Gunpoint 0032
		{x = 3644, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 34: GF Crying at Gunpoint 0033
		{x = 4555, y = 0, width = 911, height = 630, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 630}, -- 35: GF Crying at Gunpoint 0034
		{x = 5466, y = 0, width = 907, height = 634, offsetX = -2, offsetY = -14, offsetWidth = 911, offsetHeight = 648}, -- 36: GF Dancing at Gunpoint0000
		{x = 6373, y = 0, width = 907, height = 634, offsetX = -2, offsetY = -14, offsetWidth = 911, offsetHeight = 648}, -- 37: GF Dancing at Gunpoint0001
		{x = 7280, y = 0, width = 905, height = 632, offsetX = -3, offsetY = -16, offsetWidth = 911, offsetHeight = 648}, -- 38: GF Dancing at Gunpoint0002
		{x = 0, y = 634, width = 905, height = 632, offsetX = -3, offsetY = -16, offsetWidth = 911, offsetHeight = 648}, -- 39: GF Dancing at Gunpoint0003
		{x = 905, y = 634, width = 911, height = 635, offsetX = 0, offsetY = -13, offsetWidth = 911, offsetHeight = 648}, -- 40: GF Dancing at Gunpoint0004
		{x = 1816, y = 634, width = 911, height = 635, offsetX = 0, offsetY = -13, offsetWidth = 911, offsetHeight = 648}, -- 41: GF Dancing at Gunpoint0005
		{x = 2727, y = 634, width = 911, height = 637, offsetX = 0, offsetY = -11, offsetWidth = 911, offsetHeight = 648}, -- 42: GF Dancing at Gunpoint0006
		{x = 3638, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 43: GF Dancing at Gunpoint0007
		{x = 3638, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 44: GF Dancing at Gunpoint0008
		{x = 3638, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 45: GF Dancing at Gunpoint0009
		{x = 4549, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 46: GF Dancing at Gunpoint0010
		{x = 4549, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 47: GF Dancing at Gunpoint0011
		{x = 4549, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 48: GF Dancing at Gunpoint0012
		{x = 5460, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 49: GF Dancing at Gunpoint0013
		{x = 5460, y = 634, width = 911, height = 648, offsetX = 0, offsetY = 0, offsetWidth = 911, offsetHeight = 648}, -- 50: GF Dancing at Gunpoint0014
		{x = 6371, y = 634, width = 907, height = 636, offsetX = -2, offsetY = -12, offsetWidth = 911, offsetHeight = 648}, -- 51: GF Dancing at Gunpoint0015
		{x = 7278, y = 634, width = 907, height = 636, offsetX = -2, offsetY = -12, offsetWidth = 911, offsetHeight = 648}, -- 52: GF Dancing at Gunpoint0016
		{x = 0, y = 1282, width = 905, height = 636, offsetX = -3, offsetY = -12, offsetWidth = 911, offsetHeight = 648}, -- 53: GF Dancing at Gunpoint0017
		{x = 905, y = 1282, width = 905, height = 636, offsetX = -3, offsetY = -12, offsetWidth = 911, offsetHeight = 648}, -- 54: GF Dancing at Gunpoint0018
		{x = 1810, y = 1282, width = 911, height = 637, offsetX = 0, offsetY = -11, offsetWidth = 911, offsetHeight = 648}, -- 55: GF Dancing at Gunpoint0019
		{x = 2721, y = 1282, width = 911, height = 637, offsetX = 0, offsetY = -11, offsetWidth = 911, offsetHeight = 648}, -- 56: GF Dancing at Gunpoint0020
		{x = 3632, y = 1282, width = 911, height = 638, offsetX = 0, offsetY = -10, offsetWidth = 911, offsetHeight = 648}, -- 57: GF Dancing at Gunpoint0021
		{x = 4543, y = 1282, width = 911, height = 643, offsetX = 0, offsetY = -5, offsetWidth = 911, offsetHeight = 648}, -- 58: GF Dancing at Gunpoint0022
		{x = 4543, y = 1282, width = 911, height = 643, offsetX = 0, offsetY = -5, offsetWidth = 911, offsetHeight = 648}, -- 59: GF Dancing at Gunpoint0023
		{x = 5454, y = 1282, width = 911, height = 643, offsetX = 0, offsetY = -5, offsetWidth = 911, offsetHeight = 648}, -- 60: GF Dancing at Gunpoint0024
		{x = 6365, y = 1282, width = 911, height = 642, offsetX = 0, offsetY = -6, offsetWidth = 911, offsetHeight = 648}, -- 61: GF Dancing at Gunpoint0025
		{x = 6365, y = 1282, width = 911, height = 642, offsetX = 0, offsetY = -6, offsetWidth = 911, offsetHeight = 648}, -- 62: GF Dancing at Gunpoint0026
		{x = 7276, y = 1282, width = 911, height = 642, offsetX = 0, offsetY = -6, offsetWidth = 911, offsetHeight = 648}, -- 63: GF Dancing at Gunpoint0027
		{x = 0, y = 1925, width = 911, height = 642, offsetX = 0, offsetY = -6, offsetWidth = 911, offsetHeight = 648}, -- 64: GF Dancing at Gunpoint0028
		{x = 0, y = 1925, width = 911, height = 642, offsetX = 0, offsetY = -6, offsetWidth = 911, offsetHeight = 648} -- 65: GF Dancing at Gunpoint0029
	},
	{
		["sad"] = {start = 1, stop = 35, speed = 24, offsetX = 0, offsetY = -10},
    	["idle"] = {start = 36, stop = 65, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle",
	false
)

return GF_ass_sets_TA_Export
