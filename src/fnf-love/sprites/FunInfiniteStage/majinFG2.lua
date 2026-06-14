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


local majinFG2 = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("FunInfiniteStage/majinFG2")),
	{
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 1: majin front bopper20000
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 2: majin front bopper20001
		{x = 424, y = 0, width = 443, height = 469, offsetX = 0, offsetY = -23, offsetWidth = 443, offsetHeight = 492}, -- 3: majin front bopper20002
		{x = 424, y = 0, width = 443, height = 469, offsetX = 0, offsetY = -23, offsetWidth = 443, offsetHeight = 492}, -- 4: majin front bopper20003
		{x = 0, y = 492, width = 439, height = 472, offsetX = -2, offsetY = -20, offsetWidth = 443, offsetHeight = 492}, -- 5: majin front bopper20004
		{x = 0, y = 492, width = 439, height = 472, offsetX = -2, offsetY = -20, offsetWidth = 443, offsetHeight = 492}, -- 6: majin front bopper20005
		{x = 439, y = 492, width = 429, height = 487, offsetX = -7, offsetY = -5, offsetWidth = 443, offsetHeight = 492}, -- 7: majin front bopper20006
		{x = 439, y = 492, width = 429, height = 487, offsetX = -7, offsetY = -5, offsetWidth = 443, offsetHeight = 492}, -- 8: majin front bopper20007
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 9: majin front bopper20008
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 10: majin front bopper20009
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 11: majin front bopper20010
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 12: majin front bopper20011
		{x = 424, y = 0, width = 443, height = 469, offsetX = 0, offsetY = -23, offsetWidth = 443, offsetHeight = 492}, -- 13: majin front bopper20012
		{x = 424, y = 0, width = 443, height = 469, offsetX = 0, offsetY = -23, offsetWidth = 443, offsetHeight = 492}, -- 14: majin front bopper20013
		{x = 0, y = 492, width = 439, height = 472, offsetX = -2, offsetY = -20, offsetWidth = 443, offsetHeight = 492}, -- 15: majin front bopper20014
		{x = 0, y = 492, width = 439, height = 472, offsetX = -2, offsetY = -20, offsetWidth = 443, offsetHeight = 492}, -- 16: majin front bopper20015
		{x = 439, y = 492, width = 429, height = 487, offsetX = -7, offsetY = -5, offsetWidth = 443, offsetHeight = 492}, -- 17: majin front bopper20016
		{x = 439, y = 492, width = 429, height = 487, offsetX = -7, offsetY = -5, offsetWidth = 443, offsetHeight = 492}, -- 18: majin front bopper20017
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 19: majin front bopper20018
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 20: majin front bopper20019
		{x = 0, y = 0, width = 424, height = 492, offsetX = -9, offsetY = 0, offsetWidth = 443, offsetHeight = 492}, -- 21: majin front bopper20020
	},
	{
		["idle"] = {start = 1, stop = 21, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return majinFG2
