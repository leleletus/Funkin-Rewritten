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


local storymode = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/storymode")),
	{
		{x = 0, y = 540, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: storymode idle0000
		{x = 0, y = 540, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: storymode idle0001
		{x = 0, y = 540, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: storymode idle0002
		{x = 0, y = 666, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: storymode idle0003
		{x = 0, y = 666, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: storymode idle0004
		{x = 0, y = 666, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: storymode idle0005
		{x = 0, y = 792, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: storymode idle0006
		{x = 0, y = 792, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: storymode idle0007
		{x = 0, y = 792, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: storymode idle0008
		{x = 0, y = 363, width = 796, height = 173, offsetX = 0, offsetY = -3, offsetWidth = 796, offsetHeight = 181}, -- 10: storymode selected0000
		{x = 0, y = 185, width = 794, height = 174, offsetX = -2, offsetY = -2, offsetWidth = 796, offsetHeight = 181}, -- 11: storymode selected0001
		{x = 0, y = 0, width = 794, height = 181, offsetX = 0, offsetY = 0, offsetWidth = 796, offsetHeight = 181}, -- 12: storymode selected0002
	},
	{
		["idle"] = {start = 1, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["selected"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return storymode
