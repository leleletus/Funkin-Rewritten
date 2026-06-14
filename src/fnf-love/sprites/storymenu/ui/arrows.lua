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


local arrows = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/ui/arrows")),
	{
		{x = 4, y = 4, width = 48, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: leftIdle0000
		{x = 56, y = 4, width = 47, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: rightIdle0000
		{x = 107, y = 4, width = 42, height = 75, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: leftConfirm0000
		{x = 153, y = 4, width = 41, height = 74, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: rightConfirm0000
	},
	{
		["leftIdle"] = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
		["rightIdle"] = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
		["leftConfirm"] = {start = 3, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
		["rightConfirm"] = {start = 4, stop = 4, speed = 24, offsetX = 0, offsetY = 0}
	},
	"leftIdle"
)

return arrows
