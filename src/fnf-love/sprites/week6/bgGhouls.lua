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


local bgGhoulsImage = love.graphics.newImage(graphics.imagePath("week6/bgGhouls"))
bgGhoulsImage:setFilter("nearest", "nearest")
local bgGhouls = graphics.newSprite(
	bgGhoulsImage,
	{
		{x = 0, y = 0, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: BG freaks glitch instance 10000
		{x = 0, y = 0, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: BG freaks glitch instance 10001
		{x = 453, y = 0, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: BG freaks glitch instance 10002
		{x = 453, y = 0, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: BG freaks glitch instance 10003
		{x = 0, y = 90, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: BG freaks glitch instance 10004
		{x = 0, y = 90, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: BG freaks glitch instance 10005
		{x = 453, y = 90, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: BG freaks glitch instance 10006
		{x = 453, y = 90, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: BG freaks glitch instance 10007
		{x = 0, y = 180, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: BG freaks glitch instance 10008
		{x = 0, y = 180, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: BG freaks glitch instance 10009
		{x = 453, y = 180, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: BG freaks glitch instance 10010
		{x = 453, y = 180, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: BG freaks glitch instance 10011
		{x = 0, y = 270, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13: BG freaks glitch instance 10012
		{x = 0, y = 270, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14: BG freaks glitch instance 10013
		{x = 453, y = 270, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 15: BG freaks glitch instance 10014
		{x = 453, y = 270, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 16: BG freaks glitch instance 10015
		{x = 0, y = 360, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 17: BG freaks glitch instance 10016
		{x = 0, y = 360, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 18: BG freaks glitch instance 10017
		{x = 453, y = 360, width = 453, height = 90, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: BG freaks glitch instance 10018
	},
	{
		["anim"] = {start = 1, stop = 19, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim"
)

return bgGhouls
