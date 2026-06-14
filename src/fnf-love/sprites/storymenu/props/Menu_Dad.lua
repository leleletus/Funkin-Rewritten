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


local Menu_Dad = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/Menu_Dad")),
	{
		{x = 4, y = 4, width = 206, height = 364, offsetX = 0, offsetY = -3, offsetWidth = 206, offsetHeight = 367}, -- 1: M Dad Idle0000
		{x = 4, y = 4, width = 206, height = 364, offsetX = 0, offsetY = -3, offsetWidth = 206, offsetHeight = 367}, -- 2: M Dad Idle0001
		{x = 210, y = 4, width = 205, height = 364, offsetX = 0, offsetY = -3, offsetWidth = 206, offsetHeight = 367}, -- 3: M Dad Idle0002
		{x = 210, y = 4, width = 205, height = 364, offsetX = 0, offsetY = -3, offsetWidth = 206, offsetHeight = 367}, -- 4: M Dad Idle0003
		{x = 415, y = 4, width = 204, height = 364, offsetX = -1, offsetY = -3, offsetWidth = 206, offsetHeight = 367}, -- 5: M Dad Idle0004
		{x = 415, y = 4, width = 204, height = 364, offsetX = -1, offsetY = -3, offsetWidth = 206, offsetHeight = 367}, -- 6: M Dad Idle0005
		{x = 619, y = 4, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 7: M Dad Idle0006
		{x = 619, y = 4, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 8: M Dad Idle0007
		{x = 4, y = 371, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 9: M Dad Idle0008
		{x = 4, y = 371, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 10: M Dad Idle0009
		{x = 206, y = 371, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 11: M Dad Idle0010
		{x = 206, y = 371, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 12: M Dad Idle0011
		{x = 206, y = 371, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 13: M Dad Idle0012
		{x = 206, y = 371, width = 202, height = 367, offsetX = -2, offsetY = 0, offsetWidth = 206, offsetHeight = 367}, -- 14: M Dad Idle0013
	},
	{
		["idle"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Menu_Dad
