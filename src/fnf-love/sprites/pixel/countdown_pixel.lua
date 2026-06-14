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


local img = love.graphics.newImage(graphics.imagePath("pixel/countdown_pixel"))
img:setFilter("nearest", "nearest")
local countdown_pixel = graphics.newSprite(
	img,
	{
		{x = 91, y = 0, width = 96, height = 41, offsetX = 2, offsetY = 2, offsetWidth = 92, offsetHeight = 37}, -- 1: date-pixel0000
		{x = 0, y = 0, width = 91, height = 45, offsetX = 2, offsetY = 2, offsetWidth = 87, offsetHeight = 41}, -- 2: ready-pixel0000
		{x = 0, y = 45, width = 84, height = 41, offsetX = 2, offsetY = 2, offsetWidth = 80, offsetHeight = 37}, -- 3: set-pixel0000
	},
	{
		["ready-pixel"] = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
		["set-pixel"] = {start = 3, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
		["date-pixel"] = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
	},
	"ready-pixel"
)

return countdown_pixel
