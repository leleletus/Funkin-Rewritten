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


local MajinBoppersFront = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("FunInfiniteStage/MajinBoppersFront")),
	{
		{x = 0, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: MajinBop1 instance 10000
		{x = 0, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: MajinBop1 instance 10001
		{x = 2118, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: MajinBop1 instance 10002
		{x = 2118, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: MajinBop1 instance 10003
		{x = 4236, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: MajinBop1 instance 10004
		{x = 4236, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: MajinBop1 instance 10005
		{x = 0, y = 1106, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: MajinBop1 instance 10006
		{x = 0, y = 1106, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: MajinBop1 instance 10007
		{x = 0, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: MajinBop1 instance 10008
		{x = 0, y = 0, width = 2118, height = 1106, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: MajinBop1 instance 10009
	},
	{
		["idle"] = {start = 1, stop = 10, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return MajinBoppersFront
