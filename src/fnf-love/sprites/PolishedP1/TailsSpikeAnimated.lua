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


local TailsSpikeAnimated = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("PolishedP1/TailsSpikeAnimated")),
	{
		{x = 0, y = 0, width = 237, height = 623, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: Tails Spike Animated instance 10000
		{x = 237, y = 0, width = 237, height = 623, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: Tails Spike Animated instance 10001
		{x = 474, y = 0, width = 237, height = 623, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: Tails Spike Animated instance 10002
		{x = 711, y = 0, width = 237, height = 623, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: Tails Spike Animated instance 10003
		{x = 948, y = 0, width = 237, height = 623, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: Tails Spike Animated instance 10004
	},
	{
		["idle"] = {start = 1, stop = 5, speed = 6, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return TailsSpikeAnimated
