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


local credits = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/credits")),
	{
		{x = 0, y = 0, width = 520, height = 172, offsetX = -2, offsetY = -0, offsetWidth = 522, offsetHeight = 172}, -- 1: credits selected0001
		{x = 0, y = 172, width = 520, height = 172, offsetX = -0, offsetY = -0, offsetWidth = 522, offsetHeight = 172}, -- 2: credits selected0002
		{x = 0, y = 344, width = 519, height = 172, offsetX = -2, offsetY = -0, offsetWidth = 522, offsetHeight = 172}, -- 3: credits selected0003
		{x = 0, y = 516, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 4: credits idle0001
		{x = 0, y = 516, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 5: credits idle0002
		{x = 0, y = 516, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 6: credits idle0003
		{x = 0, y = 640, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 7: credits idle0004
		{x = 0, y = 640, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 8: credits idle0005
		{x = 0, y = 640, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 9: credits idle0006
		{x = 0, y = 764, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 10: credits idle0007
		{x = 0, y = 764, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 11: credits idle0008
		{x = 0, y = 764, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124}, -- 12: credits idle0009
	},
	{
		["selected"] = {start = 1, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
		["idle"] = {start = 4, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return credits
