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


local freeplay = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/freeplay")),
	{
		{x = 0, y = 524, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: freeplay idle0000
		{x = 0, y = 524, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: freeplay idle0001
		{x = 0, y = 524, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: freeplay idle0002
		{x = 0, y = 650, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: freeplay idle0003
		{x = 0, y = 650, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: freeplay idle0004
		{x = 0, y = 650, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: freeplay idle0005
		{x = 0, y = 776, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: freeplay idle0006
		{x = 0, y = 776, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: freeplay idle0007
		{x = 0, y = 776, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: freeplay idle0008
		{x = 0, y = 351, width = 627, height = 169, offsetX = 0, offsetY = 0, offsetWidth = 635, offsetHeight = 174}, -- 10: freeplay selected0000
		{x = 0, y = 177, width = 632, height = 170, offsetX = -3, offsetY = -1, offsetWidth = 635, offsetHeight = 174}, -- 11: freeplay selected0001
		{x = 0, y = 0, width = 629, height = 173, offsetX = -4, offsetY = -1, offsetWidth = 635, offsetHeight = 174}, -- 12: freeplay selected0002
	},
	{
		["idle"] = {start = 1, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["selected"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return freeplay
