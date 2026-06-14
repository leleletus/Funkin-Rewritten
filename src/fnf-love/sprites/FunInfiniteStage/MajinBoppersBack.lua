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


local MajinBoppersBack = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("FunInfiniteStage/MajinBoppersBack")),
	{
		{x = 0, y = 0, width = 1197, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 1200, offsetHeight = 874}, -- 1: MajinBop2 instance 10000
		{x = 0, y = 0, width = 1197, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 1200, offsetHeight = 874}, -- 2: MajinBop2 instance 10001
		{x = 1197, y = 0, width = 1200, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: MajinBop2 instance 10002
		{x = 1197, y = 0, width = 1200, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: MajinBop2 instance 10003
		{x = 2397, y = 0, width = 1200, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: MajinBop2 instance 10004
		{x = 2397, y = 0, width = 1200, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: MajinBop2 instance 10005
		{x = 0, y = 874, width = 1198, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 1200, offsetHeight = 874}, -- 7: MajinBop2 instance 10006
		{x = 0, y = 874, width = 1198, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 1200, offsetHeight = 874}, -- 8: MajinBop2 instance 10007
		{x = 0, y = 0, width = 1197, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 1200, offsetHeight = 874}, -- 9: MajinBop2 instance 10008
		{x = 0, y = 0, width = 1197, height = 874, offsetX = 0, offsetY = 0, offsetWidth = 1200, offsetHeight = 874}, -- 10: MajinBop2 instance 10009
	},
	{
		["idle"] = {start = 1, stop = 10, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return MajinBoppersBack
