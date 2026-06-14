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


local BloodSplash = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("BloodSplash")),
	{
		{x = 0, y = 0, width = 101, height = 65, offsetX = -70, offsetY = -43, offsetWidth = 242, offsetHeight = 150}, -- 1: Squirt0000
		{x = 0, y = 0, width = 101, height = 65, offsetX = -70, offsetY = -43, offsetWidth = 242, offsetHeight = 150}, -- 2: Squirt0001
		{x = 101, y = 0, width = 218, height = 128, offsetX = -12, offsetY = 0, offsetWidth = 242, offsetHeight = 150}, -- 3: Squirt0002
		{x = 101, y = 0, width = 218, height = 128, offsetX = -12, offsetY = 0, offsetWidth = 242, offsetHeight = 150}, -- 4: Squirt0003
		{x = 0, y = 128, width = 238, height = 141, offsetX = -2, offsetY = -3, offsetWidth = 242, offsetHeight = 150}, -- 5: Squirt0004
		{x = 0, y = 128, width = 238, height = 141, offsetX = -2, offsetY = -3, offsetWidth = 242, offsetHeight = 150}, -- 6: Squirt0005
		{x = 238, y = 128, width = 241, height = 133, offsetX = -1, offsetY = -17, offsetWidth = 242, offsetHeight = 150}, -- 7: Squirt0006
		{x = 238, y = 128, width = 241, height = 133, offsetX = -1, offsetY = -17, offsetWidth = 242, offsetHeight = 150}, -- 8: Squirt0007
		{x = 0, y = 269, width = 242, height = 85, offsetX = 0, offsetY = -37, offsetWidth = 242, offsetHeight = 150}, -- 9: Squirt0008
		{x = 0, y = 269, width = 242, height = 85, offsetX = 0, offsetY = -37, offsetWidth = 242, offsetHeight = 150}, -- 10: Squirt0009
		{x = 242, y = 269, width = 1, height = 1, offsetX = -42, offsetY = -6, offsetWidth = 242, offsetHeight = 150}, -- 11: Squirt0010
	},
	{
		["Squirt"] = {start = 1, stop = 11, speed = 24, offsetX = 0, offsetY = 0}
	},
	"Squirt"
)

return BloodSplash
