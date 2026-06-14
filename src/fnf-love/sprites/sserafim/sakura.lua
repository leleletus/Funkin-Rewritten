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


local sakura = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sserafim/char/sakura")),
	{
		{x = 1170, y = 687, width = 579, height = 684, offsetX = -316, offsetY = -28, offsetWidth = 1280, offsetHeight = 720}, -- 1: idle0000
		{x = 588, y = 687, width = 582, height = 685, offsetX = -313, offsetY = -27, offsetWidth = 1280, offsetHeight = 720}, -- 2: idle0001
		{x = 1764, y = 0, width = 580, height = 692, offsetX = -315, offsetY = -21, offsetWidth = 1280, offsetHeight = 720}, -- 3: idle0002
		{x = 0, y = 1373, width = 579, height = 693, offsetX = -316, offsetY = -20, offsetWidth = 1280, offsetHeight = 720}, -- 4: idle0003
		{x = 2344, y = 0, width = 578, height = 694, offsetX = -317, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 5: idle0004
		{x = 2344, y = 694, width = 578, height = 694, offsetX = -317, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 6: idle0005
		{x = 2344, y = 694, width = 578, height = 694, offsetX = -317, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 7: idle0006
		{x = 2344, y = 694, width = 578, height = 694, offsetX = -317, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 8: idle0007
		{x = 2187, y = 3463, width = 576, height = 654, offsetX = -318, offsetY = -63, offsetWidth = 1280, offsetHeight = 720}, -- 9: down0000
		{x = 2308, y = 2066, width = 576, height = 660, offsetX = -318, offsetY = -58, offsetWidth = 1280, offsetHeight = 720}, -- 10: down0001
		{x = 1732, y = 2066, width = 576, height = 661, offsetX = -318, offsetY = -57, offsetWidth = 1280, offsetHeight = 720}, -- 11: down0002
		{x = 1735, y = 1373, width = 582, height = 678, offsetX = -313, offsetY = -35, offsetWidth = 1280, offsetHeight = 720}, -- 12: left0000
		{x = 2922, y = 2040, width = 574, height = 681, offsetX = -321, offsetY = -32, offsetWidth = 1280, offsetHeight = 720}, -- 13: left0001
		{x = 2922, y = 1358, width = 574, height = 682, offsetX = -321, offsetY = -31, offsetWidth = 1280, offsetHeight = 720}, -- 14: left0002
		{x = 2713, y = 4159, width = 543, height = 695, offsetX = -351, offsetY = -18, offsetWidth = 1280, offsetHeight = 720}, -- 15: right0000
		{x = 1097, y = 3463, width = 545, height = 694, offsetX = -349, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 16: right0001
		{x = 1642, y = 3463, width = 545, height = 694, offsetX = -349, offsetY = -19, offsetWidth = 1280, offsetHeight = 720}, -- 17: right0002
		{x = 3503, y = 2157, width = 535, height = 721, offsetX = -360, offsetY = 2, offsetWidth = 1280, offsetHeight = 720}, -- 18: up0000
		{x = 3503, y = 716, width = 537, height = 720, offsetX = -358, offsetY = 2, offsetWidth = 1280, offsetHeight = 720}, -- 19: up0001
		{x = 4044, y = 0, width = 537, height = 718, offsetX = -358, offsetY = 0, offsetWidth = 1280, offsetHeight = 720}, -- 20: up0002
		{x = 2826, y = 2744, width = 576, height = 654, offsetX = -318, offsetY = -63, offsetWidth = 1280, offsetHeight = 720}, -- 21: down miss0000
		{x = 2248, y = 2744, width = 578, height = 663, offsetX = -314, offsetY = -53, offsetWidth = 1280, offsetHeight = 720}, -- 22: down miss0001
		{x = 1151, y = 2066, width = 581, height = 661, offsetX = -313, offsetY = -56, offsetWidth = 1280, offsetHeight = 720}, -- 23: down miss0002
		{x = 0, y = 2066, width = 582, height = 678, offsetX = -313, offsetY = -35, offsetWidth = 1280, offsetHeight = 720}, -- 24: left miss0000
		{x = 2922, y = 679, width = 581, height = 679, offsetX = -321, offsetY = -34, offsetWidth = 1280, offsetHeight = 720}, -- 25: left miss0001
		{x = 2922, y = 0, width = 581, height = 679, offsetX = -320, offsetY = -34, offsetWidth = 1280, offsetHeight = 720}, -- 26: left miss0002
		{x = 2170, y = 4159, width = 543, height = 695, offsetX = -351, offsetY = -18, offsetWidth = 1280, offsetHeight = 720}, -- 27: right miss0000
		{x = 549, y = 3463, width = 548, height = 696, offsetX = -346, offsetY = -20, offsetWidth = 1280, offsetHeight = 720}, -- 28: right miss0001
		{x = 0, y = 3463, width = 549, height = 696, offsetX = -346, offsetY = -20, offsetWidth = 1280, offsetHeight = 720}, -- 29: right miss0002
		{x = 3503, y = 1436, width = 535, height = 721, offsetX = -360, offsetY = 2, offsetWidth = 1280, offsetHeight = 720}, -- 30: up miss0000
		{x = 3503, y = 0, width = 541, height = 716, offsetX = -360, offsetY = -2, offsetWidth = 1280, offsetHeight = 720}, -- 31: up miss0001
		{x = 0, y = 2744, width = 543, height = 719, offsetX = -356, offsetY = 2, offsetWidth = 1280, offsetHeight = 720}, -- 32: up miss0002
		{x = 582, y = 2066, width = 569, height = 677, offsetX = -325, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 33: down-bf0000
		{x = 1682, y = 2744, width = 566, height = 680, offsetX = -328, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 34: down-bf0001
		{x = 1116, y = 2744, width = 566, height = 680, offsetX = -328, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 35: down-bf0002
		{x = 1116, y = 2744, width = 566, height = 680, offsetX = -328, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 36: down-bf0003
		{x = 1116, y = 2744, width = 566, height = 680, offsetX = -328, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 37: down-bf0004
		{x = 1116, y = 2744, width = 566, height = 680, offsetX = -328, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 38: down-bf0005
		{x = 1176, y = 0, width = 588, height = 686, offsetX = -307, offsetY = -27, offsetWidth = 1280, offsetHeight = 720}, -- 39: left-bf0000
		{x = 588, y = 0, width = 588, height = 687, offsetX = -307, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 40: left-bf0001
		{x = 0, y = 0, width = 588, height = 687, offsetX = -307, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 41: left-bf0002
		{x = 0, y = 0, width = 588, height = 687, offsetX = -307, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 42: left-bf0003
		{x = 0, y = 0, width = 588, height = 687, offsetX = -307, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 43: left-bf0004
		{x = 0, y = 0, width = 588, height = 687, offsetX = -307, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 44: left-bf0005
		{x = 1628, y = 4159, width = 542, height = 697, offsetX = -352, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 45: right-bf0000
		{x = 543, y = 4159, width = 543, height = 697, offsetX = -351, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 46: right-bf0001
		{x = 0, y = 4159, width = 543, height = 697, offsetX = -351, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 47: right-bf0002
		{x = 0, y = 4159, width = 543, height = 697, offsetX = -351, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 48: right-bf0003
		{x = 0, y = 4159, width = 543, height = 697, offsetX = -351, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 49: right-bf0004
		{x = 0, y = 4159, width = 543, height = 697, offsetX = -351, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 50: right-bf0005
		{x = 4581, y = 2105, width = 535, height = 711, offsetX = -360, offsetY = -8, offsetWidth = 1280, offsetHeight = 720}, -- 51: up-bf0000
		{x = 4044, y = 1426, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 52: up-bf0001
		{x = 4581, y = 2816, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 53: up-bf0002
		{x = 4581, y = 2816, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 54: up-bf0003
		{x = 4581, y = 2816, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 55: up-bf0004
		{x = 4581, y = 2816, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 56: up-bf0005
		{x = 2344, y = 1388, width = 574, height = 677, offsetX = -320, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 57: down-bf-alt0000
		{x = 1764, y = 692, width = 573, height = 680, offsetX = -321, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 58: down-bf-alt0001
		{x = 543, y = 2744, width = 573, height = 680, offsetX = -321, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 59: down-bf-alt0002
		{x = 543, y = 2744, width = 573, height = 680, offsetX = -321, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 60: down-bf-alt0003
		{x = 543, y = 2744, width = 573, height = 680, offsetX = -321, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 61: down-bf-alt0004
		{x = 543, y = 2744, width = 573, height = 680, offsetX = -321, offsetY = -38, offsetWidth = 1280, offsetHeight = 720}, -- 62: down-bf-alt0005
		{x = 0, y = 687, width = 588, height = 686, offsetX = -307, offsetY = -27, offsetWidth = 1280, offsetHeight = 720}, -- 63: left-bf-alt0000
		{x = 1157, y = 1373, width = 578, height = 687, offsetX = -317, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 64: left-bf-alt0001
		{x = 579, y = 1373, width = 578, height = 687, offsetX = -317, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 65: left-bf-alt0002
		{x = 579, y = 1373, width = 578, height = 687, offsetX = -317, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 66: left-bf-alt0003
		{x = 579, y = 1373, width = 578, height = 687, offsetX = -317, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 67: left-bf-alt0004
		{x = 579, y = 1373, width = 578, height = 687, offsetX = -317, offsetY = -26, offsetWidth = 1280, offsetHeight = 720}, -- 68: left-bf-alt0005
		{x = 1086, y = 4159, width = 542, height = 697, offsetX = -351, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 69: right-bf-alt0000
		{x = 4581, y = 697, width = 546, height = 697, offsetX = -348, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 70: right-bf-alt0001
		{x = 4581, y = 0, width = 546, height = 697, offsetX = -348, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 71: right-bf-alt0002
		{x = 4581, y = 0, width = 546, height = 697, offsetX = -348, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 72: right-bf-alt0003
		{x = 4581, y = 0, width = 546, height = 697, offsetX = -348, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 73: right-bf-alt0004
		{x = 4581, y = 0, width = 546, height = 697, offsetX = -348, offsetY = -16, offsetWidth = 1280, offsetHeight = 720}, -- 74: right-bf-alt0005
		{x = 4581, y = 1394, width = 535, height = 711, offsetX = -360, offsetY = -8, offsetWidth = 1280, offsetHeight = 720}, -- 75: up-bf-alt0000
		{x = 4044, y = 2134, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 76: up-bf-alt0001
		{x = 4044, y = 718, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 77: up-bf-alt0002
		{x = 4044, y = 718, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 78: up-bf-alt0003
		{x = 4044, y = 718, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 79: up-bf-alt0004
		{x = 4044, y = 718, width = 537, height = 708, offsetX = -358, offsetY = -10, offsetWidth = 1280, offsetHeight = 720}, -- 80: up-bf-alt0005
	},
	{
		["idle"] = {start = 1, stop = 8, speed = 12, offsetX = 0, offsetY = 0},
		["down"] = {start = 9, stop = 11, speed = 12, offsetX = 0, offsetY = 0},
		["left"] = {start = 12, stop = 14, speed = 12, offsetX = 0, offsetY = 0},
		["right"] = {start = 15, stop = 17, speed = 12, offsetX = 0, offsetY = 0},
		["up"] = {start = 18, stop = 20, speed = 12, offsetX = 0, offsetY = 0},
		["miss down"] = {start = 21, stop = 23, speed = 12, offsetX = 0, offsetY = 0},
		["miss left"] = {start = 24, stop = 26, speed = 12, offsetX = 0, offsetY = 0},
		["miss right"] = {start = 27, stop = 29, speed = 12, offsetX = 0, offsetY = 0},
		["miss up"] = {start = 30, stop = 32, speed = 12, offsetX = 0, offsetY = 0},
		--bf
		["down bf"] = {start = 33, stop = 38, speed = 12, offsetX = 0, offsetY = 0},
		["left bf"] = {start = 39, stop = 44, speed = 12, offsetX = 0, offsetY = 0},
		["right bf"] = {start = 45, stop = 50, speed = 12, offsetX = 0, offsetY = 0},
		["up bf"] = {start = 51, stop = 56, speed = 12, offsetX = 0, offsetY = 0},
		--bf alt
		["down alt"] = {start = 57, stop = 62, speed = 12, offsetX = 0, offsetY = 0},
		["left alt"] = {start = 63, stop = 68, speed = 12, offsetX = 0, offsetY = 0},
		["right alt"] = {start = 69, stop = 74, speed = 12, offsetX = 0, offsetY = 0},
		["up alt"] = {start = 75, stop = 80, speed = 12, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return sakura
