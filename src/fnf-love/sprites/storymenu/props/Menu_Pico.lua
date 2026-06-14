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


local Menu_Pico = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_Pico")),
	{
		{x = 4, y = 4, width = 205, height = 217, offsetX = 0, offsetY = -6, offsetWidth = 213, offsetHeight = 224}, -- 1: M Pico Idle0000
		{x = 4, y = 4, width = 205, height = 217, offsetX = 0, offsetY = -6, offsetWidth = 213, offsetHeight = 224}, -- 2: M Pico Idle0001
		{x = 209, y = 4, width = 208, height = 220, offsetX = 0, offsetY = -3, offsetWidth = 213, offsetHeight = 224}, -- 3: M Pico Idle0002
		{x = 209, y = 4, width = 208, height = 220, offsetX = 0, offsetY = -3, offsetWidth = 213, offsetHeight = 224}, -- 4: M Pico Idle0003
		{x = 417, y = 4, width = 212, height = 221, offsetX = -1, offsetY = -3, offsetWidth = 213, offsetHeight = 224}, -- 5: M Pico Idle0004
		{x = 629, y = 4, width = 210, height = 221, offsetX = -3, offsetY = -3, offsetWidth = 213, offsetHeight = 224}, -- 6: M Pico Idle0005
		{x = 4, y = 225, width = 210, height = 223, offsetX = -3, offsetY = -1, offsetWidth = 213, offsetHeight = 224}, -- 7: M Pico Idle0006
		{x = 214, y = 225, width = 209, height = 223, offsetX = -4, offsetY = -1, offsetWidth = 213, offsetHeight = 224}, -- 8: M Pico Idle0007
		{x = 423, y = 225, width = 209, height = 224, offsetX = -4, offsetY = 0, offsetWidth = 213, offsetHeight = 224}, -- 9: M Pico Idle0008
		{x = 423, y = 225, width = 209, height = 224, offsetX = -4, offsetY = 0, offsetWidth = 213, offsetHeight = 224}, -- 10: M Pico Idle0009
		{x = 423, y = 225, width = 209, height = 224, offsetX = -4, offsetY = 0, offsetWidth = 213, offsetHeight = 224}, -- 11: M Pico Idle0010
		{x = 423, y = 225, width = 209, height = 224, offsetX = -4, offsetY = 0, offsetWidth = 213, offsetHeight = 224}, -- 12: M Pico Idle0011
		{x = 423, y = 225, width = 209, height = 224, offsetX = -4, offsetY = 0, offsetWidth = 213, offsetHeight = 224}, -- 13: M Pico Idle0012
		{x = 423, y = 225, width = 209, height = 224, offsetX = -4, offsetY = 0, offsetWidth = 213, offsetHeight = 224}, -- 14: M Pico Idle0013
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_Pico
