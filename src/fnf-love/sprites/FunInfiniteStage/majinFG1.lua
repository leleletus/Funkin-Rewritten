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


local majinFG1 = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("FunInfiniteStage/majinFG1")),
	{
		{x = 0, y = 0, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 1: majin front bopper10000
		{x = 0, y = 0, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 2: majin front bopper10001
		{x = 611, y = 0, width = 666, height = 504, offsetX = 0, offsetY = -23, offsetWidth = 666, offsetHeight = 527}, -- 3: majin front bopper10002
		{x = 611, y = 0, width = 666, height = 504, offsetX = 0, offsetY = -23, offsetWidth = 666, offsetHeight = 527}, -- 4: majin front bopper10003
		{x = 1277, y = 0, width = 654, height = 502, offsetX = -10, offsetY = -20, offsetWidth = 666, offsetHeight = 527}, -- 5: majin front bopper10004
		{x = 1277, y = 0, width = 654, height = 502, offsetX = -10, offsetY = -20, offsetWidth = 666, offsetHeight = 527}, -- 6: majin front bopper10005
		{x = 0, y = 505, width = 624, height = 505, offsetX = -35, offsetY = -5, offsetWidth = 666, offsetHeight = 527}, -- 7: majin front bopper10006
		{x = 0, y = 505, width = 624, height = 505, offsetX = -35, offsetY = -5, offsetWidth = 666, offsetHeight = 527}, -- 8: majin front bopper10007
		{x = 624, y = 505, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 9: majin front bopper10008
		{x = 624, y = 505, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 10: majin front bopper10009
		{x = 0, y = 0, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 11: majin front bopper10010
		{x = 0, y = 0, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 12: majin front bopper10011
		{x = 611, y = 0, width = 666, height = 504, offsetX = 0, offsetY = -23, offsetWidth = 666, offsetHeight = 527}, -- 13: majin front bopper10012
		{x = 611, y = 0, width = 666, height = 504, offsetX = 0, offsetY = -23, offsetWidth = 666, offsetHeight = 527}, -- 14: majin front bopper10013
		{x = 1235, y = 505, width = 654, height = 502, offsetX = -10, offsetY = -20, offsetWidth = 666, offsetHeight = 527}, -- 15: majin front bopper10014
		{x = 1235, y = 505, width = 654, height = 502, offsetX = -10, offsetY = -20, offsetWidth = 666, offsetHeight = 527}, -- 16: majin front bopper10015
		{x = 0, y = 505, width = 624, height = 505, offsetX = -35, offsetY = -5, offsetWidth = 666, offsetHeight = 527}, -- 17: majin front bopper10016
		{x = 0, y = 505, width = 624, height = 505, offsetX = -35, offsetY = -5, offsetWidth = 666, offsetHeight = 527}, -- 18: majin front bopper10017
		{x = 624, y = 505, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 19: majin front bopper10018
		{x = 624, y = 505, width = 611, height = 505, offsetX = -45, offsetY = 0, offsetWidth = 666, offsetHeight = 527}, -- 20: majin front bopper10019
	},
	{
		["idle"] = {start = 1, stop = 20, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return majinFG1
