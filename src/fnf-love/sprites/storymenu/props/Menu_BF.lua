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


local Menu_BF = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_BF")),
	{
		{x = 4, y = 4, width = 326, height = 315, offsetX = 0, offsetY = -15, offsetWidth = 328, offsetHeight = 330}, -- 1: M BF Idle0000
		{x = 4, y = 4, width = 326, height = 315, offsetX = 0, offsetY = -15, offsetWidth = 328, offsetHeight = 330}, -- 2: M BF Idle0001
		{x = 335, y = 4, width = 324, height = 319, offsetX = -2, offsetY = -11, offsetWidth = 328, offsetHeight = 330}, -- 3: M BF Idle0002
		{x = 335, y = 4, width = 324, height = 319, offsetX = -2, offsetY = -11, offsetWidth = 328, offsetHeight = 330}, -- 4: M BF Idle0003
		{x = 664, y = 4, width = 328, height = 329, offsetX = 0, offsetY = -1, offsetWidth = 328, offsetHeight = 330}, -- 5: M BF Idle0004
		{x = 664, y = 4, width = 328, height = 329, offsetX = 0, offsetY = -1, offsetWidth = 328, offsetHeight = 330}, -- 6: M BF Idle0005
		{x = 4, y = 333, width = 327, height = 330, offsetX = -1, offsetY = 0, offsetWidth = 328, offsetHeight = 330}, -- 7: M BF Idle0006
		{x = 4, y = 333, width = 327, height = 330, offsetX = -1, offsetY = 0, offsetWidth = 328, offsetHeight = 330}, -- 8: M BF Idle0007
		{x = 4, y = 333, width = 327, height = 330, offsetX = -1, offsetY = 0, offsetWidth = 328, offsetHeight = 330}, -- 9: M BF Idle0008
		{x = 4, y = 333, width = 327, height = 330, offsetX = -1, offsetY = 0, offsetWidth = 328, offsetHeight = 330}, -- 10: M BF Idle0009
		{x = 4, y = 333, width = 327, height = 330, offsetX = -1, offsetY = 0, offsetWidth = 328, offsetHeight = 330}, -- 11: M BF Idle0010
		{x = 4, y = 333, width = 327, height = 330, offsetX = -1, offsetY = 0, offsetWidth = 328, offsetHeight = 330}, -- 12: M BF Idle0011
		{x = 336, y = 333, width = 325, height = 314, offsetX = 0, offsetY = -16, offsetWidth = 328, offsetHeight = 330}, -- 13: M BF Idle0012
		{x = 336, y = 333, width = 325, height = 314, offsetX = 0, offsetY = -16, offsetWidth = 328, offsetHeight = 330}, -- 14: M BF Idle0013
		{x = 666, y = 333, width = 316, height = 334, offsetX = 0, offsetY = 5, offsetWidth = 332, offsetHeight = 335}, -- 15: M bf HEY0000
		{x = 666, y = 333, width = 316, height = 334, offsetX = 0, offsetY = 5, offsetWidth = 332, offsetHeight = 335}, -- 16: M bf HEY0001
		{x = 4, y = 667, width = 331, height = 329, offsetX = 0, offsetY = -1, offsetWidth = 332, offsetHeight = 335}, -- 17: M bf HEY0002
		{x = 4, y = 667, width = 331, height = 329, offsetX = 0, offsetY = -1, offsetWidth = 332, offsetHeight = 335}, -- 18: M bf HEY0003
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 19: M bf HEY0004
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 20: M bf HEY0005
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 21: M bf HEY0006
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 22: M bf HEY0007
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 23: M bf HEY0008
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 24: M bf HEY0009
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 25: M bf HEY0010
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 26: M bf HEY0011
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 27: M bf HEY0012
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 28: M bf HEY0013
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 29: M bf HEY0014
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 30: M bf HEY0015
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 31: M bf HEY0016
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 32: M bf HEY0017
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 33: M bf HEY0018
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 34: M bf HEY0019
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 35: M bf HEY0020
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 36: M bf HEY0021
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 37: M bf HEY0022
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 38: M bf HEY0023
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 39: M bf HEY0024
		{x = 340, y = 667, width = 332, height = 330, offsetX = 0, offsetY = 0, offsetWidth = 332, offsetHeight = 335}, -- 40: M bf HEY0025
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0},
		["confirm"] = {start = 15, stop = 40, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_BF
