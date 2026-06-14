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


local options = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/options")),
	{
		{x = 0, y = 488, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: options idle0000
		{x = 0, y = 488, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: options idle0001
		{x = 0, y = 488, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: options idle0002
		{x = 0, y = 603, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: options idle0003
		{x = 0, y = 603, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: options idle0004
		{x = 0, y = 603, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: options idle0005
		{x = 0, y = 718, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: options idle0006
		{x = 0, y = 718, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: options idle0007
		{x = 0, y = 718, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: options idle0008
		{x = 0, y = 329, width = 606, height = 155, offsetX = -2, offsetY = -1, offsetWidth = 610, offsetHeight = 163}, -- 10: options selected0000
		{x = 0, y = 167, width = 607, height = 158, offsetX = -3, offsetY = -1, offsetWidth = 610, offsetHeight = 163}, -- 11: options selected0001
		{x = 0, y = 0, width = 610, height = 163, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: options selected0002
	},
	{
		["idle"] = {start = 1, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["selected"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return options
