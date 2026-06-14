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


local phillyTraffic = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/phillyStreets/phillyTraffic")),
	{
		{x = 342, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 1: redtogreen0020
		{x = 1362, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 2: redtogreen0019
		{x = 2, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 3: redtogreen0018
		{x = 342, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 4: redtogreen0017
		{x = 682, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 5: redtogreen0016
		{x = 682, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 6: redtogreen0015
		{x = 2, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 7: redtogreen0014
		{x = 342, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 8: redtogreen0013
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 9: redtogreen0012
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 10: redtogreen0011
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 11: redtogreen0010
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 12: redtogreen0009
		{x = 2722, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 13: redtogreen0008
		{x = 2722, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 14: redtogreen0007
		{x = 2722, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 15: redtogreen0006
		{x = 2722, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 16: redtogreen0005
		{x = 2382, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 17: redtogreen0004
		{x = 2382, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 18: redtogreen0003
		{x = 2382, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 19: redtogreen0002
		{x = 2382, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 20: redtogreen0001
		{x = 2382, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 21: greentored0057
		{x = 2382, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 22: greentored0056
		{x = 2382, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 23: greentored0055
		{x = 2042, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 24: greentored0054
		{x = 2042, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 25: greentored0053
		{x = 2042, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 26: greentored0052
		{x = 2042, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 27: greentored0051
		{x = 1702, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 28: greentored0050
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 29: greentored0049
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 30: greentored0048
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 31: greentored0047
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 32: greentored0046
		{x = 1702, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 33: greentored0045
		{x = 1702, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 34: greentored0044
		{x = 1702, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 35: greentored0043
		{x = 1362, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 36: greentored0042
		{x = 2, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 37: greentored0041
		{x = 1362, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 38: greentored0040
		{x = 1362, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 39: greentored0039
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 40: greentored0038
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 41: greentored0037
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 42: greentored0036
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 43: greentored0035
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 44: greentored0034
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 45: greentored0033
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 46: greentored0032
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 47: greentored0031
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 48: greentored0030
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 49: greentored0029
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 50: greentored0028
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 51: greentored0027
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 52: greentored0026
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 53: greentored0025
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 54: greentored0024
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 55: greentored0023
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 56: greentored0022
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 57: greentored0021
		{x = 1022, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 58: greentored0020
		{x = 682, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 59: greentored0019
		{x = 342, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 60: greentored0018
		{x = 2, y = 1358, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 61: greentored0017
		{x = 1022, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 62: greentored0016
		{x = 1022, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 63: greentored0015
		{x = 1022, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 64: greentored0014
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 65: greentored0013
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 66: greentored0012
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 67: greentored0011
		{x = 682, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 68: greentored0010
		{x = 342, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 69: greentored0009
		{x = 2, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 70: greentored0008
		{x = 682, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 71: greentored0007
		{x = 682, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 72: greentored0006
		{x = 342, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 73: greentored0005
		{x = 2, y = 454, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 74: greentored0004
		{x = 1362, y = 906, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 75: greentored0003
		{x = 342, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 76: greentored0002
		{x = 342, y = 2, width = 336, height = 448, offsetX = -0, offsetY = -0, offsetWidth = 336, offsetHeight = 448}, -- 77: greentored0001
	},
	{
		["redtogreen"] = {start = 1, stop = 20, speed = 24, offsetX = 0, offsetY = 0},
		["greentored"] = {start = 21, stop = 77, speed = 24, offsetX = 0, offsetY = 0}
	},
	"redtogreen"
)

return phillyTraffic
