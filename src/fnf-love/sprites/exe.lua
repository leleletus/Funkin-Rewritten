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


local exe = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("exe")),
	{
		{x = 0, y = 0, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 1: puaj down0000
		{x = 297, y = 0, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 2: puaj down0001
		{x = 594, y = 0, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 3: puaj down0002
		{x = 891, y = 0, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 4: puaj down0003
		{x = 1188, y = 0, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 5: puaj down0004
		{x = 0, y = 334, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 6: puaj idle0000
		{x = 297, y = 334, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 7: puaj idle0001
		{x = 594, y = 334, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 8: puaj idle0002
		{x = 891, y = 334, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 9: puaj idle0003
		{x = 1188, y = 334, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 10: puaj idle0004
		{x = 0, y = 668, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 11: puaj idle0005
		{x = 297, y = 668, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 12: puaj idle0006
		{x = 594, y = 668, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 13: puaj idle0007
		{x = 891, y = 668, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 14: puaj idle0008
		{x = 1188, y = 668, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 15: puaj idle0009
		{x = 0, y = 1002, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 16: puaj left0000
		{x = 297, y = 1002, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 17: puaj left0001
		{x = 594, y = 1002, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 18: puaj left0002
		{x = 891, y = 1002, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 19: puaj left0003
		{x = 1188, y = 1002, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 20: puaj right0000
		{x = 0, y = 1336, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 21: puaj right0001
		{x = 297, y = 1336, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 22: puaj right0002
		{x = 594, y = 1336, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 23: puaj right0003
		{x = 891, y = 1336, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 24: puaj up0000
		{x = 1188, y = 1336, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 25: puaj up0001
		{x = 0, y = 1670, width = 297, height = 334, offsetX = 0, offsetY = 0, offsetWidth = 297, offsetHeight = 334}, -- 26: puaj up0002
	},
	{
		["down"] = {start = 1, stop = 5, speed = 24, offsetX = 0, offsetY = 0},
		["idle"] = {start = 6, stop = 15, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 16, stop = 19, speed = 24, offsetX = 0, offsetY = 0},
		["right"] = {start = 20, stop = 23, speed = 24, offsetX = 0, offsetY = 0},
		["up"] = {start = 24, stop = 26, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return exe
