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


local YCR = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("YCR")),
	{
		{x = 73, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: laugh_Instance0000
		{x = 73, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: laugh_Instance0001
		{x = 685, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: laugh_Instance0002
		{x = 685, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: laugh_Instance0003
		{x = 1297, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: laugh_Instance0004
		{x = 1297, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: laugh_Instance0005
		{x = 1909, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: laugh_Instance0006
		{x = 1909, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: laugh_Instance0007
		{x = 2521, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: laugh_Instance0008
		{x = 2521, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: laugh_Instance0009
		{x = 2521, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: laugh_Instance0010
		{x = 2521, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: laugh_Instance0011
		{x = 2521, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13: laugh_Instance0012
		{x = 2521, y = 73, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14: laugh_Instance0013
		{x = 3133, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 15: normal_down0000
		{x = 3133, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 16: normal_down0001
		{x = 3760, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 17: normal_down0002
		{x = 3760, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 18: normal_down0003
		{x = 4387, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: normal_down0004
		{x = 4387, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 20: normal_down0005
		{x = 5014, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 21: normal_down0006
		{x = 5014, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 22: normal_down0007
		{x = 5641, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 23: normal_down0008
		{x = 5641, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 24: normal_down0009
		{x = 6268, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: normal_down0010
		{x = 6268, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 26: normal_down0011
		{x = 6268, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 27: normal_down0012
		{x = 6268, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 28: normal_down0013
		{x = 6268, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 29: normal_down0014
		{x = 6268, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 30: normal_down0015
		{x = 6268, y = 73, width = 584, height = 639, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 31: normal_down0016
		{x = 6895, y = 73, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 32: normal_idle0000
		{x = 6895, y = 73, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 33: normal_idle0001
		{x = 7450, y = 73, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 34: normal_idle0002
		{x = 7450, y = 73, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 35: normal_idle0003
		{x = 73, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 36: normal_idle0004
		{x = 73, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 37: normal_idle0005
		{x = 628, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 38: normal_idle0006
		{x = 628, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 39: normal_idle0007
		{x = 1183, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 40: normal_idle0008
		{x = 1738, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 41: normal_idle0009
		{x = 2293, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 42: normal_idle0010
		{x = 2848, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 43: normal_idle0011
		{x = 3403, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 44: normal_idle0012
		{x = 3958, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 45: normal_idle0013
		{x = 4513, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 46: normal_idle0014
		{x = 5068, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 47: normal_idle0015
		{x = 5623, y = 854, width = 512, height = 738, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 48: normal_idle0016
		{x = 6178, y = 854, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 49: normal_left0000
		{x = 6178, y = 854, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 50: normal_left0001
		{x = 6933, y = 854, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 51: normal_left0002
		{x = 6933, y = 854, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 52: normal_left0003
		{x = 73, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 53: normal_left0004
		{x = 73, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 54: normal_left0005
		{x = 828, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 55: normal_left0006
		{x = 828, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 56: normal_left0007
		{x = 1583, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 57: normal_left0008
		{x = 1583, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 58: normal_left0009
		{x = 2338, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 59: normal_left0010
		{x = 2338, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 60: normal_left0011
		{x = 2338, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 61: normal_left0012
		{x = 2338, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 62: normal_left0013
		{x = 2338, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 63: normal_left0014
		{x = 2338, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 64: normal_left0015
		{x = 2338, y = 1635, width = 712, height = 683, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 65: normal_left0016
		{x = 3093, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 66: normal_right0000
		{x = 3093, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 67: normal_right0001
		{x = 3865, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 68: normal_right0002
		{x = 3865, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 69: normal_right0003
		{x = 4637, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 70: normal_right0004
		{x = 4637, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 71: normal_right0005
		{x = 5409, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 72: normal_right0006
		{x = 5409, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 73: normal_right0007
		{x = 6181, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 74: normal_right0008
		{x = 6181, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 75: normal_right0009
		{x = 6953, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 76: normal_right0010
		{x = 6953, y = 1635, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 77: normal_right0011
		{x = 73, y = 2361, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 78: normal_right0012
		{x = 73, y = 2361, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 79: normal_right0013
		{x = 73, y = 2361, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 80: normal_right0014
		{x = 73, y = 2361, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 81: normal_right0015
		{x = 73, y = 2361, width = 729, height = 619, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 82: normal_right0016
		{x = 845, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 83: normal_up0000
		{x = 845, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 84: normal_up0001
		{x = 1419, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 85: normal_up0002
		{x = 1419, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 86: normal_up0003
		{x = 1993, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 87: normal_up0004
		{x = 1993, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 88: normal_up0005
		{x = 2567, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 89: normal_up0006
		{x = 2567, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 90: normal_up0007
		{x = 3141, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 91: normal_up0008
		{x = 3141, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 92: normal_up0009
		{x = 3715, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 93: normal_up0010
		{x = 3715, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 94: normal_up0011
		{x = 2567, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 95: normal_up0012
		{x = 2567, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 96: normal_up0013
		{x = 2567, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 97: normal_up0014
		{x = 2567, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 98: normal_up0015
		{x = 2567, y = 2361, width = 531, height = 770, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 99: normal_up0016
		{x = 4289, y = 2361, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 100: scream0000
		{x = 5180, y = 2361, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 101: scream0001
		{x = 6071, y = 2361, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 102: scream0002
		{x = 6962, y = 2361, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 103: scream0003
		{x = 73, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 104: scream0004
		{x = 73, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 105: scream0005
		{x = 964, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 106: scream0006
		{x = 964, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 107: scream0007
		{x = 1855, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 108: scream0008
		{x = 1855, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 109: scream0009
		{x = 2746, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 110: scream0010
		{x = 2746, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 111: scream0011
		{x = 3637, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 112: scream0012
		{x = 3637, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 113: scream0013
		{x = 4528, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 114: scream0014
		{x = 4528, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 115: scream0015
		{x = 5419, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 116: scream0016
		{x = 5419, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 117: scream0017
		{x = 6310, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 118: scream0018
		{x = 6310, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 119: scream0019
		{x = 7201, y = 3174, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 120: scream0020
	},
	{
		["down alt"] = {start = 1, stop = 14, speed = 24, offsetX = 5, offsetY = -45}, --risita
		["down"] = {start = 15, stop = 31, speed = 24, offsetX = 0, offsetY = -20},
		["idle"] = {start = 32, stop = 48, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 49, stop = 65, speed = 24, offsetX = 20, offsetY = -40},
		["right"] = {start = 66, stop = 82, speed = 24, offsetX = -100, offsetY = -40},
		["up"] = {start = 83, stop = 99, speed = 24, offsetX = -40, offsetY = 45},
		["up alt"] = {start = 100, stop = 120, speed = 24, offsetX = 200, offsetY = -20} -- bebe chillador
	},
	"idle"
)
YCR.isSonicYCR = true
return YCR
