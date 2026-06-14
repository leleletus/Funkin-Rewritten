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


local Menu_Mom = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_Mom")),
	{
		{x = 4, y = 4, width = 177, height = 379, offsetX = -1, offsetY = -1, offsetWidth = 178, offsetHeight = 380}, -- 1: M Mom Idle0000
		{x = 4, y = 4, width = 177, height = 379, offsetX = -1, offsetY = -1, offsetWidth = 178, offsetHeight = 380}, -- 2: M Mom Idle0001
		{x = 181, y = 4, width = 177, height = 374, offsetX = -1, offsetY = -6, offsetWidth = 178, offsetHeight = 380}, -- 3: M Mom Idle0002
		{x = 181, y = 4, width = 177, height = 374, offsetX = -1, offsetY = -6, offsetWidth = 178, offsetHeight = 380}, -- 4: M Mom Idle0003
		{x = 358, y = 4, width = 177, height = 377, offsetX = 0, offsetY = -3, offsetWidth = 178, offsetHeight = 380}, -- 5: M Mom Idle0004
		{x = 358, y = 4, width = 177, height = 377, offsetX = 0, offsetY = -3, offsetWidth = 178, offsetHeight = 380}, -- 6: M Mom Idle0005
		{x = 535, y = 4, width = 176, height = 378, offsetX = 0, offsetY = -2, offsetWidth = 178, offsetHeight = 380}, -- 7: M Mom Idle0006
		{x = 535, y = 4, width = 176, height = 378, offsetX = 0, offsetY = -2, offsetWidth = 178, offsetHeight = 380}, -- 8: M Mom Idle0007
		{x = 711, y = 4, width = 176, height = 379, offsetX = 0, offsetY = -1, offsetWidth = 178, offsetHeight = 380}, -- 9: M Mom Idle0008
		{x = 711, y = 4, width = 176, height = 379, offsetX = 0, offsetY = -1, offsetWidth = 178, offsetHeight = 380}, -- 10: M Mom Idle0009
		{x = 4, y = 383, width = 176, height = 380, offsetX = 0, offsetY = 0, offsetWidth = 178, offsetHeight = 380}, -- 11: M Mom Idle0010
		{x = 4, y = 383, width = 176, height = 380, offsetX = 0, offsetY = 0, offsetWidth = 178, offsetHeight = 380}, -- 12: M Mom Idle0011
		{x = 180, y = 383, width = 176, height = 380, offsetX = 0, offsetY = 0, offsetWidth = 178, offsetHeight = 380}, -- 13: M Mom Idle0012
		{x = 180, y = 383, width = 176, height = 380, offsetX = 0, offsetY = 0, offsetWidth = 178, offsetHeight = 380}, -- 14: M Mom Idle0013
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_Mom
