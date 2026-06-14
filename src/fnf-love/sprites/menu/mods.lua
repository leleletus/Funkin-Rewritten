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


local menu_mods = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/mods")),
	{
		{x = 391, y = 186, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 1: mods idle0000
		{x = 391, y = 186, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 2: mods idle0001
		{x = 391, y = 186, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 3: mods idle0002
		{x = 0, y = 367, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 4: mods idle0003
		{x = 0, y = 367, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 5: mods idle0004
		{x = 0, y = 367, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 6: mods idle0005
		{x = 347, y = 367, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 7: mods idle0006
		{x = 347, y = 367, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 8: mods idle0007
		{x = 347, y = 367, width = 347, height = 125, offsetX = 0, offsetY = 0, offsetWidth = 346, offsetHeight = 123}, -- 9: mods idle0008
		{x = 394, y = 0, width = 395, height = 183, offsetX = 0, offsetY = 0, offsetWidth = 395, offsetHeight = 184}, -- 10: mods selected0000
		{x = 0, y = 0, width = 394, height = 186, offsetX = -1, offsetY = 0, offsetWidth = 395, offsetHeight = 184}, -- 11: mods selected0001
		{x = 0, y = 186, width = 391, height = 181, offsetX = -6, offsetY = 0, offsetWidth = 395, offsetHeight = 184}, -- 12: mods selected0002
	},
	{
		["idle"] = {start = 1, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["selected"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return menu_mods
