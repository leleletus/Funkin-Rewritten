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


local eunchae = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sserafim/char/eunchae")),
	{
		{x = 1851, y = 2519, width = 616, height = 490, offsetX = -243, offsetY = -123, offsetWidth = 1280, offsetHeight = 720}, -- 1: idle0000
		{x = 1235, y = 2519, width = 616, height = 491, offsetX = -243, offsetY = -123, offsetWidth = 1280, offsetHeight = 720}, -- 2: idle0001
		{x = 2984, y = 994, width = 616, height = 494, offsetX = -243, offsetY = -120, offsetWidth = 1280, offsetHeight = 720}, -- 3: idle0002
		{x = 2984, y = 0, width = 616, height = 497, offsetX = -243, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 4: idle0003
		{x = 2984, y = 497, width = 616, height = 497, offsetX = -243, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 5: idle0004
		{x = 1851, y = 2016, width = 616, height = 497, offsetX = -243, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 6: idle0005
		{x = 1851, y = 2016, width = 616, height = 497, offsetX = -243, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 7: idle0006
		{x = 1851, y = 2016, width = 616, height = 497, offsetX = -243, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 8: idle0007
		{x = 618, y = 2519, width = 617, height = 494, offsetX = -236, offsetY = -121, offsetWidth = 1280, offsetHeight = 720}, -- 9: down0000
		{x = 1234, y = 2016, width = 617, height = 497, offsetX = -237, offsetY = -118, offsetWidth = 1280, offsetHeight = 720}, -- 10: down0001
		{x = 617, y = 2016, width = 617, height = 498, offsetX = -237, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 11: down0002
		{x = 0, y = 3013, width = 605, height = 497, offsetX = -244, offsetY = -117, offsetWidth = 1280, offsetHeight = 720}, -- 12: left0000
		{x = 2984, y = 1488, width = 608, height = 499, offsetX = -244, offsetY = -116, offsetWidth = 1280, offsetHeight = 720}, -- 13: left0001
		{x = 2984, y = 1987, width = 608, height = 499, offsetX = -244, offsetY = -116, offsetWidth = 1280, offsetHeight = 720}, -- 14: left0002
		{x = 1744, y = 0, width = 625, height = 504, offsetX = -243, offsetY = -113, offsetWidth = 1280, offsetHeight = 720}, -- 15: right0000
		{x = 1744, y = 1009, width = 623, height = 501, offsetX = -244, offsetY = -114, offsetWidth = 1280, offsetHeight = 720}, -- 16: right0001
		{x = 626, y = 1513, width = 623, height = 501, offsetX = -243, offsetY = -114, offsetWidth = 1280, offsetHeight = 720}, -- 17: right0002
		{x = 871, y = 502, width = 872, height = 497, offsetX = -248, offsetY = -118, offsetWidth = 1280, offsetHeight = 720}, -- 18: up0000
		{x = 0, y = 502, width = 871, height = 502, offsetX = -248, offsetY = -113, offsetWidth = 1280, offsetHeight = 720}, -- 19: up0001
		{x = 872, y = 0, width = 872, height = 502, offsetX = -248, offsetY = -113, offsetWidth = 1280, offsetHeight = 720}, -- 20: up0002
		{x = 0, y = 0, width = 872, height = 502, offsetX = -248, offsetY = -113, offsetWidth = 1280, offsetHeight = 720}, -- 21: up0003
		{x = 0, y = 2519, width = 618, height = 494, offsetX = -325, offsetY = -70, offsetWidth = 1280, offsetHeight = 720}, -- 22: down miss0000
		{x = 1744, y = 504, width = 620, height = 505, offsetX = -325, offsetY = -61, offsetWidth = 1280, offsetHeight = 720}, -- 23: down miss0001
		{x = 2369, y = 0, width = 615, height = 507, offsetX = -328, offsetY = -59, offsetWidth = 1280, offsetHeight = 720}, -- 24: down miss0002
		{x = 605, y = 3013, width = 605, height = 497, offsetX = -204, offsetY = -69, offsetWidth = 1280, offsetHeight = 720}, -- 25: left miss0000
		{x = 0, y = 2016, width = 617, height = 503, offsetX = -198, offsetY = -68, offsetWidth = 1280, offsetHeight = 720}, -- 26: left miss0001
		{x = 2369, y = 507, width = 614, height = 503, offsetX = -198, offsetY = -68, offsetWidth = 1280, offsetHeight = 720}, -- 27: left miss0002
		{x = 0, y = 1513, width = 626, height = 503, offsetX = -226, offsetY = -96, offsetWidth = 1280, offsetHeight = 720}, -- 28: right miss0000
		{x = 620, y = 1004, width = 619, height = 509, offsetX = -225, offsetY = -93, offsetWidth = 1280, offsetHeight = 720}, -- 29: right miss0001
		{x = 0, y = 1004, width = 620, height = 509, offsetX = -225, offsetY = -93, offsetWidth = 1280, offsetHeight = 720}, -- 30: right miss0002
		{x = 2369, y = 1516, width = 606, height = 497, offsetX = -294, offsetY = -96, offsetWidth = 1280, offsetHeight = 720}, -- 31: up miss0000
		{x = 1249, y = 1513, width = 617, height = 499, offsetX = -286, offsetY = -94, offsetWidth = 1280, offsetHeight = 720}, -- 32: up miss0001
		{x = 2369, y = 1010, width = 608, height = 506, offsetX = -292, offsetY = -89, offsetWidth = 1280, offsetHeight = 720}, -- 33: up miss0002
	},
	{
		["idle"] = {start = 1, stop = 8, speed = 12, offsetX = 0, offsetY = 0},
		["down"] = {start = 9, stop = 11, speed = 12, offsetX = 0, offsetY = 0},
		["left"] = {start = 12, stop = 14, speed = 12, offsetX = 0, offsetY = 0},
		["right"] = {start = 15, stop = 17, speed = 12, offsetX = 0, offsetY = 0},
		["up"] = {start = 18, stop = 21, speed = 12, offsetX = 0, offsetY = 0},
		["miss down"] = {start = 22, stop = 24, speed = 12, offsetX = 90, offsetY = -50},
		["miss left"] = {start = 25, stop = 27, speed = 12, offsetX = -40, offsetY = -50},
		["miss right"] = {start = 28, stop = 30, speed = 12, offsetX = -20, offsetY = -20},
		["miss up"] = {start = 31, stop = 33, speed = 12, offsetX = 45, offsetY = -25}
	},
	"idle"
)

return eunchae
