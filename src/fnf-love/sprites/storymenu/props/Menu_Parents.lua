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


local Menu_Parents = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_Parents")),
	{
		{x = 0, y = 0, width = 420, height = 373, offsetX = -2, offsetY = -2, offsetWidth = 424, offsetHeight = 375}, -- 1: M Parents Idle0000
		{x = 0, y = 0, width = 420, height = 373, offsetX = -2, offsetY = -2, offsetWidth = 424, offsetHeight = 375}, -- 2: M Parents Idle0001
		{x = 424, y = 0, width = 420, height = 365, offsetX = 0, offsetY = -10, offsetWidth = 424, offsetHeight = 375}, -- 3: M Parents Idle0002
		{x = 424, y = 0, width = 420, height = 365, offsetX = 0, offsetY = -10, offsetWidth = 424, offsetHeight = 375}, -- 4: M Parents Idle0003
		{x = 848, y = 0, width = 421, height = 368, offsetX = -2, offsetY = -7, offsetWidth = 424, offsetHeight = 375}, -- 5: M Parents Idle0004
		{x = 848, y = 0, width = 421, height = 368, offsetX = -2, offsetY = -7, offsetWidth = 424, offsetHeight = 375}, -- 6: M Parents Idle0005
		{x = 1273, y = 0, width = 416, height = 373, offsetX = -8, offsetY = -2, offsetWidth = 424, offsetHeight = 375}, -- 7: M Parents Idle0006
		{x = 1273, y = 0, width = 416, height = 373, offsetX = -8, offsetY = -2, offsetWidth = 424, offsetHeight = 375}, -- 8: M Parents Idle0007
		{x = 0, y = 377, width = 416, height = 374, offsetX = -8, offsetY = -1, offsetWidth = 424, offsetHeight = 375}, -- 9: M Parents Idle0008
		{x = 0, y = 377, width = 416, height = 374, offsetX = -8, offsetY = -1, offsetWidth = 424, offsetHeight = 375}, -- 10: M Parents Idle0009
		{x = 420, y = 377, width = 416, height = 375, offsetX = -8, offsetY = 0, offsetWidth = 424, offsetHeight = 375}, -- 11: M Parents Idle0010
		{x = 420, y = 377, width = 416, height = 375, offsetX = -8, offsetY = 0, offsetWidth = 424, offsetHeight = 375}, -- 12: M Parents Idle0011
		{x = 420, y = 377, width = 416, height = 375, offsetX = -8, offsetY = 0, offsetWidth = 424, offsetHeight = 375}, -- 13: M Parents Idle0012
		{x = 420, y = 377, width = 416, height = 375, offsetX = -8, offsetY = 0, offsetWidth = 424, offsetHeight = 375}, -- 14: M Parents Idle0013
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_Parents
