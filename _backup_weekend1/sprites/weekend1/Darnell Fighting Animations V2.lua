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

local Darnell_Fighting_Animations_V2 = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/char/Darnell Fighting Animations V2")),
	{
		{x = 0, y = 0, width = 388, height = 488, offsetX = -120, offsetY = -136, offsetWidth = 709, offsetHeight = 643}, -- 1: Darnell Fighting ALL ANIMS0000
		{x = 0, y = 0, width = 388, height = 488, offsetX = -120, offsetY = -136, offsetWidth = 709, offsetHeight = 643}, -- 2: Darnell Fighting ALL ANIMS0001
		{x = 388, y = 0, width = 388, height = 488, offsetX = -120, offsetY = -136, offsetWidth = 709, offsetHeight = 643}, -- 3: Darnell Fighting ALL ANIMS0002
		{x = 776, y = 0, width = 390, height = 488, offsetX = -121, offsetY = -136, offsetWidth = 709, offsetHeight = 643}, -- 4: Darnell Fighting ALL ANIMS0003
		{x = 1166, y = 0, width = 390, height = 493, offsetX = -121, offsetY = -131, offsetWidth = 709, offsetHeight = 643}, -- 5: Darnell Fighting ALL ANIMS0004
		{x = 1166, y = 0, width = 390, height = 493, offsetX = -121, offsetY = -131, offsetWidth = 709, offsetHeight = 643}, -- 6: Darnell Fighting ALL ANIMS0005
		{x = 1556, y = 0, width = 384, height = 501, offsetX = -126, offsetY = -123, offsetWidth = 709, offsetHeight = 643}, -- 7: Darnell Fighting ALL ANIMS0006
		{x = 1556, y = 0, width = 384, height = 501, offsetX = -126, offsetY = -123, offsetWidth = 709, offsetHeight = 643}, -- 8: Darnell Fighting ALL ANIMS0007
		{x = 1940, y = 0, width = 384, height = 503, offsetX = -126, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 9: Darnell Fighting ALL ANIMS0008
		{x = 2324, y = 0, width = 386, height = 503, offsetX = -126, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 10: Darnell Fighting ALL ANIMS0009
		{x = 2324, y = 0, width = 386, height = 503, offsetX = -126, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 11: Darnell Fighting ALL ANIMS0010
		{x = 2710, y = 0, width = 387, height = 504, offsetX = -123, offsetY = -120, offsetWidth = 709, offsetHeight = 643}, -- 12: Darnell Fighting ALL ANIMS0011
		{x = 2710, y = 0, width = 387, height = 504, offsetX = -123, offsetY = -120, offsetWidth = 709, offsetHeight = 643}, -- 13: Darnell Fighting ALL ANIMS0012
		{x = 2710, y = 0, width = 387, height = 504, offsetX = -123, offsetY = -120, offsetWidth = 709, offsetHeight = 643}, -- 14: Darnell Fighting ALL ANIMS0013
		{x = 3097, y = 0, width = 477, height = 326, offsetX = -69, offsetY = -287, offsetWidth = 709, offsetHeight = 643}, -- 15: Darnell Fighting ALL ANIMS0014
		{x = 3097, y = 0, width = 477, height = 326, offsetX = -69, offsetY = -287, offsetWidth = 709, offsetHeight = 643}, -- 16: Darnell Fighting ALL ANIMS0015
		{x = 3574, y = 0, width = 479, height = 337, offsetX = -77, offsetY = -276, offsetWidth = 709, offsetHeight = 643}, -- 17: Darnell Fighting ALL ANIMS0016
		{x = 3574, y = 0, width = 479, height = 337, offsetX = -77, offsetY = -276, offsetWidth = 709, offsetHeight = 643}, -- 18: Darnell Fighting ALL ANIMS0017
		{x = 3574, y = 0, width = 479, height = 337, offsetX = -77, offsetY = -276, offsetWidth = 709, offsetHeight = 643}, -- 19: Darnell Fighting ALL ANIMS0018
		{x = 0, y = 504, width = 476, height = 531, offsetX = -130, offsetY = -82, offsetWidth = 709, offsetHeight = 643}, -- 20: Darnell Fighting ALL ANIMS0019
		{x = 476, y = 504, width = 476, height = 531, offsetX = -130, offsetY = -82, offsetWidth = 709, offsetHeight = 643}, -- 21: Darnell Fighting ALL ANIMS0020
		{x = 952, y = 504, width = 458, height = 521, offsetX = -125, offsetY = -92, offsetWidth = 709, offsetHeight = 643}, -- 22: Darnell Fighting ALL ANIMS0021
		{x = 1410, y = 504, width = 458, height = 521, offsetX = -125, offsetY = -92, offsetWidth = 709, offsetHeight = 643}, -- 23: Darnell Fighting ALL ANIMS0022
		{x = 1868, y = 504, width = 458, height = 521, offsetX = -125, offsetY = -92, offsetWidth = 709, offsetHeight = 643}, -- 24: Darnell Fighting ALL ANIMS0023
		{x = 2326, y = 504, width = 480, height = 426, offsetX = -122, offsetY = -195, offsetWidth = 709, offsetHeight = 643}, -- 25: Darnell Fighting ALL ANIMS0024
		{x = 2326, y = 504, width = 480, height = 426, offsetX = -122, offsetY = -195, offsetWidth = 709, offsetHeight = 643}, -- 26: Darnell Fighting ALL ANIMS0025
		{x = 2806, y = 504, width = 469, height = 431, offsetX = -120, offsetY = -190, offsetWidth = 709, offsetHeight = 643}, -- 27: Darnell Fighting ALL ANIMS0026
		{x = 2806, y = 504, width = 469, height = 431, offsetX = -120, offsetY = -190, offsetWidth = 709, offsetHeight = 643}, -- 28: Darnell Fighting ALL ANIMS0027
		{x = 2806, y = 504, width = 469, height = 431, offsetX = -120, offsetY = -190, offsetWidth = 709, offsetHeight = 643}, -- 29: Darnell Fighting ALL ANIMS0028
		{x = 3275, y = 504, width = 410, height = 515, offsetX = -83, offsetY = -116, offsetWidth = 709, offsetHeight = 643}, -- 30: Darnell Fighting ALL ANIMS0029
		{x = 3275, y = 504, width = 410, height = 515, offsetX = -83, offsetY = -116, offsetWidth = 709, offsetHeight = 643}, -- 31: Darnell Fighting ALL ANIMS0030
		{x = 3685, y = 504, width = 394, height = 513, offsetX = -103, offsetY = -118, offsetWidth = 709, offsetHeight = 643}, -- 32: Darnell Fighting ALL ANIMS0031
		{x = 3685, y = 504, width = 394, height = 513, offsetX = -103, offsetY = -118, offsetWidth = 709, offsetHeight = 643}, -- 33: Darnell Fighting ALL ANIMS0032
		{x = 0, y = 1035, width = 537, height = 503, offsetX = -172, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 34: Darnell Fighting ALL ANIMS0033
		{x = 0, y = 1035, width = 537, height = 503, offsetX = -172, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 35: Darnell Fighting ALL ANIMS0034
		{x = 537, y = 1035, width = 512, height = 503, offsetX = -169, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 36: Darnell Fighting ALL ANIMS0035
		{x = 537, y = 1035, width = 512, height = 503, offsetX = -169, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 37: Darnell Fighting ALL ANIMS0036
		{x = 537, y = 1035, width = 512, height = 503, offsetX = -169, offsetY = -121, offsetWidth = 709, offsetHeight = 643}, -- 38: Darnell Fighting ALL ANIMS0037
		{x = 1049, y = 1035, width = 527, height = 473, offsetX = -167, offsetY = -148, offsetWidth = 709, offsetHeight = 643}, -- 39: Darnell Fighting ALL ANIMS0038
		{x = 1049, y = 1035, width = 527, height = 473, offsetX = -167, offsetY = -148, offsetWidth = 709, offsetHeight = 643}, -- 40: Darnell Fighting ALL ANIMS0039
		{x = 1576, y = 1035, width = 505, height = 469, offsetX = -166, offsetY = -152, offsetWidth = 709, offsetHeight = 643}, -- 41: Darnell Fighting ALL ANIMS0040
		{x = 1576, y = 1035, width = 505, height = 469, offsetX = -166, offsetY = -152, offsetWidth = 709, offsetHeight = 643}, -- 42: Darnell Fighting ALL ANIMS0041
		{x = 1576, y = 1035, width = 505, height = 469, offsetX = -166, offsetY = -152, offsetWidth = 709, offsetHeight = 643}, -- 43: Darnell Fighting ALL ANIMS0042
		{x = 2081, y = 1035, width = 525, height = 447, offsetX = -178, offsetY = -166, offsetWidth = 709, offsetHeight = 643}, -- 44: Darnell Fighting ALL ANIMS0043
		{x = 2081, y = 1035, width = 525, height = 447, offsetX = -178, offsetY = -166, offsetWidth = 709, offsetHeight = 643}, -- 45: Darnell Fighting ALL ANIMS0044
		{x = 2606, y = 1035, width = 508, height = 456, offsetX = -176, offsetY = -157, offsetWidth = 709, offsetHeight = 643}, -- 46: Darnell Fighting ALL ANIMS0045
		{x = 2606, y = 1035, width = 508, height = 456, offsetX = -176, offsetY = -157, offsetWidth = 709, offsetHeight = 643}, -- 47: Darnell Fighting ALL ANIMS0046
		{x = 2606, y = 1035, width = 508, height = 456, offsetX = -176, offsetY = -157, offsetWidth = 709, offsetHeight = 643}, -- 48: Darnell Fighting ALL ANIMS0047
		{x = 3114, y = 1035, width = 513, height = 442, offsetX = -189, offsetY = -182, offsetWidth = 709, offsetHeight = 643}, -- 49: Darnell Fighting ALL ANIMS0048
		{x = 3114, y = 1035, width = 513, height = 442, offsetX = -189, offsetY = -182, offsetWidth = 709, offsetHeight = 643}, -- 50: Darnell Fighting ALL ANIMS0049
		{x = 0, y = 1538, width = 492, height = 448, offsetX = -186, offsetY = -176, offsetWidth = 709, offsetHeight = 643}, -- 51: Darnell Fighting ALL ANIMS0050
		{x = 0, y = 1538, width = 492, height = 448, offsetX = -186, offsetY = -176, offsetWidth = 709, offsetHeight = 643}, -- 52: Darnell Fighting ALL ANIMS0051
		{x = 0, y = 1538, width = 492, height = 448, offsetX = -186, offsetY = -176, offsetWidth = 709, offsetHeight = 643}, -- 53: Darnell Fighting ALL ANIMS0052
		{x = 492, y = 1538, width = 373, height = 456, offsetX = -170, offsetY = -165, offsetWidth = 709, offsetHeight = 643}, -- 54: Darnell Fighting ALL ANIMS0053
		{x = 492, y = 1538, width = 373, height = 456, offsetX = -170, offsetY = -165, offsetWidth = 709, offsetHeight = 643}, -- 55: Darnell Fighting ALL ANIMS0054
		{x = 865, y = 1538, width = 374, height = 457, offsetX = -167, offsetY = -161, offsetWidth = 709, offsetHeight = 643}, -- 56: Darnell Fighting ALL ANIMS0055
		{x = 865, y = 1538, width = 374, height = 457, offsetX = -167, offsetY = -161, offsetWidth = 709, offsetHeight = 643}, -- 57: Darnell Fighting ALL ANIMS0056
		{x = 865, y = 1538, width = 374, height = 457, offsetX = -167, offsetY = -161, offsetWidth = 709, offsetHeight = 643}, -- 58: Darnell Fighting ALL ANIMS0057
		{x = 1239, y = 1538, width = 446, height = 570, offsetX = -92, offsetY = -39, offsetWidth = 709, offsetHeight = 643}, -- 59: Darnell Fighting ALL ANIMS0058
		{x = 1239, y = 1538, width = 446, height = 570, offsetX = -92, offsetY = -39, offsetWidth = 709, offsetHeight = 643}, -- 60: Darnell Fighting ALL ANIMS0059
		{x = 1685, y = 1538, width = 423, height = 573, offsetX = -111, offsetY = -41, offsetWidth = 709, offsetHeight = 643}, -- 61: Darnell Fighting ALL ANIMS0060
		{x = 1685, y = 1538, width = 423, height = 573, offsetX = -111, offsetY = -41, offsetWidth = 709, offsetHeight = 643}, -- 62: Darnell Fighting ALL ANIMS0061
		{x = 1685, y = 1538, width = 423, height = 573, offsetX = -111, offsetY = -41, offsetWidth = 709, offsetHeight = 643}, -- 63: Darnell Fighting ALL ANIMS0062
		{x = 2108, y = 1538, width = 630, height = 456, offsetX = 0, offsetY = -172, offsetWidth = 709, offsetHeight = 643}, -- 64: Darnell Fighting ALL ANIMS0063
		{x = 2108, y = 1538, width = 630, height = 456, offsetX = 0, offsetY = -172, offsetWidth = 709, offsetHeight = 643}, -- 65: Darnell Fighting ALL ANIMS0064
		{x = 2738, y = 1538, width = 408, height = 479, offsetX = -143, offsetY = -148, offsetWidth = 709, offsetHeight = 643}, -- 66: Darnell Fighting ALL ANIMS0065
		{x = 2738, y = 1538, width = 408, height = 479, offsetX = -143, offsetY = -148, offsetWidth = 709, offsetHeight = 643}, -- 67: Darnell Fighting ALL ANIMS0066
		{x = 3146, y = 1538, width = 324, height = 496, offsetX = -151, offsetY = -130, offsetWidth = 709, offsetHeight = 643}, -- 68: Darnell Fighting ALL ANIMS0067
		{x = 3146, y = 1538, width = 324, height = 496, offsetX = -151, offsetY = -130, offsetWidth = 709, offsetHeight = 643}, -- 69: Darnell Fighting ALL ANIMS0068
		{x = 3470, y = 1538, width = 333, height = 503, offsetX = -146, offsetY = -122, offsetWidth = 709, offsetHeight = 643}, -- 70: Darnell Fighting ALL ANIMS0069
		{x = 3470, y = 1538, width = 333, height = 503, offsetX = -146, offsetY = -122, offsetWidth = 709, offsetHeight = 643}, -- 71: Darnell Fighting ALL ANIMS0070
		{x = 0, y = 2111, width = 378, height = 556, offsetX = -172, offsetY = -87, offsetWidth = 709, offsetHeight = 643}, -- 72: Darnell Fighting ALL ANIMS0071
		{x = 378, y = 2111, width = 342, height = 570, offsetX = -144, offsetY = -68, offsetWidth = 709, offsetHeight = 643}, -- 73: Darnell Fighting ALL ANIMS0072
		{x = 720, y = 2111, width = 419, height = 540, offsetX = -124, offsetY = -82, offsetWidth = 709, offsetHeight = 643}, -- 74: Darnell Fighting ALL ANIMS0073
		{x = 1139, y = 2111, width = 334, height = 479, offsetX = -143, offsetY = -140, offsetWidth = 709, offsetHeight = 643}, -- 75: Darnell Fighting ALL ANIMS0074
		{x = 1139, y = 2111, width = 334, height = 479, offsetX = -143, offsetY = -140, offsetWidth = 709, offsetHeight = 643}, -- 76: Darnell Fighting ALL ANIMS0075
		{x = 1473, y = 2111, width = 328, height = 482, offsetX = -146, offsetY = -137, offsetWidth = 709, offsetHeight = 643}, -- 77: Darnell Fighting ALL ANIMS0076
		{x = 1473, y = 2111, width = 328, height = 482, offsetX = -146, offsetY = -137, offsetWidth = 709, offsetHeight = 643}, -- 78: Darnell Fighting ALL ANIMS0077
		{x = 1473, y = 2111, width = 328, height = 482, offsetX = -146, offsetY = -137, offsetWidth = 709, offsetHeight = 643}, -- 79: Darnell Fighting ALL ANIMS0078
		{x = 1801, y = 2111, width = 451, height = 575, offsetX = -110, offsetY = -43, offsetWidth = 709, offsetHeight = 643}, -- 80: Darnell Fighting ALL ANIMS0079
		{x = 2252, y = 2111, width = 406, height = 626, offsetX = -120, offsetY = 0, offsetWidth = 709, offsetHeight = 643}, -- 81: Darnell Fighting ALL ANIMS0080
		{x = 2252, y = 2111, width = 406, height = 626, offsetX = -120, offsetY = 0, offsetWidth = 709, offsetHeight = 643}, -- 82: Darnell Fighting ALL ANIMS0081
		{x = 2658, y = 2111, width = 408, height = 502, offsetX = -103, offsetY = -129, offsetWidth = 709, offsetHeight = 643}, -- 83: Darnell Fighting ALL ANIMS0082
		{x = 2658, y = 2111, width = 408, height = 502, offsetX = -103, offsetY = -129, offsetWidth = 709, offsetHeight = 643}, -- 84: Darnell Fighting ALL ANIMS0083
		{x = 3066, y = 2111, width = 411, height = 497, offsetX = -100, offsetY = -134, offsetWidth = 709, offsetHeight = 643}, -- 85: Darnell Fighting ALL ANIMS0084
		{x = 3066, y = 2111, width = 411, height = 497, offsetX = -100, offsetY = -134, offsetWidth = 709, offsetHeight = 643}, -- 86: Darnell Fighting ALL ANIMS0085
		{x = 3477, y = 2111, width = 413, height = 493, offsetX = -98, offsetY = -137, offsetWidth = 709, offsetHeight = 643}, -- 87: Darnell Fighting ALL ANIMS0086
		{x = 3477, y = 2111, width = 413, height = 493, offsetX = -98, offsetY = -137, offsetWidth = 709, offsetHeight = 643}, -- 88: Darnell Fighting ALL ANIMS0087
		{x = 3477, y = 2111, width = 413, height = 493, offsetX = -98, offsetY = -137, offsetWidth = 709, offsetHeight = 643} -- 89: Darnell Fighting ALL ANIMS0088
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0},
		["uppercutPrep"] = {start = 15, stop = 19, speed = 24, offsetX = 0, offsetY = 0},
		["uppercutPunch"] = {start = 20, stop = 24, speed = 24, offsetX = 0, offsetY = 0},
		["fakeHit"] = {start = 25, stop = 29, speed = 24, offsetX = 0, offsetY = 0},
		["block"] = {start = 30, stop = 33, speed = 24, offsetX = 0, offsetY = 0},
		["punchHigh1"] = {start = 34, stop = 38, speed = 24, offsetX = 0, offsetY = 0},
		["punchHigh2"] = {start = 39, stop = 43, speed = 24, offsetX = 0, offsetY = 0},
		["punchLow2"] = {start = 44, stop = 48, speed = 24, offsetX = 0, offsetY = 0},
		["punchLow1"] = {start = 49, stop = 53, speed = 24, offsetX = 0, offsetY = 0},
		["dodge"] = {start = 54, stop = 58, speed = 24, offsetX = 0, offsetY = 0},
		["hitHigh"] = {start = 59, stop = 63, speed = 24, offsetX = 0, offsetY = 0},
		["hitLow"] = {start = 64, stop = 67, speed = 24, offsetX = 0, offsetY = 0},
		["cringe"] = {start = 68, stop = 71, speed = 24, offsetX = 0, offsetY = 0},
		["hitSpin"] = {start = 72, stop = 74, speed = 24, offsetX = 0, offsetY = 0},
		["pissed"] = {start = 75, stop = 79, speed = 24, offsetX = 0, offsetY = 0},
		["uppercutHit"] = {start = 80, stop = 89, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Darnell_Fighting_Animations_V2