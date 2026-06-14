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

local AbotSystem = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/char/AbotSystem")),
	{
		{x = 0, y = 0, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 1: aaaaaaa0000
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 2: aaaaaaa0001
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 3: aaaaaaa0002
		{x = 0, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 4: aaaaaaa0003
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 5: aaaaaaa0004
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 6: aaaaaaa0005
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 7: aaaaaaa0006
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 8: aaaaaaa0007
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 9: aaaaaaa0008
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 10: aaaaaaa0009
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 11: aaaaaaa0010
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 12: aaaaaaa0011
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 13: aaaaaaa0012
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 14: aaaaaaa0013
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 15: aaaaaaa0014
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 16: aaaaaaa0015
		{x = 0, y = 0, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 17: aaaaaaa0016
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 18: aaaaaaa0017
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 19: aaaaaaa0018
		{x = 0, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 20: aaaaaaa0019
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 21: aaaaaaa0020
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 22: aaaaaaa0021
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 23: aaaaaaa0022
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 24: aaaaaaa0023
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 25: aaaaaaa0024
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 26: aaaaaaa0025
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 27: aaaaaaa0026
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 28: aaaaaaa0027
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 29: aaaaaaa0028
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 30: aaaaaaa0029
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 31: aaaaaaa0030
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 32: aaaaaaa0031
		{x = 0, y = 0, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 33: aaaaaaa0032
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 34: aaaaaaa0033
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 35: aaaaaaa0034
		{x = 0, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 36: aaaaaaa0035
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 37: aaaaaaa0036
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 38: aaaaaaa0037
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 39: aaaaaaa0038
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 40: aaaaaaa0039
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 41: aaaaaaa0040
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 42: aaaaaaa0041
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 43: aaaaaaa0042
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 44: aaaaaaa0043
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 45: aaaaaaa0044
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 46: aaaaaaa0045
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 47: aaaaaaa0046
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 48: aaaaaaa0047
		{x = 0, y = 0, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 49: aaaaaaa0048
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 50: aaaaaaa0049
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359}, -- 51: aaaaaaa0050
		{x = 0, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 52: aaaaaaa0051
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 53: aaaaaaa0052
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 54: aaaaaaa0053
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 55: aaaaaaa0054
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 56: aaaaaaa0055
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 57: aaaaaaa0056
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 58: aaaaaaa0057
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 59: aaaaaaa0058
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 60: aaaaaaa0059
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 61: aaaaaaa0060
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 62: aaaaaaa0061
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 63: aaaaaaa0062
		{x = 813, y = 359, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 64: aaaaaaa0063
		{x = 0, y = 0, width = 813, height = 358, offsetX = -2, offsetY = -1, offsetWidth = 815, offsetHeight = 359}, -- 65: aaaaaaa0064
		{x = 813, y = 0, width = 815, height = 359, offsetX = 0, offsetY = 0, offsetWidth = 815, offsetHeight = 359} -- 66: aaaaaaa0065
	},
	{
		["idle"] = {start = 1, stop = 33, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return AbotSystem
