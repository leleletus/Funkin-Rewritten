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


local speech_bubble = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("dialogue/speech_bubble")),
	{
		{x = 4, y = 4, width = 1231, height = 408, offsetX = -9, offsetY = -5, offsetWidth = 1241, offsetHeight = 421}, -- 1: AHH speech bubble0000
		{x = 1239, y = 4, width = 1228, height = 421, offsetX = -9, offsetY = 0, offsetWidth = 1241, offsetHeight = 421}, -- 2: AHH speech bubble0001
		{x = 2471, y = 4, width = 1241, height = 393, offsetX = 0, offsetY = -15, offsetWidth = 1241, offsetHeight = 421}, -- 3: AHH speech bubble0002
		{x = 4, y = 429, width = 1231, height = 381, offsetX = -9, offsetY = 0, offsetWidth = 1241, offsetHeight = 389}, -- 4: AHH Speech Bubble middle0000
		{x = 1239, y = 429, width = 1228, height = 389, offsetX = -9, offsetY = 0, offsetWidth = 1241, offsetHeight = 389}, -- 5: AHH Speech Bubble middle0001
		{x = 2471, y = 429, width = 1241, height = 376, offsetX = 0, offsetY = 0, offsetWidth = 1241, offsetHeight = 389}, -- 6: AHH Speech Bubble middle0002
		{x = 3716, y = 429, width = 16, height = 122, offsetX = -589, offsetY = 0, offsetWidth = 1163, offsetHeight = 333}, -- 7: Speech Bubble Middle Open0000
		{x = 3736, y = 429, width = 317, height = 195, offsetX = -439, offsetY = -11, offsetWidth = 1163, offsetHeight = 333}, -- 8: Speech Bubble Middle Open0001
		{x = 4, y = 822, width = 826, height = 275, offsetX = -158, offsetY = -15, offsetWidth = 1163, offsetHeight = 333}, -- 9: Speech Bubble Middle Open0002
		{x = 834, y = 822, width = 1163, height = 303, offsetX = 0, offsetY = -30, offsetWidth = 1163, offsetHeight = 333}, -- 10: Speech Bubble Middle Open0003
		{x = 2001, y = 822, width = 40, height = 118, offsetX = -918, offsetY = 0, offsetWidth = 1163, offsetHeight = 330}, -- 11: Speech Bubble Normal Open0000
		{x = 2045, y = 822, width = 318, height = 201, offsetX = -735, offsetY = -5, offsetWidth = 1163, offsetHeight = 330}, -- 12: Speech Bubble Normal Open0001
		{x = 2367, y = 822, width = 835, height = 283, offsetX = -287, offsetY = -4, offsetWidth = 1163, offsetHeight = 330}, -- 13: Speech Bubble Normal Open0002
		{x = 4, y = 1129, width = 1163, height = 315, offsetX = 0, offsetY = -15, offsetWidth = 1163, offsetHeight = 330}, -- 14: Speech Bubble Normal Open0003
		{x = 4, y = 1129, width = 1163, height = 315, offsetX = 0, offsetY = -15, offsetWidth = 1163, offsetHeight = 330}, -- 15: Speech Bubble Normal Open0004
		{x = 1175, y = 1129, width = 335, height = 295, offsetX = -655, offsetY = -69, offsetWidth = 1175, offsetHeight = 436}, -- 16: speech bubble loud open0000
		{x = 1514, y = 1129, width = 421, height = 287, offsetX = -586, offsetY = -103, offsetWidth = 1175, offsetHeight = 436}, -- 17: speech bubble loud open0001
		{x = 1939, y = 1129, width = 1124, height = 387, offsetX = -13, offsetY = -36, offsetWidth = 1175, offsetHeight = 436}, -- 18: speech bubble loud open0002
		{x = 4, y = 1520, width = 1175, height = 436, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: speech bubble loud open0003
		{x = 1183, y = 1520, width = 334, height = 296, offsetX = -417, offsetY = -51, offsetWidth = 1137, offsetHeight = 412}, -- 20: speech bubble Middle loud open0000
		{x = 1521, y = 1520, width = 421, height = 287, offsetX = -345, offsetY = -95, offsetWidth = 1137, offsetHeight = 412}, -- 21: speech bubble Middle loud open0001
		{x = 1946, y = 1520, width = 1124, height = 387, offsetX = -13, offsetY = -12, offsetWidth = 1137, offsetHeight = 412}, -- 22: speech bubble Middle loud open0002
		{x = 4, y = 1960, width = 1107, height = 412, offsetX = 0, offsetY = 0, offsetWidth = 1137, offsetHeight = 412}, -- 23: speech bubble Middle loud open0003
		{x = 1115, y = 1960, width = 1162, height = 319, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 319}, -- 24: speech bubble middle0000
		{x = 1115, y = 1960, width = 1162, height = 319, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 319}, -- 25: speech bubble middle0001
		{x = 1115, y = 1960, width = 1162, height = 319, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 319}, -- 26: speech bubble middle0002
		{x = 1115, y = 1960, width = 1162, height = 319, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 319}, -- 27: speech bubble middle0003
		{x = 1115, y = 1960, width = 1162, height = 319, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 319}, -- 28: speech bubble middle0004
		{x = 2281, y = 1960, width = 1160, height = 310, offsetX = -4, offsetY = -4, offsetWidth = 1167, offsetHeight = 319}, -- 29: speech bubble middle0005
		{x = 2281, y = 1960, width = 1160, height = 310, offsetX = -4, offsetY = -4, offsetWidth = 1167, offsetHeight = 319}, -- 30: speech bubble middle0006
		{x = 2281, y = 1960, width = 1160, height = 310, offsetX = -4, offsetY = -4, offsetWidth = 1167, offsetHeight = 319}, -- 31: speech bubble middle0007
		{x = 2281, y = 1960, width = 1160, height = 310, offsetX = -4, offsetY = -4, offsetWidth = 1167, offsetHeight = 319}, -- 32: speech bubble middle0008
		{x = 2281, y = 1960, width = 1160, height = 310, offsetX = -4, offsetY = -4, offsetWidth = 1167, offsetHeight = 319}, -- 33: speech bubble middle0009
		{x = 4, y = 2376, width = 1161, height = 301, offsetX = -6, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 34: speech bubble middle0010
		{x = 4, y = 2376, width = 1161, height = 301, offsetX = -6, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 35: speech bubble middle0011
		{x = 4, y = 2376, width = 1161, height = 301, offsetX = -6, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 36: speech bubble middle0012
		{x = 4, y = 2376, width = 1161, height = 301, offsetX = -6, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 37: speech bubble middle0013
		{x = 4, y = 2376, width = 1161, height = 301, offsetX = -6, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 38: speech bubble middle0014
		{x = 1169, y = 2376, width = 1156, height = 301, offsetX = -9, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 39: speech bubble middle0015
		{x = 1169, y = 2376, width = 1156, height = 301, offsetX = -9, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 40: speech bubble middle0016
		{x = 1169, y = 2376, width = 1156, height = 301, offsetX = -9, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 41: speech bubble middle0017
		{x = 1169, y = 2376, width = 1156, height = 301, offsetX = -9, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 42: speech bubble middle0018
		{x = 1169, y = 2376, width = 1156, height = 301, offsetX = -9, offsetY = -6, offsetWidth = 1167, offsetHeight = 319}, -- 43: speech bubble middle0019
		{x = 2329, y = 2376, width = 1162, height = 328, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 328}, -- 44: speech bubble normal0000
		{x = 2329, y = 2376, width = 1162, height = 328, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 328}, -- 45: speech bubble normal0001
		{x = 2329, y = 2376, width = 1162, height = 328, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 328}, -- 46: speech bubble normal0002
		{x = 2329, y = 2376, width = 1162, height = 328, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 328}, -- 47: speech bubble normal0003
		{x = 2329, y = 2376, width = 1162, height = 328, offsetX = 0, offsetY = 0, offsetWidth = 1167, offsetHeight = 328}, -- 48: speech bubble normal0004
		{x = 4, y = 2708, width = 1160, height = 318, offsetX = -4, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 49: speech bubble normal0005
		{x = 4, y = 2708, width = 1160, height = 318, offsetX = -4, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 50: speech bubble normal0006
		{x = 4, y = 2708, width = 1160, height = 318, offsetX = -4, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 51: speech bubble normal0007
		{x = 4, y = 2708, width = 1160, height = 318, offsetX = -4, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 52: speech bubble normal0008
		{x = 4, y = 2708, width = 1160, height = 318, offsetX = -4, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 53: speech bubble normal0009
		{x = 1168, y = 2708, width = 1161, height = 315, offsetX = -6, offsetY = -1, offsetWidth = 1167, offsetHeight = 328}, -- 54: speech bubble normal0010
		{x = 1168, y = 2708, width = 1161, height = 315, offsetX = -6, offsetY = -1, offsetWidth = 1167, offsetHeight = 328}, -- 55: speech bubble normal0011
		{x = 1168, y = 2708, width = 1161, height = 315, offsetX = -6, offsetY = -1, offsetWidth = 1167, offsetHeight = 328}, -- 56: speech bubble normal0012
		{x = 1168, y = 2708, width = 1161, height = 315, offsetX = -6, offsetY = -1, offsetWidth = 1167, offsetHeight = 328}, -- 57: speech bubble normal0013
		{x = 1168, y = 2708, width = 1161, height = 315, offsetX = -6, offsetY = -1, offsetWidth = 1167, offsetHeight = 328}, -- 58: speech bubble normal0014
		{x = 2333, y = 2708, width = 1156, height = 311, offsetX = -9, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 59: speech bubble normal0015
		{x = 2333, y = 2708, width = 1156, height = 311, offsetX = -9, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 60: speech bubble normal0016
		{x = 2333, y = 2708, width = 1156, height = 311, offsetX = -9, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 61: speech bubble normal0017
		{x = 2333, y = 2708, width = 1156, height = 311, offsetX = -9, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 62: speech bubble normal0018
		{x = 2333, y = 2708, width = 1156, height = 311, offsetX = -9, offsetY = -5, offsetWidth = 1167, offsetHeight = 328}, -- 63: speech bubble normal0019
	},
	{
		["AHH speech bubble"] = {start = 1, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
		["AHH Speech Bubble middle"] = {start = 4, stop = 6, speed = 24, offsetX = 0, offsetY = 0},
		["Speech Bubble Middle Open"] = {start = 7, stop = 10, speed = 24, offsetX = 0, offsetY = 0},
		["Speech Bubble Normal Open"] = {start = 11, stop = 15, speed = 24, offsetX = 0, offsetY = 0},
		["speech bubble loud open"] = {start = 16, stop = 19, speed = 24, offsetX = 0, offsetY = 0},
		["speech bubble Middle loud open"] = {start = 20, stop = 23, speed = 24, offsetX = 0, offsetY = 0},
		["speech bubble middle"] = {start = 24, stop = 43, speed = 24, offsetX = 0, offsetY = 0},
		["speech bubble normal"] = {start = 44, stop = 63, speed = 24, offsetX = 0, offsetY = 0}
	},
	"AHH speech bubble"
)

return speech_bubble
