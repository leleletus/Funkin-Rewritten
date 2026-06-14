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


local Sonic_EXE_Assets = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("Sonic_EXE_Assets")),
	{
		{x = 0, y = 0, width = 450, height = 617, offsetX = -6, offsetY = 0, offsetWidth = 456, offsetHeight = 617}, -- 1: SONIClaugh0000
		{x = 450, y = 0, width = 442, height = 606, offsetX = -2, offsetY = -10, offsetWidth = 456, offsetHeight = 617}, -- 2: SONIClaugh0001
		{x = 892, y = 0, width = 440, height = 602, offsetX = -1, offsetY = -13, offsetWidth = 456, offsetHeight = 617}, -- 3: SONIClaugh0002
		{x = 1332, y = 0, width = 439, height = 601, offsetX = -1, offsetY = -14, offsetWidth = 456, offsetHeight = 617}, -- 4: SONIClaugh0003
		{x = 1771, y = 0, width = 439, height = 600, offsetX = 0, offsetY = -15, offsetWidth = 456, offsetHeight = 617}, -- 5: SONIClaugh0004
		{x = 2210, y = 0, width = 439, height = 600, offsetX = 0, offsetY = -15, offsetWidth = 456, offsetHeight = 617}, -- 6: SONIClaugh0005
		{x = 2649, y = 0, width = 438, height = 600, offsetX = 0, offsetY = -15, offsetWidth = 456, offsetHeight = 617}, -- 7: SONIClaugh0006
		{x = 2649, y = 0, width = 438, height = 600, offsetX = 0, offsetY = -15, offsetWidth = 456, offsetHeight = 617}, -- 8: SONIClaugh0007
		{x = 2649, y = 0, width = 438, height = 600, offsetX = 0, offsetY = -15, offsetWidth = 456, offsetHeight = 617}, -- 9: SONIClaugh0008
		{x = 2649, y = 0, width = 438, height = 600, offsetX = 0, offsetY = -15, offsetWidth = 456, offsetHeight = 617}, -- 10: SONIClaugh0009
		{x = 2649, y = 0, width = 438, height = 600, offsetX = 0, offsetY = -15, offsetWidth = 456, offsetHeight = 617}, -- 11: SONIClaugh0010
		{x = 3087, y = 0, width = 376, height = 559, offsetX = -2, offsetY = -52, offsetWidth = 379, offsetHeight = 612}, -- 12: SONICmoveDOWN0000
		{x = 3463, y = 0, width = 379, height = 587, offsetX = 0, offsetY = -25, offsetWidth = 379, offsetHeight = 612}, -- 13: SONICmoveDOWN0001
		{x = 3842, y = 0, width = 378, height = 601, offsetX = 0, offsetY = -11, offsetWidth = 379, offsetHeight = 612}, -- 14: SONICmoveDOWN0002
		{x = 4220, y = 0, width = 378, height = 603, offsetX = 0, offsetY = -9, offsetWidth = 379, offsetHeight = 612}, -- 15: SONICmoveDOWN0003
		{x = 4598, y = 0, width = 377, height = 602, offsetX = -1, offsetY = -10, offsetWidth = 379, offsetHeight = 612}, -- 16: SONICmoveDOWN0004
		{x = 4975, y = 0, width = 376, height = 608, offsetX = -1, offsetY = -4, offsetWidth = 379, offsetHeight = 612}, -- 17: SONICmoveDOWN0005
		{x = 5351, y = 0, width = 376, height = 609, offsetX = -1, offsetY = -3, offsetWidth = 379, offsetHeight = 612}, -- 18: SONICmoveDOWN0006
		{x = 5727, y = 0, width = 376, height = 611, offsetX = -1, offsetY = -1, offsetWidth = 379, offsetHeight = 612}, -- 19: SONICmoveDOWN0007
		{x = 6103, y = 0, width = 376, height = 611, offsetX = -1, offsetY = -1, offsetWidth = 379, offsetHeight = 612}, -- 20: SONICmoveDOWN0008
		{x = 6479, y = 0, width = 376, height = 612, offsetX = -1, offsetY = 0, offsetWidth = 379, offsetHeight = 612}, -- 21: SONICmoveDOWN0009
		{x = 6855, y = 0, width = 376, height = 612, offsetX = -1, offsetY = 0, offsetWidth = 379, offsetHeight = 612}, -- 22: SONICmoveDOWN0010
		{x = 7231, y = 0, width = 360, height = 605, offsetX = 0, offsetY = 0, offsetWidth = 369, offsetHeight = 606}, -- 23: SONICmoveIDLE0000
		{x = 7591, y = 0, width = 361, height = 605, offsetX = 0, offsetY = 0, offsetWidth = 369, offsetHeight = 606}, -- 24: SONICmoveIDLE0001
		{x = 0, y = 617, width = 361, height = 604, offsetX = -1, offsetY = -1, offsetWidth = 369, offsetHeight = 606}, -- 25: SONICmoveIDLE0002
		{x = 361, y = 617, width = 363, height = 603, offsetX = -4, offsetY = -2, offsetWidth = 369, offsetHeight = 606}, -- 26: SONICmoveIDLE0003
		{x = 724, y = 617, width = 363, height = 603, offsetX = -5, offsetY = -2, offsetWidth = 369, offsetHeight = 606}, -- 27: SONICmoveIDLE0004
		{x = 1087, y = 617, width = 363, height = 603, offsetX = -6, offsetY = -2, offsetWidth = 369, offsetHeight = 606}, -- 28: SONICmoveIDLE0005
		{x = 1450, y = 617, width = 363, height = 603, offsetX = -5, offsetY = -2, offsetWidth = 369, offsetHeight = 606}, -- 29: SONICmoveIDLE0006
		{x = 1813, y = 617, width = 363, height = 603, offsetX = -4, offsetY = -2, offsetWidth = 369, offsetHeight = 606}, -- 30: SONICmoveIDLE0007
		{x = 2176, y = 617, width = 361, height = 604, offsetX = -1, offsetY = -1, offsetWidth = 369, offsetHeight = 606}, -- 31: SONICmoveIDLE0008
		{x = 2537, y = 617, width = 361, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 369, offsetHeight = 606}, -- 32: SONICmoveIDLE0009
		{x = 7231, y = 0, width = 360, height = 605, offsetX = 0, offsetY = 0, offsetWidth = 369, offsetHeight = 606}, -- 33: SONICmoveIDLE0010
		{x = 2898, y = 617, width = 407, height = 578, offsetX = 0, offsetY = -9, offsetWidth = 408, offsetHeight = 587}, -- 34: SONICmoveLEFT0000
		{x = 3305, y = 617, width = 382, height = 587, offsetX = -25, offsetY = 0, offsetWidth = 408, offsetHeight = 587}, -- 35: SONICmoveLEFT0001
		{x = 3687, y = 617, width = 380, height = 579, offsetX = -27, offsetY = -8, offsetWidth = 408, offsetHeight = 587}, -- 36: SONICmoveLEFT0002
		{x = 4067, y = 617, width = 380, height = 572, offsetX = -27, offsetY = -15, offsetWidth = 408, offsetHeight = 587}, -- 37: SONICmoveLEFT0003
		{x = 4447, y = 617, width = 380, height = 576, offsetX = -27, offsetY = -11, offsetWidth = 408, offsetHeight = 587}, -- 38: SONICmoveLEFT0004
		{x = 4827, y = 617, width = 381, height = 577, offsetX = -27, offsetY = -10, offsetWidth = 408, offsetHeight = 587}, -- 39: SONICmoveLEFT0005
		{x = 5208, y = 617, width = 380, height = 577, offsetX = -27, offsetY = -10, offsetWidth = 408, offsetHeight = 587}, -- 40: SONICmoveLEFT0006
		{x = 5588, y = 617, width = 380, height = 577, offsetX = -27, offsetY = -10, offsetWidth = 408, offsetHeight = 587}, -- 41: SONICmoveLEFT0007
		{x = 5968, y = 617, width = 381, height = 577, offsetX = -27, offsetY = -10, offsetWidth = 408, offsetHeight = 587}, -- 42: SONICmoveLEFT0008
		{x = 6349, y = 617, width = 381, height = 578, offsetX = -27, offsetY = -9, offsetWidth = 408, offsetHeight = 587}, -- 43: SONICmoveLEFT0009
		{x = 6730, y = 617, width = 381, height = 578, offsetX = -27, offsetY = -9, offsetWidth = 408, offsetHeight = 587}, -- 44: SONICmoveLEFT0010
		{x = 7111, y = 617, width = 410, height = 592, offsetX = -4, offsetY = -6, offsetWidth = 414, offsetHeight = 598}, -- 45: SONICmoveRIGHT0000
		{x = 7521, y = 617, width = 385, height = 598, offsetX = -4, offsetY = 0, offsetWidth = 414, offsetHeight = 598}, -- 46: SONICmoveRIGHT0001
		{x = 0, y = 1223, width = 380, height = 578, offsetX = -4, offsetY = -20, offsetWidth = 414, offsetHeight = 598}, -- 47: SONICmoveRIGHT0002
		{x = 380, y = 1223, width = 379, height = 576, offsetX = -3, offsetY = -22, offsetWidth = 414, offsetHeight = 598}, -- 48: SONICmoveRIGHT0003
		{x = 759, y = 1223, width = 380, height = 576, offsetX = -1, offsetY = -22, offsetWidth = 414, offsetHeight = 598}, -- 49: SONICmoveRIGHT0004
		{x = 1139, y = 1223, width = 380, height = 581, offsetX = -1, offsetY = -17, offsetWidth = 414, offsetHeight = 598}, -- 50: SONICmoveRIGHT0005
		{x = 1519, y = 1223, width = 380, height = 582, offsetX = 0, offsetY = -16, offsetWidth = 414, offsetHeight = 598}, -- 51: SONICmoveRIGHT0006
		{x = 1899, y = 1223, width = 380, height = 582, offsetX = 0, offsetY = -16, offsetWidth = 414, offsetHeight = 598}, -- 52: SONICmoveRIGHT0007
		{x = 2279, y = 1223, width = 380, height = 582, offsetX = 0, offsetY = -16, offsetWidth = 414, offsetHeight = 598}, -- 53: SONICmoveRIGHT0008
		{x = 2659, y = 1223, width = 380, height = 582, offsetX = 0, offsetY = -16, offsetWidth = 414, offsetHeight = 598}, -- 54: SONICmoveRIGHT0009
		{x = 3039, y = 1223, width = 380, height = 582, offsetX = 0, offsetY = -16, offsetWidth = 414, offsetHeight = 598}, -- 55: SONICmoveRIGHT0010
		{x = 3419, y = 1223, width = 456, height = 670, offsetX = -1, offsetY = 0, offsetWidth = 461, offsetHeight = 670}, -- 56: SONICmoveUP0000
		{x = 3875, y = 1223, width = 455, height = 661, offsetX = -1, offsetY = -6, offsetWidth = 461, offsetHeight = 670}, -- 57: SONICmoveUP0001
		{x = 4330, y = 1223, width = 456, height = 647, offsetX = 0, offsetY = -19, offsetWidth = 461, offsetHeight = 670}, -- 58: SONICmoveUP0002
		{x = 4786, y = 1223, width = 461, height = 644, offsetX = 0, offsetY = -22, offsetWidth = 461, offsetHeight = 670}, -- 59: SONICmoveUP0003
		{x = 5247, y = 1223, width = 457, height = 646, offsetX = 0, offsetY = -19, offsetWidth = 461, offsetHeight = 670}, -- 60: SONICmoveUP0004
		{x = 5704, y = 1223, width = 456, height = 645, offsetX = 0, offsetY = -20, offsetWidth = 461, offsetHeight = 670}, -- 61: SONICmoveUP0005
		{x = 6160, y = 1223, width = 456, height = 645, offsetX = 0, offsetY = -20, offsetWidth = 461, offsetHeight = 670}, -- 62: SONICmoveUP0006
		{x = 6616, y = 1223, width = 456, height = 644, offsetX = 0, offsetY = -21, offsetWidth = 461, offsetHeight = 670}, -- 63: SONICmoveUP0007
		{x = 7072, y = 1223, width = 456, height = 643, offsetX = 0, offsetY = -22, offsetWidth = 461, offsetHeight = 670}, -- 64: SONICmoveUP0008
		{x = 7528, y = 1223, width = 456, height = 643, offsetX = 0, offsetY = -22, offsetWidth = 461, offsetHeight = 670}, -- 65: SONICmoveUP0009
		{x = 0, y = 1893, width = 456, height = 643, offsetX = 0, offsetY = -22, offsetWidth = 461, offsetHeight = 670}, -- 66: SONICmoveUP0010
		{x = 456, y = 1893, width = 354, height = 585, offsetX = -59, offsetY = -15, offsetWidth = 626, offsetHeight = 602}, -- 67: sonicImmagetya0000
		{x = 456, y = 1893, width = 354, height = 585, offsetX = -59, offsetY = -15, offsetWidth = 626, offsetHeight = 602}, -- 68: sonicImmagetya0001
		{x = 810, y = 1893, width = 356, height = 586, offsetX = -58, offsetY = -14, offsetWidth = 626, offsetHeight = 602}, -- 69: sonicImmagetya0002
		{x = 810, y = 1893, width = 356, height = 586, offsetX = -58, offsetY = -14, offsetWidth = 626, offsetHeight = 602}, -- 70: sonicImmagetya0003
		{x = 1166, y = 1893, width = 355, height = 587, offsetX = -58, offsetY = -13, offsetWidth = 626, offsetHeight = 602}, -- 71: sonicImmagetya0004
		{x = 1166, y = 1893, width = 355, height = 587, offsetX = -58, offsetY = -13, offsetWidth = 626, offsetHeight = 602}, -- 72: sonicImmagetya0005
		{x = 1521, y = 1893, width = 352, height = 590, offsetX = -58, offsetY = -11, offsetWidth = 626, offsetHeight = 602}, -- 73: sonicImmagetya0006
		{x = 1873, y = 1893, width = 352, height = 590, offsetX = -58, offsetY = -11, offsetWidth = 626, offsetHeight = 602}, -- 74: sonicImmagetya0007
		{x = 2225, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 75: sonicImmagetya0008
		{x = 2576, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 76: sonicImmagetya0009
		{x = 2927, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 77: sonicImmagetya0010
		{x = 2927, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 78: sonicImmagetya0011
		{x = 3278, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 79: sonicImmagetya0012
		{x = 3629, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 80: sonicImmagetya0013
		{x = 3980, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 81: sonicImmagetya0014
		{x = 4331, y = 1893, width = 351, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 82: sonicImmagetya0015
		{x = 4682, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 83: sonicImmagetya0016
		{x = 5034, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 84: sonicImmagetya0017
		{x = 5386, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 85: sonicImmagetya0018
		{x = 5738, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 86: sonicImmagetya0019
		{x = 5738, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 87: sonicImmagetya0020
		{x = 5738, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 88: sonicImmagetya0021
		{x = 6090, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 89: sonicImmagetya0022
		{x = 6090, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 90: sonicImmagetya0023
		{x = 6442, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 91: sonicImmagetya0024
		{x = 6442, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 92: sonicImmagetya0025
		{x = 6794, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 93: sonicImmagetya0026
		{x = 6794, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 94: sonicImmagetya0027
		{x = 6794, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 95: sonicImmagetya0028
		{x = 6794, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 96: sonicImmagetya0029
		{x = 6794, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 97: sonicImmagetya0030
		{x = 7146, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 98: sonicImmagetya0031
		{x = 7146, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 99: sonicImmagetya0032
		{x = 7146, y = 1893, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 100: sonicImmagetya0033
		{x = 7498, y = 1893, width = 349, height = 596, offsetX = -62, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 101: sonicImmagetya0034
		{x = 7498, y = 1893, width = 349, height = 596, offsetX = -62, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 102: sonicImmagetya0035
		{x = 0, y = 2536, width = 349, height = 594, offsetX = -60, offsetY = -7, offsetWidth = 626, offsetHeight = 602}, -- 103: sonicImmagetya0036
		{x = 0, y = 2536, width = 349, height = 594, offsetX = -60, offsetY = -7, offsetWidth = 626, offsetHeight = 602}, -- 104: sonicImmagetya0037
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 105: sonicImmagetya0038
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 106: sonicImmagetya0039
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 107: sonicImmagetya0040
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 108: sonicImmagetya0041
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 109: sonicImmagetya0042
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 110: sonicImmagetya0043
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 111: sonicImmagetya0044
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 112: sonicImmagetya0045
		{x = 349, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 113: sonicImmagetya0046
		{x = 701, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 114: sonicImmagetya0047
		{x = 701, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 115: sonicImmagetya0048
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 116: sonicImmagetya0049
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 117: sonicImmagetya0050
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 118: sonicImmagetya0051
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 119: sonicImmagetya0052
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 120: sonicImmagetya0053
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 121: sonicImmagetya0054
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 122: sonicImmagetya0055
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 123: sonicImmagetya0056
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 124: sonicImmagetya0057
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 125: sonicImmagetya0058
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 126: sonicImmagetya0059
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 127: sonicImmagetya0060
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 128: sonicImmagetya0061
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 129: sonicImmagetya0062
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 130: sonicImmagetya0063
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 131: sonicImmagetya0064
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 132: sonicImmagetya0065
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 133: sonicImmagetya0066
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 134: sonicImmagetya0067
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 135: sonicImmagetya0068
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 136: sonicImmagetya0069
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 137: sonicImmagetya0070
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 138: sonicImmagetya0071
		{x = 1053, y = 2536, width = 352, height = 591, offsetX = -57, offsetY = -10, offsetWidth = 626, offsetHeight = 602}, -- 139: sonicImmagetya0072
		{x = 1405, y = 2536, width = 348, height = 601, offsetX = -48, offsetY = 0, offsetWidth = 626, offsetHeight = 602}, -- 140: sonicImmagetya0073
		{x = 1405, y = 2536, width = 348, height = 601, offsetX = -48, offsetY = 0, offsetWidth = 626, offsetHeight = 602}, -- 141: sonicImmagetya0074
		{x = 1753, y = 2536, width = 354, height = 585, offsetX = -47, offsetY = -16, offsetWidth = 626, offsetHeight = 602}, -- 142: sonicImmagetya0075
		{x = 1753, y = 2536, width = 354, height = 585, offsetX = -47, offsetY = -16, offsetWidth = 626, offsetHeight = 602}, -- 143: sonicImmagetya0076
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 144: sonicImmagetya0077
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 145: sonicImmagetya0078
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 146: sonicImmagetya0079
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 147: sonicImmagetya0080
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 148: sonicImmagetya0081
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 149: sonicImmagetya0082
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 150: sonicImmagetya0083
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 151: sonicImmagetya0084
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 152: sonicImmagetya0085
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 153: sonicImmagetya0086
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 154: sonicImmagetya0087
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 155: sonicImmagetya0088
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 156: sonicImmagetya0089
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 157: sonicImmagetya0090
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 158: sonicImmagetya0091
		{x = 2107, y = 2536, width = 362, height = 596, offsetX = -47, offsetY = -5, offsetWidth = 626, offsetHeight = 602}, -- 159: sonicImmagetya0092
		{x = 2469, y = 2536, width = 335, height = 551, offsetX = -78, offsetY = -50, offsetWidth = 626, offsetHeight = 602}, -- 160: sonicImmagetya0093
		{x = 2469, y = 2536, width = 335, height = 551, offsetX = -78, offsetY = -50, offsetWidth = 626, offsetHeight = 602}, -- 161: sonicImmagetya0094
		{x = 2804, y = 2536, width = 338, height = 545, offsetX = -78, offsetY = -56, offsetWidth = 626, offsetHeight = 602}, -- 162: sonicImmagetya0095
		{x = 3142, y = 2536, width = 338, height = 543, offsetX = -78, offsetY = -56, offsetWidth = 626, offsetHeight = 602}, -- 163: sonicImmagetya0096
		{x = 3480, y = 2536, width = 342, height = 549, offsetX = -78, offsetY = -50, offsetWidth = 626, offsetHeight = 602}, -- 164: sonicImmagetya0097
		{x = 3822, y = 2536, width = 342, height = 549, offsetX = -78, offsetY = -50, offsetWidth = 626, offsetHeight = 602}, -- 165: sonicImmagetya0098
		{x = 4164, y = 2536, width = 342, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 166: sonicImmagetya0099
		{x = 4506, y = 2536, width = 352, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 167: sonicImmagetya0100
		{x = 4506, y = 2536, width = 352, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 168: sonicImmagetya0101
		{x = 4164, y = 2536, width = 342, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 169: sonicImmagetya0102
		{x = 4164, y = 2536, width = 342, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 170: sonicImmagetya0103
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 171: sonicImmagetya0104
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 172: sonicImmagetya0105
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 173: sonicImmagetya0106
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 174: sonicImmagetya0107
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 175: sonicImmagetya0108
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 176: sonicImmagetya0109
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 177: sonicImmagetya0110
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 178: sonicImmagetya0111
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 179: sonicImmagetya0112
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 180: sonicImmagetya0113
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 181: sonicImmagetya0114
		{x = 4858, y = 2536, width = 334, height = 551, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 182: sonicImmagetya0115
		{x = 5192, y = 2536, width = 348, height = 585, offsetX = -72, offsetY = -16, offsetWidth = 626, offsetHeight = 602}, -- 183: sonicImmagetya0116
		{x = 5192, y = 2536, width = 348, height = 585, offsetX = -72, offsetY = -16, offsetWidth = 626, offsetHeight = 602}, -- 184: sonicImmagetya0117
		{x = 5540, y = 2536, width = 345, height = 592, offsetX = -78, offsetY = -9, offsetWidth = 626, offsetHeight = 602}, -- 185: sonicImmagetya0118
		{x = 5540, y = 2536, width = 345, height = 592, offsetX = -78, offsetY = -9, offsetWidth = 626, offsetHeight = 602}, -- 186: sonicImmagetya0119
		{x = 5885, y = 2536, width = 348, height = 577, offsetX = -78, offsetY = -24, offsetWidth = 626, offsetHeight = 602}, -- 187: sonicImmagetya0120
		{x = 5885, y = 2536, width = 348, height = 577, offsetX = -78, offsetY = -24, offsetWidth = 626, offsetHeight = 602}, -- 188: sonicImmagetya0121
		{x = 6233, y = 2536, width = 350, height = 572, offsetX = -78, offsetY = -29, offsetWidth = 626, offsetHeight = 602}, -- 189: sonicImmagetya0122
		{x = 6233, y = 2536, width = 350, height = 572, offsetX = -78, offsetY = -29, offsetWidth = 626, offsetHeight = 602}, -- 190: sonicImmagetya0123
		{x = 6583, y = 2536, width = 353, height = 566, offsetX = -78, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 191: sonicImmagetya0124
		{x = 6936, y = 2536, width = 353, height = 566, offsetX = -78, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 192: sonicImmagetya0125
		{x = 7289, y = 2536, width = 356, height = 563, offsetX = -78, offsetY = -38, offsetWidth = 626, offsetHeight = 602}, -- 193: sonicImmagetya0126
		{x = 7645, y = 2536, width = 356, height = 563, offsetX = -78, offsetY = -38, offsetWidth = 626, offsetHeight = 602}, -- 194: sonicImmagetya0127
		{x = 0, y = 3137, width = 359, height = 562, offsetX = -78, offsetY = -40, offsetWidth = 626, offsetHeight = 602}, -- 195: sonicImmagetya0128
		{x = 359, y = 3137, width = 359, height = 562, offsetX = -78, offsetY = -40, offsetWidth = 626, offsetHeight = 602}, -- 196: sonicImmagetya0129
		{x = 718, y = 3137, width = 362, height = 558, offsetX = -78, offsetY = -43, offsetWidth = 626, offsetHeight = 602}, -- 197: sonicImmagetya0130
		{x = 1080, y = 3137, width = 361, height = 558, offsetX = -78, offsetY = -43, offsetWidth = 626, offsetHeight = 602}, -- 198: sonicImmagetya0131
		{x = 1441, y = 3137, width = 364, height = 555, offsetX = -78, offsetY = -45, offsetWidth = 626, offsetHeight = 602}, -- 199: sonicImmagetya0132
		{x = 1805, y = 3137, width = 364, height = 555, offsetX = -78, offsetY = -45, offsetWidth = 626, offsetHeight = 602}, -- 200: sonicImmagetya0133
		{x = 2169, y = 3137, width = 365, height = 552, offsetX = -78, offsetY = -47, offsetWidth = 626, offsetHeight = 602}, -- 201: sonicImmagetya0134
		{x = 2534, y = 3137, width = 365, height = 552, offsetX = -78, offsetY = -47, offsetWidth = 626, offsetHeight = 602}, -- 202: sonicImmagetya0135
		{x = 2899, y = 3137, width = 365, height = 550, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 203: sonicImmagetya0136
		{x = 3264, y = 3137, width = 365, height = 550, offsetX = -78, offsetY = -48, offsetWidth = 626, offsetHeight = 602}, -- 204: sonicImmagetya0137
		{x = 3629, y = 3137, width = 366, height = 548, offsetX = -78, offsetY = -50, offsetWidth = 626, offsetHeight = 602}, -- 205: sonicImmagetya0138
		{x = 3995, y = 3137, width = 365, height = 548, offsetX = -78, offsetY = -50, offsetWidth = 626, offsetHeight = 602}, -- 206: sonicImmagetya0139
		{x = 4360, y = 3137, width = 366, height = 546, offsetX = -78, offsetY = -52, offsetWidth = 626, offsetHeight = 602}, -- 207: sonicImmagetya0140
		{x = 4726, y = 3137, width = 366, height = 546, offsetX = -78, offsetY = -52, offsetWidth = 626, offsetHeight = 602}, -- 208: sonicImmagetya0141
		{x = 5092, y = 3137, width = 358, height = 555, offsetX = -78, offsetY = -43, offsetWidth = 626, offsetHeight = 602}, -- 209: sonicImmagetya0142
		{x = 5450, y = 3137, width = 358, height = 555, offsetX = -78, offsetY = -43, offsetWidth = 626, offsetHeight = 602}, -- 210: sonicImmagetya0143
		{x = 5808, y = 3137, width = 351, height = 558, offsetX = -78, offsetY = -40, offsetWidth = 626, offsetHeight = 602}, -- 211: sonicImmagetya0144
		{x = 5808, y = 3137, width = 351, height = 558, offsetX = -78, offsetY = -40, offsetWidth = 626, offsetHeight = 602}, -- 212: sonicImmagetya0145
		{x = 6159, y = 3137, width = 350, height = 569, offsetX = -78, offsetY = -30, offsetWidth = 626, offsetHeight = 602}, -- 213: sonicImmagetya0146
		{x = 6159, y = 3137, width = 350, height = 569, offsetX = -78, offsetY = -30, offsetWidth = 626, offsetHeight = 602}, -- 214: sonicImmagetya0147
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 215: sonicImmagetya0148
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 216: sonicImmagetya0149
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 217: sonicImmagetya0150
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 218: sonicImmagetya0151
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 219: sonicImmagetya0152
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 220: sonicImmagetya0153
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 221: sonicImmagetya0154
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 222: sonicImmagetya0155
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 223: sonicImmagetya0156
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 224: sonicImmagetya0157
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 225: sonicImmagetya0158
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 226: sonicImmagetya0159
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 227: sonicImmagetya0160
		{x = 6509, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 228: sonicImmagetya0161
		{x = 6859, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 229: sonicImmagetya0162
		{x = 6859, y = 3137, width = 350, height = 568, offsetX = -78, offsetY = -31, offsetWidth = 626, offsetHeight = 602}, -- 230: sonicImmagetya0163
		{x = 7209, y = 3137, width = 379, height = 554, offsetX = -78, offsetY = -47, offsetWidth = 626, offsetHeight = 602}, -- 231: sonicImmagetya0164
		{x = 7209, y = 3137, width = 379, height = 554, offsetX = -78, offsetY = -47, offsetWidth = 626, offsetHeight = 602}, -- 232: sonicImmagetya0165
		{x = 7588, y = 3137, width = 393, height = 555, offsetX = -20, offsetY = -47, offsetWidth = 626, offsetHeight = 602}, -- 233: sonicImmagetya0166
		{x = 7588, y = 3137, width = 393, height = 555, offsetX = -20, offsetY = -47, offsetWidth = 626, offsetHeight = 602}, -- 234: sonicImmagetya0167
		{x = 0, y = 3706, width = 413, height = 556, offsetX = 0, offsetY = -46, offsetWidth = 626, offsetHeight = 602}, -- 235: sonicImmagetya0168
		{x = 0, y = 3706, width = 413, height = 556, offsetX = 0, offsetY = -46, offsetWidth = 626, offsetHeight = 602}, -- 236: sonicImmagetya0169
		{x = 413, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 237: sonicImmagetya0170
		{x = 813, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 238: sonicImmagetya0171
		{x = 1213, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 239: sonicImmagetya0172
		{x = 1613, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 240: sonicImmagetya0173
		{x = 2013, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 241: sonicImmagetya0174
		{x = 2413, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 242: sonicImmagetya0175
		{x = 2413, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 243: sonicImmagetya0176
		{x = 2813, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 244: sonicImmagetya0177
		{x = 2813, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 245: sonicImmagetya0178
		{x = 3213, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 246: sonicImmagetya0179
		{x = 3213, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 247: sonicImmagetya0180
		{x = 3613, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 248: sonicImmagetya0181
		{x = 3613, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 249: sonicImmagetya0182
		{x = 3613, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 250: sonicImmagetya0183
		{x = 3613, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 251: sonicImmagetya0184
		{x = 3613, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 252: sonicImmagetya0185
		{x = 4013, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 253: sonicImmagetya0186
		{x = 4013, y = 3706, width = 400, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 254: sonicImmagetya0187
		{x = 4413, y = 3706, width = 414, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 255: sonicImmagetya0188
		{x = 4413, y = 3706, width = 414, height = 551, offsetX = -13, offsetY = -51, offsetWidth = 626, offsetHeight = 602}, -- 256: sonicImmagetya0189
		{x = 4827, y = 3706, width = 486, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 257: sonicImmagetya0190
		{x = 4827, y = 3706, width = 486, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 258: sonicImmagetya0191
		{x = 5313, y = 3706, width = 584, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 259: sonicImmagetya0192
		{x = 5897, y = 3706, width = 595, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 260: sonicImmagetya0193
		{x = 6492, y = 3706, width = 594, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 261: sonicImmagetya0194
		{x = 7086, y = 3706, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 262: sonicImmagetya0195
		{x = 0, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 263: sonicImmagetya0196
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 264: sonicImmagetya0197
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 265: sonicImmagetya0198
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 266: sonicImmagetya0199
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 267: sonicImmagetya0200
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 268: sonicImmagetya0201
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 269: sonicImmagetya0202
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 270: sonicImmagetya0203
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 271: sonicImmagetya0204
		{x = 4221, y = 4275, width = 617, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 272: sonicImmagetya0205
		{x = 4838, y = 4275, width = 619, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 273: sonicImmagetya0206
		{x = 5457, y = 4275, width = 621, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 274: sonicImmagetya0207
		{x = 6078, y = 4275, width = 579, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 275: sonicImmagetya0208
		{x = 6657, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 276: sonicImmagetya0209
		{x = 7251, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 277: sonicImmagetya0210
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 278: sonicImmagetya0211
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 279: sonicImmagetya0212
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 280: sonicImmagetya0213
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 281: sonicImmagetya0214
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 282: sonicImmagetya0215
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 283: sonicImmagetya0216
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 284: sonicImmagetya0217
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 285: sonicImmagetya0218
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 286: sonicImmagetya0219
		{x = 0, y = 4844, width = 579, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 287: sonicImmagetya0220
		{x = 579, y = 4844, width = 594, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 288: sonicImmagetya0221
		{x = 1173, y = 4844, width = 612, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 289: sonicImmagetya0222
		{x = 1785, y = 4844, width = 617, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 290: sonicImmagetya0223
		{x = 2402, y = 4844, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 291: sonicImmagetya0224
		{x = 7086, y = 3706, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 292: sonicImmagetya0225
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 293: sonicImmagetya0226
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 294: sonicImmagetya0227
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 295: sonicImmagetya0228
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 296: sonicImmagetya0229
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 297: sonicImmagetya0230
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 298: sonicImmagetya0231
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 299: sonicImmagetya0232
		{x = 579, y = 4844, width = 594, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 300: sonicImmagetya0233
		{x = 3021, y = 4844, width = 612, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 301: sonicImmagetya0234
		{x = 3633, y = 4844, width = 617, height = 569, offsetX = -5, offsetY = -33, offsetWidth = 626, offsetHeight = 602}, -- 302: sonicImmagetya0235
		{x = 4250, y = 4844, width = 619, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 303: sonicImmagetya0236
		{x = 5457, y = 4275, width = 621, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 304: sonicImmagetya0237
		{x = 4869, y = 4844, width = 579, height = 567, offsetX = -5, offsetY = -35, offsetWidth = 626, offsetHeight = 602}, -- 305: sonicImmagetya0238
		{x = 6657, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 306: sonicImmagetya0239
		{x = 7251, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 307: sonicImmagetya0240
		{x = 5448, y = 4844, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 308: sonicImmagetya0241
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 309: sonicImmagetya0242
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 310: sonicImmagetya0243
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 311: sonicImmagetya0244
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 312: sonicImmagetya0245
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 313: sonicImmagetya0246
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 314: sonicImmagetya0247
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 315: sonicImmagetya0248
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 316: sonicImmagetya0249
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 317: sonicImmagetya0250
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 318: sonicImmagetya0251
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 319: sonicImmagetya0252
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 320: sonicImmagetya0253
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 321: sonicImmagetya0254
		{x = 6065, y = 4844, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 322: sonicImmagetya0255
		{x = 0, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 323: sonicImmagetya0256
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 324: sonicImmagetya0257
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 325: sonicImmagetya0258
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 326: sonicImmagetya0259
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 327: sonicImmagetya0260
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 328: sonicImmagetya0261
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 329: sonicImmagetya0262
		{x = 579, y = 4275, width = 594, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 330: sonicImmagetya0263
		{x = 1173, y = 4275, width = 612, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 331: sonicImmagetya0264
		{x = 1785, y = 4275, width = 617, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 332: sonicImmagetya0265
		{x = 2402, y = 4275, width = 619, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 333: sonicImmagetya0266
		{x = 3021, y = 4275, width = 621, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 334: sonicImmagetya0267
		{x = 3642, y = 4275, width = 579, height = 561, offsetX = -5, offsetY = -41, offsetWidth = 626, offsetHeight = 602}, -- 335: sonicImmagetya0268
	},
	{
		["down alt"] = {start = 1, stop = 11, speed = 24, offsetX = 50, offsetY = -20},
		["down"] = {start = 12, stop = 22, speed = 24, offsetX = 115, offsetY = -20},
		["idle"] = {start = 23, stop = 33, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 34, stop = 44, speed = 24, offsetX = 160, offsetY = 0},
		["right"] = {start = 45, stop = 55, speed = 24, offsetX = 0, offsetY = 20},
		["up"] = {start = 56, stop = 66, speed = 24, offsetX = -20, offsetY = 20},
		["left alt"] = {start = 67, stop = 335, speed = 24, offsetX = -50, offsetY = 0},
	},
	"idle"
)
Sonic_EXE_Assets.isSonicEXE = true
return Sonic_EXE_Assets
