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


local gf_truck = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("sserafim/char/gf_truck")),
	{
		{x = 1542, y = 1700, width = 379, height = 558, offsetX = -363, offsetY = -58, offsetWidth = 1280, offsetHeight = 720}, -- 1: dance left0000
		{x = 1110, y = 2272, width = 375, height = 555, offsetX = -360, offsetY = -61, offsetWidth = 1280, offsetHeight = 720}, -- 2: dance left0001
		{x = 1485, y = 2272, width = 375, height = 552, offsetX = -360, offsetY = -61, offsetWidth = 1280, offsetHeight = 720}, -- 3: dance left0002
		{x = 0, y = 2841, width = 368, height = 555, offsetX = -359, offsetY = -58, offsetWidth = 1280, offsetHeight = 720}, -- 4: dance left0003
		{x = 368, y = 2841, width = 368, height = 555, offsetX = -359, offsetY = -58, offsetWidth = 1280, offsetHeight = 720}, -- 5: dance left0004
		{x = 3940, y = 0, width = 363, height = 557, offsetX = -357, offsetY = -55, offsetWidth = 1280, offsetHeight = 720}, -- 6: dance left0005
		{x = 3213, y = 1134, width = 366, height = 564, offsetX = -355, offsetY = -48, offsetWidth = 1280, offsetHeight = 720}, -- 7: dance left0006
		{x = 2836, y = 0, width = 377, height = 570, offsetX = -346, offsetY = -42, offsetWidth = 1280, offsetHeight = 720}, -- 8: dance left0007
		{x = 0, y = 1700, width = 381, height = 572, offsetX = -343, offsetY = -40, offsetWidth = 1280, offsetHeight = 720}, -- 9: dance left0008
		{x = 1077, y = 1121, width = 390, height = 568, offsetX = -306, offsetY = -54, offsetWidth = 1280, offsetHeight = 720}, -- 10: dance right0000
		{x = 1467, y = 1121, width = 388, height = 564, offsetX = -312, offsetY = -57, offsetWidth = 1280, offsetHeight = 720}, -- 11: dance right0001
		{x = 381, y = 1700, width = 388, height = 561, offsetX = -312, offsetY = -58, offsetWidth = 1280, offsetHeight = 720}, -- 12: dance right0002
		{x = 1156, y = 1700, width = 386, height = 558, offsetX = -318, offsetY = -61, offsetWidth = 1280, offsetHeight = 720}, -- 13: dance right0003
		{x = 769, y = 1700, width = 387, height = 558, offsetX = -318, offsetY = -61, offsetWidth = 1280, offsetHeight = 720}, -- 14: dance right0004
		{x = 1921, y = 1700, width = 377, height = 557, offsetX = -322, offsetY = -60, offsetWidth = 1280, offsetHeight = 720}, -- 15: dance right0005
		{x = 3213, y = 1698, width = 364, height = 562, offsetX = -320, offsetY = -55, offsetWidth = 1280, offsetHeight = 720}, -- 16: dance right0006
		{x = 3579, y = 0, width = 361, height = 561, offsetX = -322, offsetY = -56, offsetWidth = 1280, offsetHeight = 720}, -- 17: dance right0007
		{x = 3213, y = 2260, width = 364, height = 561, offsetX = -321, offsetY = -56, offsetWidth = 1280, offsetHeight = 720}, -- 18: dance right0008
		{x = 769, y = 0, width = 767, height = 550, offsetX = -298, offsetY = -56, offsetWidth = 1280, offsetHeight = 720}, -- 19: down0000
		{x = 0, y = 0, width = 769, height = 554, offsetX = -296, offsetY = -53, offsetWidth = 1280, offsetHeight = 720}, -- 20: down0001
		{x = 0, y = 554, width = 606, height = 567, offsetX = -369, offsetY = -45, offsetWidth = 1280, offsetHeight = 720}, -- 21: left0000
		{x = 606, y = 554, width = 604, height = 567, offsetX = -371, offsetY = -46, offsetWidth = 1280, offsetHeight = 720}, -- 22: left0001
		{x = 743, y = 2272, width = 367, height = 568, offsetX = -392, offsetY = -42, offsetWidth = 1280, offsetHeight = 720}, -- 23: right0000
		{x = 3213, y = 0, width = 366, height = 567, offsetX = -389, offsetY = -43, offsetWidth = 1280, offsetHeight = 720}, -- 24: right0001
		{x = 2465, y = 1160, width = 360, height = 580, offsetX = -325, offsetY = -45, offsetWidth = 1280, offsetHeight = 720}, -- 25: up0000
		{x = 2465, y = 582, width = 363, height = 578, offsetX = -322, offsetY = -45, offsetWidth = 1280, offsetHeight = 720}, -- 26: up0001
		{x = 2836, y = 1721, width = 373, height = 549, offsetX = -348, offsetY = -66, offsetWidth = 1280, offsetHeight = 720}, -- 27: down miss0000
		{x = 2836, y = 1146, width = 373, height = 575, offsetX = -345, offsetY = -46, offsetWidth = 1280, offsetHeight = 720}, -- 28: down miss0001
		{x = 0, y = 2272, width = 376, height = 569, offsetX = -344, offsetY = -50, offsetWidth = 1280, offsetHeight = 720}, -- 29: down miss0002
		{x = 3213, y = 567, width = 365, height = 567, offsetX = -318, offsetY = -52, offsetWidth = 1280, offsetHeight = 720}, -- 30: left miss0000
		{x = 2465, y = 0, width = 371, height = 582, offsetX = -319, offsetY = -43, offsetWidth = 1280, offsetHeight = 720}, -- 31: left miss0001
		{x = 2089, y = 0, width = 376, height = 581, offsetX = -314, offsetY = -44, offsetWidth = 1280, offsetHeight = 720}, -- 32: left miss0002
		{x = 376, y = 2272, width = 367, height = 568, offsetX = -353, offsetY = -50, offsetWidth = 1280, offsetHeight = 720}, -- 33: right miss0000
		{x = 2836, y = 570, width = 373, height = 576, offsetX = -342, offsetY = -44, offsetWidth = 1280, offsetHeight = 720}, -- 34: right miss0001
		{x = 545, y = 1121, width = 532, height = 576, offsetX = -188, offsetY = -44, offsetWidth = 1280, offsetHeight = 720}, -- 35: right miss0002
		{x = 0, y = 1121, width = 545, height = 579, offsetX = -140, offsetY = -60, offsetWidth = 1280, offsetHeight = 720}, -- 36: up miss0000
		{x = 1536, y = 0, width = 553, height = 585, offsetX = -140, offsetY = -55, offsetWidth = 1280, offsetHeight = 720}, -- 37: up miss0001
		{x = 2089, y = 581, width = 366, height = 595, offsetX = -322, offsetY = -48, offsetWidth = 1280, offsetHeight = 720}, -- 38: up miss0002
	},
	{
		["dance left"] = {start = 1, stop = 9, speed = 12, offsetX = 20, offsetY = 0},
		["dance right"] = {start = 10, stop = 18, speed = 12, offsetX = -25, offsetY = 5},
		["down"] = {start = 19, stop = 20, speed = 12, offsetX = -50, offsetY = -5},
		["left"] = {start = 21, stop = 22, speed = 12, offsetX = 50, offsetY = -5},
		["right"] = {start = 23, stop = 24, speed = 12, offsetX = 40, offsetY = -5},
		["up"] = {start = 25, stop = 26, speed = 12, offsetX = -20, offsetY = 0},
		["miss down"] = {start = 27, stop = 29, speed = 12, offsetX = 0, offsetY = 5},
		["miss left"] = {start = 30, stop = 32, speed = 12, offsetX = -5, offsetY = 0},
		["miss right"] = {start = 33, stop = 35, speed = 12, offsetX = 0, offsetY = 0},
		["miss up"] = {start = 36, stop = 38, speed = 12, offsetX = -20, offsetY = 15},
		["idle"] = {start = 1, stop = 9, speed = 12, offsetX = 20, offsetY = 0},
		["sad"] = {start = 1, stop = 9, speed = 12, offsetX = 20, offsetY = 0}
	},
	"idle"
)

return gf_truck
