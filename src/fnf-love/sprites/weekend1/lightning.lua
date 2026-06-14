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


local lightning = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/phillyBlazin/lightning")),
	{
		{x = 8, y = 8, width = 108, height = 339, offsetX = -91, offsetY = -1, offsetWidth = 206, offsetHeight = 347}, -- 1: lightning0001
		{x = 8, y = 363, width = 123, height = 313, offsetX = -62, offsetY = -27, offsetWidth = 206, offsetHeight = 347}, -- 2: lightning0002
		{x = 8, y = 692, width = 143, height = 267, offsetX = -27, offsetY = -11, offsetWidth = 206, offsetHeight = 347}, -- 3: lightning0003
		{x = 8, y = 975, width = 206, height = 347, offsetX = -0, offsetY = -0, offsetWidth = 206, offsetHeight = 347}, -- 4: lightning0004
		{x = 132, y = 8, width = 173, height = 281, offsetX = -4, offsetY = -12, offsetWidth = 206, offsetHeight = 347}, -- 5: lightning0005
		{x = 8, y = 1338, width = 173, height = 254, offsetX = -1, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 6: lightning0007
		{x = 147, y = 305, width = 173, height = 254, offsetX = -1, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 7: lightning0008
		{x = 8, y = 1608, width = 173, height = 254, offsetX = -1, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 8: lightning0009
		{x = 197, y = 1338, width = 173, height = 254, offsetX = -1, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 9: lightning0010
		{x = 167, y = 575, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 10: lightning0011
		{x = 321, y = 8, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 11: lightning0012
		{x = 197, y = 1608, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 12: lightning0013
		{x = 230, y = 845, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 13: lightning0014
		{x = 508, y = 8, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 14: lightning0015
		{x = 336, y = 278, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 15: lightning0016
		{x = 384, y = 1608, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 16: lightning0017
		{x = 695, y = 8, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 17: lightning0018
		{x = 354, y = 548, width = 171, height = 254, offsetX = -2, offsetY = -22, offsetWidth = 206, offsetHeight = 347}, -- 18: lightning0019
		{x = 386, y = 1115, width = 171, height = 253, offsetX = -2, offsetY = -23, offsetWidth = 206, offsetHeight = 347}, -- 19: lightning0020
		{x = 882, y = 8, width = 171, height = 252, offsetX = -2, offsetY = -23, offsetWidth = 206, offsetHeight = 347}, -- 20: lightning0021
		{x = 523, y = 278, width = 171, height = 252, offsetX = -2, offsetY = -23, offsetWidth = 206, offsetHeight = 347}, -- 21: lightning0022
		{x = 571, y = 1384, width = 171, height = 252, offsetX = -2, offsetY = -23, offsetWidth = 206, offsetHeight = 347}, -- 22: lightning0023
		{x = 417, y = 818, width = 170, height = 252, offsetX = -3, offsetY = -23, offsetWidth = 206, offsetHeight = 347}, -- 23: lightning0024
		{x = 882, y = 276, width = 170, height = 252, offsetX = -3, offsetY = -23, offsetWidth = 206, offsetHeight = 347}, -- 24: lightning0025
		{x = 1069, y = 8, width = 168, height = 251, offsetX = -4, offsetY = -23, offsetWidth = 206, offsetHeight = 347}, -- 25: lightning0026
		{x = 571, y = 1652, width = 166, height = 249, offsetX = -5, offsetY = -24, offsetWidth = 206, offsetHeight = 347}, -- 26: lightning0027
		{x = 8, y = 975, width = 206, height = 347, offsetX = -0, offsetY = -0, offsetWidth = 206, offsetHeight = 347}, -- 27: lightning0006
		{x = 8, y = 975, width = 206, height = 347, offsetX = -0, offsetY = -0, offsetWidth = 206, offsetHeight = 347}, -- 28: lightning0028
		{x = 8, y = 975, width = 206, height = 347, offsetX = -0, offsetY = -0, offsetWidth = 206, offsetHeight = 347}, -- 29: lightning0029
		{x = 8, y = 975, width = 206, height = 347, offsetX = -0, offsetY = -0, offsetWidth = 206, offsetHeight = 347}, -- 30: lightning0030
	},
	{
		["lightning"] = {start = 1, stop = 30, speed = 24, offsetX = 0, offsetY = 0}
	},
	"lightning"
)

return lightning
