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


local Menu_Tankman = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_Tankman")),
	{
		{x = 4, y = 4, width = 192, height = 246, offsetX = -2, offsetY = -7, offsetWidth = 195, offsetHeight = 253}, -- 1: M Tankman Idle0000
		{x = 4, y = 4, width = 192, height = 246, offsetX = -2, offsetY = -7, offsetWidth = 195, offsetHeight = 253}, -- 2: M Tankman Idle0001
		{x = 196, y = 4, width = 193, height = 246, offsetX = -1, offsetY = -7, offsetWidth = 195, offsetHeight = 253}, -- 3: M Tankman Idle0002
		{x = 196, y = 4, width = 193, height = 246, offsetX = -1, offsetY = -7, offsetWidth = 195, offsetHeight = 253}, -- 4: M Tankman Idle0003
		{x = 389, y = 4, width = 192, height = 248, offsetX = 0, offsetY = -5, offsetWidth = 195, offsetHeight = 253}, -- 5: M Tankman Idle0004
		{x = 389, y = 4, width = 192, height = 248, offsetX = 0, offsetY = -5, offsetWidth = 195, offsetHeight = 253}, -- 6: M Tankman Idle0005
		{x = 581, y = 4, width = 192, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 7: M Tankman Idle0006
		{x = 773, y = 4, width = 193, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 8: M Tankman Idle0007
		{x = 4, y = 257, width = 193, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 9: M Tankman Idle0008
		{x = 4, y = 257, width = 193, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 10: M Tankman Idle0009
		{x = 4, y = 257, width = 193, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 11: M Tankman Idle0010
		{x = 4, y = 257, width = 193, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 12: M Tankman Idle0011
		{x = 4, y = 257, width = 193, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 13: M Tankman Idle0012
		{x = 4, y = 257, width = 193, height = 253, offsetX = 0, offsetY = 0, offsetWidth = 195, offsetHeight = 253}, -- 14: M Tankman Idle0013
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_Tankman
