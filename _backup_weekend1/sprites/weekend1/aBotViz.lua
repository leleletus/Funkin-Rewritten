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


local aBotViz = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/char/aBotViz")),
	{
		{x = 212, y = 0, width = 68, height = 196, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: viz10000
		{x = 538, y = 0, width = 68, height = 169, offsetX = 0, offsetY = -27, offsetWidth = 68, offsetHeight = 196}, -- 2: viz10001
		{x = 538, y = 173, width = 65, height = 135, offsetX = -3, offsetY = -61, offsetWidth = 68, offsetHeight = 196}, -- 3: viz10002
		{x = 806, y = 195, width = 60, height = 96, offsetX = -8, offsetY = -100, offsetWidth = 68, offsetHeight = 196}, -- 4: viz10003
		{x = 928, y = 299, width = 53, height = 53, offsetX = -15, offsetY = -143, offsetWidth = 68, offsetHeight = 196}, -- 5: viz10004
		{x = 531, y = 312, width = 46, height = 28, offsetX = -22, offsetY = -168, offsetWidth = 68, offsetHeight = 196}, -- 6: viz10005
		{x = 407, y = 0, width = 58, height = 209, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: viz20000
		{x = 870, y = 0, width = 58, height = 183, offsetX = 0, offsetY = -26, offsetWidth = 58, offsetHeight = 209}, -- 8: viz20001
		{x = 607, y = 189, width = 57, height = 141, offsetX = -1, offsetY = -68, offsetWidth = 58, offsetHeight = 209}, -- 9: viz20002
		{x = 407, y = 213, width = 54, height = 99, offsetX = -4, offsetY = -110, offsetWidth = 58, offsetHeight = 209}, -- 10: viz20003
		{x = 741, y = 300, width = 48, height = 56, offsetX = -10, offsetY = -153, offsetWidth = 58, offsetHeight = 209}, -- 11: viz20004
		{x = 383, y = 316, width = 43, height = 27, offsetX = -15, offsetY = -182, offsetWidth = 58, offsetHeight = 209}, -- 12: viz20005
		{x = 284, y = 0, width = 58, height = 215, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13: viz30000
		{x = 747, y = 0, width = 58, height = 188, offsetX = 0, offsetY = -27, offsetWidth = 58, offsetHeight = 215}, -- 14: viz30001
		{x = 469, y = 182, width = 58, height = 151, offsetX = 0, offsetY = -64, offsetWidth = 58, offsetHeight = 215}, -- 15: viz30002
		{x = 212, y = 200, width = 55, height = 100, offsetX = -3, offsetY = -115, offsetWidth = 58, offsetHeight = 215}, -- 16: viz30003
		{x = 271, y = 286, width = 50, height = 57, offsetX = -8, offsetY = -158, offsetWidth = 58, offsetHeight = 215}, -- 17: viz30004
		{x = 668, y = 316, width = 45, height = 22, offsetX = -13, offsetY = -193, offsetWidth = 58, offsetHeight = 215}, -- 18: viz30005
		{x = 346, y = 0, width = 57, height = 216, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: viz40000
		{x = 809, y = 0, width = 57, height = 191, offsetX = 0, offsetY = -25, offsetWidth = 57, offsetHeight = 216}, -- 20: viz40001
		{x = 870, y = 187, width = 54, height = 153, offsetX = 0, offsetY = -63, offsetWidth = 57, offsetHeight = 216}, -- 21: viz40002
		{x = 132, y = 219, width = 52, height = 101, offsetX = 0, offsetY = -115, offsetWidth = 57, offsetHeight = 216}, -- 22: viz40003
		{x = 806, y = 295, width = 49, height = 58, offsetX = 0, offsetY = -158, offsetWidth = 57, offsetHeight = 216}, -- 23: viz40004
		{x = 109, y = 324, width = 44, height = 22, offsetX = -2, offsetY = -194, offsetWidth = 57, offsetHeight = 216}, -- 24: viz40005
		{x = 0, y = 0, width = 67, height = 207, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: viz60000
		{x = 469, y = 0, width = 65, height = 178, offsetX = 0, offsetY = -29, offsetWidth = 67, offsetHeight = 207}, -- 26: viz60001
		{x = 675, y = 168, width = 62, height = 144, offsetX = 0, offsetY = -63, offsetWidth = 67, offsetHeight = 207}, -- 27: viz60002
		{x = 71, y = 197, width = 57, height = 101, offsetX = 0, offsetY = -106, offsetWidth = 67, offsetHeight = 207}, -- 28: viz60003
		{x = 329, y = 220, width = 51, height = 61, offsetX = 0, offsetY = -146, offsetWidth = 67, offsetHeight = 207}, -- 29: viz60004
		{x = 188, y = 304, width = 45, height = 30, offsetX = 0, offsetY = -177, offsetWidth = 67, offsetHeight = 207}, -- 30: viz60005
		{x = 71, y = 0, width = 71, height = 193, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 31: viz70000
		{x = 675, y = 0, width = 68, height = 164, offsetX = 0, offsetY = -29, offsetWidth = 71, offsetHeight = 193}, -- 32: viz70001
		{x = 932, y = 0, width = 66, height = 139, offsetX = 0, offsetY = -54, offsetWidth = 71, offsetHeight = 193}, -- 33: viz70002
		{x = 741, y = 192, width = 61, height = 104, offsetX = 0, offsetY = -89, offsetWidth = 71, offsetHeight = 193}, -- 34: viz70003
		{x = 271, y = 219, width = 54, height = 63, offsetX = 0, offsetY = -130, offsetWidth = 71, offsetHeight = 193}, -- 35: viz70004
		{x = 59, y = 302, width = 46, height = 32, offsetX = 0, offsetY = -161, offsetWidth = 71, offsetHeight = 193}, -- 36: viz70005
		{x = 146, y = 0, width = 62, height = 215, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 37: viz50000
		{x = 610, y = 0, width = 61, height = 185, offsetX = 0, offsetY = -30, offsetWidth = 62, offsetHeight = 215}, -- 38: viz50001
		{x = 932, y = 143, width = 59, height = 152, offsetX = 0, offsetY = -63, offsetWidth = 62, offsetHeight = 215}, -- 39: viz50002
		{x = 0, y = 211, width = 55, height = 100, offsetX = 0, offsetY = -115, offsetWidth = 62, offsetHeight = 215}, -- 40: viz50003
		{x = 329, y = 285, width = 50, height = 60, offsetX = 0, offsetY = -155, offsetWidth = 62, offsetHeight = 215}, -- 41: viz50004
		{x = 0, y = 315, width = 46, height = 27, offsetX = 0, offsetY = -188, offsetWidth = 62, offsetHeight = 215}, -- 42: viz50005
	},
	{
		["viz1"] = {start = 1, stop = 6, speed = 24, offsetX = 0, offsetY = 0},
		["viz2"] = {start = 7, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
		["viz3"] = {start = 13, stop = 18, speed = 24, offsetX = 0, offsetY = 0},
		["viz4"] = {start = 19, stop = 24, speed = 24, offsetX = 0, offsetY = 0},
		["viz5"] = {start = 37, stop = 42, speed = 24, offsetX = 0, offsetY = 0},
		["viz6"] = {start = 25, stop = 30, speed = 24, offsetX = 0, offsetY = 0},
		["viz7"] = {start = 31, stop = 36, speed = 24, offsetX = 0, offsetY = 0}
	},
	"viz1"
)

return aBotViz
