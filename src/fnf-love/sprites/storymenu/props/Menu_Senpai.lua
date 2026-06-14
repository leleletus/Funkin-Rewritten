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


local Menu_Senpai = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_Senpai")),
	{
		{x = 4, y = 4, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: M Senpai Idle0000
		{x = 4, y = 4, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: M Senpai Idle0001
		{x = 341, y = 4, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: M Senpai Idle0002
		{x = 341, y = 4, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: M Senpai Idle0003
		{x = 678, y = 4, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: M Senpai Idle0004
		{x = 678, y = 4, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: M Senpai Idle0005
		{x = 4, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: M Senpai Idle0006
		{x = 4, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: M Senpai Idle0007
		{x = 341, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: M Senpai Idle0008
		{x = 341, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: M Senpai Idle0009
		{x = 341, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: M Senpai Idle0010
		{x = 341, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: M Senpai Idle0011
		{x = 341, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13: M Senpai Idle0012
		{x = 341, y = 292, width = 337, height = 288, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14: M Senpai Idle0013
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_Senpai
