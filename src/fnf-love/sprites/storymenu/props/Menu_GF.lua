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


local Menu_GF = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_GF")),
	{
		{x = 4, y = 4, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 1: M GF Idle0000
		{x = 348, y = 4, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 2: M GF Idle0001
		{x = 692, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 3: M GF Idle0002
		{x = 692, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 4: M GF Idle0003
		{x = 692, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 5: M GF Idle0004
		{x = 1036, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 6: M GF Idle0005
		{x = 1036, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 7: M GF Idle0006
		{x = 1036, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 8: M GF Idle0007
		{x = 1380, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 9: M GF Idle0008
		{x = 1380, y = 4, width = 340, height = 310, offsetX = 0, offsetY = -3, offsetWidth = 340, offsetHeight = 313}, -- 10: M GF Idle0009
		{x = 4, y = 318, width = 338, height = 307, offsetX = -1, offsetY = -6, offsetWidth = 340, offsetHeight = 313}, -- 11: M GF Idle0010
		{x = 346, y = 318, width = 340, height = 307, offsetX = 0, offsetY = -6, offsetWidth = 340, offsetHeight = 313}, -- 12: M GF Idle0011
		{x = 690, y = 318, width = 340, height = 306, offsetX = 0, offsetY = -7, offsetWidth = 340, offsetHeight = 313}, -- 13: M GF Idle0012
		{x = 1034, y = 318, width = 340, height = 306, offsetX = 0, offsetY = -7, offsetWidth = 340, offsetHeight = 313}, -- 14: M GF Idle0013
		{x = 1378, y = 318, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 15: M GF Idle0014
		{x = 4, y = 630, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 16: M GF Idle0015
		{x = 348, y = 630, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 17: M GF Idle0016
		{x = 692, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 18: M GF Idle0017
		{x = 692, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: M GF Idle0018
		{x = 692, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 20: M GF Idle0019
		{x = 1036, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 21: M GF Idle0020
		{x = 1036, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 22: M GF Idle0021
		{x = 1036, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 23: M GF Idle0022
		{x = 1380, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 24: M GF Idle0023
		{x = 1380, y = 630, width = 340, height = 313, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: M GF Idle0024
		{x = 4, y = 947, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 26: M GF Idle0025
		{x = 4, y = 947, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 27: M GF Idle0026
		{x = 348, y = 947, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 28: M GF Idle0027
		{x = 692, y = 947, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 29: M GF Idle0028
		{x = 1036, y = 947, width = 340, height = 308, offsetX = 0, offsetY = -5, offsetWidth = 340, offsetHeight = 313}, -- 30: M GF Idle0029
	},
	{
		["idle"] = {start = 1, stop = 30, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_GF
