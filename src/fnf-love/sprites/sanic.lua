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


local sanic = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sanic")),
	{
		{x = 0, y = 0, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 1: sanic idle0000
		{x = 2052, y = 0, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 2: sanic idle0001
		{x = 4104, y = 0, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 3: sanic idle0002
		{x = 0, y = 2052, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 4: sanic idle0003
		{x = 2052, y = 2052, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 5: sanic down0000
		{x = 4104, y = 2052, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 6: sanic down0001
		{x = 0, y = 4104, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 7: sanic down0002
		{x = 2052, y = 4104, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 8: sanic down0003
		{x = 4104, y = 4104, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 9: sanic down0004
		{x = 0, y = 6156, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 10: sanic left0000
		{x = 2052, y = 6156, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 11: sanic left0001
		{x = 4104, y = 6156, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 12: sanic right0000
		{x = 0, y = 8208, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 13: sanic right0001
		{x = 2052, y = 8208, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 14: sanic up0000
		{x = 4104, y = 8208, width = 2052, height = 2052, offsetX = 0, offsetY = 0, offsetWidth = 2052, offsetHeight = 2052}, -- 15: sanic up0001
	},
	{
		["idle"] = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
		["down"] = {start = 5, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 10, stop = 11, speed = 24, offsetX = 0, offsetY = 0},
		["right"] = {start = 12, stop = 13, speed = 24, offsetX = 0, offsetY = 0},
		["up"] = {start = 14, stop = 15, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return sanic
