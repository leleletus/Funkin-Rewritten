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

local Pico_Fighting_Animations_V2 = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/char/Pico Fighting Animations V2")),
	{
		{x = 0, y = 0, width = 377, height = 466, offsetX = -156, offsetY = -163, offsetWidth = 812, offsetHeight = 664}, -- 1: Pico Fighting ALL ANIMS0000
		{x = 0, y = 0, width = 377, height = 466, offsetX = -156, offsetY = -163, offsetWidth = 812, offsetHeight = 664}, -- 2: Pico Fighting ALL ANIMS0001
		{x = 0, y = 0, width = 377, height = 466, offsetX = -156, offsetY = -163, offsetWidth = 812, offsetHeight = 664}, -- 3: Pico Fighting ALL ANIMS0002
		{x = 377, y = 0, width = 377, height = 466, offsetX = -156, offsetY = -163, offsetWidth = 812, offsetHeight = 664}, -- 4: Pico Fighting ALL ANIMS0003
		{x = 754, y = 0, width = 377, height = 468, offsetX = -156, offsetY = -161, offsetWidth = 812, offsetHeight = 664}, -- 5: Pico Fighting ALL ANIMS0004
		{x = 1131, y = 0, width = 377, height = 468, offsetX = -156, offsetY = -161, offsetWidth = 812, offsetHeight = 664}, -- 6: Pico Fighting ALL ANIMS0005
		{x = 1131, y = 0, width = 377, height = 468, offsetX = -156, offsetY = -161, offsetWidth = 812, offsetHeight = 664}, -- 7: Pico Fighting ALL ANIMS0006
		{x = 1508, y = 0, width = 377, height = 468, offsetX = -156, offsetY = -161, offsetWidth = 812, offsetHeight = 664}, -- 8: Pico Fighting ALL ANIMS0007
		{x = 1508, y = 0, width = 377, height = 468, offsetX = -156, offsetY = -161, offsetWidth = 812, offsetHeight = 664}, -- 9: Pico Fighting ALL ANIMS0008
		{x = 1885, y = 0, width = 377, height = 468, offsetX = -156, offsetY = -161, offsetWidth = 812, offsetHeight = 664}, -- 10: Pico Fighting ALL ANIMS0009
		{x = 2262, y = 0, width = 377, height = 463, offsetX = -156, offsetY = -166, offsetWidth = 812, offsetHeight = 664}, -- 11: Pico Fighting ALL ANIMS0010
		{x = 2639, y = 0, width = 377, height = 463, offsetX = -156, offsetY = -166, offsetWidth = 812, offsetHeight = 664}, -- 12: Pico Fighting ALL ANIMS0011
		{x = 2639, y = 0, width = 377, height = 463, offsetX = -156, offsetY = -166, offsetWidth = 812, offsetHeight = 664}, -- 13: Pico Fighting ALL ANIMS0012
		{x = 2639, y = 0, width = 377, height = 463, offsetX = -156, offsetY = -166, offsetWidth = 812, offsetHeight = 664}, -- 14: Pico Fighting ALL ANIMS0013
		{x = 3016, y = 0, width = 425, height = 471, offsetX = -174, offsetY = -157, offsetWidth = 812, offsetHeight = 664}, -- 15: Pico Fighting ALL ANIMS0014
		{x = 3016, y = 0, width = 425, height = 471, offsetX = -174, offsetY = -157, offsetWidth = 812, offsetHeight = 664}, -- 16: Pico Fighting ALL ANIMS0015
		{x = 3441, y = 0, width = 421, height = 473, offsetX = -173, offsetY = -155, offsetWidth = 812, offsetHeight = 664}, -- 17: Pico Fighting ALL ANIMS0016
		{x = 3441, y = 0, width = 421, height = 473, offsetX = -173, offsetY = -155, offsetWidth = 812, offsetHeight = 664}, -- 18: Pico Fighting ALL ANIMS0017
		{x = 3441, y = 0, width = 421, height = 473, offsetX = -173, offsetY = -155, offsetWidth = 812, offsetHeight = 664}, -- 19: Pico Fighting ALL ANIMS0018
		{x = 0, y = 473, width = 341, height = 459, offsetX = -183, offsetY = -176, offsetWidth = 812, offsetHeight = 664}, -- 20: Pico Fighting ALL ANIMS0019
		{x = 0, y = 473, width = 341, height = 459, offsetX = -183, offsetY = -176, offsetWidth = 812, offsetHeight = 664}, -- 21: Pico Fighting ALL ANIMS0020
		{x = 341, y = 473, width = 342, height = 452, offsetX = -181, offsetY = -180, offsetWidth = 812, offsetHeight = 664}, -- 22: Pico Fighting ALL ANIMS0021
		{x = 341, y = 473, width = 342, height = 452, offsetX = -181, offsetY = -180, offsetWidth = 812, offsetHeight = 664}, -- 23: Pico Fighting ALL ANIMS0022
		{x = 341, y = 473, width = 342, height = 452, offsetX = -181, offsetY = -180, offsetWidth = 812, offsetHeight = 664}, -- 24: Pico Fighting ALL ANIMS0023
		{x = 683, y = 473, width = 523, height = 456, offsetX = -4, offsetY = -174, offsetWidth = 812, offsetHeight = 664}, -- 25: Pico Fighting ALL ANIMS0024
		{x = 683, y = 473, width = 523, height = 456, offsetX = -4, offsetY = -174, offsetWidth = 812, offsetHeight = 664}, -- 26: Pico Fighting ALL ANIMS0025
		{x = 1206, y = 473, width = 489, height = 459, offsetX = -40, offsetY = -171, offsetWidth = 812, offsetHeight = 664}, -- 27: Pico Fighting ALL ANIMS0026
		{x = 1206, y = 473, width = 489, height = 459, offsetX = -40, offsetY = -171, offsetWidth = 812, offsetHeight = 664}, -- 28: Pico Fighting ALL ANIMS0027
		{x = 1695, y = 473, width = 505, height = 457, offsetX = -13, offsetY = -187, offsetWidth = 812, offsetHeight = 664}, -- 29: Pico Fighting ALL ANIMS0028
		{x = 1695, y = 473, width = 505, height = 457, offsetX = -13, offsetY = -187, offsetWidth = 812, offsetHeight = 664}, -- 30: Pico Fighting ALL ANIMS0029
		{x = 2200, y = 473, width = 487, height = 456, offsetX = -35, offsetY = -188, offsetWidth = 812, offsetHeight = 664}, -- 31: Pico Fighting ALL ANIMS0030
		{x = 2200, y = 473, width = 487, height = 456, offsetX = -35, offsetY = -188, offsetWidth = 812, offsetHeight = 664}, -- 32: Pico Fighting ALL ANIMS0031
		{x = 2687, y = 473, width = 510, height = 455, offsetX = -1, offsetY = -189, offsetWidth = 812, offsetHeight = 664}, -- 33: Pico Fighting ALL ANIMS0032
		{x = 2687, y = 473, width = 510, height = 455, offsetX = -1, offsetY = -189, offsetWidth = 812, offsetHeight = 664}, -- 34: Pico Fighting ALL ANIMS0033
		{x = 3197, y = 473, width = 486, height = 464, offsetX = -25, offsetY = -180, offsetWidth = 812, offsetHeight = 664}, -- 35: Pico Fighting ALL ANIMS0034
		{x = 3197, y = 473, width = 486, height = 464, offsetX = -25, offsetY = -180, offsetWidth = 812, offsetHeight = 664}, -- 36: Pico Fighting ALL ANIMS0035
		{x = 0, y = 937, width = 812, height = 446, offsetX = 0, offsetY = -190, offsetWidth = 812, offsetHeight = 664}, -- 37: Pico Fighting ALL ANIMS0036
		{x = 0, y = 937, width = 812, height = 446, offsetX = 0, offsetY = -190, offsetWidth = 812, offsetHeight = 664}, -- 38: Pico Fighting ALL ANIMS0037
		{x = 812, y = 937, width = 789, height = 449, offsetX = -23, offsetY = -187, offsetWidth = 812, offsetHeight = 664}, -- 39: Pico Fighting ALL ANIMS0038
		{x = 812, y = 937, width = 789, height = 449, offsetX = -23, offsetY = -187, offsetWidth = 812, offsetHeight = 664}, -- 40: Pico Fighting ALL ANIMS0039
		{x = 1601, y = 937, width = 520, height = 484, offsetX = -73, offsetY = -178, offsetWidth = 812, offsetHeight = 664}, -- 41: Pico Fighting ALL ANIMS0040
		{x = 1601, y = 937, width = 520, height = 484, offsetX = -73, offsetY = -178, offsetWidth = 812, offsetHeight = 664}, -- 42: Pico Fighting ALL ANIMS0041
		{x = 2121, y = 937, width = 396, height = 478, offsetX = -141, offsetY = -186, offsetWidth = 812, offsetHeight = 664}, -- 43: Pico Fighting ALL ANIMS0042
		{x = 2121, y = 937, width = 396, height = 478, offsetX = -141, offsetY = -186, offsetWidth = 812, offsetHeight = 664}, -- 44: Pico Fighting ALL ANIMS0043
		{x = 2517, y = 937, width = 419, height = 515, offsetX = -182, offsetY = -129, offsetWidth = 812, offsetHeight = 664}, -- 45: Pico Fighting ALL ANIMS0044
		{x = 2517, y = 937, width = 419, height = 515, offsetX = -182, offsetY = -129, offsetWidth = 812, offsetHeight = 664}, -- 46: Pico Fighting ALL ANIMS0045
		{x = 2936, y = 937, width = 375, height = 523, offsetX = -172, offsetY = -112, offsetWidth = 812, offsetHeight = 664}, -- 47: Pico Fighting ALL ANIMS0046
		{x = 2936, y = 937, width = 375, height = 523, offsetX = -172, offsetY = -112, offsetWidth = 812, offsetHeight = 664}, -- 48: Pico Fighting ALL ANIMS0047
		{x = 3311, y = 937, width = 418, height = 560, offsetX = -94, offsetY = -75, offsetWidth = 812, offsetHeight = 664}, -- 49: Pico Fighting ALL ANIMS0048
		{x = 0, y = 1497, width = 396, height = 642, offsetX = -105, offsetY = 0, offsetWidth = 812, offsetHeight = 664}, -- 50: Pico Fighting ALL ANIMS0049
		{x = 0, y = 1497, width = 396, height = 642, offsetX = -105, offsetY = 0, offsetWidth = 812, offsetHeight = 664}, -- 51: Pico Fighting ALL ANIMS0050
		{x = 396, y = 1497, width = 402, height = 492, offsetX = -126, offsetY = -152, offsetWidth = 812, offsetHeight = 664}, -- 52: Pico Fighting ALL ANIMS0051
		{x = 396, y = 1497, width = 402, height = 492, offsetX = -126, offsetY = -152, offsetWidth = 812, offsetHeight = 664}, -- 53: Pico Fighting ALL ANIMS0052
		{x = 798, y = 1497, width = 405, height = 491, offsetX = -126, offsetY = -153, offsetWidth = 812, offsetHeight = 664}, -- 54: Pico Fighting ALL ANIMS0053
		{x = 798, y = 1497, width = 405, height = 491, offsetX = -126, offsetY = -153, offsetWidth = 812, offsetHeight = 664}, -- 55: Pico Fighting ALL ANIMS0054
		{x = 1203, y = 1497, width = 406, height = 489, offsetX = -127, offsetY = -155, offsetWidth = 812, offsetHeight = 664}, -- 56: Pico Fighting ALL ANIMS0055
		{x = 1203, y = 1497, width = 406, height = 489, offsetX = -127, offsetY = -155, offsetWidth = 812, offsetHeight = 664}, -- 57: Pico Fighting ALL ANIMS0056
		{x = 1609, y = 1497, width = 423, height = 439, offsetX = -106, offsetY = -191, offsetWidth = 812, offsetHeight = 664}, -- 58: Pico Fighting ALL ANIMS0057
		{x = 1609, y = 1497, width = 423, height = 439, offsetX = -106, offsetY = -191, offsetWidth = 812, offsetHeight = 664}, -- 59: Pico Fighting ALL ANIMS0058
		{x = 2032, y = 1497, width = 434, height = 449, offsetX = -95, offsetY = -181, offsetWidth = 812, offsetHeight = 664}, -- 60: Pico Fighting ALL ANIMS0059
		{x = 2032, y = 1497, width = 434, height = 449, offsetX = -95, offsetY = -181, offsetWidth = 812, offsetHeight = 664}, -- 61: Pico Fighting ALL ANIMS0060
		{x = 2032, y = 1497, width = 434, height = 449, offsetX = -95, offsetY = -181, offsetWidth = 812, offsetHeight = 664}, -- 62: Pico Fighting ALL ANIMS0061
		{x = 2466, y = 1497, width = 376, height = 455, offsetX = -121, offsetY = -175, offsetWidth = 812, offsetHeight = 664}, -- 63: Pico Fighting ALL ANIMS0062
		{x = 2466, y = 1497, width = 376, height = 455, offsetX = -121, offsetY = -175, offsetWidth = 812, offsetHeight = 664}, -- 64: Pico Fighting ALL ANIMS0063
		{x = 2842, y = 1497, width = 348, height = 466, offsetX = -150, offsetY = -164, offsetWidth = 812, offsetHeight = 664}, -- 65: Pico Fighting ALL ANIMS0064
		{x = 2842, y = 1497, width = 348, height = 466, offsetX = -150, offsetY = -164, offsetWidth = 812, offsetHeight = 664}, -- 66: Pico Fighting ALL ANIMS0065
		{x = 2842, y = 1497, width = 348, height = 466, offsetX = -150, offsetY = -164, offsetWidth = 812, offsetHeight = 664}, -- 67: Pico Fighting ALL ANIMS0066
		{x = 3190, y = 1497, width = 348, height = 463, offsetX = -150, offsetY = -167, offsetWidth = 812, offsetHeight = 664}, -- 68: Pico Fighting ALL ANIMS0067
		{x = 3538, y = 1497, width = 448, height = 322, offsetX = -157, offsetY = -306, offsetWidth = 812, offsetHeight = 664}, -- 69: Pico Fighting ALL ANIMS0068
		{x = 3538, y = 1497, width = 448, height = 322, offsetX = -157, offsetY = -306, offsetWidth = 812, offsetHeight = 664}, -- 70: Pico Fighting ALL ANIMS0069
		{x = 0, y = 2139, width = 452, height = 331, offsetX = -146, offsetY = -297, offsetWidth = 812, offsetHeight = 664}, -- 71: Pico Fighting ALL ANIMS0070
		{x = 0, y = 2139, width = 452, height = 331, offsetX = -146, offsetY = -297, offsetWidth = 812, offsetHeight = 664}, -- 72: Pico Fighting ALL ANIMS0071
		{x = 0, y = 2139, width = 452, height = 331, offsetX = -146, offsetY = -297, offsetWidth = 812, offsetHeight = 664}, -- 73: Pico Fighting ALL ANIMS0072
		{x = 452, y = 2139, width = 453, height = 520, offsetX = -89, offsetY = -116, offsetWidth = 812, offsetHeight = 664}, -- 74: Pico Fighting ALL ANIMS0073
		{x = 905, y = 2139, width = 453, height = 520, offsetX = -89, offsetY = -116, offsetWidth = 812, offsetHeight = 664}, -- 75: Pico Fighting ALL ANIMS0074
		{x = 1358, y = 2139, width = 436, height = 506, offsetX = -110, offsetY = -130, offsetWidth = 812, offsetHeight = 664}, -- 76: Pico Fighting ALL ANIMS0075
		{x = 1794, y = 2139, width = 436, height = 506, offsetX = -110, offsetY = -130, offsetWidth = 812, offsetHeight = 664}, -- 77: Pico Fighting ALL ANIMS0076
		{x = 2230, y = 2139, width = 436, height = 506, offsetX = -110, offsetY = -130, offsetWidth = 812, offsetHeight = 664}, -- 78: Pico Fighting ALL ANIMS0077
		{x = 2666, y = 2139, width = 369, height = 465, offsetX = -165, offsetY = -152, offsetWidth = 812, offsetHeight = 664}, -- 79: Pico Fighting ALL ANIMS0078
		{x = 3035, y = 2139, width = 302, height = 435, offsetX = -230, offsetY = -177, offsetWidth = 812, offsetHeight = 664}, -- 80: Pico Fighting ALL ANIMS0079
		{x = 3337, y = 2139, width = 305, height = 434, offsetX = -232, offsetY = -183, offsetWidth = 812, offsetHeight = 664}, -- 81: Pico Fighting ALL ANIMS0080
		{x = 2666, y = 2139, width = 369, height = 465, offsetX = -165, offsetY = -152, offsetWidth = 812, offsetHeight = 664} -- 82: Pico Fighting ALL ANIMS0081
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0},
		["block"] = {start = 15, stop = 19, speed = 24, offsetX = 0, offsetY = 0},
		["dodge"] = {start = 20, stop = 24, speed = 24, offsetX = 0, offsetY = 0},
		["punchHigh1"] = {start = 25, stop = 28, speed = 24, offsetX = 0, offsetY = 0},
		["punchHigh2"] = {start = 29, stop = 32, speed = 24, offsetX = 0, offsetY = 0},
		["punchLow2"] = {start = 33, stop = 36, speed = 24, offsetX = 0, offsetY = 0},
		["punchLow1"] = {start = 37, stop = 40, speed = 24, offsetX = 0, offsetY = 0},
		["hitLow"] = {start = 41, stop = 44, speed = 24, offsetX = 0, offsetY = 0},
		["hitHigh"] = {start = 45, stop = 48, speed = 24, offsetX = 0, offsetY = 0},
		["uppercutHit"] = {start = 49, stop = 57, speed = 24, offsetX = 0, offsetY = 0},
		["fakeHit"] = {start = 58, stop = 62, speed = 24, offsetX = 0, offsetY = 0},
		["taunt"] = {start = 63, stop = 68, speed = 24, offsetX = 0, offsetY = 0},
		["uppercutPrep"] = {start = 69, stop = 73, speed = 24, offsetX = 0, offsetY = 0},
		["uppercutPunch"] = {start = 74, stop = 78, speed = 24, offsetX = 0, offsetY = 0},
		["hitSpin"] = {start = 79, stop = 82, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Pico_Fighting_Animations_V2