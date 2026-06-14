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


local Menu_Spooky_Kids = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_Spooky_Kids")),
	{
		{x = 0, y = 0, width = 176, height = 253, offsetX = -22, offsetY = 0, offsetWidth = 226, offsetHeight = 253}, -- 1: M Spooky Kids Idle0000
		{x = 0, y = 0, width = 176, height = 253, offsetX = -22, offsetY = 0, offsetWidth = 226, offsetHeight = 253}, -- 2: M Spooky Kids Idle0001
		{x = 180, y = 0, width = 175, height = 250, offsetX = -24, offsetY = -3, offsetWidth = 226, offsetHeight = 253}, -- 3: M Spooky Kids Idle0002
		{x = 180, y = 0, width = 175, height = 250, offsetX = -24, offsetY = -3, offsetWidth = 226, offsetHeight = 253}, -- 4: M Spooky Kids Idle0003
		{x = 359, y = 0, width = 165, height = 224, offsetX = -35, offsetY = -27, offsetWidth = 226, offsetHeight = 253}, -- 5: M Spooky Kids Idle0004
		{x = 359, y = 0, width = 165, height = 224, offsetX = -35, offsetY = -27, offsetWidth = 226, offsetHeight = 253}, -- 6: M Spooky Kids Idle0005
		{x = 528, y = 0, width = 164, height = 229, offsetX = -35, offsetY = -23, offsetWidth = 226, offsetHeight = 253}, -- 7: M Spooky Kids Idle0006
		{x = 528, y = 0, width = 164, height = 229, offsetX = -35, offsetY = -23, offsetWidth = 226, offsetHeight = 253}, -- 8: M Spooky Kids Idle0007
		{x = 696, y = 0, width = 226, height = 245, offsetX = 0, offsetY = -7, offsetWidth = 226, offsetHeight = 253}, -- 9: M Spooky Kids Idle0008
		{x = 696, y = 0, width = 226, height = 245, offsetX = 0, offsetY = -7, offsetWidth = 226, offsetHeight = 253}, -- 10: M Spooky Kids Idle0009
		{x = 0, y = 257, width = 221, height = 242, offsetX = -3, offsetY = -9, offsetWidth = 226, offsetHeight = 253}, -- 11: M Spooky Kids Idle0010
		{x = 0, y = 257, width = 221, height = 242, offsetX = -3, offsetY = -9, offsetWidth = 226, offsetHeight = 253}, -- 12: M Spooky Kids Idle0011
		{x = 359, y = 0, width = 165, height = 224, offsetX = -35, offsetY = -27, offsetWidth = 226, offsetHeight = 253}, -- 13: M Spooky Kids Idle0012
		{x = 359, y = 0, width = 165, height = 224, offsetX = -35, offsetY = -27, offsetWidth = 226, offsetHeight = 253}, -- 14: M Spooky Kids Idle0013
		{x = 528, y = 0, width = 164, height = 229, offsetX = -35, offsetY = -23, offsetWidth = 226, offsetHeight = 253}, -- 15: M Spooky Kids Idle0014
		{x = 528, y = 0, width = 164, height = 229, offsetX = -35, offsetY = -23, offsetWidth = 226, offsetHeight = 253}, -- 16: M Spooky Kids Idle0015
	},
	{
		["idle"] = {start = 1, stop = 16, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_Spooky_Kids
