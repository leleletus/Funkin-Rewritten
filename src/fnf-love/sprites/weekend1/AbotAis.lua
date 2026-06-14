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

local AbotAis = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/char/AbotAis")),
	{
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 1: a bot eyes lookin0000
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 2: a bot eyes lookin0001
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 3: a bot eyes lookin0002
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 4: a bot eyes lookin0003
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 5: a bot eyes lookin0004
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 6: a bot eyes lookin0005
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 7: a bot eyes lookin0006
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 8: a bot eyes lookin0007
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 9: a bot eyes lookin0008
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 10: a bot eyes lookin0009
		{x = 0, y = 0, width = 106, height = 39, offsetX = -5, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 11: a bot eyes lookin0010
		{x = 0, y = 39, width = 79, height = 23, offsetX = -3, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 12: a bot eyes lookin0011
		{x = 0, y = 39, width = 79, height = 23, offsetX = -3, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 13: a bot eyes lookin0012
		{x = 0, y = 39, width = 79, height = 23, offsetX = -1, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 14: a bot eyes lookin0013
		{x = 0, y = 39, width = 79, height = 23, offsetX = -1, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 15: a bot eyes lookin0014
		{x = 0, y = 39, width = 79, height = 23, offsetX = -1, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 16: a bot eyes lookin0015
		{x = 0, y = 39, width = 79, height = 23, offsetX = 0, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 17: a bot eyes lookin0016
		{x = 0, y = 39, width = 79, height = 23, offsetX = 0, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 18: a bot eyes lookin0017
		{x = 0, y = 39, width = 79, height = 23, offsetX = 0, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 19: a bot eyes lookin0018
		{x = 0, y = 39, width = 79, height = 23, offsetX = 0, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 20: a bot eyes lookin0019
		{x = 0, y = 39, width = 79, height = 23, offsetX = 0, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 21: a bot eyes lookin0020
		{x = 0, y = 39, width = 79, height = 23, offsetX = 0, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 22: a bot eyes lookin0021
		{x = 0, y = 39, width = 79, height = 23, offsetX = -1, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 23: a bot eyes lookin0022
		{x = 0, y = 39, width = 79, height = 23, offsetX = -1, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 24: a bot eyes lookin0023
		{x = 0, y = 39, width = 79, height = 23, offsetX = -3, offsetY = -17, offsetWidth = 115, offsetHeight = 40}, -- 25: a bot eyes lookin0024
		{x = 0, y = 0, width = 106, height = 39, offsetX = -6, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 26: a bot eyes lookin0025
		{x = 0, y = 0, width = 106, height = 39, offsetX = -6, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 27: a bot eyes lookin0026
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 28: a bot eyes lookin0027
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 29: a bot eyes lookin0028
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 30: a bot eyes lookin0029
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40}, -- 31: a bot eyes lookin0030
		{x = 0, y = 0, width = 106, height = 39, offsetX = -9, offsetY = 0, offsetWidth = 115, offsetHeight = 40} -- 32: a bot eyes lookin0031
	},
	{
		["oponent"] = {start = 10, stop = 15, speed = 24, offsetX = 0, offsetY = 0},
		["player"] = {start = 15, stop = 30, speed = 24, offsetX = 0, offsetY = 0}
	},
	"player"
)

return AbotAis