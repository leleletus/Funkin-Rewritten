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


local spaghetti = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("storymenu/props/spaghetti")),
	{
		{x = 4081, y = 1, width = 289, height = 243, offsetX = -2, offsetY = -14, offsetWidth = 300, offsetHeight = 260}, -- 1: SPL_00000
		{x = 4081, y = 1, width = 289, height = 243, offsetX = -2, offsetY = -14, offsetWidth = 300, offsetHeight = 260}, -- 2: SPL_00001
		{x = 3499, y = 1, width = 288, height = 240, offsetX = -3, offsetY = -15, offsetWidth = 300, offsetHeight = 260}, -- 3: SPL_00002
		{x = 3499, y = 1, width = 288, height = 240, offsetX = -3, offsetY = -15, offsetWidth = 300, offsetHeight = 260}, -- 4: SPL_00003
		{x = 1, y = 1, width = 288, height = 225, offsetX = -3, offsetY = -15, offsetWidth = 300, offsetHeight = 260}, -- 5: SPL_00004
		{x = 1, y = 1, width = 288, height = 225, offsetX = -3, offsetY = -15, offsetWidth = 300, offsetHeight = 260}, -- 6: SPL_00005
		{x = 292, y = 1, width = 289, height = 226, offsetX = -2, offsetY = -14, offsetWidth = 300, offsetHeight = 260}, -- 7: SPL_00006
		{x = 292, y = 1, width = 289, height = 226, offsetX = -2, offsetY = -14, offsetWidth = 300, offsetHeight = 260}, -- 8: SPL_00007
		{x = 584, y = 1, width = 288, height = 228, offsetX = -3, offsetY = -12, offsetWidth = 300, offsetHeight = 260}, -- 9: SPL_00008
		{x = 584, y = 1, width = 288, height = 228, offsetX = -3, offsetY = -12, offsetWidth = 300, offsetHeight = 260}, -- 10: SPL_00009
		{x = 875, y = 1, width = 288, height = 231, offsetX = -3, offsetY = -9, offsetWidth = 300, offsetHeight = 260}, -- 11: SPL_00010
		{x = 875, y = 1, width = 288, height = 231, offsetX = -3, offsetY = -9, offsetWidth = 300, offsetHeight = 260}, -- 12: SPL_00011
		{x = 1457, y = 1, width = 288, height = 235, offsetX = -3, offsetY = -5, offsetWidth = 300, offsetHeight = 260}, -- 13: SPL_00012
		{x = 1457, y = 1, width = 288, height = 235, offsetX = -3, offsetY = -5, offsetWidth = 300, offsetHeight = 260}, -- 14: SPL_00013
		{x = 2042, y = 1, width = 288, height = 236, offsetX = -3, offsetY = -4, offsetWidth = 300, offsetHeight = 260}, -- 15: SPL_00014
		{x = 2042, y = 1, width = 288, height = 236, offsetX = -3, offsetY = -4, offsetWidth = 300, offsetHeight = 260}, -- 16: SPL_00015
		{x = 2916, y = 1, width = 288, height = 237, offsetX = -3, offsetY = -3, offsetWidth = 300, offsetHeight = 260}, -- 17: SPL_00016
		{x = 2916, y = 1, width = 288, height = 237, offsetX = -3, offsetY = -3, offsetWidth = 300, offsetHeight = 260}, -- 18: SPL_00017
		{x = 3207, y = 1, width = 289, height = 237, offsetX = -2, offsetY = -3, offsetWidth = 300, offsetHeight = 260}, -- 19: SPL_00018
		{x = 3207, y = 1, width = 289, height = 237, offsetX = -2, offsetY = -3, offsetWidth = 300, offsetHeight = 260}, -- 20: SPL_00019
		{x = 2333, y = 1, width = 289, height = 236, offsetX = -2, offsetY = -4, offsetWidth = 300, offsetHeight = 260}, -- 21: SPL_00020
		{x = 2333, y = 1, width = 289, height = 236, offsetX = -2, offsetY = -4, offsetWidth = 300, offsetHeight = 260}, -- 22: SPL_00021
		{x = 1748, y = 1, width = 291, height = 235, offsetX = -2, offsetY = -5, offsetWidth = 300, offsetHeight = 260}, -- 23: SPL_00022
		{x = 1748, y = 1, width = 291, height = 235, offsetX = -2, offsetY = -5, offsetWidth = 300, offsetHeight = 260}, -- 24: SPL_00023
		{x = 1166, y = 1, width = 288, height = 231, offsetX = -3, offsetY = -9, offsetWidth = 300, offsetHeight = 260}, -- 25: SPL_00024
		{x = 1166, y = 1, width = 288, height = 231, offsetX = -3, offsetY = -9, offsetWidth = 300, offsetHeight = 260}, -- 26: SPL_00025
		{x = 2625, y = 1, width = 288, height = 236, offsetX = -3, offsetY = -12, offsetWidth = 300, offsetHeight = 260}, -- 27: SPL_00026
		{x = 2625, y = 1, width = 288, height = 236, offsetX = -3, offsetY = -12, offsetWidth = 300, offsetHeight = 260}, -- 28: SPL_00027
		{x = 3790, y = 1, width = 288, height = 242, offsetX = -3, offsetY = -13, offsetWidth = 300, offsetHeight = 260}, -- 29: SPL_00028
		{x = 3790, y = 1, width = 288, height = 242, offsetX = -3, offsetY = -13, offsetWidth = 300, offsetHeight = 260}, -- 30: SPL_00029
	},
	{
		["idle"] = {start = 1, stop = 30, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return spaghetti
