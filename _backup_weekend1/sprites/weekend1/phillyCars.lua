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


local phillyCars = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/phillyStreets/phillyCars")),
	{
		{x = 2, y = 496, width = 438, height = 197, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: car10000
		{x = 2, y = 698, width = 470, height = 175, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: car20000
		{x = 2, y = 2, width = 463, height = 237, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: car30000
		{x = 2, y = 244, width = 443, height = 247, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: car40000
	},
	{
		["car1"] = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
		["car2"] = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
		["car3"] = {start = 3, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
		["car4"] = {start = 4, stop = 4, speed = 24, offsetX = 0, offsetY = 0}
	},
	"car1"
)

return phillyCars
