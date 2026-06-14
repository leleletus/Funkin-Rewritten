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


local hitmarker = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("hitmarker")),
	{
		{x = 2, y = 2, width = 109, height = 109, offsetX = -13, offsetY = -12, offsetWidth = 135, offsetHeight = 134}, -- 1: hit0000
		{x = 113, y = 2, width = 111, height = 110, offsetX = -12, offsetY = -12, offsetWidth = 135, offsetHeight = 134}, -- 2: hit0001
		{x = 226, y = 2, width = 115, height = 116, offsetX = -10, offsetY = -9, offsetWidth = 135, offsetHeight = 134}, -- 3: hit0002
		{x = 343, y = 2, width = 123, height = 124, offsetX = -6, offsetY = -5, offsetWidth = 135, offsetHeight = 134}, -- 4: hit0003
		{x = 2, y = 128, width = 135, height = 134, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: hit0004
	},
	{
		["hit"] = {start = 1, stop = 5, speed = 24, offsetX = 0, offsetY = 0}
	},
	"hit"
)

return hitmarker
