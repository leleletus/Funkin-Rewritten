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


local chaewon = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sserafim/char/chaewon")),
	{
		{x = 1542, y = 920, width = 284, height = 460, offsetX = -396, offsetY = -115, offsetWidth = 1280, offsetHeight = 720}, -- 1: idle0000
		{x = 1542, y = 0, width = 285, height = 460, offsetX = -395, offsetY = -115, offsetWidth = 1280, offsetHeight = 720}, -- 2: idle0001
		{x = 1542, y = 920, width = 284, height = 460, offsetX = -396, offsetY = -115, offsetWidth = 1280, offsetHeight = 720}, -- 3: idle0002
		{x = 0, y = 1869, width = 284, height = 456, offsetX = -395, offsetY = -122, offsetWidth = 1280, offsetHeight = 720}, -- 4: idle0003
		{x = 0, y = 1412, width = 284, height = 457, offsetX = -395, offsetY = -120, offsetWidth = 1280, offsetHeight = 720}, -- 5: idle0004
		{x = 1827, y = 919, width = 284, height = 458, offsetX = -395, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 6: idle0005
		{x = 418, y = 477, width = 285, height = 460, offsetX = -395, offsetY = -115, offsetWidth = 1280, offsetHeight = 720}, -- 7: idle0006
		{x = 1141, y = 1412, width = 284, height = 450, offsetX = -395, offsetY = -118, offsetWidth = 1280, offsetHeight = 720}, -- 8: down0000
		{x = 1425, y = 1412, width = 284, height = 446, offsetX = -395, offsetY = -120, offsetWidth = 1280, offsetHeight = 720}, -- 9: down0001
		{x = 857, y = 1412, width = 284, height = 450, offsetX = -395, offsetY = -118, offsetWidth = 1280, offsetHeight = 720}, -- 10: down0002
		{x = 284, y = 1412, width = 287, height = 452, offsetX = -392, offsetY = -123, offsetWidth = 1280, offsetHeight = 720}, -- 11: left0000
		{x = 1135, y = 938, width = 287, height = 456, offsetX = -392, offsetY = -119, offsetWidth = 1280, offsetHeight = 720}, -- 12: left0001
		{x = 848, y = 938, width = 287, height = 457, offsetX = -392, offsetY = -118, offsetWidth = 1280, offsetHeight = 720}, -- 13: left0002
		{x = 564, y = 938, width = 284, height = 462, offsetX = -395, offsetY = -112, offsetWidth = 1280, offsetHeight = 720}, -- 14: right0000
		{x = 1542, y = 460, width = 284, height = 460, offsetX = -395, offsetY = -114, offsetWidth = 1280, offsetHeight = 720}, -- 15: right0001
		{x = 1827, y = 460, width = 284, height = 459, offsetX = -395, offsetY = -115, offsetWidth = 1280, offsetHeight = 720}, -- 16: right0002
		{x = 703, y = 0, width = 280, height = 479, offsetX = -395, offsetY = -107, offsetWidth = 1280, offsetHeight = 720}, -- 17: up0000
		{x = 1262, y = 0, width = 280, height = 475, offsetX = -395, offsetY = -109, offsetWidth = 1280, offsetHeight = 720}, -- 18: up0001
		{x = 0, y = 938, width = 280, height = 474, offsetX = -395, offsetY = -110, offsetWidth = 1280, offsetHeight = 720}, -- 19: up0002
		{x = 1709, y = 1412, width = 284, height = 446, offsetX = -358, offsetY = -114, offsetWidth = 1280, offsetHeight = 720}, -- 20: down miss0000
		{x = 2393, y = 457, width = 280, height = 459, offsetX = -360, offsetY = -108, offsetWidth = 1280, offsetHeight = 720}, -- 21: down miss0001
		{x = 2393, y = 0, width = 283, height = 457, offsetX = -358, offsetY = -109, offsetWidth = 1280, offsetHeight = 720}, -- 22: down miss0002
		{x = 571, y = 1412, width = 286, height = 450, offsetX = -264, offsetY = -93, offsetWidth = 1280, offsetHeight = 720}, -- 23: left miss0000
		{x = 2111, y = 460, width = 282, height = 460, offsetX = -265, offsetY = -89, offsetWidth = 1280, offsetHeight = 720}, -- 24: left miss0001
		{x = 2111, y = 0, width = 282, height = 460, offsetX = -265, offsetY = -89, offsetWidth = 1280, offsetHeight = 720}, -- 25: left miss0002
		{x = 1827, y = 0, width = 284, height = 460, offsetX = -384, offsetY = -132, offsetWidth = 1280, offsetHeight = 720}, -- 26: right miss0000
		{x = 0, y = 0, width = 418, height = 464, offsetX = -248, offsetY = -133, offsetWidth = 1280, offsetHeight = 720}, -- 27: right miss0001
		{x = 280, y = 938, width = 284, height = 464, offsetX = -382, offsetY = -133, offsetWidth = 1280, offsetHeight = 720}, -- 28: right miss0002
		{x = 983, y = 0, width = 279, height = 478, offsetX = -350, offsetY = -105, offsetWidth = 1280, offsetHeight = 720}, -- 29: up miss0000
		{x = 418, y = 0, width = 285, height = 477, offsetX = -349, offsetY = -106, offsetWidth = 1280, offsetHeight = 720}, -- 30: up miss0001
		{x = 0, y = 464, width = 289, height = 474, offsetX = -346, offsetY = -108, offsetWidth = 1280, offsetHeight = 720}, -- 31: up miss0002
	},
	{
		["idle"] = {start = 1, stop = 7, speed = 12, offsetX = 0, offsetY = 0},
		["down"] = {start = 8, stop = 10, speed = 12, offsetX = 0, offsetY = 0},
		["left"] = {start = 11, stop = 13, speed = 12, offsetX = 0, offsetY = 0},
		["right"] = {start = 14, stop = 16, speed = 12, offsetX = 0, offsetY = 0},
		["up"] = {start = 17, stop = 19, speed = 12, offsetX = 0, offsetY = 0},
		["miss down"] = {start = 20, stop = 22, speed = 12, offsetX = -35, offsetY = -5},
		["miss left"] = {start = 23, stop = 25, speed = 12, offsetX = -130, offsetY = -30},
		["miss right"] = {start = 26, stop = 28, speed = 12, offsetX = -10, offsetY = 20},
		["miss up"] = {start = 29, stop = 31, speed = 12, offsetX = -45, offsetY = 0}
	},
	"idle"
)

return chaewon
